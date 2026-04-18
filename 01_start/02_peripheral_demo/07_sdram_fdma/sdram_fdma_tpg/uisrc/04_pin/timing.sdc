 
create_clock -name sysclk -period 40 -waveform {0 20} [get_ports {I_sys_clk}]
derive_pll_clocks
rename_clock -name {pclk1} -source [get_pins {u_sdram_pll/pll_inst.clkc[4]}] -master_clock {clk4} [get_pins {hdmi_pll_inst/pll_inst.clkc[0]}]
rename_clock -name {pclk5} -source [get_pins {u_sdram_pll/pll_inst.clkc[4]}] -master_clock {clk4} [get_pins {hdmi_pll_inst/pll_inst.clkc[1]}]
rename_clock -name {clk0} -source [get_ports {I_sys_clk}] -master_clock {sysclk} [get_pins {u_sdram_pll/pll_inst.clkc[0]}]
rename_clock -name {clk1} -source [get_ports {I_sys_clk}] -master_clock {sysclk} [get_pins {u_sdram_pll/pll_inst.clkc[1]}]
rename_clock -name {clk2} -source [get_ports {I_sys_clk}] -master_clock {sysclk} [get_pins {u_sdram_pll/pll_inst.clkc[2]}]
rename_clock -name {clk3} -source [get_ports {I_sys_clk}] -master_clock {sysclk} [get_pins {u_sdram_pll/pll_inst.clkc[3]}]
rename_clock -name {clk4} -source [get_ports {I_sys_clk}] -master_clock {sysclk} [get_pins {u_sdram_pll/pll_inst.clkc[4]}]
set_clock_groups -exclusive -group [get_clocks {sysclk}] -group [get_clocks {clk0}] -group [get_clocks {clk1}] -group [get_clocks {clk2}] -group [get_clocks {clk3}] -group [get_clocks {clk4}] -group [get_clocks {pclk1}] -group [get_clocks {pclk5}]