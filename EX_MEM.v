module IF_ID(
    input A, B;
    input ID_B_instr, ID_BL_instr;
    input next_pc;
    input [3:0] I_15_12_Rd, I_31_28, RM, OpCode;
    input [11:0] I_11_0;
    input AM, SE; 
    input flags;

    output reg Out;
    output reg Branch, B&L;
    output reg Flags;
    output reg [31:0] instruction;


);

always @(instruction) begin
//signals definition

end

initial begin
  
end

endmodule 