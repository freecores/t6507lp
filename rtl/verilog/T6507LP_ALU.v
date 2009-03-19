////////////////////////////////////////////////////////////////////////////
////									////
//// T6507LP IP Core	 						////
////									////
//// This file is part of the T6507LP project				////
//// http://www.opencores.org/cores/t6507lp/				////
////									////
//// Description							////
//// 6507 ALU								////
////									////
//// To Do:								////
//// - Search for TODO							////
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

`timescale 1ns / 1ps

// TODO: verify code identation

module T6507LP_ALU( clk_i, n_rst_i, alu_enable, alu_result, alu_status, alu_opcode, alu_a, alu_x, alu_y );

input wire       clk_i;
input wire       n_rst_i;
input wire       alu_enable;
input wire [7:0] alu_opcode;
input wire [7:0] alu_a;
output reg [7:0] alu_result;
output reg [7:0] alu_status;
output reg [7:0] alu_x;
output reg [7:0] alu_y;

reg [7:0] A;
reg [7:0] X;
reg [7:0] Y;

reg [7:0] STATUS;
reg [7:0] result;
reg [7:0] temp1;
reg [7:0] temp2;

`include "T6507LP_Package.v"

always @ (posedge clk_i or negedge n_rst_i)
begin
	if (n_rst_i == 0) begin
		alu_result <= 0;
		alu_status <= 8'b00100010;
		A <= 0;
		X <= 0;
		Y <= 0;
		alu_x <= 0;
		alu_y <= 0;
	end
	else if ( alu_enable == 1 ) begin
		alu_result <= result;
		A <= A;
		X <= X;
		Y <= Y;
		alu_x <= X;
		alu_y <= Y;
		case (alu_opcode)
			ADC_IMM, ADC_ZPG, ADC_ZPX, ADC_ABS, ADC_ABX, ADC_ABY, ADC_IDX, ADC_IDY,
			AND_IMM, AND_ZPG, AND_ZPX, AND_ABS, AND_ABX, AND_ABY, AND_IDX, AND_IDY,
			ASL_ACC,
			EOR_IMM, EOR_ZPG, EOR_ZPX, EOR_ABS, EOR_ABX, EOR_ABY, EOR_IDX, EOR_IDY,
			LSR_ACC,
			ORA_IMM, ORA_ZPG, ORA_ZPX, ORA_ABS, ORA_ABX, ORA_ABY, ORA_IDX, ORA_IDY,
			ROL_ACC, ROR_ACC,
			SBC_IMM, SBC_ZPG, SBC_ZPX, SBC_ABS, SBC_ABX, SBC_ABY, SBC_IDX, SBC_IDY :
			begin
				A <= result;
				alu_status <= STATUS;
			end
			LDA_IMM, LDA_ZPG, LDA_ZPX, LDA_ABS, LDA_ABX, LDA_ABY, LDA_IDX, LDA_IDY,
			PLA_IMP :
			begin
				A <= alu_a;
				alu_status <= STATUS;
			end
			LDX_IMM, LDX_ZPG, LDX_ZPY, LDX_ABS, LDX_ABY :
			begin
				X <= alu_a;
				alu_status <= STATUS;
			end
			LDY_IMM, LDY_ZPG, LDY_ZPX, LDY_ABS, LDY_ABX :
			begin
				Y <= alu_a;
				alu_status <= STATUS;
			end
			LSR_ZPG, LSR_ZPX, LSR_ABS, LSR_ABX,
			ROL_ZPG, ROL_ZPX, ROL_ABS, ROL_ABX,
			ROR_ZPG, ROR_ZPX, ROR_ABS, ROR_ABX,
			BIT_ZPG, BIT_ABS,
			BRK_IMP,
			CLC_IMP, CLD_IMP, CLI_IMP, CLV_IMP,
			CMP_IMM, CMP_ZPG, CMP_ZPX, CMP_ABS, CMP_ABX, CMP_ABY, CMP_IDX, CMP_IDY,
			CPX_IMM, CPX_ZPG, CPX_ABS,
			CPY_IMM, CPY_ZPG, CPY_ABS,
			SEC_IMP, SED_IMP, SEI_IMP,
			TAX_IMP, TAY_IMP, TSX_IMP, TXA_IMP, TXS_IMP, TYA_IMP :
			begin
				alu_status <= STATUS;
			end
			PLP_IMP :
			begin
				alu_status <= alu_a;
			end

		endcase
	end
