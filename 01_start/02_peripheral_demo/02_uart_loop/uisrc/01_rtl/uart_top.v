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
`timescale 1ns / 1ns //浠跨湡鏃堕挓鍒诲害鍜岀簿搴?

module uart_top
(
input I_sysclk,//绯荤粺鏃堕挓杈撳叆
input I_uart_rx,//uart rx鎺ユ敹淇″彿
output O_uart_tx //uart tx鍙戦€佷俊鍙?
);

localparam SYSCLKHZ = 25_000_000; //绯荤粺杈撳叆鏃堕挓

reg [11:0] rstn_cnt = 0;//涓婄數鍚庡欢杩熷浣?
wire uart_rstn;//鍐呴儴澶嶄綅淇″彿
wire uart_wreq,uart_rvalid;
wire [7:0]uart_wdata,uart_rdata;

assign uart_wreq = uart_rvalid;//鐢╱art rx鎺ユ敹鏁版嵁鏈夋晥鐨剈art_rvalid淇″彿,鎺у埗uart鍙戦€佹ā鍧楃殑鍙戦€佽姹?
assign uart_wdata = uart_rdata; //鎺ユ敹鐨勬暟鎹粰鍙戦€佹ā鍧楀彂閫?
assign uart_rstn = rstn_cnt[11];//寤惰繜澶嶄綅璁捐,鐢ㄨ鏁板櫒鐨勯珮bit鎺у埗澶嶄綅

//鍚屾璁℃暟鍣ㄥ疄鐜板浣?
always @(posedge I_sysclk)begin
   if(rstn_cnt[11] == 1'b0)
     rstn_cnt <= rstn_cnt + 1'b1;
   else 
     rstn_cnt <= rstn_cnt;
end

//渚嬪寲uart 鍙戦€佹ā鍧?
uiuart_tx#
(
.BAUD_DIV(SYSCLKHZ/115200-1)  
)
uart_tx_u 
(
.I_clk(I_sysclk),//绯荤粺鏃堕挓杈撳叆
.I_uart_rstn(uart_rstn), //绯荤粺澶嶄綅
.I_uart_wreq(uart_wreq), //uart鍙戦€侀┍鍔ㄧ殑鍐欒姹備俊鍙?楂樼數骞虫湁鏁?
.I_uart_wdata(uart_wdata), //uart鍙戦€侀┍鍔ㄧ殑鍐欐暟鎹?
.O_uart_wbusy(),//uart 鍙戦€侀┍鍔ㄧ殑蹇欐爣蹇?
.O_uart_tx(O_uart_tx)//uart 涓茶鏁版嵁鍙戦€?
);

//渚嬪寲uart 鎺ユ敹
uiuart_rx#
(
.BAUD_DIV(SYSCLKHZ/115200-1)  
)
uiuart_rx_u 
(
.I_clk(I_sysclk), //绯荤粺鏃堕挓杈撳叆
.I_uart_rx_rstn(uart_rstn),//绯荤粺澶嶄綅
.I_uart_rx(I_uart_rx), //uart 涓茶鏁版嵁鎺ユ敹
.O_uart_rdata(uart_rdata), //uart 鎺ユ敹鏁版嵁
.O_uart_rvalid(uart_rvalid)//uart 鎺ユ敹鏁版嵁鏈夋晥,O_uart_rvalid =1'b1 O_uart_rvalid杈撳嚭鐨勬暟鎹湁鏁?
);

endmodule
