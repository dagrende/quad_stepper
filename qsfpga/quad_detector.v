// Detects movement from quadrature signals phaseA and phaseB,
// Outputs each movement by raising step for one clk cycle and indicating direction with direction_up
// Produces 4 steps for each quadrature cycle.
module quad_detector(clk, phaseA, phaseB, step, direction_up);
	input clk, phaseA, phaseB;
	output step, direction_up;

	reg [2:0] phaseA_delayed, phaseB_delayed;

	always @(posedge clk) phaseA_delayed <= {phaseA_delayed[1:0], phaseA};
	always @(posedge clk) phaseB_delayed <= {phaseB_delayed[1:0], phaseB};

	wire step = phaseA_delayed[1] ^ phaseA_delayed[2] ^ phaseB_delayed[1] ^ phaseB_delayed[2];
	wire direction_up = phaseA_delayed[1] ^ phaseB_delayed[2];
endmodule
