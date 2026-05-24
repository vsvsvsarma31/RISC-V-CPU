module forwarding_unit (
    // Source registers of current EX stage instruction
    input  [4:0] ex_rs1,       // ID/EX.rs1
    input  [4:0] ex_rs2,       // ID/EX.rs2

    // EX/MEM stage: instruction that just finished EX
    input  [4:0] mem_rd,       // EX/MEM.rd
    input        mem_reg_write, // EX/MEM.reg_write

    // MEM/WB stage: instruction that just finished MEM
    input  [4:0] wb_rd,        // MEM/WB.rd
    input        wb_reg_write,  // MEM/WB.reg_write

    // Forwarding select signals (2-bit each)
    output reg [1:0] forward_a, // selects ALU operand A source
    output reg [1:0] forward_b  // selects ALU operand B source
);

// forward_a / forward_b encoding:
//   2'b00 = no forwarding, use register file output (ID/EX.rd1 or rd2)
//   2'b10 = forward from EX/MEM stage (ALU result)
//   2'b01 = forward from MEM/WB stage (ALU result or memory data)

always @(*) begin
    // Default: no forwarding
    forward_a = 2'b00;
    forward_b = 2'b00;

    // Forward A from EX/MEM (highest priority)
    if (mem_reg_write && (mem_rd != 5'b0) && (mem_rd == ex_rs1))
        forward_a = 2'b10;
    // Forward A from MEM/WB (lower priority)
    else if (wb_reg_write && (wb_rd != 5'b0) && (wb_rd == ex_rs1))
        forward_a = 2'b01;

    // Forward B from EX/MEM (highest priority)
    if (mem_reg_write && (mem_rd != 5'b0) && (mem_rd == ex_rs2))
        forward_b = 2'b10;
    // Forward B from MEM/WB (lower priority)
    else if (wb_reg_write && (wb_rd != 5'b0) && (wb_rd == ex_rs2))
        forward_b = 2'b01;
end

endmodule
