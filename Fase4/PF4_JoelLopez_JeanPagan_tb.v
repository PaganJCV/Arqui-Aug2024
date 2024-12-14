
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
    wire [31:0] out_result_PC;

    //MUX RN, RM
    reg [31:0] in_Px;
    wire [31:0] out_RN;
    wire [31:0] out_RM;
    wire [31:0] out_RD;


    reg clk, R, LE;
    reg [31:0] dataIN; 
    integer fi, code;  
    //PC 
    reg [31:0] in_pc;
    wire [31:0] out_pc;

    //PC adder
    reg [31:0] num;
    wire [31:0] result;
  
  	//ROM
    reg [7:0] address;
    wire [31:0] Instruction;

    //IF_ID 
    reg [31:0] rom_instruction;
    wire [31:0] instruction;
    wire [23:0] I_23_0;
    wire [31:0] next_pc;
    wire [3:0] I_19_16_Rn, I_3_0_Rm, I_15_12_Rd, I_31_28;
    wire [11:0] I_11_0;

    //TA
    wire [31:0] Target_add;

   //Register File
    reg [31:0] PW;
    wire [31:0] PA, PB, PD;

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
    wire [31:0] EX_next_pc;
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
    reg [31:0] in_mux_NextPC_Out;
    reg [11:0] in_EX_I_11_0;
    reg [31:0] in_EX_Pd;
    reg [3:0] IN_EX_Rd_or_14;
    wire MEM_load_instr, MEM_RF_enable, MEM_Size_enable, MEM_RW_enable, MEM_Enable_signal;
    wire [31:0] mux_NextPC_Out;
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
    wire FW_LE_SIGNAL, FW_CU_MUX_SIGNAL, FW_MEM_MUX_SIGNAL, R_EX;
    wire [1:0] FW_ID_RM_MUX_SIGNAL, FW_ID_RN_MUX_SIGNAL, FW_ID_RD_MUX_SIGNAL;
    wire [3:0] EX_TO_ID_RD, MEM_TO_ID_RD, WB_TO_ID_RD;
 
 //IF
 
  PC pc_tb(.clk(clk), .R(R), .LE(FW_LE_SIGNAL), .in_pc(out_result_PC), .out_pc(out_pc));

  PC_adder adder_tb(.num(out_pc), .result(result));
  
  mux_32x1 IF_mux(.Y_32(out_result_PC), .S_32(Branch), .A_32(Target_add), .B_32(result));

  ROM rom(.address(out_pc[7:0]),.instruction(Instruction));
