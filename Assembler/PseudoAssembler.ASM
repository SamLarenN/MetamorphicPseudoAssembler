;*******************************************
;*	       (X) SamLaren 2016	   *
;*******************************************
;*   Metamorphic Pseudo Assembler	   *
;*					   *
;* release v1.0 	    20/12-2016	   *
;*					   *
;*******************************************


buff		equ buffert
decryptorSize	equ bufferSize


include 'pseudo_assembler.inc'


fixAAjmps:
buff_size		equ [ebp+8]
buff_addr		equ [ebp+12]
label_arr_address	equ [ebp+16]

	push ebp
	mov ebp, esp
	pushad


	xor ecx, ecx
	mov eax, buff_addr
	mov ebx, label_arr_address

_@lop1:
	cmp ecx, buff_size
	je end_lop1

	movzx edx, byte[eax+ecx]
	cmp dl, 0xE9
	je fix_jmp

	cmp dl, 0x74
	je fix_je_jmp

	cmp dl, 0x75
	je fix_jne_jmp


ret_to_lop:
	inc ecx
	jmp _@lop1


end_lop1:
	popad
	mov esp, ebp
	pop ebp
ret

fix_jne_jmp:
	push edx
	mov edx, [ebx]
	sub edx, buff_addr
	sub edx, ecx
	sub edx, 2
	mov byte[eax+ecx+1], dl
	pop edx
	add ebx, 4
	jmp ret_to_lop

fix_je_jmp:
	push edx
	mov edx, [ebx]
	sub edx, buff_addr
	sub edx, ecx
	sub edx, 2
	mov byte[eax+ecx+1], dl
	pop edx
	add ebx, 4
	jmp ret_to_lop

fix_jmp:
	push edx
	mov edx, [ebx]
	sub edx, buff_addr
	sub edx, ecx
	sub edx, 5
	mov dword[eax+ecx+1], edx
	pop edx
	add ebx, 4
	jmp ret_to_lop



assembler:
buff_address		equ [ebp+8]
store_address		equ [ebp+12]
	push ebp
	mov ebp, esp
	pushad

	xor eax, eax
	xor edx, edx

	cmp [pseudo.type], TYPEPUSHAD
	je @ps_pushad

	cmp [pseudo.type], TYPEPOPAD
	je @ps_popad

	cmp [pseudo.type], TYPECALL
	je @ps_call

	cmp [pseudo.type], TYPEDECR
	je @decr

	cmp [pseudo.type], TYPEPUSHI
	je @pushi

	cmp [pseudo.type], TYPEPUSHM
	je @pushi

	cmp [pseudo.type], TYPETESTR
	je @testr

	cmp [pseudo.type], TYPEMOVREGPTR
	je @mov_reg_ptr

	cmp [pseudo.type], TYPEMOVPTRREG
	je @mov_ptr_reg

	cmp [pseudo.type], TYPESUBI
	je @subi

	cmp [pseudo.type], TYPELABEL
	je _label

	cmp [pseudo.type], TYPEXORI
	je @xori

	cmp [pseudo.type], TYPEADDI
	je @addi

	cmp [pseudo.type], TYPEJNE
	je @jnejump

	cmp [pseudo.type], TYPEINCR
	je @incr

	cmp [pseudo.type], TYPECMPR
	je @cmpr

	cmp [pseudo.type], TYPECMPI
	je @cmpi

	cmp [pseudo.type], TYPEJE
	je @jejump

	cmp [pseudo.type], TYPEJMP
	je @jump

	cmp [pseudo.type], TYPEXORR
	je @xorr

	cmp [pseudo.type], TYPEPUSHR
	je @pushr

	cmp [pseudo.type], TYPEPOPR
	je @popr

	cmp [pseudo.type], TYPEMOVI
	je @movi

	cmp [pseudo.type], TYPEMOVR
	je @movr

	cmp [pseudo.type], TYPERET
	je retfunc

