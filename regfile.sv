`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: ARIVU
// 
// Create Date: 19.04.2026 15:40:24
// Design Name: 
// Module Name: regfile
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
module regfile (
    input  logic        clk,
    input  logic        we3,     // Write Enable
    input  logic [4:0]  a1,      // Source 1 Address
    input  logic [4:0]  a2,      // Source 2 Address
    input  logic [4:0]  a3,      // Destination Address
    input  logic [31:0] wd3,     // Write Data
    output logic [31:0] rd1,     // Read Data 1
    output logic [31:0] rd2      // Read Data 2
);

    // 32 registers, each 32 bits wide
    logic [31:0] rf [31:0];

    // Synchronous write on positive clock edge
    always_ff @(posedge clk) begin
        if (we3) begin
            // Crucial RISC-V Rule: We cannot write to x0.
            if (a3 != 5'd0) begin
                rf[a3] <= wd3;
            end
        end
    end

    // Combinational read
    // Rule: Register 0 is always 0.
    // NOTE: This forward logic handles reading the same cycle we write? 
    // In a single-cycle CPU we don't strictly need internal forwarding as writes happen at the end of the inst cycle.
    assign rd1 = (a1 != 5'd0) ? rf[a1] : 32'd0;
    assign rd2 = (a2 != 5'd0) ? rf[a2] : 32'd0;

endmodule


