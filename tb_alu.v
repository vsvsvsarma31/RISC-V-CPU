`timescale 1ns / 1ps

module tb_alu;

    // Inputs
    reg [31:0] a;
    reg [31:0] b;
    reg [3:0] alu_ctrl;

    // Outputs
    wire [31:0] result;
    wire zero;

    // Instantiate the Unit Under Test (UUT)
    alu uut (
        .a(a),
        .b(b),
        .alu_ctrl(alu_ctrl),
        .result(result),
        .zero(zero)
    );

    // Helper variable for counting test failures
    integer failures = 0;

    initial begin
        // Initialize Inputs
        a = 0;
        b = 0;
        alu_ctrl = 0;

        // Wait 100 ns for global reset
        #100;

        // ==========================================
        // 1. ADD (alu_ctrl = 4'b0000)
        // ==========================================
        alu_ctrl = 4'b0000;
        
        // Test Vector 1: 5 + 10 = 15
        a = 32'd5; b = 32'd10; #10;
        if (result === 32'd15 && zero === 1'b0) begin
            $display("PASS: ADD Vector 1 (5 + 10 = 15, zero = 0)");
        end else begin
            $display("FAIL: ADD Vector 1 (5 + 10 = 15, got %d, zero = %b)", result, zero);
            failures = failures + 1;
        end

        // Test Vector 2: -5 + 5 = 0
        a = -32'd5; b = 32'd5; #10;
        if (result === 32'd0 && zero === 1'b1) begin
            $display("PASS: ADD Vector 2 (-5 + 5 = 0, zero = 1)");
        end else begin
            $display("FAIL: ADD Vector 2 (-5 + 5 = 0, got %d, zero = %b)", result, zero);
            failures = failures + 1;
        end


        // ==========================================
        // 2. SUB (alu_ctrl = 4'b0001)
        // ==========================================
        alu_ctrl = 4'b0001;

        // Test Vector 1: 20 - 8 = 12
        a = 32'd20; b = 32'd8; #10;
        if (result === 32'd12 && zero === 1'b0) begin
            $display("PASS: SUB Vector 1 (20 - 8 = 12, zero = 0)");
        end else begin
            $display("FAIL: SUB Vector 1 (20 - 8 = 12, got %d, zero = %b)", result, zero);
            failures = failures + 1;
        end

        // Test Vector 2: 15 - 15 = 0 (Check zero flag explicitly for SUB where a==b)
        a = 32'd15; b = 32'd15; #10;
        if (result === 32'd0 && zero === 1'b1) begin
            $display("PASS: SUB Vector 2 (15 - 15 = 0, zero = 1) [Explicit Zero Check]");
        end else begin
            $display("FAIL: SUB Vector 2 (15 - 15 = 0, got %d, zero = %b) [Explicit Zero Check]", result, zero);
            failures = failures + 1;
        end


        // ==========================================
        // 3. AND (alu_ctrl = 4'b0010)
        // ==========================================
        alu_ctrl = 4'b0010;

        // Test Vector 1: 32'hFFFF0000 & 32'h00FFFF00 = 32'h00FF0000
        a = 32'hFFFF0000; b = 32'h00FFFF00; #10;
        if (result === 32'h00FF0000 && zero === 1'b0) begin
            $display("PASS: AND Vector 1 (FFFF0000 & 00FFFF00 = 00FF0000)");
        end else begin
            $display("FAIL: AND Vector 1, got %h", result);
            failures = failures + 1;
        end

        // Test Vector 2: 32'h55555555 & 32'hAAAAAAAA = 32'h00000000
        a = 32'h55555555; b = 32'hAAAAAAAA; #10;
        if (result === 32'h00000000 && zero === 1'b1) begin
            $display("PASS: AND Vector 2 (55555555 & AAAAAAAA = 00000000, zero = 1)");
        end else begin
            $display("FAIL: AND Vector 2, got %h, zero = %b", result, zero);
            failures = failures + 1;
        end


        // ==========================================
        // 4. OR (alu_ctrl = 4'b0011)
        // ==========================================
        alu_ctrl = 4'b0011;

        // Test Vector 1: 32'hF0F0F0F0 | 32'h0F0F0F0F = 32'hFFFFFFFF
        a = 32'hF0F0F0F0; b = 32'h0F0F0F0F; #10;
        if (result === 32'hFFFFFFFF && zero === 1'b0) begin
            $display("PASS: OR Vector 1 (F0F0F0F0 | 0F0F0F0F = FFFFFFFF)");
        end else begin
            $display("FAIL: OR Vector 1, got %h", result);
            failures = failures + 1;
        end

        // Test Vector 2: 32'h00000000 | 32'h00000000 = 32'h00000000
        a = 32'h00000000; b = 32'h00000000; #10;
        if (result === 32'h00000000 && zero === 1'b1) begin
            $display("PASS: OR Vector 2 (0 | 0 = 0, zero = 1)");
        end else begin
            $display("FAIL: OR Vector 2, got %h", result);
            failures = failures + 1;
        end


        // ==========================================
        // 5. XOR (alu_ctrl = 4'b0100)
        // ==========================================
        alu_ctrl = 4'b0100;

        // Test Vector 1: 32'hFFFFFFFF ^ 32'hF0F0F0F0 = 32'h0F0F0F0F
        a = 32'hFFFFFFFF; b = 32'hF0F0F0F0; #10;
        if (result === 32'h0F0F0F0F && zero === 1'b0) begin
            $display("PASS: XOR Vector 1 (FFFFFFFF ^ F0F0F0F0 = 0F0F0F0F)");
        end else begin
            $display("FAIL: XOR Vector 1, got %h", result);
            failures = failures + 1;
        end

        // Test Vector 2: 32'h12345678 ^ 32'h12345678 = 32'h00000000
        a = 32'h12345678; b = 32'h12345678; #10;
        if (result === 32'h00000000 && zero === 1'b1) begin
            $display("PASS: XOR Vector 2 (12345678 ^ 12345678 = 0, zero = 1)");
        end else begin
            $display("FAIL: XOR Vector 2, got %h", result);
            failures = failures + 1;
        end


        // ==========================================
        // 6. SLT (alu_ctrl = 4'b0101)
        // ==========================================
        alu_ctrl = 4'b0101;

        // Test Vector 1: -5 < 3 (True -> 1)
        a = -32'd5; b = 32'd3; #10;
        if (result === 32'd1 && zero === 1'b0) begin
            $display("PASS: SLT Vector 1 (-5 < 3 = 1)");
        end else begin
            $display("FAIL: SLT Vector 1 (-5 < 3, got %d)", result);
            failures = failures + 1;
        end

        // Test Vector 2: 3 < -5 (False -> 0)
        a = 32'd3; b = -32'd5; #10;
        if (result === 32'd0 && zero === 1'b1) begin
            $display("PASS: SLT Vector 2 (3 < -5 = 0, zero = 1)");
        end else begin
            $display("FAIL: SLT Vector 2 (3 < -5, got %d)", result);
            failures = failures + 1;
        end


        // ==========================================
        // 7. SLTU (alu_ctrl = 4'b0110)
        // ==========================================
        alu_ctrl = 4'b0110;

        // Test Vector 1: 3 < -5 (Unsigned: 3 < 4294967291 -> True -> 1)
        a = 32'd3; b = -32'd5; #10;
        if (result === 32'd1 && zero === 1'b0) begin
            $display("PASS: SLTU Vector 1 (3 < -5 unsigned = 1)");
        end else begin
            $display("FAIL: SLTU Vector 1 (3 < -5 unsigned, got %d)", result);
            failures = failures + 1;
        end

        // Test Vector 2: -5 < 3 (Unsigned: 4294967291 < 3 -> False -> 0)
        a = -32'd5; b = 32'd3; #10;
        if (result === 32'd0 && zero === 1'b1) begin
            $display("PASS: SLTU Vector 2 (-5 < 3 unsigned = 0, zero = 1)");
        end else begin
            $display("FAIL: SLTU Vector 2 (-5 < 3 unsigned, got %d)", result);
            failures = failures + 1;
        end


        // ==========================================
        // 8. SLL (alu_ctrl = 4'b0111)
        // ==========================================
        alu_ctrl = 4'b0111;

        // Test Vector 1: 32'h00000001 << 4 = 32'h00000010
        a = 32'h00000001; b = 32'd4; #10;
        if (result === 32'h00000010 && zero === 1'b0) begin
            $display("PASS: SLL Vector 1 (1 << 4 = 16)");
        end else begin
            $display("FAIL: SLL Vector 1, got %h", result);
            failures = failures + 1;
        end

        // Test Vector 2: 32'hFFFFFFFF << 32 -> should shift by 32 & 5'b11111 = 0 -> 32'hFFFFFFFF
        a = 32'hFFFFFFFF; b = 32'd32; #10;
        if (result === 32'hFFFFFFFF && zero === 1'b0) begin
            $display("PASS: SLL Vector 2 (FFFFFFFF << 32 = FFFFFFFF)");
        end else begin
            $display("FAIL: SLL Vector 2, got %h", result);
            failures = failures + 1;
        end


        // ==========================================
        // 9. SRL (alu_ctrl = 4'b1000)
        // ==========================================
        alu_ctrl = 4'b1000;

        // Test Vector 1: 32'h80000000 >> 4 = 32'h08000000
        a = 32'h80000000; b = 32'd4; #10;
        if (result === 32'h08000000 && zero === 1'b0) begin
            $display("PASS: SRL Vector 1 (80000000 >> 4 = 08000000)");
        end else begin
            $display("FAIL: SRL Vector 1, got %h", result);
            failures = failures + 1;
        end

        // Test Vector 2: 32'h0000000F >> 4 = 32'h00000000
        a = 32'h0000000F; b = 32'd4; #10;
        if (result === 32'h00000000 && zero === 1'b1) begin
            $display("PASS: SRL Vector 2 (F >> 4 = 0, zero = 1)");
        end else begin
            $display("FAIL: SRL Vector 2, got %h", result);
            failures = failures + 1;
        end


        // ==========================================
        // 10. SRA (alu_ctrl = 4'b1001)
        // ==========================================
        alu_ctrl = 4'b1001;

        // Test Vector 1: 32'h80000000 >>> 4 = 32'hF8000000
        a = 32'h80000000; b = 32'd4; #10;
        if (result === 32'hF8000000 && zero === 1'b0) begin
            $display("PASS: SRA Vector 1 (80000000 >>> 4 = F8000000)");
        end else begin
            $display("FAIL: SRA Vector 1, got %h", result);
            failures = failures + 1;
        end

        // Test Vector 2: 32'h70000000 >>> 4 = 32'h07000000
        a = 32'h70000000; b = 32'd4; #10;
        if (result === 32'h07000000 && zero === 1'b0) begin
            $display("PASS: SRA Vector 2 (70000000 >>> 4 = 07000000)");
        end else begin
            $display("FAIL: SRA Vector 2, got %h", result);
            failures = failures + 1;
        end


        // ==========================================
        // 11. LUI (alu_ctrl = 4'b1010)
        // ==========================================
        alu_ctrl = 4'b1010;

        // Test Vector 1: LUI with b = 32'h12345000 -> 32'h12345000
        a = 32'hDEADC0DE; b = 32'h12345000; #10;
        if (result === 32'h12345000 && zero === 1'b0) begin
            $display("PASS: LUI Vector 1 (pass 12345000)");
        end else begin
            $display("FAIL: LUI Vector 1, got %h", result);
            failures = failures + 1;
        end

        // Test Vector 2: LUI with b = 32'h00000000 -> 32'h00000000
        a = 32'hFFFFFFFF; b = 32'h00000000; #10;
        if (result === 32'h00000000 && zero === 1'b1) begin
            $display("PASS: LUI Vector 2 (pass 00000000, zero = 1)");
        end else begin
            $display("FAIL: LUI Vector 2, got %h", result);
            failures = failures + 1;
        end


        // ==========================================
        // Summary & Exit
        // ==========================================
        if (failures === 0) begin
            $display("ALL TESTS PASSED SUCCESSFULLY!");
        end else begin
            $display("SOME TESTS FAILED! Total failures: %d", failures);
        end

        $finish;
    end

endmodule
