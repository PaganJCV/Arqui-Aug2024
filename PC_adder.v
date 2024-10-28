module PC_adder(
    input [7:0] num,
    output reg [7:0] result;
);

always @(num) result <= num + 3'b100;

endmodule