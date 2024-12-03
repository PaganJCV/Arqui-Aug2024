
module PPU;
    //MUX RF_enable
    reg one_bit;
    wire out_RF_mux;

    //MUX RD_reg
    reg [3:0] fourteen_decimal;
    wire [3:0] out_RD_mux; 

    //MUX ALU out
    wire [31:0] out_ALU_mux; 

    //MUX Flags
    reg [3:0] alu_flags_conc;
    wire [3:0] out_flags_mux;

    //MUX 2x1 32 bits (MEM)
    wire [31:0] out_RAM_mux;

    //MUX IF
    wire [7:0] out_result_PC;

    //MUX RN, RM
    reg [31:0] in_Px;
    wire [31:0] out_RN;
    wire [31:0] out_RM;


    reg clk, R, LE;
    reg [31:0] dataIN; 
    integer fi, code;  
    //PC 
    reg [7:0] in_pc;
    wire [7:0] out_pc;

    //PC adder
    reg [7:0] num;
    wire [7:0] result;
  
  	//ROM
    reg [7:0] address;
    wire [31:0] Instruction;

    //IF_ID 
    reg [31:0] rom_instruction;
    wire [31:0] instruction;
    wire [23:0] I_23_0;
    wire [7:0] next_pc;
    wire [3:0] I_19_16_Rn, I_3_0_Rm, I_15_12_Rd, I_31_28;
    wire [11:0] I_11_0;

    //TA
    wire [7:0] Target_add;

   //Register File
    reg [31:0] PW;
    wire [31:0] PA, PB, PD;
    wire [31:0] monQ0, monQ1, monQ2, monQ3, monQ4, monQ5, monQ6, monQ7, monQ8, monQ9, monQ10, monQ11, monQ12, monQ13, monQ14, monQ15;

    //Control Unit
    reg [31:0] in_instruction;
    wire [3:0] opcode;
    wire [1:0] AM;
    wire S_enable,
         load_instr,
         RF_enable,
         Size_enable,
         RW_enable,
         Enable_signal,
         BL_instr,
         B_instr;
    wire [47:0] keyword;

    //CU mux
    reg S;
    reg [3:0] mux_opcode;
    reg [1:0] mux_AM;
    reg mux_S_enable,
        mux_load_instr,
        mux_RF_enable,
        mux_Size_enable,
        mux_RW_enable,
        mux_Enable_signal,
        mux_BL_instr,
        mux_B_instr;
    wire [3:0] ID_opcode;
    wire [1:0] ID_AM;
    wire ID_S_enable,
         ID_load_instr,
         ID_RF_enable,
         ID_Size_enable,
         ID_RW_enable,
         ID_Enable_signal,
         ID_BL_instr,
         ID_B_instr;

    //ID_EX
    reg [31:0] Pa, Pb, Pd;
    reg [3:0] in_Rd_or_14;
    reg [11:0] in_I_11_0;
    reg [3:0] in_ID_opcode;
    reg [1:0] in_ID_AM;
    reg   in_ID_S_enable,
          in_ID_load_instr,
          in_ID_RF_enable,
          in_ID_Size_enable,
          in_ID_RW_enable,
          in_ID_Enable_signal;
    wire [7:0] EX_next_pc;
    wire [31:0] EX_Pa, EX_Pb, EX_Pd;
    wire [11:0] EX_I_11_0;  
	  wire [3:0] EX_Rd_or_14; 
	  wire EX_BL_instr;      
	  wire EX_BL_enable;      
    wire [3:0] EX_opcode;
    wire [1:0] EX_AM;
    wire   EX_S_enable,
          EX_load_instr,
          EX_RF_enable,
          EX_Size_enable,
          EX_RW_enable,
          EX_Enable_signal;

    //SHIFTER
    reg [31:0] Rm;
    reg [11:0] I;
    reg [1:0] in_AM;
    wire [31:0] N_Shift;

    //ALU
    reg c0;
    wire [31:0] result_ALU;
    wire Z, N, C, V;

    //CONDITION HANDLER
    reg [3:0] cond_code;
    reg [3:0] flags; // [N, Z, C, V]
    wire Branch;
    wire BranchL;

    //PSR
    wire [3:0] PSR_flags;

    //EX_MEM
    reg in_EX_load_instr,
    in_EX_RF_enable,
    in_EX_Size_enable,
    in_EX_RW_enable,
    in_EX_Enable_signal;
    reg [7:0] in_mux_NextPC_Out;
    reg [11:0] in_EX_I_11_0;
    reg [31:0] in_EX_Pd;
    reg [3:0] IN_EX_Rd_or_14;
    wire MEM_load_instr, MEM_RF_enable, MEM_Size_enable, MEM_RW_enable, MEM_Enable_signal;
    wire [7:0] mux_NextPC_Out;
    wire [3:0] MEM_Rd_or_14;
    wire [31:0] MEM_Pd;

    //RAM
    reg E, RW, Size;
    reg [7:0] A;
    reg [31:0] DI;
    wire [31:0] DO;
    
    //MEM_WB
    reg in_MEM_RF_enable;
    reg [7:0] in_EA;
    reg [3:0] in_MEM_Rd_or_14;
    reg [31:0] in_MEM_DO;
    wire [31:0] out_WB_DO;
    wire [3:0] WB_Rd_or_14;
    wire WB_RF_enable;

    //FOWARDING UNIT
    reg [3:0] EX_RD, MEM_RD, WB_RD, ID_RM, ID_RN;
    wire FW_LE_SIGNAL, FW_CU_MUX_SIGNAL, FW_MEM_MUX_SIGNAL;
    wire [1:0] FW_ID_RM_MUX_SIGNAL, FW_ID_RN_MUX_SIGNAL;
    wire [3:0] EX_TO_ID_RD, MEM_TO_ID_RD, WB_TO_ID_RD;
 
 //IF
  PC pc_tb(.clk(clk), .R(R), .LE(FW_LE_SIGNAL), .in_pc(out_result_PC), .out_pc(out_pc));

  PC_adder adder_tb(.num(out_pc), .result(result));
  
  mux_8x1 IF_mux(.Y_8(out_result_PC), .S_8(Branch), .A_8(Target_add), .B_8(result));

  ROM rom(.address(out_pc),.instruction(Instruction));
