/* My Changes:
* I made some macro func's because i thought macro will make it much faster
* I also changed the min/max funcs to macros.
* I removed the struct 'pixel_sum' and instead used vars
* I did some loop unrolling, and gave up some functions like copyPixels, charsToPixels, PixelstoChars
* I tried to do multipication by shifting
*/

typedef struct {
    unsigned char R;
    unsigned char G;
    unsigned char B;
} pixel;
//We can give-up the other struct.



// Compute by macro the min and max of two integers
#define max(a,b) ((a) > (b) ? (a) : (b))
#define min(a,b) ((a) < (b) ? (a) : (b))

//Add appropriate values to the sum of the G/B/R of the pixel
#define plus(g,b,r, sG, sB, sR) ({g+=sG; b+=sB; r+=sR;})
#define minus(g,b,r, sG, sB, sR) ({g-=sG; b-=sB; r-=sR;})


//The Sharp func. Applys the kernel over each pixel.
//We need to ignore the pixels that are irrelevant (those which are out-of-bounds,
//with rol/col indexes that smaller than size/2
void makeItSharp(pixel *src, pixel *dst,register int sizeM) {

//Assign register-int instead of original int, which might put the value
//in register, which is faster
    register int i, j, Rsum, Bsum, Gsum, temp, d=sizeM;
    pixel current_pixel, p;

//Instead of the originial loop, we can do loop-unrolling
    for (i = 1 ; i < sizeM-1; ++i) {
        for (j = 1; j < sizeM-1; j++) {
            Rsum=0,Bsum=0,Gsum=0;
//Calculating the sum
            temp = (i-1)*sizeM +(j-1);
            p = *(src+temp);
            minus(Gsum,Bsum,Rsum,p.G,p.B,p.R);
            p = *(src+temp+1);
            minus(Gsum,Bsum,Rsum,p.G,p.B,p.R);
            p = *(src+temp+2);
            minus(Gsum,Bsum,Rsum,p.G,p.B,p.R);

            temp+=sizeM;
            p = *(src+temp);
            minus(Gsum,Bsum,Rsum,p.G,p.B,p.R);
            p = *(src+temp+1);

	    //Now the multi by 9
            Rsum+=(p.R) + (p.R << 3);
            Gsum+=(p.G) + (p.G << 3);
            Bsum+=(p.B) + (p.B << 3);
            p = *(src+temp +2);
            minus(Gsum,Bsum,Rsum,p.G,p.B,p.R);

            temp+=sizeM;
            p = *(src+temp);
            minus(Gsum,Bsum,Rsum,p.G,p.B,p.R);
            p = *(src+temp + 1);
            minus(Gsum,Bsum,Rsum,p.G,p.B,p.R);
            p = *(src+temp + 2);
            minus(Gsum,Bsum,Rsum,p.G,p.B,p.R);

            // truncate each pixel's color values to match the range [0,255]
            current_pixel.R = (min(max(Rsum, 0), 255));
            current_pixel.G =(min(max(Gsum, 0), 255));
            current_pixel.B = (min(max(Bsum, 0), 255));
            *(dst+d+j) = current_pixel;

        }
        d+=sizeM;
    }
}

//The Smooth Func
//We need to ignore the pixels that are irrelevant (those which are out-of-bounds,
//with rol/col indexes that smaller than size/2

void makeItBlur(pixel *src, pixel *dst,register int sizeM) {

//Assign register-int instead of original int, which might put the value
//in register, which is faster
    register int i=0, j=0, Rsum, Bsum, Gsum, x2, d=sizeM, limit = m;
    pixel p, current;

    // We can fill the frame and give-up the copy function
    for (i= 0; i<limit;i++){
        j+=sizeM;
        *(dst+i) = *(src+i);
    }
    for (i= j-sizeM; i <j;i++){
        *(dst+i) = *(src+i);
    }

    for (i = 1 ; i < limit -1; ++i) {
        *(dst+d) = *(src+d);
        *(dst+d+sizeM-1) = *(src+d+sizeM-1);
        for (j = 1; j < limit-1 ; ++j) {
	//Instead of the originial loop, we can do loop-unrolling
            Rsum=0,Bsum=0,Gsum=0;
            x2 = (i-1)*sizeM +(j-1);
            p = *(src+x2);

            plus(Gsum,Bsum,Rsum,p.G,p.B,p.R);
            p = *(src+x2+1);
            plus(Gsum,Bsum,Rsum,p.G,p.B,p.R);
	    p = *(src+x2+2);
            plus(Gsum,Bsum,Rsum,p.G,p.B,p.R);

            x2+=sizeM;
            p = *(src+x2);
            plus(Gsum,Bsum,Rsum,p.G,p.B,p.R);
            p = *(src+x2+1);
            plus(Gsum,Bsum,Rsum,p.G,p.B,p.R);
            p = *(src+x2+2);
            plus(Gsum,Bsum,Rsum,p.G,p.B,p.R);

            x2+=sizeM;
            p = *(src+x2);
            plus(Gsum,Bsum,Rsum,p.G,p.B,p.R);
            p = *(src+x2+1);
            plus(Gsum,Bsum,Rsum,p.G,p.B,p.R);
            p = *(src+x2+2);
            plus(Gsum,Bsum,Rsum,p.G,p.B,p.R);

            // truncate each pixel's color values to match the range [0,255]
            current.R = Rsum/9;
//(Rsum>>4)+(Rsum>>5)+(Rsum>>6)+(Rsum>>10)+(Rsum>>11)+(Rsum>>12)+(Rsum>>16);

            current.G = Gsum/9;
            current.B = Bsum/9;
            *(dst+d+j) = current;

        }
        d+=sizeM;
    }
}

void myfunction(Image *image, char* srcImgpName, char* blurRsltImgName, char* sharpRsltImgName) {

//Allocating memory
    pixel* pImage = malloc(m*n*sizeof(pixel));
    makeItBlur((pixel *) image->data, pImage,m);

    // make back up of pImage
    pixel* backUp = (pixel *) image->data;
    image->data = (char *) pImage;
    pImage = backUp;

    // write result image to file
    writeBMP(image, srcImgpName, blurRsltImgName);

    makeItSharp((pixel *) image->data,pImage,m);

    // make back up of pImage
    backUp = (pixel *) image->data;
    image->data = (char *) pImage;
    pImage = backUp;

    // write result image to file
    writeBMP(image, srcImgpName, sharpRsltImgName);

    //Free the allocated
    free(pImage);
}

