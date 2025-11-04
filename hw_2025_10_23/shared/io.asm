global reverse_string

; reverse_to_stack(rsi=адрес исходной строки, rdx=длина)
reverse_string:
    test rdx, rdx                   ; проверка на нулевую длину
    jz .done                        ; длина == 0 -> выход

    ; сохранение регистров, которые будут использованы
    ; (см. https://metanit.com/assembler/nasm/4.2.php)
    push rdi                       
    push rcx
    
;    cmp rdx, 2
;    ja .do_reverse                  ; длина > 2 -> разворот

    ; Иначе длина 1 или 2 — проверяем на наличие '\n'
;    cld                             ; убедиться, что направление для repne вперёд
;    mov rcx, rdx                    ; rcx = длина строки
;    mov rdi, rsi                    ; rdi = адрес строки
;    mov al, 10                      ; '\n'
;    repne scasb                     ; поиск '\n'

;    je .done                        ; <=2 символов, один из которых '\n' -> выход

;.do_reverse:
    push r8

; - Создать локальный временный буфер temp на стеке
    mov rcx, rdx                    ; rcx = длина (используется командой loop)
    sub rsp, rcx                    ; память на стеке растёт в сторону уменьшения адресов -> указываем, сколько ячеек резервируем
    mov rdi, rsp                    ; rdi -> временный буфер temp

    ; r8 -> последний символ исходной строки
    lea r8, [rsi + (rcx - 1) - 1]   ; (rcx - 1) - последний индекс; -1, т.к. не нужен '\n'

; - Скопировать в temp строку в обратном порядке
.reverse_copy:
    ; чтение 1 байта по адресу r8
    mov al, [r8]                    ; movzx rax, byte [r8]
    mov [rdi], al                   ; запись в temp с начала
    dec r8
    inc rdi
    loop .reverse_copy              ; ВАЖНО: декремент rcx

; - Скопировать обратно в исходный буфер (по адресу rsi)
    mov rcx, rdx                    ; обновление rcx после loop
    mov rdi, rsi                    ; rdi -> исходная строка
    mov r8, rsp                     ; r8 -> temp

.copy_back:
    mov al, [r8]
    mov [rdi], al
    inc r8
    inc rdi
    loop .copy_back

    ; Освободить стек
    add rsp, rdx

    pop r8
    
.done
    pop rcx
    pop rdi

    ret
