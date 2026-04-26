
/*******************************MILIANKE*******************************
*Company : MiLianKe Electronic Technology Co., Ltd.
*WebSite:https://www.milianke.com
*TechWeb:https://www.uisrc.com
*tmall-shop:https://milianke.tmall.com
*jd-shop:https://milianke.jd.com
*taobao-shop1: https://milianke.taobao.com
*Create Date: 2024/08/20
*Module Name:uii2c
*File Name:uii2c.v
*Description: 
*The reference demo provided by Milianke is only used for learning. 
*We cannot ensure that the demo itself is free of bugs, so users 
*should be responsible for the technical problems and consequences
*caused by the use of their own products.
*Copyright: Copyright (c) MiLianKe
*All rights reserved.
*Revision: 1.1
*Signal description
*1) I_ input
*2) O_ output
*3) IO_ input output
*4) S_ system internal signal
*5) _n activ low
*6) _dg debug signal 
*7) _r delay or register
*8) _s state mechine
*********************************************************************/

`timescale 1ns / 1ns//浠跨湡鏃堕棿闂撮殧/绮惧害

module eeprom_test#
(
parameter SYSCLKHZ     =  25_000_000 //瀹氫箟绯荤粺鏃堕挓25MHZ
)
(
input  wire I_sysclk,//绯荤粺鏃堕挓杈撳叆
output wire O_iic_scl,// I2C SCL鏃堕挓
inout  wire IO_iic_sda,//I2C SDA鏁版嵁鎬荤嚎
output wire [2:0]O_test_led,//娴嬭瘯LED
output wire O_error_led //error LED
);
  
localparam T500MS_CNT   = (SYSCLKHZ/2-1); //瀹氫箟姣?00ms璁块棶涓€娆EPROM 

reg [8 :0]  rst_cnt      = 9'd0;//寤惰繜澶嶄綅璁℃暟鍣?
reg [25:0]  t500ms_cnt   = 26'd0;//500ms璁℃暟鍣?
reg [19:0]  delay_cnt    = 20'd0;//eeprom姣忔璇诲啓瀹屽悗锛屽欢杩熸搷浣滆鏁板櫒
reg [2 :0]  TS_S         = 3'd0; // 璇诲啓EEPROM鐘舵€佹満
reg         iic_req      = 1'b0; //i2c鎬荤嚎锛岃/鍐欒姹備俊鍙?
reg [31:0]  wr_data      = 32'd0;//鍐欐暟鎹瘎瀛樺櫒
reg [7 :0]  wr_cnt       = 8'd0;//鍐欐暟鎹鏁板櫒
reg [7 :0]  rd_cnt       = 8'd0;//璇绘暟鎹鏁板櫒
wire        iic_busy; // i2c鎬荤嚎蹇欎俊鍙锋爣蹇?
wire [31:0] rd_data;  // i2c璇绘暟鎹?
wire        t500ms_en;// 500ms寤惰繜鍒颁娇鑳?

wire IO_iic_sda_dg;
wire iic_bus_error;  //i2c鎬荤嚎閿欒
reg iic_error = 1'b0; //i2c 璇诲嚭鏁版嵁鏈夐敊璇?
assign O_test_led  = ~rd_data[2:0];//娴嬭瘯LED杈撳嚭,娉ㄦ剰纭欢涓奓ED椹卞姩鏂瑰紡
assign O_error_led = ~iic_error;//閫氳繃LED鏄剧ず閿欒鏍囧織,娉ㄦ剰纭欢涓奓ED椹卞姩鏂瑰紡
assign t500ms_en = (t500ms_cnt==T500MS_CNT);//500ms 浣胯兘淇″彿
                
//閫氳繃鍐呴儴璁℃暟鍣ㄥ疄鐜板浣?
always@(posedge I_sysclk) begin
    if(!rst_cnt[8]) 
        rst_cnt <= rst_cnt + 1'b1;
end

//I2C鎬荤嚎寤惰繜闂撮殧鎿嶄綔,璇ユ椂闂寸害涓嶈兘浣庝簬500us,鍚﹀垯浼氬鑷碋EPROM鎿嶄綔澶辫触
always@(posedge I_sysclk) begin
    if(!rst_cnt[8])
        delay_cnt <= 0;
    else if((TS_S == 3'd0 || TS_S == 3'd2 )) 
        delay_cnt <= delay_cnt + 1'b1;
    else 
        delay_cnt <= 0;
end

//姣忛棿闅?00ms鐘舵€佹満杩愯涓€娆?
always@(posedge I_sysclk) begin
    if(!rst_cnt[8])
        t500ms_cnt <= 0;
    else if(t500ms_cnt == T500MS_CNT) 
        t500ms_cnt <= 0;
    else 
        t500ms_cnt <= t500ms_cnt + 1'b1;
end

//鐘舵€佹満瀹炵幇姣忔鍐?瀛楄妭鍒癊EPROM鐒跺悗鍐嶈1瀛楄妭
always@(posedge I_sysclk) begin
    if(!rst_cnt[8])begin
        iic_req   <= 1'b0;
        wr_data   <= 32'd0;
        rd_cnt    <= 8'd0; 
        wr_cnt    <= 8'd0;
        iic_error <= 1'b0;
        TS_S      <= 3'd0;    
    end
    else begin
        case(TS_S)
        0:if(!iic_busy)begin//褰撴€荤嚎闈炲繖锛屽彲浠ュ紑濮嬩竴娆2C鏁版嵁鎿嶄綔
            iic_req <= 1'b1;//璇锋眰鍙戦€佹暟鎹?
            wr_data <= {8'hfe,wr_data[15:8],wr_data[15:8],8'b10100000};//鏁版嵁瀵勫瓨鍣ㄤ腑8'b10100000浠ｈ〃闇€瑕佸啓鐨勫櫒浠跺湴鍧€锛岀涓€涓獁r_data[15:8]浠ｈ〃浜咵EPROM鍐呭瓨鍦板潃锛岀浜屼釜wr_data[15:8]浠ｈ〃浜嗗啓鍏ユ暟鎹?
            rd_cnt  <= 8'd0; //涓嶉渶瑕佽鏁版嵁
            wr_cnt  <= 8'd3; //闇€瑕佸啓鍏?涓狟YTES鏁版嵁锛屽寘鍚?涓櫒浠跺湴鍧€锛?涓狤EPROM 瀵勫瓨鍣ㄥ湴鍧€ 1涓暟鎹?  
            TS_S     <= 3'd1;//杩涘叆涓嬩竴涓姸鎬?     
        end
        1:if(iic_busy)begin 
            iic_req  <= 1'b0; //閲嶇疆iic_req=0
            TS_S     <= 3'd2;
        end
        2:if(!iic_busy&&delay_cnt[19])begin //褰撴€荤嚎闈炲繖锛屽彲浠ュ紑濮嬩竴娆2C鏁版嵁鎿嶄綔锛岃鏃堕棿绾︿笉鑳戒綆浜?00us,鍚﹀垯浼氬鑷碋EPROM鎿嶄綔澶辫触
            iic_req  <= 1'b1;//璇锋眰鎺ユ敹鏁版嵁
            rd_cnt  <= 8'd1; //闇€瑕佽1涓狟YTE
            wr_cnt  <= 8'd2; //闇€瑕佷簺2涓狟YTE(1涓櫒浠跺湴鍧€8'b10100000锛屽拰1涓瘎瀛樺櫒鍦板潃wr_data[15:8])(I2C鎺у埗鍣ㄤ細鑷畾璁剧疆璇诲啓鏍囧織浣?
            TS_S    <= 3'd3;  //杩涘叆涓嬩竴涓姸鎬?
        end     
        3:if(iic_busy)begin 
            iic_req  <= 1'b0; //閲嶇疆iic_req=0
            TS_S     <= 3'd4;
        end    
        4:if(!iic_busy)begin//褰撴€荤嚎闈炲繖锛屼唬琛ㄥ墠闈㈣鏁版嵁瀹屾垚
            if(wr_data[23:16] != rd_data[7:0])//姣斿鏁版嵁鏄惁姝ｇ‘
                iic_error <= 1'b1;//濡傛灉鏈夐敊璇紝璁剧疆iic_error=1
            else 
                iic_error <= 1'b0;//濡傛灉娌℃湁閿欒锛岃缃甶ic_error=0
                wr_data[15:8] <= wr_data[15:8] + 1'b1;//wr_data[15:8]+1 鍦板潃鍜屾暟鎹兘鍔?
            TS_S    <= 3'd5;
        end
        5:if(t500ms_en)begin//寤惰繜鎿嶄綔鍚庤繘鍏ヤ笅涓€涓姸鎬?
            TS_S    <= 3'd0; 
        end 
        default:
            TS_S    <= 3'd0;
    endcase
   end
end

//渚嬪寲I2C鎺у埗妯″潡
uii2c#
(
.WMEN_LEN(4),//鏈€澶ф敮鎸佷竴娆″啓鍏?BYTE(鍖呭惈鍣ㄤ欢鍦板潃)
.RMEN_LEN(4),//鏈€澶ф敮鎸佷竴娆¤鍑?BYTE(鍖呭惈鍣ㄤ欢鍦板潃)
.CLK_DIV(124)//100KHZ I2C鎬荤嚎鏃堕挓
)
uii2c_inst
(
.I_clk(I_sysclk),//绯荤粺鏃堕挓
.I_rstn(rst_cnt[8]),//绯荤粺澶嶄綅
.O_iic_scl(O_iic_scl),//I2C SCL鎬荤嚎鏃堕挓
.IO_iic_sda(IO_iic_sda),//I2C SDA鏁版嵁鎬荤嚎
.I_wr_data(wr_data),//鍐欐暟鎹瘎瀛樺櫒
.I_wr_cnt(wr_cnt),//闇€瑕佸啓鐨勬暟鎹瓸YTES
.O_rd_data(rd_data), //璇绘暟鎹瘎瀛樺櫒
.I_rd_cnt(rd_cnt),//闇€瑕佽鐨勬暟鎹瓸YTES
.I_iic_req(iic_req),//I2C鎺у埗鍣ㄨ姹?
.I_iic_mode(1'b1),//璇绘ā寮?
.O_iic_busy(iic_busy),//I2C鎺у埗鍣ㄥ繖
.O_iic_bus_error(iic_bus_error)//鎬荤嚎閿欒淇″彿鏍囧織
//.IO_iic_sda_dg(IO_iic_sda_dg)//debug IO_iic_sda
); 

endmodule
