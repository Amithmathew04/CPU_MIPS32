1ns/1ps
module Control_Unit (
    input  wire [5:0] opcode,
    output reg PCSrc,
    output reg RegDst,
    output reg Branch,
    output reg MemRead,
    output reg MemWrite,
    output reg MemtoReg,
    output reg ALUSrc,
    output reg RegWrite,
    output reg [1:0] ALUOp
);

    always @(*) begin
        RegDst   = 0;
        Branch   = 0;
        MemRead = 0;
        MemWrite= 0;
        MemtoReg= 0;
        ALUSrc  = 0;
        RegWrite= 0;
        ALUOp   = 2'b00;

        case (opcode)

            6'b000000: begin // R-type
                RegDst = 1;
                RegWrite = 1;
                ALUSrc = 0;
                ALUOp = 2'b10;
                PCSrc = 
            end

            6'b100011: begin // LW
                ALUSrc = 1;
                MemRead = 1;
                MemtoReg = 1;
                RegWrite = 1;
                ALUOp = 2'b00;
            end

            6'b101011: begin // SW
                ALUSrc = 1;
                MemWrite = 1;
                ALUOp = 2'b00;
            end

            6'b000100: begin // BEQ
                Branch = 1;
                ALUOp  = 2'b01;
            end

            default: ; // NOP
        endcase
    end
endmodule

module ALU_Control (
    input  wire [1:0] ALUOp,
    input  wire [5:0] funct,
    output reg  [3:0] ALUControl
);

    always @(*) begin
        case (ALUOp)

            2'b00: ALUControl = 4'b0010; // ADD (lw, sw)

            2'b01: ALUControl = 4'b0110; // SUB (beq)

            2'b10: begin // R-type
                case (funct)
                    6'b100000: ALUControl = 4'b0010; // ADD
                    6'b100010: ALUControl = 4'b0110; // SUB
                    6'b100100: ALUControl = 4'b0000; // AND
                    6'b100101: ALUControl = 4'b0001; // OR
                    6'b100110: ALUControl = 4'b1100; // XOR
                    6'b101010: ALUControl = 4'b0111; // SLT
                    default:   ALUControl = 4'b0000;
                endcase
            end

            default: ALUControl = 4'b0000;
        endcase
    end
endmodule

module Shift_Left_2 (
    input  wire [31:0] in,
    output wire [31:0] out
);
    assign out = in << 2;
endmodule

module RegDst_Mux (
    input  wire [4:0] rt,
    input  wire [4:0] rd,
    input  wire RegDst,
    output wire [4:0] WriteReg
);
    assign WriteReg = RegDst ? rd : rt;
endmodule

module ALUSrc_Mux (
    input  wire [31:0] ReadData2,
    input  wire [31:0] ImmExt,
    input  wire ALUSrc,
    output wire [31:0] ALU_B
);
    assign ALU_B = ALUSrc ? ImmExt : ReadData2;
endmodule

module MemToReg_Mux (
    input  wire [31:0] ALUout,
    input  wire [31:0] MemData,
    input  wire MemtoReg,
    output wire [31:0] WriteData
);
    assign WriteData = MemtoReg ? MemData : ALUout;
endmodule

module PCSrc(
    input wire [31:0] instr,

);

endmodule
