build:
	nasm -f win64 main.asm
	gcc main.obj -o main.exe -lws2_32
	main.exe
