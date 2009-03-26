alu_agent.e;
<'
import alu_components.e;

unit alu_agent_u {
	smp: alu_signal_map_u is instance;
	mon: alu_mon_u is instance;
	bfm: alu_bfm_u is instance;
	sync: alu_sync_u is instance;
	
	event main_clk;	
	
	keep bfm.rst == smp.rst;
	keep bfm.alu_enable == smp.alu_enable;
	keep bfm.alu_opcode == smp.alu_opcode;
	//keep bfm.alu_a == smp.alu_a;

	keep mon.alu_result == smp.alu_result;
	keep mon.alu_status == smp.alu_status;
	keep mon.alu_x == smp.alu_x;
	keep mon.alu_y == smp.alu_y;

	help() @ main_clk is {
		out ("Hello World");
	};

	run() is also {
		start help();
	};
};
'>
