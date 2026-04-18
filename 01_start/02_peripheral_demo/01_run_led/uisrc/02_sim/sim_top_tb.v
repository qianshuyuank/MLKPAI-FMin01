/*******************************MILIANKE*******************************
*Company : MiLianKe Electronic Technology Co., Ltd.
*WebSite:https://www.milianke.com
*TechWeb:https://www.uisrc.com
*tmall-shop:https://milianke.tmall.com
*jd-shop:https://milianke.jd.com
*taobao-shop1: https://milianke.taobao.com
*Create Date: 2021/10/15
*Module Name:
*File Name:
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

`timescale 1ns / 1ns

module sim_top_tb();

reg I_sysclk,I_rstn;      //时钟信号以及复位信号
wire [7:0]  O_LED;        //仿真的LED 信号

run_led#
(
.T_INR_CNT_SET(1000)       //设置一个较小的时钟计数参数，可以大大缩小我们仿真需要的时间
)
run_led_inst(
 .I_sysclk(I_sysclk),      //例化时钟接口
 .I_rstn(I_rstn),          //例化复位接口
 .O_LED(O_LED)             //例化led接口
);

initial begin
   I_sysclk  <= 1'b0;     //时钟信号的寄存器设置初值
   I_rstn        <= 1'b0;     //复位信号的寄存器设置初值
   #100;                  //延时100个时间单位
   I_rstn        <= 1'b1;     //复位恢复高点平，模拟复位完成
end

always #20 I_sysclk=~I_sysclk;    //每过20个时钟周期，模拟的系统时钟信号进行一次翻转

endmodule