//

  IF_ID ifid(.clk(clk), .R(R), .pc_plus_4(result), .rom_instruction(Instruction), 
                .LE(FW_LE_SIGNAL), 
                .I_23_0(I_23_0), 
                .next_pc(next_pc), 
                .I_19_16_Rn(I_19_16_Rn), 
                .I_3_0_Rm(I_3_0_Rm), 
                .I_15_12_Rd(I_15_12_Rd), 
                .I_31_28(I_31_28), 
                .I_11_0(I_11_0), 
                .Instruction(instruction));

// 
//ID 
// Register_file RF (
//     .clk(clk),
//     .LE(WB_RF_enable),
//     .RA(I_19_16_Rn),
//     .RB(I_3_0_Rm),
//     .RD(I_15_12_Rd),
//     .RW(WB_Rd_or_14),
//     .PC({24'b0, out_pc}),
//     .PW(out_WB_DO),
//     .PA(PA),
//     .PB(PB),
//     .PD(PD)
//   );

  Register_File RF (
        .LE(WB_RF_enable),
        .clk(clk),
        .PC({24'b0, out_pc}),
        .PW(out_WB_DO),
        .RD(I_15_12_Rd),
        .RB(I_3_0_Rm),
        .RA(I_19_16_Rn),
        .RW(WB_Rd_or_14),
        .PA(PA),
        .PB(PB),
        .PD(PD),
        .monQ0(monQ0),
        .monQ1(monQ1),
        .monQ2(monQ2),
        .monQ3(monQ3),
        .monQ4(monQ4),
        .monQ5(monQ5),
        .monQ6(monQ6),
        .monQ7(monQ7),
        .monQ8(monQ8),
        .monQ9(monQ9),
        .monQ10(monQ10),
        .monQ11(monQ11),
        .monQ12(monQ12),
        .monQ13(monQ13),
        .monQ14(monQ14),
        .monQ15(monQ15)
    );


  //RN
  RF_big_mux PA_mux(
    .in_PX(PA), 
    .EX_TO_ID_RD(out_ALU_mux), 
    .MEM_TO_ID_RD(out_RAM_mux), 
    .WB_TO_ID_RD(out_WB_DO), 
    .FW_ID_RX_MUX_SIGNAL(FW_ID_RN_MUX_SIGNAL), 
    .Px(out_RN)
);

  //RM
  RF_big_mux PB_mux(
    .in_PX(PB), 
    .EX_TO_ID_RD(out_ALU_mux), 
    .MEM_TO_ID_RD(out_RAM_mux), 
    .WB_TO_ID_RD(out_WB_DO), 
    .FW_ID_RX_MUX_SIGNAL(FW_ID_RM_MUX_SIGNAL), 
    .Px(out_RM)
);

 

 //TA
 TA ta(.in_I_23_0(I_23_0), .in_next_pc(result), .Target_add(Target_add));

 //MUX RD
 mux_4x1 RD_mux(.Y_4(out_RD_mux), .A_4(4'b1110), .B_4(I_15_12_Rd), .S_4(BranchL));

  Control_Unit cu_tb(.in_instruction(instruction), .opcode(opcode), 
               .AM(AM),
               .S_enable(S_enable),
               .load_instr(load_instr),
               .RF_enable(RF_enable),
               .Size_enable(Size_enable),
               .RW_enable(RW_enable),
               .Enable_signal(Enable_signal),
               .BL_instr(BL_instr),
               .B_instr(B_instr),
               .keyword(keyword));

  mux_2x1 RF_en(.Y(out_RF_mux), .S(BranchL), .A(1'b1), .B(RF_enable));             

  CU_mux  cu_mux_tb(.S(FW_CU_MUX_SIGNAL), .mux_opcode(opcode),  
                      .mux_AM(AM), 
                      .mux_S_enable(S_enable), 
                      .mux_load_instr(load_instr),
                      .mux_RF_enable(out_RF_mux),
                      .mux_Size_enable(Size_enable),
                      .mux_RW_enable(RW_enable),
                      .mux_Enable_signal(Enable_signal),
                      .mux_BL_instr(BL_instr),
                      .mux_B_instr(B_instr),
                  .ID_opcode(ID_opcode),
                  .ID_AM(ID_AM),
                  .ID_S_enable(ID_S_enable),
                  .ID_load_instr(ID_load_instr),
                  .ID_RF_enable(ID_RF_enable),
                  .ID_Size_enable(ID_Size_enable),
                  .ID_RW_enable(ID_RW_enable),
                  .ID_Enable_signal(ID_Enable_signal),
                  .ID_BL_instr(ID_BL_instr),
                  .ID_B_instr(ID_B_instr) );

//
//                  

  ID_EX idex(.clk(clk), .R(R), .in_next_pc(next_pc), .Pa(out_RN), .Pb(out_RM), .Pd(PD), .in_Rd_or_14(out_RD_mux), .in_I_11_0(I_11_0),
                    .in_ID_opcode(ID_opcode),
                    .in_ID_AM(ID_AM),
                    .in_ID_S_enable(ID_S_enable),
                    .in_ID_load_instr(ID_load_instr),
                    .in_ID_RF_enable(ID_RF_enable),
                    .in_ID_Size_enable(ID_Size_enable),
                    .in_ID_RW_enable(ID_RW_enable),
                    .in_ID_Enable_signal(ID_Enable_signal),
                    .in_BL_enable(BranchL),
           .EX_next_pc(EX_next_pc), .EX_Pa(EX_Pa), .EX_Pb(EX_Pb), .EX_Pd(EX_Pd), .EX_I_11_0(EX_I_11_0), .EX_Rd_or_14(EX_Rd_or_14), 
           .EX_opcode(EX_opcode),
           .EX_AM(EX_AM),
           .EX_S_enable(EX_S_enable),
           .EX_load_instr(EX_load_instr),
           .EX_RF_enable(EX_RF_enable),
           .EX_Size_enable(EX_Size_enable),
           .EX_RW_enable(EX_RW_enable),
           .EX_Enable_signal(EX_Enable_signal),
           .EX_BL_enable(BranchL)
           );
//EX
alu ALU (
        .opcode(EX_opcode),
        .OperandA(EX_Pa),
        .OperandB(N_Shift),
        .c0(PSR_flags[1]), 
  .result(result_ALU),
        .Z(Z),
        .N(N),
        .C(C),
        .V(V)
    );

mux_32x1 alu_out_mux(
    .Y_32(out_ALU_mux),
  .A_32({24'b0, EX_next_pc}),
    .B_32(result_ALU),
    .S_32(EX_BL_enable)
);

Shifter shift (
        .Rm(EX_Pb),
        .I(EX_I_11_0),
        .AM(EX_AM),
        .N_Shift(N_Shift)
    );

PSR psr(
    .clk(clk),
    .SE(EX_S_enable),
    .Z_in(Z),
    .N_in(N),
    .C_in(C),
    .V_in(V),
    .PSR_flags(PSR_flags)
);

assign alu_flags_conc = {N, Z, C, V};
mux_4x1 flags_mux(
    .Y_4(out_flags_mux),
    .A_4(alu_flags_conc),
    .B_4(PSR_flags),
    .S_4(EX_S_enable)
);

ConditionHandler CH (
        .cond_code(I_31_28),
        .flags(out_flags_mux),
        .in_B_instr(B_instr),
        .in_BL_instr(BL_instr),
        .Branch(Branch),
        .BranchL(BranchL)
    );


//
//
  EX_MEM exmem(.clk(clk), .R(R), .in_EX_load_instr(EX_load_instr),
                     .in_EX_RF_enable(EX_RF_enable),
                     .in_EX_Size_enable(EX_Size_enable),
                     .in_EX_RW_enable(EX_RW_enable),
                     .in_EX_Enable_signal(EX_Enable_signal),
               .in_mux_NextPC_Out(out_ALU_mux[7:0]),
                     .in_EX_Pd(EX_Pd),
                     .in_EX_Rd_or_14(EX_Rd_or_14), 
             .mux_NextPC_Out(mux_NextPC_Out),
             .MEM_Pd(MEM_Pd),
             .MEM_Rd_or_14(MEM_Rd_or_14),
             .MEM_load_instr(MEM_load_instr),
             .MEM_RF_enable(MEM_RF_enable),
             .MEM_Size_enable(MEM_Size_enable),
             .MEM_RW_enable(MEM_RW_enable),
             .MEM_Enable_signal(MEM_Enable_signal));
//
//MEM
ram256x8 RAM (
        .DO(DO),
        .E(MEM_Enable_signal),
        .RW(MEM_RW_enable),
        .Size(MEM_Size_enable),
        .A(mux_NextPC_Out),
        .DI(MEM_Pd)
    );

mux_32x1 mem_mux(
    .Y_32(out_RAM_mux),
    .A_32(DO),
  .B_32({24'b0, mux_NextPC_Out}),
    .S_32(MEM_load_instr)
);

//
                      
  MEM_WB memwb(.clk(clk), .R(R), .in_MEM_RF_enable(MEM_RF_enable), 
                .in_MEM_Rd_or_14(MEM_Rd_or_14),
                .in_MEM_DO(out_RAM_mux),
                .out_WB_DO(out_WB_DO),
                .WB_Rd_or_14(WB_Rd_or_14), 
                .WB_RF_enable(WB_RF_enable)
                );


  ForwardingUnit UNIDAD (
        .EX_RD(EX_Rd_or_14), .MEM_RD(MEM_Rd_or_14), .WB_RD(WB_Rd_or_14),
        .ID_RM(I_3_0_Rm), .ID_RN(I_19_16_Rn),
        .EX_RF_enable(EX_RF_enable), .MEM_RF_enable(MEM_RF_enable),
        .WB_RF_enable(WB_RF_enable), .EX_load_instr(EX_load_instr),
        .MEM_load_instr(MEM_load_instr),
        .FW_LE_SIGNAL(FW_LE_SIGNAL), .FW_CU_MUX_SIGNAL(FW_CU_MUX_SIGNAL),
        .FW_MEM_MUX_SIGNAL(FW_MEM_MUX_SIGNAL),
        .FW_ID_RM_MUX_SIGNAL(FW_ID_RM_MUX_SIGNAL),
        .FW_ID_RN_MUX_SIGNAL(FW_ID_RN_MUX_SIGNAL),
        .EX_TO_ID_RD(EX_TO_ID_RD), .MEM_TO_ID_RD(MEM_TO_ID_RD),
        .WB_TO_ID_RD(WB_TO_ID_RD)
    );
//

    // Control de Señales Iniciales
    initial begin
        clk = 0;
      repeat(20) #2 clk = ~clk; 
    end

    // Control de Señales Iniciales
    initial begin
        R = 1; // Reset en 1 al inicio
      in_pc = 0;  
        S = 0; // Multiplexor en 0
        #3 R = 0; // Reset cambia a 0 en tiempo 3
        #32 S = 1; // Multiplexor cambia a 1 en tiempo 32
    end

   initial begin
        fi = $fopen("input_file.txt", "r");
        if (fi == 0) begin
            $display("Error: No se pudo abrir el archivo input_file.txt");
            $finish;
        end
        // Leer cada instrucción y cargar en ROM Y RAM
        address = 8'b00000000;
        A = 8'b0;
        while (!$feof(fi)) begin
            code = $fscanf(fi, "%b", dataIN);
            rom.Mem[address] = dataIN;
            RAM.Mem[A] = dataIN;
            address = address + 1;
          A = A + 1;
        end
        $fclose(fi);
    end

 initial begin
   $monitor("clk: %d | pc=%0d | LE=%b | Keyword: %s | RA=%b | RB=%b | RD=%b | PW=%d | R1=%b | R2=%b | R3=%b, R5= %b | R6= %b", clk,
         out_result_PC, WB_RF_enable, keyword, I_19_16_Rn, I_3_0_Rm, I_15_12_Rd, WB_RF_enable,monQ1, monQ2, monQ3, monQ5, monQ6);
 end


endmodule