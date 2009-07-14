////////////////////////////////////////////////////////////////////////////
////									////
//// T6507LP IP Core	 						////
////									////
//// This file is part of the T6507LP project				////
//// http://www.opencores.org/cores/t6507lp/				////
////									////
//// Description							////
//// 6507 io wrapper							////
////									////
//// TODO:								////
//// - Nothing								////
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
`include "stubs.v"

module t6507lp_io(vdd, gnd, clk, reset_n, data_in, rw_mem, data_out, address, clkIO, reset_nIO, data_inIO, rw_memIO, data_outIO, addressIO);
	parameter [3:0] DATA_SIZE = 4'd8;
	parameter [3:0] ADDR_SIZE = 4'd13;

	localparam [3:0] DATA_SIZE_ = DATA_SIZE - 4'b0001;
	localparam [3:0] ADDR_SIZE_ = ADDR_SIZE - 4'b0001;

	input vdd;
	input gnd;

	input clk;
	output clkIO;

	input reset_n;
	output reset_nIO;

	input [DATA_SIZE_:0] data_in;
	output [DATA_SIZE_:0] data_inIO;

	input rw_mem;
	output rw_memIO;

	input [DATA_SIZE_:0] data_out;
	output [DATA_SIZE_:0] data_outIO;

	input [ADDR_SIZE_:0] address;
	output [ADDR_SIZE_:0] addressIO;

	// the ICP cell format is PAD PI Y PO
	ICP clk_pad(
		.PI	(gnd),
		.PO	(gnd),
		.PAD	(clk),
		.Y	(clkIO)
	);

	ICP reset_n_pad(
		.PI	(gnd),
		.PO	(gnd),
		.PAD	(reset_n),
		.Y	(reset_nIO)
	);

	ICP data_in_pad0(
		.PI	(gnd),
		.PO	(gnd),
		.PAD	(data_in[0]),
		.Y	(data_inIO[0])
	);

	ICP data_in_pad1(
		.PI	(gnd),
		.PO	(gnd),
		.PAD	(data_in[1]),
		.Y	(data_inIO[1])
	);

	ICP data_in_pad2(
		.PI	(gnd),
		.PO	(gnd),
		.PAD	(data_in[2]),
		.Y	(data_inIO[2])
	);

	ICP data_in_pad3(
		.PI	(gnd),
		.PO	(gnd),
		.PAD	(data_in[3]),
		.Y	(data_inIO[3])
	);

	ICP data_in_pad4(
		.PI	(gnd),
		.PO	(gnd),
		.PAD	(data_in[4]),
		.Y	(data_inIO[4])
	);

	ICP data_in_pad5(
		.PI	(gnd),
		.PO	(gnd),
		.PAD	(data_in[5]),
		.Y	(data_inIO[5])
	);

	ICP data_in_pad6(
		.PI	(gnd),
		.PO	(gnd),
		.PAD	(data_in[6]),
		.Y	(data_inIO[6])
	);

	ICP data_in_pad7(
		.PI	(gnd),
		.PO	(gnd),
		.PAD	(data_in[7]),
		.Y	(data_inIO[7])
	);

	BBT16P rw_mem_pad(
		.EN	(gnd),
		.PAD	(rw_memIO),
		.A	(rw_mem)
	);

	BBT16P data_out_pad0(
		.EN	(gnd),
		.PAD	(data_outIO[0]),
		.A	(data_out[0])
	);

	BBT16P data_out_pad1(
		.EN	(gnd),
		.PAD	(data_outIO[1]),
		.A	(data_out[1])
	);

	BBT16P data_out_pad2(
		.EN	(gnd),
		.PAD	(data_outIO[2]),
		.A	(data_out[2])
	);

	BBT16P data_out_pad3(
		.EN	(gnd),
		.PAD	(data_outIO[3]),
		.A	(data_out[3])
	);

	BBT16P data_out_pad4(
		.EN	(gnd),
		.PAD	(data_outIO[4]),
		.A	(data_out[4])
	);

	BBT16P data_out_pad5(
		.EN	(gnd),
		.PAD	(data_outIO[5]),
		.A	(data_out[5])
	);

	BBT16P data_out_pad6(
		.EN	(gnd),
		.PAD	(data_outIO[6]),
		.A	(data_out[6])
	);

	BBT16P data_out_pad7(
		.EN	(gnd),
		.PAD	(data_outIO[7]),
		.A	(data_out[7])
	);

	BBT16P adress_pad0(
		.EN	(gnd),
		.PAD	(addressIO[0]),
		.A	(address[0])
	);

	BBT16P adress_pad1(
		.EN	(gnd),
		.PAD	(addressIO[1]),
		.A	(address[1])
	);

	BBT16P adress_pad2(
		.EN	(gnd),
		.PAD	(addressIO[2]),
		.A	(address[2])
	);

	BBT16P adress_pad3(
		.EN	(gnd),
		.PAD	(addressIO[3]),
		.A	(address[3])
	);

	BBT16P adress_pad4(
		.EN	(gnd),
		.PAD	(addressIO[4]),
		.A	(address[4])
	);

	BBT16P adress_pad5(
		.EN	(gnd),
		.PAD	(addressIO[5]),
		.A	(address[5])
	);

	BBT16P adress_pad6(
		.EN	(gnd),
		.PAD	(addressIO[6]),
		.A	(address[6])
	);

	BBT16P adress_pad7(
		.EN	(gnd),
		.PAD	(addressIO[7]),
		.A	(address[7])
	);

	BBT16P adress_pad8(
		.EN	(gnd),
		.PAD	(addressIO[8]),
		.A	(address[8])
	);

	BBT16P adress_pad9(
		.EN	(gnd),
		.PAD	(addressIO[9]),
		.A	(address[9])
	);

	BBT16P adress_pad10(
		.EN	(gnd),
		.PAD	(addressIO[10]),
		.A	(address[10])
	);

	BBT16P adress_pad11(
		.EN	(gnd),
		.PAD	(addressIO[11]),
		.A	(address[11])
	);

	BBT16P adress_pad12(
		.EN	(gnd),
		.PAD	(addressIO[12]),
		.A	(address[12])
	);

endmodule


