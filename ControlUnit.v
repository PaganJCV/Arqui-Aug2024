module Control_Unit(
    input [31:0] instruction;
    output reg[3:0] opcode;
    output reg ID_AM;
    output reg ID_S_enable,
               ID_load_instr,
               ID_RF_enable,
               ID_Size_enable,
               ID_RW_enable,
               ID_Enable_signal,
               ID_BL_instr,
               ID_B_instr
);

always @(instruction) begin
//signals defiinition
end

endmodule