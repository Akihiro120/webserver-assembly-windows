extern printf
extern scanf
extern ExitProcess

extern WSAStartup
extern WSACleanup
extern socket
extern bind
extern listen
extern accept
extern send
extern recv
extern WSAGetLastError
extern htons
extern inet_addr
extern strlen
extern closesocket
extern setsockopt

section .data
  wsaVersion: db 2, 2
  
  ; print messages
  wsaInitMessage: db "INFO: Initializing Winsock", 10, 0
  socketInitMessage: db "INFO: Creating Socket", 10, 0
  bindMessage: db "INFO: Binding Socket", 10, 0
  errorMessage: db "ERROR!", 10, 0
  ipAddressMessage: db "Enter the IP Address: ", 10, 0
  portMessage: db "Enter the PORT", 10, 0
  listeningMessage: db "Server Listening on PORT: %d", 10, 0
  acceptMessage: db "Client Connection Accepted", 10, 0

  str_scan: db "%s", 0
  int_scan: db "%d", 0

  s_print: db "Request: %s", 10, 0
  send_print: db "Sent: %s", 10, 0
  d_print: db "%d", 10, 0
  
  ; networking constants
  INVALID_SOCKET: equ -1
  AF_INET: equ 2
  SOCK_STREAM: equ 1
  IPPROTO_TCP: equ 6
  SOCKET_ERROR: equ -1

  SOL_SOCKET: equ 65535
  SO_RCVTIMEO: equ 4102
  TIMEOUT_SECONDS: equ 10

  ; server address
  server_addr:
    server_addr.sin_family: dw 0,
    server_addr.sin_port: dw 0
    server_addr.s_addr: dq 0
    server_addr.sin_zero: dq 0
  server_addr_size equ $ - server_addr

  ; client address
  client_addr:
    client_addr.sin_family: dw 0,
    client_addr.sin_port: dw 0
    client_addr.s_addr: dq 0
    client_addr.sin_zero: dq 0
  client_addr_size equ $ - client_addr

  ; messages
  web_msg_buffer: db 1024 dup(0)
  web_response: db "HTTP/1.1 200 OK", 0x0A, "Content-Type: text/html", 0x0A, 0x0A, "<html><body><h1>This is a Webserver made in Assembly</h1></body></html>", "<p>IP: Localhost(127.0.0.1)<br>Created by Kevin Phan</p> <br>Created using Microsoft Winsock 2 API<br>", "<a href='https://github.com/Akihiro120/webserver-assembly-windows'>Link to project GITHUB page</a><br><p>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Proin ut rutrum mi, vel fermentum ante. Nunc sed facilisis magna. Phasellus sollicitudin felis sed mi faucibus, quis pulvinar nibh accumsan. Donec faucibus risus nec diam lacinia, id tempor odio iaculis. Nullam enim nunc, maximus tristique malesuada sed, pharetra vel eros. Nullam quis volutpat diam, sit amet vulputate odio. Quisque fringilla commodo massa. Praesent at felis ac justo ullamcorper maximus et quis tellus. Ut leo dui, iaculis efficitur neque eu, volutpat dapibus augue. Sed in erat magna. Aenean purus quam, vestibulum et interdum quis, rutrum eget dui. In hac habitasse platea dictumst. In hac habitasse platea dictumst.</p>", 0
  response_len: equ $ - web_response

section .bss
  wsaData: resb 408
  serverSocket: resb 8
  clientSocket: resb 8

  ; network address
  ip_address: resb 32
  port: resb 4

section .text
global main
main:
  ; start the stack frame
  push rbp
  mov rbp, rsp
  
  ; ------------------------------------------------------------
  ; initialize winsock
  mov rcx, wsaInitMessage
  mov rdx, 0
  call printf
  xor rax, rax

  mov rcx, wsaVersion
  lea rdx, [wsaData]
  call WSAStartup
  cmp rax, 1
  je error
  
  ; ------------------------------------------------------------
  ; create a socket
  mov rcx, socketInitMessage
  mov rdx, 0
  call printf
  xor rax, rax

  mov ecx, dword AF_INET
  mov edx, dword SOCK_STREAM
  mov r8d, dword IPPROTO_TCP
  call socket
  mov [serverSocket], qword rax
  mov rcx, qword [serverSocket]
  mov rdx, qword INVALID_SOCKET
  cmp rcx, rdx
  je error

  ; ------------------------------------------------------------
  ; get the address and PORT of the network
  mov rcx, portMessage
  mov rdx, 0
  call printf
  xor rax, rax
  
  mov rcx, int_scan
  lea rdx, [port]
  call scanf

  ; ------------------------------------------------------------
  ; bind the socket
  mov word [server_addr.sin_family], AF_INET
  mov rcx, 0
  call inet_addr
  mov rcx, rax
  mov [server_addr.s_addr], rcx
  mov rcx, [port]
  call htons
  mov [server_addr.sin_port], rax

  mov rcx, bindMessage
  mov rdx, 0
  call printf
  xor rax, rax
  
  mov rcx, qword [serverSocket]
  lea rdx, [server_addr]
  mov r8, server_addr_size
  call bind
  mov rcx, SOCKET_ERROR
  cmp rax, rcx
  je error

  ; ------------------------------------------------------------
  ; listen
  mov rcx, qword [serverSocket]
  mov rdx, 10
  call listen

  mov rcx, listeningMessage
  mov rdx, [port]
  call printf
  xor rax, rax

accept_loop:
  ; ------------------------------------------------------------
  ; accept connections
  mov rcx, qword [serverSocket]
  mov rdx, 0
  mov r8, 0
  call accept
  mov [clientSocket], rax

  mov rcx, acceptMessage
  mov rdx, 0
  call printf
  xor rax, rax
  
  mov rcx, [clientSocket]
  mov rdx, INVALID_SOCKET
  cmp rcx, rdx
  je exit

  ; ------------------------------------------------------------
  ; timeout
  sub rsp, 32
  mov rcx, [clientSocket]
  mov rdx, SOL_SOCKET
  mov r8, SO_RCVTIMEO
  lea r9, [TIMEOUT_SECONDS]
  mov [rsp], dword 4
  call setsockopt
  add rsp, 32

  ; ------------------------------------------------------------
  ; recv
  mov rcx, [clientSocket]
  lea rdx, [web_msg_buffer]
  mov r8, 1024
  mov r9, 0
  call recv

  mov rcx, rax
  mov rdx, 0
  cmp rcx, rdx
  je exit

  mov rcx, s_print
  lea rdx, [web_msg_buffer]
  call printf

  ; ------------------------------------------------------------
  ; send
  mov rcx, [clientSocket]
  lea rdx, [web_response]
  mov r8, response_len
  mov r9, 0
  call send

  mov rcx, send_print
  lea rdx, [web_response]
  call printf
  xor rax, rax

  ; -------------------------------------------------------------
  ; close the socket
  mov rcx, [clientSocket]
  call closesocket

  jmp accept_loop

exit:
  ; -------------------------------------------------------------
  ; close the socket
  mov rcx, [clientSocket]
  call closesocket

  ; ------------------------------------------------------------
  ; deintialize Winsock
  xor rcx, rcx
  call WSACleanup

  ; deinitialize the stack frame
  mov rsp, rbp
  pop rbp

  mov rcx, 0
  call ExitProcess

error:
  mov rcx, errorMessage
  mov rdx, 0
  call printf
  xor rax, rax

  xor rcx, rcx
  call WSACleanup

  mov rcx, 1
  call ExitProcess
