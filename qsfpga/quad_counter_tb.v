`timescale 1ns/100ps
`include "quad_counter.v"

module quad_counter_tb();
  parameter POS_BITS = 5;
  reg clk = 0;
  reg quadA = 0;
  reg quadB = 0;
  wire [POS_BITS - 1:0] position;

  quad_counter #(POS_BITS) qc(clk, quadA, quadB, position);

  initial begin
    forever #20 clk = ~clk;
  end

  initial begin
    $dumpfile("quad_counter.vcd");
    $dumpvars(0, quad_counter_tb);

    #25;
    quadA = 1;
    #10001;
    quadB = 1;
    #10001;
    quadA = 0;
    #10001;
    quadB = 0;
    #50001;

    $finish;
   end

endmodule
