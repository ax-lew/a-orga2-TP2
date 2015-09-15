default rel
global _diff_asm
global diff_asm


section .data
	permu1: DB 3,1,2,4,3,1,2,4,3,1,2,4,3,1,2,4
	permu2: DB 2,3,1,4,2,3,1,4,2,3,1,4,2,3,1,4
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
	
	; R12 = imagen1
	; R13 = imagen2
	; R14 = res
	; R15 = filas
	; RBX = cols

	xor rcx,rcx
	;cvtsi2sd xmm0, r15
	;cvtsi2sd xmm1, rbx
	;mulsd xmm0, xmm1
	;mul rbx, r15
	mov rcx, rbx
	.ciclo:
		;movAlgo xmm0, [r12] 			; xmm0 = [b00,g00,r00,a00, .....]
		;movAlgo xmm1, [r13] 			; xmm1 = [b10,g10,r0,a10, .....]
		add r12, 16
		add r13, 16
		psubusb xmm0, xmm1 				; xmm0 = [b00-b10,g00-g10,r00-r10,a00-a10, .....]
		psubusb xmm1, xmm0 				; xmm1 = [b10-b00,g10-g00,r10-r00,a10-a00, .....]
		pmaxub xmm0, xmm1 				; xmm0 = [|b00-b10|,|g00-g10|,|r00-r10|,|a00-a10|, .....] = [a0,b0,c0,d0, .....]
		;movAlgo xmm1, xmm0 					; xmm1 = [a0,b0,c0,d0, .....]
		;movAlgo xmm2, [permu1] 			
		pshufb xmm1, xmm2 			; xmm1 = [c0,a0,b0,d0, .....]
		;movAlgo xmm2, xmm1				; xmm2 = [c0,a0,b0,d0, .....]
		;movAlgo xmm3, [permu2] 			
		pshufb xmm1, xmm3 			; xmm1 = [b0,c0,a0,d0, .....]
		pmaxub xmm0, xmm1 
		pmaxub xmm0, xmm2 				; xmm0 = [max(a0,b0,c0),max(a0,b0,c0),max(a0,b0,c0),d0, .....]
		pxor xmm0, [transp] 			; xmm0 = [max(a0,b0,c0),max(a0,b0,c0),max(a0,b0,c0),255, .....]
		;movAlgo [R14], xmm0	 			; o fprint ?
		add r14, 16
		loop .ciclo
    ret




;  http://x86.renejeschke.de/
; PMAXUB para sacar maximo
; PSUBSB saturacion, para sacar modulo