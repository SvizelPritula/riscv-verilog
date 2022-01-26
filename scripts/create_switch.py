import sys
import struct

if len(sys.argv) != 3:
    print("Usage: [input] [output]")
    sys.exit(1)

with open(sys.argv[1], "rb") as firmware:
    with open(sys.argv[2], "w") as code:
        code.write("module progmem (output reg [31:0] memory_out, input wire [19:2] address);\n")
        code.write("always @(address) case (address)\n")

        address = 0

        while (data := firmware.read(4)):
            word, = struct.unpack("<I", data.ljust(4, b'\0'))
            if word != 0:
                code.write(f"18'h{address:05X}: memory_out = 32'h{word:08X};\n")

            address += 1

        code.write("default: memory_out = 32'd0;\n")
        code.write("endcase\n")
        code.write("endmodule\n")