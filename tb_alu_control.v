`timescale 1ns / 1ps

module tb_alu_control;

    reg [1:0]  alu_op;
    reg [2:0]  funct3;
    reg        funct7_5;
    wire [3:0] alu_ctrl;

    alu_control uut (
        .alu_op(alu_op),
        .funct3(funct3),
        .funct7_5(funct7_5),
        .alu_ctrl(alu_ctrl)
    );

    integer failures = 0;

    task check_alu_ctrl(
        input [3:0] expected_alu_ctrl,
        input [39:0] op_name
    );
        begin
            #1;
            if (alu_ctrl !== expected_alu_ctrl) begin
                $display("FAIL: %s | Expected alu_ctrl = %b, Got = %b", op_name, expected_alu_ctrl, alu_ctrl);
                failures = failures + 1;
            end else begin
                $display("PASS: %s | alu_ctrl = %b", op_name, alu_ctrl);
            end
        end
    endtask

    initial begin
        funct3 = 3'b000;
        funct7_5 = 1'b0;

        // Test fixed cases
        $display("--- Testing Fixed Cases ---");
        
        // alu_op = 00 (Load/Store/JAL -> ADD)
        alu_op = 2'b00;
        check_alu_ctrl(4'b0000, "alu_op=00 (ADD)");

        // alu_op = 01 (Branch -> SUB)
        alu_op = 2'b01;
        check_alu_ctrl(4'b0001, "alu_op=01 (SUB)");

        // alu_op = 11 (LUI -> LUI passthrough)
        alu_op = 2'b11;
        check_alu_ctrl(4'b1010, "alu_op=11 (LUI)");

        // Test alu_op = 10 cases (R-type or I-arith)
        $display("--- Testing alu_op=10 (R-type/I-arith) Cases ---");
        alu_op = 2'b10;

        // ADD (funct3=000, funct7_5=0)
        funct3 = 3'b000; funct7_5 = 1'b0;
        check_alu_ctrl(4'b0000, "ADD");

        // SUB (funct3=000, funct7_5=1)
        funct3 = 3'b000; funct7_5 = 1'b1;
        check_alu_ctrl(4'b0001, "SUB");

        // SLL (funct3=001)
        funct3 = 3'b001; funct7_5 = 1'b0;
        check_alu_ctrl(4'b0111, "SLL");

        // SLT (funct3=010)
        funct3 = 3'b010; funct7_5 = 1'b0;
        check_alu_ctrl(4'b0101, "SLT");

        // SLTU (funct3=011)
        funct3 = 3'b011; funct7_5 = 1'b0;
        check_alu_ctrl(4'b0110, "SLTU");

        // XOR (funct3=100)
        funct3 = 3'b100; funct7_5 = 1'b0;
        check_alu_ctrl(4'b0100, "XOR");

        // SRL (funct3=101, funct7_5=0)
        funct3 = 3'b101; funct7_5 = 1'b0;
        check_alu_ctrl(4'b1000, "SRL");

        // SRA (funct3=101, funct7_5=1)
        funct3 = 3'b101; funct7_5 = 1'b1;
        check_alu_ctrl(4'b1001, "SRA");

        // OR (funct3=110)
        funct3 = 3'b110; funct7_5 = 1'b0;
        check_alu_ctrl(4'b0011, "OR");

        // AND (funct3=111)
        funct3 = 3'b111; funct7_5 = 1'b0;
        check_alu_ctrl(4'b0010, "AND");

        $display("--------------------------------------------");
        if (failures === 0) begin
            $display("ALL ALU_CONTROL TESTS PASSED!");
        end else begin
            $display("SOME ALU_CONTROL TESTS FAILED! Total failures: %d", failures);
        end
        $display("--------------------------------------------");
        $finish;
    end

endmodule
