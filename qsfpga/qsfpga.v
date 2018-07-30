module tacho_fpga(quadA, quadB, mosi, miso, sck, cs, dir, step);
	parameter COUNT_BITS = 32;

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

	reg [COUNT_BITS - 1: 0] step_period;
	reg dir;
	wire [COUNT_BITS * 2 - 1: 0] rx_data;

	wire [COUNT_BITS - 1:0] encoder_position;
	wire [COUNT_BITS - 1: 0] stepper_position;
	wire [COUNT_BITS * 2 - 1: 0] tx_data;
	assign tx_data[COUNT_BITS * 2 - 1:COUNT_BITS] = encoder_position;
	assign tx_data[COUNT_BITS - 1:0] =  stepper_position;

	quad_counter #(COUNT_BITS) counter(clk, quadA, quadB, encoder_position);
	step_pulse_generator #(COUNT_BITS) step_gen(clk, step_period, stepper_position, dir, step);
	spi_slave #(COUNT_BITS * 2) spi(clk, mosi, miso, sck, cs, tx_data, rx_data, rx_ready);

	// when received from master
	always @(posedge rx_ready)
	begin
		// pick out stepper period part of the received data
		step_period = rx_data[COUNT_BITS - 1:0];
		dir = rx_data[COUNT_BITS];
	end
endmodule
