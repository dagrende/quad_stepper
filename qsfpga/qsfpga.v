module tacho_fpga(quadA, quadB, mosi, miso, sck, ssel, dir, step);
	parameter COUNT_BITS = 32;

	input quadA, quadB;
	output miso;
	input mosi, sck, ssel;
	output dir, step;

	wire clk;

	OSCH #(
	.NOM_FREQ("53.2")
	) internal_oscillator_inst (
	.STDBY(1'b0),
	.OSC(clk)
	);

	reg [COUNT_BITS - 1: 0] step_period;
	wire [COUNT_BITS * 2 - 1: 0] receive_port;

	wire [COUNT_BITS - 1:0] count;
	wire [COUNT_BITS - 1: 0] position;
	wire [COUNT_BITS * 2 - 1: 0] send_data;
	assign send_data[63:32] = count;
	assign send_data[31:0] =  position;

	quad_counter #(COUNT_BITS) counter(clk, quadA, quadB, count);
	step_pulse_generator step_gen(clk, step_period, position, dir, step);
	spi_slave #(COUNT_BITS * 2) spi(clk, mosi, miso, sck, ssel, send_data, receive_port, received_ready);


	always @(posedge received_ready)
	begin
		step_period = receive_port[31:0];
	end
endmodule
