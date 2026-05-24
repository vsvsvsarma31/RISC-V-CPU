module decoder (
    input  [6:0]  opcode,     // instr[6:0]
    input  [2:0]  funct3,     // instr[14:12]
    input  [6:0]  funct7,     // instr[31:25]

    output reg        reg_write,   // 1 = write result to register file
    output reg        mem_read,    // 1 = load from data memory
    output reg        mem_write,   // 1 = store to data memory
    output reg        mem_to_reg,  // 1 = writeback from memory, 0 = from ALU
    output reg        alu_src,     // 1 = ALU B input from immediate, 0 = from rs2
    output reg        branch,      // 1 = this is a branch instruction
    output reg        jump,        // 1 = this is JAL/JALR
    output reg [2:0]  imm_sel,     // immediate format selector → feeds imm_gen
    output reg [1:0]  alu_op       // 2-bit code → feeds alu_control
);

    parameter R_TYPE  = 7'b0110011; // ADD,SUB,AND,OR,XOR,SLT,SLTU,SLL,SRL,SRA
    parameter I_ARITH = 7'b0010011; // ADDI,SLTI,ANDI,ORI,XORI,SLLI,SRLI,SRAI
    parameter I_LOAD  = 7'b0000011; // LW, LH, LB
    parameter S_TYPE  = 7'b0100011; // SW, SH, SB
    parameter B_TYPE  = 7'b1100011; // BEQ, BNE, BLT, BGE
    parameter U_LUI   = 7'b0110111; // LUI
    parameter U_AUIPC = 7'b0010111; // AUIPC
    parameter J_JAL   = 7'b1101111; // JAL
    parameter J_JALR  = 7'b1100111; // JALR

    always @(*) begin
        case (opcode)
            R_TYPE: begin
                reg_write  = 1'b1;
                mem_read   = 1'b0;
                mem_write  = 1'b0;
                mem_to_reg = 1'b0;
                alu_src    = 1'b0;
                branch     = 1'b0;
                jump       = 1'b0;
                imm_sel    = 3'b000;
                alu_op     = 2'b10;
            end
            I_ARITH: begin
                reg_write  = 1'b1;
                mem_read   = 1'b0;
                mem_write  = 1'b0;
                mem_to_reg = 1'b0;
                alu_src    = 1'b1;
                branch     = 1'b0;
                jump       = 1'b0;
                imm_sel    = 3'b000;
                alu_op     = 2'b10;
            end
            I_LOAD: begin
                reg_write  = 1'b1;
                mem_read   = 1'b1;
                mem_write  = 1'b0;
                mem_to_reg = 1'b1;
                alu_src    = 1'b1;
                branch     = 1'b0;
                jump       = 1'b0;
                imm_sel    = 3'b000;
                alu_op     = 2'b00;
            end
            S_TYPE: begin
                reg_write  = 1'b0;
                mem_read   = 1'b0;
                mem_write  = 1'b1;
                mem_to_reg = 1'b0;
                alu_src    = 1'b1;
                branch     = 1'b0;
                jump       = 1'b0;
                imm_sel    = 3'b001;
                alu_op     = 2'b00;
            end
            B_TYPE: begin
                reg_write  = 1'b0;
                mem_read   = 1'b0;
                mem_write  = 1'b0;
                mem_to_reg = 1'b0;
                alu_src    = 1'b0;
                branch     = 1'b1;
                jump       = 1'b0;
                imm_sel    = 3'b010;
                alu_op     = 2'b01;
            end
            U_LUI: begin
                reg_write  = 1'b1;
                mem_read   = 1'b0;
                mem_write  = 1'b0;
                mem_to_reg = 1'b0;
                alu_src    = 1'b1;
                branch     = 1'b0;
                jump       = 1'b0;
                imm_sel    = 3'b011;
                alu_op     = 2'b11;
            end
            U_AUIPC: begin
                reg_write  = 1'b1;
                mem_read   = 1'b0;
                mem_write  = 1'b0;
                mem_to_reg = 1'b0;
                alu_src    = 1'b1;
                branch     = 1'b0;
                jump       = 1'b0;
                imm_sel    = 3'b011;
                alu_op     = 2'b11;
            end
            J_JAL: begin
                reg_write  = 1'b1;
                mem_read   = 1'b0;
                mem_write  = 1'b0;
                mem_to_reg = 1'b0;
                alu_src    = 1'b1;
                branch     = 1'b0;
                jump       = 1'b1;
                imm_sel    = 3'b100;
                alu_op     = 2'b00;
            end
            J_JALR: begin
                reg_write  = 1'b1;
                mem_read   = 1'b0;
                mem_write  = 1'b0;
                mem_to_reg = 1'b0;
                alu_src    = 1'b1;
                branch     = 1'b0;
                jump       = 1'b1;
                imm_sel    = 3'b000;
                alu_op     = 2'b00;
            end
            default: begin
                reg_write  = 1'b0;
                mem_read   = 1'b0;
                mem_write  = 1'b0;
                mem_to_reg = 1'b0;
                alu_src    = 1'b0;
                branch     = 1'b0;
                jump       = 1'b0;
                imm_sel    = 3'b000;
                alu_op     = 2'b00;
            end
        endcase
    end

endmodule
