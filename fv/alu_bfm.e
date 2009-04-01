<' 
import alu_components.e;

unit alu_bfm_u { 
	reset_n: out simple_port of bool;
	alu_enable: out simple_port of bool;
	alu_opcode: out simple_port of byte;
	alu_a: out simple_port of byte;

	reset_needed : bool;
	keep reset_needed == TRUE;
	
	event done;
	event main_clk;

	on main_clk {
		//Send in packet using the DUT protocol
		var data : alu_input_s;
		gen data;

		while (reset_needed) {
			gen data;
	
			if (data.input_kind == RESET) {
				reset_needed = FALSE;
			};
		};
	
		emit data.T1_cover_event;

		reset_n$ = data.reset_n;
		alu_enable$ = data.alu_enable;
		alu_opcode$ = data.alu_opcode.as_a(byte);
		alu_a$ = data.alu_a;

		agent.chk.store(data);
		emit done;
	};

};
'>
