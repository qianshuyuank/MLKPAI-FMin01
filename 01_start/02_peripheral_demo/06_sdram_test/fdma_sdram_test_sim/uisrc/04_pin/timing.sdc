create_clock -name clk_in -period 40 -waveform {0 20} [get_ports { clk_in }]
derive_pll_clocks
