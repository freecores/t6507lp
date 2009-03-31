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

		out ("CYCLE ", count_cycles, " STORE:");
		print input;

		if (first_cycle) {
			inst = input;
			next_inst = input;
		}
		else {
			inst = next_inst;
			next_inst = input;
		};


		if (count_cycles == 10000) {
			dut_error();
		}
	};

	compare(alu_result:byte, alu_status:byte, alu_x:byte, alu_y:byte ) is {
		if (first_cycle) {
			first_cycle = FALSE;
			reg_x = alu_x;
			reg_y = alu_y;
			reg_status = alu_status;
			reg_a = 0; // TODO: check this
			reg_result = 0;
		}
		else {
			out ("CYCLE ", count_cycles, " COMPARE:");
			print inst;

			case inst.input_kind {
				ENABLED_VALID: {
					out("CYCLE ", count_cycles, ": executing and comparing");
					execute();
				};
				DISABLED_VALID: { 
					out("CYCLE ", count_cycles, ": just comparing");
				};
				default: {
					dut_error("error at e code");
				};
			};
			
			// here i have already calculated. must compare!
			if (reg_result != alu_result) {
				print inst;
				print me;
				print alu_result;
				print alu_status;
				print alu_x;
				print alu_y;
				
				dut_error("WRONG!");
			};

			if (reg_x != alu_x) {
				dut_error("WRONG!");
			};

			if (reg_y != alu_y) {
				dut_error("WRONG!");
			};

			if (reg_status != alu_status) {
				dut_error("WRONG!");
			};
		}
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
		update_c(reg_a, inst.alu_a);
		reg_a = reg_a + inst.alu_a;
		update_z(reg_a);
		update_n(reg_a);
		reg_result = reg_a;
		//print me;
		//dut_error();
	};

	update_z(arg : byte) is {
		if (arg == 0) {
			reg_status[1:1] = 1;
		}
		else {
			reg_status[1:1] = 0;
		}
	};
	
	update_c(arg1 : byte, arg2 : byte) is {
		if (arg1 + arg2 > 256) {
			reg_status[0:0] = 1;
		}
		else {
			reg_status[0:0] = 0;
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
