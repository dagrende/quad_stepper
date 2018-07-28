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

	wire [COUNT_BITS - 1:0] count;
	reg [COUNT_BITS - 1: 0] step_period;
	wire [COUNT_BITS - 1: 0] receive_port;

	quad_counter #(COUNT_BITS) counter(clk, quadA, quadB, count);
	spi_slave #(COUNT_BITS) spi(clk, mosi, miso, sck, ssel, count, receive_port, received_ready);
	step_pulse_generator step_gen(clk, step_period, dir, step);
	
	always @(posedge received_ready)
	begin
		step_period = receive_port;
	end
endmodule
