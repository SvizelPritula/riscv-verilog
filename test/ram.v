module ram (
    input wire clk,
    output wire [31:0] memory_out,
    input wire [31:0] memory_in,
    input wire [11:2] address,
    input wire write_enable
);

reg [31:0] storage [1024];

assign memory_out = storage[address];

always @(posedge clk) begin
    if (write_enable) begin
        storage[address] <= memory_in;
    end
end

endmodule