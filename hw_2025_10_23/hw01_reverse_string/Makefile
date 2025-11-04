# Папки
BUILD_DIR = build
FILES_DIR = files

# Название выходного файла
TARGET = hw01_reverse_string

# Исходники
SRC = main.asm
SHARED_SRC = ../shared/io.asm
INC = ../shared/io.inc

# Объекты
OBJ = $(BUILD_DIR)/main.o $(BUILD_DIR)/io.o
BIN = $(BUILD_DIR)/$(TARGET).out
LST = $(FILES_DIR)/$(TARGET).lst
OUT = $(FILES_DIR)/$(TARGET).txt
STRACE = $(FILES_DIR)/strace_output.txt

# Флаги NASM
NASMFLAGS = -f elf64

# Цель по умолчанию
all: run

# Цель: создание директорий сборки
prepare:
	@mkdir -p $(BUILD_DIR) $(FILES_DIR)

# Цель: сборка
build: prepare $(BIN)

$(BIN): $(OBJ)
	ld -o $(BIN) $(OBJ)

$(BUILD_DIR)/main.o: $(SRC) $(INC)
	nasm $(NASMFLAGS) $(SRC) -o $@

$(BUILD_DIR)/io.o: $(SHARED_SRC)
	nasm $(NASMFLAGS) $(SHARED_SRC) -o $@

# Цель: очистка
clean:
	rm -rf $(BUILD_DIR)
	rm -rf $(FILES_DIR)
	rm -f $(OUT) $(STRACE)

# Цель: запуск (сборка + запуск с выводом)
run: build
	strace $(BIN) 2> $(STRACE)

