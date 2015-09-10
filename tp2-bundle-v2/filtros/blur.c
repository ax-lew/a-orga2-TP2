
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include "../tp2.h"

void blur_asm    (unsigned char *src, unsigned char *dst, int cols, int filas,
                      float sigma, int radius);

void blur_c    (unsigned char *src, unsigned char *dst, int cols, int filas,
                      float sigma, int radius);

typedef void (blur_fn_t) (unsigned char*, unsigned char*, int, int, float, int);

typedef struct blur_params_t {
	float sigma;
    int radius;
} blur_params_t;

blur_params_t extra;
void leer_params_blur(configuracion_t *config, int argc, char *argv[]) {
    config->extra_config = &extra;
    extra.sigma    = atof(argv[argc - 2]);
    extra.radius    = atoi(argv[argc - 1]);
}



void aplicar_blur(configuracion_t *config)
{
	blur_fn_t *blur = SWITCH_C_ASM ( config, blur_c, blur_asm ) ;
	buffer_info_t info = config->src;
    blur_params_t * extra_params = (blur_params_t *) config->extra_config;
	blur(info.bytes, config->dst.bytes, info.width, info.height,
				extra_params->sigma, extra_params->radius);

}

void ayuda_blur()
{
	printf ( "       * blur\n" );
	printf ( "           Parámetros     : \n"
	         "                         sigma\n"
	         "                         radio\n");
	printf ( "           Ejemplo de uso : \n"
	         "                         blur -i c facil.bmp 0.7 1\n");
}
