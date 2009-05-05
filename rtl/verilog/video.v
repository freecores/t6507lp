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
	reg VBLANK; //  1 1 1 vertical blank set-clear
	reg WSYNC; //  s t r o b e wait for leading edge of horizontal blank
	reg RSYNC; //  s t r o b e reset horizontal sync counter
	reg NUSIZ0; //  1 1 1 1 1 1 number-size player-missile 0
	reg NUSIZ1; //  1 1 1 1 1 1 number-size player-missile 1
	reg COLUP0; //  1 1 1 1 1 1 1 color-lum player 0
	reg COLUP1; //  1 1 1 1 1 1 1 color-lum player 1
	reg COLUPF; //  1 1 1 1 1 1 1 color-lum playfield
	reg COLUBK; //  1 1 1 1 1 1 1 color-lum background
	reg CTRLPF; //  1 1 1 1 1 control playfield ball size & collisions
	reg REFP0; //  1 reflect player 0
	reg REFP1; //  1 reflect player 1
	reg PF0; //  1 1 1 1 playfield register byte 0
	reg PF1; //  1 1 1 1 1 1 1 1 playfield register byte 1
	reg PF2; //  1 1 1 1 1 1 1 1 playfield register byte 2
	reg RESP0; //  s t r o b e reset player 0
	reg RESP1; //  s t r o b e reset player 1
	reg RESM0; //  s t r o b e reset missile 0
	reg RESM1; //  s t r o b e reset missile 1
	reg RESBL; //  s t r o b e reset ball
	reg AUDC0; //  1 1 1 1 audio control 0
	reg AUDC1; //  1 1 1 1 1 audio control 1
	reg AUDF0; //  1 1 1 1 1 audio frequency 0
	reg AUDF1; //  1 1 1 1 audio frequency 1
	reg AUDV0; //  1 1 1 1 audio volume 0
	reg AUDV1; //  1 1 1 1 audio volume 1
	reg GRP0; //  1 1 1 1 1 1 1 1 graphics player 0
	reg GRP1; //  1 1 1 1 1 1 1 1 graphics player 1
	reg ENAM0; //  1 graphics (enable) missile 0
	reg ENAM1; //  1 graphics (enable) missile 1
	reg ENABL; //  1 graphics (enable) ball
	reg HMP0; //  1 1 1 1 horizontal motion player 0
	reg HMP1; //  1 1 1 1 horizontal motion player 1
	reg HMM0; //  1 1 1 1 horizontal motion missile 0
	reg HMM1; //  1 1 1 1 horizontal motion missile 1
	reg HMBL; //  1 1 1 1 horizontal motion ball
	reg VDELP0; //  1 vertical delay player 0
	reg VDEL01; //  1 vertical delay player 1
	reg VDELBL; //  1 vertical delay ball
	reg RESMP0; //  1 reset missile 0 to player 0
	reg RESMP1; //  1 reset missile 1 to player 1
	reg HMOVE; //  s t r o b e apply horizontal motion
	reg HMCLR; //  s t r o b e clear horizontal motion registers
	reg CXCLR ; // s t r o b e clear collision latches 

	always @(posedge clk  or negedge reset_n) begin // R/W register/memory handling
		if (reset_n == 1'b0) begin
			data_drv <= 8'h00;
		end
		else begin
			if (reading) begin // reading! 
				case (address) 
					10'h280: data_drv <= port_a;
					10'h281: data_drv <= ddra;
					10'h282: data_drv <= port_b;
					10'h283: data_drv <= 8'h00; // portb ddr is always input
					10'h284: data_drv <= timer;
					default: data_drv <= ram[address];
				endcase
			end  	
			else if (writing) begin // writing! 
				case (address)
					10'h281: begin
						ddra <= data;
					end 
					10'h294: begin
						c1_timer <= 1'b1;
						c8_timer <= 1'b0;
						c64_timer <= 1'b0;
						c1024_timer <= 1'b0;
						timer <= data;
						flipped <= 1'b0;
						counter <= 11'd1;
					end
					10'h295: begin
						c1_timer <= 1'b0;
						c8_timer <= 1'b1;
						c64_timer <= 1'b0;
						c1024_timer <= 1'b0;
						timer <= data;
						flipped <= 1'b0;
						counter <= 11'd7;
					end
					10'h296: begin
						c1_timer <= 1'b0;
						c8_timer <= 1'b0;
						c64_timer <= 1'b1;
						c1024_timer <= 1'b0;
						timer <= data;
						flipped <= 1'b0;
						counter <= 11'd63;
					end
					10'h297: begin
						c1_timer <= 1'b0;
						c8_timer <= 1'b0;
						c64_timer <= 1'b0;
						c1024_timer <= 1'b1;
						timer <= data;
						flipped <= 1'b0;
						counter <= 11'd1023;
					end
					default: begin
						ram[address] <= data;
					end
				endcase
			end
		
			if (!writing_at_timer) begin
				if (flipped || timer == 8'd0) begin // finished counting
					counter <= 11'd0;
					timer <= timer - 8'd1;
					flipped <= 1'b1;
				end
				else begin
					if (counter == 11'd0) begin
						timer <= timer - 8'd1;
	
						if (c1_timer) begin
							counter <= 11'd0;
						end
						if (c8_timer) begin
							counter <= 11'd7;
						end
						if (c64_timer) begin
							counter <= 11'd63;
						end
						if (c1024_timer) begin
							counter <= 11'd1023;
						end
					end
					else begin
						counter <= counter - 11'd1;
					end
				end
			end
		end
	end
	
	always @(*) begin // logic for easier controlling
		reading = 1'b0;
		writing = 1'b0;
		writing_at_timer = 1'b0;

		if (enable && reset_n) begin
			if (mem_rw == 1'b0) begin
				reading = 1'b1;
			end
			else begin
				writing = 1'b1;

				if ( (address == 10'h294) || (address == 10'h295) || (address == 10'h296) || (address == 10'h297) ) begin
					writing_at_timer = 1'b1;
				end
			end
		end
	end
	
endmodule

