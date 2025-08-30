module FSM (
	input CLK,						// System clock
	input RST,						// Active-low reset
	input Data_Valid,				// High when new data is ready
	input PAR_EN,					// Enable parity bit
	input ser_done,					// Serializer done signal
	output reg [1:0] mux_sel,		// Select line for MUX (start/data/parity/stop)
	output reg busy,				// High when transmission in progress
	output reg ser_en				// Serializer enable
	);

// State encoding
parameter IDLE = 3'b000;
parameter START = 3'b001;
parameter DATA = 3'b010;
parameter PARITY = 3'b011;
parameter STOP = 3'b100;

reg [2:0] cs, ns;  					// Current state and next state

/* State Memory & flag update */
always @(posedge CLK) begin
	if (~RST) begin
		cs <= IDLE;					// Reset to IDLE state
	end
	else begin
		cs <= ns;					// Update to next state
	end
end

/* Next State Logic */
always @(*) begin
	case (cs)
		IDLE: 
			if (Data_Valid) 
				ns = START;	
			else  
				ns = IDLE;		

		START: 
			ns = DATA;

		DATA: 
			if (ser_done) begin
				if (PAR_EN) 
					ns = PARITY;
				else
					ns = STOP;
			end else  
				ns = DATA;

		PARITY: 
			ns = STOP;	

		STOP: 
			ns = IDLE;

		default: ns = IDLE;
	endcase
end

/* Output Logic */
always @(posedge CLK) begin
	if (~RST) begin
		// reset
		busy <= 1'b0;
		mux_sel <= 2'b00;			
		ser_en <= 1'b0;
	end
	else begin
		case (cs)
		IDLE: begin
			busy <= 1'b0;
			mux_sel <= 2'b00;		// Idle line
            ser_en  <= 1'b0;
		end
		START: begin
			busy <= 1'b1;
			mux_sel <= 2'b01;		// Start bit
			ser_en <= 1'b1;			// Enable serializer
		end
		DATA: begin
			busy <= 1'b1;
			mux_sel <= 2'b10;		// Data bits
			// ser_en stays high from START
		end
		PARITY: begin
			busy <= 1'b1;
			mux_sel <= 2'b11;		// Parity bit
			ser_en <= 1'b0;			// Disable serializer
		end
		STOP: begin
			busy <= 1'b1;
			mux_sel <= 2'b00;		// Stop bit
			ser_en <= 1'b0;
		end
		default: begin
			busy <= 1'b0;
			mux_sel <= 2'd0;
			ser_en  <= 1'b0;
		end
		endcase
	end
end

endmodule