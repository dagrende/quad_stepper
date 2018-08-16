`timescale 1ns/100ps
`include "reciprocal_divider.v"

// generate outclk rate  that is inclk rate * multiplicand / dividend
module reciprocal_divider_tb();
  parameter COUNT_BITS = 32;

  reg clk = 0;
  wire outclk;

  reg [COUNT_BITS - 1:0] multiplicand = 2;
  reg [COUNT_BITS - 1:0] dividend = 3;
  reg [COUNT_BITS - 1:0] counter = 0;

  reciprocal_divider rd(clk, multiplicand, dividend, outclk);

  always @(posedge outclk)
  begin
    counter = counter + 1;
  end

  initial begin
    $dumpfile("reciprocal_divider_tb.vcd");
    $dumpvars(0, reciprocal_divider_tb);

    #25;
    repeat (60) #10000 clk = ~clk;

    if (counter != 20) $display("fail: counter is not 20");

    $finish;
   end

endmodule
