module register_file (
    input         clk,
    input         we,          // write enable
    input  [4:0]  rs1,         // read port 1 address (5-bit: selects x0-x31)
    input  [4:0]  rs2,         // read port 2 address
    input  [4:0]  rd,          // write port address
    input  [31:0] wd,          // write data
    output [31:0] rd1,         // read data 1 (combinational)
    output [31:0] rd2          // read data 2 (combinational)
);

    // Declare registers as 32 registers of 32-bit width
    reg [31:0] regs [0:31];

    // Combinational read operations (x0 always returns 0)
    assign rd1 = (rs1 == 5'b0) ? 32'b0 : regs[rs1];
    assign rd2 = (rs2 == 5'b0) ? 32'b0 : regs[rs2];

    // Synchronous write operation on positive clock edge
    always @(posedge clk) begin
        if (we && (rd != 5'b0)) begin
            regs[rd] <= wd;
        end
    end

    // Initialize all registers to 0 in an initial block (simulation only)
    integer i;
    initial begin
        for (i = 0; i < 32; i = i + 1) begin
            regs[i] = 32'b0;
        end
    end

endmodule
