`include "opcode.vh"
`define STATE_FETCH 1'b0
`define STATE_EXECUTE 1'b1

module cpu (
    input wire clk,
    input wire rst,
    input wire [31:0] memory_out,
    output wire [31:0] memory_in,
    output wire [31:2] address,
    output reg [3:0] write_enable,
    input wire read_capable,
    input wire write_capable
);

reg [0:0] state;
reg [31:2] ip;
reg [31:0] registers [31:1];

reg error;

reg [31:0] instruction;

wire [6:0] opcode;
wire [4:0] rd;
wire [4:0] rs1;
wire [4:0] rs2;
wire [2:0] funct3;
wire [6:0] funct7;
wire [31:0] imm_i;
wire [31:0] imm_s;
wire [31:0] imm_b;
wire [31:0] imm_u;
wire [31:0] imm_j;

decoder decoder (
    .instruction(instruction),
    .opcode(opcode),
    .rd(rd),
    .rs1(rs1),
    .rs2(rs2),
    .funct3(funct3),
    .funct7(funct7),
    .imm_i(imm_i),
    .imm_s(imm_s),
    .imm_b(imm_b),
    .imm_u(imm_u),
    .imm_j(imm_j)
);

wire [31:0] rs1_value = rs1 > 5'd0 ? registers[rs1] : 32'd0;
wire [31:0] rs2_value = rs2 > 5'd0 ? registers[rs2] : 32'd0;

wire [31:0] alu_result;
wire alu_error;

alu alu (
    .opcode(opcode),
    .funct3(funct3),
    .funct7(funct7),
    .rs1_value(rs1_value),
    .rs2_value(rs2_value),
    .imm(imm_i),
    .result(alu_result),
    .error(alu_error)
);

wire branch_evaluator_result;
wire branch_evaluator_error;

branch_evaluator branch_evaluator (
    .funct3(funct3),
    .a(rs1_value),
    .b(rs2_value),
    .result(branch_evaluator_result),
    .error(branch_evaluator_error)
);

integer i;
reg [31:0] value;
reg [31:0] target;

always @(posedge clk) begin
    if (rst) begin
        state <= `STATE_FETCH;
        ip <= 0;
        error <= 0;

        for (i = 1; i < 32; i++) begin
            registers[i] = 32'd0;
        end
    end else if (!error) begin
        case (state)
            `STATE_FETCH: begin
                instruction <= memory_out;
                state <= `STATE_EXECUTE;
            end
            `STATE_EXECUTE: begin
                case (opcode)
                    `OPCODE_LOAD: begin
                        if (!memory_error && read_capable) begin
                            value = memory_out >> (8 * access_address[1:0]);

                            case (funct3)
                                `FUNCT3_B: begin
                                    if (rd > 5'd0) registers[rd] <= {{24{value[7]}}, value[7:0]};
                                end
                                `FUNCT3_H: begin
                                    if (rd > 5'd0) registers[rd] <= {{16{value[15]}}, value[15:0]};
                                end
                                `FUNCT3_W: begin
                                    if (rd > 5'd0) registers[rd] <= value;
                                end
                                `FUNCT3_BU: begin
                                    if (rd > 5'd0) registers[rd] <= {24'd0, value[7:0]};
                                end
                                `FUNCT3_HU: begin
                                    if (rd > 5'd0) registers[rd] <= {16'd0, value[15:0]};
                                end
                            endcase

                            ip <= ip + 1;
                        end else begin
                            error <= 1;
                        end
                    end
                    `OPCODE_MISC_MEM: begin
                        case (funct3)
                            `FUNCT3_FENCE: begin
                                if (rd == 5'd0 && rs1 == 5'd0) begin
                                    if (instruction[31:28] == 4'b0000 || instruction[31:20] == 12'b100000110011) begin
                                        ip <= ip + 1;
                                    end else begin
                                        error <= 1;
                                    end
                                end else begin
                                    error <= 1;
                                end
                            end
                            default: error <= 1;
                        endcase
                        ip <= ip + 1;
                    end
                    `OPCODE_OP_IMM: begin
                        if (rd > 5'd0) registers[rd] <= alu_result;
                        ip <= ip + 1;
                    end
                    `OPCODE_AUIPC: begin
                        if (rd > 5'd0) registers[rd] <= imm_u + {ip, 2'b00};
                        ip <= ip + 1;
                    end
                    `OPCODE_STORE: begin
                        if (!memory_error && write_capable) begin
                            ip <= ip + 1;
                        end else begin
                            error <= 1;
                        end
                    end
                    `OPCODE_OP: begin
                        if (!alu_error) begin
                            if (rd > 5'd0) registers[rd] <= alu_result;
                            ip <= ip + 1;
                        end else begin
                            error <= 1;
                        end
                    end
                    `OPCODE_LUI: begin
                        if (rd > 5'd0) registers[rd] <= imm_u;
                        ip <= ip + 1;
                    end
                    `OPCODE_BRANCH: begin
                        target = {ip, 2'b00} + imm_b;

                        if (branch_evaluator_error) begin
                            error <= 1;
                        end else if (branch_evaluator_result) begin
                            if (target[1:0] == 2'd0) begin
                                ip <= target[31:2];
                            end else begin
                                error <= 1;
                            end
                        end else begin
                            ip <= ip + 1;
                        end
                    end
                    `OPCODE_JALR: begin
                        target = (rs1_value + imm_i) & 32'hfffffffe;

                        if (target[1:0] == 2'd0) begin
                            ip <= target[31:2];
                            if (rd > 5'd0) registers[rd] <= {ip + 30'd1, 2'b00};
                        end else begin
                            error <= 1;
                        end
                    end
                    `OPCODE_JAL: begin
                        target = {ip, 2'b00} + imm_j;

                        if (target[1:0] == 2'd0) begin
                            ip <= target[31:2];
                            if (rd > 5'd0) registers[rd] <= {ip + 30'd1, 2'b00};
                        end else begin
                            error <= 1;
                        end
                    end
                    default: begin
                        error <= 1;
                    end
                endcase

                state <= `STATE_FETCH;
            end
        endcase
    end
end

wire [31:0] access_address = (opcode == `OPCODE_STORE ? imm_s : imm_i) + rs1_value;
assign address = state == `STATE_FETCH ? ip : access_address[31:2];

assign memory_in = rs2_value << (8 * access_address[1:0]);

always @(opcode, funct3, access_address, write_capable) begin
    if (opcode == `OPCODE_STORE && write_capable) begin
        case (funct3)
            `FUNCT3_B: begin
                write_enable = 4'b0001 << (access_address[1:0]);
            end
            `FUNCT3_H: begin
                if (access_address[0] == 1'b0) begin
                    write_enable = 4'b0011 << (access_address[1:0]);
                end else begin
                    write_enable = 4'b0000;
                end
            end
            `FUNCT3_W: begin
                if (access_address[1:0] == 2'b0) begin
                    write_enable = 4'b1111;
                end else begin
                    write_enable = 4'b0000;
                end
            end
            default: write_enable = 4'b0000;
        endcase
    end else begin
        write_enable = 4'b0000;
    end
end

reg memory_error;

always @(opcode, funct3, access_address) begin
    if (opcode == `OPCODE_STORE || opcode == `OPCODE_LOAD) begin
        case (funct3)
            `FUNCT3_B: memory_error = 0;
            `FUNCT3_H: memory_error = access_address[0] != 1'b0;
            `FUNCT3_W: memory_error = access_address[1:0] != 2'b0;
            `FUNCT3_BU: memory_error = opcode == `OPCODE_STORE;
            `FUNCT3_HU: memory_error = access_address[0] != 1'b0 || opcode == `OPCODE_STORE;
            default: memory_error = 1;
        endcase
    end else begin
        memory_error = 0;
    end
end
    
endmodule