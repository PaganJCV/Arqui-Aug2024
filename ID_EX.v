module ID_EX(
    input clk, R;
//     input next_pc;
//     input [3:0] Pa, Pb, Pd;
//     input [3:0] Rd_or_14;
//     input [11:0] I_11_0;
    input [3:0] in_ID_opcode;
    input in_ID_AM,
          in_ID_S_enable,
          in_ID_load_instr,
          in_ID_RF_enable,
          in_ID_Size_enable,
          in_ID_RW_enable,
          in_ID_Enable_signal
//     output reg EX_next_pc;
//     output reg [3:0] EX_Pa, EX_Pb, EX_Pd;
//     output reg [11:0] EX_I_11_0;
//     output reg [3:0] EX_Rd_or_14;
    output reg [3:0] EX_opcode;
    output reg EX_AM,
          EX_S_enable,
          EX_load_instr,
          EX_RF_enable,
          EX_Size_enable,
          EX_RW_enable,
          EX_Enable_signal
);

always @(posedge clk) begin
      if(R) begin
            EX_opcode <= 4'0000;
            EX_AM <= 1'0;
            EX_S_enable <= 1'0;
            EX_load_instr <= 1'0;
            EX_RF_enable <= 1'0;
            EX_Size_enable <= 1'0;
            EX_RW_enable <= 1'0;
            EX_Enable_signal <= 1'0;
      end
      else begin
            EX_opcode <= in_ID_opcode;
            EX_AM <= in_ID_AM;
            EX_S_enable <= in_ID_S_enable;
            EX_load_instr <= in_ID_load_instr;
            EX_RF_enable <= in_ID_RF_enable;
            EX_Size_enable <= in_ID_Size_enable;
            EX_RW_enable <= in_ID_RW_enable;
            EX_Enable_signal <= in_ID_Enable_signal;
      end 
end

endmodule