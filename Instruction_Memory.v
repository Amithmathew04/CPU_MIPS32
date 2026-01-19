`timescale 1ns/1ps

module PC (  
    input wire clk,
    input wire reset,
    output reg [31:0] pc_out
);
    localparam PC_RESET = 32'h0000_0000;
    localparam PC_INCREMENT = 32'd4;

    always(@posedge clk) begin
        if (reset)
            pc_out <= PC_RESET;
        else
            pc_out <= pc_out + PC_INCREMENT;
    end

endmodule

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


module Data_Memory(
    input wire clk,
    input wire [31:0] addr,
    output wire [31:0] data
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
endmodule