////////////////////////////////////////////////////////////////////////////
////									////
//// t2600 IP Core	 						////
////									////
//// This file is part of the t2600 project				////
//// http://www.opencores.org/cores/t2600/				////
////									////
//// Description							////
//// Video module					 		////
////									////
//// TODO:								////
//// - Everything?							////
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

module video(clk, reset_n, io_lines, enable, mem_rw, address, data);
	parameter [3:0] DATA_SIZE = 4'd8;
	parameter [3:0] ADDR_SIZE = 4'd10; // this is the *local* addr_size

	localparam [3:0] DATA_SIZE_ = DATA_SIZE - 4'd1;
	localparam [3:0] ADDR_SIZE_ = ADDR_SIZE - 4'd1;

	input clk; // master clock signal, 1.19mhz
	input reset_n;
	input [15:0] io_lines; // inputs from the keyboard controller
	input enable; // since the address bus is shared an enable signal is used
	input mem_rw; // read == 0, write == 1
	input [ADDR_SIZE_:0] address; // system address bus
	inout [DATA_SIZE_:0] data; // controler <=> riot data bus

	reg [DATA_SIZE_:0] data_drv; // wrapper for the data bus

	assign data = (mem_rw || !reset_n) ? 8'bZ : data_drv; // if under writing the bus receives the data from cpu, else local data. 

	reg VSYNC; // vertical sync set-clear
	reg [2:0] VBLANK; // vertical blank set-clear
	reg WSYNC; //  s t r o b e wait for leading edge of horizontal blank
	reg RSYNC; //  s t r o b e reset horizontal sync counter
	reg [5:0] NUSIZ0; //  number-size player-missile 0
	reg [5:0] NUSIZ1; //  number-size player-missile 1
	reg [6:0] COLUP0; //  color-lum player 0
	reg [6:0] COLUP1; //  color-lum player 1
	reg [6:0] COLUPF; //  color-lum playfield
	reg [6:0] COLUBK; //  color-lum background
	reg [4:0] CTRLPF; //  control playfield ball size & collisions
	reg REFP0; //  reflect player 0
	reg REFP1; //  reflect player 1
	reg [3:0] PF0; //  playfield register byte 0
	reg [7:0] PF1; //  playfield register byte 1
	reg [7:0] PF2; //  playfield register byte 2
	reg RESP0; //  s t r o b e reset player 0
	reg RESP1; //  s t r o b e reset player 1
	reg RESM0; //  s t r o b e reset missile 0
	reg RESM1; //  s t r o b e reset missile 1
	reg RESBL; //  s t r o b e reset ball
	reg [3:0] AUDC0; //  audio control 0
	reg [4:0] AUDC1; //  audio control 1
	reg [4:0] AUDF0; //  audio frequency 0
	reg [3:0] AUDF1; //  audio frequency 1
	reg [3:0] AUDV0; //  audio volume 0
	reg [3:0] AUDV1; //  audio volume 1
	reg [7:0] GRP0; //  graphics player 0
	reg [7:0] GRP1; //  graphics player 1
	reg ENAM0; //  graphics (enable) missile 0
	reg ENAM1; //  graphics (enable) missile 1
	reg ENABL; //  graphics (enable) ball
	reg [3:0] HMP0; //  horizontal motion player 0
	reg [3:0] HMP1; //  horizontal motion player 1
	reg [3:0] HMM0; //  horizontal motion missile 0
	reg [3:0] HMM1; //  horizontal motion missile 1
	reg [3:0] HMBL; //  horizontal motion ball
	reg VDELP0; //  vertical delay player 0
	reg VDEL01; //  vertical delay player 1
	reg VDELBL; //  vertical delay ball
	reg RESMP0; //  reset missile 0 to player 0
	reg RESMP1; //  reset missile 1 to player 1
	reg HMOVE; //  s t r o b e apply horizontal motion
	reg HMCLR; //  s t r o b e clear horizontal motion registers
	reg CXCLR ; // s t r o b e clear collision latches

	reg [1:0] CXM0P; // read collision MO P1 M0 P0
	reg [1:0] CXM1P; // read collision M1 P0 M1 P1
	reg [1:0] CXP0FB; // read collision P0 PF P0 BL
	reg [1:0] CXP1FB; // read collision P1 PF P1 BL
	reg [1:0] CXM0FB; // read collision M0 PF M0 BL
	reg [1:0] CXM1FB; // read collision M1 PF M1 BL
	reg CXBLPF; // read collision BL PF unused
	reg [1:0] CXPPMM; // read collision P0 P1 M0 M1
	reg INPT0; // read pot port
	reg INPT1; // read pot port
	reg INPT2; // read pot port
	reg INPT3; // read pot port
	reg INPT4; // read input
	reg INPT5; // read input 

	always @(posedge clk  or negedge reset_n) begin
		if (reset_n == 1'b0) begin
			data_drv <= 8'h00;
		end
		else begin
			if (mem_rw == 1'b0) begin // reading! 
				case (address) 
					6'h00: data_drv <= {CXM0P, 6'b000000};
					6'h01: data_drv <= {CXM1P, 6'b000000};
					6'h02: data_drv <= {CXP0FB, 6'b000000};
					6'h03: data_drv <= {CXP1FB, 6'b000000};
					6'h04: data_drv <= {CXM0FB, 6'b000000};
					6'h05: data_drv <= {CXM1FB, 6'b000000};
					6'h06: data_drv <= {CXBLPF, 7'b000000};
					6'h07: data_drv <= {CXPPMM, 6'b000000};
					6'h08: data_drv <= {INPT0, 7'b000000};
					6'h09: data_drv <= {INPT1, 7'b000000};
					6'h0A: data_drv <= {INPT2, 7'b000000};
					6'h0B: data_drv <= {INPT3, 7'b000000};
					6'h0C: data_drv <= {INPT4, 7'b000000};
					6'h0D: data_drv <= {INPT5, 7'b000000};
					default: ;
				endcase
			end  	
			else begin // writing! 
				case (address)
					6'h00: begin
						VSYNC <= data;
					end
					6'h01: begin
						VBLANK <= data;
					end
					6'h02: begin
						WSYNC <= data;
					end
					6'h03: begin
						RSYNC <= data;
					end
					6'h04: begin
						NUSIZ0 <= data;
					end
					6'h05: begin
						NUSIZ1 <= data;
					end
					6'h06: begin
						COLUP0 <= data;
					end
					6'h07: begin
						COLUP1 <= data;
					end
					6'h08: begin
						COLUPF <= data;
					end
					6'h09: begin
						COLUBK <= data;
					end
					6'h0a: begin
						CTRLPF <= data;
					end
					6'h0b: begin
						NUSIZ1 <= data;
					end
					6'h0c: begin
						NUSIZ1 <= data;
					end
					default: begin
					end
				endcase
			end
		end
	end
	
endmodule

