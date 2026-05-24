module alu (
    input  [31:0] a,          // operand A
    input  [31:0] b,          // operand B
    input  [3:0]  alu_ctrl,   // operation selector
    output reg [31:0] result, // ALU result
    output             zero   // 1 if result == 0
);

    // Purely combinational always block to compute ALU result
    always @(*) begin
        case (alu_ctrl)
            // ADD (a + b)
            4'b0000: result = a + b;
            
            // SUB (a - b)
            4'b0001: result = a - b;
            
            // AND (a & b)
            4'b0010: result = a & b;
            
            // OR (a | b)
            4'b0011: result = a | b;
            
            // XOR (a ^ b)
            4'b0100: result = a ^ b;
            
            // SLT (signed less than: $signed(a) < $signed(b))
            4'b0101: result = ($signed(a) < $signed(b)) ? 32'd1 : 32'd0;
            
            // SLTU (unsigned less than)
            4'b0110: result = (a < b) ? 32'd1 : 32'd0;
            
            // SLL (a << b[4:0])
            4'b0111: result = a << b[4:0];
            
            // SRL (a >> b[4:0])
            4'b1000: result = a >> b[4:0];
            
            // SRA (arithmetic right shift: $signed(a) >>> b[4:0])
            4'b1001: result = $signed(a) >>> b[4:0];
            
            // LUI (pass b directly, used for LUI instruction)
            4'b1010: result = b;
            
            // Default case to avoid latches
            default: result = 32'b0;
        endcase
    end

    // Zero flag output
    assign zero = (result == 32'b0);

endmodule
