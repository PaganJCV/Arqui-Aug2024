`timescale 1ns / 1ps
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
            V = (!(OperandA[31] ^ OperandB[31]) &(OperandA[31] ^ result[31]));
        end
        4'b0001: begin
            {C, result} = OperandA + OperandB + c0; // Assuming 8-bit result with carry-in
            Z = (result == 0);
            N = (result[31] == 1);
            V = (!(OperandA[31] ^ OperandB[31]) &(OperandA[31] ^ result[31]));
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
            C = (OperandA < OperandB); // Assuming 8-bit result with borrow
            V = ((OperandA[31] ^ OperandB[31]) & (OperandA[31] ^ result[31]));
        end
        4'b0100: begin
            result = OperandB - OperandA;
            Z = (result == 0);
            N = (result[31] == 1);
         	  C = (OperandB < OperandA); // Assuming 8-bit result with borrow
            V = ((OperandB[31] ^ OperandA[31]) & (OperandB[31] ^ result[31]));
        end
        4'b0101: begin
            result = OperandB - OperandA - 1; // Subtract carry-in
            Z = (result == 0);
            N = (result[31] == 1);
          	C = (OperandB < OperandA); // Assuming 8-bit result with borrow
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
            result = OperandA; //RETURNS OperandA
            Z = (result == 0);
            N = (result[31] == 1);
            C = 0;
            V = 0;
        end
        4'b1010: begin
            result = OperandB; //RETURNS OperandB
            Z = (result == 0);
            N = (result[31] == 1);
            C = 0;
            V = 0;
        end
        4'b1011: begin
            result = ~OperandB; //NOT OperandB
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