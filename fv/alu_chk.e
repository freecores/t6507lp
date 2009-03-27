alu_chk.e
<'
import alu_components;

unit alu_chk_u {
	reg_a : byte;
	reg_x : byte;
	reg_y : byte;
	reg_status : byte;

	count_cycles : int;
	first_cycle : bool;

	keep first_cycle == TRUE;
	keep count_cycles == 0;

	store(input : alu_input_s) is {
		out ("input stored: ", input);
	};

	compare(alu_result:byte, alu_status:byte, alu_x:byte, alu_y:byte ) is {
		if (first_cycle) {
			first_cycle = FALSE;
			reg_x = alu_x;
			reg_y = alu_y;
			reg_status = alu_status;
			reg_a = ???? // TODO
		}
	};
};
'>
