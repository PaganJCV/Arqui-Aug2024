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

always @(*) begin
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
//Data processing instruction and bit 20 = 0, S_enable
if((instruction[27:25] == 3'b000) && (instruction[7] == 1'b0) && (instruction[4] == 1'b1) && (instruction[20] == 1'b0)) S_enable = 1'b0;

//load/store instruction indicator
else if((instruction[27:25] == 3'b010) 
        || ((instruction[27:25] == 3'b011) && (instruction[4] == 1'b0)) 
        || (instruction[27:25] == 3'b100) 
        || ((instruction[27:25] == 3'b000) && (instruction[7] == 1'b1) && (instruction[4] == 1'b1))) begin
            //load word
            if(instruction[20] && instruction[22]) begin load_instr = 1'b1; Size_enable = 1'b0; RW_enable = 1'b0; Enable_signal = 1'b1; RF_enable = 1'b1; end
            //load byte
            else if(instruction[20] && !instruction[22]) begin load_instr = 1'b1; Size_enable = 1'b1; RW_enable = 1'b0; Enable_signal = 1'b1; RF_enable = 1'b1; end
            //store word
            else if(!instruction[20] && instruction[22]) begin load_instr = 1'b0; Size_enable = 1'b0; RW_enable = 1'b0; Enable_signal = 1'b1; RF_enable = 1'b1; end
            //store byte
            else if(!instruction[20] && !instruction[22]) begin load_instr = 1'b0; Size_enable = 1'b1; RW_enable = 1'b0; Enable_signal = 1'b1; RF_enable = 1'b1; end
        end
//branch/branch and link
else if(instruction[27:25] == 101) begin
    if(instruction[24]) B_instr = 1'b1;
    else BL_instr =1'b1;
    end
default: begin
    opcode = 4'1110;
    AM = 1'b0;
    S_enable = 1'b0;
    load_instr = 1'b0;
    RF_enable = 1'b0;
    Size_enable = 1'b0;
    RW_enable = 1'b0;
    Enable_signal = 1'b0;
    BL_instr = 1'b0;
    B_instr = 1'b0;
end
end

endmodule