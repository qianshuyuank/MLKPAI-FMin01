
/*******************************MILIANKE*******************************
*Company : MiLianKe Electronic Technology Co., Ltd.
*WebSite:https://www.milianke.com
*TechWeb:https://www.uisrc.com
*tmall-shop:https://milianke.tmall.com
*jd-shop:https://milianke.jd.com
*taobao-shop1: https://milianke.taobao.com
*Create Date: 2019/12/17
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
`timescale 1ns / 1ns//浠跨湡鏃堕棿鍒诲害/绮惧害

module uiuart_tx#
(
 parameter integer BAUD_DIV     = 10416                           //璁剧疆閲囨牱绯绘暟 锛堟椂閽?閲囨牱鐜?1锛?
)
(
    input        I_clk,//绯荤粺鏃堕挓杈撳叆
    input        I_uart_rstn,//绯荤粺澶嶄綅杈撳叆
    input        I_uart_wreq, //鍙戦€佹暟鎹姹?  
    input [7:0] I_uart_wdata, //鍙戦€佹暟鎹?     
    output      O_uart_wbusy,//鍙戦€佺姸鎬佸繖锛屼唬琛ㄦ鍦ㄥ彂閫佹暟鎹?  
    output      O_uart_tx//uart tx 鍙戦€佹€荤嚎
);

localparam  UART_LEN = 4'd10; //璁剧疆uart 鍙戦€佺殑bit鏁伴噺涓?0锛屼唬琛?bit璧峰浣嶏紝8bits鏁版嵁,1bit鍋滄浣?
wire        bps_en ; //鍙戦€佷娇鑳?
reg         uart_wreq_r   = 1'b0;//瀵勫瓨涓€娆_uart_wreq
reg         bps_start_en    = 1'b0; //娉㈢壒鐜囪鏁板櫒鍚姩浣胯兘锛屼篃鏄彂閫佸惎鍔ㄤ娇鑳?
reg [13:0]  baud_div        = 14'd0;//娉㈢壒鐜囪鏁板櫒
reg [9 :0]  uart_wdata_r  = 10'h3ff;//瀵勫瓨I_uart_wreq
reg [3 :0]  tx_cnt          = 4'd0;//璁℃暟鍙戦€佷簡澶氬皯bits

assign O_uart_tx = uart_wdata_r[0];//鎬荤嚎涓婄殑鏁版嵁锛屽缁堟槸uart_wdata_r[0]

assign O_uart_wbusy = bps_start_en;//鎬荤嚎蹇欐爣蹇楋紝鍗虫槸bps_start_en涓烘湁鏁堬紝鍗冲綋鎬荤嚎蹇欎簬鍙戦€侊紝鎬荤嚎蹇?

// 鍙戦€佷娇鑳?
assign bps_en = (baud_div == BAUD_DIV);                 //浜х敓涓€娆″彂閫佷娇鑳戒俊鍙凤紝鏉′欢鏄痓aud_div == BAUD_DIV锛屾尝鐗圭巼璁℃暟杈炬垚

//娉㈢壒鐜囪鏁板櫒
always@(posedge I_clk )begin
    if((I_uart_rstn== 1'b0) || (I_uart_wreq==1'b1&uart_wreq_r==1'b0))begin
        baud_div <= 14'd0;
    end
    else begin
        if(bps_start_en && baud_div < BAUD_DIV)        //bps_start_en鐨勪俊鍙锋媺楂橈紝琛ㄧず寮€濮嬪彂閫?
           baud_div <= baud_div + 1'b1;                //涓攂aud_div < BAUD_DIV娉㈢壒鐜囪绠楋紝鏈揪鍒版尝鐗圭巼baud_div+1
        else 
            baud_div <= 14'd0;                         //杈惧埌娓呴浂
    end
end

always@(posedge I_clk)begin
    uart_wreq_r <= I_uart_wreq;                           //瀵勫瓨涓€娆_uart_wreq淇″彿
end

//褰揑_uart_wreq浠庝綆鐢靛钩鍙樹负楂樼數骞筹紝鍚姩鍙戦€?
always@(posedge I_clk)begin
    if(I_uart_rstn == 1'b0)
        bps_start_en    <= 1'b0;                           //澶嶄綅锛岃鏁版竻闆?
    else if(I_uart_wreq==1'b1&uart_wreq_r==1'b0)          //I_uart_wreq涓婂崌娌挎縺娲?
        bps_start_en    <= 1'b1;                           //婵€娲诲悗灏?bps_start_en鎷夐珮锛屼紶杈撳紑濮?
    else if(tx_cnt == UART_LEN)                            //tx_cnt鐢ㄤ簬璁℃暟褰撳墠鍙戦€佺殑bits鏁伴噺锛屽綋杈惧埌棰勫畾鍊糢ART_LEN
        bps_start_en    <= 1'b0;                           //灏?bps_start_en鎷変綆锛屼紶杈撶粨鏉?
    else 
        bps_start_en    <= bps_start_en;                    
end

//鍙戦€乥its璁℃暟鍣?
always@(posedge I_clk)begin
    if(((I_uart_rstn== 1'b0) || (I_uart_wreq==1'b1&uart_wreq_r==1'b0))||(tx_cnt == 10))//褰撳浣嶃€佸惎鍔ㄥ彂閫併€佸彂閫佸畬鎴愶紝閲嶇疆tx_cnt
        tx_cnt <=4'd0;
    else if(bps_en && (tx_cnt < UART_LEN))   //tx_cnt璁℃暟鍣紝姣忓彂閫佷竴涓猙it鍔?
        tx_cnt <= tx_cnt + 1'b1;
end

//uart鍙戦€佸苟涓茬Щ浣嶆帶鍒跺櫒
always@(posedge I_clk)begin
    if((I_uart_wreq==1'b1&uart_wreq_r==1'b0)) //褰撳彂閫佽姹傛湁鏁堬紝瀵勫瓨闇€瑕佸彂閫佺殑鏁版嵁鍒皍art_wdata_r
        uart_wdata_r  <= {1'b1,I_uart_wdata[7:0],1'b0};//瀵勫瓨闇€瑕佸彂閫佺殑鏁版嵁锛屽寘鎷?bit 璧峰浣嶏紝8bits鏁版嵁锛?bit鍋滄浣?
    else if(bps_en && (tx_cnt < (UART_LEN - 1'b1)))                               //shift 9 bits
        uart_wdata_r <= {uart_wdata_r[0],uart_wdata_r[9:1]};                     //骞朵覆杞崲锛屽皢骞惰鏁版嵁渚濇浼犺緭
    else 
        uart_wdata_r <= uart_wdata_r;
end   
endmodule