_@exit:
	popad
	mov esp, ebp
	pop ebp
	ret

@ps_popad:
	mov [pseudo.len], 0x1
	mov edi, buff_address
	add edi, [decryptorSize]       ; Get next spot for instruction
	movzx eax, [pseudo.len]
	add [decryptorSize], eax       ; update decryptor size
	mov al, 0x61
	stosb
	jmp _@exit

@ps_pushad:
	mov [pseudo.len], 0x1
	mov edi, buff_address
	add edi, [decryptorSize]       ; Get next spot for instruction
	movzx eax, [pseudo.len]
	add [decryptorSize], eax       ; update decryptor size
	mov al, 0x60
	stosb
	jmp _@exit

@ps_call:
	mov [pseudo.len], 0x6
	mov edi, buff_address
	add edi, [decryptorSize]       ; Get next spot for instruction
	movzx eax, [pseudo.len]
	add [decryptorSize], eax       ; update decryptor size
	mov al, 0xFF
	stosb
	mov al, 0x15
	stosb
	mov eax, [pseudo.dst]
	stosd
	jmp _@exit


@decr:
	mov [pseudo.len], 0x1	       ; size = 1
	mov edi, buff_address
	add edi, [decryptorSize]       ; Get next spot for instruction
	movzx eax, [pseudo.len]
	add [decryptorSize], eax       ; update decryptor size
	mov al, 0x48
	add al, byte[pseudo.dst]
	stosb
	jmp _@exit

@pushi:
	mov edx, [pseudo.src]
	cmp edx, 127
	ja large_i

	xor edx, edx
	mov [pseudo.len], 0x2
	mov edi, buff_address
	add edi, [decryptorSize]       ; Get next spot for instruction
	movzx eax, [pseudo.len]
	add [decryptorSize], eax       ; update decryptor size
	mov al, 0x6A
	stosb
	mov al, byte[pseudo.src]
	stosb
	jmp _@exit


large_i:
	xor edx, edx
	mov [pseudo.len], 0x5
	mov edi, buff_address
	add edi, [decryptorSize]       ; Get next spot for instruction
	movzx eax, [pseudo.len]
	add [decryptorSize], eax       ; update decryptor size
	mov al, 0x68
	stosb
	mov eax, [pseudo.src]
	stosd
	xor eax, eax
	jmp _@exit



@testr:
	call Rand
	cmp eax, 6
	jae testr_mut_1
	cmp eax, 3
	jae testr_mut_1

	mov [pseudo.len], 0x2
	mov edi, buff_address
	add edi, [decryptorSize]       ; Get next spot for instruction
	movzx eax, [pseudo.len]
	add [decryptorSize], eax       ; update decryptor size
	mov al, 0x85
	stosb
	mov al, byte[pseudo.src]
	mov dl, 0x8
	mul dl
	add al, 0xC0
	add al, byte[pseudo.dst]
	stosb
	jmp _@exit

	testr_mut_1:				; or reg, reg
		mov [pseudo.len], 0x2
		mov edi, buff_address
		add edi, [decryptorSize]       ; Get next spot for instruction
		movzx eax, [pseudo.len]
		add [decryptorSize], eax       ; update decryptor size
		mov al, 0x09
		stosb
		mov al, byte[pseudo.src]
		mov dl, 0x8
		mul dl
		add al, 0xC0
		add al, byte[pseudo.dst]
		stosb
		jmp _@exit

	testr_mut_2:				; and reg, reg
		mov [pseudo.len], 0x2
		mov edi, buff_address
		add edi, [decryptorSize]       ; Get next spot for instruction
		movzx eax, [pseudo.len]
		add [decryptorSize], eax       ; update decryptor size
		mov al, 0x21
		stosb
		mov al, byte[pseudo.src]
		mov dl, 0x8
		mul dl
		add al, 0xC0
		add al, byte[pseudo.dst]
		stosb
		jmp _@exit


