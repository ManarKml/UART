module data_sampling (
	input CLK,							// System clock
	input RST,							// Active-low reset
	input RX_IN,						// Serial input 
	input dat_samp_en,					// Enable from FSM
	input [5:0] edge_cnt,				// Edge counter for mid-bit sampling
	input [5:0] Prescale,				// Prescale for clock
	output reg sampled_bit				// Output sampled bit
	);

reg [2:0] in_bits;						// To store the 3 samples 

always @(posedge CLK) begin
	if (~RST) begin
		// reset
		sampled_bit <= 1'b0;
	end
	else if (dat_samp_en) begin

		// Sample 3 middle points of the bit
		if (edge_cnt == (Prescale/2 - 1))
			in_bits[0] <= RX_IN;
		else if (edge_cnt == (Prescale/2))
			in_bits[1] <= RX_IN;
		else if (edge_cnt == (Prescale/2 + 1))
			in_bits[2] <= RX_IN;

		// Decide bit value by majority vote
		if (edge_cnt == Prescale/2 + 2) begin
			sampled_bit <= ((in_bits[0] + in_bits[1] + in_bits[2]) >= 2);
		end
	end
end

endmodule