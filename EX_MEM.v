module EX_MEM(
       input clk, R;
       input in_EX_load_instr,
          in_EX_RF_enable,
          in_EX_Size_enable,
          in_EX_RW_enable,
          in_EX_Enable_signal;
    // input A, B;
    // input ID_B_instr, ID_BL_instr;
    // input next_pc;
    // input [3:0] I_15_12_Rd, I_31_28, RM, OpCode;
    // input [11:0] I_11_0;
    // input AM, SE; 
    // input flags;
       output reg MEM_load_instr,
          MEM_RF_enable,
          MEM_Size_enable,
          MEM_RW_enable,
          MEM_Enable_signal
    // output reg Out;
    // output reg Branch, B&L;
    // output reg Flags;
    // output reg [31:0] instruction;
);

always @(posedge clk) begin
    if(R) begin
        MEM_load_instr <= 1'b0;
        MEM_RF_enable <= 1'b0;
        MEM_Size_enable <= 1'b0;
        MEM_RW_enable <= 1'b0;
        MEM_Enable_signal <= 1'b0;
    end
    else begin
        MEM_load_instr <= in_EX_load_instr;
        MEM_RF_enable <= in_EX_RF_enable;
        MEM_Size_enable <= in_EX_Size_enable;
        MEM_RW_enable <= in_EX_RW_enable;
        MEM_Enable_signal <= in_EX_Enable_signal;
    end
end

endmodule 