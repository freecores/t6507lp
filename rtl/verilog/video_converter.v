////////////////////////////////////////////////////////////////////////////
////									////
//// t2600 IP Core	 						////
////									////
//// This file is part of the t2600 project				////
//// http://www.opencores.org/cores/t2600/				////
////									////
//// Description							////
//// Color scheme conversion				 		////
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


module video_converter(ypbpr, rgb);
	input [6:0] ypbpr;
	output [23:0] rgb;

	case (ypbpr[2:0]) begin // luminance
		3'h0: begin 
			case (ypbpr[6:3]) begin
				4'h0: rgb = 24'h000000;
				4'h1: rgb = 24'h444400;
				4'h2: rgb = 24'h702800;
				4'h3: rgb = 24'h841800;
				4'h4: rgb = 24'h880000;
				4'h5: rgb = 24'h78005C;
				4'h6: rgb = 24'h480078;
				4'h7: rgb = 24'h140084;
				4'h8: rgb = 24'h000088;
				4'h9: rgb = 24'h00187C;
				4'hA: rgb = 24'h002C5C;
				4'hB: rgb = 24'h003C2C;
				4'hC: rgb = 24'h003C00;
				4'hD: rgb = 24'h;
				4'hE: rgb = 24'h;
				4'hF: rgb = 24'h;
			endcase
		end
		3'h1: 
		3'h2: 
		3'h3: 
		3'h4: 
		3'h5: 
		3'h6: 
		3'h7: 
	endcase

endmodule

