`timescale 1ns/1ps

module Instruction_Memory( 
        input wire [31:0] PC,
        output wire [31:0] instr       
);
    localparam MEM_BYTES = 32 * 1024;
    localparam WORDS = MEM_BYTES/4;

    reg[31:0] memory [0:WORDS - 1];

    wire [12:0] word_index;
    assign word_index = PC[14:2];

    assign instr = memory[word_index];

endmodule


module Data_Memory (
    input wire clk,
    input wire MemWrite,
    input wire MemRead,
    input wire [31:0] addr,
    input wire [31:0] in_data,
    output wire [31:0] out_data
);
    localparam MEM_BYTES = 1024 * 128;
    localparam WORDS = MEM_BYTES/4;

    reg [31:0] memory[0:WORDS - 1];
    
    wire [14:0] word_index;
    assign word_index = addr[16:2];

    assign data = memory[word_index];

endmodule

module Register_File(
    input wire clk, 
    input wire we,
    input wire [4:0] ra1,
    input wire [4:0] ra2,
    input wire [4:0] wa,
    input wire [31:0] wd,
    output wire [31:0] rd1,
    output wire [31:0] rd2
);
    reg [31:0] regs [31:0];

        assign rd1 = (ra1 != 0) ? regs[ra1] : 32'b0;
    assign rd2 = (ra2 != 0) ? regs[ra2] : 32'b0;

    always @(posedge clk) begin
        if (we && wa != 0)
            regs[wa] <= wd;
    end
endmodule

module PipelineRegs(
    input reg [31:0] a,
    output reg [31:0] b
);
    always @(posedge clk)
endmodule

