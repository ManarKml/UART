module edge_bit_counter (
	input CLK,							// System clock
	input RST,							// Active-low reset
	input enable,						// Enable from FSM
	input [5:0] Prescale,				// Prescale for clock
	output reg [5:0] edge_cnt,			// Edge counter for mid-bit sampling
	output reg [3:0] bit_cnt 			// Bit counter for the uart frame
	);

always @(posedge CLK) begin
	if (~RST) begin
		// reset
		edge_cnt <= 6'b0;
		bit_cnt <= 4'b0;
	end
	else if (enable) begin
		if (edge_cnt == Prescale - 1) begin
			// Full bit received
			edge_cnt <= 6'b0;
			bit_cnt <= bit_cnt + 1;
		end else if (edge_cnt == 0 && bit_cnt == 0) begin
			edge_cnt <= 3; 				// Skip first few edges in the case of the start bit 
		end else begin
			edge_cnt <= edge_cnt + 1;
		end
	end
	else begin
		// Reset counters when enable is disabled
		edge_cnt <= 6'b0;
		bit_cnt <= 4'b0;
	end
end

endmodule