@mov_reg_ptr:
	mov [pseudo.len], 0x2
	mov edi, buff_address
	add edi, [decryptorSize]       ; Get next spot for instruction
	movzx eax, [pseudo.len]
	add [decryptorSize], eax       ; update decryptor size
	mov al, 0x8B
	stosb
	mov al, byte[pseudo.dst]
	mov dl, 0x8
	mul dl
	add al, byte[pseudo.src]
	stosb
	jmp _@exit


@mov_ptr_reg:
	mov [pseudo.len], 0x2
	mov edi, buff_address
	add edi, [decryptorSize]       ; Get next spot for instruction
	movzx eax, [pseudo.len]
	add [decryptorSize], eax       ; update decryptor size
	mov al, 0x89
	stosb
	mov al, byte[pseudo.src]
	mov dl, 0x8
	mul dl
	add al, byte[pseudo.dst]
	stosb
	jmp _@exit

@subi:
	call Rand
	cmp eax, 4
	jae subi_mut_1

	mov [pseudo.len], 0x3	       ; size = 3
	mov edi, buff_address
	add edi, [decryptorSize]       ; Get next spot for instruction
	movzx eax, [pseudo.len]
	add [decryptorSize], eax       ; update decryptor size
	mov al, 0x83
	stosb
	mov al, 0xE8
	add al, byte[pseudo.dst]
	stosb
	mov al, byte[pseudo.src]
	stosb
	jmp _@exit

	subi_mut_1:			      ; sub reg, (imm+rand) | add reg, rand
		mov [pseudo.len], 0x3
		mov edi, buff_address
		add edi, [decryptorSize]       ; Get next spot for instruction
		movzx eax, [pseudo.len]
		add [decryptorSize], eax       ; update decryptor size
		call Rand
		mov dl, al
		mov al, 0x83
		stosb
		mov al, 0xE8
		add al, byte[pseudo.dst]
		stosb
		mov al, byte[pseudo.src]
		add al, dl
		stosb
		mov byte[pseudo.src], dl
		jmp @addi


_label:
	mov eax, buff_address
	add eax, [decryptorSize]
	mov edx, [ebp+12]
	mov [edx], eax
	jmp _@exit


@xori:
	mov [pseudo.len], 0x3	       ; size = 3
	mov edi, buff_address
	add edi, [decryptorSize]       ; Get next spot for instruction
	movzx eax, [pseudo.len]
	add [decryptorSize], eax       ; update decryptor size
	mov al, 0x83
	stosb
	mov al, 0xF0
	add al, byte[pseudo.dst]
	stosb
	mov al, byte[pseudo.src]
	stosb
	jmp _@exit

@addi:
	call Rand
	cmp eax, 4
	jae addi_mut_1


	mov [pseudo.len], 0x3	       ; size = 3
	mov edi, buff_address
	add edi, [decryptorSize]       ; Get next spot for instruction
	movzx eax, [pseudo.len]
	add [decryptorSize], eax       ; update decryptor size
	mov al, 0x83
	stosb
	mov al, 0xC0
	add al, byte[pseudo.dst]
	stosb
	mov al, byte[pseudo.src]
	stosb
	jmp _@exit

	addi_mut_1:			       ; add reg, (imm+rand) | sub reg, rand
		mov [pseudo.len], 0x3
		mov edi, buff_address
		add edi, [decryptorSize]       ; Get next spot for instruction
		movzx eax, [pseudo.len]
		add [decryptorSize], eax       ; update decryptor size
		call Rand
		mov dl, al
		mov al, 0x83
		stosb
		mov al, byte[pseudo.dst]
		add al, 0xC0
		stosb
		mov al, byte[pseudo.src]
		add al, dl
		stosb
		mov byte[pseudo.src], dl
		jmp @subi



