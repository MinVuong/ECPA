
##################################################
#
#Khai Pham 
#HCMUT LAB 203 
#
##################################################

if ![info exists env(GENUSHOME)] {puts "PLEASE SET \"GENUSHOME\" VARIABLE!"; exit 1}
set mod tb_modular_inversion 
##################################################
set_db library [list /opt/PDKs/skywater130/timing/sky130_fd_sc_hd__tt_025C_1v80.lib /opt/PDKs/sky130_sram_macros-dev/sky130_sram_1kbyte_1r1w_8x1024_8/sky130_sram_1kbyte_1r1w_8x1024_8_TT_1p8V_25C.lib ]

##################################################
read_hdl -sv -f  00_src/flist.f

##################################################
elaborate ${mod}
#set_top_design
write_hdl > 03_synth/${mod}_elab.v

check_design

##################################################
set FREQ_GHz 0.2
set FREQ [ expr ${FREQ_GHz}*1000000000.0 ]
set PERIOD [ expr (1.0/${FREQ})*1000000000000 ]
set IN_DLY [ expr $PERIOD/2 ]
set OUT_DLY [ expr $PERIOD/2 ]

##################################################

set clock [define_clock -period $PERIOD -name clk [clock_ports] ]

external_delay -clock clk -input $IN_DLY  -name delay_in  [all_inputs]
external_delay -clock clk -output $OUT_DLY -name delay_out [all_outputs]

set fan_net_max 3
set_max_fanout ${fan_net_max} [get_design ${mod}]
set_max_fanout ${fan_net_max} [all_inputs]

##################################################
syn_generic
write_hdl > 03_synth/${mod}_generic.v
syn_map
write_hdl > 03_synth/${mod}_tech_map.v
syn_opt 
##################################################
write_hdl > 03_synth/${mod}_gate.v
write_sdf -edges check_edge -setuphold "split" -recrem split > 03_synth/$mod.sdf

report timing -max_paths 10 > 04_reports/${mod}_timing.rpt
report hierarchy > 04_reports/${mod}_hier.rpt
report qor > 04_reports/${mod}_qor.rpt
report area > 04_reports/${mod}_area.rpt
report power > 04_reports/${mod}_power.rpt
report gates > 04_reports/${mod}_gates.rpt

##################################################
#gui_show
#exit
