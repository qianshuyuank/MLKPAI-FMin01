/*******************************MILIANKE*******************************
*Company : MiLianKe Electronic Technology Co., Ltd.
*WebSite:https://www.milianke.com
*TechWeb:https://www.uisrc.com
*tmall-shop:https://milianke.tmall.com
*jd-shop:https://milianke.jd.com
*taobao-shop1: https://milianke.taobao.com
*Create Date: 2024/8/19
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

module uiuart_rx#
(
 parameter integer  BAUD_DIV     = 10416 
)
(
input I_clk,
input I_uart_rx_rstn,
input I_uart_rx,//uart rx 鎬荤嚎淇″彿杈撳叆
output [7:0] O_uart_rdata,//uart rx鎺ユ敹鍒扮殑鏁版嵁杈撳嚭
output O_uart_rvalid// uart rx 鎺ユ敹鏁版嵁鏈夋晥淇″彿,涓?鏃禣_uart_rdata鏁版嵁鏈夋晥
);

localparam  BAUD_DIV_SAMP = (BAUD_DIV/8)-1;//澶氭閲囨牱,鎸夌収娉㈢壒鐜囩郴鏁扮殑鍏垎涔嬩竴杩涜閲囨牱

wire bps_en       ; //娉㈢壒鐜囦娇鑳戒俊鍙?
wire samp_en      ;//閲囨牱浣胯兘淇″彿
wire bit_cap_done ; //uart rx鎬荤嚎淇″彿閲囨牱鏈夋晥鏁版嵁瀹屾垚
wire uarx_rx_done ;//uart 1byte 鎺ユ敹瀹屾垚
wire bit_data     ; //鎺ユ敹鐨?bit鏁版嵁
wire I_uart_rxnt  ;//I_uart_rx鐨勫惎鍔ㄤ俊鍙锋娴?褰撳彉涓轰綆鐢靛钩,浠ｈ〃鍙兘瀛樺湪璧峰浣?UART璧峰浣嶄负浣庣數骞?

reg [13:0]  baud_div = 14'd0;//娉㈢壒鐜囧垎棰戣鏁板櫒
reg [13:0]  samp_cnt = 14'd0;//閲囨牱璁℃暟鍣?
reg [4 :0]  I_uart_rx_r = 5'd0;//寮傛閲囬泦澶氭瀵勫瓨
reg [3 :0]  bit_cnt=4'd0;//bit 璁℃暟鍣?
reg [3 :0]  cap_cnt=4'd0;//cap 璁℃暟鍣?
reg [4 :0]  rx_bit_tmp = 5'd0;//rx_bit_tmp鐢ㄤ簬澶氭閲囨牱,閫氳繃璁＄畻閲囨牱鍒伴珮鐢靛钩娆℃暟鍜屼綆鐢靛钩娆℃暟,鍒ゆ柇鏈閲囨牱鏄珮鐢靛钩杩樻槸浣庣數骞?
reg [7 :0]  rx_data = 8'd0;//鏁版嵁鎺ユ敹瀵勫瓨鍣?

reg bps_start_en_r = 1'b0;
reg bit_cap_done_r = 1'b0;
reg bps_start_en,start_check_done,start_check_failed;

assign bps_en       =   (baud_div == (BAUD_DIV - 1'b1));//瀹屾垚涓€娆℃尝鐗圭巼浼犺緭淇″彿
assign samp_en      =   (samp_cnt == (BAUD_DIV_SAMP - 1'b1 ));//瀹屾垚涓€娆℃尝鐗圭巼閲囨牱淇″彿
assign bit_cap_done =   (cap_cnt  == 3'd7);//閲囨牱璁℃暟
assign uarx_rx_done =   (bit_cnt  == 9)&&(baud_div == BAUD_DIV >> 1);
//褰撳仠姝綅寮€濮?鎻愬墠浜屽垎涔嬩竴浣?鍙戦€乽art_rx_done淇″彿,浠ヤ究鎻愬墠鍑嗗杩涘叆涓嬩竴涓暟鎹殑鎺ユ敹
//received bits finished half the baud rate time earlier

assign bit_data     =   (rx_bit_tmp < 5'd15) ? 0 : 1;//rx_bit_tmp鐢ㄤ簬澶氭閲囨牱,閫氳繃璁＄畻閲囨牱鍒伴珮鐢靛钩娆℃暟鍜屼綆鐢靛钩娆℃暟,鍒ゆ柇鏈閲囨牱鏄珮鐢靛钩杩樻槸浣庣數骞?鎻愰珮鎶楀共鎵拌兘鍔?
//杩炵画5娆′俊鍙锋媺浣?鍒ゆ柇寮€濮嬩紶杈?
assign I_uart_rxnt  =   I_uart_rx_r[4] | I_uart_rx_r[3] | I_uart_rx_r[2] | I_uart_rx_r[1] | I_uart_rx_r[0];//鍒ゆ柇鏄惁鏈夎捣濮嬩綅

assign O_uart_rdata   =   rx_data;
assign O_uart_rvalid  =   uarx_rx_done;   

//娉㈢壒鐜囪鏁板櫒
always@(posedge I_clk)begin
    if(bps_start_en && baud_div < BAUD_DIV)	//baud_div璁℃暟,鐩爣鍊糂AUD_DIV
        baud_div <= baud_div + 1'b1;
    else 
        baud_div <= 14'd0;
end

//8bit閲囨牱浣胯兘,8鍊嶆尝鐗圭巼閲囨牱,涔熷氨鏄繖涓鏁板櫒,鐢ㄤ簬浜х敓8鍊嶈繃閲囨牱
always@(posedge I_clk)begin
    if(bps_start_en && samp_cnt < BAUD_DIV_SAMP)	 //bps_start_en楂樼數骞虫湁鏁?寮€濮嬪bit杩涜閲囨牱,samp_cnt浠?鍊嶄簬娉㈢壒鐜囬€熷害瀵规瘡涓猙it閲囨牱
        samp_cnt <= samp_cnt + 1'b1;//samp_cnt璁℃暟+1
    else 
        samp_cnt <= 14'd0; //samp_cnt璁℃暟娓呴浂
end

//uart rx bus asynchronous to Synchronous
always@(posedge I_clk)begin 
    I_uart_rx_r <= {I_uart_rx_r[3:0],I_uart_rx};//I_uart_rx鐨勬暟鎹瓨鍏_uart_rx_r杩涜缂撳瓨
end

//uart鎺ユ敹鍚姩妫€鏌?
always@(posedge I_clk)begin
    if(I_uart_rx_rstn == 1'b0 || uarx_rx_done || start_check_failed) 
        //bps_start_en鎷変綆鐨勪笁绉嶆儏鍐?澶嶄綅銆佹帴鏀跺畬鎴愩€佹牎楠屽け璐?
        bps_start_en    <= 1'b0;//鎺ユ敹缁撴潫
    else if((I_uart_rxnt == 1'b0)&(bps_start_en==1'b0))
        //褰撳垽鏂埌I_uart_rx == 1'b0,骞朵笖鎬荤嚎涔嬪墠绌洪棽(bps_start_en==1'b0,浠ｈ〃鎬荤嚎绌洪棽)
        bps_start_en    <= 1'b1;//浣胯兘娉㈢壒鐜囪鏁板櫒浣胯兘
end

//uart鎺ユ敹鍚姩浣胯兘
always@(posedge I_clk)begin
        bps_start_en_r <= bps_start_en;//bps_start_en淇″彿鎵撲竴鎷?鏂逛究鍚庣画涓婂崌娌挎崟鎹?
end

always@(posedge I_clk)begin
    if(I_uart_rx_rstn == 1'b0 || start_check_failed)begin
        //褰撶郴缁熷浣?鎴栬€卻tart_check_failed,閲嶇疆start_check_done鍜宻tart_check_failed
        start_check_done    <= 1'b0;
        start_check_failed  <= 1'b0;
    end    
    else if(bps_start_en == 1'b1&&bps_start_en_r == 1'b0) begin
        //褰撴娴嬪埌start淇″彿,涔熼噸缃畇tart_check_done鍜宻tart_check_failed
        start_check_done    <= 1'b0;
        start_check_failed  <= 1'b0;
    end
    else if((bit_cap_done&&bit_cap_done_r==1'b0)&&(start_check_done == 1'b0))begin
        //绗竴涓尝鐗圭巼閲囨牱,鐢ㄤ簬鍒ゆ柇鏄惁涓€涓湁鏁堢殑璧峰浣?濡傛灉涓嶆槸鏈夋晥鐨?start_check_failed璁剧疆涓?
        start_check_failed <= bit_data ? 1'b1 : 1'b0;
        start_check_done   <= 1'b1;
        //涓嶇鏄惁start_check_failed==1,閮戒細璁剧疆start_check_done=1,浣嗘槸start_check_failed==1,浼氫笅涓€涓郴缁熸椂閽熼噸缃畇tart_check_done=0
    end     
end

//bits 璁℃暟鍣?
always@(posedge I_clk)begin
    if(I_uart_rx_rstn == 1'b0 || uarx_rx_done || bps_start_en == 1'b0)
        bit_cnt   <= 4'd0;  
    else if(bps_en)
        bit_cnt <= bit_cnt + 1'b1;    
end

//8娆¤繃閲囨牱,鎻愰珮鎶楀共鎵?
always@(posedge I_clk)begin
    if(I_uart_rx_rstn == 1'b0 || bps_en == 1'b1 || bps_start_en == 1'b0) begin 
        //褰揑_uart_rx_rstn=0鎴栬€卋ps_en=1鎴栬€卋ps_start_en==0,閲嶇疆cap_cnt鍜宺x_bit_tmp
        cap_cnt     <= 4'd0;
        rx_bit_tmp  <= 5'd15; 
    end
    else if(samp_en)begin//bit閲囨牱浣胯兘
        cap_cnt     <= cap_cnt + 1'b1;//cap_cnt鐢ㄤ簬璁板綍浜嗗綋鍓嶆槸绗嚑娆¤繃閲囨牱,1涓猙it閲囨牱8娆?
        rx_bit_tmp  <= I_uart_rx_r[4] ? rx_bit_tmp + 1'b1 :  rx_bit_tmp - 1'b1;
        //澶氭閲囨牱,濡傛灉鏄珮鐢靛钩+1,濡傛灉鏄綆鐢靛钩-1,鏈€缁堢湅鏈bit閲囨牱缁撴潫rx_bit_tmp濡傛灉灏忎簬15浠ｈ〃鏄綆鐢靛钩
    end
end

//瀵勫瓨涓€娆it_cap_done,鐢ㄤ簬浜х敓楂樼數骞宠Е鍙戣剦鍐?
always@(posedge I_clk)
    bit_cap_done_r <= bit_cap_done;

//shift rx bit data
always@(posedge I_clk)begin
    if(I_uart_rx_rstn == 1'b0 || bps_start_en == 1'b0)
        rx_data  <= 8'd0;  //褰撳浣嶆垨鑰呮€荤嚎绌洪棽,閲嶇疆rx_data
    else if(start_check_done&&(bit_cap_done&&bit_cap_done_r==1'b0)&&bit_cnt < 9)
    //褰搒tart_check_done鏈夋晥,骞朵笖bit_cnt<9,姣忔bit_cap_done涓婂崌娌挎湁鏁?瀹屾垚涓€娆＄Щ浣嶅瘎瀛?
        rx_data  <= {bit_data,rx_data[7:1]}; //涓插苟杞崲,灏嗘暟鎹瓨鍏x_data 涓?鍏?浣?
end

endmodule

