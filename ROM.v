<<<<<<< HEAD
module ROM(
    input [7:0] address,  
    output reg [31:0] instruction  
);
    reg [7:0] Mem [0:255];

    always @(address) begin
      instruction = {Mem[address], Mem[address+1], Mem[address+2], Mem[address+3]};
    end

=======
module ROM(
    input [7:0] address,  
    output reg [31:0] instruction  
);
    reg [7:0] Mem [0:255];

    always @(address) begin
      instruction = {Mem[address], Mem[address+1], Mem[address+2], Mem[address+3]};
    end

>>>>>>> 1db9e949b472e9b3ff5d4bed6418ec777fa0fb9b
endmodule