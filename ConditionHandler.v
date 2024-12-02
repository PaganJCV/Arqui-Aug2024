module ConditionHandler (
    input [3:0] cond_code,      // Bits 28-31
    input [3:0] flags,          // Flags from PSR: [N, Z, C, V]
    input B_instr, BL_instr,      
    output reg Branch, BranchL 
);

    // Decode PSR flags
    // wire N = flags[3];  // Negative
    // wire Z = flags[2];  // Zero
    // wire C = flags[1];  // Carry
    // wire V = flags[0];  // Overflow

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
        Branch= 1'b0;
        BranchL = 1'b0;

        if (B_instr && cond_true) Branch = 1'b1;
        else if (BL_instr && cond_true) begin
            Branch = 1'b1;
            BranchL = 1'b1;
        end
    end

endmodule
