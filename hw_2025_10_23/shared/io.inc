extern reverse_string

%macro PRINT 2
    mov rax, 1        ; номер системного вызова write
    mov rdi, 1        ; fd=1 -> stdout
    lea rsi, [%1]     ; адрес строки
    mov rdx, %2       ; длина строки
    syscall
%endmacro