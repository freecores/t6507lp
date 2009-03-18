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
//// - Fix absolute indexed mode					////
//// - Code the relative mode						////
//// - Code the indexed indirect mode					////
//// - Code the indirect indexed mode					////
//// - Code the absolute indirect mode					////
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

module t6507lp_fsm(clk, reset_n, alu_result, alu_status, data_in, address, control, data_out, alu_opcode, alu_a, alu_enable, alu_x, alu_y);
	parameter DATA_SIZE = 4'h8;
	parameter ADDR_SIZE = 4'hd;

	localparam DATA_SIZE_ = DATA_SIZE - 4'b0001;
	localparam ADDR_SIZE_ = ADDR_SIZE - 4'b0001;

	input clk;
	input reset_n;
	input [DATA_SIZE_:0] alu_result;
	input [DATA_SIZE_:0] alu_status;
	input [DATA_SIZE_:0] data_in;
	output reg [ADDR_SIZE_:0] address;
	output reg control; // one bit is enough? read = 0, write = 1
	output reg [DATA_SIZE_:0] data_out;
	output reg [DATA_SIZE_:0] alu_opcode;
	output reg [DATA_SIZE_:0] alu_a;
	output reg alu_enable;

	input [DATA_SIZE_:0] alu_x;
	input [DATA_SIZE_:0] alu_y;


	// FSM states
	localparam RESET = 4'b1111;
	localparam FETCH_OP = 4'b0000;
	localparam FETCH_OP_CALC = 4'b0001;
	localparam FETCH_LOW = 4'b0010;
	localparam FETCH_HIGH = 4'b0011;
	localparam READ_MEM = 4'b0100;
	localparam DUMMY_WRT_CALC = 4'b0101;
	localparam WRITE_MEM = 4'b0110;
	localparam FETCH_OP_CALC_PARAM = 4'b0111;
	localparam READ_MEM_CALC_INDEX = 4'b1000;

	// OPCODES TODO: verify how this get synthesised
	`include "../T6507LP_Package.v"

	// control signals
	localparam MEM_READ = 1'b0;
	localparam MEM_WRITE = 1'b1;

	reg [ADDR_SIZE_:0] pc;		// program counter
	reg [DATA_SIZE_:0] sp;		// stack pointer
	reg [DATA_SIZE_:0] ir;		// instruction register
	reg [ADDR_SIZE_:0] temp_addr;	// temporary address
	reg [DATA_SIZE_:0] temp_data;	// temporary data

	reg [3:0] state, next_state; // current and next state registers
	// TODO: not sure if this will be 4 bits wide. as of march 9th this was 4bit wide.

	// wiring that simplifies the FSM logic
	reg absolute;
	reg absolute_indexed;
	reg accumulator;
	reg immediate;
	reg implied;
	reg indirect;
	reg relative;
	reg zero_page;
	reg zero_page_indexed;
	reg [DATA_SIZE_:0] index; // will be assigned with either X or Y

	// regs that store the type of operation. again, this simplifies the FSM a lot.
	reg read;
	reg read_modify_write;
	reg write;
	reg jump;

	wire [ADDR_SIZE_:0] next_pc;
	assign next_pc = pc + 13'b0000000000001;

	wire [ADDR_SIZE_:0] address_plus_index; // this would update more times than actually needed, consuming power.
						// so the assign was changed to conditional.
	assign address_plus_index = (zero_page_indexed == 1'b1 && state == READ_MEM_CALC_INDEX)? (temp_addr + index): 0;

	always @ (posedge clk or negedge reset_n) begin // sequencial always block
		if (reset_n == 1'b0) begin
			// all registers must assume default values
			pc <= 0; // TODO: this is written somewhere. something about a reset vector. must be checked.
			sp <= 0; // TODO: the default is not 0. maybe $0100 or something like that. must be checked.
			ir <= 8'h00;
			temp_addr <= 0;
			temp_data <= 8'h00;
			state <= RESET;
			// registered outputs also receive default values
			address <= 0;
			control <= MEM_READ;
			data_out <= 8'h00;
		end
		else begin
			state <= next_state;
			
			case (state)
				RESET: begin
					// The processor was reset
					$write("under reset"); 
				end
				FETCH_OP: begin // this state is the simplest one. it is a simple fetch that must be done when the cpu was reset or
						// the last cycle was a memory write.
					pc <= next_pc;
					address <= next_pc;
					control <= MEM_READ; 
					ir <= data_in;
				end
				FETCH_OP_CALC, FETCH_OP_CALC_PARAM: begin // this is the pipeline happening!
					pc <= next_pc;
					address <= next_pc;
					control <= MEM_READ; 
					ir <= data_in;
				end
				FETCH_LOW: begin // in this state the opcode is already known so truly execution begins
					if (accumulator || implied) begin
						pc <= pc; // is this better?
						address <= pc;
						control <= MEM_READ; 
					end
					else if (immediate) begin
						pc <= next_pc;
						address <= next_pc;
						control <= MEM_READ; 
						temp_data <= data_in; // the follow-up byte is saved in temp_data 
					end
					else if (absolute) begin
						pc <= next_pc;
						address <= next_pc;					
						control <= MEM_READ; 
						temp_addr[7:0] <= data_in;
					end
					else if (zero_page) begin
						pc <= next_pc;
						address <= {{5{1'b0}},data_in};
						temp_addr <= {{5{1'b0}},data_in};

						if (write) begin
							control <= MEM_WRITE;
							data_out <= alu_result;
						end
						else begin
							control <= MEM_READ; 
							data_out <= 8'h00;
						end
					end
					else if (zero_page_indexed) begin
						pc <= next_pc;
						address <= {{5{1'b0}},data_in};
						temp_addr <= {{5{1'b0}},data_in};
						control <= MEM_READ; 
					end
				end
				FETCH_HIGH: begin
					if (jump) begin
						pc <= {data_in[4:0], temp_addr[7:0]}; // PCL <= first byte, PCH <= second byte
						address <= {data_in[4:0], temp_addr[7:0]};
						control <= MEM_READ; 
						data_out <= 8'h00;
					end
					else begin 
						if (write) begin 
							pc <= next_pc;
							temp_addr[12:8] <= data_in[4:0];
							address <= {data_in[4:0],temp_addr[7:0]};
							control <= MEM_WRITE;
							data_out <= alu_result;
						end
						else begin // read_modify_write or just read
							pc <= next_pc;
							temp_addr[12:8] <= data_in[4:0];
							address <= {data_in[4:0],temp_addr[7:0]};
							control <= MEM_READ; 
							data_out <= 8'h00;
						end
					end
					//else begin
					//	$write("FETCHHIGH PROBLEM"); 
					//	$finish(0); 
					//end
				end
				READ_MEM: begin
					if (read_modify_write) begin
						pc <= pc;
						address <= temp_addr;
						control <= MEM_WRITE;
						temp_data <= data_in;
						data_out <= data_in; // writeback the same value
					end
					else begin 
						pc <= pc;
						address <= pc;
						temp_data <= data_in;
						control <= MEM_READ; 
						data_out <= 8'h00;
					end
				end
				READ_MEM_CALC_INDEX: begin
						//pc <= next_pc; // pc was  already updated in the previous cycle
						address <= address_plus_index;
						temp_addr <= address_plus_index;

						if (write) begin
							control <= MEM_WRITE;
							data_out <= alu_result;
						end
						else begin
							control <= MEM_READ; 
							data_out <= 8'h00;
						end

				end
				DUMMY_WRT_CALC: begin
					pc <= pc;
					address <= temp_addr;
					control <= MEM_WRITE;
					data_out <= alu_result;
				end
				WRITE_MEM: begin
					pc <= pc;
					address <= pc;
					control <= MEM_READ; 
					data_out <= 8'h00;
				end
				default: begin
					$write("unknown state"); 	// TODO: check if synth really ignores this 2 lines. Otherwise wrap it with a `ifdef 
					$finish(0); 
				end
					
			endcase
		end
	end

	always @ (*) begin // this is the next_state logic and the output logic always block
		alu_opcode = 8'h00;
		alu_a = 8'h00;
		alu_enable = 1'b0;

		next_state = RESET; // this prevents the latch

		case (state)
			RESET: begin
				next_state = FETCH_OP;
			end
			FETCH_OP: begin
				next_state = FETCH_LOW;
			end
			//FETCH_OP_CALC: begin // so far no addressing mode required the use of this state
			//	next_state = FETCH_LOW;
			//	alu_opcode = ir;
			//	alu_enable = 1'b1;
			//end
			FETCH_OP_CALC_PARAM: begin
				next_state = FETCH_LOW;
				alu_opcode = ir;
				alu_enable = 1'b1;
				alu_a = temp_data;
			end
			FETCH_LOW: begin
				if (accumulator  || implied) begin
					alu_opcode = ir;
					alu_enable = 1'b1;
					next_state = FETCH_OP; 
				end
				else if (immediate) begin
					next_state = FETCH_OP_CALC_PARAM;
				end
				else if (zero_page) begin
					if (read || read_modify_write) begin
						next_state = READ_MEM;
					end
					else if (write) begin
						next_state = WRITE_MEM;
						alu_opcode = ir;
						alu_enable = 1'b1;
						alu_a = 8'h00;
					end
					else begin
						$write("unknown behavior"); 
						$finish(0);
					end
				end
				else if (zero_page_indexed) begin
					next_state = READ_MEM_CALC_INDEX;
				end
				else begin // at least the absolute address mode falls here
					next_state = FETCH_HIGH;
					if (write) begin // this is being done one cycle early?
						alu_opcode = ir;
						alu_enable = 1'b1;
						alu_a = 8'h00;
					end
				end
			end
			FETCH_HIGH: begin
				if (jump) begin
					next_state = FETCH_OP;
				end
				else if (read || read_modify_write) begin
					next_state = READ_MEM;
				end
				else if (write) begin
					next_state = WRITE_MEM;
				end
				else begin
					$write("unknown behavior"); 
					$finish(0);
				end
			end
			READ_MEM_CALC_INDEX: begin
				if (read || read_modify_write) begin
					next_state = READ_MEM;
				end
				else if (write) begin
					alu_opcode = ir;
					alu_enable = 1'b1;
					next_state = WRITE_MEM;
				end
				else begin
					$write("unknown behavior"); 
					$finish(0);
				end
			end
			READ_MEM: begin
				if (read) begin
					next_state = FETCH_OP_CALC_PARAM;
				end
				else if (read_modify_write) begin
					next_state = DUMMY_WRT_CALC;
				end
			end
			DUMMY_WRT_CALC: begin
				alu_opcode = ir;
				alu_enable = 1'b1;
				alu_a = data_in;
				next_state = WRITE_MEM;
			end
			WRITE_MEM: begin
				next_state = FETCH_OP;
			end
			default: begin
				next_state = RESET; 
			end
		endcase
	end

	// this always block is responsible for updating the address mode and the type of operation being done
	always @ (*) begin // 
		absolute = 1'b0;
		absolute_indexed = 1'b0;
		accumulator = 1'b0;
		immediate = 1'b0;
		implied = 1'b0;
		indirect = 1'b0;
		relative = 1'b0;
		zero_page = 1'b0;
		zero_page_indexed = 1'b0;
	
		index = 1'b0;

		read = 1'b0;
		read_modify_write = 1'b0;
		write = 1'b0;
		jump = 1'b0;
		
		case (ir)
			BRK_IMP, CLC_IMP, CLD_IMP, CLI_IMP, CLV_IMP, DEX_IMP, DEY_IMP, INX_IMP, INY_IMP, NOP_IMP, PHA_IMP, PHP_IMP, PLA_IMP,
			PLP_IMP, RTI_IMP, RTS_IMP, SEC_IMP, SED_IMP, SEI_IMP, TAX_IMP, TAY_IMP, TSX_IMP, TXA_IMP, TXS_IMP, TYA_IMP: begin
				implied = 1'b1;
			end
			ASL_ACC, LSR_ACC, ROL_ACC, ROR_ACC: begin
				accumulator = 1'b1;
			end
			ADC_IMM, AND_IMM, CMP_IMM, CPX_IMM, CPY_IMM, EOR_IMM, LDA_IMM, LDX_IMM, LDY_IMM, ORA_IMM, SBC_IMM: begin
				immediate = 1'b1;
			end
			ADC_ZPG, AND_ZPG, ASL_ZPG, BIT_ZPG, CMP_ZPG, CPX_ZPG, CPY_ZPG, DEC_ZPG, EOR_ZPG, INC_ZPG, LDA_ZPG, LDX_ZPG, LDY_ZPG,
			LSR_ZPG, ORA_ZPG, ROL_ZPG, ROR_ZPG, SBC_ZPG, STA_ZPG, STX_ZPG, STY_ZPG: begin
				zero_page = 1'b1;
			end	
			ADC_ZPX, AND_ZPX, ASL_ZPX, CMP_ZPX, DEC_ZPX, EOR_ZPX, INC_ZPX, LDA_ZPX, LDY_ZPX, LSR_ZPX, ORA_ZPX, ROL_ZPX, ROR_ZPX,
			SBC_ZPX, STA_ZPX, STY_ZPX: begin
				zero_page_indexed = 1'b1;
				index = alu_x;
			end
			LDX_ZPY, STX_ZPY: begin
				zero_page_indexed = 1'b1;
				index = alu_y;
			end
			BCC_REL, BCS_REL, BEQ_REL, BMI_REL, BNE_REL, BPL_REL, BVC_REL, BVS_REL: begin
				relative = 1'b1;
			end
			ADC_ABS, AND_ABS, ASL_ABS, BIT_ABS, CMP_ABS, CPX_ABS, CPY_ABS, DEC_ABS, EOR_ABS, INC_ABS, JMP_ABS, JSR_ABS, LDA_ABS, 
			LDX_ABS, LDY_ABS, LSR_ABS, ORA_ABS, ROL_ABS, ROR_ABS, SBC_ABS, STA_ABS, STX_ABS, STY_ABS: begin
				absolute = 1'b1;
			end
			ADC_ABX, AND_ABX, ASL_ABX, CMP_ABX, DEC_ABX, EOR_ABX, INC_ABX, LDA_ABX, LDY_ABX, LSR_ABX, ORA_ABX, ROL_ABX, ROR_ABX,
			SBC_ABX, STA_ABX, ADC_ABY, AND_ABY, CMP_ABY, EOR_ABY, LDA_ABY, LDX_ABY, ORA_ABY, SBC_ABY, STA_ABY: begin
				absolute_indexed = 1'b1;
			end
			ADC_IDX, AND_IDX, CMP_IDX, EOR_IDX, LDA_IDX, ORA_IDX, SBC_IDX, STA_IDX, ADC_IDY, AND_IDY, CMP_IDY, EOR_IDY, LDA_IDY, 
			ORA_IDY, SBC_IDY, STA_IDY: begin // all these opcodes are 8'hX1; TODO: optimize this
				indirect = 1'b1;	
			end
			default: begin
				if (reset_n == 1) begin // the processor is NOT being reset
					$write("\nunknown OPCODE!!!!! 0x%h\n", ir);
					$finish();
				end
			end
		endcase
	
		case (ir)
			ASL_ACC, ASL_ZPG, ASL_ZPX, ASL_ABS, ASL_ABX, LSR_ACC, LSR_ZPG, LSR_ZPX, LSR_ABS, LSR_ABX, ROL_ACC, ROL_ZPG, ROL_ZPX, ROL_ABS,
                	ROL_ABX, ROR_ACC, ROR_ZPG, ROR_ZPX, ROR_ABS, ROR_ABX, INC_ZPG, INC_ZPX, INC_ABS, INC_ABX, DEC_ZPG, DEC_ZPX, DEC_ABS,
			DEC_ABX: begin
				read_modify_write = 1'b1;
			end
			STA_ZPG, STA_ZPX, STA_ABS, STA_ABX, STA_ABY, STA_IDX, STA_IDY, STX_ZPG, STX_ZPY, STX_ABS, STY_ZPG, STY_ZPX, STY_ABS: begin
				write = 1'b1;
			end
			default: begin // this should work fine since the previous case statement will detect the unknown/undocumented/unsupported opcodes
				read = 1'b1;
			end
		endcase
			
		if (ir == JMP_ABS || ir == JMP_IND) begin // the opcodes are 8'h4C and 8'h6C
			jump = 1'b1;
		end
	end 
endmodule



