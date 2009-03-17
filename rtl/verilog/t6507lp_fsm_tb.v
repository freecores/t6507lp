////////////////////////////////////////////////////////////////////////////
////									////
//// T6507LP IP Core	 						////
////									////
//// This file is part of the T6507LP project				////
//// http://www.opencores.org/cores/t6507lp/				////
////									////
//// Description							////
//// 6507 FSM								////
////									////
//// TODO:								////
//// - Perform simple tests before going into serious verification	////
//// 									////
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


`timescale 1ns / 1ps

module t6507lp_fsm_tb();
	reg clk;
	reg reset_n;
	reg [7:0] alu_result;
	reg [7:0] alu_status;
	reg [7:0] data_in;

	wire [12:0] address;
	wire control; // one bit is enough? read = 0, write = 1
	wire [7:0] data_out;
	wire [7:0] alu_opcode;
	wire [7:0] alu_a;
	wire alu_enable;

	`include "../T6507LP_Package.v"

	t6507lp_fsm #(8,13) my_dut(clk, reset_n, alu_result, alu_status, data_in, address, control, data_out, alu_opcode, alu_a, alu_enable);

	always #10 clk = ~clk;

	reg[7:0] fake_mem[30:0];

	initial begin
		clk = 0;
		reset_n = 1'b0;
		alu_result = 8'h01;
		alu_status = 0;

		fake_mem[0] = ASL_ACC; // testing ACC mode
		fake_mem[1] = ADC_IMM; // testing IMM mode
		fake_mem[2] = 8'h27;
		fake_mem[3] = JMP_ABS; // testing ABS mode, JMP type
		fake_mem[4] = 8'h09;
		fake_mem[5] = 8'h00;
		fake_mem[6] = ASL_ACC; // wont be executed
		fake_mem[7] = ASL_ACC; // wont be executed
		fake_mem[8] = ASL_ACC; // wont be executed
		fake_mem[9] = ASL_ACC; // wont be executed
		fake_mem[10] = LDA_ABS; // testing ABS mode, READ type. A = MEM[0002]. (a=27)
		fake_mem[11] = 8'h02;
		fake_mem[12] = 8'h00;
		fake_mem[13] = ASL_ABS; // testing ABS mode, READ_MODIFY_WRITE type. should overwrite the first ASL_ACC
		fake_mem[14] = 8'h00;
		fake_mem[15] = 8'h00;
		fake_mem[16] = STA_ABS; // testing ABS mode, WRITE type. should write alu_result on MEM[1]
		fake_mem[17] = 8'h01;
		fake_mem[18] = 8'h00;
		fake_mem[19] = LDA_ZPG; // testing ZPG mode, READ type
		fake_mem[20] = 8'h00;
		fake_mem[21] = ASL_ZPG; // testing ZPG mode, READ_MODIFY_WRITE type
		fake_mem[22] = 8'h00;
		fake_mem[23] = STA_ZPG; // testing ZPG mode, WRITE type
		fake_mem[24] = 8'h00;

		@(negedge clk) // will wait for next negative edge of the clock (t=20)
		reset_n=1'b1;
	

		#1000;
		$finish; // to shut down the simulation
	end //initial

	always @(clk) begin
		if (control == 0) begin // MEM_READ
			data_in <= fake_mem[address];
			$write("\nreading from mem position %h: %h", address, fake_mem[address]);
		end
		else if (control == 1'b1) begin // MEM_WRITE
			fake_mem[address] <= data_out;
			$write("\nreading from mem position %h: %h", address, fake_mem[address]);
		end
	end

endmodule
