module pc_register (
    input         clk,
    input         rst,       // synchronous active-high reset
    input         stall,     // when 1, freeze PC (do not update)
    input  [31:0] pc_next,   // next PC value to load
    output reg [31:0] pc     // current PC value
);

    // Synchronous update on posedge clk
    always @(posedge clk) begin
        if (rst) begin
            pc <= 32'h00000000;
        end else if (stall) begin
            pc <= pc;
        end else begin
            pc <= pc_next;
        end
    end

endmodule
