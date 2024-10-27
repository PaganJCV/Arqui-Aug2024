module clock_gen(
    output reg clk
);

    initial begin
        clk = 0;
    end

    always begin
        #5 clk = ~clk; // Toggle the clock every 5 time units for a 10-time-unit period
    end

endmodule
