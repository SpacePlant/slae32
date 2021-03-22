global _start

section .text

_start:
    ; int stime(const time_t *t): syscall 0x19
    ;   stime([0])
    xor eax, eax    ; eax = 0
    push eax
    mov ebx, esp    ; ebx = [0]
    mov al, 0x19    ; eax = 25
    int 0x80        ; perform syscall
    
    ; void _exit(int status): syscall 0x1
    ;   _exit(whatever)
    inc eax         ; eax = 1
    int 0x80        ; perform syscall

