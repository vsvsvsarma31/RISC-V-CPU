module top (
    input clk,
    input rst
);

// ---- WIRE DECLARATIONS ----

// PC stage
wire [31:0] pc_current, pc_next, pc_plus4;
wire [31:0] instr_if;

// IF/ID outputs
wire [31:0] if_id_pc, if_id_instr;

// Decode stage
wire [31:0] rd1, rd2, imm;
wire        reg_write_dec, mem_read_dec, mem_write_dec;
wire        mem_to_reg_dec, alu_src_dec, branch_dec, jump_dec;
wire [1:0]  alu_op_dec;
wire [2:0]  imm_sel_dec;

// ID/EX outputs
wire        id_ex_reg_write, id_ex_mem_read, id_ex_mem_write;
wire        id_ex_mem_to_reg, id_ex_alu_src, id_ex_branch, id_ex_jump;
wire [1:0]  id_ex_alu_op;
wire [31:0] id_ex_pc, id_ex_rd1, id_ex_rd2, id_ex_imm;
wire [4:0]  id_ex_rs1, id_ex_rs2, id_ex_rd;
wire [2:0]  id_ex_funct3;
wire        id_ex_funct7_5;

// Execute stage
wire [31:0] alu_a, alu_b, alu_b_pre;
wire [31:0] alu_result;
wire        alu_zero;
wire [3:0]  alu_ctrl;
wire [31:0] branch_target;
wire        take_branch;
wire [1:0]  forward_a, forward_b;

// EX/MEM outputs
wire        ex_mem_reg_write, ex_mem_mem_read, ex_mem_mem_write;
wire        ex_mem_mem_to_reg, ex_mem_branch, ex_mem_jump;
wire [31:0] ex_mem_alu_result, ex_mem_rd2;
wire [4:0]  ex_mem_rd;
wire        ex_mem_zero;
wire [31:0] ex_mem_branch_target, ex_mem_pc_plus4;

// MEM stage
wire [31:0] mem_read_data;

// MEM/WB outputs
wire        mem_wb_reg_write, mem_wb_mem_to_reg;
wire [31:0] mem_wb_mem_data, mem_wb_alu_result;
wire [4:0]  mem_wb_rd;
wire [31:0] mem_wb_pc_plus4;

// Writeback
wire [31:0] wb_data;

// Hazard signals
wire stall_pc, stall_if_id, flush_id_ex;

// Branch flush
wire flush_if_id_branch;
assign flush_if_id_branch = take_branch;

// ---- PC NEXT LOGIC ----
assign pc_plus4 = pc_current + 32'd4;
assign pc_next  = take_branch ? branch_target : pc_plus4;

// ---- MODULE INSTANTIATIONS ----

// 1. PC Register
pc_register PC (
    .clk(clk), .rst(rst),
    .stall(stall_pc),
    .pc_next(pc_next),
    .pc(pc_current)
);

// 2. Instruction Memory
instr_memory IMEM (
    .addr(pc_current),
    .instr(instr_if)
);

// 3. IF/ID Pipeline Register
IF_ID_reg IF_ID (
    .clk(clk), .rst(rst),
    .flush(flush_if_id_branch),
    .stall(stall_if_id),
    .pc_in(pc_current),
    .instr_in(instr_if),
    .pc_out(if_id_pc),
    .instr_out(if_id_instr)
);

// 4. Decoder
decoder DEC (
    .opcode(if_id_instr[6:0]),
    .funct3(if_id_instr[14:12]),
    .funct7(if_id_instr[31:25]),
    .reg_write(reg_write_dec),
    .mem_read(mem_read_dec),
    .mem_write(mem_write_dec),
    .mem_to_reg(mem_to_reg_dec),
    .alu_src(alu_src_dec),
    .branch(branch_dec),
    .jump(jump_dec),
    .imm_sel(imm_sel_dec),
    .alu_op(alu_op_dec)
);

// 5. Register File
register_file RF (
    .clk(clk),
    .we(mem_wb_reg_write),
    .rs1(if_id_instr[19:15]),
    .rs2(if_id_instr[24:20]),
    .rd(mem_wb_rd),
    .wd(wb_data),
    .rd1(rd1),
    .rd2(rd2)
);

// 6. Immediate Generator
imm_gen IMM (
    .instr(if_id_instr),
    .imm_sel(imm_sel_dec),
    .imm(imm)
);

// 7. Hazard Detection Unit
hazard_detect HDU (
    .id_ex_mem_read(id_ex_mem_read),
    .id_ex_rd(id_ex_rd),
    .if_id_rs1(if_id_instr[19:15]),
    .if_id_rs2(if_id_instr[24:20]),
    .stall_pc(stall_pc),
    .stall_if_id(stall_if_id),
    .flush_id_ex(flush_id_ex)
);

