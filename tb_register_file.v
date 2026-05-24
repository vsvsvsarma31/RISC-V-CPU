`timescale 1ns / 1ps

module tb_register_file;

    // Inputs
    reg clk;
    reg we;
    reg [4:0] rs1;
    reg [4:0] rs2;
    reg [4:0] rd;
    reg [31:0] wd;

    // Outputs
    wire [31:0] rd1;
    wire [31:0] rd2;

    // Instantiate the Unit Under Test (UUT)
    register_file uut (
        .clk(clk),
        .we(we),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .wd(wd),
        .rd1(rd1),
        .rd2(rd2)
    );

    // Clock generator (10 ns period)
    always #5 clk = ~clk;

    // Failure counter
    integer failures = 0;

    initial begin
        // Initialize Inputs
        clk = 0;
        we = 0;
        rs1 = 0;
        rs2 = 0;
        rd = 0;
        wd = 0;

        // Wait for 100 ns global reset
        #100;

        // ==========================================
        // Test 1: x0 always reads 0 even after attempting a write to it
        // ==========================================
        $display("--- Running Test 1: x0 Write and Read Check ---");
        // Attempt write to x0
        rd = 5'd0;
        wd = 32'hFFFFFFFF;
        we = 1'b1;
        @(posedge clk);
        #1; // Wait for write and combinational propagation
        
        // Try reading x0 on both ports
        rs1 = 5'd0;
        rs2 = 5'd0;
        #1;
        if (rd1 === 32'h0 && rd2 === 32'h0) begin
            $display("PASS: x0 remained 0 after write attempt.");
        end else begin
            $display("FAIL: x0 did not remain 0 (rd1 = %h, rd2 = %h)", rd1, rd2);
            failures = failures + 1;
        end


        // ==========================================
        // Test 2: Write a value to x5, then read it back on rs1 and rs2 simultaneously
        // ==========================================
        $display("--- Running Test 2: x5 Write and Dual Read Check ---");
        rd = 5'd5;
        wd = 32'hA5A5A5A5;
        we = 1'b1;
        @(posedge clk);
        #1;

        // Read from rs1 and rs2 simultaneously
        rs1 = 5'd5;
        rs2 = 5'd5;
        #1;
        if (rd1 === 32'hA5A5A5A5 && rd2 === 32'hA5A5A5A5) begin
            $display("PASS: Successfully wrote to x5 and read back on both ports simultaneously.");
        end else begin
            $display("FAIL: Failed x5 readback (rd1 = %h, rd2 = %h)", rd1, rd2);
            failures = failures + 1;
        end


        // ==========================================
        // Test 3: Write enable check (attempt write with we = 0, confirm unchanged)
        // ==========================================
        $display("--- Running Test 3: Write Enable (we = 0) Check ---");
        // Attempt write to x5 with we = 0
        rd = 5'd5;
        wd = 32'h5A5A5A5A;
        we = 1'b0;
        @(posedge clk);
        #1;

        // Read again
        rs1 = 5'd5;
        #1;
        if (rd1 === 32'hA5A5A5A5) begin
            $display("PASS: Write enable we=0 prevented overwriting x5.");
        end else begin
            $display("FAIL: Register x5 was overwritten when we=0 (rd1 = %h)", rd1);
            failures = failures + 1;
        end


        // ==========================================
        // Test 4: Write to x31 (boundary register)
        // ==========================================
        $display("--- Running Test 4: Boundary Register x31 Check ---");
        rd = 5'd31;
        wd = 32'h12345678;
        we = 1'b1;
        @(posedge clk);
        #1;

        // Read back from x31
        rs1 = 5'd31;
        #1;
        if (rd1 === 32'h12345678) begin
            $display("PASS: Successfully wrote and read boundary register x31.");
        end else begin
            $display("FAIL: Boundary register x31 check failed (rd1 = %h)", rd1);
            failures = failures + 1;
        end


        // ==========================================
        // Test 5: Read-After-Write (RAW) combinational read sees updated value immediately
        // ==========================================
        $display("--- Running Test 5: Simultaneous Write and Read Check ---");
        // Set up read address to match write address
        rs1 = 5'd10;
        rd = 5'd10;
        wd = 32'hCAFEF00D;
        we = 1'b1;
        
        // Before the clock edge, rd1 should be 0
        #1;
        if (rd1 !== 32'h0) begin
            $display("FAIL: Pre-clock read is not 0 (rd1 = %h)", rd1);
            failures = failures + 1;
        end

        // Trigger the clock edge
        @(posedge clk);
        // Combinational read should see the new value immediately after the positive edge
        #1;
        if (rd1 === 32'hCAFEF00D) begin
            $display("PASS: Combinational read sees the updated value immediately after clock edge.");
        end else begin
            $display("FAIL: Combinational read failed to see updated value (rd1 = %h)", rd1);
            failures = failures + 1;
        end


        // ==========================================
        // Summary & Finish
        // ==========================================
        $display("--------------------------------------------");
        if (failures === 0) begin
            $display("ALL REGISTER FILE TESTS PASSED!");
        end else begin
            $display("SOME REGISTER FILE TESTS FAILED! Total failures: %d", failures);
        end
        $display("--------------------------------------------");

        $finish;
    end

endmodule
