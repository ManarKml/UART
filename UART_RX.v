module UART_RX (
	input CLK,
	input RST,
	input PAR_TYP,
	input PAR_EN,
	input [5:0] Prescale,
	input RX_IN,
	output [7:0] P_DATA,
	output Data_Valid,
	output Parity_Error,
	output Stop_Error
	);

wire dat_samp_en;
wire [5:0] edge_cnt;
wire [3:0] bit_cnt;
wire enable;
wire deser_en;
wire par_chk_en;
wire par_err;
wire strt_chk_en;
wire strt_glitch;
wire stp_chk_en;
wire stp_err;
wire sampled_bit;

data_sampling sampler (
	.CLK(CLK),
	.RST(RST),
	.RX_IN(RX_IN),
	.dat_samp_en(dat_samp_en),
	.edge_cnt(edge_cnt),
	.Prescale(Prescale),
	.sampled_bit(sampled_bit)
	);

edge_bit_counter counter (
	.CLK(CLK),
	.RST(RST),
	.enable(enable),
	.Prescale(Prescale),
	.edge_cnt(edge_cnt),
	.bit_cnt(bit_cnt)
	);

deserializer deser (
	.CLK(CLK),
	.RST(RST),
	.sampled_bit(sampled_bit),
	.deser_en(deser_en),
	.edge_cnt(edge_cnt),
	.P_DATA(P_DATA)
	);

Parity_Check par_chk (
	.CLK(CLK),
	.RST(RST),
	.par_chk_en(par_chk_en),
	.sampled_bit(sampled_bit),
	.PAR_TYP(PAR_TYP),
	.edge_cnt(edge_cnt),
	.par_err(par_err)
	);

Strt_Check strt_chk (
	.CLK(CLK),
	.RST(RST),
	.strt_chk_en(strt_chk_en),
	.sampled_bit(sampled_bit),
	.edge_cnt(edge_cnt),
	.strt_glitch(strt_glitch)
	);

Stop_Check stop_chk (
	.CLK(CLK),
	.RST(RST),
	.stp_chk_en(stp_chk_en),
	.sampled_bit(sampled_bit),
	.edge_cnt(edge_cnt),
	.stp_err(stp_err)
	);

FSM_RX fsm (
	.CLK(CLK),
	.RST(RST),
	.RX_IN(RX_IN),
	.PAR_EN(PAR_EN),
	.edge_cnt(edge_cnt),
	.bit_cnt(bit_cnt),
	.strt_glitch(strt_glitch),
	.par_err(par_err),
	.stp_err(stp_err),
	.dat_samp_en(dat_samp_en),
	.enable(enable),
	.strt_chk_en(strt_chk_en),
	.par_chk_en(par_chk_en),
	.stp_chk_en(stp_chk_en),
	.deser_en(deser_en),
	.data_valid(Data_Valid),
	.Parity_Error(Parity_Error),
	.Stop_Error(Stop_Error)
	);

endmodule