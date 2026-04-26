
/*******************************MILIANKE*******************************
*Company : MiLianKe Electronic Technology Co., Ltd.
*WebSite:https://www.milianke.com
*TechWeb:https://www.uisrc.com
*tmall-shop:https://milianke.tmall.com
*jd-shop:https://milianke.jd.com
*taobao-shop1: https://milianke.taobao.com
*Create Date: 2021/10/15
*Module Name:ds1337
*File Name:ds1337.v
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
*3) IO_ input output
*4) S_ system internal signal
*5) _n activ low
*6) _dg debug signal 
*7) _r delay or register
*8) _s state mechine
*********************************************************************/

`timescale 1ns / 1ns//浠跨湡鏃堕棿鍒诲害/绮惧害

module rtc_clock_ds1337#
(
parameter SYSCLKHZ   =  25_000_000 //瀹氫箟绯荤粺鏃堕挓
)
(
input  wire I_sysclk, //绯荤粺鏃堕挓杈撳叆
output wire O_iic_scl,  //I2C鎬荤嚎锛孲CL鏃堕挓
inout  wire IO_iic_sda, //I2C鎬荤嚎锛孲DA鏁版嵁
output wire O_uart_tx   //UART涓茶鍙戦€佹€荤嚎
);

localparam T1000MS_CNT   =  (SYSCLKHZ-1); //瀹氫箟璁块棶RTC鐨勬椂闂撮棿闅斾负1000MS
localparam [7:0] RTC_DEV_ADDR =  8'b1101_0000;

reg [8 :0]  rst_cnt       = 9'd0;//涓婄數寤惰繜澶嶄綅
reg [29:0]  t_cnt = 30'd0;//瀹氭椂璁℃暟鍣?
wire t_en = (t_cnt==T1000MS_CNT);//瀹氭椂浣胯兘  

wire [23:0] wr_data;//鍐欐暟鎹俊鍙?
wire [23:0] rd_data;//璇绘暟鎹俊鍙?
wire        iic_busy;//I2C鎬荤嚎蹇?
reg  [7 :0] wr_cnt = 8'd0;//鍐欐暟鎹鏁板櫒
reg  [7 :0] rd_cnt = 8'd0;//璇绘暟鎹鏁板櫒
reg         iic_req = 1'b0;//i2c 鎺у埗鍣ㄨ姹備俊鍙?
reg  [2 :0] TS_S   = 3'd0;//鐘舵€佹満

reg  [7 :0] rtc_addr;//RTC鐨勫瘎瀛樺櫒鍦板潃
reg         wr_done = 1'b0; //鍐橰TC鍒濆€煎畬鎴愪俊鍙?
          
//鍒濆鍖栨椂闂寸殑BDC鐮侊紝12:00:00
wire [7 :0] WSecond = {4'd0,4'd0};//濡?
wire [7 :0] WMinute = {4'd0,4'd0};//鍒?
wire [7 :0] WHour   = {4'd1,4'd2};//鏃?
reg  [23:0] rtime   = 24'd0; //鐢ㄤ簬淇濆瓨璇诲彇鐨勬椂闂达紝鏍煎紡涓築CD鐮?

assign wr_data   = {WHour,WMinute,WSecond};//鍐欐暟鎹垵鍊?

//**********涓婄數寤惰繜澶嶄綅***************************/
always@(posedge I_sysclk) begin
    if(!rst_cnt[8]) 
        rst_cnt <= rst_cnt + 1'b1;
end

//**********500ms瀹氭椂璁℃暟鍣?*********************/
always@(posedge I_sysclk) begin
    if(t_cnt == T1000MS_CNT) 
        t_cnt <= 0;
    else 
        t_cnt <= t_cnt + 1'b1;
end

//璇诲啓RTC鏃堕挓鑺墖鐘舵€佹満
always@(posedge I_sysclk) begin
    if(!rst_cnt[8])begin//澶嶄綅鍒濆鍖栧瘎瀛樺櫒
        rtc_addr <= 8'd0;
        iic_req  <= 1'b0;
        wr_done  <= 1'b0;
        rd_cnt   <= 8'd0; 
        wr_cnt   <= 8'd0;
        TS_S     <= 2'd0;    
    end
    else begin
        case(TS_S)
        0:if(wr_done == 1'b0)begin//涓婄數鍚庯紝wr_done=0锛屽RTC鏃堕棿瀵勫瓨鍣ㄥ垵濮嬪寲锛岀粰瀹氬垵濮嬫椂闂?
            wr_done  <= 1'b1;//璁剧疆wr_done=1
            rtc_addr <= 8'd0;//璁剧疆闇€瑕佽闂殑瀵勫瓨鍣ㄨ捣濮嬪湴鍧€
            TS_S     <= 3'd1;//涓嬩竴涓姸鎬?
        end
        else begin //宸茬粡瀵筊TC鑺墖鍒濆鍖栧畬鎴?
            iic_req  <= 1'b0; //閲嶇疆 iic_req =0
            if(t_en)//姣忛棿闅?000ms杩涜涓€娆¤鎿嶄綔
            TS_S     <= 3'd3;//涓嬩竴涓姸鎬侊紝杩涘叆璇诲瘎鏃堕棿瀵勫瓨鍣ㄧ姸鎬佹満
        end
        1:if(!iic_busy)begin//褰撴€荤嚎闈炲繖锛屾墠鍙互鎿嶄綔I2C鎺у埗鍣?
            iic_req  <= 1'b1;//璇锋眰鎿嶄綔I2C鎺у埗鍣?
            rd_cnt   <= 8'd0;//鐢变簬鏈搷浣滄槸鍐欐暟鎹紝涓嶉渶瑕佽鏁版嵁锛岃鏁版嵁瀵勫瓨鍣ㄨ缃? 
            wr_cnt   <= 8'd5;//闇€瑕佸啓鍏? BYTES,鍖呮嫭1瀛楄妭鐨勫櫒浠跺湴鍧€锛?瀛楄妭鐨勫瘎瀛樺櫒璧峰鍦板潃锛?瀛楄妭鐨凚CD鏃堕棿鍙傛暟
            TS_S     <= 3'd2;//涓嬩竴涓姸鎬佹満
        end
        2:if(iic_busy)begin//绛夊緟鎬荤嚎蹇?
            iic_req  <= 1'b0;//閲嶇疆 iic_req =0
            TS_S     <= 3'd3;//涓嬩竴涓姸鎬佹満   
        end
        3:if(!iic_busy)begin//璇ョ姸鎬佽RTC鏃堕棿瀵勫瓨鍣?
            iic_req  <= 1'b1;//璇锋眰鎿嶄綔I2C鎺у埗鍣?
            rtc_addr <= 8'd0;//璇籖TC瀵勫瓨鍣ㄧ殑璧峰鍦板潃
            wr_cnt   <= 8'd2;//璇绘搷浣滈渶瑕佷簺1BYTE鍣ㄤ欢鍦板潃锛?BYTE 瀵勫瓨鍣ㄨ捣濮嬪湴鍧€
            rd_cnt   <= 8'd3;//璇诲彇3涓椂闂村瘎瀛樺櫒 
            TS_S     <= 3'd4;//涓嬩竴涓姸鎬?   
        end 
        4:if(iic_busy)begin//绛夊緟鎬荤嚎绌洪棽
            iic_req  <= 1'b0;//閲嶇疆 iic_req =0
            TS_S     <= 3'd0;//涓嬩竴涓姸鎬?   
        end   
        default: TS_S    <= 3'd0;//default鐘舵€佸洖鍒?
    endcase
   end
end

//***********淇濆瓨浠嶳TC璇诲彇鍒扮殑鏃堕棿瀵勫瓨鍣紝鏃堕棿涓築CD鏍煎紡***********//
always@(posedge I_sysclk) begin
    if(!rst_cnt[8])
        rtime <=0;
   else if(TS_S == 3)
        rtime[23: 0] <= rd_data;//璇诲彇鐨勬椂闂村寘鎷?鏃?鍒嗭細绉掞紝BCD鏍煎紡
end

//渚嬪寲I2C鎺у埗妯″潡
uii2c#
(
.WMEN_LEN(5),//鏈€澶ф敮鎸佷竴娆″啓鍏?BYTE(鍖呭惈鍣ㄤ欢鍦板潃)
.RMEN_LEN(3),//鏈€澶ф敮鎸佷竴娆¤鍑?BYTE
.CLK_DIV(SYSCLKHZ/100000)//100KHZ I2C鎬荤嚎鏃堕挓
)
uii2c_inst
(
.I_clk(I_sysclk),//绯荤粺鏃堕挓
.I_rstn(rst_cnt[8]),//绯荤粺澶嶄綅
.O_iic_scl(O_iic_scl),//I2C SCL鎬荤嚎鏃堕挓
.IO_iic_sda(IO_iic_sda),//I2C SDA鏁版嵁鎬荤嚎
.I_wr_data({wr_data,rtc_addr,RTC_DEV_ADDR}),//鍐欐暟鎹瘎瀛樺櫒
.I_wr_cnt(wr_cnt),//闇€瑕佸啓鐨勬暟鎹瓸YTES
.O_rd_data(rd_data), //璇绘暟鎹瘎瀛樺櫒
.I_rd_cnt(rd_cnt),//闇€瑕佽鐨勬暟鎹瓸YTES
.I_iic_req(iic_req),//I2C鎺у埗鍣ㄨ姹?
.I_iic_mode(1'b1),//璇绘ā寮?
.O_iic_busy(iic_busy)//I2C鎺у埗鍣ㄥ繖
//.iic_bus_error(iic_bus_error),//鎬荤嚎閿欒淇″彿鏍囧織
//.IO_iic_sda_dg(IO_iic_sda_dg)//debug IO_iic_sda
); 

//浠ヤ笅瀹屾垚BCD鐮佽禋ASCII鐮侊紝杩欐牱閫氳繃涓插彛鎵撳嵃鍙互鏂逛究瑙傚療
function signed[7:0] ascii ;   //瀹氫箟ascii鐮佽浆鎹㈠嚱鏁帮紝鍙渶瑕佽浆鎹CD鏁版嵁 
    
input[7:0] bcd; //杈撳叆鍙傛暟  

begin                                                    
    case(bcd)
    0 :     ascii   =   {8'h30};//ascii 鐮?  
    1 :     ascii   =   {8'h31};//ascii 鐮?      
    2 :     ascii   =   {8'h32};//ascii 鐮?  
    3 :     ascii   =   {8'h33};//ascii 鐮?
    4 :     ascii   =   {8'h34};//ascii 鐮?  
    5 :     ascii   =   {8'h35};//ascii 鐮?          
    6 :     ascii   =   {8'h36};//ascii 鐮?  
    7 :     ascii   =   {8'h37};//ascii 鐮?  
    8 :     ascii   =   {8'h38};//ascii 鐮?  
    9 :     ascii   =   {8'h39};//ascii 鐮?
    default:ascii   =   {8'h00};    
    endcase                                
end  
                                                    
endfunction   

//渚嬪寲UART鍙戦€佹ā鍧?
uart_tx_block u_uart_tx_block
(
.I_sysclk(I_sysclk),//绯荤粺鏃堕挓杈撳叆
.O_uart_tx(O_uart_tx),//UART 涓茶鎬荤嚎鏁版嵁鍙戦€?
//楂樹綅锛?'h0a,8'h0d锛屼负鍥炶溅+鎹㈣鎺у埗瀛楃
.I_uart_tx_buf({8'h0a,8'h0d,ascii(rtime[3:0]),ascii(rtime[7:4]),8'h2d,ascii(rtime[11:8]),ascii(rtime[15:12]),8'h2d,ascii(rtime[19:16]),ascii(rtime[23:20])}),
.I_uart_tx_buf_en(t_en)//t_en涔熸槸鍙戦€佷娇鑳?
);

endmodule
