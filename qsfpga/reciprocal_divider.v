`include "edge_detector.v"

// generate outclk rate  that is inclk rate * multiplicand / dividend
module reciprocal_divider(clk, multiplicand, dividend, inclk, outclk);
  parameter COUNT_BITS = 32;
  input clk, inclk;
  input [COUNT_BITS - 1:0] multiplicand, dividend;
  output outclk;

  reg [COUNT_BITS - 1:0] counter = 0;
  reg outclk = 0;

  edge_detector ed(.clk(clk), .in(inclk), .pose(inclk_pose), .nege(inclk_nege));

  always @(posedge clk)
  begin
    if (inclk_pose) begin
      counter = counter + multiplicand;
      if (counter >= dividend) begin
        counter = counter - dividend;
        outclk = 1;
      end
    end else begin
      outclk = 0;
    end
  end
endmodule
