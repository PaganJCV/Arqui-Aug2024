module Control_Unit(
    input [31:0] instruction;
    output reg[3:0] opcode;
    output reg AM,
               S_enable,
               load_instr,
               RF_enable,
               Size_enable,
               RW_enable,
               Enable_signal,
               BL_instr,
               B_instr
);

always @(posedge clk) begin
//signals definition
end

endmodule