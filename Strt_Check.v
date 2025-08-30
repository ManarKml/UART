module Strt_Check (
	input CLK,								// System clock
	input RST,								// Active-low reset
	input strt_chk_en,						// Enable from FSM
	input sampled_bit,						// Input start bit
	input [5:0] edge_cnt,					// Edge counter for mid-bit sampling
	output reg strt_glitch					// Flag start error
	);

always @(posedge CLK) begin
	if (~RST) begin
		// reset
		strt_glitch <= 1'b0;
	end
	else if (strt_chk_en && edge_cnt == 7) begin
		if (sampled_bit != 1'b0) 			// Check for correct start bit
			strt_glitch <= 1'b1;
		else 
			strt_glitch <= 1'b0;
	end else if (~strt_chk_en) begin
		strt_glitch <= 1'b0;				// Reset error flag when enable is disabled
	end
end

endmodule