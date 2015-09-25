default rel
global _blur_asm
global blur_asm
extern matrizcmb

	%define filas 				r14
	%define cols 				r15
	%define radius 				rbx
	%define dst 				r13
	%define src 				r12



	
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

    mov r12, rdi 									; r12 = src	
    mov r13, rsi									; r13 = dest
    mov r14, rdx									; r14 = filas	
    mov r15, rcx									; r15 = columnas
    mov rbx, r8										; rbx = radio	


	
	mov rdi, radius
	sub rsp, 8
    call matrizcmb
    add rsp, 8
    mov rdi, rax 									; rdi = matrix

	;CALCULO CANTIDAD DE FILAS  (SACANDO LOS DEL RADIO)
	mov r8, filas
	sub r8, radius
	sub r8, radius 							; r8 = cantidad de iteraciones por filas
	

	;CALCULO CUANTOS PIXELES POR FILA TENGO Q PROCESAR ANTES DE LLEGAR AL RADIO

	xor rsi, rsi
 	mov rsi, cols
  	sub rsi, radius 									
 	sub rsi, radius 					; rsi = limite (hasta que columna llega rdi)
 	shr rsi, 2							; divido por 4 pues avanzo de a 4
 	

 	;CALCULO PIXELES A IGNORAR CUANDO LLEGO AL RADIO

 	mov r14, radius
 	add r14, 1 			; TAL VEZ?
	shl r14, 3				
	mov r10, 0x0000000000000003
	and r10, rsi
	;sub r10, 1 		; TAL VEZ?
	shl r10, 2
	add r14, r10 										; r14 = cuanto avanza si llega al limite





	;CALCULO EN QUE PIXEL EMPIEZO

	mov rbp, cols
	mov rax, radius
	mul rbp							; revisar multiplicaciones
	shl rax, 2
	mov rbp, radius
	shl rbp, 2
	add rax, rbp
	add src, rax
	add dst, rax

	;CALCULO COMO PARARME EN EL PRIMER VECINO

	mov rbp, radius
	shl rbp, 2
	mov r10, cols
	shl r10, 2
	mov rax, radius
	mul r10
	mov r10, rax
	add r10, rbp 

	
	; r -i asm blur ../img/lena32.bmp 5 15

	; rdi = matriz combolucion
	; r10 = radius*4 + radius*cols*4
	; r8 = filas sin las afectadas por el radio


	
	push rdi
	.cicloFils:

		xor rdx, rdx

		.cicloCols:
			movdqu xmm0, [src]
			mov r9, src
			sub r9, r10 								; r9 = posicion primer vecino
			
			pxor xmm15, xmm15 			; primer acumulador
			pxor xmm14, xmm14 			; segundo
			pxor xmm13, xmm13 			; tercero
			pxor xmm12, xmm12 			; cuarto

			xor rax, rax
			mov rax, radius
			shl rax, 1
			; sub rcx, 1 		;TAL VEZ?

			pop rdi
			push rdi
			.vecFilas:
				xor rcx, rcx
				mov rcx, radius
				shl rcx, 1
				; sub rcx, 1 		;TAL VEZ?
				.vecCols:
					movdqu xmm1, [r9] 						; xmm1 = vecinos
					add r9, 4
					movdqu xmm2, [rdi] 						; xmm2 = matriz
					add rdi, 4
					pshufd xmm2, xmm2, 0 					; esta bien??

					pxor xmm7, xmm7 
					movdqu xmm3, xmm1

					punpcklbw xmm1, xmm7
					punpckhbw xmm3, xmm7

					movdqu xmm4, xmm1
					movdqu xmm5, xmm3
					
					punpcklwd xmm1, xmm7 					; xmm1 = [b0,g0,r0,a0]
					punpckhwd xmm4, xmm7 					; xmm4 = [b1,g1,r1,a1]
					punpcklwd xmm3, xmm7 					; xmm3 = [b2,g2,r2,a2]
					punpckhwd xmm5, xmm7 					; xmm5 = [b3,g3,r3,a3]

					cvtdq2ps xmm1, xmm1
					cvtdq2ps xmm4, xmm4
					cvtdq2ps xmm3, xmm3
					cvtdq2ps xmm5, xmm5

					mulps xmm1, xmm2
					mulps xmm3, xmm2
					mulps xmm4, xmm2
					mulps xmm5, xmm2

					addps xmm15, xmm1
					addps xmm14, xmm3
					addps xmm13, xmm4
					addps xmm12, xmm5

					loop .vecCols

				sub r9, radius
				sub r9, radius
				sub r9, radius
				sub r9, radius
				sub r9, radius
				sub r9, radius
				sub r9, radius
				sub r9, radius
				sub r9, 1 				; TAL VEZ?
				add r9, r15
				add r9, r15
				add r9, r15
				add r9, r15

				sub rax, 1
				cmp rax, 0
				jne .vecFilas
			
			xor rax, rax

			cvtps2dq xmm15, xmm15
			cvtps2dq xmm14, xmm14
			cvtps2dq xmm13, xmm13
			cvtps2dq xmm12, xmm12

			packssdw xmm15, xmm14
			packssdw xmm13, xmm12 			; consultar (con signo)
			packuswb xmm15, xmm13 			; creo que esta todo al reves

			; falta mascara para transparencia

			movdqu [dst], xmm15
			
			add dst, 16
			add src, 16
				
			add rdx, 1
			cmp rdx, rsi
			jne .cicloCols

		add src,r14
		add dst,r14

		sub r8, 1
		cmp r8, 0
		jne .cicloFils				
	
	pop rdi
	pop rbx
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbp
    ret


