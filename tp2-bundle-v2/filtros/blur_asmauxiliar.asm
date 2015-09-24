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

    mov r12, rdi 									; r12 = src	
    mov r13, rsi									; r13 = dest
    mov r14, rdx									; r14 = filas	
    mov r15, rcx									; r15 = columnas
    mov rbx, r8										; rbx = radio	


	
	mov rdi, radius
	sub rsp, 8 
    call matrizcmb
    add rsp, 8
    push rsp
    mov rdi, rax 									; rdi = matrix

	;CALCULO CANTIDAD DE PIXELES A APLICAR EFECTO BLUR  (SACANDO LOS DEL RADIO)

	mov rax, cols 			; rax = columnas 
	mov rbp, radius 			; rbp = radio
	mul rbp 					; rax = columnas*radio
	shl rax,2 				; rax = columnas*radio*4
	mov rbp, radius 			; rbp = radio
	shl rbp, 2 				; rbp = radio*4
	add rax, rbp 			; rax = columnas*radio*4 + radio*4
	mov r8, rax 									; r8 = cantidad de iteraciones

	;CALCULO CUANTOS PIXELES POR FILA TENGO Q PROCESAR ANTES DE LLEGAR AL RADIO

	xor rsi, rsi
 	mov rsi, cols
 	sub rsi, radius 									; rsi = limite (hasta que columna llega rdi)

 	;CALCULO PIXELES A IGNORAR CUANDO LLEGO AL RADIO

 	mov rsp, radius
	shl rsp, 3 					
	sub rsp, 4 										; rsp = cuanto avanza si llega al limite

	;CALCULO EN QUE PIXEL EMPIEZO

	mov rbp, cols
	mov rax, radius
	mul rbp							; revisar multiplicaciones
	shl rax, 2
	mov src, rax
	mov dst, rax

	;CALCULO COMO PARARME EN EL PRIMER VECINO

	mov rbp,radius
	mov rax,4
	mul rbp
	mov r10, rax
	mov rbp, cols
	mov rax, 4
	mul rbp
	add r10,rax 									; r10 = 

	pxor acumBl4, acumBl4 							; xmm4 = 0
	pxor acumGr5, acumGr5 							; xmm5 = 0
	pxor acumRd6, acumRd6 							; xmm6 = 0


	; rdi = matriz combolucion
	; r10 = radius*4 + radius*cols*4
	; acumBl4 = acumulador azul
	; acumGr5 = acumulador verde
	; acumRd6 = acumulador rojo
	; r8 = cantidad de iteraciones
	; rax = contador auxiliar = radio
	push rdi
	.ciclo:
		mov r9, src
		sub r9, r10 								; r9 = primer vecino
		
		mov r11, radius
		shl r11, 1									; r11 = columnas de la matriz de combolucion
		.filas:
			mov rcx, radius
			shl rcx, 1
			add rcx, 1
			shr rcx, 2 								; rcx = cantidad de iteraciones por fila, (radio*2+1)/4  porque agarro de a 4
			.vecinos:
				mov rdx, r9							; rdx   = primer vecino
				movdqu xmm0, [rdx] 					; xmm0 = [b0,g0,r0,a0,.....]
				add rdx, 16
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
				pshufb xmm2, [copiarred] 	; xmm2 = [r0,rdx,r2,r3...]
				punpcklbw xmm2, xmm3 		; xmm2 = [0,r0,0,rdx,0,r2,0,r3...]
				punpcklwd xmm2, xmm3 		; xmm2 = [0,0,0,r0...]
				cvtdq2ps xmm2, xmm2 		; xmm2 = [r0, rdx, r2, r3] (en floats)

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
			haddps acumBl4, acumBl4				; acumBl4 = [...,suma1]

			haddps acumGr5, acumGr5
			haddps acumGr5, acumGr5				; acumGr5 = [...,suma2]

			haddps acumRd6, acumRd6
			haddps acumRd6, acumRd6				; acumRd6 = [...,suma3]

			;movd ebp, acumBl4
			cvtss2si ebp, acumBl4
			mov [dst], spl
			add dst, 1

			;movd ebp, acumGr5
			cvtss2si ebp, acumGr5
			mov [dst], spl
			add dst, 1

			;movd ebp, acumRd6
			cvtss2si ebp, acumRd6
			mov [dst], spl
			add dst, 1			


 			pxor acumBl4, acumBl4
 			pxor acumGr5, acumGr5
 			pxor acumRd6, acumRd6

			add rax, 1

			cmp rax, rsi
			je .sumarRadio

			jmp .seguir

			.sumarRadio:
				xor rax, rax
				
				add dst, rsp   
			.seguir:
				sub r8, 1
				cmp r8, 0
				jne .ciclo

	pop rsp
	pop rbx
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbp
    ret


