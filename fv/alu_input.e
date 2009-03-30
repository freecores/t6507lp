alu_input.e
<'
import alu_components.e;
type alu_input_t: [ENABLED_VALID, DISABLED_VALID]; 

struct alu_input_s {
	input_kind : alu_input_t;
	
	reset_n: bool;
	alu_enable: bool;
	alu_opcode: valid_opcodes;
	alu_a: byte;

	keep soft input_kind == select {
		50: ENABLED_VALID;
		50: DISABLED_VALID;
	};

	when ENABLED_VALID'input_kind alu_input_s {
		keep reset_n == TRUE; // remember this is active low 
		keep alu_enable == TRUE;
		//keep alu_opcode in [0..255];
		keep alu_a in [0..255];
	};
	when DISABLED_VALID'input_kind alu_input_s {
		keep reset_n == TRUE; // remember this is active low 
		keep alu_enable == FALSE;
		//keep alu_opcode in [0..255];
		keep alu_a in [0..255];
	};

	event T1_cover_event;
	cover T1_cover_event is {
		item input_kind using no_collect=TRUE;
		item alu_opcode using num_of_buckets=256, radix=HEX, no_collect=TRUE;
		cross input_kind, alu_opcode;
		//item alu_a;
	};

};
'>

