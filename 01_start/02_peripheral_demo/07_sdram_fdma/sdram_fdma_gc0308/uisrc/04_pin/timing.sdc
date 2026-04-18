create_clock -name SYS_CLK -period 40 -waveform {0 20} [get_ports {I_sysclk}]
 
derive_pll_clocks
 
rename_clock -name {pll_clk0} -source [get_ports {I_sysclk}] -master_clock {SYS_CLK} [get_pins {u_pll/pll_inst.clkc[0]}]
rename_clock -name {pll_clk1} -source [get_ports {I_sysclk}] -master_clock {SYS_CLK} [get_pins {u_pll/pll_inst.clkc[1]}]
rename_clock -name {pll_clk2} -source [get_ports {I_sysclk}] -master_clock {SYS_CLK} [get_pins {u_pll/pll_inst.clkc[2]}]
rename_clock -name {pll_clk3} -source [get_ports {I_sysclk}] -master_clock {SYS_CLK} [get_pins {u_pll/pll_inst.clkc[3]}]
rename_clock -name {hdmi_pll_clk0} -source [get_pins {u_pll/pll_inst.clkc[0]}] -master_clock {pll_clk0} [get_pins {hdmi_pll_inst/pll_inst.clkc[0]}]
rename_clock -name {hdmi_pll_clk1} -source [get_pins {u_pll/pll_inst.clkc[0]}] -master_clock {pll_clk0} [get_pins {hdmi_pll_inst/pll_inst.clkc[1]}]
 
set_clock_groups -exclusive -group [get_clocks {pll_clk0}] -group [get_clocks {pll_clk1}] -group [get_clocks {pll_clk2}] -group [get_clocks {pll_clk3}] -group [get_clocks {hdmi_pll_clk0}] -group [get_clocks {hdmi_pll_clk1}] -group [get_clocks {SYS_CLK}]

#create_clock -name cam_clk -period 40 -waveform {0 20} [get_ports {I_cmos_pclk}]
#create_clock -name hdmi_clk -period 8 -waveform {0 4} [get_ports {O_HDMI_CLK_P}]
#create_clock -name cmos_xclk -period 40 -waveform {0 20} [get_ports {O_cmos_xclk}]
