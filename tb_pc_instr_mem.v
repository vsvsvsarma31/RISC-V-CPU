`timescale 1ns / 1ps

module tb_pc_instr_mem;

    reg clk;
    reg rst;
    reg stall;
    reg [31:0] pc_next;
    wire [31:0] pc;
    wire [31:0] instr;

    pc_register uut_pc (
        .clk(clk),
        .rst(rst),
        .stall(stall),
        .pc_next(pc_next),
        .pc(pc)
    );

    instr_memory uut_imem (
        .addr(pc),
        .instr(instr)
    );

    always #5 clk = ~clk;

    integer failures = 0;

    initial begin
        clk = 0;
        rst = 1;
        stall = 0;
        pc_next = 32'h00000000;
        
        #12; // Wait after reset edge
        rst = 0;
        
        if (pc === 32'h00000000) begin
            $display("PASS: PC reset value is 0");
        end else begin
            $display("FAIL: PC reset value is not 0 (Got %h)", pc);
            failures = failures + 1;
        end

        // Test PC increment
        pc_next = 32'h00000004;
        @(posedge clk);
        #1;
        if (pc === 32'h00000004) begin
            $display("PASS: PC updated to 4");
        end else begin
            $display("FAIL: PC did not update to 4 (Got %h)", pc);
            failures = failures + 1;
        end

        // Test Stall
        stall = 1;
        pc_next = 32'h00000008;
        @(posedge clk);
        #1;
        if (pc === 32'h00000004) begin
            $display("PASS: PC stalled and held value 4");
        end else begin
            $display("FAIL: PC did not hold value 4 during stall (Got %h)", pc);
            failures = failures + 1;
        end

        // Release Stall
        stall = 0;
        @(posedge clk);
        #1;
        if (pc === 32'h00000008) begin
            $display("PASS: PC updated to 8 after stall released");
        end else begin
            $display("FAIL: PC did not update to 8 after release (Got %h)", pc);
            failures = failures + 1;
        end

        // Test Instruction Memory Async Reads
        // Direct hierarchical force into instruction memory array
        uut_imem.mem[0] = 32'hDEADBEEF;
        uut_imem.mem[1] = 32'hCAFEBABE;

        // Drive PC (or address) directly to 0
        pc_next = 32'h00000000;
        @(posedge clk);
        #1;
        if (instr === 32'hDEADBEEF) begin
            $display("PASS: instr_memory read at addr 0 returned DEADBEEF");
        end else begin
            $display("FAIL: instr_memory read at addr 0 (Got %h, expected DEADBEEF)", instr);
            failures = failures + 1;
        end

        // Drive PC (or address) directly to 4
        pc_next = 32'h00000004;
        @(posedge clk);
        #1;
        if (instr === 32'hCAFEBABE) begin
            $display("PASS: instr_memory read at addr 4 returned CAFEBABE");
        end else begin
            $display("FAIL: instr_memory read at addr 4 (Got %h, expected CAFEBABE)", instr);
            failures = failures + 1;
        end

        $display("--------------------------------------------");
        if (failures === 0) begin
            $display("ALL PC_REGISTER & INSTR_MEMORY TESTS PASSED!");
        end else begin
            $display("SOME TESTS FAILED! Total failures: %d", failures);
        end
        $display("--------------------------------------------");
        $finish;
    end

endmodule
