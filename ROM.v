module ROM(
    input [7:0] address,  
    output reg [31:0] instruction  
);
    reg [7:0] Mem [0:255];

    always @(address) begin
      instruction = {Mem[address], Mem[address+1], Mem[address+2], Mem[address+3]};
    end

endmodule