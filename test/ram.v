module ram (
    input wire clk,
    output wire [31:0] memory_out,
    input wire [31:0] memory_in,
    input wire [11:2] address,
    input wire [3:0] write_enable
);

reg [7:0] storage [4][1024];

assign memory_out = {storage[3][address], storage[2][address], storage[1][address], storage[0][address]};

always @(posedge clk) begin
    if (write_enable[0]) begin
        storage[0][address] <= memory_in[7:0];
    end

    if (write_enable[1]) begin
        storage[1][address] <= memory_in[15:8];
    end

    if (write_enable[2]) begin
        storage[2][address] <= memory_in[23:16];
    end

    if (write_enable[3]) begin
        storage[3][address] <= memory_in[31:24];
    end
end

endmodule