module MUX (
	input In_0,				// Stop bit input
	input In_1,				// Start bit input
	input In_2,				// Data bits input (from serializer)
	input In_3,				// Parity bit input
	input [1:0] mux_sel,	// Control signal to select which input is output
	output reg TX_OUT		// Selected output bit
	);

always @(*) begin
	case (mux_sel)
	2'b00: TX_OUT = In_0; 	// Select stop bit
	2'b01: TX_OUT = In_1;	// Select start bit
	2'b10: TX_OUT = In_2;	// Select serialized data bit
	default: TX_OUT = In_3;	// Select parity bit
	endcase
end

endmodule