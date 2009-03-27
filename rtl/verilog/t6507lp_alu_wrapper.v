////////////////////////////////////////////////////////////////////////////
////									////
//// T6507LP IP Core	 						////
////									////
//// This file is part of the T6507LP project				////
//// http://www.opencores.org/cores/t6507lp/				////
////									////
//// Description							////
//// 6507 ALU wrapper							////
////									////
//// TODO:								////
////									////
//// Author(s):								////
//// - Gabriel Oshiro Zardo, gabrieloshiro@gmail.com			////
//// - Samuel Nascimento Pagliarini (creep), snpagliarini@gmail.com	////
////									////
////////////////////////////////////////////////////////////////////////////
////									////
//// Copyright (C) 2001 Authors and OPENCORES.ORG			////
////									////
//// This source file may be used and distributed without		////
//// restriction provided that this copyright statement is not		////
//// removed from the file and that any derivative work contains	////
//// the original copyright notice and the associated disclaimer.	////
////									////
//// This source file is free software; you can redistribute it		////
//// and/or modify it under the terms of the GNU Lesser General		////
//// Public License as published by the Free Software Foundation;	////
//// either version 2.1 of the License, or (at your option) any		////
//// later version.							////
////									////
//// This source is distributed in the hope that it will be		////
//// useful, but WITHOUT ANY WARRANTY; without even the implied		////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR		////
//// PURPOSE. See the GNU Lesser General Public License for more	////
//// details.								////
////									////
//// You should have received a copy of the GNU Lesser General		////
//// Public License along with this source; if not, download it		////
//// from http://www.opencores.org/lgpl.shtml				////
////									////
////////////////////////////////////////////////////////////////////////////

`include "timescale.v"

module wrapper_alu();
	parameter [3:0] DATA_SIZE = 4'd8;
	localparam [3:0] DATA_SIZE_ = DATA_SIZE - 4'b0001;

	// all inputs are regs
	reg clk;
	reg n_rst_i;
	reg alu_enable;
	reg alu_opcode;
	reg alu_a;
	
	// all outputs are wires
	wire alu_result; 
	wire alu_status; 
	wire alu_x; 
	wire alu_y; 
	
	
	initial clk = 0;
	always #10 clk <= ~clk;
	
	T6507LP_ALU T6507LP_ALU (
		.clk_i		(clk),
		.n_rst_i	(reset_n),
		.alu_enable	(alu_enable),
		.alu_result	(alu_result),
		.alu_status	(alu_status),
		.alu_opcode	(alu_opcode),
		.alu_a		(alu_a),
		.alu_x		(alu_x),
		.alu_y		(alu_y)
	);
endmodule
