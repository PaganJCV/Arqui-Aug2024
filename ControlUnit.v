module Control_Unit(
    input [31:0] instruction;
    output reg[3:0] opcode;
    output reg AM,
               S_enable,
               load_instr,
               RF_enable,
               Size_enable,
               RW_enable,
               Enable_signal,
               BL_instr,
               B_instr
);

always @(posedge clk) begin
//signals definition
case(instruction[24-21])
        default: result = A; 
        4'b0000: begin
            opcode = 4'b0110; //And	
        end
        4'b0001: begin
            opcode = 4'b1000; //XOR
        end
        4'b0010: begin
            opcode = 4'b0010; //A-B
        end
         4'b0011: begin
            opcode = 4'b0100; //B-A
        end
        4'b0100: begin
            opcode = 4'b0000; //A+B
        end
        4'b0101: begin
            opcode = 4'b0001; //A+B+Cin
        end
         4'b0110: begin
            opcode = 4'b0011; //A-B-Cin
        end
        4'b0111: begin
            opcode = 4'b0101; //B-A-Cin
        end
        4'b1100: begin
            opcode = 4'b0111; //OR
        end
        4'b1101: begin
            opcode = 4'b1010; //B
        end
        4'b1110: begin
            opcode = 4'b1100; //A and (notB)
        end
        4'b1111: begin
            opcode = 4'b1011; //not B
        end
endcase
end

endmodule