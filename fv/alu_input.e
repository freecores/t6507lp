alu_input.e
<'

type alu_input_t: [ENABLED_VALID, DISABLED_VALID]; 

struct alu_input_s {
	input_kind : alu_input_t;
	
	reset_n: bool;
	alu_enable: bool;
	alu_opcode: byte;
	alu_a: byte;

	keep soft input_kind == select {
		50: ENABLED_VALID;
		50: DISABLED_VALID;
	};

	when ENABLED_VALID'input_kind alu_input_s {
		keep reset_n == TRUE; // remember this is active low 
		keep alu_enable == TRUE;
		keep alu_opcode in [0..255];
		keep alu_a in [0..255];
	};
	when DISABLED_VALID'input_kind alu_input_s {
		keep reset_n == TRUE; // remember this is active low 
		keep alu_enable == FALSE;
		keep alu_opcode in [0..255];
		keep alu_a in [0..255];
	};

	event T1_cover_event;
	cover T1_cover_event is {
		item input_kind using no_collect=TRUE;
		item alu_opcode using radix=HEX, no_collect=TRUE;
		cross input_kind, alu_opcode;
		//item alu_a;
	};

	post_generate() is also {
		emit T1_cover_event;
	};
};
'>

event cover_me;

   cover cover_me is {
      item a1 using no_collect=TRUE;
      item b2 using no_collect=TRUE;
      transition a1 using name=a_trans, no_collect=TRUE;
      transition b2 using name = b_trans, no_collect=TRUE;
      cross a_trans,b_trans;
   };


