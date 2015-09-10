
#include <stdlib.h>
#include <math.h>
#include "../tp2.h"

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

}
