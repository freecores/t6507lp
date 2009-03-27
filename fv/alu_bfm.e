<' 
import alu_components.e;

unit alu_bfm_u { 
	reset_n: out simple_port of bool;
	alu_enable: out simple_port of bool;
	alu_opcode: out simple_port of byte;
	alu_a: out simple_port of byte;

	event main_clk;

	on main_clk {
		//Send in packet using the DUT protocol
		var data : alu_input_s;
		gen data;

		emit data.T1_cover_event;

		reset_n$ = data.reset_n;
		alu_enable$ = data.alu_enable;
		alu_opcode$ = data.alu_opcode;
		alu_a$ = data.alu_a;	

	};

};
'>
