module Stop_Check (
	input CLK,								// System clock
	input RST,								// Active-low reset
	input stp_chk_en,						// Enable from FSM
	input sampled_bit,						// Input stop bit
	input [5:0] edge_cnt,					// Edge counter for mid-bit sampling
	output reg stp_err						// Flag stop error
	);

always @(posedge CLK) begin
	if (~RST) begin
		// reset
		stp_err <= 1'b0;
	end
	else if (stp_chk_en && edge_cnt == 7) begin
		if (sampled_bit != 1'b1) begin 		// Check for correct stop bit
			stp_err <= 1'b1;
		end else begin
			stp_err <= 1'b0;
		end
	end
	else if (~stp_chk_en) begin
		stp_err <= 1'b0; 					// Reset error flag when enable is disabled
	end
end

endmodule