module hazard_detect (
    // ID/EX stage: the instruction currently in Execute
    input        id_ex_mem_read, // is EX instruction a LOAD?
    input  [4:0] id_ex_rd,       // destination register of EX instruction

    // IF/ID stage: the instruction currently in Decode
    input  [4:0] if_id_rs1,      // source reg 1 of ID instruction
    input  [4:0] if_id_rs2,      // source reg 2 of ID instruction

    // Stall control outputs
    output reg   stall_pc,       // 1 = freeze PC
    output reg   stall_if_id,    // 1 = freeze IF/ID register
    output reg   flush_id_ex     // 1 = insert bubble into ID/EX (NOP)
);

// Load-use hazard condition:
// If EX stage is a LOAD AND its destination matches
// either source of the ID stage instruction -> STALL

always @(*) begin
    if (id_ex_mem_read &&
        (id_ex_rd != 5'b0) &&
        ((id_ex_rd == if_id_rs1) || (id_ex_rd == if_id_rs2)))
    begin
        stall_pc    = 1'b1;  // freeze PC
        stall_if_id = 1'b1;  // freeze IF/ID
        flush_id_ex = 1'b1;  // insert bubble
    end else begin
        stall_pc    = 1'b0;
        stall_if_id = 1'b0;
        flush_id_ex = 1'b0;
    end
end

endmodule
