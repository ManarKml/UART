`timescale 1ps/1ps

module UART_TX_tb;

// Testbench signals
reg CLK;
reg RST;
reg PAR_TYP;         // 0 = even, 1 = odd
reg PAR_EN;          // 0 = no parity, 1 = parity enabled
reg [7:0] P_DATA;
reg DATA_VALID;
wire TX_OUT;
wire Busy;

// Self check signals
reg [10:0] expected_out;
reg [7:0] data;
reg parity_enable;
reg parity_type;
integer bit_index;
integer length;

// Instantiate DUT
UART_TX dut (
    .CLK(CLK),
    .RST(RST),
    .PAR_TYP(PAR_TYP),
    .PAR_EN(PAR_EN),
    .P_DATA(P_DATA),
    .DATA_VALID(DATA_VALID),
    .TX_OUT(TX_OUT),
    .Busy(Busy)
);

// Clock generation (200 MHz -> 5 ns -> 5000 ps period)
initial begin
    CLK = 0;
    forever #2500 CLK = ~CLK;
end

initial begin
    // Initialize signals
    RST = 0;
    DATA_VALID = 0;
    PAR_EN = 0;
    PAR_TYP = 0;
    P_DATA = 8'd0;

    expected_out = 11'b0;
    data = 8'b0;

    // Apply reset
    repeat (5) @(negedge CLK);
    RST = 1;

    // Send bytes with different settings
    repeat (10) begin
        data = $random;
        parity_enable = $random;
        parity_type = $random;

        send_byte(data, parity_enable, parity_type);
        @(negedge CLK);
        check_out(data, parity_enable, parity_type);

        repeat (5) @(negedge CLK);
    end

    // End simulation
    $stop;
end

// Task to send a byte
task send_byte(input [7:0] data, input parity_enable, input parity_type);
begin
    @(negedge CLK);
    PAR_EN = parity_enable;
    PAR_TYP = parity_type;
    P_DATA = data;
    DATA_VALID = 1'b1; // Assert for 1 cycle
    @(negedge CLK);
    DATA_VALID = 1'b0;
    // Wait until transmission is complete
    //repeat (20) @(negedge CLK);
end
endtask

task check_out(input [7:0] data, input parity_enable, input parity_type);
begin
    expected_out[10] = 1'b0; // Start bit (MSB)
    expected_out[9:2] = data; // Data bits (MSB first)
    
    if (parity_enable) begin
        expected_out[1] = (parity_type)? ~(^data) : (^data); // Parity bit
        expected_out[0] = 1'b1; // Stop bit
        length = 11;
    end else begin
        expected_out[1] = 1'b1; // Stop bit
        length = 10;
    end

    for (bit_index = 10; bit_index >= 11 - length; bit_index = bit_index - 1) begin
        if (TX_OUT != expected_out[bit_index]) begin
            $display("Error!");
            $stop;
        end
        @(negedge CLK);
    end
end
endtask

endmodule
