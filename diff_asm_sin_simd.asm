default rel
global _diff_asm
global diff_asm



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


	.ciclo:		
		mov dil, [r12] 				; dil = blue
		add r12, 1
		mov sil, [r12] 				; sil = green
		add r12, 1		
		mov dl, [r12] 				; dl = red
		add r12, 1		

		mov r8b, [r13] 				; r8b = blue
		add r13, 1
		mov r9b, [r13] 				; r9b = green
		add r13, 1
		mov r10b, [r13] 			; r10b = red
		add r13, 1

		cmp dil, r8b
		ja .masGrandeB

		sub r8b, dil
		mov dil, r8b
		jmp .green

		.masGrandeB:
			sub dil, r8b		 

		.green:
		cmp sil, r9b
		ja .masGrandeG

		sub r9b, sil
		mov sil, r9b
		jmp .red

		.masGrandeG:
			sub sil, r9b

		.red:
		cmp dl, r10b
		ja .masGrandeR
		sub r10b, dl
		mov dl, r10b
		jmp .mayor

		.masGrandeR:
			sub dl, r10b

		.mayor:
			cmp dil, sil
			ja .mayor2
			mov dil, sil
			.mayor2:
				cmp dil, dl
				ja .agregar
				mov dil, dl

		.agregar:
		mov [r14], dil
		add r14, 1
		mov [r14], dil
		add r14, 1
		mov [r14], dil
		add r14, 1
		mov byte [r14], 255
		add r14, 1
		add r12, 1
		add r13, 1
		dec rcx
		jnz .ciclo


	pop rbx
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbp
    ret


