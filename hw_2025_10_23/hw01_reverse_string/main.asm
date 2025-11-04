%include "../shared/io.inc"         ; подключаем экстерны функций

global _start                       ; делаем метку метку _start видимой извне
 
section .data
    msg0 db "Enter your string:",10 ; строка для вывода на консоль
    msg0_sz equ $ - msg0            ; длина строки
    
    msg1 db "Reversed string:"  ,10 
    msg1_sz equ $ - msg1

    string_sz_max equ 10            ; ограничение ввода =n символов

section .bss
    string resb string_sz_max       ; резервируем область размером string_sz_max
    string_sz resb 1                ; фактический размер ввода (достаточно 1 байта для хранения)
    tmp resb 1
 
section .text                       ; объявление секции кода
_start:                             ; точка входа в программу   
    ; write(stdout, msg0, msg0_sz)                         
    mov rax, 1                      ; номер системного вызова write
    mov rdi, 1                      ; fd=1 -> stdout
    lea rsi, [rel msg0]             ; адрес строки для вывода
    mov rdx, msg0_sz                ; количество байт
    syscall

    ; read(stdin, msg0, msg0_sz)
    mov rax, 0                  
    mov rdi, 0                      ; fd=0 -> stdin       
    lea rsi, [rel string]                   
    mov rdx, string_sz_max               
    syscall 

    ; сохраняем размер прочитанной строки
    mov [rel string_sz], rax

    ; остались ли данные в stdin?
    cmp rax, string_sz_max
    jne no_trim

trim:
    ; читаем оставшиеся байты по одному
    mov rax, 0
    mov rdi, 0
    lea rsi, [rel tmp]
    mov rdx, 1
    syscall
    cmp rax, 0 
    je no_trim
    cmp byte [rel tmp], 10          ; читаем, пока не уткнёмся в '\n'
    jne trim

no_trim:
    ; void reverse_string(char* string, uint8_t string_sz)
    lea rsi, [rel string]           ; rsi = адрес исходной строки
    movzx rdx, byte [rel string_sz] ; rdx = длина
    call reverse_string             ; rsi = адрес перевёрнутой строки             

    ; write(stdout, msg1, msg1_sz)
    mov rax, 1                    
    mov rdi, 1                    
    lea rsi, [rel msg1]               
    mov rdx, msg1_sz                    
    syscall

    ; write(stdout, string, string_sz)
    mov rax, 1                    
    mov rdi, 1                    
    lea rsi, [rel string]               
    movzx rdx, byte [rel string_sz] ; перемещаем байт в младший байт 64-разрядного регистра                 
    syscall                         
 
    ; exit(0)
    mov rax, 60                     ; 60 - номер системного вызова exit
    xor rdi, rdi                    ; код ошибки - 0
    syscall                         ; выполняем системный вызов exit
