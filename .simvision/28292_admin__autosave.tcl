
# XM-Sim Command File
# TOOL:	xmsim(64)	20.09-s001
#

set tcl_prompt1 {puts -nonewline "xcelium> "}
set tcl_prompt2 {puts -nonewline "> "}
set vlog_format %h
set vhdl_format %v
set real_precision 6
set display_unit auto
set time_unit module
set heap_garbage_size -200
set heap_garbage_time 0
set assert_report_level note
set assert_stop_level error
set autoscope yes
set assert_1164_warnings yes
set pack_assert_off {}
set severity_pack_assert_off {note warning}
set assert_output_stop_level failed
set tcl_debug_level 0
set relax_path_name 1
set vhdl_vcdmap XX01ZX01X
set intovf_severity_level ERROR
set probe_screen_format 0
set rangecnst_severity_level ERROR
set textio_severity_level ERROR
set vital_timing_checks_on 1
set vlog_code_show_force 0
set assert_count_attempts 1
set tcl_all64 false
set tcl_runerror_exit false
set assert_report_incompletes 0
set show_force 1
set force_reset_by_reinvoke 0
set tcl_relaxed_literal 0
set probe_exclude_patterns {}
set probe_packed_limit 4k
set probe_unpacked_limit 16k
set assert_internal_msg no
set svseed 1
set assert_reporting_mode 0
set vcd_compact_mode 0
alias . run
alias quit exit
database -open -shm -into waves.shm waves -default
probe -create -database waves tb_ECC_top.uut.done tb_ECC_top.uut.done_ECC_core tb_ECC_top.uut.done_ECPA tb_ECC_top.uut.done_ECPM tb_ECC_top.uut.ecc_X tb_ECC_top.uut.ecc_control tb_ECC_top.uut.ecc_sel tb_ECC_top.uut.ecpa_X tb_ECC_top.uut.ecpa_Y tb_ECC_top.uut.ecpa_Z tb_ECC_top.uut.ecpm_X tb_ECC_top.uut.ecpm_Y tb_ECC_top.uut.ecpm_Z tb_ECC_top.uut.en_pc_update tb_ECC_top.uut.i_clk tb_ECC_top.uut.i_rst_n tb_ECC_top.uut.i_start tb_ECC_top.uut.inst tb_ECC_top.uut.n tb_ECC_top.uut.p tb_ECC_top.uut.pc tb_ECC_top.uut.pc_next tb_ECC_top.uut.rs1x_data tb_ECC_top.uut.rs1y_data tb_ECC_top.uut.rs1z_data tb_ECC_top.uut.rs2x_data tb_ECC_top.uut.rs2y_data tb_ECC_top.uut.rs2z_data tb_ECC_top.uut.start_ECC_core tb_ECC_top.uut.start_ECPA tb_ECC_top.uut.start_ECPM tb_ECC_top.uut.wb_data_1 tb_ECC_top.uut.wb_data_2 tb_ECC_top.uut.wb_data_3 tb_ECC_top.uut.wb_sel tb_ECC_top.uut.wb_wren tb_ECC_top.uut.control_inst.clk tb_ECC_top.uut.control_inst.done tb_ECC_top.uut.control_inst.done_ECC_core tb_ECC_top.uut.control_inst.done_ECPA tb_ECC_top.uut.control_inst.done_ECPM tb_ECC_top.uut.control_inst.done_EXECUTE tb_ECC_top.uut.control_inst.ecc_control tb_ECC_top.uut.control_inst.ecc_sel tb_ECC_top.uut.control_inst.en_pc_update tb_ECC_top.uut.control_inst.funct3 tb_ECC_top.uut.control_inst.instruction tb_ECC_top.uut.control_inst.next_state tb_ECC_top.uut.control_inst.opcode tb_ECC_top.uut.control_inst.rst_n tb_ECC_top.uut.control_inst.start tb_ECC_top.uut.control_inst.start_ECC_core tb_ECC_top.uut.control_inst.start_ECPA tb_ECC_top.uut.control_inst.start_ECPM tb_ECC_top.uut.control_inst.state tb_ECC_top.uut.control_inst.wb_sel tb_ECC_top.uut.control_inst.wb_wren tb_ECC_top.uut.regfile_inst.ecc_control tb_ECC_top.uut.regfile_inst.i_clk tb_ECC_top.uut.regfile_inst.i_rst_n tb_ECC_top.uut.regfile_inst.memory tb_ECC_top.uut.regfile_inst.not_reg0 tb_ECC_top.uut.regfile_inst.rs1_addr tb_ECC_top.uut.regfile_inst.rs1x_data tb_ECC_top.uut.regfile_inst.rs1y_data tb_ECC_top.uut.regfile_inst.rs1z_data tb_ECC_top.uut.regfile_inst.rs2_addr tb_ECC_top.uut.regfile_inst.rs2x_data tb_ECC_top.uut.regfile_inst.rs2y_data tb_ECC_top.uut.regfile_inst.rs2z_data tb_ECC_top.uut.regfile_inst.wb_addr tb_ECC_top.uut.regfile_inst.wb_data_1 tb_ECC_top.uut.regfile_inst.wb_data_2 tb_ECC_top.uut.regfile_inst.wb_data_3 tb_ECC_top.uut.regfile_inst.wb_wren tb_ECC_top.uut.regfile_inst.write
probe -create -database waves tb_ECC_top.uut.ecc_core_inst.a tb_ECC_top.uut.ecc_core_inst.alu_result tb_ECC_top.uut.ecc_core_inst.b tb_ECC_top.uut.ecc_core_inst.busy_inv tb_ECC_top.uut.ecc_core_inst.done tb_ECC_top.uut.ecc_core_inst.done_add tb_ECC_top.uut.ecc_core_inst.done_inv tb_ECC_top.uut.ecc_core_inst.done_mult tb_ECC_top.uut.ecc_core_inst.done_sub tb_ECC_top.uut.ecc_core_inst.ecc_sel tb_ECC_top.uut.ecc_core_inst.i_clk tb_ECC_top.uut.ecc_core_inst.i_rst_n tb_ECC_top.uut.ecc_core_inst.n tb_ECC_top.uut.ecc_core_inst.p_or_n tb_ECC_top.uut.ecc_core_inst.prime tb_ECC_top.uut.ecc_core_inst.ready0_inv tb_ECC_top.uut.ecc_core_inst.reset tb_ECC_top.uut.ecc_core_inst.result_add tb_ECC_top.uut.ecc_core_inst.result_inv tb_ECC_top.uut.ecc_core_inst.result_mult tb_ECC_top.uut.ecc_core_inst.result_sub tb_ECC_top.uut.ecc_core_inst.rst_modular tb_ECC_top.uut.ecc_core_inst.start tb_ECC_top.uut.ecc_core_inst.start_add tb_ECC_top.uut.ecc_core_inst.start_inv tb_ECC_top.uut.ecc_core_inst.start_inv_d tb_ECC_top.uut.ecc_core_inst.start_inv_pulse tb_ECC_top.uut.ecc_core_inst.start_mult tb_ECC_top.uut.ecc_core_inst.start_mult_d tb_ECC_top.uut.ecc_core_inst.start_mult_delay tb_ECC_top.uut.ecc_core_inst.start_mult_pulse tb_ECC_top.uut.ecc_core_inst.start_sub tb_ECC_top.uut.ecc_core_inst.state

simvision -input /home/admin/shared/ECDSA/.simvision/28292_admin__autosave.tcl.svcf
