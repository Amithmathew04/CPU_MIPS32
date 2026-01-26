`timescale 1ps/1ps

module PC (
    input  wire        clk,
    input  wire        reset,
    input  wire [31:0] pc_next,
    output reg  [31:0] pc_out
);

    localparam PC_RESET = 32'h0000_0000;

    always @(posedge clk or posedge reset) begin
        if (reset)
            pc_out <= PC_RESET;
        else
            pc_out <= pc_next;
    end

endmodule

module PC_Plus4 (
    input  wire [31:0] pc,
    output wire [31:0] pc_plus4
);
    assign pc_plus4 = pc + 32'd4;
endmodule

module Branch_Adder (
    input  wire [31:0] pc_plus4,
    input  wire [31:0] imm_shifted,
    output wire [31:0] branch_target
);
    assign branch_target = pc_plus4 + imm_shifted;
endmodule

module PC_Mux (
    input  wire [31:0] pc_plus4,
    input  wire [31:0] branch_target,
    input  wire        PCSrc,
    output wire [31:0] pc_next
);
    assign pc_next = PCSrc ? branch_target : pc_plus4;
endmodule