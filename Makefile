make_bin:
	mkdir -p bin

clean_bin_build:
	mkdir -p bin/build
	rm -rf bin/build/*
	
synth: make_bin
	yosys scripts/synth.ys

build: make_bin create_progmem $(if ${SIM},,synth)
	iverilog -g2012 $(if ${VERBOSE},-DVERBOSE) -I src/ $(if ${SIM},src/*.v,bin/synth.v scripts/nor.v) test/*.v bin/progmem.v -o bin/test

run: build
	./bin/test

FIRMWARE ?= art

SOURCES_ASM := $(wildcard code/lib/*.S) $(wildcard code/${FIRMWARE}/*.S)
OBJECTS_ASM := $(patsubst code/%.S, bin/build/%.S.o, $(SOURCES_ASM))

SOURCES_C := $(wildcard code/lib/*.c) $(wildcard code/${FIRMWARE}/*.c)
OBJECTS_C := $(patsubst code/%.c, bin/build/%.c.o, $(SOURCES_C))

SOURCES_CPP := $(wildcard code/lib/*.cpp) $(wildcard code/${FIRMWARE}/*.cpp)
OBJECTS_CPP := $(patsubst code/%.cpp, bin/build/%.cpp.o, $(SOURCES_CPP))

bin/build/%.S.o: code/%.S
	mkdir -p $(@D)
	riscv64-unknown-elf-gcc -c -mabi=ilp32 -march=rv32i -o $@ $<

bin/build/%.c.o: code/%.c
	mkdir -p $(@D)
	riscv64-unknown-elf-gcc -c -mabi=ilp32 -march=rv32i -mstrict-align -ffreestanding -O3 -Icode/ -o $@ $<

bin/build/%.cpp.o: code/%.cpp
	mkdir -p $(@D)
	riscv64-unknown-elf-g++ -c -mabi=ilp32 -march=rv32i -mstrict-align -ffreestanding -O3 -Icode/ -o $@ $<

build_firmware: clean_bin_build $(OBJECTS_ASM) $(OBJECTS_C) $(OBJECTS_CPP)
	riscv64-unknown-elf-gcc -Wl,-M,-T scripts/link.ld -mabi=ilp32 -march=rv32i -nostdlib ${OBJECTS_ASM} ${OBJECTS_C} ${OBJECTS_CPP} -lgcc -o bin/firmware.elf
	riscv64-unknown-elf-objcopy -O binary bin/firmware.elf bin/firmware.bin

create_progmem: build_firmware
	python scripts/create_switch.py bin/firmware.bin bin/progmem.v
