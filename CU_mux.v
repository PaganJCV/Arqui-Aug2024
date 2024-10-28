module CU_mux(
    input S,
    input [3:0] mux_opcode,
    input mux_AM,
          mux_S_enable,
          mux_load_instr,
          mux_RF_enable,
          mux_Size_enable,
          mux_RW_enable,
          mux_Enable_signal,
          mux_BL_instr,
          mux_B_instr,
    output reg [3:0] ID_opcode,
    output reg ID_AM,
               ID_S_enable,
               ID_load_instr,
               ID_RF_enable,
               ID_Size_enable,
               ID_RW_enable,
               ID_Enable_signal,
               ID_BL_instr,
               ID_B_instr
);

always @(*) begin
    if(S) begin
        ID_opcode = 4'b0000;
        ID_AM = 1'b0;
        ID_S_enable = 1'b0;
        ID_load_instr = 1'b0;
        ID_RF_enable = 1'b0;
        ID_Size_enable = 1'b0;
        ID_RW_enable = 1'b0;
        ID_Enable_signal = 1'b0;
        ID_BL_instr = 1'b0;
        ID_B_instr = 1'b0;
    end

    else begin
        ID_opcode <= mux_opcode;
        ID_AM <= mux_AM;
        ID_S_enable <= mux_S_enable;
        ID_load_instr <= mux_load_instr;
        ID_RF_enable <= mux_RF_enable;
        ID_Size_enable <= mux_Size_enable;
        ID_RW_enable <= mux_RW_enable;
        ID_Enable_signal <= mux_Enable_signal;
        ID_BL_instr <= mux_BL_instr;
        ID_B_instr <= mux_B_instr;
    end
end

endmodule