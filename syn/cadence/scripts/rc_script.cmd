# Cadence Encounter(R) RTL Compiler
#   version v07.20-s009_1 (32-bit) built Feb  7 2008
#
# Run with the following arguments:
#   -logfile rc.log
#   -cmdfile rc_script.cmd
read_hdl  t6507lp.v t6507lp_alu.v t6507lp_fsm.v -v2001
set_attr lib_search_path /home/nscad/samuel/Desktop/libs/xc06/
set_attr library D_CELLS_3_3V.lib
elaborate
define_clock -period 1000000 -name 1MHz [find [ find / -design t6507lp] -port clk]
#set_attribute lp_insert_operand_isolation true
#set_attr lp_insert_clock_gating true
#synthesize -effort high
synthesize -to_generic
synthesize -to_mapped
synthesize -to_placed

write_hdl t6507lp > t6507lp.vg

exit
