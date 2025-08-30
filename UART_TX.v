module UART_TX (
	input CLK,				// System clock
	input RST,				// Active-low reset
	input PAR_TYP,			// Party type
	input PAR_EN,			// Parity enable
	input [7:0] P_DATA,		// Parallel data input
	input DATA_VALID,		// Data valid signal
	output TX_OUT,			// UART transmit output
	output Busy				// Transmitter busy status
	);

// Constant signals
wire start_bit = 1'b0;   	// Start bit '0'
wire stop_bit  = 1'b1;   	// Stop bit '1'

// Internal connection signals
wire ser_done;           	// Indicates serializer finished sending all bits
wire ser_en;             	// Serializer enable from FSM
wire ser_data;           	// Serial data output from serializer
wire par_bit;            	// Parity bit from parity calculator
wire [1:0] mux_sel;      	// MUX select lines from FSM

/* Serializer Instance */
Serializer my_serializer (
	.CLK(CLK),
	.RST(RST),
	.P_DATA(P_DATA),
	.ser_en(ser_en),
	.ser_data(ser_data),
	.ser_done(ser_done)
	);

/* FSM Controller Instance */
FSM my_fsm (
	.CLK(CLK),
	.RST(RST),
	.Data_Valid(DATA_VALID),
	.PAR_EN(PAR_EN),
	.ser_done(ser_done),
	.mux_sel(mux_sel),
	.busy(Busy),
	.ser_en(ser_en)
	);

/* Parity Calculator Instance */
Parity_Calc my_parity_calc (
	.CLK(CLK),
	.RST(RST),
	.P_DATA(P_DATA),
	.Data_Valid(DATA_VALID),
	.PAR_TYP(PAR_TYP),
	.par_bit(par_bit)
	);

/* MUX Instance */
MUX my_mux (
	.In_0(stop_bit),
	.In_1(start_bit),
	.In_2(ser_data),
	.In_3(par_bit),
	.mux_sel(mux_sel),
	.TX_OUT(TX_OUT)
	);

endmodule