import sys

def main():
    iv = int(sys.argv[1])

    shellcode = bytearray(sys.stdin.buffer.read())
    shellcode.append(iv)
    
    for i in range(len(shellcode) - 2, -1, -1):
        shellcode[i] ^= shellcode[i + 1]

    sys.stdout.buffer.write(shellcode)

if __name__ == '__main__':
    main()

