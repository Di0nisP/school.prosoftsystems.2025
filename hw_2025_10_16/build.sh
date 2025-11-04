#!/bin/bash
# Создаём каталоги, если их ещё нет
mkdir -p files build

# Сборка
nasm -f elf64 hw01.asm -o build/hw01.o -l files/hw01.lst
ld -o build/hw01.out build/hw01.o

# Запуск
strace build/hw01.out \
    1> files/hw01.txt \
    2> files/strace_output.txt # strace пишет в stderr

# Очистка после запуска
#rm -f build/hw01.o # оставляем исполняемый файл
rm -rf build/
