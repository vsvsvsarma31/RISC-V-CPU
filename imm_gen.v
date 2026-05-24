module imm_gen (
    input  [31:0] instr,    // full 32-bit instruction word
    input  [2:0]  imm_sel,  // selects which format to decode
    output reg [31:0] imm   // sign-extended 32-bit immediate output
);

    // Purely combinational always block to extract and sign-extend the immediate
    always @(*) begin
        case (imm_sel)
            // I-type: ADDI, SLTI, LW, JALR
            3'b000: begin
                imm = { {20{instr[31]}}, instr[31:20] };
            end

            // S-type: SW, SH, SB
            3'b001: begin
                imm = { {20{instr[31]}}, instr[31:25], instr[11:7] };
            end

            // B-type: BEQ, BNE, BLT, BGE
            3'b010: begin
                imm = { {19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0 };
            end

            // U-type: LUI, AUIPC
            3'b011: begin
                imm = { instr[31:12], 12'b0 };
            end

            // J-type: JAL
            3'b100: begin
                imm = { {11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0 };
            end

            // I-type shift: SLLI, SRLI, SRAI
            3'b101: begin
                imm = { 27'b0, instr[24:20] };
            end

            // Default case to avoid latches
            default: begin
                imm = 32'b0;
            end
        endcase
    end

endmodule
