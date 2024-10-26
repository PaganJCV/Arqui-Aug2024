module Shifter(
    input [31:0] Rm, 
    input [11:0] I,
    input [1:0] AM,
    output reg [31:0] N_Shift
);

always @(*) begin
    case(AM)
        2'b00: begin
         N_Shift = ({3'b000, I[7:0]} >> (2 * I[11:8])) | ({3'b000, I[7:0]} << (32 - (2 * I[11:8])));
        end
        2'b01: begin
        N_Shift = Rm;
        end
        2'b10: begin
        N_Shift = {20'b00000000000000000000,I};
        end
        2'b11:
      begin
        case(I[6:5])
          2'b00: begin
            N_Shift = Rm << I[11:7]; //LSL
          end
          2'b01: begin
            N_Shift = Rm >> I[11:7]; //LSR
          end
          2'b10: begin  
            N_Shift = $signed(Rm) >>> I[11:7]; //ASR
          end
          2'b11: begin 
            N_Shift = (Rm >> I[11:7]) | (Rm << (32-I[11:7])); //ROR
          end
        endcase
      end
    endcase
  end
endmodule

module alu(
    input [3:0] opcode,
    input [31:0] OperandA, 
    input [31:0] OperandB,
    input c0,              // Carry-in input
    output reg [31:0] result,
    output reg Z, N, C, V   // Status flags
);

always @(*) begin
    case(opcode)
        4'b0000: begin
            {C, result} = OperandA + OperandB; 	
            Z = (result == 0);
            N = (result[31] == 1);
            V = (~(OperandA[31] ^ OperandB[31]) & (OperandA[31] ^ result[31]));
        end
        4'b0001: begin
            {C, result} = OperandA + OperandB + c0; // result with carry-in
            Z = (result == 0);
            N = (result[31] == 1);
            V = (~(OperandA[31] ^ OperandB[31]) & (OperandA[31] ^ result[31]));
        end
        4'b0010: begin
            result = OperandA - OperandB;
            Z = (result == 0);
            N = (result[31] == 1);
            C = (OperandA < OperandB); 
            V = ((OperandA[31] ^ OperandB[31]) & (OperandA[31] ^ result[31]));
        end
        4'b0011: begin
            result = OperandA - OperandB - 1; // Subtract carry-in
            Z = (result == 0);
            N = (result[31] == 1);
            C = (OperandA < OperandB); 
            V = ((OperandA[31] ^ OperandB[31]) & (OperandA[31] ^ result[31]));
        end
        4'b0100: begin
            result = OperandB - OperandA;
            Z = (result == 0);
            N = (result[31] == 1);
         	  C = (OperandB < OperandA);
            V = ((OperandB[31] ^ OperandA[31]) & (OperandB[31] ^ result[31]));
        end
        4'b0101: begin
            result = OperandB - OperandA - 1; // Subtract carry-in
            Z = (result == 0);
            N = (result[31] == 1);
          	C = (OperandB < OperandA);
            V = ((OperandB[31] ^ OperandA[31]) & (OperandB[31] ^ result[31]));
        end
        4'b0110: begin
            result = OperandA & OperandB; //AND
            Z = (result == 0);
            N = (result[31] == 1);
            C = 0;
            V = 0;
        end
        4'b0111: begin
            result = OperandA | OperandB; //OR
            Z = (result == 0);
            N = (result[31] == 1);
            C = 0;
            V = 0;
        end
        4'b1000: begin
            result = OperandA ^ OperandB; //XOR
            Z = (result == 0);
            N = (result[31] == 1);
            C = 0;
            V = 0;
        end
        4'b1001: begin
            result = OperandA; //OperandA
            Z = (result == 0);
            N = (result[31] == 1);
            C = 0;
            V = 0;
        end
        4'b1010: begin
            result = OperandB; //OperandB
            Z = (result == 0);
            N = (result[31] == 1);
            C = 0;
            V = 0;
        end
        4'b1011: begin
            result = ~OperandB; // not-OperandB
            Z = (result == 0);
            N = (result[31] == 1);
            C = 0;
            V = 0;
        end
        4'b1100: begin
            result = OperandA & ~OperandB;
            Z = (result == 0);
            N = (result[31] == 1);
            C = 0;
            V = 0;
        end
        default: begin
            result = 0;
            Z = 1;
            N = 0;
            C = 0;
            V = 0;
        end
    endcase
end

endmodule

module alu_tb;

// Inputs
reg [3:0] opcode;
reg [31:0] OperandA;
reg [31:0] OperandB;
reg c0;

// Outputs
wire [31:0] result;
wire Z, N, C, V;

alu testbench_ALU(
    .opcode(opcode), 
    .OperandA(OperandA), 
    .OperandB(OperandB), 
    .c0(c0), 
    .result(result), 
    .Z(Z), 
    .N(N), 
    .C(C), 
    .V(V)
);
initial begin
    // Initialize Inputs
    OperandA = 32'b10011100000000000000000000111000; // Test large value for OperandA
    OperandB = 32'b10011100000000000000000000111000; // Small value for OperandB
    c0 = 1'b0; // No carry-in initially
    opcode = 4'b0000;

    // Sequential block to ensure correct execution order
    begin
        repeat (13) begin 
            #2 $display("OPCODE = %b | A = %bb , %dd | B = %bb , %dd | RESULT = %bb , %dd | Flags Z = %b, N = %b, C = %b, V = %b", opcode, OperandA, OperandA, OperandB, OperandB, result, result , Z, N, C, V);
            opcode = opcode + 4'b001;
        end
    end

    // Change CIN and repeat
    c0 = 1'b1;
    opcode = 4'b0000;
    
    repeat (6) begin    
        #2 $display("OPCODE = %b | A = %bb , %dd | B = %bb , %dd | RESULT = %bb , %dd | Flags Z = %b, N = %b, C = %b, V = %b", opcode, OperandA, OperandA, OperandB, OperandB, result, result , Z, N, C, V);
        opcode = opcode + 4'b001;
    end
end

endmodule

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
        #100 //delay to show shifter test after alu is done displaying
        Rm = 32'b10000100001100011111111111101010;  // Test value for Rm
        I = 12'b010000001100;          // Test Value for I
        AM = 2'b00;         // Starting value for AM

        #10;
        $display("AM = %b | N = %b | I = %b", AM, N_Shift, I);

        // Test AM = 01 (Pass Rm)
        AM = 2'b01;
        #10;
        $display("AM = %b | N = %b | I = %b", AM, N_Shift, I);

        // Test AM = 10 (Immediate value {0b00000000000000000000, I})
        AM = 2'b10;
        #10;
        $display("AM = %b | N = %b | I = %b", AM, N_Shift, I);

        // Test AM = 11 with 00 (Logical Shift Left)
        AM = 2'b11;
        #10;
        $display("AM = %b | I[6:5] = %b | N = %b | I = %b", AM , I[6:5], N_Shift, I);

        $display("----------------------Additional Tests with AM = 11 and different cases of shift-------------------------");
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
