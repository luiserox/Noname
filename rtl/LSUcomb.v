/*
* LSU unidad combinatoria
* Classic Implementation:
* Luis Ruiz
*/

module LSUcomb(clk_i, rst_i, mem_dat_i, mem_addr_i, mem_we_i, mem_re_i, mem_type_i, mem_sign_i, mem_err_o, mem_dat_o, 
	lsu_dat_i, lsu_sel_o, lsu_addr_o, lsu_dat_o, lsu_we_o, lsu_re_o);

	input wire rst_i;
	input wire clk_i;


	input wire [31:0] mem_dat_i;
	input wire [31:0] mem_addr_i;
	input wire mem_we_i;
	input wire mem_re_i;
	input wire [1:0] mem_type_i;
	input wire mem_sign_i;
	input wire [31:0] lsu_dat_i;

	output reg mem_err_o;
	output reg [31:0] mem_dat_o;
	output reg [3:0] lsu_sel_o;
	output reg [31:0] lsu_addr_o;
	output reg [31:0] lsu_dat_o;
	output reg lsu_we_o;
	output reg lsu_re_o;

	localparam mem_type_word = 2'b11;
	localparam mem_type_half = 2'b10;
	localparam mem_type_byte = 2'b01;


	//Circuito combinatorio
	always @(*) begin
		if(mem_we_i) begin
			case(mem_type_i)
				mem_type_word: begin
					if(mem_addr_i[1:0]) begin
						mem_err_o = 1;
					end else begin
						lsu_we_o = 1;
						lsu_sel_o = 4'b1111;
						lsu_addr_o = mem_addr_i;
						lsu_dat_o = mem_dat_i;
					end
				end
				mem_type_half: begin
					if(mem_addr_i[0]) begin
						mem_err_o = 1;
					end else begin
						lsu_we_o = 1;
						lsu_dat_o = {mem_dat_i[15:0], mem_dat_i[15:0]};
						lsu_addr_o = {mem_addr_i[31:2], 2'b00};
						if(mem_addr_i[1])begin
							lsu_sel_o = 4'b1100;
						end else begin
							lsu_sel_o = 4'b0011;
						end
					end
				end
				mem_type_byte: begin
					lsu_we_o = 1;
					lsu_dat_o = {mem_dat_i[7:0], mem_dat_i[7:0], mem_dat_i[7:0], mem_dat_i[7:0]};
					lsu_addr_o = {mem_addr_i[31:2], 2'b00};
					case(mem_addr_i[1:0])
						2'b00: lsu_sel_o = 4'b0001;
						2'b01: lsu_sel_o = 4'b0010;
						2'b10: lsu_sel_o = 4'b0100;
						2'b11: lsu_sel_o = 4'b1000;
					endcase
				end
			endcase
		end else if(mem_re_i)begin
			case(mem_type_i)
				mem_type_word: begin
					if(mem_addr_i[1:0]) begin
						mem_err_o = 1;
					end else begin
						lsu_re_o = 1;
						lsu_addr_o = mem_addr_i;
						mem_dat_o = lsu_dat_i;
					end
				end
				mem_type_half: begin
					if(mem_addr_i[0]) begin
						mem_err_o = 1;
					end else begin
						lsu_re_o = 1;
						lsu_addr_o = {mem_addr_i[31:2], 2'b00};
						if(mem_addr_i[1])begin
							if(mem_sign_i && lsu_dat_i[31]) mem_dat_o = {16'hFFFF,lsu_dat_i[31:16]};
							else mem_dat_o = {16'h0000,lsu_dat_i[31:16]};
						end else begin
							if(mem_sign_i && lsu_dat_i[15]) mem_dat_o = {16'hFFFF,lsu_dat_i[15:0]};
							else mem_dat_o = {16'h0000,lsu_dat_i[15:0]};
						end
					end
				end
				mem_type_byte: begin
					lsu_re_o = 1;
					lsu_addr_o = {mem_addr_i[31:2], 2'b00};
					case(mem_addr_i[1:0])
						2'b00: begin
							if(mem_sign_i && lsu_dat_i[7]) mem_dat_o = {24'hFFFFFF,lsu_dat_i[7:0]};
							else mem_dat_o = {24'h000000,lsu_dat_i[7:0]};
						end
						2'b01: begin
							if(mem_sign_i && lsu_dat_i[15]) mem_dat_o = {24'hFFFFFF,lsu_dat_i[15:8]};
							else mem_dat_o = {24'h000000,lsu_dat_i[15:8]};
						end
						2'b10: begin
							if(mem_sign_i && lsu_dat_i[23]) mem_dat_o = {24'hFFFFFF,lsu_dat_i[23:16]};
							else mem_dat_o = {24'h000000,lsu_dat_i[23:16]};
						end
						2'b11: begin
							if(mem_sign_i && lsu_dat_i[31]) mem_dat_o = {24'hFFFFFF,lsu_dat_i[31:24]};
							else mem_dat_o = {24'h000000,lsu_dat_i[31:24]};
						end
					endcase
				end
			endcase
		end
	end

endmodule