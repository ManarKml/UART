module UART (
	input	     TX_CLK,			// UART TX Clock Signal
	input	     RX_CLK,			// UART RX Clock Signal
	input	     RST,				// Synchronized reset signal
	input	     PAR_TYP,			// Parity Type
	input	 	 PAR_EN,			// Parity Enable
	input  [5:0] Prescale,			// Oversampling Prescale
	input  [7:0] TX_IN_P,			// Input TX data byte
	input 		 TX_IN_V,			// Input TX data valid signal
	input 		 RX_IN_S,			// Input RX UART frame
	output 		 TX_OUT_S,			// TX Frame Serial Out
	output 		 TX_OUT_V,			// TX Out Valid signal
	output [7:0] RX_OUT_P,			// RX Out Data
	output 		 RX_OUT_V			// RX Out Data Valid signal
	);

wire Parity_Error;
wire Stop_Error;

// Instantiate the transmitter module
UART_TX Tx (
    .CLK(TX_CLK),
    .RST(RST),
    .PAR_TYP(PAR_TYP),
    .PAR_EN(PAR_EN),
    .P_DATA(TX_IN_P),
    .DATA_VALID(TX_IN_V),
    .TX_OUT(TX_OUT_S),
    .Busy(TX_OUT_V)
);

// Instantiate the receiver module
UART_RX Rx (
	.CLK(RX_CLK),
	.RST(RST),
	.PAR_TYP(PAR_TYP),
	.PAR_EN(PAR_EN),
	.Prescale(Prescale),
	.RX_IN(RX_IN_S),
	.P_DATA(RX_OUT_P),
	.Data_Valid(RX_OUT_V),
	.Parity_Error(Parity_Error),
	.Stop_Error(Stop_Error)
	);

endmodule