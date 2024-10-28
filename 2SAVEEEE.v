module PC(
    input clk, R, LE,
    input [7:0] in_pc,
    output reg [7:0] out_pc
);

always @(posedge clk) begin
  if(LE == 1 && R == 0) out_pc = in_pc;
  else if (R == 1) out_pc = 8'b00000000;
end

endmodule

module PC_adder(
    input [7:0] num,
    output reg [7:0] result
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
    input clk, R,
    // input pc_plus_4;
  input [31:0] rom_instruction,
    input LE,
    // output reg [23:0] I_23_0;
    // output reg next_pc;
    // output reg [3:0] I_19_16_Rn, I_3_0_Rm, I_15_12_Rd, I_31_28;
    // output reg [11:0] I_11_0;
    output reg [31:0] Instruction
);

// normal run
always @(posedge clk)begin
    if(R) Instruction <= 32'b00000000000000000000000000000000;
    else if(LE)
    // I_23_0 <= rom_instruction[23:0];
    // I_19_16_Rn <= rom_instruction[19:16];
    // I_3_0_Rm <= rom_instruction[15:12];
    // I_31_28 <= rom_instruction[31:28];
    // next_pc <= pc_plus_4;
    Instruction <= rom_instruction;
end

endmodule

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
               B_instr
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
            RF_enable = 1'b1;
        end
        4'b0001: begin
            opcode = 4'b1000; //XOR
            RF_enable = 1'b1;
        end
        4'b0010: begin
            opcode = 4'b0010; //A-B
            RF_enable = 1'b1;
        end
         4'b0011: begin
            opcode = 4'b0100; //B-A
            RF_enable = 1'b1;
        end
        4'b0100: begin
            opcode = 4'b0000; //A+B
            RF_enable = 1'b1;
        end
        4'b0101: begin
            opcode = 4'b0001; //A+B+Cin
            RF_enable = 1'b1;
        end
         4'b0110: begin
            opcode = 4'b0011; //A-B-Cin
            RF_enable = 1'b1;
        end
        4'b0111: begin
            opcode = 4'b0101; //B-A-Cin
            RF_enable = 1'b1;
        end
        4'b1100: begin
            opcode = 4'b0111; //OR
            RF_enable = 1'b1;
        end
        4'b1101: begin
            opcode = 4'b1010; //B
            RF_enable = 1'b1;
        end
        4'b1110: begin
            opcode = 4'b1100; //A and (notB)
            RF_enable = 1'b1;
        end
        4'b1111: begin
            opcode = 4'b1011; //not B
            RF_enable = 1'b1;

        end
    default: begin
    opcode = 4'b1001; 
    RF_enable = 1'b1;//A
    end
endcase
//Data processing in_instruction and bit 20 = 0, S_enable
if((in_instruction[27:25] == 3'b000) && (in_instruction[7] == 1'b0) && (in_instruction[4] == 1'b1) && (in_instruction[20] == 1'b0)) S_enable = 1'b0;

