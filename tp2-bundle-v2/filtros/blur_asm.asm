default rel
global _blur_asm
global blur_asm

	%define filas 				rdx
	%define cols 				r12
	%define radius 				r8
	%define dst 				rdi
	%define src 				rsi

section .data



section .text
;void blur_asm    (
	;unsigned char *src,
	;unsigned char *dst,
	;int filas,
	;int cols,
    ;float sigma,
    ;int radius)

_blur_asm:
blur_asm:
	; rdi = src
	; rsi = dst
	; rdx = filas
	; rcx = cols
	; xmm0 = sigma
	; r8 = radius

	mov rax, cols 			; rax = columnas 
	mov r5, radius 			; r5 = radio
	mul r5 					; rax = columnas*radio
	shl rax,2 				; rax = columnas*radio*4
	mov r5, radius 			; r5 = radio
	shl r5, 2 				; r5 = radio*4
	add rax, r5 			; rax = columnas*radio*4 + radio*4
	mov r2, rax 			; r2 = cantidad de iteraciones



	xor r4, r4
 	mov r4, filas
 	sub r4, radius 				; r4 = limite (hasta que columna llega rdi)

 	mov r6, radius
	shl r6, 3 					; r6 = cuanto avanza si llega al limite

	; rax = matriz
	; r10 = radius*filas
	; xmm4 = contador
	; r2 = cantidad de iteraciones
	; r3 = contador auxiliar = radio
	.ciclo:
		mov r9, dst
		sub r9, radius
		sub r9, r10 					; r9 = primer vecino
		
		mov r11, radius
		shl r11, 1
		.filas:
			mov rcx, radius
			shl rcx, 1
			add rcx, 1
			shr rcx, 2 						; rcx = cantidad de iteraciones por fila 
			.vecinos:
				mov r1, r9
				movdqu xmm0, [r1] 				; xmm0 = [b0,g0,r0,a0,.....]
				add r1, 16
				movdqu xmm1, [rax] 				; cuidado, son floats
				add rax, 16
				mulps xmm0, xmm1 				; cuidado con los tipos	
				; hacer algo con las posiciones que estan de mas
				addps xmm4, xmm0 				; (cuidado con la saturacion)

				loop .vecinos
			add r9, cols
			sub r11, 1
			cmp r11, 0
			jne .filas
			; sumar todo xmm4 y dejar el alpha en 255 (cuidado con la saturacion)
			movAlgo [rsi], xmm4
 			xor xmm4, xmm4
			add r3, 1

			cmp r3, r4
			je .sumarRadio

			add dst, 4
			jmp .seguir

			.sumarRadio:
				xor r3, r3
				
				add dst, r6
			.seguir:
				sub r2, 1
				cmp r2, 0
				jne .ciclo

    ret
