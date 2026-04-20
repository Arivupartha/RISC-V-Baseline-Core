`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: ARIVU
// 
// Create Date: 19.04.2026 15:35:08
// Design Name: 
// Module Name: imem
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


module imem(
    input  logic [31:0] addr,
    output logic [31:0] instr
    );
    // 256 words (1KB) Instruction Memory ROM
    logic [31:0] ROM [255:0];

    // In a real verification environment, we use $readmemh to load a hex file
    initial begin
        // For synthesis tools or simulator initializations:
        $readmemh("firmware.hex", ROM);
    end

    // Word-aligned combinatorial read
    assign instr = ROM[addr[9:2]];
endmodule
