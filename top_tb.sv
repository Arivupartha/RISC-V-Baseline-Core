`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: ARIVU
// 
// Create Date: 19.04.2026 15:46:24
// Design Name: 
// Module Name: top_tb
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
  
  
  



module tb_riscv_core();

    // Verification Testbench Signals
    logic clk;
    logic reset_n;

    // Instantiate the Design Under Test (DUT)
    riscv_core dut (
        .clk(clk),
        .reset_n(reset_n)
    );

    // Clock Generator: 100MHz (10ns period)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Stimulus and Reset Driver
    initial begin
        // Initialize
        reset_n = 0;
        
        // Wait for a few clock cycles
        #20;
        
        // Release reset (Boot the CPU!)
        reset_n = 1;

        // In a real verification environment, you would use a timeout watchdog here
        // We will run for 1000ns (100 clock cycles) which is plenty to execute
        // the 11 instructions inside firmware.hex.
        #1000;
        
        $display("Simulation Complete.");
        $finish;
    end

    // Basic Monitor: Watch what the CPU is doing
    always @(posedge clk) begin
        if (reset_n) begin
            $display("Time: %0t | PC: %h | Inst: %h | RegWrite: %b | MemWrite: %b",
                     $time, dut.pc, dut.instr, dut.reg_write, dut.mem_write);
        end
    end

endmodule
