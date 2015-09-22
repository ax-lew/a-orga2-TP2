default rel
global _blur_asm
global blur_asm
extern matrizcmb

	%define filas 				r14
	%define cols 				r15
	%define radius 				rbx
	%define dst 				r13
	%define src 				r12
	%define acumBl4				xmm4
	%define acumGr5				xmm5
	%define acumRd6				xmm6

section .data
	copiarblue: DB 0,4,8,12,0,4,8,12,0,4,8,12,0,4,8,12
	copiargreen: DB 1,5,9,13,1,5,9,13,1,5,9,13,1,5,9,13
	copiarred: DB 2,6,10,14,2,6,10,14,2,6,10,14,2,6,10,14
	
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

    push rbp
    mov rbp, rsp
    push r12
    push r13
    push r14
    push r15
    push rbx

    mov r12, rdi 			;src	
    mov r13, rsi			;dest
    mov r14, rdx			;filas	
    mov r15, rcx			;columnas
    mov rbx, r8				;radio	


	
	mov rdi, radius 
    call matrizcmb
    mov rdi, rax

	;CALCULO CANTIDAD DE PIXELES A APLICAR EFECTO BLUR  (SACANDO LOS DEL RADIO)

	mov rax, cols 			; rax = columnas 
	mov r5, radius 			; r5 = radio
	mul r5 					; rax = columnas*radio
	shl rax,2 				; rax = columnas*radio*4
	mov r5, radius 			; r5 = radio
	shl r5, 2 				; r5 = radio*4
	add rax, r5 			; rax = columnas*radio*4 + radio*4
	mov r2, rax 			; r2 = cantidad de iteraciones

	;CALCULO CUANTOS PIXELES POR FILA TENGO Q PROCESAR ANTES DE LLEGAR AL RADIO

	xor r4, r4
 	mov r4, cols
 	sub r4, radius 				; r4 = limite (hasta que columna llega rdi)

 	;CALCULO PIXELES A IGNORAR CUANDO LLEGO AL RADIO

 	mov r6, radius
	shl r6, 3 					; r6 = cuanto avanza si llega al limite

	;CALCULO EN QUE PIXEL EMPIEZO

	mov r5, cols
	mov rax, radius
	mul r5							; revisar multiplicaciones (con numeros grande se pierde precision)
	shl rax, 2
	mov src, rax
	mov dst, rax

	;CALCULO COMO PARARME EN EL PRIMER VECINO

	mov r5,radius
	mov rax,4
	mul r5
	mov r10, rax
	mov r5, cols
	mov rax, 4
	mul r5
	add r10,rax

	pxor acumBl4, acumBl4
	pxor acumGr5, acumGr5
	pxor acumRd6, acumRd6


	; rdi = matriz combolucion
	; r10 = radius*4 + radius*cols*4
	; acumBl4 = acumulador azul
	; acumGr5 = acumulador verde
	; acumRd6 = acumulador rojo
	; r2 = cantidad de iteraciones
	; r3 = contador auxiliar = radio
	
	.ciclo:
		mov r9, src
		sub r9, r10 					; r9 = primer vecino
		
		mov r11, radius
		shl r11, 1						; columnas de la matriz de combolucion
		.filas:
			mov rcx, radius
			shl rcx, 1
			add rcx, 1
			shr rcx, 2 						; rcx = cantidad de iteraciones por fila, (radio*2+1)/4  porque agarro de a 4
			.vecinos:
				mov r1, r9						; r1   = primer vecino
				movdqu xmm0, [r1] 				; xmm0 = [b0,g0,r0,a0,.....]
				add r1, 16
				movdqu xmm1, [rdi] 				; cuidado, son floats. falta volver a poner rdi como antes
				add rdi, 16
				
				pxor xmm3, xmm3 			; xmm3 = [0,0,0,0....]

				movups xmm2, xmm0 			; xmm2 = [b0,g0,r0,a0,.....]
				pshufb xmm2, [copiarblue] 	; xmm2 = [b0,b1,b2,b3...]
				punpcklbw xmm2, xmm3 		; xmm2 = [0,b0,0,b1,0,b2,0,b3...]
				punpcklwd xmm2, xmm3 		; xmm2 = [0,0,0,b0...]
				cvtdq2ps xmm2, xmm2 		; xmm2 = [b0, b1, b2, b3] (en floats)

				mulps xmm2, xmm1
				addps acumBl4, xmm2 			; (cuidado con la saturacion)

				movups xmm2, xmm0 			; xmm2 = [b0,g0,r0,a0,.....]
				pshufb xmm2, [copiargreen] 	; xmm2 = [g0,g1,g2,g3...]
				punpcklbw xmm2, xmm3 		; xmm2 = [0,g0,0,g1,0,g2,0,g3...]
				punpcklwd xmm2, xmm3 		; xmm2 = [0,0,0,b0...]
				cvtdq2ps xmm2, xmm2 		; xmm2 = [g0, g1, g2, g3] (en floats)

				mulps xmm2, xmm1
				addps acumGr5, xmm2

				movups xmm2, xmm0 			; xmm2 = [b0,g0,r0,a0,.....]
				pshufb xmm2, [copiarred] 	; xmm2 = [r0,r1,r2,r3...]
				punpcklbw xmm2, xmm3 		; xmm2 = [0,r0,0,r1,0,r2,0,r3...]
				punpcklwd xmm2, xmm3 		; xmm2 = [0,0,0,r0...]
				cvtdq2ps xmm2, xmm2 		; xmm2 = [r0, r1, r2, r3] (en floats)

				mulps xmm2, xmm1
				addps acumRd6, xmm2

				; hacer algo con las posiciones que estan de mas
				loop .vecinos

			add r9, cols
			sub r11, 1
			cmp r11, 0
			jne .filas
			; sumar todos los acum y dejar el alpha en 255 (cuidado con la saturacion)
			
			haddps acumBl4, acumBl4
			haddps acumBl4, acumBl4				; acumBl4 = [...,suma]

			haddps acumGr5, acumGr5
			haddps acumGr5, acumGr5				; acumGr5 = [...,suma]

			haddps acumRd6, acumRd6
			haddps acumRd6, acumRd6				; acumRd6 = [...,suma]
			
			movAlgo [dst], acumBl4
 			xor acumBl4, acumBl4
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