@jnejump:
	mov [pseudo.len], 0x2	       ; size = 2
	mov edi, buff_address
	add edi, [decryptorSize]       ; Get next spot for instruction
	movzx eax, [pseudo.len]
	add [decryptorSize], eax       ; update decryptor size
	mov al, 0x75
	stosb
	;mov al, byte[pseudo.dst]
	;stosb
	mov al, 0
	stosb
	jmp _@exit


@incr:
	call Rand
	cmp eax, 5
	jae add_1

	mov [pseudo.len], 0x1	       ; size = 1
	mov edi, buff_address
	add edi, [decryptorSize]       ; Get next spot for instruction
	movzx eax, [pseudo.len]
	add [decryptorSize], eax       ; update decryptor size
	mov al, 0x40
	add al, byte[pseudo.dst]
	stosb
	jmp _@exit

	add_1:			       ; add reg, 1
		mov [pseudo.src], 1
		jmp @addi



@cmpr:
	mov [pseudo.len], 0x2	       ; size = 2
	mov edi, buff_address
	add edi, [decryptorSize]       ; Get next spot for instruction
	movzx eax, [pseudo.len]
	add [decryptorSize], eax       ; update decryptor size
	mov al, 0x39
	stosb
	mov al, byte[pseudo.src]
	mov dl, 8
	mul dl
	add al, 0xC0
	add al, byte[pseudo.dst]
	stosb
	jmp _@exit


@cmpi:
	mov [pseudo.len], 0x3	       ; size = 3
	mov edi, buff_address
	add edi, [decryptorSize]       ; Get next spot for instruction
	movzx eax, [pseudo.len]
	add [decryptorSize], eax       ; update decryptor size
	mov al, 0x83
	stosb
	mov al, 0xF8
	add al, byte[pseudo.dst]
	stosb
	mov al, byte[pseudo.src]
	stosb
	jmp _@exit

@jejump:
	mov [pseudo.len], 0x2	       ; size = 2
	mov edi, buff_address
	add edi, [decryptorSize]       ; Get next spot for instruction
	movzx eax, [pseudo.len]
	add [decryptorSize], eax       ; update decryptor size
	mov al, 0x74
	stosb
	;mov al, byte[pseudo.dst]
	;stosb
	mov al, 0
	stosb
	jmp _@exit

@jump:
	mov eax, buff
	add eax, [decryptorSize]
	mov [pseudo.src], eax	       ; save src location, vill aldrig hoppa från något annat ställe
	xor eax, eax

	mov [pseudo.len], 0x5	       ; size = 5
	mov edi, buff_address
	add edi, [decryptorSize]       ; Get next spot for instruction
	movzx eax, [pseudo.len]
	add [decryptorSize], eax       ; update decryptor size
	mov al, 0xE9
	stosb

	mov eax, 0
	stosd
	jmp _@exit

@xorr:
	mov [pseudo.len], 0x2	       ; size = 2
	mov edi, buff_address
	add edi, [decryptorSize]       ; Get next spot for instruction
	movzx eax, [pseudo.len]
	add [decryptorSize], eax       ; update decryptor size
	mov al, 0x31
	stosb
	mov al, byte[pseudo.src]
	mov dl, 8
	mul dl
	add al, 0xC0
	add al, byte[pseudo.dst]
	stosb
	jmp _@exit

retfunc:
	mov [pseudo.len], 0x1	       ; size = 1
	mov edi, buff_address
	add edi, [decryptorSize]       ; Get next spot for instruction
	movzx eax, [pseudo.len]
	add [decryptorSize], eax       ; update decryptor size
	mov al, 0xC3
	stosb
	jmp _@exit

