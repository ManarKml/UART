module deserializer (
	input CLK,										// System clock
	input RST,										// Active-low reset
	input sampled_bit,								// Output sampled bit
	input deser_en,									// Enable from FSM
	input [5:0] edge_cnt,							// Edge counter for mid-bit sampling
	output reg [7:0] P_DATA							// Parallel output byte
	);

reg [7:0] shift_reg;
reg [3:0] counter;									// 4-bit counter (used from 0 to 8)

always @(posedge CLK) begin
	if (~RST) begin
		// reset
		shift_reg <= 8'b0;
		counter <= 4'b0;
		P_DATA <= 8'b0;
	end
	else if (deser_en) begin
		if (edge_cnt == 7) begin
			shift_reg [7 - counter] <= sampled_bit; // Use shift register to store data
			counter <= counter + 1;					// Increment bits counter
		end
		if (counter == 4'd8) begin 
			P_DATA <= shift_reg; 					// Send data to output after receiving all 8 bits
			counter <= 4'b0; 						// Reset counter for next byte 
		end
	end 
	else if (~deser_en) begin
		// Reset counter and shift register when enable is disabled
		counter <= 4'b0;
		shift_reg <= 8'b0;
	end
end

endmodule