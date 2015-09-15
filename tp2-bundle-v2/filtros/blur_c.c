#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include "../tp2.h"
#define M_PI 3.14159265358979323846
#define M_E 2.71828182846

void blur_c    (
    unsigned char *src,
    unsigned char *dst,
    int cols,
    int filas,
    float sigma,
    int radius)
{
    unsigned char (*src_matrix)[cols*4] = (unsigned char (*)[cols*4]) src;
    unsigned char (*dst_matrix)[cols*4] = (unsigned char (*)[cols*4]) dst;

    float matrizcomb[radius*2+1][radius*2+1];
    float primermultiplicando = 1/(2 * M_PI * pow(sigma,2));
    printf("%f\n",primermultiplicando );
    float potdividendo = 2*pow(sigma,2);
    printf("%f\n",potdividendo );

    for(int i= 0; i<radius*2+1; i++){
    	for(int j = 0; j<radius*2+1;j++){
    		float potencia = - ( (pow(radius-i,2) + pow(radius-j,2)) / potdividendo ) ;
    		//printf("%d\n",potencia );
    		matrizcomb[i][j]=primermultiplicando*pow(M_E,potencia);
    	}
    }

  for(int i= 0; i<radius*2+1; i++){
    	for(int j = 0; j<radius*2+1;j++){
    		printf("%f ",matrizcomb[i][j]);
    	}
    	printf("\n");
    }

/*
  for(int i= 0; i<radius*2+1; i++){
    	for(int j = 0; j<radius*2+1;j++){
    		matrizcomb[i][j]=1;
    	}
    }
*/


    for(int i = radius*cols; i < filas*cols; i= i + cols){
    	for(int j = radius*4; j<cols*4-radius*4; j = j + 4){
    				
    		float blue  = 0;
    		float green = 0;
    		float red   = 0;

    		int a = 0;
    		int b = 0;

    		for(int h = i  - radius; h < i + radius; h = h+cols){    			
    			for(int k = j - radius*4; k < j + radius; k = k+4){    			
	    			blue  = blue  +src[h+k+0] *matrizcomb[a][b];
	    			green = green +src[h+k+1] *matrizcomb[a][b];
	    			red	  = red   +src[h+k+2] *matrizcomb[a][b];
	    			b++;
    			}
    			a++;
    		}

    		unsigned char blue2 = blue;
    		unsigned char green2 = green;
    		unsigned char red2 = red;
    		
    		dst[i+j]   = blue2;
    		dst[i+j+1] = green2;
    		dst[i+j+2] = red2;
    		dst[i+j+3] = 255;

    	
    	}
    }

}
