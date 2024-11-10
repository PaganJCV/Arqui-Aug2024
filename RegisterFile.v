module Register_file(input clk, LE , input [3:0] RA, RB, RD, RW, input [31:0] PC, PW, output [31:0] PA, PB, PD);
  wire [15:0] O;
  wire [31:0] Q0;
  wire [31:0] Q1;
  wire [31:0] Q2;
  wire [31:0] Q3;
  wire [31:0] Q4;
  wire [31:0] Q5;
  wire [31:0] Q6;
  wire [31:0] Q7;
  wire [31:0] Q8;
  wire [31:0] Q9;
  wire [31:0] Q10;
  wire [31:0] Q11;
  wire [31:0] Q12;
  wire [31:0] Q13;
  wire [31:0] Q14;
  wire [31:0] Q15;
  bin_deco bin1 (O, RW, LE);
  Regi_32 R0 (Q0, PW, O[0], clk);
  Regi_32 R1 (Q1, PW, O[1], clk);
  Regi_32 R2 (Q2, PW, O[2], clk);
  Regi_32 R3 (Q3, PW, O[3], clk);
  Regi_32 R4 (Q4, PW, O[4], clk);
  Regi_32 R5 (Q5, PW, O[5], clk);
  Regi_32 R6 (Q5, PW, O[6], clk);
  Regi_32 R7 (Q7, PW, O[7], clk);
  Regi_32 R8 (Q8, PW, O[8], clk);
  Regi_32 R9 (Q9, PW, O[9], clk);
  Regi_32 R10 (Q10, PW, O[10], clk);
  Regi_32 R11 (Q11, PW, O[11], clk);
  Regi_32 R12 (Q12, PW, O[12], clk);
  Regi_32 R13 (Q13, PW, O[13], clk);
  Regi_32 R14 (Q14, PW, O[14], clk);
  Mux_32 mux_A (PA, RA, Q0, Q1, Q2, Q3, Q4, Q5, Q6, Q7, Q8, Q9, Q10, Q11, Q12, Q13, Q14, PC);
  Mux_32 mux_B (PB, RB, Q0, Q1, Q2, Q3, Q4, Q5, Q6, Q7, Q8, Q9, Q10, Q11, Q12, Q13, Q14, PC);
  Mux_32 mux_D (PD, RD, Q0, Q1, Q2, Q3, Q4, Q5, Q6, Q7, Q8, Q9, Q10, Q11, Q12, Q13, Q14, PC);

endmodule

module Regi_32 (output reg [31:0] o_regi, input [31:0] i_regi, input
LE, Clk);
always @ (posedge Clk)
if (LE) o_regi <= i_regi;
endmodule

module bin_deco (output reg [15:0] o_deco , input [3:0] i_deco, input E );
always@* begin
    if (E) case (i_deco)
            5'd0: o_deco = 32'h1;
            5'd1: o_deco = 32'h2;
            5'd2: o_deco = 32'h4;
            5'd3: o_deco = 32'h8;
            5'd4: o_deco = 32'h10;
            5'd5: o_deco = 32'h20;
            5'd6: o_deco = 32'h40;
            5'd7: o_deco = 32'h80;
            5'd8: o_deco = 32'h100;
            5'd9: o_deco = 32'h200;
            5'd10: o_deco = 32'h400;
            5'd11: o_deco = 32'h800;
            5'd12: o_deco = 32'h1000;
            5'd13: o_deco = 32'h2000;
            5'd14: o_deco = 32'h4000;
            5'd15: o_deco = 32'h8000;
        endcase
        else o_deco = 32'h0;
    end
endmodule

module Mux_32 (output reg [31:0] o_mux, input [3:0] i_mux,
input [31:0] Z0, Z1, Z2, Z3, Z4, Z5, Z6, Z7, Z8, Z9, Z10, Z11, Z12, Z13, Z14, Z15);
always @ (i_mux , Z0, Z1, Z2, Z3, Z4, Z5, Z6, Z7, Z8, Z9, Z10, Z11, Z12, Z13, Z14, Z15)
    case (i_mux)
        5'b00000: o_mux = Z0;
        5'b00001: o_mux = Z1;
        5'b00010: o_mux = Z2;
        5'b00011: o_mux = Z3;
        5'b00100: o_mux = Z4;
        5'b00101: o_mux = Z5;
        5'b00110: o_mux = Z6;
        5'b00111: o_mux = Z7;
        5'b01000: o_mux = Z8;
        5'b01001: o_mux = Z9;
        5'b01010: o_mux = Z10;
        5'b01011: o_mux = Z11;
        5'b01100: o_mux = Z12;
        5'b01101: o_mux = Z13;
        5'b01110: o_mux = Z14;
        5'b01111: o_mux = Z15;
    endcase
endmodule