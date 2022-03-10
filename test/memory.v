module memory (
    input wire clk,
    output reg [31:0] memory_out,
    input wire [31:0] memory_in,
    input wire [31:2] address,
    input wire write_enable,
    output reg read_capable,
    output reg write_capable
);

localparam NONE = 2'd0;
localparam PROGMEM = 2'd1;
localparam RAM = 2'd2;
localparam IO = 2'd3;

reg [1:0] memory_type;

wire [31:0] progmem_out;
wire [31:0] ram_out;

progmem progmem(
    .memory_out(progmem_out),
    .address(address[19:2])
);

ram ram(
    .clk(clk),
    .memory_out(ram_out),
    .memory_in(memory_in),
    .address(address[11:2]),
    .write_enable(memory_type == RAM ? write_enable : 1'b0)
);

io io(
    .clk(clk),
    .memory_in(memory_in),
    .address(address[2:2]),
    .write_enable(memory_type == IO ? write_enable : 1'b0)
);

always @(address) begin
    if (address < (32'h100000 >> 2)) begin
        memory_type = PROGMEM;
    end else if (address >= (32'h80000000 >> 2) && address < (32'h80001000 >> 2)) begin
        memory_type = RAM;
    end else if (address >= (32'hFFFF0000 >> 2) && address < (32'hFFFF0008 >> 2)) begin
        memory_type = IO;
    end else begin
        memory_type = NONE;
    end
end

always @(memory_type) begin
    case (memory_type)
        PROGMEM: begin read_capable = 1; write_capable = 0; end
        RAM: begin read_capable = 1; write_capable = 1; end
        IO: begin read_capable = 0; write_capable = 1; end
        NONE: begin read_capable = 0; write_capable = 0; end
    endcase
end

always @(memory_type, progmem_out, ram_out) begin
    case (memory_type)
        PROGMEM: memory_out = progmem_out;
        RAM: memory_out = ram_out;
        default: memory_out = 0;
    endcase
end
    
endmodule
