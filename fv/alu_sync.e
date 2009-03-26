alu_sync.e;
<'
unit alu_sync_u {
	clk_p: in event_port is instance;
	keep bind(clk_p, external);
	keep clk_p.hdl_path() == "clk";
	keep clk_p.edge() == rise;
};
'>
