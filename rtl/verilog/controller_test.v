////////////////////////////////////////////////////////////////////////////
////									////
//// t2600 IP Core	 						////
////									////
//// This file is part of the t2600 project				////
//// http://www.opencores.org/cores/t2600/				////
////									////
//// Description							////
//// VGA controller					 		////
////									////
//// TODO:								////
//// - Feed the controller with data					////
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

module controller_test(reset_n, clk_50, line, vert_counter);

input reset_n;
input clk_50;
output reg [479:0] line;
output reg [4:0] vert_counter;

reg clk_358; // 3.58mhz
reg [3:0] counter;

reg [3:0] red;
reg [3:0] green;
reg [3:0] blue;

reg [11:0] pixel0;
reg [11:0] pixel1;
reg [11:0] pixel2;
reg [11:0] pixel3;
reg [11:0] pixel4;
reg [11:0] pixel5;
reg [11:0] pixel6;
reg [11:0] pixel7;
reg [11:0] pixel8;
reg [11:0] pixel9;


always @ (posedge clk_50 or negedge reset_n) begin
	if (reset_n == 1'b0) begin
		clk_358 <= 1'b0;
		counter <= 4'd0;
		red <= 4'b1010;
		green <= 4'b0001;
		blue <= 4'b1110;
	end
	else begin
		if (counter == 4'h6) begin
			clk_358 <= !clk_358;
			counter <= 4'd0;
		end
		else begin
			counter <= counter + 4'd1;
		end
	end
end



always @ (posedge clk_358 or negedge reset_n) begin
	if (reset_n == 1'b0) begin
		vert_counter <= 6'd0;
		line <= 480'd0;
		$write("NEVER!");
	end
	else begin
		
		line <= {pixel0, pixel1, pixel2, pixel3, pixel4, pixel5, pixel6, pixel7, pixel8, pixel9,
			 pixel0, pixel1, pixel2, pixel3, pixel4, pixel5, pixel6, pixel7, pixel8, pixel9,
			 pixel0, pixel1, pixel2, pixel3, pixel4, pixel5, pixel6, pixel7, pixel8, pixel9,
			 pixel0, pixel1, pixel2, pixel3, pixel4, pixel5, pixel6, pixel7, pixel8, pixel9};

		if (vert_counter == 5'd29) begin
			vert_counter <= 6'd0;
		end
		else begin
			vert_counter <= vert_counter + 5'd1;
		end
	end
end

always @(*) begin
	pixel0 = {red, green, blue};
	pixel1 = {red, green, blue};
	pixel2 = {red, green, blue};
	pixel3 = {red, green, blue};
	pixel4 = {red, green, blue};
	pixel5 = {red, green, blue};
	pixel6 = {red, green, blue};
	pixel7 = {red, green, blue};
	pixel8 = {red, green, blue};
	pixel9 = {red, green, blue};
end

endmodule