// Write-during-read bypass in Decode stage (resolves RF RAW hazards without breaking RF testbench)
wire [31:0] bypass_rd1 = (mem_wb_reg_write && (mem_wb_rd != 5'd0) && (mem_wb_rd == if_id_instr[19:15])) ? wb_data : rd1;
wire [31:0] bypass_rd2 = (mem_wb_reg_write && (mem_wb_rd != 5'd0) && (mem_wb_rd == if_id_instr[24:20])) ? wb_data : rd2;

// 8. ID/EX Pipeline Register
ID_EX_reg ID_EX (
    .clk(clk), .rst(rst),
    .flush(flush_id_ex || take_branch),
    .reg_write_in(reg_write_dec),
    .mem_read_in(mem_read_dec),
    .mem_write_in(mem_write_dec),
    .mem_to_reg_in(mem_to_reg_dec),
    .alu_src_in(alu_src_dec),
    .branch_in(branch_dec),
    .jump_in(jump_dec),
    .alu_op_in(alu_op_dec),
    .pc_in(if_id_pc),
    .rd1_in(bypass_rd1),
    .rd2_in(bypass_rd2),
    .imm_in(imm),
    .rs1_in(if_id_instr[19:15]),
    .rs2_in(if_id_instr[24:20]),
    .rd_in(if_id_instr[11:7]),
    .funct3_in(if_id_instr[14:12]),
    .funct7_5_in(if_id_instr[30]),
    .reg_write_out(id_ex_reg_write),
    .mem_read_out(id_ex_mem_read),
    .mem_write_out(id_ex_mem_write),
    .mem_to_reg_out(id_ex_mem_to_reg),
    .alu_src_out(id_ex_alu_src),
    .branch_out(id_ex_branch),
    .jump_out(id_ex_jump),
    .alu_op_out(id_ex_alu_op),
    .pc_out(id_ex_pc),
    .rd1_out(id_ex_rd1),
    .rd2_out(id_ex_rd2),
    .imm_out(id_ex_imm),
    .rs1_out(id_ex_rs1),
    .rs2_out(id_ex_rs2),
    .rd_out(id_ex_rd),
    .funct3_out(id_ex_funct3),
    .funct7_5_out(id_ex_funct7_5)
);

// 9. Forwarding Unit
forwarding_unit FWD (
    .ex_rs1(id_ex_rs1),
    .ex_rs2(id_ex_rs2),
    .mem_rd(ex_mem_rd),
    .mem_reg_write(ex_mem_reg_write),
    .wb_rd(mem_wb_rd),
    .wb_reg_write(mem_wb_reg_write),
    .forward_a(forward_a),
    .forward_b(forward_b)
);

// 10. ALU input muxes with forwarding
assign alu_a = (forward_a == 2'b10) ? ex_mem_alu_result :
               (forward_a == 2'b01) ? wb_data           :
               id_ex_rd1;

assign alu_b_pre = (forward_b == 2'b10) ? ex_mem_alu_result :
                   (forward_b == 2'b01) ? wb_data            :
                   id_ex_rd2;

assign alu_b = id_ex_alu_src ? id_ex_imm : alu_b_pre;

// 11. ALU Control
alu_control ALUCTL (
    .alu_op(id_ex_alu_op),
    .funct3(id_ex_funct3),
    .funct7_5(id_ex_funct7_5),
    .alu_ctrl(alu_ctrl)
);

// 12. ALU
alu ALU (
    .a(alu_a),
    .b(alu_b),
    .alu_ctrl(alu_ctrl),
    .result(alu_result),
    .zero(alu_zero)
);

// 13. Branch Unit
branch_unit BRU (
    .pc(id_ex_pc),
    .imm(id_ex_imm),
    .rs1(alu_a),
    .alu_result(alu_result),
    .zero(alu_zero),
    .branch(id_ex_branch),
    .jump(id_ex_jump),
    .funct3(id_ex_funct3),
    .branch_target(branch_target),
    .take_branch(take_branch)
);

// 14. EX/MEM Pipeline Register
EX_MEM_reg EX_MEM (
    .clk(clk), .rst(rst),
    .flush(1'b0),
    .reg_write_in(id_ex_reg_write),
    .mem_read_in(id_ex_mem_read),
    .mem_write_in(id_ex_mem_write),
    .mem_to_reg_in(id_ex_mem_to_reg),
    .branch_in(id_ex_branch),
    .jump_in(id_ex_jump),
    .alu_result_in(alu_result),
    .rd2_in(alu_b_pre),
    .rd_in(id_ex_rd),
    .zero_in(alu_zero),
    .branch_target_in(branch_target),
    .pc_plus4_in(id_ex_pc + 32'd4),
    .reg_write_out(ex_mem_reg_write),
    .mem_read_out(ex_mem_mem_read),
    .mem_write_out(ex_mem_mem_write),
    .mem_to_reg_out(ex_mem_mem_to_reg),
    .branch_out(ex_mem_branch),
    .jump_out(ex_mem_jump),
    .alu_result_out(ex_mem_alu_result),
    .rd2_out(ex_mem_rd2),
    .rd_out(ex_mem_rd),
    .zero_out(ex_mem_zero),
    .branch_target_out(ex_mem_branch_target),
    .pc_plus4_out(ex_mem_pc_plus4)
);

// 15. Data Memory
data_memory DMEM (
    .clk(clk),
    .mem_read(ex_mem_mem_read),
    .mem_write(ex_mem_mem_write),
    .addr(ex_mem_alu_result),
    .write_data(ex_mem_rd2),
    .read_data(mem_read_data)
);

// 16. MEM/WB Pipeline Register
MEM_WB_reg MEM_WB (
    .clk(clk), .rst(rst),
    .reg_write_in(ex_mem_reg_write),
    .mem_to_reg_in(ex_mem_mem_to_reg),
    .mem_data_in(mem_read_data),
    .alu_result_in(ex_mem_alu_result),
    .rd_in(ex_mem_rd),
    .pc_plus4_in(ex_mem_pc_plus4),
    .reg_write_out(mem_wb_reg_write),
    .mem_to_reg_out(mem_wb_mem_to_reg),
    .mem_data_out(mem_wb_mem_data),
    .alu_result_out(mem_wb_alu_result),
    .rd_out(mem_wb_rd),
    .pc_plus4_out(mem_wb_pc_plus4)
);

// 17. Writeback Mux
assign wb_data = mem_wb_mem_to_reg ? mem_wb_mem_data : mem_wb_alu_result;

endmodule
