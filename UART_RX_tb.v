`timescale 1ns/1ps

module UART_RX_tb;

// Inputs
reg CLK;
reg RST;
reg PAR_TYP;
reg PAR_EN;
reg [5:0] Prescale;
reg RX_IN;

// Outputs
wire [7:0] P_DATA;
wire Data_Valid;
wire Parity_Error;
wire Stop_Error;

// DUT instantiation
UART_RX dut (
	.CLK(CLK),
	.RST(RST),
	.PAR_TYP(PAR_TYP),
	.PAR_EN(PAR_EN),
	.Prescale(Prescale),
	.RX_IN(RX_IN),
	.P_DATA(P_DATA),
	.Data_Valid(Data_Valid),
	.Parity_Error(Parity_Error),
	.Stop_Error(Stop_Error)
	);

// Clock generation (100 MHz -> 10 ns period)
initial begin
	CLK = 0;
	forever #5 CLK = ~CLK;
end

// Stimulus
initial begin
	// Init
	RX_IN = 1;    // Idle
	RST = 0;
	PAR_TYP = 0;
	PAR_EN = 0;   // Disable parity
	Prescale = 8; // Oversampling by 8
	repeat (5) @(posedge CLK);
	RST = 1;

	// -------------------------
	// 1) Start bit glitch test
	// -------------------------
	$display("\n--- Start bit glitch test ---");
	repeat (10) @(posedge CLK);
	RX_IN <= 0;                  // Send LOW signal
	repeat (Prescale/2) @(posedge CLK); // Too short for valid start
	RX_IN <= 1;                  // Return to idle
	repeat (Prescale*2) @(posedge CLK);

	repeat (10) @(posedge CLK);
	// -------------------------
	// 2) Normal frame (0xA5) with correct parity
	// -------------------------
	$display("\n--- Normal frame with correct parity ---");
	PAR_EN = 1;
	PAR_TYP = 0; // even
	send_byte(8'hA5, PAR_EN, PAR_TYP);

	repeat (10) @(posedge CLK);
	// -------------------------
	// 3) Frame with parity error (0xA5)
	// -------------------------
	$display("\n--- Frame with parity error ---");
	@(posedge CLK);
	send_byte_with_parity_error(8'hA5, PAR_EN, PAR_TYP);

	repeat (10) @(posedge CLK);
	// -------------------------
	// 4) Frame with stop bit error (0xF3)
	// -------------------------
	$display("\n--- Frame with stop bit error ---");
	PAR_EN = 0;
	send_byte_with_stop_error(8'hF3, PAR_EN, PAR_TYP);

	repeat (10) @(posedge CLK);
	// -------------------------
	// 5) Two consecutive frames (0x55 and 0xAA) back-to-back
	// -------------------------
	$display("\n--- Two consecutive frames ---");

	send_byte(8'h55, PAR_EN, PAR_TYP);
	send_byte(8'hAA, PAR_EN, PAR_TYP); // Directly after with no idle gap

	repeat (10) @(posedge CLK);
	$stop;
end

// Task to send UART frame 
task send_byte;
	input [7:0] data;
	input parity_enable;
	input parity_type; // 0=even 1=odd
	integer i, bit_cycles;
	reg parity_bit;
begin
	bit_cycles = Prescale; // Number of clock cycles per bit
	parity_bit = 0;

	// Start bit
	@(posedge CLK) RX_IN = 0;
	repeat (bit_cycles) @(posedge CLK);

	// Data bits (LSB first)
	for (i=0; i<8; i=i+1) begin
		RX_IN = data[7 - i];
		parity_bit = parity_bit ^ data[7 - i];
		repeat (bit_cycles) @(posedge CLK);
	end

	// Optional parity
	if (parity_enable) begin
		RX_IN = (parity_type==0) ? parity_bit : ~parity_bit;
		repeat (bit_cycles) @(posedge CLK);
	end

	// Stop bit
	RX_IN = 1;
	repeat (bit_cycles) @(posedge CLK);
end
endtask

// Task to send frame with wrong parity bit
task send_byte_with_parity_error;
	input [7:0] data;
	input parity_enable;
	input parity_type;
	integer i, bit_cycles;
	reg parity_bit;
begin
	bit_cycles = Prescale;
	parity_bit = 0;

	// Start bit
	@(posedge CLK) RX_IN = 0;
	repeat (bit_cycles) @(posedge CLK);

	// Data bits
	for (i=0; i<8; i=i+1) begin
		RX_IN = data[7 - i];
		parity_bit = parity_bit ^ data[7 - i];
		repeat (bit_cycles) @(posedge CLK);
	end

	// Inject wrong parity bit
	if (parity_enable) begin
		RX_IN = (parity_type==0) ? ~parity_bit : parity_bit; // Flipped
		repeat (bit_cycles) @(posedge CLK);
	end

	// Stop bit
	RX_IN = 1;
	repeat (bit_cycles) @(posedge CLK);
end
endtask

// Task to send frame with stop bit error
task send_byte_with_stop_error;
	input [7:0] data;
	input parity_enable;
	input parity_type;
	integer i, bit_cycles;
	reg parity_bit;
begin
	bit_cycles = Prescale;
	parity_bit = 0;

	// Start bit
	@(posedge CLK) RX_IN = 0;
	repeat (bit_cycles) @(posedge CLK);

	// Data bits
	for (i=0; i<8; i=i+1) begin
		RX_IN = data[7 - i];
		parity_bit = parity_bit ^ data[7 - i];
		repeat (bit_cycles) @(posedge CLK);
	end

	// Optional parity
	if (parity_enable) begin
		RX_IN = (parity_type==0) ? parity_bit : ~parity_bit;
		repeat (bit_cycles) @(posedge CLK);
	end

	// Wrong stop bit (drive 0 instead of 1)
	RX_IN = 0;
	repeat (bit_cycles) @(posedge CLK);

	// Return to idle
	RX_IN = 1;
end
endtask

endmodule

