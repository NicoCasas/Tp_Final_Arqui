## This file is a general .xdc for the Basys3 rev B board
## To use it in a project:
## - uncomment the lines corresponding to used pins
## - rename the used ports (in each line, after get_ports) according to the top level signal names in the project

# Pal warning
#https://docs.xilinx.com/r/en-US/ug912-vivado-properties/CFGBVS
set_property CFGBVS VCCO [current_design]
#https://docs.xilinx.com/r/en-US/ug912-vivado-properties/CONFIG_VOLTAGE
set_property CONFIG_VOLTAGE 3.3 [current_design]

# Clock signal
set_property PACKAGE_PIN W5 [get_ports i_clk]							
	set_property IOSTANDARD LVCMOS33 [get_ports i_clk]
	create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports i_clk]

#USB-RS232 Interface
set_property PACKAGE_PIN B18 [get_ports i_rx]						
	set_property IOSTANDARD LVCMOS33 [get_ports i_rx]
set_property PACKAGE_PIN A18 [get_ports o_tx]						
	set_property IOSTANDARD LVCMOS33 [get_ports o_tx]

# Switches
#set_property PACKAGE_PIN V17 [get_ports i_reset]					
#	set_property IOSTANDARD LVCMOS33 [get_ports i_reset]
#set_property PACKAGE_PIN V16 [get_ports i_clk_reset]					
#	set_property IOSTANDARD LVCMOS33 [get_ports i_clk_reset]
#set_property PACKAGE_PIN W16 [get_ports {sw[2]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {sw[2]}]
#set_property PACKAGE_PIN W17 [get_ports {sw[3]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {sw[3]}]
#set_property PACKAGE_PIN W15 [get_ports {sw[4]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {sw[4]}]
#set_property PACKAGE_PIN V15 [get_ports {sw[5]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {sw[5]}]
#set_property PACKAGE_PIN W14 [get_ports {sw[6]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {sw[6]}]
#set_property PACKAGE_PIN W13 [get_ports {sw[7]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {sw[7]}]
#set_property PACKAGE_PIN V2 [get_ports {sw[8]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {sw[8]}]
#set_property PACKAGE_PIN T3 [get_ports {sw[9]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {sw[9]}]
#set_property PACKAGE_PIN T2 [get_ports {sw[10]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {sw[10]}]
#set_property PACKAGE_PIN R3 [get_ports {sw[11]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {sw[11]}]
#set_property PACKAGE_PIN W2 [get_ports {sw[12]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {sw[12]}]
#set_property PACKAGE_PIN U1 [get_ports {sw[13]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {sw[13]}]
#set_property PACKAGE_PIN T1 [get_ports {sw[14]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {sw[14]}]
#set_property PACKAGE_PIN R2 [get_ports {sw[15]}]					
	#set_property IOSTANDARD LVCMOS33 [get_ports {sw[15]}]
 

