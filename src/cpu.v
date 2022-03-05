`include "opcode.vh"
`define STATE_FETCH 2'b00
`define STATE_EXECUTE 2'b10
`define STATE_EXECUTE2 2'b11

module cpu (
    input wire clk,
    input wire rst,
    input wire [31:0] memory_out,
    output wire [31:0] memory_in,
    output wire [31:2] address,
    output wire write_enable,
    input wire read_capable,
    input wire write_capable
);

reg [1:0] state;
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
                            if (access_mask[7:4] != 4'd0) begin
                                state <= `STATE_EXECUTE2;
                            end else begin
                                ip <= ip + 1;
                                if (rd > 5'd0) registers[rd] <= read_value_extended;
                                state <= `STATE_FETCH;
                            end
                        end else begin
                            error <= 1;
                            state <= `STATE_FETCH;
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
                        
                        state <= `STATE_FETCH;
                    end
                    `OPCODE_OP_IMM: begin
                        if (rd > 5'd0) registers[rd] <= alu_result;
                        ip <= ip + 1;
                        
                        state <= `STATE_FETCH;
                    end
                    `OPCODE_AUIPC: begin
                        if (rd > 5'd0) registers[rd] <= imm_u + {ip, 2'b00};
                        ip <= ip + 1;
                        
                        state <= `STATE_FETCH;
                    end
                    `OPCODE_STORE: begin
                        if (!memory_error && write_capable) begin
                            if (access_mask[7:4] != 4'd0) begin
                                state <= `STATE_EXECUTE2;
                            end else begin
                                ip <= ip + 1;
                                state <= `STATE_FETCH;
                            end
                        end else begin
                            error <= 1;
                            state <= `STATE_FETCH;
                        end
                    end
                    `OPCODE_OP: begin
                        if (!alu_error) begin
                            if (rd > 5'd0) registers[rd] <= alu_result;
                            ip <= ip + 1;
                        end else begin
                            error <= 1;
                        end
                        
                        state <= `STATE_FETCH;
                    end
                    `OPCODE_LUI: begin
                        if (rd > 5'd0) registers[rd] <= imm_u;
                        ip <= ip + 1;
                        
                        state <= `STATE_FETCH;
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
                        
                        state <= `STATE_FETCH;
                    end
                    `OPCODE_JALR: begin
                        target = (rs1_value + imm_i) & 32'hfffffffe;

                        if (target[1:0] == 2'd0 && funct3 == 3'd0) begin
                            ip <= target[31:2];
                            if (rd > 5'd0) registers[rd] <= {ip + 30'd1, 2'b00};
                        end else begin
                            error <= 1;
                        end

                        state <= `STATE_FETCH;
                    end
                    `OPCODE_JAL: begin
                        target = {ip, 2'b00} + imm_j;

                        if (target[1:0] == 2'd0) begin
                            ip <= target[31:2];
                            if (rd > 5'd0) registers[rd] <= {ip + 30'd1, 2'b00};
                        end else begin
                            error <= 1;
                        end

                        state <= `STATE_FETCH;
                    end
                    default: begin
                        error <= 1;
                        state <= `STATE_FETCH;
                    end
                endcase
            end

            `STATE_EXECUTE2: begin
                case (opcode)
                    `OPCODE_LOAD: begin
                        if (!memory_error && read_capable) begin
                            ip <= ip + 1;
                            if (rd > 5'd0) registers[rd] <= read_value_extended;
                        end else begin
                            error <= 1;
                        end
                    end
                    `OPCODE_STORE: begin
                        if (!memory_error && write_capable) begin
                            ip <= ip + 1;
                        end else begin
                            error <= 1;
                        end
                    end
                endcase

                state <= `STATE_FETCH;
            end
        endcase
    end
end

wire [31:0] access_address = (opcode == `OPCODE_STORE ? imm_s : imm_i) + rs1_value;
assign address = state == `STATE_FETCH ? ip : (access_address[31:2] + (state == `STATE_EXECUTE2 ? 1 : 0));

reg [3:0] access_width;
wire [7:0] access_mask = { 4'd0, access_width } << access_address[1:0];
wire do_write = opcode == `OPCODE_STORE && write_capable && (state == `STATE_EXECUTE || state == `STATE_EXECUTE2);
wire [3:0] write_enable_bytes = do_write ? (state == `STATE_EXECUTE ? access_mask[3:0] : access_mask[7:4]) : 4'd0;
assign write_enable = write_enable_bytes != 0;

always @(funct3) begin
    case (funct3[1:0])
        `FUNCT3_B: access_width = 4'b0001;
        `FUNCT3_H: access_width = 4'b0011;
        `FUNCT3_W: access_width = 4'b1111;
        default: access_width = 4'b0000;
    endcase
end

wire [63:0] memory_in_full = { 32'd0, rs2_value } << (8 * access_address[1:0]);
wire [31:0] memory_in_unmasked = state == `STATE_EXECUTE ? memory_in_full[31:0] : memory_in_full[63:32];

assign memory_in[7:0] = write_enable_bytes[0] ? memory_in_unmasked[7:0] : memory_out[7:0];
assign memory_in[15:8] = write_enable_bytes[1] ? memory_in_unmasked[15:8] : memory_out[15:8];
assign memory_in[23:16] = write_enable_bytes[2] ? memory_in_unmasked[23:16] : memory_out[23:16];
assign memory_in[31:24] = write_enable_bytes[3] ? memory_in_unmasked[31:24] : memory_out[31:24];

reg [31:0] memory_first_read;

always @(posedge clk) begin
    if (state == `STATE_EXECUTE) begin
        memory_first_read <= memory_out;
    end
end

wire [3:0] read_mask_first = access_mask[3:0] >> access_address[1:0];

wire [31:0] read_value_first = (state == `STATE_EXECUTE ? memory_out : memory_first_read) >> (8 * access_address[1:0]);
wire [31:0] read_value_second = memory_out << (8 * (4 - access_address[1:0]));

wire [31:0] read_value;
assign read_value[7:0] = read_mask_first[0] ? read_value_first[7:0] : read_value_second[7:0];
assign read_value[15:8] = read_mask_first[1] ? read_value_first[15:8] : read_value_second[15:8];
assign read_value[23:16] = read_mask_first[2] ? read_value_first[23:16] : read_value_second[23:16];
assign read_value[31:24] = read_mask_first[3] ? read_value_first[31:24] : read_value_second[31:24];

reg [31:0] read_value_extended;

always @(funct3, read_value) begin
    case (funct3)
        `FUNCT3_B: read_value_extended = {{24{read_value[7]}}, read_value[7:0]};
        `FUNCT3_H: read_value_extended = {{16{read_value[15]}}, read_value[15:0]};
        `FUNCT3_W: read_value_extended = read_value;
        `FUNCT3_BU: read_value_extended = {24'd0, read_value[7:0]};
        `FUNCT3_HU: read_value_extended = {16'd0, read_value[15:0]};
        default: read_value_extended = 32'd0;
    endcase
end

reg memory_error;

always @(opcode, funct3, access_address) begin
    if (opcode == `OPCODE_STORE || opcode == `OPCODE_LOAD) begin
        case (funct3)
            `FUNCT3_B: memory_error = 0;
            `FUNCT3_H: memory_error = 0;
            `FUNCT3_W: memory_error = 0;
            `FUNCT3_BU: memory_error = opcode == `OPCODE_STORE;
            `FUNCT3_HU: memory_error = opcode == `OPCODE_STORE;
            default: memory_error = 1;
        endcase
    end else begin
        memory_error = 0;
    end
end
    
endmodule