end

always @ (*) begin
	case (alu_opcode)

		// BIT - Bit Test
		BIT_ZPG, BIT_ABS:
		begin
			result = A & alu_a;
			STATUS[V] = result[6];
		end

		// BRK - Force Interrupt
		BRK_IMP: begin
			STATUS[B] = 1'b1;
		end

		// CLC - Clear Carry Flag
		CLC_IMP: begin
			STATUS[C] = 1'b0;
		end
			
		// CLD - Clear Decimal Flag
		CLD_IMP: begin
			STATUS[D] = 1'b0;
		end

		// CLI - Clear Interrupt Disable
		// TODO: verify if this should be supported by 6507
		CLI_IMP: begin
			STATUS[I] = 1'b0;
		end

		// CLV - Clear Overflow Flag
		CLV_IMP: begin
			STATUS[V] = 1'b0;
		end

		// NOP - No Operation
		//NOP_IMP: begin
			// Do nothing :-D
		//end
	
		// PHP - Pull Processor Status Register
		PLP_IMP: begin
			STATUS = alu_a;
		end

		// STA - Store Accumulator
		// PHA - Push A
		// TAX - Transfer Accumulator to X
		// TAY - Transfer Accumulator to Y
		TAX_IMP, TAY_IMP, PHA_IMP, STA_ZPG, STA_ZPX, STA_ABS, STA_ABX, STA_ABY, STA_IDX, STA_IDY :
		begin
			result = A;
		end

		// STX - Store X Register
		// TXA - Transfer X to Accumulator
		// TXS - Transfer X to Stack pointer
		STX_ZPG, STX_ZPY, STX_ABS, TXA_IMP, TXS_IMP :
		begin
			result = X;
		end
			
		// STY - Store Y Register
		// TYA - Transfer Y to Accumulator
		STY_ZPG, STY_ZPX, STY_ABS, TYA_IMP :
		begin
			result = Y;
		end

		// SEC - Set Carry Flag
		SEC_IMP: begin
			STATUS[C] = 1'b1;
		end

		// SED - Set Decimal Flag
		SED_IMP: begin
			STATUS[D] = 1'b1;
		end

		// SEI - Set Interrupt Disable
		SEI_IMP: begin
			STATUS[I] = 1'b1;
		end

		// INC - Increment memory
		INC_ZPG, INC_ZPX, INC_ABS, INC_ABX :
		begin
			result = alu_a + 1;
		end

		// INX - Increment X Register
		INX_IMP: begin
			result = X + 1;
		end

		// INY - Increment Y Register
		INY_IMP : begin
			result = Y + 1;
		end

		// DEC - Decrement memory
		DEC_ZPG, DEC_ZPX, DEC_ABS, DEC_ABX :
		begin
			result = alu_a - 1;
		end

		// DEX - Decrement X register
		DEX_IMP: begin
			result = X - 1;
		end

		// DEY - Decrement Y Register
		DEY_IMP: begin
			result = Y - 1;
		end

		// ADC - Add with carry
		ADC_IMM, ADC_ZPG, ADC_ZPX, ADC_ABS, ADC_ABX, ADC_ABY, ADC_IDX, ADC_IDY :
		begin
			temp1 = A;
			temp2 = alu_a;
			if (alu_status[D] == 1) begin
				if (A[3:0] > 9) begin
					temp1 = A + 6; // A = A - 10 and A = A + 16
				end
				if (alu_a[3:0] > 9) begin
					temp2 = alu_a + 6;
				end
			end

			{STATUS[C],result} = temp1 + temp2 + alu_status[C];
			if ((temp1[7] == temp2[7]) && (temp1[7] != alu_result[7]))
				STATUS[V] = 1;
			else
				STATUS[V] = 0;
		end
			
		// AND - Logical AND
		AND_IMM, AND_ZPG, AND_ZPX, AND_ABS, AND_ABX, AND_ABY, AND_IDX, AND_IDY :
		begin
			result = A & alu_a;
		end

		// CMP - Compare
		CMP_IMM, CMP_ZPG, CMP_ZPX, CMP_ABS, CMP_ABX, CMP_ABY, CMP_IDX, CMP_IDY :
		begin
			{STATUS[C],result} = A - alu_a - ~alu_status[C];
		end

		// EOR - Exclusive OR
		EOR_IMM, EOR_ZPG, EOR_ZPX, EOR_ABS, EOR_ABX, EOR_ABY, EOR_IDX, EOR_IDY :
		begin
			result = A ^ alu_a ;
		end

		// LDA - Load Accumulator
		// LDX - Load X Register
		// LDY - Load Y Register
		// TSX - Transfer Stack Pointer to X
		LDA_IMM, LDA_ZPG, LDA_ZPX, LDA_ABS, LDA_ABX, LDA_ABY, LDA_IDX, LDA_IDY,
		LDX_IMM, LDX_ZPG, LDX_ZPY, LDX_ABS, LDX_ABY,
		LDY_IMM, LDY_ZPG, LDY_ZPX, LDY_ABS, LDY_ABX,
		TSX_IMP :
		begin
			result = alu_a;
		end

		// ORA - Logical OR
		ORA_IMM, ORA_ZPG, ORA_ZPX, ORA_ABS, ORA_ABX, ORA_ABY, ORA_IDX, ORA_IDY :
		begin
			result = A | alu_a;
		end

		// SBC - Subtract with Carry
		SBC_IMM, SBC_ZPG, SBC_ZPX, SBC_ABS, SBC_ABX, SBC_ABY, SBC_IDX, SBC_IDY :
		begin
			temp1 = A;
			temp2 = alu_a;
			if (alu_status[D] == 1) begin
				if (A[3:0] > 9) begin
					temp1 = A + 6; // A = A - 10 and A = A + 16
				end
				if (alu_a[3:0] > 9) begin
					temp2 = alu_a + 6;
				end
			end

			{STATUS[C],result} = temp1 - temp2 - ~alu_status[C];
			if ((temp1[7] == temp2[7]) && (temp1[7] != alu_result[7]))
				STATUS[V] = 1;
			else
				STATUS[V] = 0;
		end

		// ASL - Arithmetic Shift Left
		ASL_ACC : begin
			{STATUS[C],result} = A << 1;
		end
		ASL_ZPG, ASL_ZPX, ASL_ABS, ASL_ABX :
		begin
			{STATUS[C],result} = alu_a << 1;
		end

		// LSR - Logical Shift Right
		LSR_ACC: begin
			{result, STATUS[C]} = A >> 1;
		end
		LSR_ZPG, LSR_ZPX, LSR_ABS, LSR_ABX :
		begin
			{result, STATUS[C]} = alu_a >> 1;
		end
			
		// ROL - Rotate Left
		ROL_ACC : begin
			{STATUS[C],result} = {A,alu_status[C]}; //TODO: does it really work?
		end
		ROL_ZPG, ROL_ZPX, ROL_ABS, ROL_ABX :
		begin
			{STATUS[C],result} = {alu_a,alu_status[C]};
		end

		// ROR - Rotate Right		
		ROR_ACC : begin
			{result,STATUS[C]} = {alu_status[C],A};
		end
		ROR_ZPG, ROR_ZPX, ROR_ABS, ROR_ABX :
		begin
			{result, STATUS[C]} = {alu_status[C], alu_a};
		end

		// CPX - Compare X Register
		CPX_IMM, CPX_ZPG, CPX_ABS :
		begin
			{STATUS[C],result} = X - alu_a - ~alu_status[C];
		end

		// CPY - Compare Y Register
		CPY_IMM, CPY_ZPG, CPY_ABS :
		begin
			{STATUS[C],result} = Y - alu_a - ~alu_status[C];
		end

		default: begin // NON-DEFAULT OPCODES FALL HERE
		end 
	endcase
end

endmodule

