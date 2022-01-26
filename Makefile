make_bin:
	mkdir -p bin

clean_bin_build:
	mkdir -p bin/build
	rm -f bin/build/*

build_sim: make_bin create_progmem
	iverilog -g2012 -I src/ src/*.v test/*.v bin/progmem.v -o bin/test
	
run_sim: build_sim
	./bin/test

synth: make_bin
	yosys scripts/synth.ys

build_synth: synth create_progmem
	iverilog -g2012 -I src/ bin/synth.v test/*.v bin/progmem.v -o bin/test

run_synth: build_synth
	./bin/test

SOURCES_ASM := $(wildcard code/*.S)
OBJECTS_ASM := $(patsubst code/%.S, bin/build/%.S.o, $(SOURCES_ASM))

SOURCES_C := $(wildcard code/*.c)
OBJECTS_C := $(patsubst code/%.c, bin/build/%.c.o, $(SOURCES_C))

bin/build/%.S.o: code/%.S
	riscv64-unknown-elf-gcc -c -mabi=ilp32 -march=rv32i -o $@ $<

bin/build/%.c.o: code/%.c
	riscv64-unknown-elf-gcc -c -mabi=ilp32 -march=rv32i -mstrict-align -I code/ -o $@ $<

build_firmware: clean_bin_build $(OBJECTS_ASM) $(OBJECTS_C)
	riscv64-unknown-elf-gcc -Wl,-M,-T scripts/link.ld -mabi=ilp32 -march=rv32i -nostdlib bin/build/*.o -lgcc -o bin/firmware.elf
	riscv64-unknown-elf-objcopy -O binary bin/firmware.elf bin/firmware.bin

create_progmem: build_firmware
	python scripts/create_switch.py bin/firmware.bin bin/progmem.v
