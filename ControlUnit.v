module Control_Unit(
  input [31:0] in_instruction,
  output reg[3:0] opcode,
    output reg AM,
               S_enable,
               load_instr,
               RF_enable,
               Size_enable,
               RW_enable,
               Enable_signal,
               BL_instr,
               B_instr,
    output reg reg [8*6-1:0] keyword  
);

always @(*) begin
  opcode = 4'b1110;
    AM = 1'b0;
    S_enable = 1'b0;
    load_instr = 1'b0;
    RF_enable = 1'b0;
    Size_enable = 1'b0;
    RW_enable = 1'b0;
    Enable_signal = 1'b0;
    BL_instr = 1'b0;
    B_instr = 1'b0;
//signals definition
  case(in_instruction[24:21])
        4'b0000: begin
            opcode = 4'b0110; //And	
            if(in_instruction[20]) keyword = "ANDS";
            else keyword = "AND";
        end
        4'b0001: begin
            opcode = 4'b1000; //XOR
            if(in_instruction[20]) keyword = "EORS";
            else keyword = "EOR";
        end
        4'b0010: begin
            opcode = 4'b0010; //A-B
            if(in_instruction[20]) keyword = "SUBS";
            else keyword = "SUB";
        end
         4'b0011: begin
            opcode = 4'b0100; //B-A
            if(in_instruction[20]) keyword = "RSBS";
            else keyword = "RSB";
        end
        4'b0100: begin
            opcode = 4'b0000; //A+B
            if(in_instruction[20]) keyword = "ADDS";
            else keyword = "ADD";
        end
        4'b0101: begin
            opcode = 4'b0001; //A+B+Cin
            if(in_instruction[20]) keyword = "ADCS";
            else keyword = "ADC";
        end
         4'b0110: begin
            opcode = 4'b0011; //A-B-Cin
            if(in_instruction[20]) keyword = "SBCS";
            else keyword = "SBC";
        end
        4'b0111: begin
            opcode = 4'b0101; //B-A-Cin
            if(in_instruction[20]) keyword = "RSCS";
            else keyword = "RSC";
        end
        4'b1100: begin
            opcode = 4'b0111; //OR
            if(in_instruction[20]) keyword = "ORRS";
            else keyword = "ORR";
        end
        4'b1101: begin
            opcode = 4'b1010; //B
            if(in_instruction[20]) keyword = "MOVS";
            else keyword = "MOV";
        end
        4'b1110: begin
            opcode = 4'b1100; //A and (notB)
            if(in_instruction[20]) keyword = "BICS";
            else keyword = "BIC";
        end
        4'b1111: begin
            opcode = 4'b1011; //not B
            if(in_instruction[20]) keyword = "MVNS";
            else keyword = "MVN";
        end
    default: opcode = 4'b1001; //A
endcase
//Data processing in_instruction and bit 20 = 0, S_enable
if((in_instruction[27:25] == 3'b000) && (in_instruction[7] == 1'b0) && (in_instruction[4] == 1'b1) && (in_instruction[20] == 1'b0)) S_enable = 1'b0;

