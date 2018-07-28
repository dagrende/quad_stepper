module step_pulse_generator(clk, period, dir, step);
	parameter PERIOD_BITS = 32;
	input clk;
	input [PERIOD_BITS - 1:0] period;
	output dir, step;
	reg [PERIOD_BITS - 1:0] ticks;
	reg [10:0] step_timer;
	
	always @(posedge clk)
	begin
		ticks = ticks + 1;
		if (ticks >= period) begin
			ticks = 0;
			step_timer = 160;
		end
		if (step_timer > 0) begin
			step_timer = step_timer - 1;
		end
	end
	assign step = step_timer > 0;
	assign dir = 1;
endmodule