//

  IF_ID ifid(.clk(clk), .R(R), .R_B(Branch), .next_pc(result), .rom_instruction(Instruction), 
                .LE(FW_LE_SIGNAL), 
                .I_23_0(I_23_0), 
                .I_19_16_Rn(I_19_16_Rn), 
                .I_3_0_Rm(I_3_0_Rm), 
                .I_15_12_Rd(I_15_12_Rd), 
                .I_31_28(I_31_28), 
                .I_11_0(I_11_0), 
                .ID_next_pc(next_pc),
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
        .PC(out_pc),
        .PW(out_WB_DO),
        .RD(I_15_12_Rd),
        .RB(I_3_0_Rm),
        .RA(I_19_16_Rn),
        .RW(WB_Rd_or_14),
        .PA(PA),
        .PB(PB),
        .PD(PD)
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

 //RD
  RF_big_mux PD_mux(
    .in_PX(PD), 
    .EX_TO_ID_RD(out_ALU_mux), 
    .MEM_TO_ID_RD(out_RAM_mux), 
    .WB_TO_ID_RD(out_WB_DO), 
    .FW_ID_RX_MUX_SIGNAL(FW_ID_RD_MUX_SIGNAL), 
    .Px(out_RD)
);

 

 //TA
 TA ta(.in_I_23_0(I_23_0), .in_next_pc(next_pc), .Target_add(Target_add));

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

  ID_EX idex(.clk(clk), .R(R_EX), .in_next_pc(next_pc), .Pa(out_RN), .Pb(out_RM), .Pd(out_RD), .in_Rd_or_14(out_RD_mux), .in_I_11_0(I_11_0),
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
           .EX_BL_enable(EX_BL_enable)
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
  .A_32(EX_next_pc),
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

always @(*)begin
   alu_flags_conc <= {N, Z,C,V};
end

mux_4x1 flags_mux(
    .Y_4(out_flags_mux),
    .A_4(alu_flags_conc),
    .B_4(PSR_flags),
    .S_4(EX_S_enable)
);

ConditionHandler CH (
        .cond_code(I_31_28),
        .flags(out_flags_mux),
        .in_B_instr(ID_B_instr),
        .in_BL_instr(ID_BL_instr),
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
               .in_mux_NextPC_Out(out_ALU_mux),
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
  reg [7:0] A_8_bit;
always @(posedge clk) A_8_bit <= mux_NextPC_Out [7:0];
//MEM
ram256x8 RAM (
        .DO(DO),
        .E(MEM_Enable_signal),
        .RW(MEM_RW_enable),
        .Size(MEM_Size_enable),
        .A(mux_NextPC_Out [7:0]),
        .DI(MEM_Pd)
    );

mux_32x1 mem_mux(
    .Y_32(out_RAM_mux),
    .A_32(DO),
  .B_32(mux_NextPC_Out),
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
        .ID_RM(I_3_0_Rm), .ID_RN(I_19_16_Rn), .ID_RD(I_15_12_Rd),
        .EX_RF_enable(EX_RF_enable), .MEM_RF_enable(MEM_RF_enable),
        .WB_RF_enable(WB_RF_enable), .EX_load_instr(EX_load_instr), .ID_AM(ID_AM),
        .MEM_load_instr(MEM_load_instr),
        .FW_LE_SIGNAL(FW_LE_SIGNAL), .FW_CU_MUX_SIGNAL(FW_CU_MUX_SIGNAL),
        .FW_MEM_MUX_SIGNAL(FW_MEM_MUX_SIGNAL),
        .R_EX(R_EX),
        .FW_ID_RM_MUX_SIGNAL(FW_ID_RM_MUX_SIGNAL),
        .FW_ID_RN_MUX_SIGNAL(FW_ID_RN_MUX_SIGNAL),
        .FW_ID_RD_MUX_SIGNAL(FW_ID_RD_MUX_SIGNAL),
        .EX_TO_ID_RD(EX_TO_ID_RD), .MEM_TO_ID_RD(MEM_TO_ID_RD),
        .WB_TO_ID_RD(WB_TO_ID_RD)
    );
//

    // Control de Señales Iniciales
    initial begin
        clk = 0;
      repeat(120) #2 clk = ~clk; 
    end

    // Control de Señales Iniciales
    reg [6:0] i = 7'b0;

    initial begin
        R = 1; // Reset en 1 al inicio
        #3 R = 0; // Reset cambia a 0 en tiempo 3

     #240 begin
     A = 8'b0;
     
     $display("Ram Content: ");
       while(i != 58)begin 
     i = i + 1;
     $display("A: %d | %b %b %b %b", A, RAM.Mem[A], RAM.Mem[A+1], RAM.Mem[A+2],RAM.Mem[A+3]);
     A = A + 4;
     end
     $finish;
     end
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

    // $monitor("\nkeyword: %s | PC: %d | PC+4: %d | Branch: %b | TA: %d | Salida Mux: %d ", keyword,out_pc[7:0],result[7:0],Branch,Target_add[7:0],out_result_PC[7:0]);
    $monitor("Time: %d | PC: %d | Keyword: %s | Address Received: %d  |  R1: %d  |  R2 : %d  |  R3: %d  |  R5: %d  |  R6 : %d \n",
    $time,
    out_pc[7:0],
    keyword,
    A_8_bit,
    RF.Q1,
    RF.Q2,
    RF.Q3,
    RF.Q5,
    RF.Q6);
    
    //Entradas y salidas ID y EX
    // $monitor("PC: %d | Keyword: %s \n\nIN_23_0: %b | IN_19_16: %b | IN_3_0: %b | IN_15_12: %b | IN_31_28: %b | IN_11_0: %b\n\nID_RN: %d | ID_RM: %d | ID_ PD: %d | ID_RD_14: %d | ID_11_0: %d | ID_OP: %d | ID_AM: %d | ID_ BranchL: %b | ID_NEXT_PC: %d\n\nEX_RN: %d | EX_RM: %d | EX_ PD: %d | EX_RD_14: %d | EX_11_0: %d | EX_OP: %d | EX_AM: %d | EX_NEXT_PC: %d\n\n----------------------------------------------------------------------------------------------------------------------------------------", 
    // out_pc, keyword, I_23_0, I_19_16_Rn, I_3_0_Rm, I_15_12_Rd, I_31_28, I_11_0,
    //                  out_RN, out_RM, PD, out_RD_mux, I_11_0, ID_opcode, ID_AM, BranchL, next_pc,
    //                  EX_Pa, EX_Pb, EX_Pd, EX_I_11_0, EX_Rd_or_14, EX_opcode, EX_AM, EX_BL_enable);
  // $monitor("\nTime: %d | PC: %d | Keyword: %s | ID_S_enbale: %b\n44: %b %b %b %b\nAc: %b\nAM: %b%b\nPW: %d | R%d\nIN_11_0: %d\nFU_RN: %b | RN: %d\nFU_RM: %b | RM: %d\nFU_RD: %d | RD: %d\nR1: %d | R2: %d | R3: %d | R5: %d | R6: %d\n\nALU:\nEntrada A: %d | Entrada B: %d | OP: %b | Cin: %b | resultado: %d | N: %b | Z: %b | C: %b | V: %b | alu flags: %b | PSR Flags: %b | CH mux: %b\nCondition code: %b | cond_true: %b | B_instr: %b | BL_instr: %b | Branch: %b | BranchL: %b | TA: %d | PC_TA: %d | S_signal: %b\n\nShifter:\nEntrada A: %d | Entrada B: %d | AM: %b | resultado: %d\n\nWB debugg:\nSalida mux ALU: %d | Salida mux ALU: %b | Entrada a MEM: %d | Valor: %d | Salida mux MEM: %d | WB Value: %d\n--------------------------------------------------------------------------------------------------------------------------------------",
  //            $time, out_pc[7:0], keyword, ID_S_enable, rom.Mem[44], rom.Mem[45], rom.Mem[46], rom.Mem[47], instruction, instruction[27:25], instruction[4], out_WB_DO, WB_Rd_or_14, I_11_0, FW_ID_RN_MUX_SIGNAL,out_RN, FW_ID_RM_MUX_SIGNAL, out_RM, FW_ID_RD_MUX_SIGNAL, out_RD, RF.Q1, RF.Q2, RF.Q3, RF.Q5, RF.Q6, EX_Pa, N_Shift, EX_opcode, PSR_flags[1], result_ALU, N, Z, C ,V, alu_flags_conc, PSR_flags, out_flags_mux, I_31_28, CH.cond_true, ID_B_instr, ID_BL_instr, Branch, BranchL, Target_add[7:0], out_result_PC, EX_S_enable,
  //             EX_Pb, EX_I_11_0,EX_AM, N_Shift,
  //             out_ALU_mux, out_ALU_mux, mux_NextPC_Out [7:0], MEM_Pd, out_RAM_mux, out_WB_DO);
    // $monitor("time: %d | Keyword: %s | PC: %d | PC+4: %d | TA: %d | Senal: %b | Out del mux: %d\n\nR_B: %b | Next_pc: %d | Instruction_IF: %b | Instruction ID: %b | I_23_0: %d\n---------------------------------------------------------------------------------", 
    // $time, keyword, out_pc, result, Target_add, Branch, out_result_PC, ifid.R_B, next_pc, Instruction, instruction, I_23_0);
//     $monitor("PC = %d | Instr = %s | ID_opcode: %b |  ID_AM = %b | ID_S_enable = %b | ID_load_instr= %b | ID_RF_enable = %b | ID_Size_enable = %b | ID_RW_enable = %b | ID_Enable_signal = %b | ID_BL_instr = %b | ID_B_instr = %b \n\nEX:\nEX_opcode = %b | EX_AM = %b | EX_S_enable = %b | EX_RF_enable = %b | EX_Size_enable = %b | EX_RW_enable = %b | EX_Enable_signal = %b \n\nMEM:\nMEM_RF_enable = %b | MEM_Size_enable = %b | MEM_RW_enable = %b | MEM_Enable_signal = %b\n\nWB:\nWB_RF_enable: %b\n\n--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------",
//              out_pc[7:0],
//              keyword,
//              ID_opcode,
//              ID_AM,
//              ID_S_enable,
//              ID_load_instr,
//              ID_RF_enable,
//              ID_Size_enable,
//              ID_RW_enable,
//              ID_Enable_signal,
//              ID_BL_instr,
//              ID_B_instr,
//           	  EX_opcode,
//              EX_AM,
//              EX_S_enable,
//              EX_RF_enable,
//              EX_Size_enable,
//              EX_RW_enable,
//              EX_Enable_signal,
//           	  MEM_RF_enable,
//              MEM_Size_enable,
//              MEM_RW_enable,
//              MEM_Enable_signal,
//           	  WB_RF_enable);
 end


endmodule