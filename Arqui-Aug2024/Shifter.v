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