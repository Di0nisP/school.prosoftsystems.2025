%include "../shared/io.inc"         ; подключаем экстерны функций
%include "../shared/macro.inc"

global _start                       ; делаем метку метку _start видимой извне
 
section .data
    msg0 db "Enter number A: "      ; строка для вывода на консоль
    msg0_sz equ $ - msg0            ; длина строки
    
    msg1 db "Enter number B: " 
    msg1_sz equ $ - msg1

    msg2 db "A + B = "
    msg2_sz equ $ - msg2

    err_msg db "Invalid number int16, try again: " 
    err_msg_sz equ $ - err_msg

section .bss
    input_buf resb 7                ; буфер ввода (-32768\n)
    input_len resq 1                ; сюда read запишет длину строки

    value_A resw 1                  ; int16_t
    value_B resw 1                  ; int16_t
    value_C resd 1                  ; int32_t <- сумма

    tmp resb 1     
 
section .text                       ; объявление секции кода
_start:                             ; точка входа в программу  
    ; write(stdout, msg0, msg0_sz) 
    PRINT rel msg0, msg0_sz
    jmp .read_A

.err_A:
    PRINT rel err_msg, err_msg_sz

.read_A:
    ; read(stdin, msg0, msg0_sz)
    mov rax, 0                  
    mov rdi, 0                      ; fd=0 -> stdin       
    lea rsi, [rel input_buf]                   
    mov rdx, 7               
    syscall

    mov [rel input_len], rax

    ; остались ли данные в stdin?
    cmp rax, 7
    jne .no_trim

.trim:
    ; читаем оставшиеся байты по одному
    mov rax, 0
    mov rdi, 0
    lea rsi, [rel tmp]
    mov rdx, 1
    syscall
    cmp rax, 0 
    je .no_trim
    cmp byte [rel tmp], 10          ; читаем, пока не уткнёмся в '\n'
    jne .trim

.no_trim:

    ; parse_int16(input_buf, length)
    lea rsi, [rel input_buf]
    mov rdx, [rel input_len]
    call parse_int16 
    
    cmp rax, 0
    jl .err_A   ; rax < 0 → ошибка → повторить   

    mov [rel value_A], bx    

    ; write(stdout, msg1, msg1_sz)
    PRINT rel msg1, msg1_sz
    jmp .read_B

.err_B:
    PRINT rel err_msg, err_msg_sz

.read_B:
    ; read(stdin, msg0, msg0_sz)
    mov rax, 0                  
    mov rdi, 0                      ; fd=0 -> stdin       
    lea rsi, [rel input_buf]                   
    mov rdx, 7               
    syscall

    mov [rel input_len], rax

    lea rsi, [rel input_buf]
    mov rdx, [rel input_len]
    call parse_int16 
    
    cmp rax, 0
    jl .err_B   ; rax < 0 → ошибка → повторить

    mov [rel value_B], bx

    PRINT rel msg2, msg2_sz

    movsx eax, word [rel value_A]
    movsx ebx, word [rel value_B]
    add eax, ebx
    mov [rel value_C], eax

    mov rdi, [rel value_C]
    lea rsi, [rel input_buf]   ; используем тот же буфер под вывод
    mov rdx, 7                 ; хватит для "-65535"
    call int_to_string

    ; теперь rax = длина строки → выводим
    mov rdi, 1        ; stdout
    mov rax, 1        ; write
    lea rsi, [rel input_buf]
    mov rdx, 7      ; длина строки
    syscall
                  
    ; exit(0)
    mov rax, 60                     ; 60 - номер системного вызова exit
    xor rdi, rdi                    ; код ошибки - 0
    syscall                         ; выполняем системный вызов exit
