create_clock -name clk_in -period 40 -waveform {0 20} [get_ports {I_sys_clk}]
derive_pll_clocks
rename_clock -name {clk0} -source [get_pins {u_clk/pll_inst.refclk}] -master_clock {u_clk/pll_inst.refclk} [get_pins {u_clk/pll_inst.clkc[0]}]
rename_clock -name {clk2} -source [get_pins {u_clk/pll_inst.refclk}] -master_clock {u_clk/pll_inst.refclk} [get_pins {u_clk/pll_inst.clkc[2]}]
set_clock_groups -exclusive -group [get_clocks {clk0}] -group [get_clocks {clk2}] -group [get_clocks {clk_in}]