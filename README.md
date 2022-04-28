# A RISC-V processor in Verilog

This is a simple implementation of the RV32I architecture in Verilog. It also includes scripts that utilize Yosys to synthesize a netlist using NOR gates.

## Building

You can build the processor using `make`. This will produce an executable file at `./bin/test` that runs a simulation of the selected firmware.

You may additionally supply the following environment variables:

* `FIRMWARE` - The name of the folder in which the target firmware resides. May be `art` (default), `graph`, `hello` or `multiplier`.
* `SIM` - If set to true, skips synthesis and simulates Verilog source.
* `VERBOSE` - Sets the `VERBOSE` define for Verilog files. Causes testbench to print all memory accesses.

## Running

To simulate the program, either build an executable as described above and run it, or use `make run` to do it in one step.