//load/store in_instruction indicator
else if((in_instruction[27:25] == 3'b010) 
        || ((in_instruction[27:25] == 3'b011) && (in_instruction[4] == 1'b0)) 
        || (in_instruction[27:25] == 3'b100) 
        || ((in_instruction[27:25] == 3'b000) && (in_instruction[7] == 1'b1) && (in_instruction[4] == 1'b1))) begin
            //load word
            if(in_instruction[20] && in_instruction[22]) begin load_instr = 1'b1; Size_enable = 1'b0; RW_enable = 1'b0; Enable_signal = 1'b1; RF_enable = 1'b1; end
            //load byte
            else if(in_instruction[20] && !in_instruction[22]) begin load_instr = 1'b1; Size_enable = 1'b1; RW_enable = 1'b0; Enable_signal = 1'b1; RF_enable = 1'b1; end
            //store word
            else if(!in_instruction[20] && in_instruction[22]) begin load_instr = 1'b0; Size_enable = 1'b0; RW_enable = 1'b0; Enable_signal = 1'b1; RF_enable = 1'b1; end
            //store byte
            else if(!in_instruction[20] && !in_instruction[22]) begin load_instr = 1'b0; Size_enable = 1'b1; RW_enable = 1'b0; Enable_signal = 1'b1; RF_enable = 1'b1; end
        end
//branch/branch and link
  else if(in_instruction[27:25] == 3'b101) begin
    if(in_instruction[24]) B_instr = 1'b1;
    else BL_instr =1'b1;
    end
end

endmodule

module CU_mux(
    input S,
    input [3:0] mux_opcode,
    input mux_AM,
          mux_S_enable,
          mux_load_instr,
          mux_RF_enable,
          mux_Size_enable,
          mux_RW_enable,
          mux_Enable_signal,
          mux_BL_instr,
          mux_B_instr,
    output reg [3:0] ID_opcode,
    output reg ID_AM,
               ID_S_enable,
               ID_load_instr,
               ID_RF_enable,
               ID_Size_enable,
               ID_RW_enable,
               ID_Enable_signal,
               ID_BL_instr,
               ID_B_instr
);

always @(*) begin
    if(S) begin
        ID_opcode = 4'b0000;
        ID_AM = 1'b0;
        ID_S_enable = 1'b0;
        ID_load_instr = 1'b0;
        ID_RF_enable = 1'b0;
        ID_Size_enable = 1'b0;
        ID_RW_enable = 1'b0;
        ID_Enable_signal = 1'b0;
        ID_BL_instr = 1'b0;
        ID_B_instr = 1'b0;
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
//     input next_pc;
//     input [3:0] Pa, Pb, Pd;
//     input [3:0] Rd_or_14;
//     input [11:0] I_11_0;
  input [3:0] in_ID_opcode,
    input in_ID_AM,
          in_ID_S_enable,
          in_ID_load_instr,
          in_ID_RF_enable,
          in_ID_Size_enable,
          in_ID_RW_enable,
          in_ID_Enable_signal,
//     output reg EX_next_pc;
//     output reg [3:0] EX_Pa, EX_Pb, EX_Pd;
//     output reg [11:0] EX_I_11_0;
//     output reg [3:0] EX_Rd_or_14;
  output reg [3:0] EX_opcode,
    output reg EX_AM,
          EX_S_enable,
          EX_load_instr,
          EX_RF_enable,
          EX_Size_enable,
          EX_RW_enable,
          EX_Enable_signal
);

always @(posedge clk) begin
      if(R) begin
            EX_opcode <= 4'b0000;
            EX_AM <= 1'b0;
            EX_S_enable <= 1'b0;
            EX_load_instr <= 1'b0;
            EX_RF_enable <= 1'b0;
            EX_Size_enable <= 1'b0;
            EX_RW_enable <= 1'b0;
            EX_Enable_signal <= 1'b0;
      end
      else begin
            EX_opcode <= in_ID_opcode;
            EX_AM <= in_ID_AM;
            EX_S_enable <= in_ID_S_enable;
            EX_load_instr <= in_ID_load_instr;
            EX_RF_enable <= in_ID_RF_enable;
            EX_Size_enable <= in_ID_Size_enable;
            EX_RW_enable <= in_ID_RW_enable;
            EX_Enable_signal <= in_ID_Enable_signal;
      end 
end

endmodule

module EX_MEM(
       input clk, R,
       input in_EX_load_instr,
          in_EX_RF_enable,
          in_EX_Size_enable,
          in_EX_RW_enable,
          in_EX_Enable_signal,
    // input A, B;
    // input ID_B_instr, ID_BL_instr;
    // input next_pc;
    // input [3:0] I_15_12_Rd, I_31_28, RM, OpCode;
    // input [11:0] I_11_0;
    // input AM, SE; 
    // input flags;
       output reg MEM_load_instr,
          MEM_RF_enable,
          MEM_Size_enable,
          MEM_RW_enable,
          MEM_Enable_signal
    // output reg Out;
    // output reg Branch, B&L;
    // output reg Flags;
    // output reg [31:0] instruction;
);

always @(posedge clk) begin
    if(R) begin
        MEM_load_instr <= 1'b0;
        MEM_RF_enable <= 1'b0;
        MEM_Size_enable <= 1'b0;
        MEM_RW_enable <= 1'b0;
        MEM_Enable_signal <= 1'b0;
    end
    else begin
        MEM_load_instr <= in_EX_load_instr;
        MEM_RF_enable <= in_EX_RF_enable;
        MEM_Size_enable <= in_EX_Size_enable;
        MEM_RW_enable <= in_EX_RW_enable;
        MEM_Enable_signal <= in_EX_Enable_signal;
    end
end

endmodule 

module MEM_WB(
    input clk, R,
    input in_MEM_RF_enable,
    output reg WB_RF_enable
);

always @(posedge clk) begin
    if(R) WB_RF_enable <= 1'b0;
    else WB_RF_enable <= in_MEM_RF_enable;
end

endmodule