/*
* ALU Module
* Operations supported:
*   - Arithmetic: addition, subtraction
*   - Logical: and, or, xor
*   - Shift: shift right logical, shift left logical, shift right arithmetic
*   - Comparison: set less than, set less than unsigned
* Output flags: equal, less than, less than unsigned
*
* Anderson Contreras
*/

//Currently the clk_i and rst_i are only for simulation purposes

module alu(clk_i, rst_i, in0_i, in1_i, op_i, equ_o, lt_o, ltu_o, out_o);
  localparam ALU_ADD  = 4'b0000;
  localparam ALU_SUB  = 4'b1000;
  localparam ALU_AND  = 4'b0111;
  localparam ALU_OR   = 4'b0110;
  localparam ALU_XOR  = 4'b0100;
  localparam ALU_SRL  = 4'b0101;
  localparam ALU_SLL  = 4'b0001;
  localparam ALU_SRA  = 4'b1101;
  localparam ALU_SLT  = 4'b0010;
  localparam ALU_SLTU = 4'b0011;

  input clk_i;
  input rst_i;

  input signed [31:0] in0_i;
  input signed [31:0] in1_i;
  input [3:0] op_i;
  output [31:0] out_o;
  output equ_o;
  output lt_o;
  output ltu_o;


  wire [31:0] add_res  = in0_i + in1_i;
  wire [31:0] sub_res  = in0_i - in1_i;
  wire [31:0] and_res  = in0_i & in1_i;
  wire [31:0] or_res   = in0_i | in1_i;
  wire [31:0] xor_res  = in0_i ^ in1_i;
  wire [31:0] srl_res  = in0_i >> in1_i;
  wire [31:0] sll_res  = in0_i << in1_i;
  wire [31:0] sra_res  = in0_i >>> in1_i;
  wire [31:0] slt_res  = (in0_i < in1_i) ? 1 : 0;
  wire [31:0] sltu_res = ($unsigned(in0_i) < $unsigned(in1_i)) ? 1 : 0;

  assign equ_o = ~(|xor_res);
  assign lt_o  = slt_res[0];
  assign ltu_o = sltu_res[0];


  always @(*) begin
    case(op_i)
      ALU_ADD:  out_o = add_res;
      ALU_SUB:  out_o = sub_res;
      ALU_AND:  out_o = and_res;
      ALU_OR:   out_o = or_res;
      ALU_XOR:  out_o = xor_res;
      ALU_SRL:  out_o = srl_res;
      ALU_SLL:  out_o = sll_res;
      ALU_SRA:  out_o = sra_res;
      ALU_SLT:  out_o = slt_res;
      ALU_SLTU: out_o = sltu_res;
    endcase
  end
endmodule
