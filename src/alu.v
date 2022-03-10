`include "opcode.vh"

module alu (
    input wire [6:0] opcode,
    input wire [2:0] funct3,
    input wire [6:0] funct7,
    input wire [31:0] rs1_value,
    input wire [31:0] rs2_value,
    input wire [31:0] imm,
    output reg [31:0] result,
    output wire error
);

wire [31:0] a = rs1_value;
wire [31:0] b = opcode == `OPCODE_OP_IMM ? imm : rs2_value;

always @(opcode, funct3, funct7, a, b) begin
    case (funct3)
        `FUNCT3_ADD: begin
            if (opcode == `OPCODE_OP && (funct7 & `FUNCT7_ALTERNATE) != 0) begin
                result = a - b;
            end else begin
                result = a + b;
            end
        end
        `FUNCT3_SLL: begin
            result = a << b[4:0];
        end
        `FUNCT3_SLT: begin
            result = $signed(a) < $signed(b) ? 1 : 0;
        end
        `FUNCT3_SLTU: begin
            result = a < b ? 1 : 0;
        end
        `FUNCT3_XOR: begin
            result = a ^ b;
        end
        `FUNCT3_SRL: begin
            if (((opcode == `OPCODE_OP_IMM ? imm[11:5] : funct7) & `FUNCT7_ALTERNATE) != 0) begin
                result = $signed(a) >>> b[4:0];
            end else begin
                result = a >> b[4:0];
            end
        end
        `FUNCT3_OR: begin
            result = a | b;
        end
        `FUNCT3_AND: begin
            result = a & b;
        end
    endcase
end

reg bad_funct7_error;
assign error = (opcode == `OPCODE_OP || opcode == `OPCODE_OP_IMM) && (bad_funct7_error);

always @(opcode, funct3, funct7) begin
    if (opcode == `OPCODE_OP) begin
        if (funct7 == `FUNCT7_ALTERNATE) begin
            bad_funct7_error = funct3 != `FUNCT3_ADD && funct3 != `FUNCT3_SRL;
        end else if (funct7 == `FUNCT7_NORMAL) begin
            bad_funct7_error = 0;
        end else begin
            bad_funct7_error = 1;
        end
    end else begin
        bad_funct7_error = 0;
    end
end

endmodule
