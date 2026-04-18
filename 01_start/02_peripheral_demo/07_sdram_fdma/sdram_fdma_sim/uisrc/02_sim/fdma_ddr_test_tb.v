`timescale 1ns / 1ps
/*******************************MILIANKE*******************************
*Company : MiLianKe Electronic Technology Co., Ltd.
*WebSite:https://www.milianke.com
*TechWeb:https://www.uisrc.com
*tmall-shop:https://milianke.tmall.com
*jd-shop:https://milianke.jd.com
*taobao-shop1: https://milianke.taobao.com
*Create Date: 2021/04/25
*Module Name:fdma_bram_test_tb
*File Name:fdma_bram_test_tb.v
*Description: 
*The reference demo provided by Milianke is only used for learning. 
*We cannot ensure that the demo itself is free of bugs, so users 
*should be responsible for the technical problems and consequences
*caused by the use of their own products.
*Copyright: Copyright (c) MiLianKe
*All rights reserved.
*Revision: 1.0
*Signal description
*1) _i input
*2) _o output
*3) _n activ low
*4) _dg debug signal 
*5) _r delay or register
*6) _s state mechine
*********************************************************************/
`timescale 1ns / 1ps
module fdma_ddr_test_tb(
);


 reg sysclk;
 reg rst_n;

 cam_test cam_test_inst
(
    .sysclk_i(sysclk),
    .sysrst_i(rst_n)
 );
 
initial begin
     sysclk  = 0;
     rst_n   = 0;
     #100;
     rst_n   = 1;
     
end

    always #20 sysclk = ~sysclk;   

glbl glbl();

endmodule

