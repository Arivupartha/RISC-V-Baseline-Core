`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: ARIVU
// 
// Create Date: 19.04.2026 15:39:09
// Design Name: 
// Module Name: alu
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

module alu (
    input  logic [31:0] src_a,
    input  logic [31:0] src_b,
    input  logic [3:0]  alu_control,
    output logic [31:0] alu_result,
    output logic        zero
);

    always_comb begin
        case (alu_control)
            4'b0000: alu_result = src_a + src_b;                           // ADD
            4'b1000: alu_result = src_a - src_b;                           // SUB
            4'b0001: alu_result = src_a << src_b[4:0];                     // SLL
            4'b0010: alu_result = $signed(src_a) < $signed(src_b) ? 32'd1 : 32'd0; // SLT
            4'b0011: alu_result = src_a < src_b ? 32'd1 : 32'd0;           // SLTU
            4'b0100: alu_result = src_a ^ src_b;                           // XOR
            4'b0101: alu_result = src_a >> src_b[4:0];                     // SRL
            4'b1101: alu_result = $signed(src_a) >>> src_b[4:0];           // SRA
            4'b0110: alu_result = src_a | src_b;                           // OR
            4'b0111: alu_result = src_a & src_b;                           // AND
            default: alu_result = 32'dx;                                   // Default to unknown
        endcase
    end

    // Zero flag generation (used for branching logic)
    assign zero = (alu_result == 32'd0);

endmodule