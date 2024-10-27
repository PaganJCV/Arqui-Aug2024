module IF_ID(
    input IN, A, Size, R/W, E;
    input [31:0] rom_instruction;
    input [3:0] EX_Rd_or_14;
    input ID_S_enable;

    output reg [3:0] EX_Rd_or_14;
    output reg PW, RW;
    output reg [31:0] instruction
);
endmodule