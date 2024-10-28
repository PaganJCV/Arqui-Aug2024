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