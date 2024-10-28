module clock_gen(
    output reg clk
);

    initial begin
        clk = 0;
        #40 $finish;
        #2 clk = ~clk; // Toggle the clock every 2 time units
    end

       always @(posedge clk) begin
        $display("Clock has a positive edge at time %0t", $time);
    end

endmodule
