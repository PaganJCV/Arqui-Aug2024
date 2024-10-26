module Shifter_tb;
    // Inputs
    reg [31:0] Rm;
    reg [11:0] I;
    reg [1:0] AM;

    // Outputs
    wire [31:0] N_Shift;

    // Instantiate the Shifter module
    Shifter testbench_shifter(
        .Rm(Rm), 
        .I(I), 
        .AM(AM), 
        .N_Shift(N_Shift)
    );

    initial begin
        // Initialize inputs
        Rm = 32'b00000100001100011111111111101010;  // Test value for Rm
        I = 12'b010000001100;          // Test Value for I
        AM = 2'b00;         // Starting value for AM

        #10;
        $display("AM = %b | N = %b | I = %b", AM, N, I);

        // Test AM = 01 (Pass Rm)
        AM = 2'b01;
        #10;
        $display("AM = %b | N = %b | I = %b", AM, N_Shift, I);

        // Test AM = 10 (Immediate value {0b00000000000000000000, I})
        AM = 2'b10;
        #10;
        $display("AM = %b | N = %b | I = %b", AM, N_Shift, I);

        // Test AM = 11 with 00 (Logical Shift Left)
        I = 12'b000100000100;  // I[11:7] 
        AM = 2'b11;
        #10;
        $display("AM = %b | I[6:5] = %b | N = %b | I = %b", AM , I[6:5], N_Shift, I);

        // Test AM = 11 with 01 (Logical Shift Right)
        I = 12'b000100100100;  // I[11:7] 
        AM = 2'b11;
        #10;
        $display("AM = %b | I[6:5] = %b | N = %b | I = %b", AM , I[6:5], N_Shift, I);

        // Test AM = 11 with 10 (Arithmetic Shift Right)
        I = 12'b000101000100;  // I[11:7] 
        AM = 2'b11;
        #10;
        $display("AM = %b | I[6:5] = %b | N = %b | I = %b", AM , I[6:5], N_Shift, I);

        // Test AM = 11 with 11 (Rotate Right)
        I = 12'b000101100100;  // I[11:7]
        AM = 2'b11;
        #10;
        $display("AM = %b | I[6:5] = %b | N = %b | I = %b", AM , I[6:5], N_Shift, I);

        #10
        // Test complete
        $finish;
    end
endmodule
