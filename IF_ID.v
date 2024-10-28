module IF_ID(
    input clk, R;
    // input pc_plus_4;
    input [31:0] rom_instruction;
    input LE;
    // output reg [23:0] I_23_0;
    // output reg next_pc;
    // output reg [3:0] I_19_16_Rn, I_3_0_Rm, I_15_12_Rd, I_31_28;
    // output reg [11:0] I_11_0;
    output reg [31:0] instruction
);

// normal run
always @(posedge clk)begin
    if(R) instruction <= 32'b00000000000000000000000000000000;
    else if(LE)
    // I_23_0 <= rom_instruction[23:0];
    // I_19_16_Rn <= rom_instruction[19:16];
    // I_3_0_Rm <= rom_instruction[15:12];
    // I_31_28 <= rom_instruction[31:28];
    // next_pc <= pc_plus_4;
    instruction <= rom_instruction;
end

endmodule