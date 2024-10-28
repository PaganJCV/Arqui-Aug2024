module MEM_WB(
    input clk, R;
    input in_MEM_RF_enable;
    output reg WB_RF_enable;
);

always @(posedge clk) begin
    if(R) WB_RF_enable <= 1'b0;
    else WB_RF_enable <= 1'b1;
end

endmodule