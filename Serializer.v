module Serializer ( 					// Outputs MSB first (P_DATA[7] -> P_DATA[0])
	input CLK,							// System clock
	input RST,							// Active-low reset
	input [7:0] P_DATA,					// Parallel input data
	input ser_en,						// Serializer enable signal
	output reg ser_data,				// Serialized output bit
	output reg ser_done					// High when last bit is sent
	);

reg [2:0] counter;						// 3-bit counter (0 to 7)

// Shift logic
always @(posedge CLK) begin
	if (~RST) begin
		// Reset all outputs and counter
		ser_data <= 1'b0;
		counter <= 3'b0;
		ser_done <= 1'b0;
	end
	else if (ser_en) begin	
		// Send current bit based on counter	
		ser_data <= P_DATA[7 - counter]; 

		// Increment counter
		counter <= counter + 1'b1;

		// Assert done one cycle before counter reaches 7
		if (counter == 6) begin
			ser_done <= 1'b1;
		end
		else  
			ser_done <= 1'b0;
	end
	else begin
		// If not enabled reset counter and done flag
		counter <= 3'b0;
		ser_done <= 1'b0;
	end

end

endmodule