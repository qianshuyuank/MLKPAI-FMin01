#Clock cycle period constraint
create_clock -period 40.000 -name sysclk [get_nets I_sysclk]

create_clock -period 10000.000 -name i2c_clk [get_nets uii2c_inst/scl_clk]
