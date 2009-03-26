<' 
unit alu_bfm_u { 
	event clock_e;
	send_pkt(pkt: alu_packet_s) @clock_e is {
	//Send in packet using the DUT protocol
	};
};
'>
