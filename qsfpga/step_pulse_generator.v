module step_pulse_generator(clk, period, position, dir, step);
	parameter PERIOD_BITS = 32;
	input clk;
	input signed [PERIOD_BITS - 1:0] period;
	output signed [PERIOD_BITS - 1:0] position;
	output dir, step;
	reg [PERIOD_BITS - 1:0] ticks;
	reg [10:0] step_timer;
	reg [PERIOD_BITS - 1:0] position;
	
	wire [PERIOD_BITS - 1:0] absperiod;
	assign absperiod = period < 0 ? -period : period;
	
	always @(posedge clk)
	begin
		ticks = ticks + 1;
		if (ticks >= absperiod) begin
			ticks = 0;
			step_timer = 160;
			position = position + (dir == 0 ? -1 : 1);
		end else
		if (step_timer > 0) begin
			step_timer = step_timer - 1;
		end
	end
	assign step = step_timer > 0;
	assign dir = period >= 0;
endmodule