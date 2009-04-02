alu_chk.e
<'
import alu_components;

unit alu_chk_u {
	reg_a : byte;
	reg_x : byte;
	reg_y : byte;
	reg_status : byte;
	reg_result : byte;

	inst : alu_input_s;
	next_inst : alu_input_s;

	count_cycles : int;
	first_cycle : bool;

	keep first_cycle == TRUE;
	keep count_cycles == 0;

	store(input : alu_input_s) is {
		count_cycles = count_cycles + 1;

		//out ("CYCLE ", count_cycles, " STORE:");
		//print input;

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

			BCC_REL: {};
			BCS_REL: {};
			BEQ_REL: {};

			default: {
				//dut_error("unknown opcode");
			}
		};
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
