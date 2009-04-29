<'
import fsm_components.e;
type fsm_input_t  :
		[ RESET, INSTRUCTIONS ];
			
'>
			BRK, RTI, RTS, PHA_PHP, PLA_PLP, JSR,
			ACCUMULATOR_OR_IMPLIED, IMMEDIATE, JMP,
			ABSOLUTE_READ_INSTRUCTIONS,
			ABSOLUTE_READ_MODIFY_WRITE,
			ABSOLUTE_WRITE_INSTRUCTIONS,
			ZERO_PAGE_READ_INSTRUCTIONS,
			ZERO_PAGE_READ_MODIFY_WRITE,
			ZERO_PAGE_WRITE_INSTRUCTIONS,
			ZERO_PAGE_INDEXED_READ_INSTRUCTIONS,
			ZERO_PAGE_INDEXED_READ_MODIFY_WRITE,
			ZERO_PAGE_INDEXED_WRITE_INSTRUCTIONS,
			ABSOLUTE_INDEXED_READ_INSTRUCTIONS,
			ABSOLUTE_INDEXED_READ_MODIFY_WRITE,
			ABSOLUTE_INDEXED_WRITE_INSTRUCTIONS,
			REL,
			INDEXED_INDIRECT_READ_INSTRUCTIONS,
			INDEXED_INDIRECT_READ_MODIFY_WRITE,
			INDEXED_INDIRECT_WRITE_INSTRUCTIONS,
			INDIRECT_INDEXED_READ_INSTRUCTIONS,
			INDIRECT_INDEXED_READ_MODIFY_WRITE,
			INDIRECT_INDEXED_WRITE_INSTRUCTIONS,
			ABSOLUTE_INDIRECT,
			ALU
<'
--type fsm_test_type: [REGULAR, RAND]; 

struct fsm_input_s {
	input_kind : fsm_input_t;
	--n_cycles   : int;
--	test_kind  : fsm_test_type;
	reset_n    : bit;
	alu_result : byte;
	alu_status : byte;
	data_in    : byte;
	alu_x      : byte;
	alu_y      : byte;

//	when RESET'input_kind fsm_input_s {
//		keep reset_n == 0;
//		--keep n_cycles == 7;
//	};
	
//	when BRK'input_kind fsm_input_s {
//		keep reset_n == 1;
//		keep n_cycles == 7;
//		keep data_in == 8'h;
//	};

//	when RTI'input_kind fsm_input_s {
//		keep reset_n == 1;
//	};

//	when RTS'input_kind fsm_input_s {
//		keep reset_n == 1;
//	};

//	when PHA_PHP'input_kind fsm_input_s {
//		keep reset_n == 1;
//	};
	
//	when PLA_PLP'input_kind fsm_input_s {
//		keep reset_n == 1;
//	};

//	when JSR'input_kind fsm_input_s {
//		keep reset_n == 1;
//	};

//	when ACCUMULATOR_OR_IMPLIED'input_kind fsm_input_s {
//		keep reset_n == 1;
//		keep data_in == 
//	};

//	when IMMEDIATE'input_kind fsm_input_s {
//		keep reset_n == 1;
//	};

//	when JMP'input_kind fsm_input_s {
//		keep reset_n == 1;
//	};

//	when ABSOLUTE_READ_INSTRUCTIONS'input_kind fsm_input_s {
//		keep reset_n == 1;
//	};

//	when ABSOLUTE_READ_MODIFY_WRITE'input_kind fsm_input_s {
//		keep reset_n == 1;
//	};

//	when ABSOLUTE_WRITE_INSTRUCTIONS'input_kind fsm_input_s {
//		keep reset_n == 1;
//	};

//	when ZERO_PAGE_READ_INSTRUCTIONS'input_kind fsm_input_s {
//		keep reset_n == 1;
//	};

//	when ZERO_PAGE_READ_MODIFY_WRITE'input_kind fsm_input_s {
//		keep reset_n == 1;
//	};

//	when ZERO_PAGE_WRITE_INSTRUCTIONS'input_kind fsm_input_s {
//		keep reset_n == 1;
//	};

//	when ZERO_PAGE_INDEXED_READ_INSTRUCTIONS'input_kind fsm_input_s {
//		keep reset_n == 1;
//	};

//	when ZERO_PAGE_INDEXED_READ_MODIFY_WRITE'input_kind fsm_input_s {
//		keep reset_n == 1;
//	};

//	when ZERO_PAGE_INDEXED_WRITE_INSTRUCTIONS'input_kind fsm_input_s {
//		keep reset_n == 1;
//	};

//	when ABSOLUTE_INDEXED_READ_INSTRUCTIONS'input_kind fsm_input_s {
//		keep reset_n == 1;
//	};

//	when ABSOLUTE_INDEXED_READ_MODIFY_WRITE'input_kind fsm_input_s {
//		keep reset_n == 1;
//	};

//	when ABSOLUTE_INDEXED_WRITE_INSTRUCTIONS'input_kind fsm_input_s {
//		keep reset_n == 1;
//	};

//	when REL'input_kind fsm_input_s {
//		keep reset_n == 1;
//	};

//	when INDEXED_INDIRECT_READ_INSTRUCTIONS'input_kind fsm_input_s {
//		keep reset_n == 1;
//	};

//	when INDEXED_INDIRECT_READ_MODIFY_WRITE'input_kind fsm_input_s {
//		keep reset_n == 1;
//	};

//	when INDEXED_INDIRECT_WRITE_INSTRUCTIONS'input_kind fsm_input_s {
//		keep reset_n == 1;
//	};

//	when INDIRECT_INDEXED_READ_INSTRUCTIONS'input_kind fsm_input_s {
//		keep reset_n == 1;
//	};

//	when INDIRECT_INDEXED_READ_MODIFY_WRITE'input_kind fsm_input_s {
//		keep reset_n == 1;
//	};

//	when INDIRECT_INDEXED_WRITE_INSTRUCTIONS'input_kind fsm_input_s {
//		keep reset_n == 1;
//	};

//	when ABSOLUTE_INDIRECT'input_kind fsm_input_s {
//		keep reset_n == 1;
//	};
	
//	when ALU'input_kind fsm_input_s {
//		keep reset_n == 1;
//	};

//	when 'input_kind fsm_input_s {
//		keep reset_n == 1;
//	};

--	when REGULAR'test_kind alu_input_s {
--		keep soft input_kind == select {
--			45: ENABLED_VALID;
--			45: DISABLED_VALID;
--			10: RESET;
--		};
--	};

