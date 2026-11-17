CC ?= cc
CFLAGS ?= -std=c99 -O1 -g -Wall -Wextra -Werror -fsanitize=address,undefined -fno-omit-frame-pointer
JL_CLANG ?= clang
JL_OBJDUMP ?= objdump

.PHONY: check q32s firmware
check: build/test_macro_store build/test_config_image
	./build/test_macro_store
	./build/test_config_image
	python3 -m unittest discover -s tests -p 'test_*.py' -v

build/test_macro_store: src/macro_store.c src/macro_store.h tests/test_macro_store.c
	mkdir -p build
	$(CC) $(CFLAGS) -Isrc src/macro_store.c tests/test_macro_store.c -o $@

build/test_config_image: src/macro_store.c src/macro_store.h src/config_image.c src/config_image.h tests/test_config_image.c
	mkdir -p build
	$(CC) $(CFLAGS) -Isrc src/macro_store.c src/config_image.c tests/test_config_image.c -o $@

q32s:
	mkdir -p build
	$(JL_CLANG) -target q32s -Os -ffreestanding -fno-builtin -Wall -Wextra -Werror -Isrc -c src/macro_store.c -o build/macro_store.q32s.o
	$(JL_CLANG) -target q32s -Os -ffreestanding -fno-builtin -Wall -Wextra -Werror -Isrc -c src/config_image.c -o build/config_image.q32s.o
	$(JL_OBJDUMP) -d -arch-name=q32s build/macro_store.q32s.o > build/macro_store.q32s.asm
	$(JL_OBJDUMP) -d -arch-name=q32s build/config_image.q32s.o > build/config_image.q32s.asm

firmware:
	python3 tools/build_firmware.py
