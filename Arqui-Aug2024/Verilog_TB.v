`timescale 1ns / 1ps
module alu_tb;

// Inputs
reg [3:0] opcode;
reg [31:0] OperandA;
reg [31:0] OperandB;
reg c0;

// Outputs
wire [31:0] result;
wire Z, N, C, V;

// Instantiate the Unit Under Test (UUT)
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
    OperandB = 32'b01110000000000000000000000000011; // Small value for OperandB
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

    // Finish simulation
    #10 $finish;
end

endmodule