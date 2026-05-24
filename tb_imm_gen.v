`timescale 1ns / 1ps

module tb_imm_gen;

    reg [31:0] instr;
    reg [2:0]  imm_sel;
    wire [31:0] imm;

    imm_gen uut (
        .instr(instr),
        .imm_sel(imm_sel),
        .imm(imm)
    );

    integer failures = 0;

    initial begin
        // 1. I-type: ADDI x0, x0, -1
        instr = 32'hFFF00013;
        imm_sel = 3'b000;
        #10;
        if (imm === 32'hFFFFFFFF) begin
            $display("PASS: I-type ADDI (Expected FFFFFFFF, Got %h)", imm);
        end else begin
            $display("FAIL: I-type ADDI (Expected FFFFFFFF, Got %h)", imm);
            failures = failures + 1;
        end

        // 2. S-type: SW
        instr = 32'hFE102FA3;
        imm_sel = 3'b001;
        #10;
        if (imm === 32'hFFFFFFFF) begin
            $display("PASS: S-type SW (Expected FFFFFFFF, Got %h)", imm);
        end else begin
            $display("FAIL: S-type SW (Expected FFFFFFFF, Got %h)", imm);
            failures = failures + 1;
        end

        // 3. B-type: BEQ with negative offset
        instr = 32'hFE000EE3;
        imm_sel = 3'b010;
        #10;
        if (imm === 32'hFFFFFFFC) begin
            $display("PASS: B-type BEQ (Expected FFFFFFFC, Got %h)", imm);
        end else begin
            $display("FAIL: B-type BEQ (Expected FFFFFFFC, Got %h)", imm);
            failures = failures + 1;
        end

        // 4. U-type: LUI
        instr = 32'h12345637;
        imm_sel = 3'b011;
        #10;
        if (imm === 32'h12345000) begin
            $display("PASS: U-type LUI (Expected 12345000, Got %h)", imm);
        end else begin
            $display("FAIL: U-type LUI (Expected 12345000, Got %h)", imm);
            failures = failures + 1;
        end

        // 5. J-type: JAL
        instr = 32'h008000EF;
        imm_sel = 3'b100;
        #10;
        if (imm === 32'h00000008) begin
            $display("PASS: J-type JAL (Expected 00000008, Got %h)", imm);
        end else begin
            $display("FAIL: J-type JAL (Expected 00000008, Got %h)", imm);
            failures = failures + 1;
        end

        // 6. I-shift: SLLI
        instr = 32'h00409013;
        imm_sel = 3'b101;
        #10;
        if (imm === 32'h00000004) begin
            $display("PASS: I-shift SLLI (Expected 00000004, Got %h)", imm);
        end else begin
            $display("FAIL: I-shift SLLI (Expected 00000004, Got %h)", imm);
            failures = failures + 1;
        end

        $display("--------------------------------------------");
        if (failures === 0) begin
            $display("ALL IMM_GEN TESTS PASSED!");
        end else begin
            $display("SOME IMM_GEN TESTS FAILED! Total failures: %d", failures);
        end
        $display("--------------------------------------------");
        $finish;
    end

endmodule
