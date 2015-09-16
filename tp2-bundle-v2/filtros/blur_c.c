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
    int ancho = cols*4;

    unsigned char (*src_matrix)[ancho] = (unsigned char (*)[ancho]) src;
    unsigned char (*dst_matrix)[ancho] = (unsigned char (*)[ancho]) dst;

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
    float c = 0;
    for(int i= 0; i<radius*2+1; i++){
    	for(int j = 0; j<radius*2+1;j++){
    		c = c + matrizcomb[i][j];
    	}    	
    }
printf("%f ",c);
printf("\n\n\n\n\n\n");



    for(int i = radius; i < filas-radius; i++){
    	
    	for(int j = radius*4; j<ancho-radius*4; j = j + 4){
    				
    		float blue  = 0;
    		float green = 0;
    		float red   = 0;
            /*
    		int a = 0;
    		int b = 0;
            
    		for(int h = i  - radius*ancho; h < i + radius*ancho; h = h+ancho){    			
    			for(int k = j - radius*4; k < j + radius*4; k = k+4){    			
	    			blue  = blue  +src[h+k+0] *matrizcomb[a][b];
	    			green = green +src[h+k+1] *matrizcomb[a][b];
	    			red	  = red   +src[h+k+2] *matrizcomb[a][b];
	    			b++;
    			}
    			a++;
    		}
  		    */
            for (int h = 0; h<2*radius+1; h++){
                for (int k = 0; k<2*radius+1; k++){
                    //printf("%d\n", src_matrix[i+(h-radius)][j+(k-radius)*4]);
                    //printf("%f\n", matrizcomb[h][k]);

                    blue = blue + (src_matrix[i+(h-radius)][j+(k-radius)*4] * matrizcomb[h][k]);
                    green = green + (src_matrix[i+(h-radius)][j+(k-radius)*4+1] * matrizcomb[h][k]);
                    red = red + (src_matrix[i+(h-radius)][j+(k-radius)*4+2] * matrizcomb[h][k]);
                    //printf("%f\n",blue );
                    //printf("%f\n",green );
                    //printf("%f\n",red );

                }
            }


    	//printf("%f\n",blue );


    		unsigned char blue2 = blue;
    		unsigned char green2 = green;
    		unsigned char red2 = red;
    	//printf("%d\n",blue2 );
    		
    		dst_matrix[i][j]   = blue2;
    		dst_matrix[i][j+1] = green2;
    		dst_matrix[i][j+2] = red2;
    		dst_matrix[i][j+3] = 255;

    	
    	}
    }

}
