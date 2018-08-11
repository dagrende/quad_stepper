module quad_counter(clk, quadA, quadB, position);
	parameter COUNT_BITS = 32;
	input clk, quadA, quadB;
	output signed [COUNT_BITS - 1:0] position;

	reg [2:0] quadA_delayed, quadB_delayed;

	always @(posedge clk) quadA_delayed <= {quadA_delayed[1:0], quadA};
	always @(posedge clk) quadB_delayed <= {quadB_delayed[1:0], quadB};

	wire count_enable = quadA_delayed[1] ^ quadA_delayed[2] ^ quadB_delayed[1] ^ quadB_delayed[2];
	wire count_up = quadA_delayed[1] ^ quadB_delayed[2];

	reg signed [COUNT_BITS - 1:0] position = 0;

	always @(posedge clk)
	begin
		if (count_enable)
		begin
			if (count_up) begin
				position = position + 1;
			end else begin
				position = position - 1;
			end
		end
	end

endmodule
