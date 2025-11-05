%include "macro.inc"

; reverse_to_stack(rsi = адрес исходной строки, rdx = длина)
global reverse_string
reverse_string:
    test rdx, rdx                   ; проверка на нулевую длину
    jz .done                        ; длина == 0 -> выход

    ;push rdi                       
    ;push rcx

    ;cmp rdx, 2
    ;ja .do_reverse                  ; длина > 2 -> разворот

    ; Иначе длина 1 или 2 — проверяем на наличие '\n'
    ;cld                             ; убедиться, что направление для repne вперёд
    ;mov rcx, rdx                    ; rcx = длина строки
    ;mov rdi, rsi                    ; rdi = адрес строки
    ;mov al, 10                      ; '\n'
    ;repne scasb                     ; поиск '\n'

    ;pop rcx
    ;pop rdx

    ;je .done                        ; <=2 символов, один из которых '\n' -> выход

 ;.do_reverse:
    ; сохранение регистров, которые будут использованы
    ; (см. https://metanit.com/assembler/nasm/4.2.php)
    push rdi                       
    push rcx
    push r8

    ; 1. Создать локальный временный буфер temp на стеке
    mov rcx, rdx                    ; rcx = длина (используется командой loop)
    sub rsp, rcx                    ; память на стеке растёт в сторону уменьшения адресов -> указываем, сколько ячеек резервируем
    mov rdi, rsp                    ; rdi -> временный буфер temp

    ; r8 -> последний символ исходной строки
    lea r8, [rsi + (rcx - 1) - 1]   ; (rcx - 1) - последний индекс; -1, т.к. не нужен '\n' или другой символ

    ; 2. Скопировать в temp строку в обратном порядке
.reverse_copy:
    ; чтение 1 байта по адресу r8
    mov al, [r8]                    ; movzx rax, byte [r8]
    mov [rdi], al                   ; запись в temp с начала
    dec r8
    inc rdi
    loop .reverse_copy              ; ВАЖНО: декремент rcx

    ; 3. Скопировать обратно в исходный буфер (по адресу rsi)
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
    pop rcx
    pop rdi
    
.done:
    ret









global parse_int16
; parse_int16(rsi = адрес исходной строки, rdx = длина)
; Парсит строку длины len как 16-битное знаковое число.
; Возвращает:
;   ebx = результат (int16)
;   rax = 0
; При ошибке:
;   rax = -1
parse_int16:
    cmp     rdx, 1              ; если длина < 1 -> невозможное число
    jl      .fail

    xor     rcx, rcx            ; rcx = флаг знака (0 = +, 1 = -)
    xor     ebx, ebx            ; ebx = аккумулятор результата (int32)

    mov     al, [rsi]           ; проверяем первый символ
    cmp     al, '-'
    jne     .check_first        ; если не '-', переходим к проверке цифры

    ; Обрабатываем знак
    mov     rcx, 1              ; sign = '-'
    inc     rsi                 ; пропускаем '-'
    dec     rdx                 ; уменьшаем длину строки
    cmp     rdx, 1              ; после '-' должна быть хотя бы одна цифра
    jl      .fail

.check_first:
    mov     al, [rsi]
    cmp     al, '0'
    jb      .fail                ; если < '0', не цифра
    cmp     al, '9'
    ja      .fail                ; если > '9', не цифра

.digit_loop:
    cmp     rdx, 0
    je      .apply               ; всё прочитано — завершить

    mov     al, [rsi]           ; читаем текущий символ
    cmp     al, 10              ; если '\n', конец ввода
    je      .apply
    cmp     al, 13              ; если '\r', тоже конец
    je      .apply

    ; Проверяем, что символ цифра
    cmp     al, '0'
    jb      .fail
    cmp     al, '9'
    ja      .fail

    ; Переводим символ в число (0..9)
    sub     al, '0'
    movzx   r8d, al           ; r8d = значение цифры

    ; Умножаем накопленное число на 10 и добавляем цифру
    imul    ebx, ebx, 10
    add     ebx, r8d

    inc     rsi                 ; переходим к следующему символу
    dec     rdx                 ; уменьшаем оставшуюся длину
    jmp     .digit_loop

.apply:
    test    rcx, rcx           ; проверяем, был ли знак '-'
    jz      .ok
    neg     ebx                 ; инвертируем значение при отрицательном знаке

.ok:
    xor     rax, rax            ; rax = 0
    ret

.fail:
    mov     rax, -1             ; rax = ошибка
    ret

global int_to_string
; int_to_string(rdi = number, rsi = buffer, rdx = bufsize) -> rax = length
int_to_string:
    push    rbx                ; сохраняем rbx, т.к. будем использовать
    push    r12                ; сохраняем r12 (будет хранить адрес буфера)

    mov     eax, edi           ; eax = входное число (параметр 1)
    mov     r12, rsi           ; r12 = указатель на начало буфера (параметр 2)
    mov     rcx, rdx           ; rcx = размер буфера (параметр 3)

    ; Проверка на ноль
    cmp     eax, 0             ; число == 0 ?
    jne     .check_sign
    mov     byte [r12], '0'    ; записываем символ '0'
    mov     eax, 1             ; длина строки = 1
    jmp     .done              ; готово

.check_sign:
    mov     ebx, 0             ; EBX = флаг знака (0 = плюс, 1 = минус)
    cmp     eax, 0
    jge     .start_convert     ; если число >= 0 -> сразу в конвертацию
    neg     eax                ; иначе берём модуль
    mov     ebx, 1             ; и помечаем, что был минус

.start_convert:
    ; Ставим rsi в конец буфера и добавляем завершающий ноль
    lea     rsi, [r12 + rcx - 1]; rsi = (buf + size - 1) — последняя позиция
    mov     byte [rsi], 0       ; конец строки ('\0')

.convert_loop:
    mov     edx, 0             ; расширяем для div (edx:eax / ecx)
    mov     ecx, 10
    div     ecx                ; делим eax на 10
    add     dl, '0'            ; преобразуем остаток в ASCII-цифру
    dec     rsi                ; двигаемся назад в буфере
    mov     [rsi], dl          ; помещаем цифру
    test    eax, eax           ; eax == 0 ?
    jnz     .convert_loop      ; если нет - продолжаем

    ; Добавление знака 
    cmp     ebx, 1             ; был ли минус?
    jne     .no_sign
    dec     rsi
    mov     byte [rsi], '-'    ; вставляем '-'

.no_sign:
    ; Сейчас rsi - начало сформированной строки
    ; r12 -> начало буфера

    ; Вычисление длины строки
    mov     rax, r12           ; rax = адрес начала буфера
    sub     rax, rsi           ; rax = r12 - rsi -> отрицательное значение
    neg     rax                ; rax = длина строки

    ; Копирование строки в начало буфера
    ; Нужно, если конвертация начиналась не с начала
    mov     rdi, r12           ; rdi = dst (начало буфера)
    mov     rdx, rax           ; rdx = длина строки
    ; rsi = src (уже на месте)
    rep movsb                  ; копируем count байт

.done:
    pop     r12                ; восстановление регистров
    pop     rbx
    ret
