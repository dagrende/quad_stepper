`include "edge_detector.v"

// generate outclk rate that is clk rate * multiplicand / dividend
module reciprocal_divider(clk, multiplicand, dividend, outclk);
  parameter COUNT_BITS = 32;
  input clk;
  input [COUNT_BITS - 1:0] multiplicand, dividend;
  output outclk;

  reg [COUNT_BITS - 1:0] counter = 0;
  reg outclk = 0;

  always @(posedge clk) begin
    counter = counter + multiplicand;
    if (counter >= dividend) begin
      counter = counter - dividend;
      outclk = 1;
    end else begin
      outclk = 0;
    end
  end
endmodule
