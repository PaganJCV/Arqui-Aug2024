module shifter_sign_extender (
    input [31:0] Rm,
    input [11:0] I,
    input [1:0] MA, // Add MA input
    output [31:0] N
);

// ... (Rest of the code remains the same)

// Shift operations with MA
assign shifted_left = Rm << (shift_amt + (MA << 1));
assign shifted_right_logical = Rm >> (shift_amt + (MA << 1));
assign shifted_right_arithmetic = $signed(Rm) >>> (shift_amt + (MA << 1));
assign sign_extended = $signed(Rm) << (32 - (shift_amt + (MA << 1)));

assign N = (I[6:5] == 2'b00) ? shifted_left :
           (I[6:5] == 2'b01) ? shifted_right_logical :
           (I[6:5] == 2'b10) ? shifted_right_arithmetic :
           (I[6:5] == 2'b11) ? sign_extended :
           32'b0; // Default to zero if opcode is invalid
endmodule