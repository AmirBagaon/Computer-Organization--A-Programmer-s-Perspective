#include "ex1.h"

int is_little_endian() {
    unsigned long a = 0x9876678955431122;
    unsigned short int *b = (unsigned short int *) &a;
    return (*b == 0x1122)? 1 : 0;
}


unsigned long merge_bytes(unsigned long x, unsigned long y) {

/*
* Notes: After a little research, to my understanding it suppose to work
* on both little&big Endian, because loading info from
* the memory to the processor is same as convert
* the number to big endian on either way.
* By the answer from:
* https://stackoverflow.com/questions/7184789/does-bit-shift-depend-on-endianness
*/
  
    //removes the least sign' BYTE of long x
    x = x >> 8;
    x = x << 8;

    //Get the only least BYTE of long y;
    unsigned long temp = 0x00000000000000FF;
    temp = temp & y;

    //Add them together
    x = (x + temp);
    return x;
}
unsigned long put_byte(unsigned long x, unsigned char b, int i) {
    //Each byte is 8 bits
    unsigned long temp = 0 | b; // 'insert' b to an unsigned long
    temp = temp << (8 * i); // move b to the appropriate place

    unsigned long zeros = 0x00000000000000FF; //create place for zeroes
    zeros = zeros << (8 * i); // move it to the appropriate place
    zeros = ~zeros; // change the f to 0 and vice versa
    x = x & zeros; // put 0 in x
    x = x | temp; // put b in x
    return x;
}
