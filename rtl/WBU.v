/*
* Wishbone Module B4
* Classic Implementation:
* Luis Ruiz
*/

module WBU(clk_i, rst_i, wbm_we_i, wbm_re_i, wbm_kill_i, wbm_ack_o, wbm_err_o,  
wbs_ack_i, wbs_err_i, wbs_cyc_o, wbs_stb_o, wbs_we_o);

	input wire clk_i;
	input wire rst_i;

	//Maquina de estados
	localparam wbu_state_idle = 2'b01;
	localparam wbu_state_tran = 2'b10;


	reg [1:0] wbu_state;

	//Comunicacion con pipeline
	input wire wbm_we_i;
	input wire wbm_re_i;
	input wire wbm_kill_i;
	output reg wbm_ack_o;
	output reg wbm_err_o;

	//Comunicacion con memoria
	input wire wbs_ack_i;
	input wire wbs_err_i;
	output reg wbs_cyc_o;
	output reg wbs_stb_o;
	output reg wbs_we_o;

	//Buffer de entradas y salidas
	always @(*) begin
		wbs_we_o = wbm_we_i;
		wbm_err_o = wbs_err_i;
		wbm_ack_o = wbs_ack_i;
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
						wbs_cyc_o <= 1;
						wbs_stb_o <= 1;
						wbu_state <= wbu_state_tran;
					end
				end
				wbu_state_tran: begin
					if(wbm_kill_i) begin
						wbu_state <= wbu_state_idle;
					end else
						if(wbs_ack_i || wbs_err_i) begin
							wbs_cyc_o <= 0;
							wbs_stb_o <= 0;
							wbu_state <= wbu_state_idle;
						end
				end
				default:begin
					wbu_state <= wbu_state_idle;
				end
			endcase
		end

	end
endmodule