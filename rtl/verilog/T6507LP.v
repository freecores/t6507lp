////////////////////////////////////////////////////////////////////////////
////									////
//// T6507LP IP Core	 						////
////									////
//// This file is part of the T6507LP project				////
//// http://www.opencores.org/cores/t6507lp/				////
////									////
//// Description							////
//// Implementation of a 6507-compatible microprocessor			////
////									////
//// To Do:								////
//// - Everything							////
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

`include  "T6507LP_ALU.v" 
`include  "T6507LP_FSM.v"

module T6507LP(n_rst_i, clk_i, rw_i, rdy_i, D_i, D_o, A_o);

input n_rst_i;
input clk_i;
input rw_i;
input rdy_i;
input [7:0] D_i;	// data, 8 bits wide
output [7:0] D_o;
output [12:0] A_o;	// address, 13 bits wide
`include  "T6507LP_Package.v"

// TODO: fix variables and signals naming convention
T6507LP_FSM FSM (
			.clk_in		(clk_i),
			.n_rst_in	(n_rst_in),
			.alu_result	(alu_result),
			.alu_status	(alu_status),
			.data_in		(D_i),
			.address	(address),
			.control	(control),
			.data_out(D_o),
			.alu_opcode	(alu_opcode),
			.alu_a		(alu_a),
			.alu_x		(alu_x),
			.alu_y		(alu_y)
		);

T6507LP_ALU ALU (
			.clk_i		(clk_i),
			.n_rst_i	(n_rst_i),
			.alu_enable	(alu_enable),
			.alu_result	(alu_result),
			.alu_status	(alu_status),
			.alu_opcode	(alu_opcode),
			.alu_a		(alu_a),
			.alu_x		(alu_x),
			.alu_y		(alu_y)
		);
endmodule
