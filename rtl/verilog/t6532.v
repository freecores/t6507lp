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

	wire [DATA_SIZE_:0] ram [127:0];
	wire [DATA_SIZE_:0] io_ports [3:0]; // porta, portaddr, portb, portbddr

	reg [DATA_SIZE_:0] data_drv;

	assign data = (rw_mem) ? 8'bZ: data_drv; // if i am writing the bus receives the data from cpu  

	t6532_io t6532_io (
		.clk		(clk),
		.io_lines	(io_lines),
		.ddra		(io_ports[1]),
		.A		(io_ports[0]),
		.B		(io_ports[2])
	);

	always @(clk) begin
		if (enable && rw_mem) begin 
			case (address) 
				8'h80: data_drv <= io_ports[0];
				default: ;
			endcase
		end  	
	end

	always @(*) begin
		io_ports [3] = 8'h00; // portb ddr is always input
	end

	// io
	// timer
	// ram
	
endmodule
