`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: ARIVU
// 
// Create Date: 19.04.2026 15:31:41
// Design Name: 
// Module Name: pc
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


module pc(
    input  logic        clk,
    input  logic        reset_n,
    input  logic [31:0] pc_next,
    output logic [31:0] pc);
    
    
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n)
            pc <= 32'd0; // Boot address is typically 0
        else
            pc <= pc_next;
    end

    
    
endmodule
