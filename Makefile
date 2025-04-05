
##################################################
#
#Khai Pham 
#HCMUT LAB 203 
#
##################################################
PHONY: syn
syn: clean
	genus -f ./03_synth/genus_shell.tcl
##################################################
#GUI = -gui
tb_file := 01_tb/tb_scalar_mult.sv

PHONY: sim
sim:
	xrun $(GUI) +xm64bit -sv \
	-vlogext .sv \
	-f 00_src/flist.f \
	$(tb_file) \
	-timescale 1ns/10ps \
	+access+rcw
##################################################
#GUI = -gui
delay_mode := -delay_mode punit
#sdf_file := -sdf_cmd_file 03_synth/sdf.cmd 
netlist := 03_synth/*_gate.v
test_file := 01_tb/tb_scalar_mult.sv+

PHONY: verify
verify:
	xrun $(GUI) +xm64bit -sv \
	$(netlist) \
	$(test_file) \
	-vlogext .sv \
	-f 02_sim/flist.f \
	$(sdf_file) \
	$(delay_mode) \
	-timescale 1ns/10ps \
	+access+rcw

##################################################
PHONY: report
report:
	@echo "with Frequency at: "
	@grep "set FREQ_GHz" 03_synth/genus_shell.tcl
	@grep "Path " 04_reports/*_timing.rpt 

##################################################
PHONY: clean
clean:
	@rm -rf genus.cmd genus.log xrun.history xrun.key xcelium.d *.shm

##################################################
PHONY: clean-all
clean-all: clean-rpt clean-syn
	@rm -rf fv genus.cmd genus.log xrun.history xrun.log xrun.key synth_wrapper.sdf.X xcelium.d *.shm

##################################################
PHONY: clean-rpt
clean-rpt:
	@rm -rf 04_reports/*.rpt

##################################################
PHONY: clean-syn
clean-syn:
	@rm -rf 03_synth/*.v 03_synth/*.sdf

##################################################

