`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: ARIVU
// 
// Create Date: 19.04.2026 15:37:35
// Design Name: 
// Module Name: control_unit
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module control_unit (
    input  logic [6:0] op,
    input  logic [2:0] funct3,
    input  logic       funct7_5, // bit 30 of instruction (funct7[5])
    input  logic       zero,     // from ALU
    output logic       reg_write,
    output logic [2:0] imm_src,
    output logic       alu_src,  // 0: register, 1: immediate
    output logic [3:0] alu_control, // Tells ALU what to do
    output logic       mem_write,
    output logic [1:0] result_src, // 00: ALUResult, 01: ReadData, 10: PC+4
    output logic       pc_src      // 1: jump/branch taken, 0: PC+4
);

    logic       branch;
    logic       jump;
    logic [1:0] alu_op;

    // Main Decoder
    always_comb begin
        // Defaults to avoid latches
        reg_write   = 1'b0;
        imm_src     = 3'b000;
        alu_src     = 1'b0;
        mem_write   = 1'b0;
        result_src  = 2'b00;
        branch      = 1'b0;
        jump        = 1'b0;
        alu_op      = 2'b00; // 00: add, 01: sub (branch), 10: R/I-type decode

        case(op)
            7'b0110011: begin // R-Type (ADD, SUB, AND, OR, etc)
                reg_write  = 1'b1;
                result_src = 2'b00;
                alu_src    = 1'b0;
                alu_op     = 2'b10;
            end
            7'b0010011: begin // I-Type ALU (ADDI, ANDI, etc)
                reg_write  = 1'b1;
                imm_src    = 3'b000;
                result_src = 2'b00;
                alu_src    = 1'b1; // Use Imm
                alu_op     = 2'b10;
            end
            7'b0000011: begin // I-Type Load (LW)
                reg_write  = 1'b1;
                imm_src    = 3'b000;
                result_src = 2'b01; // Data from Mem
                alu_src    = 1'b1;
                alu_op     = 2'b00; // add offset
            end
            7'b0100011: begin // S-Type Store (SW)
                mem_write  = 1'b1;
                imm_src    = 3'b001;
                alu_src    = 1'b1;
                alu_op     = 2'b00; // add offset
            end
            7'b1100011: begin // B-Type Branch (BEQ)
                branch     = 1'b1;
                imm_src    = 3'b010;
                alu_src    = 1'b0;
                alu_op     = 2'b01; // subtract for comparison
            end
            7'b1101111: begin // J-Type (JAL)
                reg_write  = 1'b1;
                jump       = 1'b1;
                imm_src    = 3'b011;
                result_src = 2'b10; // Save PC+4 to reg
                // jal computes PC + imm_ext, we could use ALU or dedicated adder
            end
            7'b0110111: begin // U-Type (LUI)
                reg_write  = 1'b1;
                imm_src    = 3'b100;
                result_src = 2'b00;
                alu_src    = 1'b1;
                // For LUI, the ALU just needs to pass the Imm string through without adding. 
                // We'll set a special ALUOp or just use ADD with SrcA tied to 0. 
                // Alternatively, our ALU doesn't have a "pass through" but x0 is 0. 
                alu_op     = 2'b00; 
            end
            default: ; // Do nothing
        endcase
    end

    // ALU Decoder
    always_comb begin
        case(alu_op)
            2'b00: alu_control = 4'b0000; // Load/Store/LUI -> ADD
            2'b01: alu_control = 4'b1000; // Branch -> SUB
            2'b10: begin // R-type or I-type ALU
                case(funct3)
                    3'b000: begin
                        // ADD or SUB
                        // If R-type (op[5]==1) and funct7[5]==1, then SUB. Else ADD.
                        if ({op[5], funct7_5} == 2'b11) alu_control = 4'b1000; // SUB
                        else                            alu_control = 4'b0000; // ADD/ADDI
                    end
                    3'b001: alu_control = 4'b0001; // SLL
                    3'b010: alu_control = 4'b0010; // SLT
                    3'b011: alu_control = 4'b0011; // SLTU
                    3'b100: alu_control = 4'b0100; // XOR
                    3'b101: begin
                        // SRL or SRA
                        if (funct7_5) alu_control = 4'b1101; // SRA
                        else          alu_control = 4'b0101; // SRL
                    end
                    3'b110: alu_control = 4'b0110; // OR
                    3'b111: alu_control = 4'b0111; // AND
                    default: alu_control = 4'bXXXX;
                endcase
            end
            default: alu_control = 4'bXXXX;
        endcase
    end

    // PCSrc Generation (Branch/Jump resolution)
    // PCSrc = 1 if (Jump == 1) OR (Branch == 1 AND Zero == 1)
    // Note: For BNE, BLT etc., you need a more advanced Zero check. For now, we support BEQ.
    assign pc_src = jump | (branch & zero);

endmodule

