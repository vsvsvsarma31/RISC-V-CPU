module IF_ID_reg (
    input         clk,
    input         rst,
    input         flush,
    input         stall,
    input  [31:0] pc_in,
    input  [31:0] instr_in,
    output reg [31:0] pc_out,
    output reg [31:0] instr_out
);
always @(posedge clk) begin
    if (rst || flush) begin
        pc_out    <= 32'b0;
        instr_out <= 32'h00000013; // NOP
    end else if (stall) begin
        pc_out    <= pc_out;
        instr_out <= instr_out;
    end else begin
        pc_out    <= pc_in;
        instr_out <= instr_in;
    end
end
endmodule
