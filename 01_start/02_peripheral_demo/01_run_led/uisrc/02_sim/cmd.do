## part 1: create lib
if [file exists work] {
    file delete -force work
}
vlib work
vmap work work

## part 2: load rtl
vlog -timescale 1ps/1ps -f  compile.f                                                                     
                                                       
## part 3: sim
vsim -voptargs=+acc work.sim_top_tb                              

## part 4: add wave
#do wave.do

## part 5: show ui
view wave
view structure
view signals

## part 6: run sim
#run -all



