`timescale 1ns/1ps
module tb_top;

reg clk, rst;
integer i;

top CPU (.clk(clk), .rst(rst));

// Clock: 10ns period
always #5 clk = ~clk;

initial begin
    // Load test program into instruction memory
    // Program tests: ADD, SUB, LW, SW, BEQ, forwarding, hazards
    // ADDI x1, x0, 5    -> x1 = 5       (32'h00500093)
    // ADDI x2, x0, 3    -> x2 = 3       (32'h00300113)
    // ADD  x3, x1, x2   -> x3 = 8       (32'h002081B3)
    // SUB  x4, x1, x2   -> x4 = 2       (32'h40208233)
    // ADDI x5, x0, 10   -> x5 = 10      (32'h00A00293)
    // SW   x5, 0(x0)    -> mem[0]=10     (32'h00502023)
    // LW   x6, 0(x0)    -> x6 = 10      (32'h00002303)
    // BEQ  x1, x1, +8   -> branch taken (32'h00108463)
    // ADDI x7, x0, 99   -> skipped      (32'h06300393)
    // ADDI x8, x0, 42   -> x8 = 42      (32'h02A00413)
    // NOP loop (fill rest with NOPs)

    CPU.IMEM.mem[0]  = 32'h00500093;
    CPU.IMEM.mem[1]  = 32'h00300113;
    CPU.IMEM.mem[2]  = 32'h002081B3;
    CPU.IMEM.mem[3]  = 32'h40208233;
    CPU.IMEM.mem[4]  = 32'h00A00293;
    CPU.IMEM.mem[5]  = 32'h00502023;
    CPU.IMEM.mem[6]  = 32'h00002303;
    CPU.IMEM.mem[7]  = 32'h00108463;
    CPU.IMEM.mem[8]  = 32'h06300393;
    CPU.IMEM.mem[9]  = 32'h02A00413;
    for (i = 10; i < 256; i = i + 1)
        CPU.IMEM.mem[i] = 32'h00000013; // NOP

    // Initialize
    clk = 0; rst = 1;
    #20; rst = 0;

    // Run for 50 cycles — enough for all instructions + pipeline drain
    repeat(50) @(posedge clk);

    // ── CHECK RESULTS ──────────────────────────────
    $display("=== RISC-V Pipeline CPU Test Results ===");

    if (CPU.RF.regs[1] === 32'd5)
        $display("PASS: x1 = 5  (ADDI)");
    else
        $display("FAIL: x1 = %0d (expected 5)", CPU.RF.regs[1]);

    if (CPU.RF.regs[2] === 32'd3)
        $display("PASS: x2 = 3  (ADDI)");
    else
        $display("FAIL: x2 = %0d (expected 3)", CPU.RF.regs[2]);

    if (CPU.RF.regs[3] === 32'd8)
        $display("PASS: x3 = 8  (ADD)");
    else
        $display("FAIL: x3 = %0d (expected 8)", CPU.RF.regs[3]);

    if (CPU.RF.regs[4] === 32'd2)
        $display("PASS: x4 = 2  (SUB)");
    else
        $display("FAIL: x4 = %0d (expected 2)", CPU.RF.regs[4]);

    if (CPU.RF.regs[5] === 32'd10)
        $display("PASS: x5 = 10 (ADDI)");
    else
        $display("FAIL: x5 = %0d (expected 10)", CPU.RF.regs[5]);

    if (CPU.RF.regs[6] === 32'd10)
        $display("PASS: x6 = 10 (LW from mem[0])");
    else
        $display("FAIL: x6 = %0d (expected 10)", CPU.RF.regs[6]);

    if (CPU.RF.regs[7] === 32'd0)
        $display("PASS: x7 = 0  (BEQ skipped ADDI x7,x0,99)");
    else
        $display("FAIL: x7 = %0d (expected 0, branch should skip)", CPU.RF.regs[7]);

    if (CPU.RF.regs[8] === 32'd42)
        $display("PASS: x8 = 42 (ADDI after branch target)");
    else
        $display("FAIL: x8 = %0d (expected 42)", CPU.RF.regs[8]);

    $display("=== Simulation Complete ===");
    $finish;
end

// Optional: waveform dump for GTKWave
initial begin
    $dumpfile("cpu_wave.vcd");
    $dumpvars(0, tb_top);
end

endmodule
