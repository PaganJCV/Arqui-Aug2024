module PSR(
    input clk, SE,
    input Z_in, N_in, C_in, V_in,
    output reg [3:0] PSR_flags // Combined register for flags [N, Z, C, V]
);

always @(posedge clk) begin
    if (SE) PSR_flags <= {N_in, Z_in, C_in, V_in};
    else PSR_flags <= 4'b0000;
end

endmodule
