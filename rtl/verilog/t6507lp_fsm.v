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
//// - Fix relative mode, bit 7 means negative				////
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
	parameter DATA_SIZE = 8;
	parameter ADDR_SIZE = 13;

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
	localparam FETCH_OP = 5'b00000;
	localparam FETCH_OP_CALC = 5'b00001;
	localparam FETCH_LOW = 5'b00010;
	localparam FETCH_HIGH = 5'b00011;
	localparam READ_MEM = 5'b00100;
	localparam DUMMY_WRT_CALC = 5'b00101;
	localparam WRITE_MEM = 5'b00110;
	localparam FETCH_OP_CALC_PARAM = 5'b00111;
	localparam READ_MEM_CALC_INDEX = 5'b01000;
	localparam FETCH_HIGH_CALC_INDEX = 5'b01001;
	localparam READ_MEM_FIX_ADDR = 5'b01010;
	localparam FETCH_OP_EVAL_BRANCH = 5'b01011;
	localparam FETCH_OP_FIX_PC = 5'b01100;
	localparam READ_FROM_POINTER = 5'b01101;
	localparam READ_FROM_POINTER_X = 5'b01110;
	localparam READ_FROM_POINTER_X1 = 5'b01111;
	localparam PUSH_PCH = 5'b10000;
	localparam PUSH_PCL = 5'b10001;
	localparam PUSH_STATUS = 5'b10010;
	localparam FETCH_PCL = 5'b10011;
	localparam FETCH_PCH = 5'b10100;
	localparam INCREMENT_SP = 5'b10101;
	localparam PULL_STATUS = 5'b10110;
	localparam PULL_PCL = 5'b10111;
	localparam PULL_PCH = 5'b11000;
	localparam INCREMENT_PC = 5'b11001;
	localparam PUSH_REGISTER = 5'b11010;

	localparam RESET = 5'b11111;

	// OPCODES TODO: verify how this get synthesised
	`include "../T6507LP_Package.v"

	// control signals
	localparam MEM_READ = 1'b0;
	localparam MEM_WRITE = 1'b1;

	reg [ADDR_SIZE_:0] pc;		// program counter
	reg [DATA_SIZE:0] sp;		// stack pointer. 9 bits wide.
	reg [DATA_SIZE_:0] ir;		// instruction register
	reg [ADDR_SIZE_:0] temp_addr;	// temporary address
	reg [DATA_SIZE_:0] temp_data;	// temporary data

	reg [4:0] state, next_state; // current and next state registers
	// TODO: not sure if this will be 5 bits wide. as of march 24th this was 5bit wide.

	// wiring that simplifies the FSM logic by simplifying the addressing modes
	reg absolute;
	reg absolute_indexed;
	reg accumulator;
	reg immediate;
	reg implied;
	reg indirectx;
	reg indirecty;
	reg relative;
	reg zero_page;
	reg zero_page_indexed;
	reg [DATA_SIZE_:0] index; // will be assigned with either X or Y

	// regs that store the type of operation. again, this simplifies the FSM a lot.
	reg read;
	reg read_modify_write;
	reg write;
	reg jump;
	reg jump_indirect;

	// regs for the special instructions
	reg break;
	reg rti;
	reg rts;
	reg pha;
	reg php;	

	wire [ADDR_SIZE_:0] next_pc;
	assign next_pc = pc + 13'b0000000000001;

	reg [ADDR_SIZE_:0] address_plus_index; // this would update more times than actually needed, consuming power.
	reg page_crossed;			// so the simple assign was changed into a combinational always block
	
	reg branch;

	always @(*) begin
		address_plus_index = 0;
		page_crossed = 0;

		if (state == READ_MEM_CALC_INDEX || state == READ_MEM_FIX_ADDR || state == FETCH_HIGH_CALC_INDEX) begin
			{page_crossed, address_plus_index[7:0]} = temp_addr[7:0] + index;
			address_plus_index[12:8] = temp_addr[12:8] + page_crossed;
		end
		else if (branch) begin
			if (state == FETCH_OP_FIX_PC || state == FETCH_OP_EVAL_BRANCH) begin
				{page_crossed, address_plus_index[7:0]} = pc[7:0] + index;
				address_plus_index[12:8] = pc[12:8] + page_crossed;// warning: pc might feed these lines twice and cause branch failure
			end								// solution: add a temp reg i guess
		end
		else if (state == READ_FROM_POINTER) begin
			if (indirectx) begin
				{page_crossed, address_plus_index[7:0]} = temp_data + index;
				address_plus_index[12:8] = 5'b00000;
			end
			else if (jump_indirect) begin
				address_plus_index[7:0] = temp_addr + 8'h01;
				address_plus_index[12:8] = 5'b00000;
			end
			else begin // indirecty falls here
				address_plus_index[7:0] = temp_data + 8'h01;
				address_plus_index[12:8] = 5'b00000;
			end
		end
		else if (state == READ_FROM_POINTER_X) begin
			{page_crossed, address_plus_index[7:0]} = temp_data + index + 8'h01;
			address_plus_index[12:8] = 5'b00000;
		end
		else if (state == READ_FROM_POINTER_X1) begin
			{page_crossed, address_plus_index[7:0]} = temp_addr[7:0] + index;
			address_plus_index[12:8] = temp_addr[12:8] + page_crossed;
		end
	end

	wire [8:0] sp_plus_one;
	assign sp_plus_one = sp + 9'b000000001;

	wire [8:0] sp_minus_one;
	assign sp_minus_one = sp - 9'b000000001;

	always @ (posedge clk or negedge reset_n) begin // sequencial always block
		if (reset_n == 1'b0) begin
			// all registers must assume default values
			pc <= 0; // TODO: this is written somewhere. something about a reset vector. must be checked.
			sp <= 9'b100000000; // the default is 'h100 
			ir <= 8'h00;
			temp_addr <= 13'h00;
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
				RESET: begin	// The processor was reset
					$write("under reset"); 
				end
				/*
				FETCH_OP: executed when the processor was reset or the last instruction could not fetch.
				FETCH_OP_CALC: enables the alu and fetchs the next instruction opcode. (pipelining)
				FETCH_OP_CALC_PARAM: enables the alu with an argument (alu_a) and fetchs the next instruction opcode. (pipelining)
				*/
				FETCH_OP, FETCH_OP_CALC, FETCH_OP_CALC_PARAM: begin // this is the pipeline happening!
					pc <= next_pc;
					address <= next_pc;
					control <= MEM_READ; 
					ir <= data_in;
				end
				/*
				in this state the opcode is already known so truly execution begins.
				all instruction execute this cycle.
				*/
				FETCH_LOW: begin 		
					if (accumulator || implied) begin
						pc <= pc; // is this better?
						address <= pc;
						control <= MEM_READ; 
					end
					else if (immediate || relative) begin
						pc <= next_pc;
						address <= next_pc;
						control <= MEM_READ; 
						temp_data <= data_in; // the follow-up byte is saved in temp_data 
					end
					else if (absolute || absolute_indexed || jump_indirect) begin
						pc <= next_pc;
						address <= next_pc;					
						control <= MEM_READ; 
						temp_addr <= {{5{1'b0}},data_in};
						temp_data <= 8'h00;
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
						address <= {{5{1'b0}}, data_in};
						temp_addr <= {{5{1'b0}}, data_in};
						control <= MEM_READ; 
					end
					else if (indirectx || indirecty) begin
						pc <= next_pc;
						address <= data_in;
						temp_data <= data_in;
						control <= MEM_READ;
					end
					else begin // the special instructions will fall here: BRK, RTI, RTS...
						if (break) begin
							pc <= next_pc;
							address <= sp;
							data_out <= {{3{1'b0}}, pc[12:8]};
							control <= MEM_WRITE;
							sp <= sp_minus_one;
						end
						else if (rti || rts) begin
							address <= sp;
							control <= MEM_READ;
						end
						else if (pha || php) begin
							pc <= pc;
							address <= sp;
							data_out <= (pha) ? alu_result : alu_status;
							control <= MEM_WRITE;
						end
					end
				end
				FETCH_HIGH_CALC_INDEX: begin
					pc <= next_pc;
					temp_addr[12:8] <= data_in[4:0];
					address <= {data_in[4:0], address_plus_index[7:0]};
					control <= MEM_READ; 
					data_out <= 8'h00;
				end
				// this cycle fetchs the next operand while still evaluating if a branch occurred.
				FETCH_OP_EVAL_BRANCH: begin
					if (branch) begin
						pc <= {{5{1'b0}}, address_plus_index[7:0]};
						address <= {{5{1'b0}}, address_plus_index[7:0]};
						control <= MEM_READ; 
						data_out <= 8'h00;
					end
					else begin
						pc <= next_pc;
						address <= next_pc;
						control <= MEM_READ; 
						data_out <= 8'h00;
						ir <= data_in;
					end
				end
				// sometimes when reading memory page crosses may occur. the pc register must be fixed, i.e., add 16'h0100
				FETCH_OP_FIX_PC: begin
					if (page_crossed) begin
						pc[12:8] <= address_plus_index[12:8];
						address[12:8] <= address_plus_index[12:8];
					end
					else begin
						pc <= next_pc;
						address <= next_pc;
						control <= MEM_READ; 
						ir <= data_in;
					end
				end
				// several instructions ocupy 3 bytes in memory. this cycle reads the third byte.
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
				READ_MEM_FIX_ADDR: begin
					if (read) begin
						control <= MEM_READ;
						data_out <= 8'h00;

						if (page_crossed) begin
							address <= address_plus_index;
							temp_addr <= address_plus_index;
						end
						else begin
							address <= pc;
							temp_data <= data_in;
						end
					end
					else if (write) begin
						control <= MEM_WRITE;
						data_out <= alu_result;
						address <= address_plus_index;
						temp_addr <= address_plus_index;

					end
					else begin // read modify write
						control <= MEM_READ; 
						data_out <= 8'h00;
						address <= address_plus_index;
						temp_addr <= address_plus_index;
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
				READ_FROM_POINTER: begin
					if (jump_indirect) begin
						pc[7:0] <= data_in;
						control <= MEM_READ;
						address <= address_plus_index;
					end
					else begin
						pc <= pc;
						control <= MEM_READ;
					
						if (indirectx) begin 
							address <= address_plus_index;
						end
						else begin // indirecty falls here
							address <= address_plus_index;
							temp_addr <= {{5{1'b0}}, data_in}; 
						end
					end
				end
				READ_FROM_POINTER_X: begin
					pc <= pc;
					address <= address_plus_index;
					temp_addr[7:0] <= data_in;
					control <= MEM_READ;
				end
				READ_FROM_POINTER_X1: begin
					if (jump_indirect) begin
						pc[12:8] <= data_in[4:0];
						control <= MEM_READ;
						address <= {data_in[4:0], pc[7:0]};
					end
					else if (indirectx) begin
						address <= {data_in[4:0], temp_addr[7:0]};
						if (write) begin
							control <= MEM_WRITE;
							data_out <= alu_result;
						end
						else begin
							control <= MEM_READ;
						end
					end
					else begin // indirecty falls here
						address <= address_plus_index;
						temp_addr[12:8] <= data_in;
						control <= MEM_READ;
					end
				end
				PUSH_PCH: begin
					pc <= pc;
					address <= sp;
					data_out <= pc[7:0];
					control <= MEM_WRITE;
					sp <= sp_minus_one;
				end
				PUSH_PCL: begin
					pc <= pc;
					address <= sp;
					data_out <= alu_status;
					control <= MEM_WRITE;
					sp <= sp_minus_one;
				end
				PUSH_STATUS: begin
					address <= 13'hFFFE;
					control <= MEM_READ;
				end
				FETCH_PCL: begin
					pc[7:0] <= data_in;
					address <= 13'hFFFF;
					control <= MEM_READ;
				end
				FETCH_PCH: begin
					pc[12:8] <= data_in[4:0];
					address <= {data_in[4:0], pc[7:0]};
					control <= MEM_READ;
				end
				INCREMENT_SP: begin
					sp <= sp_plus_one;
					address <= sp_plus_one;
				end
				PULL_STATUS: begin
					sp <= sp_plus_one;
					address <= sp_plus_one;
					temp_data <= data_in;
				end
				PULL_PCL: begin
					sp <= sp_plus_one;
					address <= sp_plus_one;
					pc[7:0] <= data_in;
				end
				PULL_PCH: begin
					pc[12:8] <= data_in[4:0];
					address <= {data_in[4:0], pc[7:0]};
				end
				INCREMENT_PC: begin
					pc <= next_pc;
					address <= next_pc;
				end
				PUSH_REGISTER: begin
					pc <= pc;
					address <= pc;
					sp <= sp_minus_one;
					control <= MEM_READ;
				end
				default: begin
					$write("unknown state"); // TODO: check if synth really ignores this 2 lines. Otherwise wrap it with a `ifdef 
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
				else if (absolute || jump_indirect) begin // at least the absolute address mode falls here
					next_state = FETCH_HIGH;
					if (write) begin // this is being done one cycle early but i have checked and the ALU will still work properly
						alu_opcode = ir;
						alu_enable = 1'b1;
						alu_a = 8'h00;
					end
				end
				else if (absolute_indexed) begin
					next_state = FETCH_HIGH_CALC_INDEX;
				end
				else if (relative) begin
					next_state = FETCH_OP_EVAL_BRANCH;
				end
				else if (indirectx || indirecty) begin
					next_state = READ_FROM_POINTER;
				end
				else begin // all the special instructions will fall here
					if (break) begin
						next_state = PUSH_PCH;
					end
					else if (rti || rts) begin
						next_state = INCREMENT_SP;
					end
					else if (pha) begin
						alu_opcode = ir;
						alu_enable = 1'b1;
						//alu_a = 8'h00;
						next_state = PUSH_REGISTER;
					end
					else if (php) begin
						next_state = PUSH_REGISTER;
					end
				end
			end
			READ_FROM_POINTER: begin
				if (indirectx) begin
					next_state = READ_FROM_POINTER_X;
				end
				else begin // indirecty and jump indirect falls here
					next_state = READ_FROM_POINTER_X1;
				end
			end
			READ_FROM_POINTER_X: begin
				next_state = READ_FROM_POINTER_X1;
			end
			READ_FROM_POINTER_X1: begin
				if (jump_indirect) begin
					next_state = FETCH_OP;
				end
				else if (indirecty) begin
					next_state = READ_MEM_FIX_ADDR;
				end
				else begin 
					if (read) begin // read_modify_write was showing up here for no reason. no instruction using pointers is from that type.
						next_state = READ_MEM;
					end
					else if (write) begin
						alu_opcode = ir;
						alu_enable = 1'b1;
						next_state = WRITE_MEM;
					end
				end
			end
			FETCH_OP_EVAL_BRANCH: begin
				if (branch) begin
					next_state = FETCH_OP_FIX_PC;
				end
				else begin
					next_state = FETCH_LOW;
				end
			end
			FETCH_OP_FIX_PC: begin
				if (page_crossed) begin
					next_state = FETCH_OP;
				end
				else begin
					next_state = FETCH_LOW;
				end
			end
			FETCH_HIGH_CALC_INDEX: begin
				next_state = READ_MEM_FIX_ADDR;
			end
			READ_MEM_FIX_ADDR: begin
				if (read) begin
					if (page_crossed) begin
						next_state = READ_MEM;
					end
					else begin
						next_state = FETCH_OP_CALC_PARAM;
					end
				end
				else if (read_modify_write) begin
					next_state = READ_MEM;
				end
				else if (write) begin
					next_state = WRITE_MEM;
					alu_enable = 1'b1;
					alu_opcode = ir;
				end
				else begin
					$write("unknown behavior"); 
					$finish(0);
				end
			end
			FETCH_HIGH: begin
				if (jump_indirect) begin
					next_state = READ_FROM_POINTER;
				end
				else if (jump) begin
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
			PUSH_PCH: begin
				next_state = PUSH_PCL;
			end
			PUSH_PCL: begin
				next_state = PUSH_STATUS;
			end
			PUSH_STATUS: begin
				next_state = FETCH_PCL;
			end
			FETCH_PCL: begin
				next_state = FETCH_PCH;
			end
			FETCH_PCH: begin
				next_state = FETCH_OP;
			end
			INCREMENT_SP: begin
				if (rti) begin 
					next_state = PULL_STATUS;
				end				
				else begin // rts
					next_state = PULL_PCL;
				end 
			end
			PULL_STATUS: begin
				next_state = PULL_PCL;
			end
			PULL_PCL: begin
				next_state = PULL_PCH;
				alu_opcode = ir;
				alu_enable = 1'b1;
				alu_a = temp_data;
			end
			PULL_PCH: begin
				if (rti) begin
					next_state = FETCH_OP;
				end
				else begin // rts
					next_state = INCREMENT_PC;
				end
			end
			INCREMENT_PC: begin
				next_state = FETCH_OP;
			end
			PUSH_REGISTER: begin
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
		indirectx = 1'b0;
		indirecty = 1'b0;
		relative = 1'b0;
		zero_page = 1'b0;
		zero_page_indexed = 1'b0;
	
		index = 1'b0;

		read = 1'b0;
		read_modify_write = 1'b0;
		write = 1'b0;
		jump = 1'b0;
		jump_indirect = 1'b0;
		branch = 1'b0;

		break = 1'b0;
		rti = 1'b0;
		rts = 1'b0;
		pha = 1'b0;
		php = 1'b0;

		case (ir)
			CLC_IMP, CLD_IMP, CLI_IMP, CLV_IMP, DEX_IMP, DEY_IMP, INX_IMP, INY_IMP, NOP_IMP, 
			SEC_IMP, SED_IMP, SEI_IMP, TAX_IMP, TAY_IMP, TSX_IMP, TXA_IMP, TXS_IMP, TYA_IMP: begin
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
			BCC_REL: begin
				relative = 1'b1;
				index = temp_data;
				
				if (!alu_status[C]) begin
					branch = 1'b1;
				end
				else begin
					branch = 1'b0;
				end
			end
			BCS_REL: begin
				relative = 1'b1;
				index = temp_data;

				if (alu_status[C]) begin
					branch = 1'b1;
				end
				else begin
					branch = 1'b0;
				end
			end
			BEQ_REL: begin
				relative = 1'b1;
				index = temp_data;
				
				if (alu_status[Z]) begin
					branch = 1'b1;
				end
				else begin
					branch = 1'b0;
				end
			end
			BNE_REL: begin
				relative = 1'b1;
				index = temp_data;
				
				if (alu_status[Z] == 1'b0) begin
					branch = 1'b1;
				end
				else begin
					branch = 1'b0;
				end
			end
			BPL_REL: begin
				relative = 1'b1;
				index = temp_data;
				
				if (!alu_status[N]) begin
					branch = 1'b1;
				end
				else begin
					branch = 1'b0;
				end
			end
			BMI_REL: begin
				relative = 1'b1;
				index = temp_data;
				
				if (alu_status[N]) begin
					branch = 1'b1;
				end
				else begin
					branch = 1'b0;
				end
			end
			BVC_REL: begin
				relative = 1'b1;
				index = temp_data;
				
				if (!alu_status[V]) begin
					branch = 1'b1;
				end
				else begin
					branch = 1'b0;
				end
			end
			BVS_REL: begin
				relative = 1'b1;
				index = temp_data;
				
				if (alu_status[V]) begin
					branch = 1'b1;
				end
				else begin
					branch = 1'b0;
				end
			end
			ADC_ABS, AND_ABS, ASL_ABS, BIT_ABS, CMP_ABS, CPX_ABS, CPY_ABS, DEC_ABS, EOR_ABS, INC_ABS, JSR_ABS, LDA_ABS, 
			LDX_ABS, LDY_ABS, LSR_ABS, ORA_ABS, ROL_ABS, ROR_ABS, SBC_ABS, STA_ABS, STX_ABS, STY_ABS: begin
				absolute = 1'b1;
			end
			ADC_ABX, AND_ABX, ASL_ABX, CMP_ABX, DEC_ABX, EOR_ABX, INC_ABX, LDA_ABX, LDY_ABX, LSR_ABX, ORA_ABX, ROL_ABX, ROR_ABX,
			SBC_ABX, STA_ABX: begin
				absolute_indexed = 1'b1;
				index = alu_x;
			end
			ADC_ABY, AND_ABY, CMP_ABY, EOR_ABY, LDA_ABY, LDX_ABY, ORA_ABY, SBC_ABY, STA_ABY: begin
				absolute_indexed = 1'b1;
				index = alu_y;
			end
			ADC_IDX, AND_IDX, CMP_IDX, EOR_IDX, LDA_IDX, ORA_IDX, SBC_IDX, STA_IDX: begin
				indirectx = 1'b1;
				index = alu_x;
			end
			ADC_IDY, AND_IDY, CMP_IDY, EOR_IDY, LDA_IDY, ORA_IDY, SBC_IDY, STA_IDY: begin 
				indirecty = 1'b1;
				index = alu_y;	
			end
			JMP_ABS: begin
				absolute = 1'b1;
				jump = 1'b1;
			end
			JMP_IND: begin
				jump_indirect = 1'b1;
			end
			BRK_IMP: begin
				break = 1'b1;
			end
			RTI_IMP: begin
				rti = 1'b1;
			end
			RTS_IMP: begin
				rts = 1'b1;
			end
			PHA_IMP: begin
				pha = 1'b1;
			end
			PHP_IMP: begin
				php = 1'b1;
			end
			default: begin
				$write("state : %b", state);
				if (reset_n == 1 && state != FETCH_OP_FIX_PC) begin // the processor is NOT being reset neither it is fixing the pc
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
	end 
endmodule



