/*
* Instruction Fetch Stage
* Anderson Contreras
*/

module stage_if(clk_i, rst_i, branch_addr_i, sel_addr_i, stall_i, mis_addr_exc_o, pc_o);
  input clk_i;
  input rst_i;

  input [31:0] branch_addr_i;
  input sel_addr_i;
  input stall_i;
  output mis_addr_exc_o;
  output reg [31:0] pc_o;

  assign mis_addr_exc_o = pc_o[0] | pc_o[1];

  // PC's
  always @(posedge clk_i) begin
    if (rst_i)
      pc_o = 0;
    else if (!stall_i)
      pc_o = (sel_addr_i) ? branch_addr_i : pc_o + 4;
  end
endmodule
