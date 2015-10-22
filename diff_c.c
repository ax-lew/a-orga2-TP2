
#include <stdlib.h>
#include <math.h>
#include "../tp2.h"

int max(int a, int b){
	if (a<b){
		return b;
	} else{
		return a;
	}
}

void diff_c (
	unsigned char *src,
	unsigned char *src_2,
	unsigned char *dst,
	int m,
	int n,
	int src_row_size,
	int src_2_row_size,
	int dst_row_size
) {
	unsigned char (*src_matrix)[src_row_size] = (unsigned char (*)[src_row_size]) src;
	unsigned char (*src_2_matrix)[src_2_row_size] = (unsigned char (*)[src_2_row_size]) src_2;
	unsigned char (*dst_matrix)[dst_row_size] = (unsigned char (*)[dst_row_size]) dst;


	for(int i = 0; i<m; i++){
		for (int j = 0; j<n*4; j+=4){
			int blue = src[j+i*n*4] - src_2[j+i*n*4];
			int green = src[j+i*n*4+1] - src_2[j+i*n*4+1];
			int red = src[j+i*n*4+2] - src_2[j+i*n*4+2];
			blue = max(blue, -blue);
			green = max(green, -green);
			red = max(red, -red);
			int color = max(max(blue, green), red);
			unsigned char result = color;
			dst[j+i*n*4] = result;
			dst[j+i*n*4+1] = result;
			dst[j+i*n*4+2] = result;
			dst[j+i*n*4+3] = 255;			
		}
	}

}