@movi:
	call Rand
	cmp eax, 4
	jae movi_mut_1

	mov [pseudo.len], 0x5	       ; size = 1
	mov edi, buff_address
	add edi, [decryptorSize]       ; Get next spot for instruction
	movzx eax, [pseudo.len]
	add [decryptorSize], eax       ; update decryptor size
	mov al, 0xB8
	add al, byte[pseudo.dst]
	stosb
	mov eax, [pseudo.src]
	stosd
	jmp _@exit

	movi_mut_1:			; push imm | pop reg
		mov [pseudo.len], 0x5
		mov edi, buff_address
		add edi, [decryptorSize]       ; Get next spot for instruction
		movzx eax, [pseudo.len]
		add [decryptorSize], eax       ; update decryptor size
		mov al, 0x68
		stosb
		mov eax, [pseudo.src]
		stosd
		xor eax, eax
		jmp @popr


@popr:
	call Rand
	cmp eax, 5
	jae popr_mut_1

	mov [pseudo.len], 0x1	       ; size = 1
	mov edi, buff_address
	add edi, [decryptorSize]       ; Get next spot for instruction
	movzx eax, [pseudo.len]
	add [decryptorSize], eax       ; update decryptor size
	mov al, 0x58
	add al, byte[pseudo.dst]
	stosb
	jmp _@exit

	popr_mut_1:		      ; mov reg, [esp] | add esp, 4
		mov [pseudo.len], 0x3
		mov edi, buff_address
		add edi, [decryptorSize]       ; Get next spot for instruction
		movzx eax, [pseudo.len]
		add [decryptorSize], eax       ; update decryptor size
		mov al, 0x8B
		stosb
		mov al, byte[pseudo.dst]
		mov dl, 8
		mul dl
		add al, 0x4
		stosb
		mov al, 0x24
		stosb
		mov [pseudo.dst], REGESP
		mov [pseudo.src], 0x4
		jmp @addi

@pushr:
	call Rand
	cmp eax, 5
	jae push_mut_1

	mov [pseudo.len], 0x1	       ; size = 1
	mov edi, buff_address
	add edi, [decryptorSize]       ; Get next spot for instruction
	movzx eax, [pseudo.len]
	add [decryptorSize], eax       ; update decryptor size
	mov al, 0x50
	add al, byte[pseudo.src]
	stosb
	jmp _@exit

	push_mut_1:			  ; sub esp, 4 | mov [esp], reg
		mov [pseudo.len], 0x6
		mov edi, buff_address
		add edi, [decryptorSize]       ; Get next spot for instruction
		movzx eax, [pseudo.len]
		add [decryptorSize], eax       ; update decryptor size
		mov al, 0x83
		stosb
		mov al, 0xEC
		stosb
		mov al, 0x4
		stosb
		mov al, 0x89
		stosb
		mov al, byte[pseudo.src]
		mov dl, 8
		mul dl
		add al, 0x4
		stosb
		mov al, 0x24
		stosb
		jmp _@exit


@movr:
	call Rand
	cmp eax, 5
	jae movr_mut_1

	mov [pseudo.len], 0x2	       ; size = 2
	mov edi, buff_address
	add edi, [decryptorSize]       ; Get next spot for instruction
	movzx eax, [pseudo.len]
	add [decryptorSize], eax       ; update decryptor size
	mov al, 0x89
	stosb
	mov al, byte[pseudo.src]
	mov dl, 0x8
	mul dl
	add al, 0xC0
	add al, byte[pseudo.dst]
	stosb
	jmp _@exit

	movr_mut_1:			  ; push reg | pop reg2
		mov [pseudo.len], 0x1
		mov edi, buff_address
		add edi, [decryptorSize]       ; Get next spot for instruction
		movzx eax, [pseudo.len]
		add [decryptorSize], eax       ; update decryptor size
		mov al, 0x50
		add al, byte[pseudo.src]
		stosb
		jmp @popr



Rand:			  ; Random number between 0 and 10
	;push ebp
	;mov ebp, esp
	push edx
	push ecx
	xor eax, eax
	rdtsc
	xor edx, edx
	mov ecx, 10
	div ecx
	mov eax, edx
	pop ecx
	pop edx
	;mov esp, ebp
	;pop ebp
ret