alu_sync.e;
<'
unit alu_sync_u {
	clk_p: in simple_port of bit is instance;
	keep bind(clk_p, external);
	event clk is rise (clk_p$) @sys.any;
};
'>
