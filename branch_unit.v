module branch_unit (
    input  [31:0] pc,
    input  [31:0] imm,
    input  [31:0] rs1,
    input  [31:0] alu_result,
    input         zero,
    input         branch,
    input         jump,
    input  [2:0]  funct3,
    output reg [31:0] branch_target,
    output reg        take_branch
);
    // Derive rs2 from rs1 and alu_result (since alu_result = rs1 - rs2)
    wire [31:0] rs2 = rs1 - alu_result;

always @(*) begin
    // Branch target computation
    if (jump && funct3 == 3'b000)
        branch_target = (rs1 + imm) & 32'hFFFFFFFE; // JALR
    else
        branch_target = pc + imm; // JAL and B-type

    // Branch decision
    if (jump) begin
        take_branch = 1'b1;
    end else if (branch) begin
        case (funct3)
            3'b000: take_branch = zero;                         // BEQ
            3'b001: take_branch = ~zero;                        // BNE
            3'b100: take_branch = ($signed(rs1) < $signed(rs2)); // BLT
            3'b101: take_branch = ($signed(rs1) >= $signed(rs2)); // BGE
            3'b110: take_branch = (rs1 < rs2);                  // BLTU
            3'b111: take_branch = (rs1 >= rs2);                 // BGEU
            default: take_branch = 1'b0;
        endcase
    end else begin
        take_branch = 1'b0;
    end
end
endmodule
