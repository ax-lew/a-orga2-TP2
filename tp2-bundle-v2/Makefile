
CC=gcc
#CFLAGS64 = -ggdb -Wall -Wextra -std=c99 -pedantic -m64 -O3 
#el icc no soporta -pedantic
CFLAGS64 = -ggdb -Wall -Wextra -std=c99 -m64 -O3



CFLAGS   = $(CFLAGS64)

BUILD_DIR = build
BIN = tp2



FILTROS = diff blur

FILTROS_OBJ = $(addsuffix .o, $(FILTROS)) $(addsuffix _asm.o, $(FILTROS)) $(addsuffix _c.o, $(FILTROS))
LIBS_OBJS   = libbmp.o imagenes.o
MAIN_OBJS   = tp2.o cli.o
MAIN_OBJS_CON_PATH = $(addprefix $(BUILD_DIR)/, $(MAIN_OBJS))

OBJS = $(MAIN_OBJS) $(LIBS_OBJS) $(FILTROS_OBJ)
OBJS_CON_PATH = $(addprefix $(BUILD_DIR)/, $(OBJS))

.PHONY: all clean FORCE

all: $(BUILD_DIR)/$(BIN)


$(BUILD_DIR)/$(BIN): FORCE $(MAIN_OBJS_CON_PATH)
	$(CC) $(CFLAGS) $(OBJS_CON_PATH) -o $@ -lm

export CFLAGS64
FORCE:
	make -C helper
	make -C filtros

$(BUILD_DIR)/%.o: %.c	
	$(CC) $(CFLAGS) -c -o $@ $< -lm

clean:
	rm -fr $(BUILD_DIR)/*