//load/store in_instruction indicator
else if((in_instruction[27:25] == 3'b010) 
        || ((in_instruction[27:25] == 3'b011) && (in_instruction[4] == 1'b0)) 
        || (in_instruction[27:25] == 3'b100) 
        || ((in_instruction[27:25] == 3'b000) && (in_instruction[7] == 1'b1) && (in_instruction[4] == 1'b1))) begin
            //load word
  if(in_instruction[20] && in_instruction[22]) begin load_instr = 1'b1; Size_enable = 1'b1; RW_enable = 1'b0; Enable_signal = 1'b1; RF_enable = 1'b1; keyword = "LDR"; end
            //load byte
            else if(in_instruction[20] && !in_instruction[22]) begin load_instr = 1'b1; Size_enable = 1'b0; RW_enable = 1'b0; Enable_signal = 1'b1; RF_enable = 1'b1; keyword = "LDRB"; end
            //store word
            else if(!in_instruction[20] && in_instruction[22]) begin load_instr = 1'b0; Size_enable = 1'b1; RW_enable = 1'b1; Enable_signal = 1'b1; RF_enable = 1'b1; keyword = "STR"; end
            //store byte
            else if(!in_instruction[20] && !in_instruction[22]) begin load_instr = 1'b0; Size_enable = 1'b0; RW_enable = 1'b1; Enable_signal = 1'b1; RF_enable = 1'b1; keyword = "STRB"; end
        end
//branch/branch and link
  else if(in_instruction[27:25] == 3'b101) begin
    if(in_instruction[24]) begin B_instr = 1'b1; keyword = "B"; end
    else begin BL_instr =1'b1; keyword = "BL"; end
    end
   else if(in_instruction = 32'b00000000000000000000000000000000) keyword = "NOP";
end

always @(*) begin 
    case(in_instruction[31:28])
    4'b0000: begin
        if(keyword[7:0] == 8'b01010011) begin 
            keyword = {keyword[8*6-1:0] >> 8};
            keyword = {keyword, "EQS"};
        end
        else keyword = {keyword, "EQ"};
    end
    4'b0001: begin
        if(keyword[7:0] == 8'b01010011) begin 
            keyword = {keyword[8*6-1:0] >> 8};
            keyword = {keyword, "NES"};
        end
        else keyword = {keyword, "NE"};
    end
    // 4'b0010: begin
    //     if(keyword[7:0] == 8'b01010011) begin 
    //         keyword = {keyword[8*6-1:0] >> 8};
    //         keyword = {keyword, "CS/HSS"};
    //     end
    //     else keyword = {keyword, "CS/HS"};
    // end
    // 4'b0011: begin
    //     if(keyword[7:0] == 8'b01010011) begin 
    //         keyword = {keyword[8*6-1:0] >> 8};
    //         keyword = {keyword, "CC/LOS"};
    //     end
    //     else keyword = {keyword, "CC/LO"};
    // end
    4'b0100: begin
        if(keyword[7:0] == 8'b01010011) begin 
            keyword = {keyword[8*6-1:0] >> 8};
            keyword = {keyword, "MIS"};
        end
        else keyword = {keyword, "MI"};
    end
    4'b0101: begin
        if(keyword[7:0] == 8'b01010011) begin 
            keyword = {keyword[8*6-1:0] >> 8};
            keyword = {keyword, "PLS"};
        end
        else keyword = {keyword, "PL"};
    end
    4'b0110: begin
        if(keyword[7:0] == 8'b01010011) begin 
            keyword = {keyword[8*6-1:0] >> 8};
            keyword = {keyword, "VSS"};
        end
        else keyword = {keyword, "VS"};
    end
    4'b0111: begin
        if(keyword[7:0] == 8'b01010011) begin 
            keyword = {keyword[8*6-1:0] >> 8};
            keyword = {keyword, "VCS"};
        end
        else keyword = {keyword, "VC"};
    end
    4'b1000: begin
        if(keyword[7:0] == 8'b01010011) begin 
            keyword = {keyword[8*6-1:0] >> 8};
            keyword = {keyword, "HIS"};
        end
        else keyword = {keyword, "HI"};
    end
    4'b1001: begin
        if(keyword[7:0] == 8'b01010011) begin 
            keyword = {keyword[8*6-1:0] >> 8};
            keyword = {keyword, "LSS"};
        end
        else keyword = {keyword, "LS"};
    end
    4'b1010: begin
        if(keyword[7:0] == 8'b01010011) begin 
            keyword = {keyword[8*6-1:0] >> 8};
            keyword = {keyword, "GES"};
        end
        else keyword = {keyword, "GE"};
    end
    4'b1011: begin
        if(keyword[7:0] == 8'b01010011) begin 
            keyword = {keyword[8*6-1:0] >> 8};
            keyword = {keyword, "LTS"};
        end
        else keyword = {keyword, "LT"};
    end
    4'b1100: begin
        if(keyword[7:0] == 8'b01010011) begin 
            keyword = {keyword[8*6-1:0] >> 8};
            keyword = {keyword, "GTS"};
        end
        else keyword = {keyword, "GT"};
    end
    4'b1101: begin
        if(keyword[7:0] == 8'b01010011) begin 
            keyword = {keyword[8*6-1:0] >> 8};
            keyword = {keyword, "LES"};
        end
        else keyword = {keyword, "LE"};
    end
    4'b1110: begin
        if(keyword[7:0] == 8'b01010011) begin 
            keyword = {keyword[8*6-1:0] >> 8};
            keyword = {keyword, "ALS"};
        end
        else keyword = {keyword, "AL"};
    end
    endcase 
end

endmodule
