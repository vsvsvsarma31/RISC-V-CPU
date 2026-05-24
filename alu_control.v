module alu_control (
    input  [1:0]  alu_op,     // from decoder
    input  [2:0]  funct3,     // instr[14:12]
    input         funct7_5,   // instr[30] — distinguishes SUB from ADD, SRA from SRL
    output reg [3:0] alu_ctrl // to alu.v
);

    always @(*) begin
        case (alu_op)
            2'b00: alu_ctrl = 4'b0000; // ADD
            2'b01: alu_ctrl = 4'b0001; // SUB
            2'b11: alu_ctrl = 4'b1010; // LUI
            2'b10: begin
                case (funct3)
                    3'b000: alu_ctrl = funct7_5 ? 4'b0001 : 4'b0000; // SUB : ADD
                    3'b001: alu_ctrl = 4'b0111; // SLL
                    3'b010: alu_ctrl = 4'b0101; // SLT
                    3'b011: alu_ctrl = 4'b0110; // SLTU
                    3'b100: alu_ctrl = 4'b0100; // XOR
                    3'b101: alu_ctrl = funct7_5 ? 4'b1001 : 4'b1000; // SRA : SRL
                    3'b110: alu_ctrl = 4'b0011; // OR
                    3'b111: alu_ctrl = 4'b0010; // AND
                    default: alu_ctrl = 4'b0000;
                endcase
            end
            default: alu_ctrl = 4'b0000;
        endcase
    end

endmodule
