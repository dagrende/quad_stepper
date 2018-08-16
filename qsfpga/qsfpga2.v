module qsfpga2(phaseA, phaseB, step_pulse);
	input phaseA, phaseB;
	output step_pulse;

	wire clk;

	OSCH #(
	.NOM_FREQ("53.2")
	) internal_oscillator_inst (
	.STDBY(1'b0),
	.OSC(clk)
	);

	gearbox gb(clk, phaseA, phaseB, step_pulse);
endmodule
