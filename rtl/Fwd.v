//Forwarding unit

//By 
// Oscar Moreno
// Carlos Sanoja
// Will Chacon
// Luis Ruiz

module fwd_unit(
						input wire [4:0] EX_rd,
						input wire [4:0] MEM_rd,  
						input wire [4:0] WB_rd, 
						input wire [1:0] EX_inst,  
						input wire [1:0] MEM_inst,
						input wire [1:0] WB_inst,
						input wire [31:0] EX_dat,
						input wire [31:0] MEM_dat,
						input wire [31:0] WB_dat,
						input wire mem_ack,
						input wire [4:0] rs1,			 //register source 
						input wire [4:0] rs2,
						output reg [31:0] dat_A,
						output reg [31:0] dat_B,
						output reg fwd_A,          // Output 1 (Mux control signal)
						output reg fwd_B,          // Output 2 (Mux control signal)
						output reg stall
						);

	localparam inst_ex = 2'b00;
	localparam inst_mem = 2'b01;
	localparam inst_wb = 2'b10;

	always@(*) begin
		//Execution 
		if((rs1 == EX_rd) || (rs2 == EX_rd )) begin
			if (EX_inst == inst_ex) begin
				stall = 0;
				if(rs1 && (rs1 == EX_rd))begin
					dat_A = EX_dat;
					fwd_A = 1;   //fwd
				end
				if(rs2 && (rs2 == EX_rd))begin
					dat_B = EX_dat;					
					fwd_B = 1;
				end
			end else 
				stall = 1;
		end else
		// Memory
		if((rs1 == MEM_rd) || (rs2 == MEM_rd )) begin
			if (((MEM_inst == inst_mem) && mem_ack) || (MEM_inst == inst_ex) begin
				stall = 0;
	            if(rs1 && (rs1 == MEM_rd))begin
					dat_A = MEM_dat;
					fwd_A = 1;   //fwd
				end
				if(rs2 && (rs2 == MEM_rd))begin
					dat_B = MEM_dat;					
					fwd_B = 1;
				end
	       	end else  
				stall = 1;
        end else
		//WB
		if((rs1 == WB_rd) || (rs2 == WB_rd )) begin
			if ( WB_inst <= inst_wb	 ) begin
				stall = 0;
				if(rs1 && (rs1 == MEM_rd))begin
					dat_A = WB_dat;
					fwd_A = 1;   //fwd
				end
				if(rs2 && (rs2 == MEM_rd))begin
					dat_B = WB_dat;					
					fwd_B = 1;
				end
			end
		end else begin
			fwd_A = 0;
			fwd_B = 0;
		end
	end

endmodule



