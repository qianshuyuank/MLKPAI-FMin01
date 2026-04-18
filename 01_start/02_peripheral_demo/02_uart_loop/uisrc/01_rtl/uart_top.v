/*******************************MILIANKE*******************************
*Company : MiLianKe Electronic Technology Co., Ltd.
*WebSite:https://www.milianke.com
*TechWeb:https://www.uisrc.com
*tmall-shop:https://milianke.tmall.com
*jd-shop:https://milianke.jd.com
*taobao-shop1: https://milianke.taobao.com
*Create Date: 2024/8/19
*Module Name:uart_top
*File Name:uart_top.v
*Description: 
*The reference demo provided by Milianke is only used for learning. 
*We cannot ensure that the demo itself is free of bugs, so users 
*should be responsible for the technical problems and consequences
*caused by the use of their own products.
*Copyright: Copyright (c) MiLianKe
*All rights reserved.
*Revision: 1.0
*Signal description
*1) I_ input
*2) O_ output
*3) _n activ low
*4) _dg debug signal 
*5) _r delay or register
*6) _s state mechine
*********************************************************************/
`timescale 1ns / 1ns //仿真时钟刻度和精度

module uart_top
(
input I_sysclk,//系统时钟输入
input I_uart_rx,//uart rx接收信号
output O_uart_tx //uart tx发送信号
);

localparam SYSCLKHZ = 25_000_000; //系统输入时钟

reg [11:0] rstn_cnt = 0;//上电后延迟复位
wire uart_rstn;//内部复位信号
wire uart_wreq,uart_rvalid;
wire [7:0]uart_wdata,uart_rdata;

assign uart_wreq = uart_rvalid;//用uart rx接收数据有效的uart_rvalid信号,控制uart发送模块的发送请求
assign uart_wdata = uart_rdata; //接收的数据给发送模块发送
assign uart_rstn = rstn_cnt[11];//延迟复位设计,用计数器的高bit控制复位

//同步计数器实现复位
always @(posedge I_sysclk)begin
   if(rstn_cnt[11] == 1'b0)
     rstn_cnt <= rstn_cnt + 1'b1;
   else 
     rstn_cnt <= rstn_cnt;
end

//例化uart 发送模块
uiuart_tx#
(
.BAUD_DIV(SYSCLKHZ/115200-1)  
)
uart_tx_u 
(
.I_clk(I_sysclk),//系统时钟输入
.I_uart_rstn(uart_rstn), //系统复位
.I_uart_wreq(uart_wreq), //uart发送驱动的写请求信号,高电平有效
.I_uart_wdata(uart_wdata), //uart发送驱动的写数据
.O_uart_wbusy(),//uart 发送驱动的忙标志
.O_uart_tx(O_uart_tx)//uart 串行数据发送
);

//例化uart 接收
uiuart_rx#
(
.BAUD_DIV(SYSCLKHZ/115200-1)  
)
uiuart_rx_u 
(
.I_clk(I_sysclk), //系统时钟输入
.I_uart_rx_rstn(uart_rstn),//系统复位
.I_uart_rx(I_uart_rx), //uart 串行数据接收
.O_uart_rdata(uart_rdata), //uart 接收数据
.O_uart_rvalid(uart_rvalid)//uart 接收数据有效,O_uart_rvalid =1'b1 O_uart_rvalid输出的数据有效
);

endmodule