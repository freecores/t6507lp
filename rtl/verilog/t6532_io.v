////////////////////////////////////////////////////////////////////////////
////									////
//// t6532 IP Core	 						////
////									////
//// This file is part of the t2600 project				////
//// http://www.opencores.org/cores/t2600/				////
////									////
//// Description							////
//// 6532 i/o						 		////
////									////
//// TODO:								////
//// - Code the	i/o							////
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

// iolines[0]  = B.D0
// iolines[15] = A.D7
// check the spec

module t6532_io(clk, io_lines, ddra, A, B);
	input clk;
	input [15:0] io_lines;
	input [15:0] ddra;
	output reg [7:0] A; // this is hex 280.
	output reg [7:0] B; // console switches. input port only. this is hex 282.

	always @ (clk) begin
		B[0] <= ~io_lines[0]; // these two are not actually switches
		B[1] <= ~io_lines[1];  
		
		if (io_lines[3]) begin // these are.
			B[3] <= !B[3];
		end 
		if (io_lines[6]) begin
			B[6] <= !B[6];
		end 
		if (io_lines[7]) begin
			B[7] <= !B[7];
		end

		A[0] <= (ddra[0] == 0) ? io_lines[8] : A[0]; 
		A[1] <= (ddra[1] == 0) ? io_lines[9] : A[1]; 
		A[2] <= (ddra[2] == 0) ? io_lines[10] : A[2]; 
		A[3] <= (ddra[3] == 0) ? io_lines[11] : A[3]; 
		A[4] <= (ddra[4] == 0) ? io_lines[12] : A[4]; 
		A[5] <= (ddra[5] == 0) ? io_lines[13] : A[5]; 
		A[6] <= (ddra[6] == 0) ? io_lines[14] : A[6]; 
		A[7] <= (ddra[7] == 0) ? io_lines[15] : A[7]; 
	end

endmodule

