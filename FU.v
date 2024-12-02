module ForwardingUnit (
    input [3:0] ID_RD, EX_RD, MEM_RD, WB_RD,
    ID_RM, ID_RN,
    input EX_RF_enable, MEM_RF_enable, WB_RF_enable,
    EX_load_instr, MEM_load_instr,
    output reg FW_LE_SIGNAL, FW_CU_MUX_SIGNAL, FW_MEM_MUX_SIGNAL
    output reg [1:0] FW_ID_RM_MUX_SIGNAL, FW_ID_RN_MUX_SIGNAL,
    output reg [3:0] EX_TO_ID_RD, MEM_TO_ID_RD, WB_TO_ID_RD       
);

// reg [3:0] CURR_EX_RM, MEM_RM, WB_RM, 
//           CURR_EX_RM, MEM_RN, WB_RN;

// always @(*) begin
//     //WB
//     WB_RM = MEM_RM;
//     WB_RN = MEM_RN;
//     //MEM
//     MEM_RM = CURR_EX_RM;
//     MEM_RN = CURR_EX_RN;
//     //UPDATE CURR_EX_RM
//     CURR_EX_RM = EX_RM;
// end
//DATA HAZARD CRITERIA
//FOR RM 
always @(*) begin
if((EX_RF_enable && (ID_RM == EX_RD))) begin
    EX_TO_ID_RD = EX_RD;
    FW_ID_RM_MUX_SIGNAL = 2'b01;  
end

else if((MEM_RF_enable && (ID_RM == MEM_RD))) begin 
    MEM_TO_ID_RD = MEM_RD;
    FW_ID_RM_MUX_SIGNAL = 2'b10;
end

else if((WB_RF_enable && (ID_RM == WB_RD))) begin 
    WB_TO_ID_RD = WB_RD;
    FW_ID_RM_MUX_SIGNAL = 2'b11;
end

else FW_ID_RM_MUX_SIGNAL = 2'b00;
end

//FOR RN
always @(*) begin
if((EX_RF_enable && (ID_RN == EX_RD))) begin
    EX_TO_ID_RD = EX_RD;
    FW_ID_RN_MUX_SIGNAL = 2'b01;  
end

else if((MEM_RF_enable && (ID_RN == MEM_RD))) begin 
    MEM_TO_ID_RD = MEM_RD;
    FW_ID_RN_MUX_SIGNAL = 2'b10;
end

else if((WB_RF_enable && (ID_RN == WB_RD))) begin 
    WB_TO_ID_RD = WB_RD;
    FW_ID_RN_MUX_SIGNAL = 2'b11;
end

else FW_ID_RN_MUX_SIGNAL = 2'b00;
end

//FOR LOAD INSTRUCTIONS
always @(*) begin
if((EX_load_instr && ((ID_RN == EX_RD) || (ID_RM == EX_RD)))) begin
    FW_CU_MUX_SIGNAL = 1'b1;
    FW_LE_SIGNAL = 1'b0;
end

else begin 
    FW_CU_MUX_SIGNAL = 1'b0;
    FW_LE_SIGNAL = 1'b1;
end

assign FW_MEM_MUX_SIGNAL = (MEM_load_instr)? 1'b1:1'b0;

end
endmodule