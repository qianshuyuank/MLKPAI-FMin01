
/*******************************MILIANKE*******************************
*Company : MiLianKe Electronic Technology Co., Ltd.
*WebSite:https://www.milianke.com
*TechWeb:https://www.uisrc.com
*tmall-shop:https://milianke.tmall.com
*jd-shop:https://milianke.jd.com
*taobao-shop1: https://milianke.taobao.com
*Create Date: 2024/8/16
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
*1) I_ input
*2) O_ output
*3) _n activ low
*4) _dg debug signal 
*5) _r delay or register
*6) _s state mechine
*********************************************************************/
`timescale 1ns / 1ns

module uiuart_tx#
(
 parameter integer BAUD_DIV     = 216 //璁剧疆閲囨牱绯绘暟(鏃堕挓/閲囨牱鐜?1),渚夸簬澶栭儴淇敼
)
(
	input       I_clk,
    input       I_uart_rstn,
	input       I_uart_wreq,//鍙戦€佹暟鎹姹?
    input [7:0] I_uart_wdata,//鍙戦€佹暟鎹?
    output      O_uart_wbusy,//鍙戦€佺姸鎬佸繖,鍗虫槸鍚︽鍦ㄥ彂閫佹暟鎹?
	output      O_uart_tx//鍙戦€佹€荤嚎
);

localparam UART_LEN = 4'd10;//璁剧疆uart鍙戦€佺殑bit鏁伴噺涓?0,浠ｈ〃1bit璧峰浣?8bits鏁版嵁,1bit鍋滄浣?
wire        bps_en ;//鍙戦€佷娇鑳?
reg         uart_wreq_r   = 1'b0;//瀵勫瓨涓€娆″彂閫佹暟鎹姹?
reg         bps_start_en    = 1'b0;//娉㈢壒鐜囪鏁板櫒鍚姩浣胯兘锛屼篃鏄彂閫佸惎鍔ㄤ娇鑳?
reg [13:0]  baud_div        = 14'd0;//娉㈢壒鐜囪鏁板櫒
reg [9 :0]  uart_wdata_r  = 10'h3ff;//瀵勫瓨10bit鏁版嵁(1+8+1)
reg [3 :0]  tx_cnt          = 4'd0;//璁℃暟宸茬粡鍙戦€佸嚭澶氬皯浣嶆暟鎹?

assign O_uart_tx = uart_wdata_r[0];//浠庝綆浣嶅紑濮嬭緭鍑?涓旀€荤嚎涓婄殑鏁版嵁濮嬬粓涓簎art_wdata_r[0]

assign O_uart_wbusy = bps_start_en;//鍙戦€佸惎鍔ㄤ娇鑳芥湁鏁堟椂,澶勪簬鍙戦€佸繖鐘舵€?

// uart tx Baud rate divider
assign bps_en = (baud_div == BAUD_DIV);//浜х敓涓€娆″彂閫佷娇鑳戒俊鍙?鏉′欢鏄痓aud_div == BAUD_DIV,娉㈢壒鐜囪鏁拌揪鎴?

//娉㈢壒鐜囪鏁板櫒
always@(posedge I_clk )begin
    if((I_uart_rstn== 1'b0) || (I_uart_wreq==1'b1&uart_wreq_r==1'b0))begin
        baud_div <= 14'd0;
    end
    else begin
        if(bps_start_en && baud_div < BAUD_DIV)//鍙戦€佷娇鑳戒负1鏃?杩涜娉㈢壒鐜囪鏁?
            baud_div <= baud_div + 1'b1;
        else 
            baud_div <= 14'd0;
    end
end

always@(posedge I_clk)begin
    uart_wreq_r <= I_uart_wreq;//瀵勫瓨涓€娆″彂閫佽姹?
end

//UART transmit enable ,Support gapless continuous enable
always@(posedge I_clk)begin
    if(I_uart_rstn == 1'b0)
        bps_start_en    <= 1'b0;
    else if(I_uart_wreq==1'b1&uart_wreq_r==1'b0) 
        bps_start_en    <= 1'b1;
    else if(tx_cnt == UART_LEN)
        bps_start_en    <= 1'b0;
    else 
        bps_start_en    <= bps_start_en;
end

//UART transmiter BIT counter
always@(posedge I_clk)begin
    if(((I_uart_rstn== 1'b0) || (I_uart_wreq==1'b1&uart_wreq_r==1'b0))||(tx_cnt == 10))
        tx_cnt <=4'd0;//澶嶄綅銆佸惎鍔ㄥ彂閫併€佸彂閫佸畬鎴?閲嶇疆tx_cnt
    else if(bps_en && (tx_cnt < UART_LEN))
        tx_cnt <= tx_cnt + 1'b1;//tx_cnt璁℃暟鍣?姣忓彂閫佷竴涓猙it鍔?
end

//uart send controller shift control
always@(posedge I_clk)begin
    if((I_uart_wreq==1'b1&uart_wreq_r==1'b0)) 
        //瀵勫瓨闇€瑕佸彂閫佺殑鏁版嵁,鍖呮嫭1bit璧峰浣?8bits鏁版嵁,1bit鍋滄浣?
        uart_wdata_r  <= {1'b1,I_uart_wdata[7:0],1'b0};
    else if(bps_en && (tx_cnt < (UART_LEN - 1'b1)))//shift 9 bits
        //骞朵覆杞崲锛屽皢骞惰鏁版嵁渚濇浼犺緭
        uart_wdata_r <= {uart_wdata_r[0],uart_wdata_r[9:1]};
    else 
        uart_wdata_r <= uart_wdata_r;

end   

endmodule
