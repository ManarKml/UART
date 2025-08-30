module FSM_RX (
	input CLK,					// System clock
	input RST,					// Active-low reset
	input RX_IN,				// Serial input
	input PAR_EN,				// Parity enable
	input [5:0] edge_cnt,		// Edge counter for mid-bit sampling
	input [3:0] bit_cnt,		// Bit counter for the uart frame
	input strt_glitch,			// Start glitch flag
	input par_err,				// Parity error flag
	input stp_err,				// Stop error flag
	output reg dat_samp_en,		// Enable sampler
	output reg enable,			// Enable edge/bit counters
	output reg strt_chk_en,		// Enable start check
	output reg par_chk_en,		// Enable parity check
	output reg stp_chk_en,		// Enable stop check
	output reg deser_en,		// Enable deserializer
	output reg data_valid,		// Frame completed successfully
	output reg Parity_Error,	// Flag parity error
	output reg Stop_Error 		// Flag stop error
	);

// State encoding
parameter IDLE = 3'b000;
parameter START = 3'b001;
parameter DATA = 3'b010;
parameter PARITY = 3'b011;
parameter STOP = 3'b100;

reg [2:0] cs, ns;  				// Current state and next state

/* State Memory */
always @(posedge CLK) begin
	if (~RST) begin
		cs <= IDLE;				// Reset to IDLE state
	end
	else begin
		cs <= ns;				// Update to next state
	end
end

/* Next State Logic */
always @(*) begin
	case (cs)
		IDLE: 
			if (RX_IN == 1'b0) 	// Detect start bit
				ns = START;	
			else  
				ns = IDLE;	

		START: 
			if (strt_glitch) 
				ns = IDLE;
			else if (bit_cnt == 1) 
				ns = DATA;
			else
				ns = START;

		DATA: 
			if (bit_cnt == 9) begin
				if (PAR_EN) 
					ns = PARITY;
				else
					ns = STOP;
			end else  
				ns = DATA;

		PARITY: 
			if (bit_cnt == 10)
				ns = STOP;	
			else  
				ns = PARITY;

		STOP: 
			if (bit_cnt == (PAR_EN? 11 : 10))
				ns = IDLE;

		default: ns = IDLE;
	endcase
end

/* Output Logic */
always @(posedge CLK) begin
	if (~RST) begin
		// reset
		dat_samp_en <= 1'b0;
		enable <= 1'b0;
		strt_chk_en <= 1'b0;
		par_chk_en <= 1'b0;
		stp_chk_en <= 1'b0;
		deser_en <= 1'b0;
		data_valid <= 1'b0;
		Parity_Error <= 1'b0;
		Stop_Error <= 1'b0;
	end
	else begin
		case (cs)
		IDLE: begin
			dat_samp_en <= 1'b0;
			enable <= 1'b0;
			strt_chk_en <= 1'b0;
			par_chk_en <= 1'b0;
			stp_chk_en <= 1'b0;
			deser_en <= 1'b0;
			data_valid <= 1'b0;
			Parity_Error <= 1'b0;
			Stop_Error <= 1'b0;
		end
		START: begin
			dat_samp_en <= 1'b1;		// Enable the sampler
			enable <= 1'b1;				// Enable edge_bit_counter
			strt_chk_en <= 1'b1;		// Enable strt_check
			par_chk_en <= 1'b0;
			stp_chk_en <= 1'b0;
			deser_en <= 1'b0;
			data_valid <= 1'b0;
			Parity_Error <= 1'b0;
			Stop_Error <= 1'b0;
		end
		DATA: begin
			dat_samp_en <= 1'b1;		// Keep sampler enabled
			enable <= 1'b1;				// Keep counter enabled
			strt_chk_en <= 1'b0;		// Disable strt_check
			par_chk_en <= (PAR_EN);		// Enable par_check if parity is enabled
			stp_chk_en <= 1'b0;
			deser_en <= 1'b1;			// Enable deserializer
			data_valid <= 1'b0;
			Parity_Error <= 1'b0;
			Stop_Error <= 1'b0;
		end
		PARITY: begin
			dat_samp_en <= 1'b1;		// Keep sampler enabled
			enable <= 1'b1;				// Keep counter enabled
			strt_chk_en <= 1'b0;
			par_chk_en <= (PAR_EN);		// Enable par_check if parity is enabled
			stp_chk_en <= 1'b0;
			deser_en <= 1'b0;			// Disable serializer
			data_valid <= 1'b0;
			Parity_Error <= (PAR_EN? par_err : 1'b0);
			Stop_Error <= 1'b0;
		end
		STOP: begin
			dat_samp_en <= 1'b1;		// Keep sampler enabled
			enable <= 1'b1;				// Keep counter enabled
			strt_chk_en <= 1'b0;
			par_chk_en <= 1'b0;			// Disable parity checker if it was enabled
			stp_chk_en <= 1'b1;			// Enable stp_checker
			deser_en <= 1'b0;
			if (bit_cnt == (PAR_EN? 11 : 10)) 
				data_valid <= (Parity_Error == 0 && stp_err == 0);
			else 
				data_valid <= 1'b0;

			Stop_Error <= stp_err;
		end
		default: begin
			dat_samp_en <= 1'b0;
			enable <= 1'b0;
			strt_chk_en <= 1'b0;
			par_chk_en <= 1'b0;
			stp_chk_en <= 1'b0;
			deser_en <= 1'b0;
			data_valid <= 1'b0;
			Parity_Error <= 1'b0;
			Stop_Error <= 1'b0;
		end
		endcase
	end
end

endmodule