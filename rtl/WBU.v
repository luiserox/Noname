/*
* Wishbone Module B4
* Classic Implementation:
* Luis Ruiz
*/

module WBU(clk_i, rst_i, wbm_dat_i, wbm_addr_i, wbm_sel_i, wbm_we_i, wbm_re_i, wbm_kill_i, wbm_ack_o, wbm_dat_o, wbm_err_o,  
wbs_dat_i, wbs_ack_i, wbs_err_i, wbs_cyc_o, wbs_stb_o, wbs_dat_o, wbs_addr_o, wbs_we_o, wbs_sel_o);

	input wire clk_i;
	input wire rst_i;

	//Maquina de estados
	localparam wbu_state_idle = 9'b000000001;
	localparam wbu_state_wstart = 9'b000000010;
	localparam wbu_state_wack = 9'b000000100;
	localparam wbu_state_wend = 9'b000001000;
	localparam wbu_state_rstart = 9'b000010000;
	localparam wbu_state_rack = 9'b000100000;
	localparam wbu_state_rend = 9'b001000000;
	localparam wbu_state_err = 9'b010000000;
	localparam wbu_state_kill = 9'b100000000;

	//Comunicacion con pipeline
	input wire [31:0] wbm_dat_i;
	input wire [31:0] wbm_addr_i;
	input wire [3:0] wbm_sel_i;
	input wire wbm_we_i;
	input wire wbm_re_i;
	input wire wbm_kill_i;
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

	reg [8:0] wbu_state;

	always @(posedge clk_i) begin
		if (rst_i) begin
			wbu_state <= wbu_state_idle;
		end else begin
			case(wbu_state)
				wbu_state_idle: begin
					if(wbm_we_i) begin
						wbu_state <= wbu_state_wstart;
					end else if(wbm_re_i) begin
						wbu_state <= wbu_state_rstart;
					end
				end
				wbu_state_wstart: begin
					if(wbm_kill_i) begin
						wbu_state <= wbu_state_kill;
					end else
					wbm_err_o <= wbs_err_i;
					wbs_addr_o <= wbm_addr_i;
					wbs_dat_o <= wbm_dat_i;
					wbs_we_o <= wbm_we_i;
					wbs_sel_o <= wbm_sel_i;
					wbs_cyc_o <= 1;
					wbs_stb_o <= 1;
					wbu_state <= wbu_state_wack;
					end
				end
				wbu_state_wack: begin
					if(wbm_kill_i) begin
						wbu_state <= wbu_state_kill;
					end else if(wbs_err_i) begin
						wbu_state <= wbu_state_err;
					end else if(wbs_ack_i) begin
						wbm_ack_o <= wbs_ack_i;
						wbu_state <= wbu_state_wend;
					end
				end
				wbu_state_wend: begin
					if(wbm_kill_i) begin
						wbu_state <= wbu_state_kill;
					end else
						wbs_cyc_o <= 0;
						wbs_stb_o <= 0;
						wbu_state <= wbu_state_idle;
					end
				end
				wbu_state_rstart: begin
					if(wbm_kill_i) begin
						wbu_state <= wbu_state_kill;
					end else
						wbm_err_o <= wbs_err_i;
						wbs_addr_o <= wbm_addr_i;
						wbs_we_o <= 0;
						wbs_sel_o <= wbm_sel_i;
						wbs_cyc_o <= 1;
						wbs_stb_o <= 1;
						wbu_state <= wbu_state_rack;
					end
				end
				wbu_state_rack: begin
					if(wbm_kill_i) begin
						wbu_state <= wbu_state_kill;
					end else
						wbs_stb_o <= 0;
						if(wbs_err_i) begin
							wbm_err_o.next <= wbs_err_i;
							wbu_state <= wbu_state_idle;
						end else if(wbs_ack_i) begin
							wbm_ack_o <= wbs_ack_i;
							wbu_state <= wbu_state_rend;
					end
				end
				wbu_state_rend: begin
					if(wbm_kill_i) begin
						wbu_state <= wbu_state_kill;
					end else
						wbs_cyc_o <= 0;
						wbs_dat_o <= wbm_dat_i;
						wbu_state <= wbu_state_idle;
					end
				end
				wbu_state_err: begin
					if(wbm_kill_i) begin
						wbu_state <= wbu_state_kill;
					end else
						wbm_err_o <= wbs_err_i;
						wbs_cyc_o <= 0;
						wbs_stb_o <= 0;	
						wbu_state <= wbu_state_idle;
					end				
				end
				wbu_state_kill: begin
					wbs_cyc_o <= 0;
					wbs_stb_o <= 0;	
					wbu_state <= wbu_state_idle;
				end
			endcase
		end

	end
endmodule