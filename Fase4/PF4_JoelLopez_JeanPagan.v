
module mux_2x1 (output Y, input S, A, B);
assign Y = (S)? A:B;
endmodule

module mux_8x1(output [7:0] Y_8, input S_8, input [7:0] A_8, B_8);
  assign Y_8 = (S_8) ? A_8 : B_8;
endmodule


//MEM MUX
module mux_32x1 (output [31:0] Y_32, input [31:0] A_32, B_32, input S_32);
assign Y_32 = (S_32)? A_32:B_32;
endmodule

//(1) ID, (2) EX MUX
module mux_4x1(output [3:0] Y_4, input [3:0] A_4, B_4, input S_4);
assign Y_4 = (S_4)? A_4:B_4;
endmodule

module PC(
    input clk, R, LE,
    input [31:0] in_pc,
    output reg [31:0] out_pc
);
	
  always @(posedge clk) begin
    if(LE == 1 && R == 0) out_pc = in_pc;
    else if (R == 1) out_pc = 32'b0;
end

endmodule

module PC_adder(
    input [31:0] num,
    output reg [31:0] result
);

always @(num) result = num + 3'b100;

endmodule

module ROM(
    input [7:0] address,  
    output reg [31:0] instruction  
);
    reg [7:0] Mem [0:255];

    always @(address) begin
      instruction = {Mem[address], Mem[address+1], Mem[address+2], Mem[address+3]};
    end

endmodule

module IF_ID(
    input clk, R, R_B,
    input [31:0] next_pc,
  input [31:0] rom_instruction,
    input LE,
    output reg [23:0] I_23_0,
    output reg [3:0] I_19_16_Rn, I_3_0_Rm, I_15_12_Rd, I_31_28,
    output reg [11:0] I_11_0,
    output reg [31:0] ID_next_pc,
    output reg [31:0] Instruction
);

// normal run
  always @(posedge clk)begin
  if(R || R_B) begin
    I_23_0 <= 32'b0;
    I_19_16_Rn <= 4'b0;
    I_3_0_Rm <= 4'b0;
    I_15_12_Rd <= 4'b0;
    I_31_28 <= 4'b0;
  	I_11_0 <= 12'b0;
    ID_next_pc <= 32'b0;
    Instruction <= 32'b0;
  end
    else if(LE) begin
    I_23_0 <= rom_instruction[23:0];
    I_19_16_Rn <= rom_instruction[19:16];
    I_3_0_Rm <= rom_instruction[3:0];
    I_15_12_Rd <= rom_instruction[15:12];
    I_31_28 <= rom_instruction[31:28];
  	I_11_0 <= rom_instruction[11:0];
    ID_next_pc <= next_pc;
    Instruction <= rom_instruction;
end
  end

endmodule

