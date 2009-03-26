alu_agent.e;
<'
import alu_components.e
unit sbt_agent_u {
	smp: sbt_signal_map_u is instance;
	mon: sbt_mon_u is instance;
	bfm: sbt_bfm_u is instance;
	
	keep mon.sample_p == read_only(smp.data_p);
	keep bfm.drv_p == read_only(smp.data_p);
};
