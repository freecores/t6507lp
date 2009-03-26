alu_sig_map.e;
<'
unit alu_signal_map_u {
	rst : out simple_port of bool is instance;
	keep bind(rst, external);
	keep rst.hdl_path() == "n_rst_i";

	alu_enable : out simple_port of bool is instance;
	keep bind(alu_enable, external);
	keep alu_enable.hdl_path() == "alu_enable";

	alu_opcode : out simple_port of byte is instance;
	keep bind(alu_opcode, external);
	keep rst.hdl_path() == "alu_opcode";

	alu_a : out simple_port of byte is instance;
	keep bind(alu_a, external);
	keep rst.hdl_path() == "alu_a";
};
'>
