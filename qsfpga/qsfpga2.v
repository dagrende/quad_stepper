module qsfpga(quadA, quadB, mosi, miso, sck, cs, dir, step);
	parameter COUNT_BITS = 32;
	parameter CLKF = 53200000;	// clock freq Hz
	parameter REGF = 100;	// regulator loop freq Hz
	parameter REGTICKS = CLKF / REGF;	// clk ticks for each regulator loop turn

	parameter m = 7;
	parameter d = 3;

	parameter MPE = 200 * 32 * 6 / 1600;	// motor revolution pulses per encoder revolution pulses
	parameter MXMPE = d * MPE;

	input quadA, quadB;
	output miso;
	input mosi, sck, cs;
	output dir, step;

	wire clk;

	OSCH #(
	.NOM_FREQ("53.2")
	) internal_oscillator_inst (
	.STDBY(1'b0),
	.OSC(clk)
	);

	wire [COUNT_BITS - 1:0] encoder_position, scaled_encoder_position;
	wire [COUNT_BITS - 1: 0] scaled_motor_position;

	quad_detector #(COUNT_BITS) qd(clk, quadA, quadB, encoder_step, encoder_up);
	reciprocal_divider rd(clk, step_freq_m, step_freq_d, step);

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

	always

	reg [COUNT_BITS - 1:0] prev_encoder_position = 0;
	reg [31:0] reg_tick_counter = 0;
	always @(posedge clk)	begin
		if (reg_tick_counter == 0) begin
			// regulator step
			step_freq_m = 2 * scaled_encoder_position - prev_encoder_position - scaled_motor_position;
			step_freq_d = d / dt;

			prev_encoder_position = encoder_position;
			reg_tick_counter = REGTICKS;
		end
		reg_tick_counter = reg_tick_counter - 1
	end

endmodule
