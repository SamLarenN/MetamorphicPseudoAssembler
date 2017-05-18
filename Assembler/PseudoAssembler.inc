
struct INSTR
	type	  db ?
	src	  dd ?
	dst	  dd ?
	len	  db ?
ends

macro store
{
	push buff
	call assembler
}

macro store_label arg1
{
	push arg1
	push buff
	call assembler
}

macro fix_jmps
{
	push label1
	push buff
	push [decryptorSize]
	call fixAAjmps
}

macro pushr src
{
	mov [pseudo.type], TYPEPUSHR
	mov [pseudo.src], src
	store
}

macro popr dst
{
	mov [pseudo.type], TYPEPOPR
	mov [pseudo.dst], dst
	store
}

macro movr dst, src
{
	mov [pseudo.type], TYPEMOVR
	mov [pseudo.dst], dst
	mov [pseudo.src], src
	store
}

macro movi dst, src
{
	mov [pseudo.type], TYPEMOVI
	mov [pseudo.dst], dst
	push eax
	mov eax, src
	mov [pseudo.src], eax
	pop eax
	store
}

macro movm dst, src
{
	mov [pseudo.type], TYPEMOVI
	mov [pseudo.dst], dst
	push eax
	mov eax, src
	mov [pseudo.src], eax
	pop eax
	store
}

macro @ret
{
	mov [pseudo.type], TYPERET
	store
}

macro xorr dst, src
{
	mov [pseudo.type], TYPEXORR
	mov [pseudo.src], src
	mov [pseudo.dst], dst
	store
}

macro jump
{
	mov [pseudo.type], TYPEJMP
	mov [pseudo.dst], 0
	store
}

macro jejump
{
	mov [pseudo.type], TYPEJE
	mov [pseudo.dst], 0
	store
}

macro jzjump
{
	mov [pseudo.type], TYPEJZ
	mov [pseudo.dst], 0
	store
}

macro cmpi dst, src
{
	mov [pseudo.type], TYPECMPI
	mov [pseudo.dst], dst
	push eax
	mov eax, src
	mov [pseudo.src], src
	pop eax
	store
}

macro cmpm dst, src
{
	mov [pseudo.type], TYPECMPI
	mov [pseudo.dst], dst
	push eax
	mov eax, src
	mov [pseudo.src], src
	pop eax
	store
}

macro cmpr dst, src
{
	mov [pseudo.type], TYPECMPR
	mov [pseudo.dst], dst
	mov [pseudo.src], src
	store
}

macro incr dst
{
	mov [pseudo.type], TYPEINCR
	mov [pseudo.dst], dst
	store
}

macro jnejump
{
	mov [pseudo.type], TYPEJNE
	mov [pseudo.dst], 0
	store
}

macro jnzjump
{
	mov [pseudo.type], TYPEJNZ
	mov [pseudo.dst], 0
	store
}

macro addi dst, src
{
	mov [pseudo.type], TYPEADDI
	mov [pseudo.dst], dst
	push eax
	mov eax, src
	mov [pseudo.src], eax
	pop eax
	store
}

macro addm dst, src
{
	mov [pseudo.type], TYPEADDI
	mov [pseudo.dst], dst
	push eax
	mov eax, src
	mov [pseudo.src], eax
	pop eax
	store
}

macro xori dst, src
{
	mov [pseudo.type], TYPEXORI
	push eax
	mov eax, src
	mov [pseudo.src], eax
	pop eax
	mov [pseudo.dst], dst
	store
}

macro xorm dst, src
{
	mov [pseudo.type], TYPEXORI
	push eax
	mov eax, src
	mov [pseudo.src], eax
	pop eax
	mov [pseudo.dst], dst
	store
}

macro @label arg1
{
	mov [pseudo.type], TYPELABEL
	store_label arg1
}

macro subi dst, src
{
	mov [pseudo.type], TYPESUBI
	push eax
	mov eax, src
	mov [pseudo.src], eax
	pop eax
	mov [pseudo.dst], dst
	store
}

