module Control_Unit(
    input wire [31:0] instr,
    output wire ALUSrc,
    output wire ITypectrl,
    output
);
    wire [4:0] opcode;
    opcode = instr[31:26];


endmodule

module 2_1_mux(
    input wire ctrlsig,
    input wire [31:0] instr
);

endmodule