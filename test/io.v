`define IO_OUT 1'b0
`define IO_POWER 1'b1

module io (
    input wire clk,
    input wire [31:0] memory_in,
    input wire [2:2] address,
    input wire write_enable
);

always @(posedge clk) begin 
    if (write_enable) begin
        case (address)
            `IO_OUT: begin
                $write("%c", memory_in[7:0]);
                $fflush();
            end
            `IO_POWER: begin
                $finish();
            end
        endcase
    end
end

endmodule
