module ram256x8 (
    output reg [31:0] DO,
    input E, RW, Size,
    input [7:0] A, 
    input [31:0] DI
);
   reg[7:0] Mem[0:255];
   always@(A, RW)
     case(Size)
            1'b0:
                //Reading operation
              if (RW == 1'b0) DO = {24'b000000000000000000000000, Mem[A]}; 
                
                //Writing Operation
                else if(RW == 1'b1 && E == 1'b1) Mem[A] = DI[7:0];
            1'b1:
                //Reading operation
                if (RW == 1'b0) DO = {Mem[A], Mem[A+1], Mem[A+2], Mem[A+3]}; //Reading operation
                
                //Writing Operation
                else if (RW == 1'b1 && E == 1'b1) begin 
                    Mem[A] = DI[31:24];
                    Mem[A+1] = DI[23:16];
                    Mem[A+2] = DI[15:8];
                    Mem[A+3] = DI[7:0];
                end
        endcase
endmodule

