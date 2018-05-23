#include <stdio.h>
#include <string.h>

/**
 * Check which os is the flag
 * @param os - a flag of operating system (for example: -win) 
 * @return 1 for -win, 2 for -unix, 3 for -mac
 */
int checkOS(char *os);
/**
 * Modify the bytes we should write in the target file
 * @param targetFile The file we write to
 * @param current The current 2 bytes we write in
 * @param flag2 The target file os flag
 * @param shouldSwap true if user wrote -swap
 * @param bigEndian true if the file acts like big endian
 */
void encodeRules(FILE *targetFile, char *current, char *flag2, int shouldSwap, int bigEndian);

/**
 * Get the parameters from main func and start encoding according to them
 * @param srcName - name of source file
 * @param targetName - name of target file
 * @param flag1 - name of source os
 * @param flag2 - name of target os
 * @param swap - if user wrote -swap
 */
void startEncoding(char *srcName, char *targetName, char *flag1, char *flag2, char *swap);
/**
 * Write the bytes to the file
 * @param targetFile the target file
 * @param current the current bytes should be written
 * @param shouldSwap if the bytes should be swapped
 */
void fileWriting(FILE *targetFile, char *current, int shouldSwap);

//unix and mac line-signs, and boolean of whether the flag was -win
char* unixSign = "\n";
char* macSign = "\r";
int isWindows = 0;

int checkOS(char *os) {
    if (strcmp(os, "-win") == 0) {
        return 1;
    } else if (strcmp(os, "-unix") == 0) {
        return 2;
    } else if (strcmp(os, "-mac") == 0) {
        return 3;
    }
    return 0;
}

void encodeRules(FILE *targetFile, char *current, char *flag2, int shouldSwap, int bigEndian) {
   //Checks if the first byte should be written as 0 or the second
    int byteOrder = 1;
    if(bigEndian) {
        byteOrder--;
    }
    //Each letter contains 2 bytes, one with 0 and one with a sign
    //If the machine is BigEndian, then the first byte is 0
    current[byteOrder] = 0x00;

    int os = checkOS(flag2); // 1 for windows, 2 for unix, 3 for mac

    switch (os) {
        case 1: //windows
            current[1 - byteOrder] = 0x0d;
            fileWriting(targetFile, current, shouldSwap);
            //also continue to unix because we need also the \n
        case 2: //unix
            current[1 - byteOrder] = 0x0a;
            break;
        case 3: //mac
            current[1 - byteOrder] = 0x0d;
            break;
        default:
            break;
    }//end Switch
}

void fileWriting(FILE *targetFile, char *current, int shouldSwap) {

    //If user's input was -swap, then it swaps the order
    fwrite(&current[shouldSwap], 1, 1, targetFile);
    fwrite(&current[1 - shouldSwap], 1, 1, targetFile);
}

void startEncoding(char *srcName, char *targetName, char *flag1, char *flag2, char *swap) {

    //Open the source file and create the target file
    FILE *srcFile = fopen(srcName, "rb");
    if (srcFile == NULL) {
        return;
    }
    //create new file
    FILE *targetFile = fopen(targetName, "wb");

    // check if it should swap bytes
    int shouldSwap = ((swap != NULL) && (strcmp(swap, "-swap") == 0));
    char current[2]; // The char of the text that will be copied

    //case there are no flags, or two same OS
    if (((flag1 == NULL) && (flag2 == NULL))
        || (strcmp(flag1, flag2) == 0)) {
        while (fread(current, 2, 1, srcFile)) {
            fileWriting(targetFile, current, shouldSwap);
        }
        return;
    }
    //Case of different OS in the flags
    char *currentSign; // the source OS sign

    int os = checkOS(flag1);

    switch (os) {
        case 1: //windows
            isWindows = 1; // and continue to case 3
        case 3: //mac
            currentSign = macSign;
            break;
        case 2: // unix
            currentSign = unixSign;
            break;
        default:
            return;
    }

    fread(current, 2, 1, srcFile);
    // Reading 2 bytes, and runs as long as it contains information.
    do {
        if ((current[0] == *currentSign) && (current[1] == 0)
                || (current[0] == 0) && (current[1] == *currentSign)) {
            // Check if it is in big endian order
            int bigEndianOrder = (current[0] == 0) && (current[1] == *currentSign);

            if (isWindows) {
                fread(current, 2, 1, srcFile); //reading the next, because there's 2 signs
            }
            encodeRules(targetFile, current, flag2, shouldSwap, bigEndianOrder);
        }

        fileWriting(targetFile, current, shouldSwap);

    } while (fread(current, 2, 1, srcFile));

    fclose(srcFile);
    fclose(targetFile);
}

int main(int argc,char *argv[]) {
    //number of argumnets should be 2, 4 or 5
    //(there's additional argument of ex2's name)
    if((argc <= 2) || (argc == 4) || argc > 6) {
        return 0;
    }
    //If there is no "." in the source/target name
    if ((!strstr(argv[1], ".")) || (!strstr(argv[2], "."))) {
        return 0;
    }
    char *param3 = NULL;
    char *param4 = NULL;
    char *param5 = NULL;

    if(argc == 5) {
        param3 = argv[3];
        param4 = argv[4];
    }
    if(argc == 6) {
        param3 = argv[3];
        param4 = argv[4];
        param5 = argv[5];
    }
    //If we got parameters of 2 os, check that they are valid
    if (argc > 4) {
        if( !(checkOS(param3)) || !(checkOS(param4))) {
            return 0;
        }
    }

    startEncoding(argv[1], argv[2], param3, param4, param5);
}
