`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: ARIVU
// 
// Create Date: 19.04.2026 15:41:49
// Design Name: 
// Module Name: immgen
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


module immgen (
    input  logic [31:0] instr,
    input  logic [2:0]  imm_src,
    output logic [31:0] imm_ext
);

    always_comb begin
        case (imm_src)
            // I-Type (e.g. ADDI, LW, JALR)
            3'b000: imm_ext = {{20{instr[31]}}, instr[31:20]};
            
            // S-Type (e.g. SW, SB)
            3'b001: imm_ext = {{20{instr[31]}}, instr[31:25], instr[11:7]};
            
            // B-Type (e.g. BEQ, BNE)
            // Note the implicit 0 at the LSB because branches are always 2-byte aligned
            3'b010: imm_ext = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};
            
            // J-Type (e.g. JAL)
            // Note the implicit 0 at the LSB for instruction alignment
            3'b011: imm_ext = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};
            
            // U-Type (e.g. LUI, AUIPC)
            // The immediate is already in the upper 20 bits, lower 12 are zeroed
            3'b100: imm_ext = {instr[31:12], 12'b0};
            
            // Default to 0 to prevent latches
            default: imm_ext = 32'd0;
        endcase
    end

endmodule
