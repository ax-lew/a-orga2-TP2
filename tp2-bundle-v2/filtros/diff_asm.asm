default rel
global _diff_asm
global diff_asm


section .data	
	permu1: DB 13,15,14,12,9,11,10,8,5,7,6,4,1,3,2,0
	permu2: DB 14,13,15,12,10,9,11,8,6,5,7,4,2,1,3,0
	transp: DB 0,0,0,255,0,0,0,255,0,0,0,255,0,0,0,255

section .text
;void diff_asm    (
	;unsigned char *src,
    ;unsigned char *src2,
	;unsigned char *dst,
	;int filas,
	;int cols)

_diff_asm:
diff_asm:	
	
	push rbp
	mov rbp, rsp
	push r12
	push r13
	push r14
	push r15
	push rbx

	mov r12, rdi 		; R12 = imagen1
	mov r13, rsi 		; R13 = imagen2
	mov r14, rdx 		; R14 = res
	xor r15, r15 		
	xor rbx, rbx
	mov r15, rcx 		; R15 = filas
	mov rbx, r8 		; RBX = cols

	
	
	


	xor rcx,rcx
	mov rax, r15
	mov rcx, rbx
	mul rcx
	mov rcx, rax 		; rcx = filas*cols
	shr rcx, 2 			; rcx = filas*cols/4

	.ciclo:
		movdqu xmm0, [r12] 			; xmm0 = [b00,g00,r00,a00, .....]
		movdqu xmm1, [r13] 			; xmm1 = [b10,g10,r0,a10, .....]
		add r12, 16
		add r13, 16

		movdqu xmm2, xmm0			; xmm2 = [b00,g00,r00,a00, .....]
		psubusb xmm0, xmm1 				; xmm0 = [b00-b10,g00-g10,r00-r10,a00-a10, .....]

		psubusb xmm1, xmm2 				; xmm1 = [b10-b00,g10-g00,r10-r00,a10-a00, .....]
		pmaxub xmm0, xmm1 				; xmm0 = [|b00-b10|,|g00-g10|,|r00-r10|,|a00-a10|, .....] = [a0,b0,c0,d0, .....]
		movdqu xmm1, xmm0 				; xmm1 = [a0,b0,c0,d0, .....]
		
		movdqu xmm2, [permu1] 			
		pshufb xmm1, xmm2 				; xmm1 = [c0,a0,b0,d0, .....]
		movdqu xmm2, xmm1				; xmm2 = [c0,a0,b0,d0, .....]

		movdqu xmm1, xmm0 				; xmm1 = [a0,b0,c0,d0, .....]
		movdqu xmm3, [permu2] 
		pshufb xmm1, xmm3 				; xmm1 = [b0,c0,a0,d0, .....]
		
		pmaxub xmm0, xmm1 
		pmaxub xmm0, xmm2 				; xmm0 = [max(a0,b0,c0),max(a0,b0,c0),max(a0,b0,c0),d0, .....]
		
		movdqu xmm1, [transp] 
		por xmm0, xmm1 					; xmm0 = [max(a0,b0,c0),max(a0,b0,c0),max(a0,b0,c0),255, .....]

		movdqu [R14], xmm0	 			; o fprint ?
		add r14, 16
		loop .ciclo


	pop rbx
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbp
    ret




;  http://x86.renejeschke.de/
; PMAXUB para sacar maximo
; PSUBSB saturacion, para sacar modulo