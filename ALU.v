`timescale 1ns/1ps

module Arithmetic_Unit(
    input  wire [31:0] OpA,
    input  wire [31:0] OpB,
    input  wire binvert,      
    output wire [31:0] out,
    output wire Overflow,
    output wire cout_final
);
    wire [31:0] B_mux;
    wire [7:0] P_group, G_group;
    wire [7:0] block_carries;

    assign B_mux = binvert ? ~OpB : OpB;

    Global_LCU_8way lcu (
        .cin(binvert),     //because -B = ~B + 1
        .P(P_group),
        .G(G_group),
        .C(block_carries),
    );

    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : gen_cla
            CLA_4bit cla_inst (
                .a(OpA[i*4 +: 4]),
                .b(B_mux[i*4 +: 4]),
                .cin(block_carries[i]),
                .sum(out[i*4 +: 4]),
                .Pg(P_group[i]),
                .Gg(G_group[i])
            );
        end
    endgenerate

    assign cout_final = G_group[7] | (P_group[7] & block_carries[7]);

    assign Overflow =(OpA[31] & B_mux[31] & ~out[31]) | (~OpA[31] & ~B_mux[31] & out[31]);

endmodule

module Logical_Unit(
    input wire [31:0] OpA,
    input wire [31:0] OpB,
    input wire [1:0] LogicOp,
    output reg [31:0] Out
);
    always @(*) begin
        case(LogicOp)
            2'b00: Out = OpA & OpB;
            2'b01: Out = OpA | OpB;
            2'b10: Out = OpA ^ OpB;
            2'b11: Out = ~(OpA | OpB);
            default: Out = 32'b0;
        endcase
    end
endmodule

module CLA_4bit(
    input  wire [3:0] a, b,
    input  wire cin,
    output wire [3:0] sum,
    output wire Pg, Gg 
);
    wire [3:0] p = a ^ b; 
    wire [3:0] g = a & b; 
    wire [4:0] c;         
    assign c[0] = cin;
    assign c[1] = g[0] | (p[0] & c[0]);
    assign c[2] = g[1] | (p[1] & g[0]) | (p[0] & p[1] & c[0]);
    assign c[3] = g[2] | (p[2] & g[1]) | (p[2] & p[1] & g[0]) | (p[2] & p[1] & p[0] & c[0]);
    
    assign sum = p ^ c[3:0];

    assign Pg = &p; 
    assign Gg = g[3] | (p[3] & g[2]) | (p[3] & p[2] & g[1]) | (p[3] & p[2] & p[1] & g[0]);
endmodule

module Global_LCU_8way(
    input  wire cin,
    input  wire [7:0] P, 
    input  wire [7:0] G, 
    output reg  [7:0] C     
);
    integer i;

    always @(*) begin
        C[0] = cin;
        for (i = 0; i < 7; i = i + 1) begin
            C[i+1] = G[i] | (P[i] & C[i]);
        end
    end
endmodule

module Shifter_Unit(
    input  wire [31:0] DataIn,
    input  wire [4:0]  Shamt,
    input  wire [1:0]  ShiftType, 
    output reg  [31:0] DataOut
);
    wire [31:0] stage1, stage2, stage3, stage4, stage5;
    wire fill;
    
    assign fill = (ShiftType == 2'b10) ? DataIn[31] : 1'b0;

    assign stage1 = Shamt[4] ? (ShiftType == 2'b00 ? {DataIn[15:0], 16'b0} : {{16{fill}}, DataIn[31:16]}) : DataIn;
    assign stage2 = Shamt[3] ? (ShiftType == 2'b00 ? {stage1[23:0], 8'b0} : {{8{fill}}, stage1[31:8]}) : stage1;
    assign stage3 = Shamt[2] ? (ShiftType == 2'b00 ? {stage2[27:0], 4'b0} : {{4{fill}}, stage2[31:4]}) : stage2;
    assign stage4 = Shamt[1] ? (ShiftType == 2'b00 ? {stage3[29:0], 2'b0} : {{2{fill}}, stage3[31:2]}) : stage3;
    assign stage5 = Shamt[0] ? (ShiftType == 2'b00 ? {stage4[30:0], 1'b0} :  {fill, stage4[31:1]}) : stage4;

    always @(*) DataOut = stage5;

endmodule

module ALU(
    input  wire [31:0] op1,        
    input  wire [31:0] op2,       
    input  wire [4:0]  shamt,      
    input  wire [3:0]  ALUControl, 
    output reg  [31:0] ALUout,
    output wire Zero,
    output wire Overflow,
    output wire Negative
);
    wire [31:0] add_sub_out;
    wire [31:0] logical_out;
    wire [31:0] shift_out;
    wire cout_internal;

    wire is_sub = (ALUControl == 4'b0110 || ALUControl == 4'b0111);

    Arithmetic_Unit AU (
        .OpA(op1), .OpB(op2), .binvert(is_sub),
        .out(add_sub_out), .Overflow(Overflow), .cout_final(cout_internal)
    );

    Logical_Unit LU (
        .OpA(op1), .OpB(op2), .LogicOp(ALUControl[1:0]),
        .Out(logical_out)
    );

    Shifter_Unit Shift (
        .DataIn(op2), .Shamt(shamt), .ShiftType(ALUControl[1:0]),
        .DataOut(shift_out)
    );

    always @(*) begin
        case (ALUControl)
            4'b0000, 4'b0001, 4'b1100, 4'b1010: ALUout = logical_out; 
            4'b0010, 4'b0110: ALUout = add_sub_out;                   
            4'b0111:          ALUout = {31'b0, add_sub_out[31] ^ Overflow}; 
            4'b1000, 4'b1001, 4'b1011: ALUout = shift_out;           
            default:          ALUout = 32'b0;
        endcase
    end

    assign Zero = (ALUout == 32'b0);
    assign Negative = ALUout[31];

endmodule