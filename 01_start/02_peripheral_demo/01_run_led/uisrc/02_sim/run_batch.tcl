# ModelSim Batch Simulation Script for AI Analysis

# 1. Create and Map Library
if [file exists work] {
    file delete -force work
}
vlib work
vmap work work

# 2. Compile Design and Testbench
vlog -timescale 1ns/1ns -f compile.f

# 3. Load Simulation
# -c: command-line mode
# -do "...": execute commands
# "log -r /*": record all signals for later waveform viewing
vsim -c -voptargs="+acc" work.sim_top_tb -do "log -r /*; run -all; quit"
