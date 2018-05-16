/*
* Wishbone Module B4
* Classic Implementation:
* Luis Ruiz
*/

module WBU(clk_i, rst_i, wbm_dat_i, wbm_addr_i, wbm_sel_i, wbm_we_i, wbm_ack_o, wbm_dat_o, wbm_err_o,  
wbs_dat_i, wbs_ack_i, wbs_err_i, wbs_cyc_o, wbs_stb_o, wbs_dat_o, wbs_addr_o, wbs_we_o, wbs_sel_o);

	input wire clk_i;
	input wire rst_i;

	//Comunicacion con pipeline
	input wire [31:0] wbm_dat_i;
	input wire [31:0] wbm_addr_i;
	input wire [3:0] wbm_sel_i;
	input wire wbm_we_i;
	output reg wbm_ack_o;
	output reg [31:0] wbm_dat_o;
	output reg wbm_err_o;

	//Comunicacion con memoria
	input wire [31:0] wbs_dat_i;
	input wire wbs_ack_i;
	input wire wbs_err_i;
	output reg wbs_cyc_o;
	output reg wbs_stb_o;
	output reg [31:0] wbs_dat_o;
	output reg [31:0] wbs_addr_o;
	output reg wbs_we_o;
	output reg [3:0] wbs_sel_o;
/*
*	assign wbm_ack_o = wbs_ack_i;
*	assign wbm_err_o = wbs_err_i;
*	assign wbm_dat_o = wbs_dat_i;
*	assign wbs_dat_o = wbm_dat_i;
*	assign wbs_addr_o = wbm_addr_i;
*	assign wbs_we_o = wbm_we_i;
*/

	always @(posedge clk_i) begin
		if (rst_i) begin

		end else begin
			if(wbm_we_i) begin
				if(wbs_err_i) begin
					wbm_err_o.next <= wbs_err_i;
				end else if(!wbs_cyc_o && !wbs_stb_o) begin
					wbm_err_o <= wbs_err_i;
					wbs_addr_o <= wbm_addr_i;
					wbs_dat_o <= wbm_dat_i;
					wbs_we_o <= wbm_we_i;
					wbs_sel_o <= wbm_sel_i;
					wbs_cyc_o <= 1;
					wbs_stb_o <= 1;
				end else if(wbs_ack_i) begin
					wbs_cyc_o <= 0;
					wbs_stb_o <= 0;
				end
			end else begin
				if(wbs_err_i) begin
					wbm_err_o <= wbs_err_i;
				end else if(!wbs_cyc_o && !wbs_stb_o) begin
					wbm_err_o <= wbs_err_i;
					wbs_addr_o <= wbm_addr_i;
					wbs_we_o <= 0;
					wbs_sel_o <= wbm_sel_i;
					wbs_cyc_o <= 1;
					wbs_stb_o <= 1;
				end else if(wbs_ack_i && wbs_stb_o) begin
					wbs_stb_o <= 0;
				end else if(wbs_ack_i && !wbs_stb_o) begin
					wbs_cyc_o <= 0;
					wbs_dat_o <= wbm_dat_i;
				end
			end

		end

	end
endmodule

