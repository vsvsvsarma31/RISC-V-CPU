module instr_memory (
    input  [31:0] addr,       // byte address from PC
    output [31:0] instr       // 32-bit instruction output
);

    // 256 words = 1KB instruction memory
    reg [31:0] mem [0:255];

    // Word-addressed combinational read: ignore bottom 2 bits
    assign instr = mem[addr[9:2]];

    // Initialization block for simulation
    integer i;
    initial begin
        // Fallback: pre-load 8 NOP instructions (ADDI x0, x0, 0 = 32'h00000013)
        for (i = 0; i < 8; i = i + 1) begin
            mem[i] = 32'h00000013;
        end
        // Try reading from hex file if available
        // (will overwrite the NOPs if successful)
        $readmemh("program.hex", mem);
    end

endmodule
