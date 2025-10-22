global _start                      ; делаем метку метку _start видимой извне
 
section .data                      ; секция данных
    message db  "Hello, world",10  ; строка для вывода на консоль
    length  equ $ - message
 
section .text                      ; объявление секции кода
_start:                            ; точка входа в программу
    mov rax, 1                     ; 1 - номер системного вызова функции write
    mov rdi, 1                     ; 1 - дескриптор файла стандартного вызова stdout
    mov rsi, message               ; адрес строки для вывода
    mov rdx, length                ; количество байтов
    syscall                        ; выполняем системный вызов write
 
    ; Проверка результата (результат syscall -> rax)
    cmp rax, length                ; `rax - length` - установка флагов
    jl _error                      ; выполняет переход, если rax < length (записаны не все байты)

    ; Успех -> exit(0)
    mov rax, 60                    ; 60 - номер системного вызова exit
    mov rdi, 0                     ; успешное завершение
    syscall                        ; выполняем системный вызов exit

_error:
    mov rax, 60                    ; 60 - номер системного вызова exit
    mov rdi, 1                     ; код ошибки - 1
    syscall                        ; выполняем системный вызов exit
