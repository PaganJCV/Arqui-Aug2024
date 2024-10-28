module CU_tb;
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

    //Control Unit
    reg [31:0] in_instruction;
    wire [3:0] opcode;
    wire AM,
         S_enable,
         load_instr,
         RF_enable,
         Size_enable,
         RW_enable,
         Enable_signal,
         BL_instr,
         B_instr;

    //CU mux
    reg S;
    reg [3:0] mux_opcode;
    reg mux_AM,
        mux_S_enable,
        mux_load_instr,
        mux_RF_enable,
        mux_Size_enable,
        mux_RW_enable,
        mux_Enable_signal,
        mux_BL_instr,
        mux_B_instr;
    wire [3:0] ID_opcode;
    wire ID_AM,
         ID_S_enable,
         ID_load_instr,
         ID_RF_enable,
         ID_Size_enable,
         ID_RW_enable,
         ID_Enable_signal,
         ID_BL_instr,
         ID_B_instr;

    //ID_EX
    reg [3:0] in_ID_opcode;
    reg   in_ID_AM,
          in_ID_S_enable,
          in_ID_load_instr,
          in_ID_RF_enable,
          in_ID_Size_enable,
          in_ID_RW_enable,
          in_ID_Enable_signal;
    wire [3:0] EX_opcode;
    wire  EX_AM,
          EX_S_enable,
          EX_load_instr,
          EX_RF_enable,
          EX_Size_enable,
          EX_RW_enable,
          EX_Enable_signal;
    
    //EX_MEM
    reg   in_EX_load_instr,
          in_EX_RF_enable,
          in_EX_Size_enable,
          in_EX_RW_enable,
          in_EX_Enable_signal;
    wire  MEM_load_instr,
          MEM_RF_enable,
          MEM_Size_enable,
          MEM_RW_enable,
          MEM_Enable_signal;
    
    //MEM_WB
    reg in_MEM_RF_enable;
    wire WB_RF_enable;

  PC pc_tb(.clk(clk), .R(R), .LE(LE), .in_pc(result), .out_pc(out_pc));

  PC_adder adder_tb(.num(out_pc), .result(result));
  

  ROM rom(.address(out_pc),.instruction(Instruction));

  IF_ID ifid(.clk(clk), .R(R), .rom_instruction(Instruction), .LE(LE), .Instruction(instruction));

  assign in_instruction = instruction;
  Control_Unit cu_tb(in_instruction, opcode, 
               AM,
               S_enable,
               load_instr,
               RF_enable,
               Size_enable,
               RW_enable,
               Enable_signal,
               BL_instr,
               B_instr);

  CU_mux  cu_mux_tb(.S(S), .mux_opcode(opcode),  
                      .mux_AM(AM), 
                      .mux_S_enable(S_enable), 
                      .mux_load_instr(load_instr),
                      .mux_RF_enable(RF_enable),
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

  ID_EX idex(.clk(clk), .R(R), .in_ID_opcode(ID_opcode),
                    .in_ID_AM(ID_AM),
                    .in_ID_S_enable(ID_S_enable),
                    .in_ID_load_instr(ID_load_instr),
                    .in_ID_RF_enable(ID_RF_enable),
                    .in_ID_Size_enable(ID_Size_enable),
                    .in_ID_RW_enable(ID_RW_enable),
                    .in_ID_Enable_signal(ID_Enable_signal),
           .EX_opcode(EX_opcode),
           .EX_AM(EX_AM),
           .EX_S_enable(EX_S_enable),
           .EX_load_instr(EX_load_instr),
           .EX_RF_enable(EX_RF_enable),
           .EX_Size_enable(EX_Size_enable),
           .EX_RW_enable(EX_RW_enable),
           .EX_Enable_signal(EX_Enable_signal));


  EX_MEM exmem(.clk(clk), .R(R), .in_EX_load_instr(EX_load_instr),
                     .in_EX_RF_enable(EX_RF_enable),
                     .in_EX_Size_enable(EX_Size_enable),
                     .in_EX_RW_enable(EX_RW_enable),
                     .in_EX_Enable_signal(EX_Enable_signal),
             .MEM_load_instr(MEM_load_instr),
             .MEM_RF_enable(MEM_RF_enable),
             .MEM_Size_enable(MEM_Size_enable),
             .MEM_RW_enable(MEM_RW_enable),
             .MEM_Enable_signal(MEM_Enable_signal));
                      
  MEM_WB memwb(.clk(clk), .R(R), .in_MEM_RF_enable(in_MEM_RF_enable), .WB_RF_enable(WB_RF_enable));
                    
integer read_counter = 0;
initial begin
  clk = 0;
  num = 0;
  fi = $fopen("input_file.txt","r");
  repeat (20) #2 clk = ~clk; // Toggle the clock every 2 time units
  
end
  
always @(posedge clk) begin
  address = out_pc;
    if (!$feof(fi)) begin
        // Solo lee cada 2 ciclos de reloj
        if (read_counter == 1) begin
            code = $fscanf(fi, "%b", dataIN);
            rom.Mem[address] = dataIN;
            address = address + 1;
            read_counter = 0; // Reinicia el contador
        end else begin
            read_counter = read_counter + 1; // Incrementa el contador
        end
    end else begin
        $fclose(fi); // Cierra el archivo al final de la lectura
    end
end
  
initial begin
    //address = out_pc;
    R = 1;
    LE = 1;
    S = 0;
    
        //#40 $finish;
        

        #3; //3
        R = 0;

        #29; //3 + 29 = 32
        S = 1;

end

initial begin
  $display("IF_ID");
  $monitor("\nAt time %t | PC: %d | clk: %d | instruction: %b | ID_opcode = %b | ID_AM = %b | ID_S_enable = %b | ID_load_instr= %b | ID_RF_enable = %b | ID_Size_enable = %b | ID_RW_enable = %b | ID_Enable_signal = %b | ID_BL_instr = %b | ID_B_instr = %b", $time, out_pc, clk, in_instruction, ID_opcode, ID_AM,
               ID_S_enable,
               ID_load_instr,
               ID_RF_enable,
               ID_Size_enable,
               ID_RW_enable,
               ID_Enable_signal,
               ID_BL_instr,
               ID_B_instr);
end


endmodule