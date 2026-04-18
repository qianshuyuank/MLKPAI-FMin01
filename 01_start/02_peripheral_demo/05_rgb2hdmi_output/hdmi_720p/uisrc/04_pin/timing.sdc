
create_clock -name SYS_CLK -period 40 -waveform {0 20} [get_ports {I_sysclk}]