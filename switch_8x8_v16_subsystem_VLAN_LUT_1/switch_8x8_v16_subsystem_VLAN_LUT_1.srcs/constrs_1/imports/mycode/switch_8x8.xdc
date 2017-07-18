# PART is kintexu xcku095ffvc1517-2
#######################################################
# Clock/period constraints                            #
#######################################################
# Main transmit clock/period constraints

create_clock -period 10.000 [get_ports clk_in_p]
set_input_jitter clk_in_p 0.050
create_clock -period 6.400 [get_ports refclk_p]

set_property PACKAGE_PIN AL30 [get_ports clk_in_p]
set_property PACKAGE_PIN AM30 [get_ports clk_in_n]
set_property IOSTANDARD DIFF_HSTL_I_DCI_18 [get_ports clk_in_p]
set_property IOSTANDARD DIFF_HSTL_I_DCI_18 [get_ports clk_in_n]

set_property PACKAGE_PIN AA34 [get_ports refclk_n]
set_property PACKAGE_PIN AA33 [get_ports refclk_p]

set_property PACKAGE_PIN AM27 [get_ports rst_n]
set_property IOSTANDARD LVCMOS33 [get_ports rst_n]

set_property PACKAGE_PIN AC38 [get_ports rxp]
set_property PACKAGE_PIN AC39 [get_ports rxn]
set_property PACKAGE_PIN AD35 [get_ports txp]
set_property PACKAGE_PIN AD36 [get_ports txn]

set_property PACKAGE_PIN AA38 [get_ports rxp_1]
set_property PACKAGE_PIN AA39 [get_ports rxn_1]
set_property PACKAGE_PIN AB35 [get_ports txp_1]
set_property PACKAGE_PIN AB36 [get_ports txn_1]

set_property PACKAGE_PIN W38 [get_ports rxp_2]
set_property PACKAGE_PIN W39 [get_ports rxn_2]
set_property PACKAGE_PIN V35 [get_ports txp_2]
set_property PACKAGE_PIN V36 [get_ports txn_2]

set_property PACKAGE_PIN U38 [get_ports rxp_3]
set_property PACKAGE_PIN U39 [get_ports rxn_3]
set_property PACKAGE_PIN T35 [get_ports txp_3]
set_property PACKAGE_PIN T36 [get_ports txn_3]

set_property PACKAGE_PIN R38 [get_ports rxp_4]
set_property PACKAGE_PIN R39 [get_ports rxn_4]
set_property PACKAGE_PIN P35 [get_ports txp_4]
set_property PACKAGE_PIN P36 [get_ports txn_4]

set_property PACKAGE_PIN N38 [get_ports rxp_5]
set_property PACKAGE_PIN N39 [get_ports rxn_5]
set_property PACKAGE_PIN M35 [get_ports txp_5]
set_property PACKAGE_PIN M36 [get_ports txn_5]

set_property PACKAGE_PIN K36 [get_ports txn_6]
set_property PACKAGE_PIN L38 [get_ports rxp_6]
set_property PACKAGE_PIN L39 [get_ports rxn_6]
set_property PACKAGE_PIN K35 [get_ports txp_6]

set_property PACKAGE_PIN J38 [get_ports rxp_7]
set_property PACKAGE_PIN J39 [get_ports rxn_7]
set_property PACKAGE_PIN H35 [get_ports txp_7]
set_property PACKAGE_PIN H36 [get_ports txn_7]

#set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets U_MAC_PHY_1/fifo_block_i/support_layer_i/shared_clocking_wrapper_i/gt_common_block_i/axi_10g_ethernet_0_gt_common_wrapper_i/common_inst/qpll0outclk]
#######################################################
# Synchronizer False paths
#######################################################
#set_false_path -to [get_cells -hierarchical -filter {NAME =~ pattern_generator*sync1_r_reg[0]}]
#set_false_path -to [get_cells -hierarchical -filter {NAME =~ reset_error_sync_reg*sync1_r_reg[0]}]
#set_false_path -to [get_cells -hierarchical -filter {NAME =~ gen_enable_sync/sync1_r_reg[0]}]
#set_false_path -to [get_pins -of_objects [get_cells -hierarchical -filter {NAME =~ *shared_clock_reset_block*sync1_r_reg[*]}] -filter {NAME =~ *PRE}]

#######################################################
# FIFO level constraints
#######################################################

