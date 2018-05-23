/*
* Wishbone Module B4
* Classic Implementation:
* Luis Ruiz
*/

module WBU(clk_i, rst_i, wbm_dat_i, wbm_addr_i, wbm_sel_i, wbm_we_i, wbm_re_i, wbm_kill_i, wbm_cyc_o, wbm_dat_o, wbm_err_o,  
wbs_dat_i, wbs_ack_i, wbs_err_i, wbs_cyc_o, wbs_stb_o, wbs_dat_o, wbs_addr_o, wbs_we_o, wbs_sel_o);

	input wire clk_i;
	input wire rst_i;

	//Maquina de estados
	localparam wbu_state_idle = 3'b001;
	localparam wbu_state_tran = 3'b010;
	localparam wbu_state_endtran = 3'b100;

	reg [2:0] wbu_state;

	//Comunicacion con pipeline
	input wire [31:0] wbm_dat_i;
	input wire [31:0] wbm_addr_i;
	input wire [3:0] wbm_sel_i;
	input wire wbm_we_i;
	input wire wbm_re_i;
	input wire wbm_kill_i;
	output reg wbm_cyc_o;
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

	//Buffer de entradas y salidas
	always @(*) begin
		assign wbs_we_o = wbm_we_i;
		assign wbs_sel_o = wbm_sel_i;
		assign wbs_addr_o = wbm_addr_i;
		assign wbs_dat_o = wbm_dat_i;
		assign wbm_dat_o = wbs_dat_i;
		assign wbm_err_o = wbs_err_i;
		assign wbm_cyc_o = wbs_cyc_o;
	end

	always @(posedge clk_i) begin
		if (rst_i) begin
			wbu_state <= wbu_state_idle;
		end else begin
			case(wbu_state)
				wbu_state_idle: begin
					wbs_cyc_o <= 0;
					wbs_stb_o <= 0;
					if(wbm_we_i ^ wbm_re_i) begin
						wbu_state <= wbu_state_tran;
					end
				end
				wbu_state_tran: begin
					if(wbm_kill_i) begin
						wbu_state <= wbu_state_idle;
					end else
						wbs_cyc_o <= 1;
						wbs_stb_o <= 1;
						if(wbs_ack_i || wbs_err_i) begin
							wbu_state <= wbu_state_endtran;
						end
				end
				wbu_state_endtran: begin
					wbs_cyc_o <= 0;
					wbs_stb_o <= 0;
					wbu_state <= wbu_state_idle;
				end
			endcase
		end

	end
endmodule