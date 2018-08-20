`timescale 1ns/100ps
`include "gearbox.v"

module gearbox_tb();
	reg clk = 0, phaseA, phaseB;
	wire step_pulse;

	gearbox gb(clk, phaseA, phaseB, step_pulse);

  initial begin
    forever #20 clk = ~clk;
  end

  initial begin
    //$dumpfile("gearbox_tb.vcd");
    //$dumpvars(0, gearbox_tb);

    #25;
		repeat (3000) begin
	    phaseA = 1;
	    #12755;
	    phaseB = 1;
	    #12755;
	    phaseA = 0;
	    #12755;
	    phaseB = 0;
	    #12755;
		end

    $finish;
   end

endmodule
