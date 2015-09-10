
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "../tp2.h"

void diff_asm  (unsigned char *src, unsigned char *src_2, unsigned char *dst,
                int cols, int filas, int src_row_size,
                int src_row_size_2 ,int dst_row_size);

void diff_c (unsigned char *src, unsigned char *src_2, unsigned char *dst,
            int cols, int filas, int src_row_size,
            int src_row_size_2 ,int dst_row_size);

typedef void (diff_fn_t) (unsigned char*, unsigned char*, unsigned char*,
                          int, int, int, int, int);

void ayuda_diff()
{
	printf ( "       * diff\n" );
	printf ( "           Parámetros     : \n"
	         "                         no tiene\n");
	printf ( "           Ejemplo de uso : \n"
	         "                         diff -i c facil.bmp facil2.bmp\n" );
}

void leer_params_diff(configuracion_t *config, int argc, char *argv[]) {
    if (config->archivo_entrada_2 == NULL) {
        printf("El filtro diff requiere de dos archivos de entrada\n\n");
        ayuda_diff();
        exit(EXIT_FAILURE);
    } else {
        printf ( "  Archivo de entrada : %s\n", config->archivo_entrada_2);
    }
}

void aplicar_diff(configuracion_t *config)
{
	diff_fn_t *diff = SWITCH_C_ASM ( config, diff_c, diff_asm ) ;
	buffer_info_t info = config->src;
	buffer_info_t info2 = config->src_2;
    if (info.width != info2.width || info.height != info2.height) {
        perror("Las imagenes deben tener el mismo tamaño en pixeles");
    }
	diff(info.bytes, info2.bytes, config->dst.bytes, info.width, info.height,
         info.width_with_padding, info2.width_with_padding,
         config->dst.width_with_padding);

}
