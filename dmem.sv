`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: ARIVU
// 
// Create Date: 19.04.2026 15:43:15
// Design Name: 
// Module Name: dmem
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

module dmem (
    input  logic        clk,
    input  logic        we,      // Write Enable
    input  logic [31:0] addr,    // Address from ALU Result
    input  logic [31:0] wd,      // Write Data from RegFile rd2
    output logic [31:0] rd       // Read Data to ResultSrc Mux
);

    // 256 words (1KB) Data Memory for demonstration
    // Note: RISC-V is byte-addressable. To simplify this single-cycle standard 
    // educational CPU, we will ignore unaligned accesses and assume word-aligned accesses.
    // Address [31:2] acts as the word index.
    logic [31:0] RAM [255:0];

    // Read asynchronously (combinational read) to satisfy single-cycle timing
    // Ignore lower 2 bits for byte alignment (Word-aligned reads only)
    assign rd = RAM[addr[9:2]];

    // Synchronous write
    always_ff @(posedge clk) begin
        if (we)
            RAM[addr[9:2]] <= wd;
    end

endmodule
