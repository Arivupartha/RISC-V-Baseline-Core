`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:ARIVU 
// 
// Create Date: 19.04.2026 15:44:32
// Design Name: 
// Module Name: riscv_core
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


`timescale 1ns / 1ps

module riscv_core (
    input logic clk,
    input logic reset_n
);

    // --- Interconnect Wires ---
    logic [31:0] pc, pc_next, pc_plus_4;
    logic [31:0] instr;
    logic [31:0] imm_ext;
    logic [31:0] result;
    logic [31:0] rd1, rd2;
    logic [31:0] src_a, src_b;
    logic [31:0] alu_result;
    logic [31:0] read_data;
    logic [31:0] pc_target;
    
    // Control Signals
    logic       reg_write, mem_write, alu_src, pc_src, zero;
    logic [2:0] imm_src;
    logic [1:0] result_src;
    logic [3:0] alu_control;

    // --- Data Path Instantiations ---

    // 1. Program Counter Fetch Logic
    pc u_pc (
        .clk(clk),
        .reset_n(reset_n),
        .pc_next(pc_next),
        .pc(pc)
    );

    // PC Adders
    assign pc_plus_4 = pc + 32'd4;
    assign pc_target = pc + imm_ext;

    // PCSrc MUX (Branch/Jump resolution)
    assign pc_next = (pc_src) ? pc_target : pc_plus_4;

    // 2. Instruction Memory
    imem u_imem (
        .addr(pc),
        .instr(instr)
    );

    // 3. Control Unit
    control_unit u_control (
        .op(instr[6:0]),
        .funct3(instr[14:12]),
        .funct7_5(instr[30]),
        .zero(zero),
        .reg_write(reg_write),
        .imm_src(imm_src),
        .alu_src(alu_src),
        .alu_control(alu_control),
        .mem_write(mem_write),
        .result_src(result_src),
        .pc_src(pc_src)
    );

    // 4. Register File
    regfile u_regfile (
        .clk(clk),
        .we3(reg_write),
        .a1(instr[19:15]),
        .a2(instr[24:20]),
        .a3(instr[11:7]),
        .wd3(result),
        .rd1(rd1),
        .rd2(rd2)
    );

    // 5. Immediate Generator
    immgen u_immgen (
        .instr(instr),
        .imm_src(imm_src),
        .imm_ext(imm_ext)
    );

    // 6. ALU & ALUSrc MUX
    assign src_a = rd1;
    assign src_b = (alu_src) ? imm_ext : rd2; // ALUSrc MUX

    alu u_alu (
        .src_a(src_a),
        .src_b(src_b),
        .alu_control(alu_control),
        .alu_result(alu_result),
        .zero(zero)
    );

    // 7. Data Memory
    dmem u_dmem (
        .clk(clk),
        .we(mem_write),
        .addr(alu_result),
        .wd(rd2),
        .rd(read_data)
    );

    // ResultSrc MUX (Writeback)
    always_comb begin
        case(result_src)
            2'b00: result = alu_result;
            2'b01: result = read_data;
            2'b10: result = pc_plus_4; // for JAL
            default: result = 32'dx;
        endcase
    end

endmodule