#set_false_path -from [get_cells fifo_block_i/ethernet_mac_fifo_i/*/wr_store_frame_tog_reg] -to [get_cells fifo_block_i/#ethernet_mac_fifo_i/*/*/sync1_r_reg*]
#set_max_delay -datapath_only -from [get_cells {fifo_block_i/ethernet_mac_fifo_i/*/rd_addr_gray_reg_reg[*]}] -to [get_cells #fifo_block_i/ethernet_mac_fifo_i/*/*/sync1_r_reg*] 6.400
#set_false_path -to [get_pins -filter {NAME =~ */PRE} -of_objects [get_cells fifo_block_i/ethernet_mac_fifo_i/*/*/reset_async*_reg]]

#######################################################
# I/O constraints                                     #
#######################################################

# These inputs can be connected to dip switches or push buttons on an
# appropriate board.

#set_false_path -from [get_ports reset]
#set_false_path -from [get_ports reset_error]
#set_false_path -from [get_ports insert_error]
#set_false_path -from [get_ports pcs_loopback]
#set_false_path -from [get_ports enable_pat_gen]
#set_false_path -from [get_ports enable_pat_check]
#set_false_path -from [get_ports enable_custom_preamble]
#set_case_analysis 0  [get_ports sim_speedup_control]

# These outputs can be connected to LED's or headers on an
# appropriate board.

#set_false_path -to [get_ports core_ready]
#set_false_path -to [get_ports coreclk_out]
#set_false_path -to [get_ports qplllock_out]
#set_false_path -to [get_ports frame_error]
#set_false_path -to [get_ports gen_active_flash]
#set_false_path -to [get_ports check_active_flash]
#set_false_path -to [get_ports serialized_stats]
#set_case_analysis 0 [get_ports sim_speedup_control]
#set_false_path -to [get_ports core_ready]
#set_false_path -to [get_ports coreclk_out]
#set_false_path -to [get_ports qplllock_out]
#set_false_path -to [get_ports frame_error]
#set_false_path -to [get_ports gen_active_flash]
#set_false_path -to [get_ports check_active_flash]
#set_false_path -to [get_ports serialized_stats]

#######################################################
# Transcevier Refclk placement constraints            #
#######################################################

# GTYE3_CHANNEL_X0Y4 was selected for use from the customization GUI.  This transcevier is located in the GT Quad GTYE3_COMMON_X0Y1

# The following reference clock source to the GTYE3_COMMON_X0Y1 is as selected from the IP customization GUI.
#set_property LOC GTYE3_COMMON_X0Y1 [get_cells -hier -filter {NAME=~  *shared_clocking_wrapper*ibufds_inst}]

set_case_analysis 0 [get_ports sim_speedup_control]
set_false_path -to [get_ports core_ready]
set_false_path -to [get_ports coreclk_out]
#set_false_path -to [get_ports frame_error]


