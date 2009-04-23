////////////////////////////////////////////////////////////////////////////
////									////
//// t6532 IP Core	 						////
////									////
//// This file is part of the t2600 project				////
//// http://www.opencores.org/cores/t2600/				////
////									////
//// Description							////
//// 6532 top level					 		////
////									////
//// TODO:								////
//// - Add the timer, ram and i/o					////
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

module t6532(clk, io_lines, enable, rw_mem, address, data);
	parameter [3:0] DATA_SIZE = 4'd8;
	parameter [3:0] ADDR_SIZE = 4'd7; // this is the *local* addr_size

	localparam [3:0] DATA_SIZE_ = DATA_SIZE - 4'd1;
	localparam [3:0] ADDR_SIZE_ = ADDR_SIZE - 4'd1;

	input clk;
	input [15:0] io_lines;
	input enable;
	input rw_mem;
	input [ADDR_SIZE_:0] address;
	inout [DATA_SIZE_:0] data;

	reg [DATA_SIZE_:0] ram [127:0];
	reg [DATA_SIZE_:0] port_a;
	reg [DATA_SIZE_:0] port_b;
	reg [DATA_SIZE_:0] ddra;
	reg [DATA_SIZE_:0] timer;
	reg [DATA_SIZE_:0] 1c_timer;
	reg [DATA_SIZE_:0] 8c_timer;
	reg [DATA_SIZE_:0] 64c_timer;
	reg [DATA_SIZE_:0] 1024c_timer;
	
	reg [DATA_SIZE_:0] data_drv;

	assign data = (rw_mem) ? 8'bZ: data_drv; // if i am writing the bus receives the data from cpu, else local data.  

	always @(clk) begin
		port_b[0] <= ~io_lines[0]; // these two are not actually switches
		port_b[1] <= ~io_lines[1];  
		
		if (io_lines[3]) begin // these are.
			port_b[3] <= !port_b[3];
		end 
		if (io_lines[6]) begin
			port_b[6] <= !port_b[6];
		end 
		if (io_lines[7]) begin
			port_b[7] <= !port_b[7];
		end

		port_a[0] <= (ddra[0] == 0) ? io_lines[8] : port_a[0]; 
		port_a[1] <= (ddra[1] == 0) ? io_lines[9] : port_a[1]; 
		port_a[2] <= (ddra[2] == 0) ? io_lines[10] : port_a[2]; 
		port_a[3] <= (ddra[3] == 0) ? io_lines[11] : port_a[3]; 
		port_a[4] <= (ddra[4] == 0) ? io_lines[12] : port_a[4]; 
		port_a[5] <= (ddra[5] == 0) ? io_lines[13] : port_a[5]; 
		port_a[6] <= (ddra[6] == 0) ? io_lines[14] : port_a[6]; 
		port_a[7] <= (ddra[7] == 0) ? io_lines[15] : port_a[7]; 

		if (enable && rw_mem == 0) begin // reading! 
			case (address) 
				8'h80: data_drv = port_a;
				8'h81: data_drv = ddra;
				8'h82: data_drv = port_b;
				8'h83: data_drv = 8'h00; // portb ddr is always input
				8'h84: data_drv = timer;
				8'h94: ;
				8'h95: ;
				8'h96: ;
				8'h97: ;
				default: ;
			endcase
		end  	
	end

	// timer
	// ram
	
endmodule
