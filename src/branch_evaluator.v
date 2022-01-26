`include "opcode.vh"

module branch_evaluator (
    input wire [2:0] funct3,
    input wire [31:0] a,
    input wire [31:0] b,
    output reg result,
    output wire error
);

always @(funct3, a, b) begin
    case (funct3)
        `FUNCT3_BEQ: begin
            result = a == b;
        end
        `FUNCT3_BNE: begin
            result = a != b;
        end
        `FUNCT3_BLT: begin
            result = $signed(a) < $signed(b);
        end
        `FUNCT3_BGE: begin
            result = $signed(a) >= $signed(b);
        end
        `FUNCT3_BLTU: begin
            result = a < b;
        end
        `FUNCT3_BGEU: begin
            result = a >= b;
        end
        default: result = 1'bx;
    endcase
end

assign error = (funct3 == 3'b010 || funct3 == 3'b011);

endmodule