macro subm dst, src
{
	mov [pseudo.type], TYPESUBI
	push eax
	mov eax, src
	mov [pseudo.src], eax
	pop eax
	mov [pseudo.dst], dst
	store
}

macro mov_ptr_reg dst, src
{
	mov [pseudo.type], TYPEMOVPTRREG
	mov [pseudo.dst], dst
	mov [pseudo.src], src
	store
}

macro mov_reg_ptr dst, src
{
	mov [pseudo.type], TYPEMOVREGPTR
	mov [pseudo.dst], dst
	mov [pseudo.src], src
	store
}

macro testr dst, src
{
	mov [pseudo.type], TYPETESTR
	mov [pseudo.dst], dst
	mov [pseudo.src], src
	store
}

macro pushi src
{
	mov [pseudo.type], TYPEPUSHI
	push eax
	mov eax, src
	mov [pseudo.src], eax
	pop eax
	store
}

macro pushm src
{
	mov [pseudo.type], TYPEPUSHI
	push eax
	mov eax, src
	mov [pseudo.src], eax
	pop eax
	store
}

macro decr dst
{
	mov [pseudo.type], TYPEDECR
	mov [pseudo.dst], dst
	store
}

macro @call dst
{
	mov [pseudo.type], TYPECALL
	mov [pseudo.dst], dst
	store
}

macro @pushad
{
	mov [pseudo.type], TYPEPUSHAD
	store
}

macro @popad
{
	mov [pseudo.type], TYPEPOPAD
	store
}

macro popm dst
{
	mov [pseudo.type], TYPEPOPM
	mov [pseudo.dst], dst
	store
}

TYPEPUSHM	equ 0x16    ; push [mem]
TYPEPUSHR	equ 0x1     ; push reg
TYPEPOPM	equ 0x2     ; pop [mem]  ,  use as (pop var_addr)
TYPEPOPR	equ 0x3     ; pop reg
TYPEMOVM	equ 0x6     ; mov reg, [mem]
TYPEMOVR	equ 0x5     ; mov reg, reg2
TYPEMOVI	equ 0x6     ; mov reg, imm  / mov reg, [mem]
TYPERET 	equ 0x7     ; ret
TYPEXORR	equ 0x8     ; xor reg, reg2
TYPEJMP 	equ 0x9     ; jmp
TYPEJE		equ 0xA     ; je
TYPEJZ		equ 0xA     ; jz
TYPECMPI	equ 0xB     ; cmp reg, imm  / cmp reg, [mem]
TYPECMPR	equ 0xC     ; cmp reg, reg2
TYPEINCR	equ 0xD     ; inc reg
TYPEJNE 	equ 0xE     ; jne
TYPEJNZ 	equ 0xE     ; jnz
TYPEADDI	equ 0xF     ; add reg, imm  / add reg, [mem]
TYPEXORI	equ 0x10    ; xor reg, imm  / xor reg, [mem]
TYPELABEL	equ 0x11    ; label:
TYPESUBI	equ 0x12    ; sub reg, imm  / sub reg, [mem]
TYPEMOVPTRREG	equ 0x13    ; mov [reg], reg2	      does not work with esp or ebp in ptr postition
TYPEMOVREGPTR	equ 0x14    ; mov reg, [reg2]	      does not work with esp or ebp in ptr postition
TYPETESTR	equ 0x15    ; test reg, reg2
TYPEPUSHI	equ 0x16    ; push imm	    / push [mem]
TYPEDECR	equ 0x17    ; dec reg
TYPECALL	equ 0x18    ; call
TYPEPUSHAD	equ 0x19    ; pushad
TYPEPOPAD	equ 0x1A    ; popad

REGEAX		equ 0x0
REGECX		equ 0x1
REGEDX		equ 0x2
REGEBX		equ 0x3
REGESP		equ 0x4
REGEBP		equ 0x5
REGESI		equ 0x6
REGEDI		equ 0x7