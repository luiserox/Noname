/*
* Wishbone Module B4
* Classic Implementation:
* Luis Ruiz
*/

module WBU(clk_i, rst_i, wbm_we_i, wbm_re_i, wbm_kill_i, wbm_cyc_o,  
wbs_ack_i, wbs_cyc_o, wbs_stb_o, wbs_we_o);

	input wire clk_i;
	input wire rst_i;

	//Maquina de estados
	localparam wbu_state_idle = 3'b001;
	localparam wbu_state_tran = 3'b010;
	localparam wbu_state_endtran = 3'b100;

	reg [2:0] wbu_state;

	//Comunicacion con pipeline
	input wire wbm_we_i;
	input wire wbm_re_i;
	input wire wbm_kill_i;
	output reg wbm_cyc_o;

	//Comunicacion con memoria
	input wire wbs_ack_i;
	output reg wbs_cyc_o;
	output reg wbs_stb_o;
	output reg wbs_we_o;

	//Buffer de entradas y salidas
	always @(*) begin
		wbs_we_o = wbm_we_i;
		wbm_cyc_o = wbs_cyc_o;
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
				default:begin
					wbu_state <= wbu_state_idle;
				end
			endcase
		end

	end
endmodule