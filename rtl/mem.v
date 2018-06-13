/*
* MEM Module
*
* Daniela Rivas
* Luis "Batman" Ruiz
*/

/*
*
* clk_i: clock
* rst_i: reset signal
* mem_alu_i: ALU result
* mem_rsc2_i: registro fuente
* mem_pc_i: program counter
* mem_pc4_i: PC + 4
* mem_rd_i: entrada registro destino
* mem_we_i: write enable
* mem_re_i: read enable
* mem_rd_o: salida registro destino
* mem_stall_o: stop next module
* mem_stall_i: stop module
* mem_out_o: output module
* wbs_dat_i:
* wbs_ack_i:
* wbs_err_i:
* wbs_cyc_o:
* wbs_stb_o:
* wbs_dat_o:
* wbs_addr_o:
* wbs_we_o:
* wbs_sel_o:
*
*/

//Currently the clk_i and rst_i are only for simulation purposes

module mem(input wire clk_i, 
  input wire rst_i,
  //Entrada pipeline
  input wire [31:0] mem_alu_i, 
  input wire [31:0] mem_rsc2_i, 
  input wire [31:0] mem_pc_i, 
  input wire [31:0] mem_pc4_i, 
  input wire [4:0] mem_rd_i,
  input wire mem_kill_i,
  input wire mem_we_i, 
  input wire mem_re_i,
  input wire mem_trap_i,
  input wire mem_type_i[1:0],
  input wire mem_sign_i,
  // Salida pipeline
  output reg [31:0] mem_pc_o, 
  output reg [31:0] mem_pc4_o, 
  output reg [31:0] mem_alu_o, 
  output reg [4:0] mem_rd_o, 
  output reg [31:0] mem_out_o,
  output reg mem_stall_o,
  output reg mem_trap_o,
  // Memoria
  input wire [31:0] wbs_dat_i, 
  input wire wbs_ack_i, 
  input wire wbs_err_i, 
  output reg wbs_cyc_o,
  output reg wbs_stb_o, 
  output reg [31:0] wbs_dat_o, 
  output reg [31:0] wbs_addr_o, 
  output reg wbs_we_o, 
  output reg [3:0] wbs_sel_o); 


  wire mem_ack;
  wire bus_err;
  wire addrmiss_err;
  wire mem_we;
  wire mem_re;

  LSUcomb lsucomb(.clk_i(clk_i), .rst_i(rst_i),.mem_dat_i(mem_rsc2_i), .mem_addr_i(mem_alu_i), 
  .mem_we_i(mem_we_i), .mem_re_i(mem_re_i), .mem_type_i(mem_type_i), .mem_sign_i(mem_sign_i), .mem_err_o(addrmiss_err), .mem_dat_o(mem_out_o), 
  .lsu_dat_i(wbs_dat_i), .lsu_sel_o(wbs_sel_o), .lsu_addr_o(wbs_addr_o), .lsu_dat_o(wbs_dat_o), .lsu_we_o(mem_we), .lsu_re_o(mem_re));

  WBU lsu(.clk_i(clk_i), .rst_i(rst_i), 
  .wbm_we_i(mem_we), .wbm_re_i(mem_re), .wbm_kill_i(mem_kill_i), .wbm_ack_o(mem_ack), .wbm_err_o(bus_err),
  .wbs_ack_i(wbs_ack_i), .wbs_err_i(wbs_err_i), .wbs_cyc_o(wbs_cyc_o), .wbs_stb_o(wbs_stb_o), .wbs_we_o(wbs_we_o));


endmodule
