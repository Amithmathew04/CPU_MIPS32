`timescale 1ns/1ps

typedef struct packed {
    logic RegWrite;
    logic MemRead;
    logic MemWrite;
    logic MemtoReg;
    logic Branch;
    logic Jump;
    logic ALUSrc;
    logic [1:0] ALUOp;
} ctrl_t;

typedef struct packed {
    logic [31:0] PC_plus_4;
    logic [31:0] rs1_data;
    logic [31:0] rs2_data;
    logic [31:0] imm;
    logic [4:0] rs;
    logic [4:0] rt;
    logic [4:0] rd;
} idex_data_t;

typedef struct packed {
    logic RegWrite;
    logic MemRead;
    logic MemtoReg;
    logic Branch;
    logic Jump;
} exmem_ctrl_t;

typedef struct packed {
    logic [31:0] ALU_result;
    logic [31:0] WriteData;
    logic [31:0] PC_branch;
    logic [4:0]  rd;
    logic        Zero;
} exmem_data_t;

module IF_ID_reg(
    input logic clk,
    input logic reset,
    input logic stall,
    input logic flush,
    input logic [31:0] PC_plus_4in,
    input logic [31:0] instr_in,
    
    output logic [31:0] PC_plus_4out,
    output logic [31:0] instr_out
);
    always @(posedge clk)
    begin
        if (reset || flush) begin
            PC_plus_4out <= 32'b0;
            instr_out <= 32'b0;
        end else if (!stall) begin
            PC_plus_4out <= PC_plus_4in;
            instr_out <= instr_in;
        end
    end

endmodule

module ID_EX_reg(
    input  logic clk,
    input  logic reset,
    input  logic stall,
    input  logic flush,
    input  ctrl_t ctrl_in,
    input  idex_data_t data_in,

    output ctrl_t ctrl_out,
    output idex_data_t data_out
);
    always_ff @(posedge clk) begin
        if (reset || flush) begin
            ctrl_out <= '0;   
            data_out <= '0;
        end else if (!stall) begin
            ctrl_out <= ctrl_in;
            data_out <= data_in;
        end
    end
endmodule


module Ex_Mem_reg(
    input  logic clk,
    input  logic reset,
    input  logic stall,
    input  logic flush,

    input  exmem_ctrl_t  ctrl_in,
    input  exmem_data_t  data_in,

    output exmem_ctrl_t  ctrl_out,
    output exmem_data_t  data_out
);
    always_ff @(posedge clk) begin
        if (reset || flush) begin
            ctrl_out <= '0;  
            data_out <= '0;
        end
        else if (!stall) begin
            ctrl_out <= ctrl_in;
            data_out <= data_in;
        end
    end
endmodule

module Mem_WB_reg(
    input  logic clk,
    input  logic reset,
    input  logic stall,
    input  logic flush,
    input  logic RegWrite_in,
    input  logic MemtoReg_in,
    input  logic [31:0] ReadData_in,
    input  logic [31:0] ALU_result_in,
    input  logic [4:0]  rd_in,

    output logic RegWrite_out,
    output logic MemtoReg_out,
    output logic [31:0] ReadData_out,
    output logic [31:0] ALU_result_out,
    output logic [4:0] rd_out
);

    always_ff @(posedge clk) begin
        if (reset || flush) begin
            RegWrite_out   <= 1'b0;
            MemtoReg_out   <= 1'b0;

            ReadData_out   <= 32'b0;
            ALU_result_out <= 32'b0;
            rd_out         <= 5'b0;
        end
        else if (!stall) begin
            RegWrite_out   <= RegWrite_in;
            MemtoReg_out   <= MemtoReg_in;

            ReadData_out   <= ReadData_in;
            ALU_result_out <= ALU_result_in;
            rd_out         <= rd_in;
        end
    end
endmodule