--	when ENABLED_VALID'input_kind alu_input_s {
--		keep reset_n == TRUE; // remember this is active low 
--		keep alu_enable == TRUE;
--		keep alu_a in [0..255];
--	};

--	when DISABLED_VALID'input_kind alu_input_s {
--		keep reset_n == TRUE; // remember this is active low 
--		keep alu_enable == FALSE;
--		keep alu_a in [0..255];
--	};

	keep soft input_kind == select {
			99: INSTRUCTIONS;
			1 : RESET;
		};	
	
	when RESET'input_kind fsm_input_s {
		keep reset_n == 0;
	};
	
	when INSTRUCTIONS'input_kind fsm_input_s {
		keep reset_n == 1;
	};
	
--	event T1_cover_event;
--	cover T1_cover_event is {
--		item input_kind using no_collect=TRUE, ignore = (input_kind == ENABLED_RAND || input_kind == DISABLED_RAND);
--		item alu_opcode using num_of_buckets=256, radix=HEX, no_collect=TRUE;
--		cross input_kind, alu_opcode;
--		//item alu_a;
--	};
};

--extend fsm_input_s {
--	rand_op : byte;
--
--	when RAND'test_kind alu_input_s {
--		keep soft input_kind == select {
--			45: ENABLED_RAND;
--			45: DISABLED_RAND;
--			10: RESET;
--		};
--	};
--
--	when ENABLED_RAND'input_kind alu_input_s {
--		keep reset_n == TRUE; // remember this is active low 
--		keep alu_enable == TRUE;
--		keep alu_a in [0..255];
--		keep rand_op in [0..255];
--	};
--
--	when DISABLED_RAND'input_kind alu_input_s {
--		keep reset_n == TRUE; // remember this is active low 
--		keep alu_enable == FALSE;
--		keep alu_a in [0..255];
--		keep rand_op in [0..255];
--	};
--
--	event T2_cover_event;
--	cover T2_cover_event is {
--		item alu_enable using no_collect=TRUE;
--		item rand_op using num_of_buckets=256, radix=HEX, no_collect=TRUE;
--		cross alu_enable, rand_op;
--	};
--};

'>
