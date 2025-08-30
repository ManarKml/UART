module Parity_Check (
	input CLK,									// System clock
	input RST,									// Active-low reset
	input par_chk_en,							// Enable signal from FSM
    input sampled_bit,    						// Current sampled bit
    input PAR_TYP,        						// 0=even 1=odd
    input [5:0] edge_cnt, 						// Edge counter for mid-bit sampling
    output reg par_err    						// Flag parity error
	);

reg [7:0] data;
reg [3:0] counter;								// Counts received data bits

always @(posedge CLK) begin
	if (~RST) begin
		// reset
		par_err <= 1'b0;
		counter <= 4'b0;
		data <= 8'b0;
	end
	else if (par_chk_en && edge_cnt == 7) begin
		if (counter < 8) begin
			data[7 - counter] <= sampled_bit; 	// Sample the data bits
			counter <= counter + 1;				// Increment bits counter
		end 
		else if (counter == 8) begin
			if ( sampled_bit != ((PAR_TYP) ? ~(^data) : (^data)) ) // Check parity according to parity type
				par_err <= 1'b1;
			else 
				par_err <= 1'b0;

			counter <= 4'b0;					// Reset counter after receiving data & parity bits
		end
	end
	else if (!par_chk_en) begin
        // Reset counter between frames
        counter <= 4'b0;
        par_err <= 1'b0;
        data <= 8'b0;
    end
end

endmodule