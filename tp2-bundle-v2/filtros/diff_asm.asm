default rel
global _diff_asm
global diff_asm


section .data
	permu1: DB 3,1,2,4,3,1,2,4,3,1,2,4,3,1,2,4
	permu2: DB 2,3,1,4,2,3,1,4,2,3,1,4,2,3,1,4

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
	mul rbx, r15
	mov rcx, rbx
	.ciclo:
		movAlgo xmm0, [r12]
		movAlgo xmm1, [r13]
		add r12, 16
		add r13, 16
		psubb xmm0, xmm1
		movAlgo xmm2, [permu1]
		movAlgo xmm3, [permu2]
		mov xmm1, xmm0
		shuffleAlgo xmm0, xmm2
		pcmpgtb xmm0, xmm1
		mov xmm3, xmm0
		mov xmm0, xmm1
		shuffleAlgo xmm0, xmm3
		pcmpgtb xmm0, xmm1
		and xmm0, xmm3
		shuffleAlgo xmm1, xmm0
		movAlgo [R14], xmm1
		add r14, 16
		loop
    ret




;  http://x86.renejeschke.de/
; PMAXUB para sacar maximo
; PSUBSB saturacion, para sacar modulo