module UART_tb;

// Inputs
reg TX_CLK;
reg	RX_CLK;
reg RST;
reg PAR_TYP;
reg PAR_EN;
reg [5:0] Prescale;
reg [7:0] TX_IN_P;
reg TX_IN_V;
wire RX_IN_S; 

// Outputs
wire TX_OUT_S;
wire TX_OUT_V;
wire [7:0] RX_OUT_P;
wire RX_OUT_V;

// Internal signals
reg [7:0] data;

// Counters
integer error_count;
integer correct_count;

// Connect TX output to RX input
assign RX_IN_S = TX_OUT_S;

// DUT instantiation
UART dut (
	.TX_CLK(TX_CLK),
	.RX_CLK(RX_CLK),
	.RST(RST),
	.PAR_TYP(PAR_TYP),
	.PAR_EN(PAR_EN),
	.Prescale(Prescale),
	.TX_IN_P(TX_IN_P),
	.TX_IN_V(TX_IN_V),
	.RX_IN_S(RX_IN_S),
	.TX_OUT_S(TX_OUT_S),
	.TX_OUT_V(TX_OUT_V),
	.RX_OUT_P(RX_OUT_P),
	.RX_OUT_V(RX_OUT_V)
	);

// TX clock generation
initial begin
	TX_CLK = 0;
	forever #8 TX_CLK = ~TX_CLK;
end

// RX clock generation
initial begin
	RX_CLK = 0;
	forever #1 RX_CLK = ~RX_CLK;
end

// Stimulus
initial begin
	// Reset
	RST = 0;
	PAR_EN = 0;     // Enable parity
	PAR_TYP = 0;    // Even parity
	Prescale = 6'd8; // Oversampling factor
	TX_IN_P = 8'h00;
	TX_IN_V = 0;
	data = 8'h00;
	error_count = 0;
	correct_count = 0;

	repeat (4) @(posedge TX_CLK);
	RST = 1;
	@(posedge TX_CLK);

	// Send first byte
	send_byte(8'hA5);
	check_byte(8'hA5);

	// Send second byte
	PAR_EN = 1;     // Enable parity
	PAR_TYP = 0;    // Even parity
	send_byte(8'h55);
	check_byte(8'h55);

	// Send third byte
	PAR_EN = 1;     // Enable parity
	PAR_TYP = 1;    // Odd parity
	send_byte(8'hFF);
	check_byte(8'hFF);

	// Randomized test
	repeat (10) begin
		data = $random;
		PAR_EN = $random;
		PAR_TYP = $random;
		send_byte(data);
		check_byte(data);
	end

	repeat (5) @(posedge TX_CLK);
	$display("Correct count = %d, Error count = %d", correct_count, error_count);
	$stop;
end

// Send one byte through TX
task send_byte(input [7:0] data);
begin
	@(posedge TX_CLK);
	TX_IN_P = data;
	TX_IN_V = 1;
	@(posedge TX_CLK);
	TX_IN_V = 0;
	// wait until TX is not busy
	@(posedge TX_CLK);
	@(negedge TX_OUT_V);
end
endtask

// Check received byte
task check_byte(input [7:0] expected);
begin
	@(posedge RX_OUT_V); // Wait until valid
	if (RX_OUT_P != expected) begin
		error_count = error_count + 1;
		$display("FAIL: expected %h, got %h", expected, RX_OUT_P);
	end else begin
		correct_count = correct_count + 1;
		$display("PASS: received %h correctly", RX_OUT_P);
	end
end
endtask

endmodule