# Webserver in Asssembly🌐
This is a Webserver made using Assembly, compiled with the NASM Assembler and GCC.
![image](https://github.com/Akihiro120/webserver-assembly-windows/assets/127700131/f5d85a72-06e7-4d96-aae5-27c16fc67ae5)

Networking was handled using the <a href="https://learn.microsoft.com/en-us/windows/win32/winsock/getting-started-with-winsock">Microsoft Winsock 2 API</a>

## Preview 🖥️

![image](https://github.com/Akihiro120/webserver-assembly-windows/assets/127700131/5f8e772e-e1ca-4e82-bf94-6a073695b316)


## Compiling
``` Shell
nasm -f win64 main.asm -o main.obj
gcc main.obj -o main.exe -lws2_32
```
or (if applicable)
``` Shell
make
```

## Prerequisites
- NASM Assembler
- GCC
- Windows Operating System
- Processor with x86-64 instructions
