`include "quad_detector.v"
`include "reciprocal_divider.v"

module gearbox(clk, quadA, quadB, step_pulse);
	parameter COUNT_BITS = 32;
	parameter CLKF = 53200000;	// clock freq Hz
	parameter REGTICKS = 524288;	// =2^19 clk ticks for each regulator loop turn (CLKF/REGTICKS = 101 approx)
	parameter STEP_PULSE_TICKS = 120;

	parameter m = 7;
	parameter d = 3;

	parameter MPE = 200 * 32 * 6 / 1600;	// motor revolution pulses per encoder revolution pulses
	parameter MXMPE = d * MPE;

	input clk, quadA, quadB;
	output step_pulse;

	reg [COUNT_BITS - 1:0] encoder_position, scaled_encoder_position, scaled_motor_position, step_freq_m, step_freq_d;

	quad_detector #(COUNT_BITS) qd(clk, quadA, quadB, encoder_step, encoder_up);
	reciprocal_divider rd(clk, step_freq_m, step_freq_d, motor_step);

	reg [31:0] step_pulse_timer = 0;
	assign step_pulse = step_pulse_timer > 0;

	always @(posedge motor_step) begin
		scaled_motor_position = scaled_motor_position + d;
	end

	always @(posedge encoder_step) begin
		if (encoder_up) begin
			encoder_position = encoder_position + 1;
			scaled_encoder_position = scaled_encoder_position + MPE;
		end else begin
			encoder_position = encoder_position - 1;
			scaled_encoder_position = scaled_encoder_position - MPE;
		end
	end

	reg [COUNT_BITS - 1:0] prev_encoder_position = 0;
	reg [31:0] reg_tick_counter = 0;
	always @(posedge clk)	begin
		if (reg_tick_counter == 0) begin
			// regulator step
			step_freq_m = 2 * scaled_encoder_position - prev_encoder_position - scaled_motor_position;
			step_freq_d = d << 19;  // d / dt = d * REGTICKS
			prev_encoder_position = encoder_position;
			reg_tick_counter = REGTICKS;
		end
		reg_tick_counter = reg_tick_counter - 1;

		if (step_pulse_timer > 0) step_pulse_timer = step_pulse_timer - 1;
	end

endmodule
