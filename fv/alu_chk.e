alu_chk.e
<'
import alu_components;

unit alu_chk_u {
	reg_a : byte;
	reg_x : byte;
	reg_y : byte;
	reg_status : byte;
	reg_result : byte;

	!inst : alu_input_s;
	!next_inst : alu_input_s;

	count_cycles : int;
	first_cycle : bool;
	last_a : byte;
	last_status : byte;
	last_result : byte;

	keep first_cycle == TRUE;
	keep count_cycles == 0;

	store(input : alu_input_s) is {
		count_cycles = count_cycles + 1;

		//out ("CYCLE ", count_cycles, " STORE:");
		//print input;

		last_a = reg_a;
		last_status = reg_status;
		last_result = reg_result;

		if (first_cycle) {
			inst = input;
			next_inst = input;
		}
		else {
			inst = next_inst;
			next_inst = input;
		};

	};

	compare(alu_result:byte, alu_status:byte, alu_x:byte, alu_y:byte ) is {
		if (first_cycle) {
			first_cycle = FALSE;
			reg_x = 0;
			reg_y = 0;
			reg_status = 8'b00100010;
			reg_a = 0; // TODO: check this
			reg_result = 0;
		}
		else {
			//out ("CYCLE ", count_cycles, " COMPARE:");
			//print inst;

			if (count_cycles == 99999) {
				out("ENOUGH!");
				stop_run();
			};

			case inst.input_kind {
				ENABLED_VALID: {
					//out("CYCLE ", count_cycles, ": executing and comparing");
					execute();
				};
				DISABLED_VALID: { 
					//out("CYCLE ", count_cycles, ": just comparing");
				};
				RESET: {
					reg_x = 0;
					reg_y = 0;
					reg_status = 8'b00100010;
					reg_a = 0; // TODO: check this
					reg_result = 0;
					
					return;
				};
				default: {
					dut_error("error at e code");
				};
			};
			
			// here i have already calculated. must compare!
			
			if ((reg_result != alu_result) || (reg_x != alu_x) or (reg_y != alu_y) or (reg_status != alu_status)) {
				out("#########################################################");
				print me;
				print me.inst;
				out("#########################################################");
				print alu_result;
				print alu_status;
				print alu_x;
				print alu_y;
				
				dut_error("WRONG!");
			};
		};
	};

	execute() is {
		case inst.alu_opcode {
			ADC_IMM: { exec_sum(); }; // A,Z,C,N = A+M+C
			ADC_ZPG: { exec_sum(); };
			ADC_ZPX: { exec_sum(); };
			ADC_ABS: { exec_sum(); };
			ADC_ABX: { exec_sum(); };
			ADC_ABY: { exec_sum(); };
			ADC_IDX: { exec_sum(); };
			ADC_IDY: { exec_sum(); };

			AND_IMM: { exec_and(); }; // A,Z,N = A&M
			AND_ZPG: { exec_and(); };
			AND_ZPX: { exec_and(); };
			AND_ABS: { exec_and(); };
			AND_ABX: { exec_and(); };
			AND_ABY: { exec_and(); };
			AND_IDX: { exec_and(); };
			AND_IDY: { exec_and(); };

			ASL_ACC: { exec_asl_acc(); }; // A,Z,C,N = M*2

			ASL_ZPG: { exec_asl_mem(); }; // M,Z,C,N = M*2
			ASL_ZPX: { exec_asl_mem(); };
			ASL_ABS: { exec_asl_mem(); };
			ASL_ABX: { exec_asl_mem(); };

			BCC_REL: {}; // nothing is done. these are all branches.
			BCS_REL: {};
			BEQ_REL: {};
			BMI_REL: {};
			BNE_REL: {};
			BPL_REL: {};
			BVC_REL: {};
			BVS_REL: {};

			BIT_ZPG: { exec_bit(); }; // Z = A & M, N = M7, V = M6
			BIT_ABS: { exec_bit(); };

			BRK_IMP: { reg_status[4:4] = 1; };

			CLC_IMP: { reg_status[0:0] = 0; };
			CLD_IMP: { reg_status[3:3] = 0; };
			CLI_IMP: { reg_status[2:2] = 0; };
			CLV_IMP: { reg_status[6:6] = 0; };

			CMP_IMM: { exec_cmp(reg_a); }; // Z,C,N = A-M
			CMP_ZPG: { exec_cmp(reg_a); };
			CMP_ZPX: { exec_cmp(reg_a); };
			CMP_ABS: { exec_cmp(reg_a); };
			CMP_ABX: { exec_cmp(reg_a); };
			CMP_ABY: { exec_cmp(reg_a); };
			CMP_IDX: { exec_cmp(reg_a); };
			CMP_IDY: { exec_cmp(reg_a); };

			CPX_IMM: { exec_cmp(reg_x); }; // Z,C,N = X-M
			CPX_ZPG: { exec_cmp(reg_x); };
			CPX_ABS: { exec_cmp(reg_x); };

			CPY_IMM: { exec_cmp(reg_y); }; //Z,C,N = Y-M
			CPY_ZPG: { exec_cmp(reg_y); };
			CPY_ABS: { exec_cmp(reg_y); };

			DEC_ZPG: { exec_dec(inst.alu_a, TRUE); }; // M,Z,N = M-1
			DEC_ZPX: { exec_dec(inst.alu_a, TRUE); };
			DEC_ABS: { exec_dec(inst.alu_a, TRUE); };
			DEC_ABX: { exec_dec(inst.alu_a, TRUE); };

			DEX_IMP: { exec_dec(reg_x, FALSE); };  // X,Z,N = X-1
			DEY_IMP: { exec_dec(reg_y, FALSE); };  // Y,Z,N = Y-1

			EOR_IMM: { exec_eor(); }; // A,Z,N = A^M
			EOR_ZPG: { exec_eor(); };
			EOR_ZPX: { exec_eor(); };
			EOR_ABS: { exec_eor(); };
			EOR_ABX: { exec_eor(); };
			EOR_ABY: { exec_eor(); };
			EOR_IDX: { exec_eor(); };
			EOR_IDY: { exec_eor(); };

			INC_ZPG: { exec_inc(inst.alu_a, TRUE); };
			INC_ZPX: { exec_inc(inst.alu_a, TRUE); };
			INC_ABS: { exec_inc(inst.alu_a, TRUE); };
			INC_ABX: { exec_inc(inst.alu_a, TRUE); };

			INX_IMP: { exec_inc(reg_x, FALSE); };
			INY_IMP: { exec_inc(reg_y, FALSE); };

			JMP_ABS: {};
			JMP_IND: {};
			JSR_ABS: {};

			LDA_IMM: { exec_load(reg_a, TRUE); }; // A,Z,N = M
			LDA_ZPG: { exec_load(reg_a, TRUE); };
			LDA_ZPX: { exec_load(reg_a, TRUE); };
			LDA_ABS: { exec_load(reg_a, TRUE); };
			LDA_ABX: { exec_load(reg_a, TRUE); };
			LDA_ABY: { exec_load(reg_a, TRUE); };
			LDA_IDX: { exec_load(reg_a, TRUE); };
			LDA_IDY: { exec_load(reg_a, TRUE); };

			LDX_IMM: { exec_load(reg_x, FALSE); };
			LDX_ZPG: { exec_load(reg_x, FALSE); };
			LDX_ZPY: { exec_load(reg_x, FALSE); };
			LDX_ABS: { exec_load(reg_x, FALSE); };
			LDX_ABY: { exec_load(reg_x, FALSE); };

			LDY_IMM: { exec_load(reg_y, FALSE); };
			LDY_ZPG: { exec_load(reg_y, FALSE); };
			LDY_ZPX: { exec_load(reg_y, FALSE); };
			LDY_ABS: { exec_load(reg_y, FALSE); };
			LDY_ABX: { exec_load(reg_y, FALSE); };

			LSR_ACC: { exec_lsr(reg_a); }; // A,C,Z,N = A/2 or M,C,Z,N = M/2
			LSR_ZPG: { exec_lsr(inst.alu_a); };
			LSR_ZPX: { exec_lsr(inst.alu_a); };
			LSR_ABS: { exec_lsr(inst.alu_a); };
			LSR_ABX: { exec_lsr(inst.alu_a); };

			NOP_IMP: {};

			ORA_IMM: { exec_or(); }; // A,Z,N = A|M
			ORA_ZPG: { exec_or(); };
			ORA_ZPX: { exec_or(); };
			ORA_ABS: { exec_or(); };
			ORA_ABX: { exec_or(); };
			ORA_ABY: { exec_or(); };
			ORA_IDX: { exec_or(); };
			ORA_IDY: { exec_or(); };

			PHA_IMP: { reg_result = reg_a; };
			PHP_IMP: {}; // P is always connected and the result is not updated
			PLA_IMP: { 
				reg_a = inst.alu_a;
				reg_result = inst.alu_a;
				update_z(reg_a);
				update_n(reg_a);
			};
			PLP_IMP: { 
				reg_status = inst.alu_a; 
				reg_status[5:5] = 1; // this is always one
			};

			default: {
				out(inst.alu_opcode);
				dut_error("unknown opcode");
			}
		};
	};

	exec_or() is {
		reg_a = reg_a | inst.alu_a;
		reg_result = reg_a;
		update_z(reg_a);
		update_n(reg_a);
	};

	exec_lsr(arg1 : *byte) is {
		reg_status[0:0] = arg1[0:0];
		arg1 = arg1 >> 1;
		update_z(arg1);
		update_n(arg1);
		reg_result = arg1;
	};

	exec_load(arg1 : *byte, update_result : bool) is {
		arg1 = inst.alu_a;
	
		if (update_result) { // 
			reg_result = inst.alu_a; // no need for this but...
		};
		update_z(arg1);
		update_n(arg1);
	};

	exec_inc(arg1 : *byte, update_result : bool) is {
		arg1 = arg1 + 1;
		update_z(arg1);
		update_n(arg1);

		if (update_result) { // 
			reg_result = arg1;
		};
	};

	exec_eor() is {
		reg_a = reg_a ^ inst.alu_a;
		reg_result = reg_a;
		update_z(reg_a);
		update_n(reg_a);
	};

	exec_dec(arg1 : *byte, update_result : bool) is {
		arg1 = arg1 - 1;
		update_z(arg1);
		update_n(arg1);

		if (update_result) { // DEX and DEY do not output the result
			reg_result = arg1;
		};
	};

	exec_cmp(arg1 : byte) is {
		update_z(arg1 - inst.alu_a);
		update_n(arg1 - inst.alu_a);
		
		if (arg1 >= inst.alu_a) {
			reg_status[0:0] = 1;
		}
		else {
			reg_status[0:0] = 0;
		};
	};

	exec_bit() is {
		update_z(reg_a & inst.alu_a);
		reg_status[7:7] = inst.alu_a[7:7];
		reg_status[6:6] = inst.alu_a[6:6];
	};

	exec_asl_acc() is {
		reg_status[0:0] = reg_a[7:7];
		reg_a = reg_a * 2;
		update_z(reg_a);
		update_n(reg_a);
		reg_result = reg_a;
	};

	exec_asl_mem() is {
		reg_status[0:0] = inst.alu_a[7:7];
		reg_result = inst.alu_a * 2;
		update_z(reg_result);
		update_n(reg_result);
	};

	exec_and() is {
		reg_a = reg_a & inst.alu_a; // TODO: this is probably wrong
		update_z(reg_a);
		update_n(reg_a);
		reg_result = reg_a;
	};

	exec_sum() is {
		//out("adding: ", reg_a, " + ", inst.alu_a, " + ", reg_status[0:0]);
		reg_result = reg_a + inst.alu_a + reg_status[0:0];
		update_c(reg_a, inst.alu_a, reg_status[0:0]);
		update_v(reg_a, inst.alu_a, reg_result);
		update_z(reg_result);
		update_n(reg_result);
		reg_a = reg_result;
		//print me;
		//dut_error();
	};

	update_c(arg1 : byte, arg2 : byte, arg3: bit) is {
		if (arg1 + arg2 + arg3 > 255) {
			reg_status[0:0] = 1;
		}
		else {
			reg_status[0:0] = 0;
		}
	};

	update_v(op1 : byte, op2 : byte, res : byte) is {
		if ((op1[7:7] == op2[7:7]) && (op1[7:7] != res[7:7])) {
			reg_status[6:6] = 1;
		}
		else {
			reg_status[6:6] = 0;
		};
	};

	update_z(arg : byte) is {
		if (arg == 0) {
			reg_status[1:1] = 1;
		}
		else {
			reg_status[1:1] = 0;
		}
	};


	update_n(arg : byte) is {
		if (arg[7:7] == 1) {
			reg_status[7:7] = 1;
		}
		else {
			reg_status[7:7] = 0;
		}
	};
};
'>
