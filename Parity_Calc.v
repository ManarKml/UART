module Parity_Calc (
	input CLK,					// System clock
	input RST,					// Active-low reset
	input [7:0] P_DATA,			// Parallel data to calculate parity
	input Data_Valid,			// Indicates P_DATA is valid for parity calculation
	input PAR_TYP,				// Parity type: 0 = Even parity, 1 = Odd parity
	output reg par_bit			// Calculated parity bit
	);

always @(posedge CLK) begin
	if (~RST) begin
		// Reset the parity bit to 0
		par_bit <= 1'b0;
	end
	else if (Data_Valid) begin
		// Calculate parity based on selected type
		if (PAR_TYP) begin 
			// Odd parity: parity bit = XNOR reduction
			par_bit <= ~(^P_DATA);
		end else begin 
			// Even parity: parity bit = XOR reduction
			par_bit <= ^P_DATA;
		end
	end
end

endmodule