create_debug_core u_ila_0 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_0]
set_property ALL_PROBE_SAME_MU_CNT 1 [get_debug_cores u_ila_0]
set_property C_ADV_TRIGGER false [get_debug_cores u_ila_0]
set_property C_DATA_DEPTH 1024 [get_debug_cores u_ila_0]
set_property C_EN_STRG_QUAL false [get_debug_cores u_ila_0]
set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_0]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_0]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_0]
set_property port_width 1 [get_debug_ports u_ila_0/clk]
connect_debug_port u_ila_0/clk [get_nets [list axi_lite_clocking_i/s_axi_aclk]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe0]
set_property port_width 64 [get_debug_ports u_ila_0/probe0]
connect_debug_port u_ila_0/probe0 [get_nets [list {m_switch_tdata[0]} {m_switch_tdata[1]} {m_switch_tdata[2]} {m_switch_tdata[3]} {m_switch_tdata[4]} {m_switch_tdata[5]} {m_switch_tdata[6]} {m_switch_tdata[7]} {m_switch_tdata[8]} {m_switch_tdata[9]} {m_switch_tdata[10]} {m_switch_tdata[11]} {m_switch_tdata[12]} {m_switch_tdata[13]} {m_switch_tdata[14]} {m_switch_tdata[15]} {m_switch_tdata[16]} {m_switch_tdata[17]} {m_switch_tdata[18]} {m_switch_tdata[19]} {m_switch_tdata[20]} {m_switch_tdata[21]} {m_switch_tdata[22]} {m_switch_tdata[23]} {m_switch_tdata[24]} {m_switch_tdata[25]} {m_switch_tdata[26]} {m_switch_tdata[27]} {m_switch_tdata[28]} {m_switch_tdata[29]} {m_switch_tdata[30]} {m_switch_tdata[31]} {m_switch_tdata[32]} {m_switch_tdata[33]} {m_switch_tdata[34]} {m_switch_tdata[35]} {m_switch_tdata[36]} {m_switch_tdata[37]} {m_switch_tdata[38]} {m_switch_tdata[39]} {m_switch_tdata[40]} {m_switch_tdata[41]} {m_switch_tdata[42]} {m_switch_tdata[43]} {m_switch_tdata[44]} {m_switch_tdata[45]} {m_switch_tdata[46]} {m_switch_tdata[47]} {m_switch_tdata[48]} {m_switch_tdata[49]} {m_switch_tdata[50]} {m_switch_tdata[51]} {m_switch_tdata[52]} {m_switch_tdata[53]} {m_switch_tdata[54]} {m_switch_tdata[55]} {m_switch_tdata[56]} {m_switch_tdata[57]} {m_switch_tdata[58]} {m_switch_tdata[59]} {m_switch_tdata[60]} {m_switch_tdata[61]} {m_switch_tdata[62]} {m_switch_tdata[63]}]]
create_debug_core u_ila_1 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_1]
set_property ALL_PROBE_SAME_MU_CNT 1 [get_debug_cores u_ila_1]
set_property C_ADV_TRIGGER false [get_debug_cores u_ila_1]
set_property C_DATA_DEPTH 1024 [get_debug_cores u_ila_1]
set_property C_EN_STRG_QUAL false [get_debug_cores u_ila_1]
set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_1]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_1]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_1]
set_property port_width 1 [get_debug_ports u_ila_1/clk]
connect_debug_port u_ila_1/clk [get_nets [list shared_clocking_wrapper_0/ethernet_shared_clock_reset_block_i/CLK]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe0]
set_property port_width 64 [get_debug_ports u_ila_1/probe0]
connect_debug_port u_ila_1/probe0 [get_nets [list {rx_axis_mac_tdata[0]} {rx_axis_mac_tdata[1]} {rx_axis_mac_tdata[2]} {rx_axis_mac_tdata[3]} {rx_axis_mac_tdata[4]} {rx_axis_mac_tdata[5]} {rx_axis_mac_tdata[6]} {rx_axis_mac_tdata[7]} {rx_axis_mac_tdata[8]} {rx_axis_mac_tdata[9]} {rx_axis_mac_tdata[10]} {rx_axis_mac_tdata[11]} {rx_axis_mac_tdata[12]} {rx_axis_mac_tdata[13]} {rx_axis_mac_tdata[14]} {rx_axis_mac_tdata[15]} {rx_axis_mac_tdata[16]} {rx_axis_mac_tdata[17]} {rx_axis_mac_tdata[18]} {rx_axis_mac_tdata[19]} {rx_axis_mac_tdata[20]} {rx_axis_mac_tdata[21]} {rx_axis_mac_tdata[22]} {rx_axis_mac_tdata[23]} {rx_axis_mac_tdata[24]} {rx_axis_mac_tdata[25]} {rx_axis_mac_tdata[26]} {rx_axis_mac_tdata[27]} {rx_axis_mac_tdata[28]} {rx_axis_mac_tdata[29]} {rx_axis_mac_tdata[30]} {rx_axis_mac_tdata[31]} {rx_axis_mac_tdata[32]} {rx_axis_mac_tdata[33]} {rx_axis_mac_tdata[34]} {rx_axis_mac_tdata[35]} {rx_axis_mac_tdata[36]} {rx_axis_mac_tdata[37]} {rx_axis_mac_tdata[38]} {rx_axis_mac_tdata[39]} {rx_axis_mac_tdata[40]} {rx_axis_mac_tdata[41]} {rx_axis_mac_tdata[42]} {rx_axis_mac_tdata[43]} {rx_axis_mac_tdata[44]} {rx_axis_mac_tdata[45]} {rx_axis_mac_tdata[46]} {rx_axis_mac_tdata[47]} {rx_axis_mac_tdata[48]} {rx_axis_mac_tdata[49]} {rx_axis_mac_tdata[50]} {rx_axis_mac_tdata[51]} {rx_axis_mac_tdata[52]} {rx_axis_mac_tdata[53]} {rx_axis_mac_tdata[54]} {rx_axis_mac_tdata[55]} {rx_axis_mac_tdata[56]} {rx_axis_mac_tdata[57]} {rx_axis_mac_tdata[58]} {rx_axis_mac_tdata[59]} {rx_axis_mac_tdata[60]} {rx_axis_mac_tdata[61]} {rx_axis_mac_tdata[62]} {rx_axis_mac_tdata[63]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe1]
set_property port_width 8 [get_debug_ports u_ila_0/probe1]
connect_debug_port u_ila_0/probe1 [get_nets [list {m_switch_tkeep[0]} {m_switch_tkeep[1]} {m_switch_tkeep[2]} {m_switch_tkeep[3]} {m_switch_tkeep[4]} {m_switch_tkeep[5]} {m_switch_tkeep[6]} {m_switch_tkeep[7]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe2]
set_property port_width 64 [get_debug_ports u_ila_0/probe2]
connect_debug_port u_ila_0/probe2 [get_nets [list {s_switch_tdata[0]} {s_switch_tdata[1]} {s_switch_tdata[2]} {s_switch_tdata[3]} {s_switch_tdata[4]} {s_switch_tdata[5]} {s_switch_tdata[6]} {s_switch_tdata[7]} {s_switch_tdata[8]} {s_switch_tdata[9]} {s_switch_tdata[10]} {s_switch_tdata[11]} {s_switch_tdata[12]} {s_switch_tdata[13]} {s_switch_tdata[14]} {s_switch_tdata[15]} {s_switch_tdata[16]} {s_switch_tdata[17]} {s_switch_tdata[18]} {s_switch_tdata[19]} {s_switch_tdata[20]} {s_switch_tdata[21]} {s_switch_tdata[22]} {s_switch_tdata[23]} {s_switch_tdata[24]} {s_switch_tdata[25]} {s_switch_tdata[26]} {s_switch_tdata[27]} {s_switch_tdata[28]} {s_switch_tdata[29]} {s_switch_tdata[30]} {s_switch_tdata[31]} {s_switch_tdata[32]} {s_switch_tdata[33]} {s_switch_tdata[34]} {s_switch_tdata[35]} {s_switch_tdata[36]} {s_switch_tdata[37]} {s_switch_tdata[38]} {s_switch_tdata[39]} {s_switch_tdata[40]} {s_switch_tdata[41]} {s_switch_tdata[42]} {s_switch_tdata[43]} {s_switch_tdata[44]} {s_switch_tdata[45]} {s_switch_tdata[46]} {s_switch_tdata[47]} {s_switch_tdata[48]} {s_switch_tdata[49]} {s_switch_tdata[50]} {s_switch_tdata[51]} {s_switch_tdata[52]} {s_switch_tdata[53]} {s_switch_tdata[54]} {s_switch_tdata[55]} {s_switch_tdata[56]} {s_switch_tdata[57]} {s_switch_tdata[58]} {s_switch_tdata[59]} {s_switch_tdata[60]} {s_switch_tdata[61]} {s_switch_tdata[62]} {s_switch_tdata[63]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe3]
set_property port_width 8 [get_debug_ports u_ila_0/probe3]
connect_debug_port u_ila_0/probe3 [get_nets [list {s_switch_tkeep[0]} {s_switch_tkeep[1]} {s_switch_tkeep[2]} {s_switch_tkeep[3]} {s_switch_tkeep[4]} {s_switch_tkeep[5]} {s_switch_tkeep[6]} {s_switch_tkeep[7]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe4]
set_property port_width 64 [get_debug_ports u_ila_0/probe4]
connect_debug_port u_ila_0/probe4 [get_nets [list {tx_axis_as_tdata[0]} {tx_axis_as_tdata[1]} {tx_axis_as_tdata[2]} {tx_axis_as_tdata[3]} {tx_axis_as_tdata[4]} {tx_axis_as_tdata[5]} {tx_axis_as_tdata[6]} {tx_axis_as_tdata[7]} {tx_axis_as_tdata[8]} {tx_axis_as_tdata[9]} {tx_axis_as_tdata[10]} {tx_axis_as_tdata[11]} {tx_axis_as_tdata[12]} {tx_axis_as_tdata[13]} {tx_axis_as_tdata[14]} {tx_axis_as_tdata[15]} {tx_axis_as_tdata[16]} {tx_axis_as_tdata[17]} {tx_axis_as_tdata[18]} {tx_axis_as_tdata[19]} {tx_axis_as_tdata[20]} {tx_axis_as_tdata[21]} {tx_axis_as_tdata[22]} {tx_axis_as_tdata[23]} {tx_axis_as_tdata[24]} {tx_axis_as_tdata[25]} {tx_axis_as_tdata[26]} {tx_axis_as_tdata[27]} {tx_axis_as_tdata[28]} {tx_axis_as_tdata[29]} {tx_axis_as_tdata[30]} {tx_axis_as_tdata[31]} {tx_axis_as_tdata[32]} {tx_axis_as_tdata[33]} {tx_axis_as_tdata[34]} {tx_axis_as_tdata[35]} {tx_axis_as_tdata[36]} {tx_axis_as_tdata[37]} {tx_axis_as_tdata[38]} {tx_axis_as_tdata[39]} {tx_axis_as_tdata[40]} {tx_axis_as_tdata[41]} {tx_axis_as_tdata[42]} {tx_axis_as_tdata[43]} {tx_axis_as_tdata[44]} {tx_axis_as_tdata[45]} {tx_axis_as_tdata[46]} {tx_axis_as_tdata[47]} {tx_axis_as_tdata[48]} {tx_axis_as_tdata[49]} {tx_axis_as_tdata[50]} {tx_axis_as_tdata[51]} {tx_axis_as_tdata[52]} {tx_axis_as_tdata[53]} {tx_axis_as_tdata[54]} {tx_axis_as_tdata[55]} {tx_axis_as_tdata[56]} {tx_axis_as_tdata[57]} {tx_axis_as_tdata[58]} {tx_axis_as_tdata[59]} {tx_axis_as_tdata[60]} {tx_axis_as_tdata[61]} {tx_axis_as_tdata[62]} {tx_axis_as_tdata[63]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe5]
set_property port_width 3 [get_debug_ports u_ila_0/probe5]
connect_debug_port u_ila_0/probe5 [get_nets [list {tx_axis_as_tdest[0]} {tx_axis_as_tdest[1]} {tx_axis_as_tdest[2]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe6]
set_property port_width 8 [get_debug_ports u_ila_0/probe6]
connect_debug_port u_ila_0/probe6 [get_nets [list {tx_axis_as_tkeep[0]} {tx_axis_as_tkeep[1]} {tx_axis_as_tkeep[2]} {tx_axis_as_tkeep[3]} {tx_axis_as_tkeep[4]} {tx_axis_as_tkeep[5]} {tx_axis_as_tkeep[6]} {tx_axis_as_tkeep[7]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe7]
set_property port_width 1 [get_debug_ports u_ila_0/probe7]
connect_debug_port u_ila_0/probe7 [get_nets [list m_switch_tlast]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe8]
set_property port_width 1 [get_debug_ports u_ila_0/probe8]
connect_debug_port u_ila_0/probe8 [get_nets [list m_switch_tready]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe9]
set_property port_width 1 [get_debug_ports u_ila_0/probe9]
connect_debug_port u_ila_0/probe9 [get_nets [list m_switch_tvalid]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe10]
set_property port_width 1 [get_debug_ports u_ila_0/probe10]
connect_debug_port u_ila_0/probe10 [get_nets [list s_switch_tlast]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe11]
set_property port_width 1 [get_debug_ports u_ila_0/probe11]
connect_debug_port u_ila_0/probe11 [get_nets [list s_switch_tready]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe12]
set_property port_width 1 [get_debug_ports u_ila_0/probe12]
connect_debug_port u_ila_0/probe12 [get_nets [list s_switch_tvalid]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe13]
set_property port_width 1 [get_debug_ports u_ila_0/probe13]
connect_debug_port u_ila_0/probe13 [get_nets [list tx_axis_as_tlast]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe14]
set_property port_width 1 [get_debug_ports u_ila_0/probe14]
connect_debug_port u_ila_0/probe14 [get_nets [list tx_axis_as_tready]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe15]
set_property port_width 1 [get_debug_ports u_ila_0/probe15]
connect_debug_port u_ila_0/probe15 [get_nets [list tx_axis_as_tvalid]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe1]
set_property port_width 8 [get_debug_ports u_ila_1/probe1]
connect_debug_port u_ila_1/probe1 [get_nets [list {rx_axis_mac_tkeep[0]} {rx_axis_mac_tkeep[1]} {rx_axis_mac_tkeep[2]} {rx_axis_mac_tkeep[3]} {rx_axis_mac_tkeep[4]} {rx_axis_mac_tkeep[5]} {rx_axis_mac_tkeep[6]} {rx_axis_mac_tkeep[7]}]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe2]
set_property port_width 64 [get_debug_ports u_ila_1/probe2]
connect_debug_port u_ila_1/probe2 [get_nets [list {tx_axis_mac_tdata[0]} {tx_axis_mac_tdata[1]} {tx_axis_mac_tdata[2]} {tx_axis_mac_tdata[3]} {tx_axis_mac_tdata[4]} {tx_axis_mac_tdata[5]} {tx_axis_mac_tdata[6]} {tx_axis_mac_tdata[7]} {tx_axis_mac_tdata[8]} {tx_axis_mac_tdata[9]} {tx_axis_mac_tdata[10]} {tx_axis_mac_tdata[11]} {tx_axis_mac_tdata[12]} {tx_axis_mac_tdata[13]} {tx_axis_mac_tdata[14]} {tx_axis_mac_tdata[15]} {tx_axis_mac_tdata[16]} {tx_axis_mac_tdata[17]} {tx_axis_mac_tdata[18]} {tx_axis_mac_tdata[19]} {tx_axis_mac_tdata[20]} {tx_axis_mac_tdata[21]} {tx_axis_mac_tdata[22]} {tx_axis_mac_tdata[23]} {tx_axis_mac_tdata[24]} {tx_axis_mac_tdata[25]} {tx_axis_mac_tdata[26]} {tx_axis_mac_tdata[27]} {tx_axis_mac_tdata[28]} {tx_axis_mac_tdata[29]} {tx_axis_mac_tdata[30]} {tx_axis_mac_tdata[31]} {tx_axis_mac_tdata[32]} {tx_axis_mac_tdata[33]} {tx_axis_mac_tdata[34]} {tx_axis_mac_tdata[35]} {tx_axis_mac_tdata[36]} {tx_axis_mac_tdata[37]} {tx_axis_mac_tdata[38]} {tx_axis_mac_tdata[39]} {tx_axis_mac_tdata[40]} {tx_axis_mac_tdata[41]} {tx_axis_mac_tdata[42]} {tx_axis_mac_tdata[43]} {tx_axis_mac_tdata[44]} {tx_axis_mac_tdata[45]} {tx_axis_mac_tdata[46]} {tx_axis_mac_tdata[47]} {tx_axis_mac_tdata[48]} {tx_axis_mac_tdata[49]} {tx_axis_mac_tdata[50]} {tx_axis_mac_tdata[51]} {tx_axis_mac_tdata[52]} {tx_axis_mac_tdata[53]} {tx_axis_mac_tdata[54]} {tx_axis_mac_tdata[55]} {tx_axis_mac_tdata[56]} {tx_axis_mac_tdata[57]} {tx_axis_mac_tdata[58]} {tx_axis_mac_tdata[59]} {tx_axis_mac_tdata[60]} {tx_axis_mac_tdata[61]} {tx_axis_mac_tdata[62]} {tx_axis_mac_tdata[63]}]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe3]
set_property port_width 8 [get_debug_ports u_ila_1/probe3]
connect_debug_port u_ila_1/probe3 [get_nets [list {tx_axis_mac_tkeep[0]} {tx_axis_mac_tkeep[1]} {tx_axis_mac_tkeep[2]} {tx_axis_mac_tkeep[3]} {tx_axis_mac_tkeep[4]} {tx_axis_mac_tkeep[5]} {tx_axis_mac_tkeep[6]} {tx_axis_mac_tkeep[7]}]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe4]
set_property port_width 1 [get_debug_ports u_ila_1/probe4]
connect_debug_port u_ila_1/probe4 [get_nets [list rx_axis_mac_tlast]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe5]
set_property port_width 1 [get_debug_ports u_ila_1/probe5]
connect_debug_port u_ila_1/probe5 [get_nets [list rx_axis_mac_tuser]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe6]
set_property port_width 1 [get_debug_ports u_ila_1/probe6]
connect_debug_port u_ila_1/probe6 [get_nets [list rx_axis_mac_tvalid]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe7]
set_property port_width 1 [get_debug_ports u_ila_1/probe7]
connect_debug_port u_ila_1/probe7 [get_nets [list tx_axis_mac_tlast]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe8]
set_property port_width 1 [get_debug_ports u_ila_1/probe8]
connect_debug_port u_ila_1/probe8 [get_nets [list tx_axis_mac_tready]]
create_debug_port u_ila_1 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe9]
set_property port_width 1 [get_debug_ports u_ila_1/probe9]
connect_debug_port u_ila_1/probe9 [get_nets [list tx_axis_mac_tvalid]]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets coreclk_out_OBUF]
