`include "opcode.vh"

module decoder (
    input wire [31:0] instruction,
    output wire [6:0] opcode,
    output wire [4:0] rd,
    output wire [4:0] rs1,
    output wire [4:0] rs2,
    output wire [2:0] funct3,
    output wire [6:0] funct7,
    output wire [31:0] imm_i,
    output wire [31:0] imm_s,
    output wire [31:0] imm_b,
    output wire [31:0] imm_u,
    output wire [31:0] imm_j
);

assign opcode = instruction[6:0];

assign rd = instruction[11:7];
assign rs1 = instruction[19:15];
assign rs2 = instruction[24:20];

assign funct3 = instruction[14:12];
assign funct7 = instruction[31:25];

assign imm_i = {{21{instruction[31]}}, instruction[30:20]};
assign imm_s = {{21{instruction[31]}}, instruction[30:25], instruction[11:7]};
assign imm_b = {{20{instruction[31]}}, instruction[7], instruction[30:25], instruction[11:8], 1'd0};
assign imm_u = {instruction[31:12], 12'd0};
assign imm_j = {{12{instruction[31]}}, instruction[19:12], instruction[20], instruction[30:21], 1'd0};

endmodule
