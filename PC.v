module PC(
    input clk, R, LE;
    input [7:0] in_pc,
    output reg [7:0] out_pc;
);

always @(posedge clk) begin
    if(LE) out_pc <= in_pc;
    else if (R) out_pc <= 8'b00000000;
end

endmodule