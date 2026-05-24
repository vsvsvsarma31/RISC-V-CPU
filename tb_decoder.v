`timescale 1ns / 1ps

module tb_decoder;

    reg [6:0] opcode;
    reg [2:0] funct3;
    reg [6:0] funct7;

    wire reg_write;
    wire mem_read;
    wire mem_write;
    wire mem_to_reg;
    wire alu_src;
    wire branch;
    wire jump;
    wire [2:0] imm_sel;
    wire [1:0] alu_op;

    decoder uut (
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),
        .reg_write(reg_write),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .mem_to_reg(mem_to_reg),
        .alu_src(alu_src),
        .branch(branch),
        .jump(jump),
        .imm_sel(imm_sel),
        .alu_op(alu_op)
    );

    integer failures = 0;

    // A helper task to verify all signals
    task check_outputs(
        input [6:0] op_name,
        input expected_reg_write,
        input expected_mem_read,
        input expected_mem_write,
        input expected_mem_to_reg,
        input expected_alu_src,
        input expected_branch,
        input expected_jump,
        input [2:0] expected_imm_sel,
        input [1:0] expected_alu_op
    );
        begin
            #1;
            if (reg_write !== expected_reg_write ||
                mem_read !== expected_mem_read ||
                mem_write !== expected_mem_write ||
                mem_to_reg !== expected_mem_to_reg ||
                alu_src !== expected_alu_src ||
                branch !== expected_branch ||
                jump !== expected_jump ||
                imm_sel !== expected_imm_sel ||
                alu_op !== expected_alu_op) begin
                
                $display("FAIL: Opcode %b mismatch!", opcode);
                $display("  Expected: reg_w=%b, mem_r=%b, mem_w=%b, mem_to_reg=%b, alu_src=%b, branch=%b, jump=%b, imm_sel=%b, alu_op=%b",
                         expected_reg_write, expected_mem_read, expected_mem_write, expected_mem_to_reg, expected_alu_src, expected_branch, expected_jump, expected_imm_sel, expected_alu_op);
                $display("  Got:      reg_w=%b, mem_r=%b, mem_w=%b, mem_to_reg=%b, alu_src=%b, branch=%b, jump=%b, imm_sel=%b, alu_op=%b",
                         reg_write, mem_read, mem_write, mem_to_reg, alu_src, branch, jump, imm_sel, alu_op);
                failures = failures + 1;
            end else begin
                $display("PASS: Opcode %b matches expected controls", opcode);
            end
        end
    endtask

    initial begin
        funct3 = 3'b000;
        funct7 = 7'b0000000;

        // 1. R_TYPE (ADD, SUB, etc.)
        opcode = 7'b0110011;
        check_outputs("R_TYPE", 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 3'b000, 2'b10);

        // 2. I_ARITH (ADDI, SLTI, etc.)
        opcode = 7'b0010011;
        check_outputs("I_ARITH", 1'b1, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 3'b000, 2'b10);

        // 3. I_LOAD (LW)
        opcode = 7'b0000011;
        check_outputs("I_LOAD", 1'b1, 1'b1, 1'b0, 1'b1, 1'b1, 1'b0, 1'b0, 3'b000, 2'b00);

        // 4. S_TYPE (SW)
        opcode = 7'b0100011;
        check_outputs("S_TYPE", 1'b0, 1'b0, 1'b1, 1'b0, 1'b1, 1'b0, 1'b0, 3'b001, 2'b00);

        // 5. B_TYPE (BEQ)
        opcode = 7'b1100011;
        check_outputs("B_TYPE", 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 3'b010, 2'b01);

        // 6. U_LUI
        opcode = 7'b0110111;
        check_outputs("U_LUI", 1'b1, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 3'b011, 2'b11);

        // 7. U_AUIPC
        opcode = 7'b0010111;
        check_outputs("U_AUIPC", 1'b1, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 3'b011, 2'b11);

        // 8. J_JAL
        opcode = 7'b1101111;
        check_outputs("J_JAL", 1'b1, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 1'b1, 3'b100, 2'b00);

        // 9. J_JALR
        opcode = 7'b1100111;
        check_outputs("J_JALR", 1'b1, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 1'b1, 3'b000, 2'b00);

        $display("--------------------------------------------");
        if (failures === 0) begin
            $display("ALL DECODER TESTS PASSED!");
        end else begin
            $display("SOME DECODER TESTS FAILED! Total failures: %d", failures);
        end
        $display("--------------------------------------------");
        $finish;
    end

endmodule