# LEDs
#set_property PACKAGE_PIN U16 [get_ports {o_wb_reg_w_data[0]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {o_wb_reg_w_data[0]}]
#set_property PACKAGE_PIN E19 [get_ports {o_wb_reg_w_data[1]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {o_wb_reg_w_data[1]}]
#set_property PACKAGE_PIN U19 [get_ports {o_wb_reg_w_data[2]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {o_wb_reg_w_data[2]}]
#set_property PACKAGE_PIN V19 [get_ports {o_wb_reg_w_data[3]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {o_wb_reg_w_data[3]}]
#set_property PACKAGE_PIN W18 [get_ports {o_wb_reg_w_data[4]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {o_wb_reg_w_data[4]}]
#set_property PACKAGE_PIN U15 [get_ports {o_wb_reg_w_data[5]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {o_wb_reg_w_data[5]}]
#set_property PACKAGE_PIN U14 [get_ports {o_wb_reg_w_data[6]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {o_wb_reg_w_data[6]}]
#set_property PACKAGE_PIN V14 [get_ports {o_wb_reg_w_data[7]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {o_wb_reg_w_data[7]}]
#set_property PACKAGE_PIN V13 [get_ports {o_wb_reg_w_data[8]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {o_wb_reg_w_data[8]}]
#set_property PACKAGE_PIN V3 [get_ports {o_wb_reg_w_data[9]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {o_wb_reg_w_data[9]}]
#set_property PACKAGE_PIN W3 [get_ports {o_wb_reg_w_data[10]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {o_wb_reg_w_data[10]}]
#set_property PACKAGE_PIN U3 [get_ports {o_wb_reg_w_data[11]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {o_wb_reg_w_data[11]}]
#set_property PACKAGE_PIN P3 [get_ports {o_wb_reg_w_data[12]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {o_wb_reg_w_data[12]}]
#set_property PACKAGE_PIN N3 [get_ports {o_wb_reg_w_data[13]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {o_wb_reg_w_data[13]}]
#set_property PACKAGE_PIN P1 [get_ports {o_wb_reg_w_data[14]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {o_wb_reg_w_data[14]}]
#set_property PACKAGE_PIN L1 [get_ports {o_wb_reg_w_data[15]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {o_wb_reg_w_data[15]}]
	
	
#7 segment display
#set_property PACKAGE_PIN W7 [get_ports {o_wb_reg_w_data[16]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {o_wb_reg_w_data[16]}]
#set_property PACKAGE_PIN W6 [get_ports {o_wb_reg_w_data[17]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {o_wb_reg_w_data[17]}]
#set_property PACKAGE_PIN U8 [get_ports {o_wb_reg_w_data[18]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {o_wb_reg_w_data[18]}]
#set_property PACKAGE_PIN V8 [get_ports {o_wb_reg_w_data[19]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {o_wb_reg_w_data[19]}]
#set_property PACKAGE_PIN U5 [get_ports {o_wb_reg_w_data[20]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {o_wb_reg_w_data[20]}]
#set_property PACKAGE_PIN V5 [get_ports {o_wb_reg_w_data[21]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {o_wb_reg_w_data[21]}]
#set_property PACKAGE_PIN U7 [get_ports {o_wb_reg_w_data[22]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {o_wb_reg_w_data[22]}]

#set_property PACKAGE_PIN V7 [get_ports dp]							
#	set_property IOSTANDARD LVCMOS33 [get_ports dp]

#set_property PACKAGE_PIN U2 [get_ports {an[0]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {an[0]}]
#set_property PACKAGE_PIN U4 [get_ports {an[1]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {an[1]}]
#set_property PACKAGE_PIN V4 [get_ports {an[2]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {an[2]}]
#set_property PACKAGE_PIN W4 [get_ports {an[3]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {an[3]}]


##Buttons
set_property PACKAGE_PIN U17 [get_ports i_reset]						
	set_property IOSTANDARD LVCMOS33 [get_ports i_reset]
#set_property PACKAGE_PIN T18 [get_ports btnU]						
	#set_property IOSTANDARD LVCMOS33 [get_ports btnU]
#set_property PACKAGE_PIN W19 [get_ports btnL]						
	#set_property IOSTANDARD LVCMOS33 [get_ports btnL]
#set_property PACKAGE_PIN T17 [get_ports btnR]						
	#set_property IOSTANDARD LVCMOS33 [get_ports btnR]
#set_property PACKAGE_PIN U18 [get_ports btnD]						
	#set_property IOSTANDARD LVCMOS33 [get_ports btnD]



##USB HID (PS/2)
#set_property PACKAGE_PIN C17 [get_ports PS2Clk]						
	#set_property IOSTANDARD LVCMOS33 [get_ports PS2Clk]
	#set_property PULLUP true [get_ports PS2Clk]
#set_property PACKAGE_PIN B17 [get_ports PS2Data]					
	#set_property IOSTANDARD LVCMOS33 [get_ports PS2Data]	
	#set_property PULLUP true [get_ports PS2Data]


