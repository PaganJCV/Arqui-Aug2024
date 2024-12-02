module RF_big_mux(
    input [3:0] in_PX, EX_TO_ID_RD, MEM_TO_ID_RD, WB_TO_ID_RD,
    input [1:0] FW_ID_RX_MUX_SIGNAL,
    output reg [3:0] Px,     
); 

always @(*) begin
    case(FW_ID_RX_MUX_SIGNAL)
        2'd00: Px = in_PX;
        2'b01: Px = EX_TO_ID_RD;
        2'b10: Px = MEM_TO_ID_RD;
        2'b11: Px = WB_TO_ID_RD;
        default: Px = in_PX;
    endcase
end 

endmodule