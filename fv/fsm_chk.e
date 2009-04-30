<'
import fsm_components;
type state_t : [RESET, CYCLE_1, CYCLE_2, CYCLE_3, CYCLE_4, CYCLE_5, CYCLE_6, CYCLE_7];
unit fsm_chk_u {
	!A  : byte;
	  keep soft A == 0;
	!X  : byte;
	  keep soft X == 0;
	!Y  : byte;
	  keep soft Y == 0;
	!PC : uint(bits : 13);
	  keep soft PC == 0;
//	!SP : uint(bits : 9);
//	  keep soft SP == 9'b100000000;
	!SP : byte;
	  keep soft SP == 0;

	!more_cycles : bool;
	  keep soft more_cycles == FALSE;
	--!R  : byte;
	-- keep soft R == 0;
	--!PS : byte;
	--  keep soft PS[0:0] == 0;
	--  keep soft PS[1:1] == 0;
	--  keep soft PS[2:2] == 0;
	--  keep soft PS[3:3] == 0;
	--  keep soft PS[4:4] == 0;
	--  keep soft PS[5:5] == 1;
	--  keep soft PS[6:6] == 0;
	--  keep soft PS[7:7] == 0;
	-- N : bit;
	-- V : bit;
	-- B : bit;
	-- D : bit;
	-- I : bit;
	-- Z : bit;
	-- C : bit;
	-- keep soft N == 0;
	-- keep soft V == 0;
	-- keep soft B == 0;
	-- keep soft D == 0;
	-- keep soft I == 0;
	-- keep soft Z == 0;
	-- keep soft C == 0;

	!new_inst   : bool;
	keep new_inst == FALSE;
	!new_input : fsm_input_s;
	!old_input : fsm_input_s;
	--!new_inst  : bool;
	--keep soft new_inst == FALSE;

	--!i : ps_index;

	!new_state : state_t;
	!old_state : state_t;
	
	--count_cycles : int;
	--first_cycle  : bool;
	--last_a       : byte;
	--last_status  : byte;
	--last_result  : byte;
	!PCL:byte;
	!PCH:byte;
	!SP_aux:byte;
	!rst : bit;
	!rst_counter  : byte;

	--keep first_cycle  == TRUE;
	--keep count_cycles == 0;
	keep rst_counter  == 0;
	
	!instruction      : valid_opcodes;
	!last_instruction : valid_opcodes;
	!instructions     : valid_opcodes;

	print_state () is {
		outf("-------------------------------------------------------\n");
		print instructions;
		-- print instruction;
		print 't6507lp_fsm.ir';
		print 't6507lp_fsm.sp';
		print SP + 256;
		print 't6507lp_fsm.pc';
		print PC;
		--print addr;
		case ('t6507lp_fsm.state') {
			0  : { outf("  t6507lp_fsm.state = FETCH_OP\n"); };
			2  : { outf("  t6507lp_fsm.state = FETCH_LOW\n");};
			3  : { outf("  t6507lp_fsm.state = FETCH_HIGH\n"); };
			4  : { outf("  t6507lp_fsm.state = READ_MEM\n"); };
			5  : { outf("  t6507lp_fsm.state = DUMMY_WRT_CALC\n"); };
			6  : { outf("  t6507lp_fsm.state = WRITE_MEM\n"); };
			7  : { outf("  t6507lp_fsm.state = FETCH_OP_CALC_PARAM\n"); };
			8  : { outf("  t6507lp_fsm.state = READ_MEM_CALC_INDEX\n"); };
			9  : { outf("  t6507lp_fsm.state = FETCH_HIGH_CALC_INDEX\n"); };
			10 : { outf("  t6507lp_fsm.state = READ_MEM_FIX_ADDR\n"); };
			11 : { outf("  t6507lp_fsm.state = FETCH_OP_EVAL_BRANCH\n"); };
			12 : { outf("  t6507lp_fsm.state = FETCH_OP_FIX_PC\n"); };
			13 : { outf("  t6507lp_fsm.state = READ_FROM_POINTER\n"); };
			14 : { outf("  t6507lp_fsm.state = READ_FROM_POINTER_X\n"); };
			15 : { outf("  t6507lp_fsm.state = READ_FROM_POINTER_X1\n"); };
			16 : { outf("  t6507lp_fsm.state = PUSH_PCH\n"); };
			17 : { outf("  t6507lp_fsm.state = PUSH_PCL\n"); };
			18 : { outf("  t6507lp_fsm.state = PUSH_STATUS\n"); };
			19 : { outf("  t6507lp_fsm.state = FETCH_PCL\n"); };
			20 : { outf("  t6507lp_fsm.state = FETCH_PCH\n"); };
			21 : { outf("  t6507lp_fsm.state = INCREMENT_SP\n"); };
			22 : { outf("  t6507lp_fsm.state = PULL_STATUS\n"); };
			23 : { outf("  t6507lp_fsm.state = PULL_PCL\n"); };
			24 : { outf("  t6507lp_fsm.state = PULL_PCH\n"); };
			25 : { outf("  t6507lp_fsm.state = INCREMENT_PC\n"); };
			26 : { outf("  t6507lp_fsm.state = PUSH_REGISTER\n"); };
			27 : { outf("  t6507lp_fsm.state = PULL_REGISTER\n"); };
			28 : { outf("  t6507lp_fsm.state = DUMMY\n"); };
			31 : { outf("  t6507lp_fsm.state = RESET\n"); };
		};
	};

	store(input : fsm_input_s) is {
	--reset_n    : bit;
	--alu_result : byte;
	--alu_status : byte;
	--data_in    : byte;
	--alu_x      : byte;
	--alu_y      : byte;
	//print me;
	//print input;
		if (input.reset_n == 0) {
		  rst_counter = 0;
		  new_state = RESET;
		  old_state = RESET;
		  A = 0;
		  X = 0;
		  Y = 0;
		  PC = 0;
		  SP = 255;
		}
		else {
			case (old_state) {
				RESET    : {
					if (rst_counter == 7) {
						new_state = CYCLE_1;
					};
				};
				CYCLE_1 : {
					instruction = input.data_in.as_a(valid_opcodes);
					new_state = CYCLE_2;
				};
				CYCLE_2 : {
					X = input.alu_x;
					Y = input.alu_y;
					print X, Y;
					outf("CYCLE_1\n");
					case {
						(
						  instruction == BRK_IMP ||
						  instruction == PHA_IMP ||
						  instruction == PHP_IMP ||
						  instruction == PLA_IMP ||
						  instruction == PLP_IMP ||
						  instruction == RTI_IMP ||
						  instruction == RTS_IMP
						) : {
							new_state = CYCLE_3;
						};
						//JSR_ABS : {
						//	new_state = CYCLE_3;
						//	PCL = input.data_in;
						//};
						(
						  instruction == ADC_ABS ||
						  instruction == ASL_ABS ||
						  instruction == BIT_ABS ||
						  instruction == AND_ABS ||
						  instruction == CMP_ABS ||
						  instruction == DEC_ABS ||
						  instruction == EOR_ABS ||
						  instruction == INC_ABS ||
						  instruction == JMP_ABS ||
						  instruction == LDA_ABS ||
						  instruction == LDX_ABS ||
						  instruction == LDY_ABS ||
						  instruction == LSR_ABS ||
						  instruction == ORA_ABS ||
						  instruction == ROL_ABS ||
						  instruction == ROR_ABS ||
						  instruction == SBC_ABS ||
						  instruction == STA_ABS ||
						  instruction == STX_ABS ||
						  instruction == STY_ABS ||
						  instruction == LDA_ZPG ||
						  instruction == LDX_ZPG ||
						  instruction == LDY_ZPG ||
						  instruction == EOR_ZPG ||
						  instruction == AND_ZPG ||
						  instruction == ORA_ZPG ||
						  instruction == ADC_ZPG ||
						  instruction == SBC_ZPG ||
						  instruction == CMP_ZPG ||
						  instruction == BIT_ZPG ||
						  instruction == STA_ZPG ||
						  instruction == STX_ZPG ||
						  instruction == STY_ZPG ||
						  instruction == ASL_ZPG ||
						  instruction == LSR_ZPG ||
						  instruction == ROL_ZPG ||
						  instruction == ROR_ZPG ||
						  instruction == INC_ZPG ||
						  instruction == DEC_ZPG ||
						  instruction == LDA_ZPX ||
						  instruction == LDX_ZPY ||
						  instruction == LDY_ZPX ||
						  instruction == EOR_ZPX ||
						  instruction == AND_ZPX ||
						  instruction == ORA_ZPX ||
						  instruction == ADC_ZPX ||
						  instruction == SBC_ZPX ||
						  instruction == CMP_ZPX ||
						  instruction == ASL_ZPX ||
						  instruction == LSR_ZPX ||
						  instruction == ROL_ZPX ||
						  instruction == ROR_ZPX ||
						  instruction == INC_ZPX ||
						  instruction == DEC_ZPX ||
						  instruction == STA_ZPX ||
						  instruction == STX_ZPY ||
						  instruction == STY_ZPX
						) : {
							new_state = CYCLE_3;
							PCL = input.data_in;
							--print X, Y;
							--print input.alu_x, input.alu_y;
							--print 't6507lp_fsm.index';
						};
						(
						  instruction == LDA_ABX ||
						  instruction == LDA_ABY ||
						  instruction == LDX_ABY ||
						  instruction == LDY_ABX ||
						  instruction == EOR_ABX ||
						  instruction == EOR_ABY ||
						  instruction == AND_ABX ||
						  instruction == AND_ABY ||
						  instruction == ORA_ABX ||
						  instruction == ORA_ABY ||
						  instruction == ADC_ABX ||
						  instruction == ADC_ABY ||
						  instruction == SBC_ABX ||
						  instruction == SBC_ABY ||
						  instruction == CMP_ABX ||
						  instruction == CMP_ABY
						) : {
							new_state = CYCLE_3;
							PCL = input.data_in;
							--X = input.alu_x;
							--Y = input.alu_y;
							--print X, Y;
							--print input.alu_x, input.alu_y;
							--print 't6507lp_fsm.index';
							--outf("CYCLE_2\n");
						};
						(
						  instruction == TXS_IMP
						) : {
							new_state = CYCLE_1;
							SP_aux    = input.alu_x;
						};
						default : {
							new_state = CYCLE_1;
						};
					};
				};
				CYCLE_3 : {
					case {
						(
						  instruction == BRK_IMP ||
						  instruction == PLA_IMP ||
						  instruction == PLP_IMP ||
						  instruction == RTI_IMP ||
						  instruction == RTS_IMP ||
						  instruction == ASL_ZPG ||
						  instruction == LSR_ZPG ||
						  instruction == ROL_ZPG ||
						  instruction == ROR_ZPG ||
						  instruction == INC_ZPG ||
						  instruction == DEC_ZPG
						) : {
							new_state = CYCLE_4;
						};
						//JSR_ABS : {
						//	new_state = CYCLE_4;
						//	PCH = input.data_in;
						//};
						(
						  instruction == LDA_ZPX ||
						  instruction == LDX_ZPY ||
						  instruction == LDY_ZPX ||
						  instruction == EOR_ZPX ||
						  instruction == AND_ZPX ||
						  instruction == ORA_ZPX ||
						  instruction == ADC_ZPX ||
						  instruction == SBC_ZPX ||
						  instruction == CMP_ZPX ||
						  instruction == ASL_ZPX ||
						  instruction == LSR_ZPX ||
						  instruction == ROL_ZPX ||
						  instruction == ROR_ZPX ||
						  instruction == INC_ZPX ||
						  instruction == DEC_ZPX ||
						  instruction == STA_ZPX ||
						  instruction == STX_ZPY ||
						  instruction == STY_ZPX
						) : {
							new_state = CYCLE_4;
							--X = input.alu_x;
							--Y = input.alu_y;
							--print X, Y;
							--print input.alu_x, input.alu_y;
							--print 't6507lp_fsm.index';
						};
						(
						  instruction == ADC_ABS ||
						  instruction == ASL_ABS ||
						  instruction == BIT_ABS ||
						  instruction == AND_ABS ||
						  instruction == CMP_ABS ||
						  instruction == DEC_ABS ||
						  instruction == EOR_ABS ||
						  instruction == INC_ABS ||
						  instruction == LDA_ABS ||
						  instruction == LDX_ABS ||
						  instruction == LDY_ABS ||
						  instruction == LSR_ABS ||
						  instruction == ORA_ABS ||
						  instruction == ROL_ABS ||
						  instruction == ROR_ABS ||
						  instruction == SBC_ABS ||
						  instruction == STA_ABS ||
						  instruction == STX_ABS ||
						  instruction == STY_ABS ||
  						  instruction == LDA_ABX ||
						  instruction == LDA_ABY ||
						  instruction == LDX_ABY ||
						  instruction == LDY_ABX ||
						  instruction == EOR_ABX ||
						  instruction == EOR_ABY ||
						  instruction == AND_ABX ||
						  instruction == AND_ABY ||
						  instruction == ORA_ABX ||
						  instruction == ORA_ABY ||
						  instruction == ADC_ABX ||
						  instruction == ADC_ABY ||
						  instruction == SBC_ABX ||
						  instruction == SBC_ABY ||
						  instruction == CMP_ABX ||
						  instruction == CMP_ABY
						) : {
							new_state = CYCLE_4;
							PCH = input.data_in;
							--X = input.alu_x;
							--Y = input.alu_y;
							--print X, Y;
							--print input.alu_x, input.alu_y;
							--print 't6507lp_fsm.index';
							--outf("CYCLE_3\n");
						};
						(
						  instruction == JMP_ABS
						) : {
							new_state = CYCLE_1;
							PCH = input.data_in;
						};
						default : {
							new_state = CYCLE_1;
						};
					};
				};
				CYCLE_4 : {
					case {
						//JSR_ABS : {
						//	new_state = CYCLE_5;
						//};
						(
						  instruction == RTS_IMP
						) : {
							new_state = CYCLE_5;
							PCL = input.data_in;
						};
						(
						  instruction == ASL_ABS ||
						  instruction == BRK_IMP ||
						  instruction == DEC_ABS ||
						  instruction == INC_ABS ||
						  instruction == LSR_ABS ||
						  instruction == ROL_ABS ||
						  instruction == ROR_ABS ||
						  instruction == RTI_IMP ||
						  instruction == ASL_ZPG ||
						  instruction == LSR_ZPG ||
						  instruction == ROL_ZPG ||
						  instruction == ROR_ZPG ||
						  instruction == INC_ZPG ||
						  instruction == DEC_ZPG ||
  						  instruction == ASL_ZPX ||
						  instruction == LSR_ZPX ||
						  instruction == ROL_ZPX ||
						  instruction == ROR_ZPX ||
						  instruction == INC_ZPX ||
						  instruction == DEC_ZPX ||
						  (
						  	more_cycles == TRUE &&
							(
							  instruction == LDA_ABX ||
							  instruction == LDA_ABY ||
							  instruction == LDX_ABY ||
							  instruction == LDY_ABX ||
							  instruction == EOR_ABX ||
							  instruction == EOR_ABY ||
							  instruction == AND_ABX ||
							  instruction == AND_ABY ||
							  instruction == ORA_ABX ||
							  instruction == ORA_ABY ||
							  instruction == ADC_ABX ||
							  instruction == ADC_ABY ||
							  instruction == SBC_ABX ||
							  instruction == SBC_ABY ||
							  instruction == CMP_ABX ||
							  instruction == CMP_ABY
							)
						  )
						) : {
							--X = input.alu_x;
							--Y = input.alu_y;
							--print X, Y;
							--print input.alu_x, input.alu_y;
							--print 't6507lp_fsm.index';
							--outf("CYCLE_4\n");
							new_state = CYCLE_5;
						};
						default : {
							new_state = CYCLE_1;
						};
					};
				};
				CYCLE_5 : {
					case {
						//JSR_ABS : {
						//	new_state = CYCLE_6;
						//};
						(
						  instruction == RTI_IMP
						) : {
							new_state = CYCLE_6;
							PCL = input.data_in;
						};
						(
						  instruction == RTS_IMP
						) : {
							new_state = CYCLE_6;
							PCH = input.data_in;
						};
						(
						  instruction == ASL_ABS ||
						  instruction == BRK_IMP ||
						  instruction == DEC_ABS ||
						  instruction == INC_ABS ||
						  instruction == LSR_ABS ||
						  instruction == ROL_ABS ||
						  instruction == ROR_ABS ||
						  instruction == ASL_ZPX ||
						  instruction == LSR_ZPX ||
						  instruction == ROL_ZPX ||
						  instruction == ROR_ZPX ||
						  instruction == INC_ZPX ||
						  instruction == DEC_ZPX
						) : {
							new_state = CYCLE_6;
						};
						(
  						  instruction == LDA_ABX ||
						  instruction == LDA_ABY ||
						  instruction == LDX_ABY ||
						  instruction == LDY_ABX ||
						  instruction == EOR_ABX ||
						  instruction == EOR_ABY ||
						  instruction == AND_ABX ||
						  instruction == AND_ABY ||
						  instruction == ORA_ABX ||
						  instruction == ORA_ABY ||
						  instruction == ADC_ABX ||
						  instruction == ADC_ABY ||
						  instruction == SBC_ABX ||
						  instruction == SBC_ABY ||
						  instruction == CMP_ABX ||
						  instruction == CMP_ABY
						) : {
							new_state = CYCLE_1;
							--X = input.alu_x;
							--Y = input.alu_y;
							--print X, Y;
							--print input.alu_x, input.alu_y;
							--print 't6507lp_fsm.index';
							--outf("CYCLE_5\n");
						};
						--(
						--  instruction == LDA_ZPX ||
						--  instruction == LDX_ZPY ||
						--  instruction == LDY_ZPX ||
						--  instruction == EOR_ZPX ||
						--  instruction == AND_ZPX ||
						--  instruction == ORA_ZPX ||
						--  instruction == ADC_ZPX ||
						--  instruction == SBC_ZPX ||
						--  instruction == CMP_ZPX ||
						--  instruction == ASL_ZPX ||
						--  instruction == LSR_ZPX ||
						--  instruction == ROL_ZPX ||
						--  instruction == ROR_ZPX ||
						--  instruction == INC_ZPX ||
						--  instruction == DEC_ZPX ||
						--  instruction == STA_ZPX ||
						--  instruction == STX_ZPY ||
						--  instruction == STY_ZPX
						--) : {
						--	new_state = CYCLE_1;
							--X = input.alu_x;
							--Y = input.alu_y;
							--print input.alu_x, input.alu_y;

						--};
						default : {
							new_state = CYCLE_1;
						};
					};
				};
				CYCLE_6 : {
					case {
						(
						  instruction == BRK_IMP
						) : {
							new_state = CYCLE_7;
							PCL = input.data_in;
						};
						(
						  instructions == RTI_IMP
						) : {
							new_state = CYCLE_1;
							PCH = input.data_in;
						};
						default : {
							new_state = CYCLE_1;
						};
					};
				};
				CYCLE_7 : {
					//case (instruction) {
					//	BRK_IMP : {
					//		new_state = CYCLE_6;
					//	};
					//	default :
						new_state = CYCLE_1;
						PCH = input.data_in
					};
			};
			old_input = new_input;
			new_input = input;
		};
	};

	compare(addr: uint(bits:13), mem_rw:bit, data_out:byte, alu_opcode:valid_opcodes, alu_a:byte, alu_enable:bit) is {
		case (old_state) {
			RESET    : {
				print_state();
				rst = 1;
				rst_counter = rst_counter + 1;
			};
			CYCLE_1 : {
				more_cycles = FALSE;
				print_state();
				print addr;
				last_instruction = instructions;
				instructions = instruction;
				//print instructions;
				//print last_instruction;
				if (mem_rw != 0) {
					dut_error("Mem_rw is Wrong!");
				};
				if (rst == 0) {
					case {
						(
						  last_instruction == ADC_ABS ||
						  last_instruction == ADC_IMM ||
						  last_instruction == AND_ABS ||
						  last_instruction == AND_IMM ||
						  last_instruction == BIT_ABS ||
						  last_instruction == CMP_ABS ||
						  last_instruction == CMP_IMM ||
						  last_instruction == CPX_IMM ||
						  last_instruction == CPY_IMM ||
						  last_instruction == EOR_ABS ||
						  last_instruction == EOR_IMM ||
						  last_instruction == LDA_ABS ||
						  last_instruction == LDA_IMM ||
						  last_instruction == LDX_ABS ||
						  last_instruction == LDX_IMM ||
						  last_instruction == LDY_ABS ||
						  last_instruction == LDY_IMM ||
						  last_instruction == ORA_ABS ||
						  last_instruction == ORA_IMM ||
						  last_instruction == PLA_IMP ||
						  last_instruction == PLP_IMP ||
						  last_instruction == SBC_ABS ||
						  last_instruction == SBC_IMM ||
	  					  last_instruction == LDA_ZPG ||
						  last_instruction == LDX_ZPG ||
						  last_instruction == LDY_ZPG ||
						  last_instruction == EOR_ZPG ||
						  last_instruction == AND_ZPG ||
						  last_instruction == ORA_ZPG ||
						  last_instruction == ADC_ZPG ||
						  last_instruction == SBC_ZPG ||
						  last_instruction == CMP_ZPG ||
						  last_instruction == BIT_ZPG ||
						  last_instruction == LDA_ZPX ||
						  last_instruction == LDX_ZPY ||
						  last_instruction == LDY_ZPX ||
						  last_instruction == EOR_ZPX ||
						  last_instruction == AND_ZPX ||
						  last_instruction == ORA_ZPX ||
						  last_instruction == ADC_ZPX ||
						  last_instruction == SBC_ZPX ||
						  last_instruction == CMP_ZPX ||
						  last_instruction == LDA_ABX ||
						  last_instruction == LDA_ABY ||
						  last_instruction == LDX_ABY ||
						  last_instruction == LDY_ABX ||
						  last_instruction == EOR_ABX ||
						  last_instruction == EOR_ABY ||
						  last_instruction == AND_ABX ||
						  last_instruction == AND_ABY ||
						  last_instruction == ORA_ABX ||
						  last_instruction == ORA_ABY ||
						  last_instruction == ADC_ABX ||
						  last_instruction == ADC_ABY ||
						  last_instruction == SBC_ABX ||
						  last_instruction == SBC_ABY ||
						  last_instruction == CMP_ABX ||
						  last_instruction == CMP_ABY
						) : {
							if (alu_opcode != last_instruction) {
								--print addr[7:0],X + PCL;
								dut_error("alu_opcode is Wrong!");
							};
							if (alu_enable != 1) {
								dut_error("alu_enable is Wrong!");
							};
							if (addr != PC) {
								dut_error("Address is Wrong!");
							};
						};
						default : {
							if (alu_opcode.as_a(byte) != 0) {
								--print alu_enable;
								--print alu_opcode;
								--print last_instruction;
								dut_error("alu_opcode is Wrong!");
							};
							if (alu_enable != 0) {
								dut_error("alu_enable is Wrong!");
							};
							if (alu_a != 0) {
								dut_error("alu_a is Wrong!");
							};
							if (addr != PC) {
								dut_error("Address is Wrong!");
							};
						};
					};
				}
				else {
					rst = 0;
					if (alu_enable != 0) {
						dut_error("alu_enable is Wrong!");
					};
					if (alu_opcode.as_a(byte) != 0) {
						dut_error("alu_opcode is Wrong!");
					};
					if (alu_a != 0) {
						dut_error("alu_a is Wrong!");
					};
					if (addr != PC) {
						dut_error("Address is Wrong!");
					};
				};
				PC = PC + 1;
			};
			CYCLE_2 : {
				print_state();
				print addr;
				if (addr != PC) {
					dut_error("ADDR should be equal PC!");
				};
				if (mem_rw != 0) {
					dut_error("MEM_RW should be 0 (READ)");
				};
				case {
					(
					  instructions == ADC_ABS ||
					  instructions == ADC_IMM ||
					  instructions == AND_ABS ||
					  instructions == AND_IMM ||
					  instructions == ASL_ABS ||
					  instructions == BIT_ABS ||
					  instructions == BRK_IMP ||
					  instructions == CMP_ABS ||
					  instructions == CMP_IMM ||
					  instructions == CPX_IMM ||
					  instructions == CPY_IMM ||
					  instructions == DEC_ABS ||
					  instructions == EOR_ABS ||
					  instructions == EOR_IMM ||
					  instructions == INC_ABS ||
					  instructions == JMP_ABS ||
					  instructions == LDA_ABS ||
					  instructions == LDA_IMM ||
					  instructions == LDX_ABS ||
					  instructions == LDX_IMM ||
					  instructions == LDY_ABS ||
					  instructions == LDY_IMM ||
					  instructions == LSR_ABS ||
					  instructions == ORA_ABS ||
					  instructions == ORA_IMM ||
					  instructions == ROL_ABS ||
					  instructions == ROR_ABS ||
					  instructions == SBC_ABS ||
					  instructions == SBC_IMM ||
					  instructions == LDA_ZPG ||
					  instructions == LDX_ZPG ||
					  instructions == LDY_ZPG ||
					  instructions == EOR_ZPG ||
					  instructions == AND_ZPG ||
					  instructions == ORA_ZPG ||
					  instructions == ADC_ZPG ||
					  instructions == SBC_ZPG ||
					  instructions == CMP_ZPG ||
					  instructions == BIT_ZPG ||
					  instructions == ASL_ZPG ||
					  instructions == LSR_ZPG ||
					  instructions == ROL_ZPG ||
					  instructions == ROR_ZPG ||
					  instructions == INC_ZPG ||
					  instructions == DEC_ZPG ||
  					  instructions == LDA_ZPX ||
					  instructions == LDX_ZPY ||
					  instructions == LDY_ZPX ||
					  instructions == EOR_ZPX ||
					  instructions == AND_ZPX ||
					  instructions == ORA_ZPX ||
					  instructions == ADC_ZPX ||
					  instructions == SBC_ZPX ||
					  instructions == CMP_ZPX ||
					  instructions == ASL_ZPX ||
					  instructions == LSR_ZPX ||
					  instructions == ROL_ZPX ||
					  instructions == ROR_ZPX ||
					  instructions == INC_ZPX ||
					  instructions == DEC_ZPX ||
					  instructions == STX_ZPY ||
					  instructions == STY_ZPX ||
					  instructions == STA_ZPX ||
					  instructions == LDA_ABX ||
					  instructions == LDA_ABY ||
					  instructions == LDX_ABY ||
					  instructions == LDY_ABX ||
					  instructions == EOR_ABX ||
					  instructions == EOR_ABY ||
					  instructions == AND_ABX ||
					  instructions == AND_ABY ||
					  instructions == ORA_ABX ||
					  instructions == ORA_ABY ||
					  instructions == ADC_ABX ||
					  instructions == ADC_ABY ||
					  instructions == SBC_ABX ||
					  instructions == SBC_ABY ||
					  instructions == CMP_ABX ||
					  instructions == CMP_ABY
					) : {
						if (alu_opcode.as_a(byte) != 0) {
							dut_error("Opcode is Wrong!");
						};
						if (alu_enable != 0) {
							dut_error("BRK_IMP is Wrong!");
						};
						PC = PC + 1;
					};
					-- TODO: STX and STY should not
					-- TODO: they dont need access to alu at any cycle
					-- TODO: because X and Y are available at alu_x and alu_y
					(
					  instructions == STA_ABS ||
					  instructions == STA_ZPG ||
  					  instructions == STX_ABS ||
					  instructions == STY_ABS ||
					  instructions == STX_ZPG ||
					  instructions == STY_ZPG
					) : {
						if (alu_opcode != instructions) {
							dut_error("Opcode is Wrong!");
						};
						if (alu_enable != 1) {
							dut_error("ASL_ACC is Wrong!");
						};
						PC = PC + 1;
					};
					(
					  instructions == NOP_IMP ||
					  instructions == PHP_IMP ||
					  instructions == PLA_IMP ||
					  instructions == PLP_IMP ||
					  instructions == RTI_IMP ||
					  instructions == RTS_IMP

					) : {
						if (alu_opcode.as_a(byte) != 0) {
							dut_error("Opcode is Wrong!");
						};
						if (alu_enable != 0) {
							dut_error("ASL_ACC is Wrong!");
						};
					};
					(
					  instructions == ASL_ACC ||
					  instructions == CLC_IMP ||
					  instructions == CLD_IMP ||
					  instructions == CLI_IMP ||
					  instructions == CLV_IMP ||
					  instructions == DEX_IMP ||
					  instructions == DEY_IMP ||
					  instructions == INX_IMP ||
					  instructions == INY_IMP ||
					  instructions == LSR_ACC ||
					  instructions == PHA_IMP ||
					  instructions == ROL_ACC ||
					  instructions == SEC_IMP ||
					  instructions == SED_IMP ||
					  instructions == SEI_IMP ||
					  instructions == TAX_IMP ||
					  instructions == TAY_IMP ||
					  instructions == TXA_IMP ||
					  instructions == TYA_IMP
					) : {
						if (alu_opcode != instructions) {
							dut_error("Opcode is Wrong!");
						};
						if (alu_enable != 1) {
							dut_error("ASL_ACC is Wrong!");
						};
					};
					//JSR_ABS : {
					//	if (alu_opcode.as_a(byte) != 0) {
					//		dut_error("Opcode is Wrong!");
					//	};
					//	if (mem_rw != 0) {
					//		dut_error("MEM_RW should be 1 (WRITE)");
					//	};
					//	if (alu_enable != 0) {
					//		dut_error("JSR_IMP is Wrong!");
					//	};
					//	if (addr != PC) {
					//		dut_error("ADDR should be equal SP!");
					//	};
					//	PC = PC + 1;
					//};
					(
					  instructions == TSX_IMP
					) : {
						if (alu_opcode != instructions) {
							dut_error("Opcode is Wrong!");
						};
						if (alu_enable != 1) {
							dut_error("TSX_IMP is Wrong!");
						};
						if (alu_a != SP) {
							dut_error("TSX_IMP is Wrong!");
						};
					};
					(
					  instructions == TXS_IMP
					) : {
						if (alu_opcode != instructions) {
							dut_error("Opcode is Wrong!");
						};
						if (alu_enable != 1) {
							dut_error("TXS_IMP is Wrong!");
						};
						SP = SP_aux;
					};
				};
			};
			CYCLE_3 : {
				print_state();
				print addr;
				case {
					(
					  instructions == BRK_IMP
					) : {
						if (alu_opcode.as_a(byte) != 0) {
							dut_error("Opcode is Wrong!");
						};
						if (mem_rw != 1) {
							dut_error("MEM_RW should be 1 (WRITE)");
						};
						if (alu_enable != 0) {
							dut_error("BRK_IMP is Wrong!");
						};
						if (data_out[4:0] != PC[12:8] && data_out[7:5] != 0) {
							dut_error("BRK_IMP is Wrong!");
						};
						if (addr != SP + 256) {
							dut_error("ADDR should be equal SP!");
						};
						SP = SP - 1;
					};
					//JSR_ABS : {
					//	if (alu_opcode.as_a(byte) != 0) {
					//		dut_error("Opcode is Wrong!");
					//	};
					//	if (mem_rw != 0) {
					//		dut_error("MEM_RW should be 1 (WRITE)");
					//	};
					//	if (alu_enable != 0) {
					//		dut_error("JSR_IMP is Wrong!");
					//	};
					//	if (addr != PC) {
					//		dut_error("ADDR should be equal PC!");
					//	};
					//};
					-- TODO: This is probably an error STA should not use ALU on the third cycle
					(
  					  instructions == STA_ZPX ||
					  instructions == STX_ZPY ||
					  instructions == STY_ZPX
					) : {
						if (alu_opcode != instructions) {
							dut_error("Opcode is Wrong!");
						};
						if (alu_enable != 1) {
							dut_error("ASL_ACC is Wrong!");
						};
						if (mem_rw != 0) {
							dut_error("MEM_RW should be 1 (WRITE)");
						};
						if (addr != PCL) {
							dut_error("ADDR should be equal SP!");
						};
					};
					(
					  instructions == STA_ZPG ||
					  instructions == STX_ZPG ||
					  instructions == STY_ZPG
					) : {
						if (alu_opcode.as_a(byte) != 0) {
							dut_error("Opcode is Wrong!");
						};
						if (alu_enable != 0) {
							dut_error("ASL_ACC is Wrong!");
						};
						if (mem_rw != 1) {
							dut_error("MEM_RW should be 1 (WRITE)");
						};
						if (addr != PCL) {
							dut_error("ADDR should be equal SP!");
						};
					};
					(
					  instructions == JMP_ABS
					) : {
						if (alu_opcode.as_a(byte) != 0) {
							dut_error("Opcode is Wrong!");
						};
						if (alu_enable != 0) {
							dut_error("ASL_ACC is Wrong!");
						};
						if (mem_rw != 0) {
							dut_error("MEM_RW should be 1 (WRITE)");
						};
						PC[7:0] = PCL;
						PC[12:8] = PCH[4:0];
					};
					(
					  instructions == LDA_ZPX ||
					  instructions == LDX_ZPY ||
					  instructions == LDY_ZPX ||
					  instructions == EOR_ZPX ||
					  instructions == AND_ZPX ||
					  instructions == ORA_ZPX ||
					  instructions == ADC_ZPX ||
					  instructions == SBC_ZPX ||
					  instructions == CMP_ZPX ||
					  instructions == ASL_ZPX ||
					  instructions == LSR_ZPX ||
					  instructions == ROL_ZPX ||
					  instructions == ROR_ZPX ||
					  instructions == INC_ZPX ||
					  instructions == DEC_ZPX
					) : {
						if (alu_opcode.as_a(byte) != 0) {
							dut_error("Opcode is Wrong!");
						};
						if (alu_enable != 0) {
							dut_error("ASL_ACC is Wrong!");
						};
						if (mem_rw != 0) {
							dut_error("MEM_RW should be 0 (WRITE)");
						};
						if (addr != PCL) {
							dut_error("ADDR should be equal SP!");
						};
					};
					(
					  instructions == ADC_ABS ||
					  instructions == AND_ABS ||
					  instructions == ASL_ABS ||
					  instructions == BIT_ABS ||
					  instructions == CMP_ABS ||
					  instructions == DEC_ABS ||
					  instructions == EOR_ABS ||
					  instructions == INC_ABS ||
					  instructions == LDA_ABS ||
					  instructions == LDX_ABS ||
					  instructions == LDY_ABS ||
					  instructions == LSR_ABS ||
					  instructions == ORA_ABS ||
					  instructions == ROL_ABS ||
					  instructions == ROR_ABS ||
					  instructions == SBC_ABS ||
					  instructions == STA_ABS ||
					  instructions == STX_ABS ||
					  instructions == STY_ABS ||
					  instructions == LDA_ABX ||
					  instructions == LDY_ABX ||
					  instructions == EOR_ABX ||
					  instructions == AND_ABX ||
					  instructions == ORA_ABX ||
					  instructions == ADC_ABX ||
					  instructions == SBC_ABX ||
					  instructions == CMP_ABX
					) : {
						if (alu_opcode.as_a(byte) != 0) {
							dut_error("Opcode is Wrong!");
						};
						if (alu_enable != 0) {
							dut_error("ASL_ACC is Wrong!");
						};
						if (addr != PC) {
							dut_error("ADDR should be equal SP!");
						};
						if (mem_rw != 0) {
							dut_error("MEM_RW should be 1 (WRITE)");
						};
						PC = PC + 1;
						if (PCL + X > 255) {
							more_cycles = TRUE;
						};
					};
					(
					  instructions == LDA_ABY ||
					  instructions == LDX_ABY ||
					  instructions == AND_ABY ||
					  instructions == EOR_ABY ||
					  instructions == ORA_ABY ||
					  instructions == ADC_ABY ||
					  instructions == SBC_ABY ||
					  instructions == CMP_ABY
					) : {
						if (alu_opcode.as_a(byte) != 0) {
							dut_error("Opcode is Wrong!");
						};
						if (alu_enable != 0) {
							dut_error("ASL_ACC is Wrong!");
						};
						if (addr != PC) {
							dut_error("ADDR should be equal SP!");
						};
						if (mem_rw != 0) {
							dut_error("MEM_RW should be 1 (WRITE)");
						};
						PC = PC + 1;
						if (PCL + Y > 255) {
							more_cycles = TRUE;
						};
					};
					(
					  instructions == LDA_ZPG ||
					  instructions == LDX_ZPG ||
					  instructions == LDY_ZPG ||
					  instructions == EOR_ZPG ||
					  instructions == AND_ZPG ||
					  instructions == ORA_ZPG ||
					  instructions == ADC_ZPG ||
					  instructions == SBC_ZPG ||
					  instructions == CMP_ZPG ||
					  instructions == BIT_ZPG ||
					  instructions == ASL_ZPG ||
					  instructions == LSR_ZPG ||
					  instructions == ROL_ZPG ||
					  instructions == ROR_ZPG ||
					  instructions == INC_ZPG ||
					  instructions == DEC_ZPG
					) : {
						if (alu_opcode.as_a(byte) != 0) {
							dut_error("Opcode is Wrong!");
						};
						if (alu_enable != 0) {
							dut_error("ASL_ACC is Wrong!");
						};
						if (mem_rw != 0) {
							dut_error("MEM_RW should be 1 (WRITE)");
						};
						if (addr != PCL) {
							dut_error("ADDR should be equal SP!");
						};
					};
					(
					  instructions == PHA_IMP ||
					  instructions == PHP_IMP
					) : {
						if (alu_opcode.as_a(byte) != 0) {
							dut_error("Opcode is Wrong!");
						};
						if (mem_rw != 1) {
							dut_error("MEM_RW should be 1 (WRITE)");
						};
						if (alu_a != 0) {
							dut_error("PHP_IMP is Wrong!");
						};
						if (addr != SP + 256) {
							dut_error("ADDR should be equal SP!");
						};
						SP = SP - 1;
						if (alu_enable != 0) {
							dut_error("PHP_IMP is Wrong!");
						};
					};
					(
					  instructions == PLA_IMP ||
					  instructions == PLP_IMP ||
					  instructions == RTI_IMP ||
					  instructions == RTS_IMP
					) : {
						if (alu_opcode.as_a(byte) != 0) {
							dut_error("Opcode is Wrong!");
						};
						if (alu_enable != 0) {
							dut_error("PLA_IMP is Wrong!");
						};
						if (mem_rw != 0) {
							dut_error("MEM_RW should be 0 (READ)");
						};
						if (addr != SP + 256) {
							dut_error("ADDR should be equal SP!");
						};
						SP = SP + 1;
					};
				};
			};
			CYCLE_4 : {
				print_state();
				print addr;
				case {
					(
					  instructions == BRK_IMP
					) : {
						if (alu_opcode.as_a(byte) != 0) {
							dut_error("Opcode is Wrong!");
						};
						if (mem_rw != 1) {
							dut_error("MEM_RW should be 1 (WRITE)");
						};
						if (alu_enable != 0) {
							dut_error("BRK_IMP is Wrong!");
						};
						if (data_out != PC[7:0]) {
							dut_error("BRK_IMP is Wrong!");
						};
						if (addr != SP + 256) {
							dut_error("ADDR should be equal SP!");
						};
						SP = SP - 1;
					};
					//JSR_ABS : {
					//	if (alu_opcode.as_a(byte) != 0) {
					//		dut_error("Opcode is Wrong!");
					//	};
					//	if (mem_rw != 1) {
					//		dut_error("MEM_RW should be 1 (WRITE)");
					//	};
					//	if (alu_enable != 0) {
					//		dut_error("JSR_ABS is Wrong!");
					//	};
					//	if (data_out != PC[7:0]) {
					//		dut_error("JSR_ABS is Wrong!");
					//	};
					//	if (addr != SP + 256) {
					//		dut_error("ADDR should be equal SP!");
					//	};
					//	SP = SP - 1;
					//};
					(
					  instructions == LDA_ZPX ||
					  instructions == LDY_ZPX ||
					  instructions == EOR_ZPX ||
					  instructions == AND_ZPX ||
					  instructions == ORA_ZPX ||
					  instructions == ADC_ZPX ||
					  instructions == SBC_ZPX ||
					  instructions == CMP_ZPX ||
					  instructions == ASL_ZPX ||
					  instructions == LSR_ZPX ||
					  instructions == ROL_ZPX ||
					  instructions == ROR_ZPX ||
					  instructions == INC_ZPX ||
					  instructions == DEC_ZPX
					) : {
						if (alu_opcode.as_a(byte) != 0) {
							dut_error("Opcode is Wrong!");
						};
						if (alu_enable != 0) {
							dut_error("ASL_ACC is Wrong!");
						};
						if (mem_rw != 0) {
							dut_error("MEM_RW should be 0 (WRITE)");
						};
						--TODO: Isn`t it suppose to have ADDRH == 0????
						if (addr != PCL + X) {
							print addr[7:0], PCL+X, PCL, X, 't6507lp_fsm.index';
							dut_error("ADDR should be equal SP!");
						};
					};
					(
  					  instructions == LDA_ABX ||
					  instructions == LDY_ABX ||
					  instructions == EOR_ABX ||
					  instructions == AND_ABX ||
					  instructions == ORA_ABX ||
					  instructions == ADC_ABX ||
					  instructions == SBC_ABX ||
					  instructions == CMP_ABX
					) : {
						if (alu_opcode.as_a(byte) != 0) {
							dut_error("Opcode is Wrong!");
						};
						if (alu_enable != 0) {
							dut_error("ASL_ACC is Wrong!");
						};
						if (mem_rw != 0) {
							dut_error("MEM_RW should be 0 (WRITE)");
						};
						if (PCL + X > 255) {
							more_cycles = TRUE;
							if (addr[7:0] != PCL + X - 256) {
								--print addr[7:0], PCL + X - 256;
								dut_error("ADDR should be equal SP!");
							};
						}
						else {
							if (addr[7:0] != PCL + X) {
								dut_error("ADDR should be equal SP!");
							};
						};
					};
					(
					  instructions == LDX_ZPY ||
					  instructions == LDA_ABY ||
					  instructions == LDX_ABY ||
					  instructions == EOR_ABY ||
					  instructions == AND_ABY ||
					  instructions == ORA_ABY ||
					  instructions == ADC_ABY ||
					  instructions == SBC_ABY ||
					  instructions == CMP_ABY
					) : {
						if (alu_opcode.as_a(byte) != 0) {
							dut_error("Opcode is Wrong!");
						};
						if (alu_enable != 0) {
							dut_error("ASL_ACC is Wrong!");
						};
						if (mem_rw != 0) {
							dut_error("MEM_RW should be 0 (WRITE)");
						};
						if (PCL + Y > 255) {
							more_cycles = TRUE;
							if (addr[7:0] != PCL + Y - 256) {
								print addr[7:0], PCL + Y - 256;
								print PCL, Y;
								print 't6507lp_fsm.index';
								dut_error("ADDR should be equal SP!");
							};
						}
						else {
							if (addr[7:0] != PCL + Y) {
								dut_error("ADDR should be equal SP!");
							};
						};
					};
					(
					  instructions == ADC_ABS ||
					  instructions == AND_ABS ||
					  instructions == ASL_ABS ||
					  instructions == BIT_ABS ||
					  instructions == CMP_ABS ||
					  instructions == DEC_ABS ||
					  instructions == EOR_ABS ||
					  instructions == INC_ABS ||
					  instructions == LDA_ABS ||
					  instructions == LDX_ABS ||
					  instructions == LDY_ABS ||
					  instructions == LSR_ABS ||
					  instructions == ORA_ABS ||
					  instructions == ROL_ABS ||
					  instructions == ROR_ABS ||
					  instructions == SBC_ABS
					  ) : {
						if (alu_opcode.as_a(byte) != 0) {
							dut_error("Opcode is Wrong!");
						};
						if (alu_enable != 0) {
							dut_error("ASL_ACC is Wrong!");
						};
						if (addr[7:0] != PCL) {
							dut_error("ADDR should be equal SP!");
						};
						if (addr[12:8] != PCH[4:0]) {
							dut_error("ADDR should be equal SP!");
						};
						if (mem_rw != 0) {
							dut_error("MEM_RW should be 1 (WRITE)");
						};
					};
					(
					  instructions == STA_ABS ||
					  instructions == STX_ABS ||
					  instructions == STY_ABS
					) : {
						if (alu_opcode.as_a(byte) != 0) {
							dut_error("Opcode is Wrong!");
						};
						if (alu_enable != 0) {
							dut_error("ASL_ACC is Wrong!");
						};
						if (addr[7:0] != PCL) {
							dut_error("ADDR should be equal SP!");
						};
						if (addr[12:8] != PCH[4:0]) {
							dut_error("ADDR should be equal SP!");
						};
						if (mem_rw != 1) {
							dut_error("MEM_RW should be 1 (WRITE)");
						};
					};
					(
					  instructions == ASL_ZPG ||
					  instructions == LSR_ZPG ||
					  instructions == ROL_ZPG ||
					  instructions == ROR_ZPG ||
					  instructions == INC_ZPG ||
					  instructions == DEC_ZPG
					) : {
						if (alu_opcode != instructions) {
							dut_error("Opcode is Wrong!");
						};
						if (mem_rw != 1) {
							dut_error("MEM_RW should be 1 (WRITE)");
						};
						if (alu_enable != 1) {
							dut_error("BRK_IMP is Wrong!");
						};
						if (addr[7:0] != PCL) {
							dut_error("ADDR should be equal SP!");
						};
					};
					(
					  instructions == STA_ZPX ||
					  instructions == STY_ZPX
					) : {
						if (alu_opcode.as_a(byte) != 0) {
							dut_error("Opcode is Wrong!");
						};
						if (alu_enable != 0) {
							dut_error("ASL_ACC is Wrong!");
						};
						if (mem_rw != 1) {
							dut_error("MEM_RW should be 1 (WRITE)");
						};
						if (addr != PCL + X) {
							dut_error("ADDR should be equal SP!");
						};
					};
					(
					  instructions == STX_ZPY
					) : {
						if (alu_opcode.as_a(byte) != 0) {
							dut_error("Opcode is Wrong!");
						};
						if (alu_enable != 0) {
							dut_error("ASL_ACC is Wrong!");
						};
						if (mem_rw != 1) {
							dut_error("MEM_RW should be 1 (WRITE)");
						};
						if (addr != PCL + Y) {
							dut_error("ADDR should be equal SP!");
						};
					};
					(
					  instructions == PLA_IMP ||
					  instructions == PLP_IMP
					) : {
						if (alu_opcode.as_a(byte) != 0) {
							dut_error("Opcode is Wrong!");
						};
						if (mem_rw != 0) {
							dut_error("MEM_RW should be 0 (READ)");
						};
						if (alu_enable != 0) {
							dut_error("PLP_IMP is Wrong!");
						};
						if (addr != SP + 256) {
							dut_error("ADDR should be equal SP!");
						};
					};
					(
					  instructions == RTI_IMP
					) : {
						if (alu_opcode.as_a(byte) != 0) {
							dut_error("Opcode is Wrong!");
						};
						if (mem_rw != 0) {
							dut_error("MEM_RW should be 1 (WRITE)");
						};
						if (alu_enable != 0) {
							dut_error("RTI_IMP is Wrong!");
						};
						if (addr != SP + 256) {
							--print addr, SP;
							dut_error("ADDR should be equal SP!");
						};
						SP = SP + 1;
					};
					(
					  instructions == RTS_IMP
					) : {
						if (alu_opcode.as_a(byte) != 0) {
							dut_error("Opcode is Wrong!");
						};
						if (alu_enable != 0) {
							dut_error("RTS_IMP is Wrong!");
						};
						if (addr != SP + 256) {
							dut_error("ADDR should be equal SP!");
						};
						SP = SP + 1;
						PC[7:0] = PCL;
					};
				};
			};
			CYCLE_5 : {
				print_state();
				print addr;
				case {
					(
					  instructions == BRK_IMP
					) : {
						if (alu_opcode.as_a(byte) != 0) {
							dut_error("Opcode is Wrong!");
						};
						if (mem_rw != 1) {
							dut_error("MEM_RW should be 1 (WRITE)");
						};
						if (alu_enable != 0) {
							dut_error("BRK_IMP is Wrong!");
						};
						if (addr != SP + 256) {
							dut_error("ADDR should be equal SP!");
						};
						SP = SP - 1;
					};
					//JSR_ABS : {
					//	if (alu_opcode.as_a(byte) != 0) {
					//		dut_error("Opcode is Wrong!");
					//	};
					//	if (mem_rw != 1) {
					//		dut_error("MEM_RW should be 1 (WRITE)");
					//	};
					//	if (alu_enable != 0) {
					//		dut_error("JSR_ABS is Wrong!");
					//	};
					//	if (data_out != PC[12:8]) {
					//		dut_error("JSR_ABS is Wrong!");
					//	};
					//	if (addr != SP + 256) {
					//		dut_error("ADDR should be equal SP!");
					//	};
					//	SP = SP - 1;
					//};
					(
					  instructions == RTI_IMP
					) : {
						if (alu_opcode != instructions) {
							dut_error("Opcode is Wrong!");
						};
						if (mem_rw != 0) {
							dut_error("MEM_RW should be 1 (WRITE)");
						};
						if (alu_enable != 1) {
							dut_error("RTI_IMP is Wrong!");
						};
						if (addr != SP + 256) {
							dut_error("ADDR should be equal SP!");
						};
						SP = SP + 1;
						PC[7:0] = PCL;
					};
					(
					  instructions == RTS_IMP
					) : {
						if (alu_opcode.as_a(byte) != 0) {
							dut_error("Opcode is Wrong!");
						};
						if (alu_enable != 0) {
							dut_error("SEI_IMP is Wrong!");
						};
						if (addr != SP + 256) {
							dut_error("ADDR should be equal SP!");
						};
						PC[12:8] = PCH[4:0];
					};
					(
					  instructions == ASL_ZPG ||
					  instructions == LSR_ZPG ||
					  instructions == ROL_ZPG ||
					  instructions == ROR_ZPG ||
					  instructions == INC_ZPG ||
					  instructions == DEC_ZPG
					) : {
						if (alu_opcode.as_a(byte) != 0) {
							dut_error("Opcode is Wrong!");
						};
						if (mem_rw != 1) {
							dut_error("MEM_RW should be 1 (WRITE)");
						};
						if (alu_enable != 0) {
							dut_error("BRK_IMP is Wrong!");
						};
						if (addr[7:0] != PCL) {
							dut_error("ADDR should be equal SP!");
						};
					};
					(
  					  instructions == LDA_ABX ||
					  instructions == LDY_ABX ||
					  instructions == EOR_ABX ||
					  instructions == AND_ABX ||
					  instructions == ORA_ABX ||
					  instructions == ADC_ABX ||
					  instructions == SBC_ABX ||
					  instructions == CMP_ABX
					) : {
						if (alu_opcode.as_a(byte) != 0) {
							dut_error("Opcode is Wrong!");
						};
						if (alu_enable != 0) {
							dut_error("ASL_ACC is Wrong!");
						};
						if (mem_rw != 0) {
							dut_error("MEM_RW should be 0 (WRITE)");
						};
						if (addr[7:0] != PCL + X - 256) {
							dut_error("ADDR is wrong!");
						};
						if (addr[12:8] != PCH[4:0] + 1) {
							dut_error("ADDR is wrong!");
						};
					};
					(
					  instructions == LDX_ZPY ||
					  instructions == LDA_ABY ||
					  instructions == LDX_ABY ||
					  instructions == EOR_ABY ||
					  instructions == AND_ABY ||
					  instructions == ORA_ABY ||
					  instructions == ADC_ABY ||
					  instructions == SBC_ABY ||
					  instructions == CMP_ABY
					) : {
						if (alu_opcode.as_a(byte) != 0) {
							dut_error("Opcode is Wrong!");
						};
						if (alu_enable != 0) {
							dut_error("ASL_ACC is Wrong!");
						};
						if (mem_rw != 0) {
							dut_error("MEM_RW should be 0 (WRITE)");
						};
						if (addr[7:0] != PCL + Y - 256) {
							dut_error("ADDR is wrong!");
						};
						if (addr[12:8] != PCH[4:0] + 1) {
							dut_error("ADDR is wrong!");
						};
					};
					(
					  instructions == ASL_ZPX ||
					  instructions == LSR_ZPX ||
					  instructions == ROL_ZPX ||
					  instructions == ROR_ZPX ||
					  instructions == INC_ZPX ||
					  instructions == DEC_ZPX
					) : {
						if (alu_opcode != instructions) {
							dut_error("Opcode is Wrong!");
						};
						if (alu_enable != 1) {
							dut_error("ASL_ACC is Wrong!");
						};
						if (mem_rw != 1) {
							dut_error("MEM_RW should be 0 (WRITE)");
						};
						if (addr != PCL + X) {
							dut_error("ADDR should be equal SP!");
						};
					};
					(
					  instructions == ASL_ABS ||
					  instructions == DEC_ABS ||
					  instructions == INC_ABS ||
					  instructions == LSR_ABS ||
					  instructions == ROL_ABS ||
					  instructions == ROR_ABS
					) : {
						if (alu_opcode != instructions) {
							dut_error("Opcode is Wrong!");
						};
						if (mem_rw != 1) {
							dut_error("MEM_RW should be 1 (WRITE)");
						};
						if (alu_enable != 1) {
							dut_error("BRK_IMP is Wrong!");
						};
						if (addr[7:0] != PCL) {
							dut_error("ADDR should be equal SP!");
						};
						if (addr[12:8] != PCH[4:0]) {
							dut_error("ADDR should be equal SP!");
						};
					};
				};
			};
			CYCLE_6 : {
				print_state();
				print addr;
				case {
					(
					  instructions == BRK_IMP
					) : {
						if (alu_opcode.as_a(byte) != 0) {
							dut_error("Opcode is Wrong!");
						};
						if (mem_rw != 0) {
							dut_error("MEM_RW should be 1 (WRITE)");
						};
						if (alu_enable != 0) {
							dut_error("BRK_IMP is Wrong!");
						};
						if (addr != 13'b1111111111110) {
							dut_error("BRK_IMP is Wrong!");
						};
						PC[7:0] = PCL;
					};
					//JSR_ABS : {
					//	if (alu_opcode.as_a(byte) != 0) {
					//		dut_error("Opcode is Wrong!");
					//	};
					//	if (mem_rw != 0) {
					//		dut_error("MEM_RW should be 1 (WRITE)");
					//	};
					//	if (alu_enable != 0) {
					//		dut_error("JSR_ABS is Wrong!");
					//	};
					//	if (addr != PC) {
					//		dut_error("ADDR should be equal SP!");
					//	};
					//	PC [7:0] = PCL;
					//	PC[12:8] = PCH[4:0];
					//};
					(
					  instructions == RTI_IMP
					) : {
						if (alu_opcode.as_a(byte) != 0) {
							dut_error("Opcode is Wrong!");
						};
						if (mem_rw != 0) {
							dut_error("MEM_RW should be 1 (WRITE)");
						};
						if (alu_enable != 0) {
							dut_error("RTI_IMP is Wrong!");
						};
						if (addr != SP + 256) {
							dut_error("ADDR should be equal SP!");
						};
						PC[12:8] = PCH[4:0];
					};
					(
					  instructions == RTS_IMP
					) : {
						if (alu_opcode.as_a(byte) != 0) {
							dut_error("Opcode is Wrong!");
						};
						if (mem_rw != 0) {
							dut_error("MEM_RW should be 1 (WRITE)");
						};
						if (alu_enable != 0) {
							dut_error("RTI_IMP is Wrong!");
						};
						if (addr != PC) {
							dut_error("ADDR should be equal SP!");
						};
						PC = PC + 1;
					};
					(
					  instructions == ASL_ZPX ||
					  instructions == LSR_ZPX ||
					  instructions == ROL_ZPX ||
					  instructions == ROR_ZPX ||
					  instructions == INC_ZPX ||
					  instructions == DEC_ZPX
					) : {
						if (alu_opcode.as_a(byte) != 0) {
							dut_error("Opcode is Wrong!");
						};
						if (alu_enable != 0) {
							dut_error("ASL_ACC is Wrong!");
						};
						if (mem_rw != 1) {
							dut_error("MEM_RW should be 0 (WRITE)");
						};
						if (addr != PCL + X) {
							dut_error("ADDR should be equal SP!");
						};
					};
					(
					  instructions == ASL_ABS ||
					  instructions == DEC_ABS ||
					  instructions == INC_ABS ||
					  instructions == LSR_ABS ||
					  instructions == ROL_ABS ||
					  instructions == ROR_ABS
					) : {
						if (alu_opcode.as_a(byte) != 0) {
							dut_error("Opcode is Wrong!");
						};
						if (mem_rw != 1) {
							dut_error("MEM_RW should be 1 (WRITE)");
						};
						if (alu_enable != 0) {
							dut_error("BRK_IMP is Wrong!");
						};
						if (addr[7:0] != PCL) {
							dut_error("ADDR should be equal SP!");
						};
						if (addr[12:8] != PCH[4:0]) {
							dut_error("ADDR should be equal SP!");
						};
					};
				};
			};
			CYCLE_7 : {
				print_state();
				print addr;
				case {
					(
					  instructions == BRK_IMP
					) : {
						if (alu_opcode.as_a(byte) != 0) {
							dut_error("Opcode is Wrong!");
						};
						if (mem_rw != 0) {
							dut_error("MEM_RW should be 1 (WRITE)");
						};
						if (alu_enable != 0) {
							dut_error("BRK_IMP is Wrong!");
						};
						if (addr != 13'b1111111111111) {
							dut_error("BRK_IMP is Wrong!");
						};
						PC[12:8] = PCH[4:0];
					};
				};
			};
		};
	old_state = new_state;
	};
};
'>
