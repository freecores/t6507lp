<' 
import alu_components.e;

unit alu_bfm_u { 
	
	//event clock_e;
	//send_pkt(pkt: alu_packet_s) @clock_e is {
	//Send in packet using the DUT protocol
	//};

	rst: out simple_port of bool;
	alu_enable: out simple_port of bool;
	alu_opcode: out simple_port of byte;
	alu_a: out simple_port of byte;
};
'>