module TA (
    input [23:0] in_I_23_0,
    input [31:0] in_next_pc,
    output reg [31:0] Target_add
);
reg [31:0] extended;
reg [31:0] I_23;
always @(*) begin
  I_23 = {8'b0, in_I_23_0};
  extended = $signed(I_23) << 2;
    Target_add = in_next_pc + extended;
end

endmodule

/////////REGISTER FILE/////////

module Register_File(
        input LE, clk, BranchL,
        input [31:0] PC,PW, next_pc,
        input [3:0] RD,RB,RA,RW,
        output [31:0] PD,PB,PA
        );

        wire [15:0] regnum;
        wire [31:0] Q0,Q1,Q2,Q3,Q4,Q5,Q6,Q7,Q8,Q9,Q10,Q11,Q12,Q13,Q14,Q15;
        decoder decoder1(.regnum(regnum),.LE(LE), .BranchL(BranchL), .RW(RW));

        register R0(.LE(regnum[0]), .clk(clk), .PW(PW), .Q(Q0));
        register R1(.LE(regnum[1]), .clk(clk), .PW(PW), .Q(Q1));
        register R2(.LE(regnum[2]), .clk(clk), .PW(PW), .Q(Q2));
        register R3(.LE(regnum[3]), .clk(clk), .PW(PW), .Q(Q3));
        register R4(.LE(regnum[4]), .clk(clk), .PW(PW), .Q(Q4));
        register R5(.LE(regnum[5]), .clk(clk), .PW(PW), .Q(Q5));
        register R6(.LE(regnum[6]), .clk(clk), .PW(PW), .Q(Q6));
        register R7(.LE(regnum[7]), .clk(clk), .PW(PW), .Q(Q7));
        register R8(.LE(regnum[8]), .clk(clk), .PW(PW), .Q(Q8));
        register R9(.LE(regnum[9]), .clk(clk), .PW(PW), .Q(Q9));
        register R10(.LE(regnum[10]), .clk(clk), .PW(PW), .Q(Q10));
        register R11(.LE(regnum[11]), .clk(clk), .PW(PW), .Q(Q11));
        register R12(.LE(regnum[12]), .clk(clk), .PW(PW), .Q(Q12));
        register R13(.LE(regnum[13]), .clk(clk), .PW(PW), .Q(Q13));
        register R14(.LE(regnum[14]), .clk(clk), .PW((BranchL) ? next_pc : PW), .Q(Q14));
        register R15(.LE(regnum[15]), .clk(clk), .PW(PC), .Q(Q15));

        in16out1mux mux1(.Y(PA),.R(RA),.Q0(Q0),.Q1(Q1),.Q2(Q2),.Q3(Q3),.Q4(Q4),.Q5(Q5),.Q6(Q6),.Q7(Q7),.Q8(Q8),.Q9(Q9),.Q10(Q10),.Q11(Q11),.Q12(Q12),.Q13(Q13),.Q14(Q14),.Q15(Q15));

        in16out1mux mux2(.Y(PB),.R(RB),.Q0(Q0),.Q1(Q1),.Q2(Q2),.Q3(Q3),.Q4(Q4),.Q5(Q5),.Q6(Q6),.Q7(Q7),.Q8(Q8),.Q9(Q9),.Q10(Q10),.Q11(Q11),.Q12(Q12),.Q13(Q13),.Q14(Q14),.Q15(Q15));

        in16out1mux mux3(.Y(PD),.R(RD),.Q0(Q0),.Q1(Q1),.Q2(Q2),.Q3(Q3),.Q4(Q4),.Q5(Q5),.Q6(Q6),.Q7(Q7),.Q8(Q8),.Q9(Q9),.Q10(Q10),.Q11(Q11),.Q12(Q12),.Q13(Q13),.Q14(Q14),.Q15(Q15));
    endmodule

    module decoder (
        output reg[15:0] regnum,
        input LE, BranchL,
        input [3:0] RW
        );
        always @(*)
            begin
               if(BranchL) regnum = 16'b0100000000000000; 
               else if(LE) begin
                    case(RW)
                    4'b0000: regnum = 16'b0000000000000001;
                    4'b0001: regnum = 16'b0000000000000010;
                    4'b0010: regnum = 16'b0000000000000100; 
                    4'b0011: regnum = 16'b0000000000001000; 
                    4'b0100: regnum = 16'b0000000000010000;
                    4'b0101: regnum = 16'b0000000000100000; 
                    4'b0110: regnum = 16'b0000000001000000; 
                    4'b0111: regnum = 16'b0000000010000000; 
                    4'b1000: regnum = 16'b0000000100000000; 
                    4'b1001: regnum = 16'b0000001000000000; 
                    4'b1010: regnum = 16'b0000010000000000; 
                    4'b1011: regnum = 16'b0000100000000000; 
                    4'b1100: regnum = 16'b0001000000000000; 
                    4'b1101: regnum = 16'b0010000000000000; 
                    4'b1110: regnum = 16'b0100000000000000;     
                    4'b1111: regnum = 16'b1000000000000000;
                endcase
            end else regnum = 16'b0000000000000000;
        end
    endmodule

    module in16out1mux(
        output reg [31:0] Y, 
        input [3:0] R,
        input [31:0] Q0,Q1,Q2,Q3,Q4,Q5,Q6,Q7,Q8,Q9,Q10,Q11,Q12,Q13,Q14,Q15
        );

        always @(*) begin
            case(R)
            4'b0000: Y = Q0;
            4'b0001: Y = Q1;
            4'b0010: Y = Q2;
            4'b0011: Y = Q3;
            4'b0100: Y = Q4;
            4'b0101: Y = Q5;
            4'b0110: Y = Q6;
            4'b0111: Y = Q7;
            4'b1000: Y = Q8;
            4'b1001: Y = Q9;
            4'b1010: Y = Q10;
            4'b1011: Y = Q11;
            4'b1100: Y = Q12;
            4'b1101: Y = Q13;
            4'b1110: Y = Q14;
            4'b1111: Y = Q15;
            endcase
        end
    endmodule

    module register(
        input LE, clk,
        input [31:0] PW,
        output reg[31:0] Q
        );

      always @(posedge clk) begin
            if(LE) begin 
                Q <= PW;
            end
        end
    endmodule

/////////REGISTER FILE/////////

//////////RF MUX////////////
module RF_big_mux(
    input [31:0] in_PX, EX_TO_ID_RD, MEM_TO_ID_RD, WB_TO_ID_RD,
    input [1:0] FW_ID_RX_MUX_SIGNAL,
    output reg [31:0] Px    
); 

always @(*) begin
    case(FW_ID_RX_MUX_SIGNAL)
        2'b00: begin 
            if(in_PX === 'bx) Px <= 32'b0;
            else Px <= in_PX;
        end
        2'b01: Px <= EX_TO_ID_RD;
        2'b10: Px <= MEM_TO_ID_RD;
        2'b11: Px <= WB_TO_ID_RD;
        default: Px <= in_PX;
    endcase
end

endmodule
////////////RF MUX///////////////

module Control_Unit(
  input [31:0] in_instruction,
  output reg[3:0] opcode,
  output reg [1:0] AM,
    output reg S_enable,
               load_instr,
               RF_enable,
               Size_enable,
               RW_enable,
               Enable_signal,
               BL_instr,
               B_instr,
    output reg [8*6-1:0] keyword  
);

always @(*) begin
    opcode = 4'b1110;
    AM = 2'b00;
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
         RF_enable = 1'b1;
         if(in_instruction == 32'b0) begin
            opcode = 4'b0000;
            RF_enable = 1'b0;
         end
            else opcode = 4'b0110; //And	
            if(in_instruction[20]) keyword = "ANDS";
            else keyword = "AND";
        end
        4'b0001: begin
            opcode = 4'b1000; //XOR
          RF_enable = 1'b1;
            if(in_instruction[20]) keyword = "EORS";
            else keyword = "EOR";
        end
        4'b0010: begin
            opcode = 4'b0010; //A-B
          RF_enable = 1'b1;
            if(in_instruction[20]) keyword = "SUBS";
            else keyword = "SUB";
        end
         4'b0011: begin
            opcode = 4'b0100; //B-A
           RF_enable = 1'b1;
            if(in_instruction[20]) keyword = "RSBS";
            else keyword = "RSB";
        end
        4'b0100: begin
            opcode = 4'b0000; //A+B
          RF_enable = 1'b1;
            if(in_instruction[20]) keyword = "ADDS";
            else keyword = "ADD";
        end
        4'b0101: begin
            opcode = 4'b0001; //A+B+Cin
          RF_enable = 1'b1;
            if(in_instruction[20]) keyword = "ADCS";
            else keyword = "ADC";
        end
         4'b0110: begin
            opcode = 4'b0011; //A-B-Cin
           RF_enable = 1'b1;
            if(in_instruction[20]) keyword = "SBCS";
            else keyword = "SBC";
        end
        4'b0111: begin
            opcode = 4'b0101; //B-A-Cin
          RF_enable = 1'b1;
            if(in_instruction[20]) keyword = "RSCS";
            else keyword = "RSC";
        end
        4'b1100: begin
            opcode = 4'b0111; //OR
          RF_enable = 1'b1;
            if(in_instruction[20]) keyword = "ORRS";
            else keyword = "ORR";
        end
        4'b1101: begin
            opcode = 4'b1010; //B
          RF_enable = 1'b1;
            if(in_instruction[20]) keyword = "MOVS";
            else keyword = "MOV";
        end
        4'b1110: begin
            opcode = 4'b1100; //A and (notB)
          RF_enable = 1'b1;
            if(in_instruction[20]) keyword = "BICS";
            else keyword = "BIC";
        end
        4'b1111: begin
            opcode = 4'b1011; //not B
          RF_enable = 1'b1;
            if(in_instruction[20]) keyword = "MVNS";
            else keyword = "MVN";
        end
        4'b1010: begin // Adding CMP
            opcode = 4'b0010; // Comparison (A - B)
            RF_enable = 1'b0; // Disable register write
            keyword = "CMP";
        end
        4'b1011: begin // Adding CMP
            opcode = 4'b0000; // Comparison (A - B)
            RF_enable = 1'b0; // Disable register write
            keyword = "CMN";
        end
    default: opcode = 4'b1001; //A
endcase
//Data processing in_instruction and bit 20 = 0, S_enable
if((in_instruction[27:25] == 3'b000) && (in_instruction[7] == 1'b0) && (in_instruction[4] == 1'b1) && (in_instruction[20] == 1'b0)) S_enable = 1'b0;
//Data processing in_instruction and bit 20 = 1, S_enable
else if((in_instruction[27:25] == 3'b000) && (in_instruction[7] == 1'b0) && (in_instruction[4] == 1'b1) && (in_instruction[20] == 1'b1)) S_enable = 1'b1;
//load/store in_instruction indicator
else if((in_instruction[27:25] == 3'b010) 
        || ((in_instruction[27:25] == 3'b011) && (in_instruction[4] == 1'b0)) 
        || (in_instruction[27:25] == 3'b100) 
        || ((in_instruction[27:25] == 3'b000) && (in_instruction[7] == 1'b1) && (in_instruction[4] == 1'b1))) begin
  //add or subs to determine the EA
  if(in_instruction[23]) opcode = 0000;
  else opcode = 0010;
            //load byte
  if(in_instruction[20] && in_instruction[22]) begin load_instr = 1'b1; Size_enable = 1'b0; RW_enable = 1'b0; Enable_signal = 1'b1; RF_enable = 1'b1; keyword = "LDRB"; end
            //load word
            else if(in_instruction[20] && !in_instruction[22]) begin load_instr = 1'b1; Size_enable = 1'b1; RW_enable = 1'b0; Enable_signal = 1'b1; RF_enable = 1'b1; keyword = "LDR"; end
            //store byte
            else if(!in_instruction[20] && in_instruction[22]) begin load_instr = 1'b0; Size_enable = 1'b0; RW_enable = 1'b1; Enable_signal = 1'b1; RF_enable = 1'b0; keyword = "STRB"; end
            //store word
            else if(!in_instruction[20] && !in_instruction[22]) begin load_instr = 1'b0; Size_enable = 1'b1; RW_enable = 1'b1; Enable_signal = 1'b1; RF_enable = 1'b0; keyword = "STR"; end
        end
//branch/branch and link
  else if(in_instruction[27:25] == 3'b101) begin
    if(!in_instruction[24]) begin B_instr = 1'b1; keyword = "B"; RF_enable = 1'b0; S_enable = 1'b0; end
    else begin BL_instr =1'b1; B_instr = 1'b1; keyword = "BL"; RF_enable = 1'b0; S_enable = 1'b0; end
    end
  else if(in_instruction == 32'b00000000000000000000000000000000) keyword = "NOP";
end

always @(*) begin 
    case(in_instruction[31:28])
    4'b0000: begin
      if(keyword[7:0] == 8'b01010011) begin 
            keyword = {keyword[8*6-1:0] >> 8};
            keyword = {keyword, "EQS"};
        end
      else if (in_instruction != 32'b0) keyword = {keyword, "EQ"};
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
    //4'b1110: begin
    //    if(keyword[7:0] == 8'b01010011) begin 
    //        keyword = {keyword[8*6-1:0] >> 8};
     //       keyword = {keyword, "ALS"};
     //   end
    //    else keyword = {keyword, "AL"};
    //end
    endcase 
  if((keyword == "CMP") || (keyword == "CMN")) S_enable = 1;
end
  
  always @(*) begin
    case ({in_instruction[27:25],in_instruction[4]})
        //data processing Immediate shift
        4'b0000: begin
          if(keyword == "NOP") AM = 2'b00;
          else AM = 2'b11;
        end
        //data processing register shift
        4'b0001: AM = 2'b11;

        //rotate 
        4'b0010: AM = 2'b00;

        4'b0011: AM = 2'b00;

        //register shift
        4'b0110: AM = 2'b11;
      

        //immediateoffset
        4'b0100: AM = 2'b10;
        4'b0101: AM = 2'b10;
	
    endcase
end

endmodule

module CU_mux(
    input S,
    input [3:0] mux_opcode,
  input [1:0] mux_AM,
    input mux_S_enable,
          mux_load_instr,
          mux_RF_enable,
          mux_Size_enable,
          mux_RW_enable,
          mux_Enable_signal,
          mux_BL_instr,
          mux_B_instr,
    output reg [3:0] ID_opcode,
  output reg [1:0] ID_AM,
    output reg ID_S_enable,
               ID_load_instr,
               ID_RF_enable,
               ID_Size_enable,
               ID_RW_enable,
               ID_Enable_signal,
               ID_BL_instr,
               ID_B_instr
);

  always @(*) begin
  if(S == 1'b1) begin
        ID_opcode <= 4'b0000;
        ID_AM <= 2'b00;
        ID_S_enable <= 1'b0;
        ID_load_instr <= 1'b0;
        ID_RF_enable <= 1'b0;
        ID_Size_enable <= 1'b0;
        ID_RW_enable <= 1'b0;
        ID_Enable_signal <= 1'b0;
        ID_BL_instr <= 1'b0;
        ID_B_instr <= 1'b0;
    end

    else begin
        ID_opcode <= mux_opcode;
        ID_AM <= mux_AM;
        ID_S_enable <= mux_S_enable;
        ID_load_instr <= mux_load_instr;
        ID_RF_enable <= mux_RF_enable;
        ID_Size_enable <= mux_Size_enable;
        ID_RW_enable <= mux_RW_enable;
        ID_Enable_signal <= mux_Enable_signal;
        ID_BL_instr <= mux_BL_instr;
        ID_B_instr <= mux_B_instr;
    end
end

endmodule

module ID_EX(
    input clk, R,
    input [31:0] in_next_pc,
    input [31:0] Pa, Pb, Pd,
    input [3:0] in_Rd_or_14,
    input [11:0] in_I_11_0,
    input [3:0] in_ID_opcode,
    input [1:0]in_ID_AM,
    input in_ID_S_enable,
          in_ID_load_instr,
          in_ID_RF_enable,
          in_ID_Size_enable,
          in_ID_RW_enable,
          in_ID_Enable_signal,
          in_BL_enable,
    output reg [31:0] EX_next_pc,
    output reg [31:0] EX_Pa, EX_Pb, EX_Pd,
    output reg [11:0] EX_I_11_0,
    output reg [3:0] EX_Rd_or_14,
    output reg [3:0] EX_opcode,
    output reg [1:0] EX_AM,
    output reg EX_S_enable,
          EX_load_instr,
          EX_RF_enable,
          EX_Size_enable,
          EX_RW_enable,
          EX_Enable_signal,
          EX_BL_enable
);

always @(posedge clk) begin
      if(R) begin
            EX_next_pc <= 32'b0;
            EX_Pa <= 32'b0;
            EX_Pb <= 32'b0;
            EX_Pd <= 32'b0;
            EX_Rd_or_14 <= 4'b0;
            EX_I_11_0 <= 12'b0;
            EX_opcode <= 4'b0000;
            EX_AM <= 2'b00;
            EX_S_enable <= 1'b0;
            EX_load_instr <= 1'b0;
            EX_RF_enable <= 1'b0;
            EX_Size_enable <= 1'b0;
            EX_RW_enable <= 1'b0;
            EX_Enable_signal <= 1'b0;
            EX_BL_enable <= 1'b0;
      end
      else begin
            EX_next_pc <= in_next_pc;
            EX_Pa <= Pa;
            EX_Pb <= Pb;
            EX_Pd <= Pd;
            EX_Rd_or_14 <= in_Rd_or_14;
            EX_I_11_0 <= in_I_11_0;
            EX_opcode <= in_ID_opcode;
            EX_AM <= in_ID_AM;
            EX_S_enable <= in_ID_S_enable;
            EX_load_instr <= in_ID_load_instr;
            EX_RF_enable <= in_ID_RF_enable;
            EX_Size_enable <= in_ID_Size_enable;
            EX_RW_enable <= in_ID_RW_enable;
            EX_Enable_signal <= in_ID_Enable_signal;
            EX_BL_enable <= in_BL_enable;
      end 
end

endmodule

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
            {C, result} <= OperandA + OperandB; 	
            Z <= (result == 0);
            N <= (result[31] == 1);
            V <= (~(OperandA[31] ^ OperandB[31]) & (OperandA[31] ^ result[31]));
        end
        4'b0001: begin
            {C, result} <= OperandA + OperandB + c0; // result with carry-in
            Z <= (result == 0);
            N <= (result[31] == 1);
            V <= (~(OperandA[31] ^ OperandB[31]) & (OperandA[31] ^ result[31]));
        end
        4'b0010: begin
            result <= OperandA - OperandB;
            Z <= (result == 0);
            N <= (result[31] == 1);
            C <= (OperandA < OperandB); 
            V <= ((OperandA[31] ^ OperandB[31]) & (OperandA[31] ^ result[31]));
        end
        4'b0011: begin
            result <= OperandA - OperandB - 1; // Subtract carry-in
            Z <= (result == 0);
            N <= (result[31] == 1);
            C <= (OperandA < OperandB); 
            V <= ((OperandA[31] ^ OperandB[31]) & (OperandA[31] ^ result[31]));
        end
        4'b0100: begin
            result <= OperandB - OperandA;
            Z <= (result == 0);
            N <= (result[31] == 1);
         	C <= (OperandB < OperandA);
            V <= ((OperandB[31] ^ OperandA[31]) & (OperandB[31] ^ result[31]));
        end
        4'b0101: begin
            result <= OperandB - OperandA - 1; // Subtract carry-in
            Z <= (result == 0);
            N <= (result[31] == 1);
          	C <= (OperandB < OperandA);
            V <= ((OperandB[31] ^ OperandA[31]) & (OperandB[31] ^ result[31]));
        end
        4'b0110: begin
            result <= OperandA & OperandB; //AND
            Z <= (result == 0);
            N <= (result[31] == 1);
            C <= 0;
            V <= 0;
        end
        4'b0111: begin
            result <= OperandA | OperandB; //OR
            Z <= (result == 0);
            N <= (result[31] == 1);
            C <= 0;
            V <= 0;
        end
        4'b1000: begin
            result <= OperandA ^ OperandB; //XOR
            Z <= (result == 0);
            N <= (result[31] == 1);
            C <= 0;
            V <= 0;
        end
        4'b1001: begin
            result <= OperandA; //OperandA
            Z <= (result == 0);
            N <= (result[31] == 1);
            C <= 0;
            V <= 0;
        end
        4'b1010: begin
            result <= OperandB; //OperandB
            Z <= (result == 0);
            N <= (result[31] == 1);
            C <= 0;
            V <= 0;
        end
        4'b1011: begin
            result <= ~OperandB; // not-OperandB
            Z <= (result == 0);
            N <= (result[31] == 1);
            C <= 0;
            V <= 0;
        end
        4'b1100: begin
            result <= OperandA & ~OperandB;
            Z <= (result == 0);
            N <= (result[31] == 1);
            C <= 0;
            V <= 0;
        end
        default: begin
            result <= 0;
            Z <= 1;
            N <= 0;
            C <= 0;
            V <= 0;
        end
    endcase
end

endmodule

module PSR(
    input clk, SE,
    input Z_in, N_in, C_in, V_in,
    output reg [3:0] PSR_flags // Combined register for flags [N, Z, C, V]
);

always @(posedge clk) begin
    if (SE) PSR_flags <= {N_in, Z_in, C_in, V_in};
    //else PSR_flags <= 4'b0000;
end

endmodule

module ConditionHandler (
    input [3:0] cond_code,      // Bits 28-31
    input [3:0] flags,          // Flags from PSR: [N, Z, C, V]
    input in_B_instr, in_BL_instr,      
    output reg Branch, BranchL 
);

    //Decode PSR flags
    wire N = flags[3];  // Negative
    wire Z = flags[2];  // Zero
    wire C = flags[1];  // Carry
    wire V = flags[0];  // Overflow

    reg cond_true;
    always @(*) begin
        case (cond_code)
            4'b0000: cond_true = Z;                 // EQ: Equal 
            4'b0001: cond_true = ~Z;                // NE: Not Equal 
            4'b0010: cond_true = C;                 // CS: Unsigned higher or same
            4'b0011: cond_true = ~C;                // CC: Unsigned Lower
            4'b0100: cond_true = N;                 // MI: Minus
            4'b0101: cond_true = ~N;                // PL: Positive or Zero
            4'b0110: cond_true = V;                 // VS: Overflow
            4'b0111: cond_true = ~V;                // VC: No Overflow
            4'b1000: cond_true = C & ~Z;            // HI: Unsigned Higher
            4'b1001: cond_true = ~C | Z;            // LS: Unsigned Lower or Same
            4'b1010: cond_true = N == V;            // GE: Greater or Equal
            4'b1011: cond_true = N != V;            // LT: Less Than
            4'b1100: cond_true = ~Z & (N == V);     // GT: Greater Than
            4'b1101: cond_true = Z | (N != V);      // LE: Less Than or Equal
            4'b1110: cond_true = 1'b1;              // AL: Always
            4'b1111: cond_true = 1'b0;              // NV: Never (not used)
            default: cond_true = 1'b0;              // Default to Never
        endcase
    end

    // Detect control hazard
    always @(*) begin
        Branch = 1'b0;
        BranchL = 1'b0;

      if (in_BL_instr && cond_true) begin
            Branch = 1'b1;
            BranchL = 1'b1;
        end
      else if (in_B_instr && cond_true) Branch = 1'b1;
    end

endmodule


module EX_MEM(
       input clk, R,
       input in_EX_load_instr,
          in_EX_RF_enable,
          in_EX_Size_enable,
          in_EX_RW_enable,
          in_EX_Enable_signal,
//    input ID_B_instr, ID_BL_instr,
       input [31:0] in_mux_NextPC_Out,
       input [31:0] in_EX_Pd,
       input [3:0] in_EX_Rd_or_14,
       output reg [31:0] mux_NextPC_Out,
       output reg [31:0] MEM_Pd,
       output reg [3:0] MEM_Rd_or_14,
       output reg MEM_load_instr,
          MEM_RF_enable,
          MEM_Size_enable,
          MEM_RW_enable,
          MEM_Enable_signal
);

always @(posedge clk) begin
    if(R) begin
        MEM_load_instr <= 1'b0;
        MEM_RF_enable <= 1'b0;
        MEM_Size_enable <= 1'b0;
        MEM_RW_enable <= 1'b0;
        MEM_Enable_signal <= 1'b0;
        mux_NextPC_Out <= 32'b0;
        MEM_Pd <= 32'b0;
        MEM_Rd_or_14 <= 4'b0;
    end
    else begin
        MEM_load_instr <= in_EX_load_instr;
        MEM_RF_enable <= in_EX_RF_enable;
        MEM_Size_enable <= in_EX_Size_enable;
        MEM_RW_enable <= in_EX_RW_enable;
        MEM_Enable_signal <= in_EX_Enable_signal;
        mux_NextPC_Out <= in_mux_NextPC_Out;
        MEM_Pd <= in_EX_Pd;
        MEM_Rd_or_14 <= in_EX_Rd_or_14;
    end
end

endmodule 

module ram256x8 (
    output reg [31:0] DO,
    input E, RW, Size,
    input [7:0] A, 
    input [31:0] DI
);
   reg[7:0] Mem[0:255];
   always@(A,E, RW)
     case(Size)
            1'b0:
                //Reading operation
              if (RW == 1'b0) DO <= {24'b000000000000000000000000, Mem[A]}; 
                
                //Writing Operation
                else if(RW == 1'b1 && E == 1'b1) Mem[A] <= DI[7:0];
            1'b1:
                //Reading operation
                if (RW == 1'b0) DO <= {Mem[A], Mem[A+1], Mem[A+2], Mem[A+3]}; //Reading operation
                
                //Writing Operation
                else if (RW == 1'b1 && E == 1'b1) begin 
                    Mem[A] <= DI[31:24];
                    Mem[A+1] <= DI[23:16];
                    Mem[A+2] <= DI[15:8];
                    Mem[A+3] <= DI[7:0];
                end
        endcase
endmodule

module MEM_WB(
    input clk, R,
    input in_MEM_RF_enable,
    //input [7:0] in_EA,
    input [3:0] in_MEM_Rd_or_14,
    input [31:0] in_MEM_DO,
    output reg [31:0] out_WB_DO,
    output reg [3:0] WB_Rd_or_14,
    output reg WB_RF_enable
);

always @(posedge clk) begin
    if(R) begin
        WB_RF_enable <= 1'b0;
        out_WB_DO <= 32'b0;
        WB_Rd_or_14 <= 4'b0;
    end
    else begin
        WB_RF_enable <= in_MEM_RF_enable;
        out_WB_DO <= in_MEM_DO;
        WB_Rd_or_14 <= in_MEM_Rd_or_14;
    end
end

endmodule

module ForwardingUnit (
    input [3:0] EX_RD, MEM_RD, WB_RD,
    ID_RM, ID_RN, ID_RD,
    input [1:0] ID_AM,
    input EX_RF_enable, MEM_RF_enable, WB_RF_enable,
    EX_load_instr, MEM_load_instr, 
    output reg FW_LE_SIGNAL, FW_CU_MUX_SIGNAL, FW_MEM_MUX_SIGNAL, R_EX,
    output reg [1:0] FW_ID_RM_MUX_SIGNAL, FW_ID_RN_MUX_SIGNAL, FW_ID_RD_MUX_SIGNAL,
    output reg [3:0] EX_TO_ID_RD, MEM_TO_ID_RD, WB_TO_ID_RD       
);
  
  // FOR LOAD INSTRUCTIONS
    always @(*) begin
        // Default values
        FW_LE_SIGNAL = 1'b1;
        FW_CU_MUX_SIGNAL = 1'b0;
        R_EX = 1'b0;

      if (EX_load_instr && ((ID_RN == EX_RD) || ((ID_RM == EX_RD) && (ID_AM != 2'b10 || ID_AM != 2'b00)))) begin
            FW_CU_MUX_SIGNAL = 1'b1; // Forwarding hazard detected
            FW_LE_SIGNAL = 1'b0;     // Disable LE
            R_EX = 1'b1;
        end
  else 

    // FOR RM
    
    if (EX_RF_enable && (ID_AM != 2'b10 || ID_AM != 2'b00) && (ID_RM == EX_RD)) begin
            EX_TO_ID_RD = EX_RD;
            FW_ID_RM_MUX_SIGNAL = 2'b01;  
        end else if (MEM_RF_enable && (ID_AM != 2'b10 || ID_AM != 2'b00) && (ID_RM == MEM_RD)) begin 
            MEM_TO_ID_RD = MEM_RD;
            FW_ID_RM_MUX_SIGNAL = 2'b10;
        end else if (WB_RF_enable && (ID_AM != 2'b10 || ID_AM != 2'b00) && (ID_RM == WB_RD)) begin 
            WB_TO_ID_RD = WB_RD;
            FW_ID_RM_MUX_SIGNAL = 2'b11;
        end else begin
            FW_ID_RM_MUX_SIGNAL = 2'b00; // Default
        end
    // FOR RN
   
        if (EX_RF_enable && (ID_RN == EX_RD)) begin
            EX_TO_ID_RD = EX_RD;
            FW_ID_RN_MUX_SIGNAL = 2'b01;  
        end else if (MEM_RF_enable && (ID_RN == MEM_RD)) begin 
            MEM_TO_ID_RD = MEM_RD;
            FW_ID_RN_MUX_SIGNAL = 2'b10;
        end else if (WB_RF_enable && (ID_RN == WB_RD)) begin 
            WB_TO_ID_RD = WB_RD;
            FW_ID_RN_MUX_SIGNAL = 2'b11;
        end else begin
            FW_ID_RN_MUX_SIGNAL = 2'b00; // Default
        end
    


    // FOR RD
	
        if (EX_RF_enable && (ID_RD == EX_RD)) begin
            EX_TO_ID_RD = EX_RD;
            FW_ID_RD_MUX_SIGNAL = 2'b01;  
        end else if (MEM_RF_enable && (ID_RD == MEM_RD)) begin 
            MEM_TO_ID_RD = MEM_RD;
            FW_ID_RD_MUX_SIGNAL = 2'b10;
        end else if (WB_RF_enable && (ID_RD == WB_RD)) begin 
            WB_TO_ID_RD = WB_RD;
            FW_ID_RD_MUX_SIGNAL = 2'b11;
        end else begin
            FW_ID_RD_MUX_SIGNAL = 2'b00; // Default
        end
    end

        

endmodule