
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

`timescale 1ns / 1ns //浠跨湡鍒诲害/绮惧害

module uii2c#
(
parameter integer WMEN_LEN = 8'd0,//鍐欓暱搴︼紝浠ュ瓧鑺備负鍗曚綅锛屽寘鍚櫒浠跺湴鍧€
parameter integer RMEN_LEN = 8'd0,//璇婚暱搴︼紝浠ュ瓧鑺備负鍗曚綅锛屼笉鍖呭惈鍣ㄤ欢鍦板潃
parameter integer CLK_DIV  = 16'd499// I2C鏃堕挓鍒嗛绯绘暟
)
(
input  wire I_clk,//绯荤粺鏃堕挓杈撳叆
input  wire I_rstn,//绯荤粺澶嶄綅锛屼綆鐢靛钩鏈夋晥
output reg  O_iic_scl = 1'b0,//I2C鏃堕挓SCL
inout  wire IO_iic_sda,//I2C 鏁版嵁鎬荤嚎
input  wire [WMEN_LEN*8-1'b1:0]I_wr_data,//鍐欐暟鎹瘎瀛樺櫒锛屽叾涓璚MEN_LEN璁剧疆浜嗘渶澶ф敮鎸佺殑鏁版嵁瀛楄妭鏁帮紝瓒婂ぇ鍗犵敤鐨凢PGA璧勬簮瓒婂
input  wire [7:0]I_wr_cnt,//鍐欐暟鎹鏁板櫒锛屼唬琛ㄥ啓浜嗗灏戜釜瀛楄妭
output reg  [RMEN_LEN*8-1'b1:0]O_rd_data = 0,//璇绘暟鎹瘎瀛樺櫒锛屽叾涓璕MEN_LEN璁剧疆浜嗘渶澶ф敮鎸佺殑鏁版嵁瀛楄妭鏁帮紝瓒婂ぇ鍗犵敤鐨凢PGA璧勬簮瓒婂
input  wire [7:0]I_rd_cnt,//璇绘暟鎹鏁板櫒
input  wire I_iic_req,//I_iic_req == 1 浣胯兘I2C浼犺緭
input  wire I_iic_mode,//I_iic_mode = 1 闅忔満璇?  I_iic_mode = 0 璇诲綋鍓嶅瘎瀛樺櫒鎴栬€呴〉璇?
output reg  O_iic_busy = 1'b0,//I2C鎺у埗鍣ㄥ繖
output reg  O_iic_bus_error, //I2C鎬荤嚎锛屾棤娉曡鍒版纭瓵CK鍑洪敊
output reg  IO_iic_sda_dg
);

localparam IDLE    = 4'd0;//I2C 鎬荤嚎绌洪棽鐘舵€?
localparam START   = 4'd1;//I2C 鎬荤嚎鍚姩
localparam W_WAIT  = 4'd2;//I2C 鎬荤嚎绛夊緟鍐欏畬鎴?
localparam W_ACK   = 4'd3;//I2C 鎬荤嚎绛夊緟鍐橶ACK
localparam R_WAIT  = 4'd4;//I2C 鎬荤嚎绛夊緟璇诲畬鎴?
localparam R_ACK   = 4'd5;//I2C 鎬荤嚎绛夊緟璇籖ACK 
localparam STOP1   = 4'd6;//I2C 鎬荤嚎浜х敓鍋滄浣?
localparam STOP2   = 4'd7;//I2C 鎬荤嚎浜х敓鍋滄浣?  

localparam SCL_DIV = CLK_DIV/2;

localparam OFFSET = SCL_DIV - SCL_DIV/4;//璁剧疆I2C鎬荤嚎鐨凷CL鏃堕挓鐨勫亸绉伙紝浠ユ弧瓒砈CL鍜孲DA鐨勬椂搴忚姹傦紝澶栭儴鐨凷CL寤惰繜鍐呴儴鐨勫崐鍛ㄦ湡鐨勫洓鍒嗕箣涓?

reg [2:0] IIC_S = 4'd0; //I2C 鐘舵€佹満
//generate  scl
reg [15:0] clkdiv = 16'd0;   //I2C 鏃堕挓鍒嗛瀵勫瓨鍣?
reg scl_r      = 1'b1;       //I2C鎺у埗鍣ㄧ殑SCL鍐呴儴鏃堕挓
reg sda_o      = 1'b0;       //I2C鎺у埗鍣ㄧ殑SDA
reg scl_clk    = 1'b0;       //I2C鎺у埗鍣ㄥ唴閮⊿CL鏃堕挓锛屼笌澶栭儴鏃堕挓瀛樺湪OFFSET鍙傛暟璁剧疆鐨勭浉浣嶅亸绉?
reg [7:0] sda_r = 8'd0;      //鍙戦€佸瘎瀛樺櫒
reg [7:0] sda_i_r = 8'd0;    //鎺ユ敹瀵勫瓨鍣?
reg [7:0] wcnt = 8'd0;       //鍙戦€佹暟鎹鏁板櫒锛屼互byte涓哄崟浣?
reg [7:0] rcnt = 8'd0;       //鎺ユ敹鏁版嵁璁℃暟鍣紝浠yte涓哄崟浣?
reg [2:0] bcnt = 3'd0;       //bit璁℃暟鍣?
reg  rd_req = 1'b0;          //璇昏姹傦紝褰撳垽鏂埌闇€瑕佽鏁版嵁锛屽唴閮ㄧ姸鎬佹満涓缃?
wire sda_i;                  //sda 杈撳叆
wire scl_offset;             //scl 鏃堕挓鍋忕Щ鎺у埗

assign  sda_i   = (IO_iic_sda == 1'b0) ?  1'b0 : 1'b1;  //璇绘€荤嚎 
assign  IO_iic_sda = (sda_o == 1'b0) ?  1'b0 : 1'bz;    //鍐欐€荤嚎锛?'bz浠ｈ〃楂橀樆锛孖2C澶栭儴閫氳繃涓婃媺鐢甸樆锛屽疄鐜版€荤嚎鐨勯珮鐢靛钩

//scl 鏃堕挓鍒嗛鍣?
always@(posedge I_clk)
    if(clkdiv < SCL_DIV)    
        clkdiv <= clkdiv + 1'b1;
    else begin
        clkdiv <= 16'd0; 
        scl_clk <= !scl_clk;
    end

assign  scl_offset  = (clkdiv == OFFSET);//璁剧疆scl_offset鐨勬椂闂村弬鏁?
always @(posedge I_clk) O_iic_scl <=  scl_offset ?  scl_r : O_iic_scl; //O_iic_scl寤惰繜scl_offset鏃堕棿鐨剆cl_r

//閲囬泦I2C 鏁版嵁鎬荤嚎sda
always @(posedge I_clk) IO_iic_sda_dg <= sda_i;  

//褰揑IC_S鐘舵€佹満澶勪簬锛屽悓鏃剁┖闂茬姸鎬侊紝璁剧疆SCL涓洪珮鐢靛钩锛屽悓鏃朵篃鏄┖闂诧紝鍋滄鐘舵€侊紝鐢ㄤ簬浜х敓璧峰浣嶅拰鍋滄浣嶆椂搴忥紝鍚﹀垯瀵勫瓨scl_clk鏃堕挓
always @(*) 
    if(IIC_S == IDLE || IIC_S == STOP1 || IIC_S == STOP2)
        scl_r <= 1'b1;
    else 
        scl_r <= scl_clk;
  

//褰撹繘鍏IC_S鐘舵€佷负鍚姩銆佸仠姝㈣缃畇da=0锛岀粨鍚坰cl浜х敓璧峰浣嶏紝鎴栬€?IIC_S == R_ACK && (rcnt != I_rd_cnt) sda=0锛岀敤浜庝骇鐢熻鎿嶄綔鐨凙CK
always @(*) 
    if(IIC_S == START || IIC_S == STOP1 || (IIC_S == R_ACK && (rcnt != I_rd_cnt)))
        sda_o <= 1'b0;
    else if(IIC_S == W_WAIT)
        sda_o <= sda_r[7]; 
    else  sda_o <= 1'b1; //鍚﹀垯鍏朵粬鐘舵€侀兘涓?锛屽綋(IIC_S == R_ACK && (rcnt == I_rd_cnt) 浜х敓涓€涓狽ACK 

//I2C鏁版嵁鍙戦€佹ā鍧楋紝鎵€鏈夌殑鍐欐暟鎹兘閫氳繃姝ゆā鍧楀彂閫?
always @(posedge scl_clk) 
    if(IIC_S == W_ACK || IIC_S == START)begin//IIC_S=START鍜學_ACK锛屾妸闇€瑕佸彂閫佺殑鏁版嵁锛屽瘎瀛樺埌sda_r
        sda_r <= I_wr_data[(wcnt*8) +: 8];//瀵勫瓨闇€瑕佸彂鍙戦€佺殑鏁版嵁鍒皊da_r
        if( rd_req ) sda_r <= {I_wr_data[7:1],1'b1};//瀵逛簬璇绘搷浣滐紝rd_req鐢卞唴閮ㄤ唬鐮佷骇鐢燂紝褰撳啓瀹岀涓€涓暟鎹?鍣ㄤ欢鍦板潃)锛屽悗閫氳繃鍒ゆ柇I_rd_cnt锛岀‘璁ゆ槸鍚︽暟鎹渶瑕佽
    end
    else if(IIC_S == W_WAIT)//褰揥_WAT鐘舵€侊紝閫氳繃绉讳綅鎿嶄綔锛屾妸鏁版嵁鍙戦€佸埌鏁版嵁鎬荤嚎
        sda_r <= {sda_r[6:0],1'b1};//绉讳綅鎿嶄綔
    else 
        sda_r <= sda_r;

//sda data bus read and hold data to O_rd_data register when IIC_S=R_ACK
//I2C鏁版嵁鎺ユ敹妯″潡锛孖2C璇绘湡闂达紝鎶婃暟鎹€氳繃绉讳綅鎿嶄綔锛岀Щ鍏_rd_data
always @(negedge scl_clk)begin
    if(IIC_S == R_WAIT ) //褰揑IC_S == R_WAIT ||IIC_S == W_ACK(濡傛灉璇绘搷浣滐紝绗?涓狟IT鏄疻_ACK杩欎釜鐘舵€佽)鍚姩绉讳綅鎿嶄綔
        sda_i_r <= {sda_i_r[6:0],sda_i};
    else if(IIC_S == R_ACK)//褰揑IC_S == R_ACK,瀹屾垚涓€涓狟YTE璇伙紝鎶婃暟鎹繚瀛樺埌O_rd_data
        O_rd_data[((rcnt-1'b1)*8) +: 8] <= sda_i_r[7:0];
    else if(IIC_S == IDLE)//绌洪棽鐘舵€侊紝閲嶇疆sda_i_r
        sda_i_r <= 8'd0;
end

//鎬荤嚎蹇欑姸鎬?
always @(posedge scl_clk or negedge I_rstn )begin
    if(I_rstn == 1'b0)
        O_iic_busy <= 1'b0; 
    else begin
        if((I_iic_req == 1'b1 || rd_req == 1'b1 || O_iic_bus_error))//I_iic_req == 1'b1 || rd_req == 1'b1鎬荤嚎杩涘叆蹇欑姸鎬?
            O_iic_busy <= 1'b1; 
        else if(IIC_S == IDLE)
            O_iic_busy <= 1'b0;
    end         
end

//鎬荤嚎蹇欑姸鎬?
always @(negedge scl_clk or negedge I_rstn )begin
    if(I_rstn == 1'b0)
        O_iic_bus_error <= 1'b0;    
    else begin
        if(IIC_S  == W_ACK && sda_i == 1'b1)//I_iic_req == 1'b1 || rd_req == 1'b1鎬荤嚎杩涘叆蹇欑姸鎬?
            O_iic_bus_error <= 1'b1; 
        else if(I_iic_req == 0)
            O_iic_bus_error <= 1'b0;
    end         
end

//I2C Master鎺у埗鍣ㄧ姸鎬佹満
always @(posedge scl_clk or negedge I_rstn )begin
        if(I_rstn == 1'b0)begin //寮傛澶嶄綅锛屽浣嶇浉鍏冲瘎瀛樺櫒
           wcnt     <= 8'd0;
           rcnt     <= 8'd0;
           rd_req   <= 1'b0;   
           IIC_S    <= IDLE;
        end
        else begin
        case(IIC_S) //sda = 1 scl =1
        IDLE:begin//鍦ㄧ┖闂茬姸鎬侊紝sda=1 scl=1 
           if(I_iic_req == 1'b1 || rd_req == 1'b1) //褰揑_iic_req == 1'b1浠ｈ〃鍚姩浼犺緭 褰?rd_req == 1'b1 浠ｈ〃璇绘搷浣滈渶瑕佷骇鐢焤epeated start 閲嶅鍚姩  
              IIC_S  <= START; //杩涘叆START鐘舵€?
           else begin
              wcnt <= 8'd0; //澶嶄綅璁℃暟鍣?
              rcnt <= 8'd0; //澶嶄綅璁℃暟鍣?
           end
        end
        START:begin //杩欎釜鐘舵€侊紝鍓嶉潰鐨勪唬鐮侊紝鍏堣缃畇da = 0锛宻cl_offset鍙傛暟璁剧疆浜唖cl_clk鏃堕挓鐨勫亸绉伙紝涔嬪悗 scl_clk =0 鍗硈cl =0 浜х敓璧峰浣嶆垨鑰呴噸澶嶈捣濮嬩綅
           bcnt <= 3'd7; //璁剧疆bcnt鐨勫垵鍊?        
           IIC_S  <= W_WAIT;//杩涘叆鍙戦€佺瓑寰?
        end           
        W_WAIT://绛夊緟鍙戦€佸畬鎴愶紝杩欓噷鍙戦€?bits 鏁版嵁锛屽啓鍣ㄤ欢鍦板潃锛屽啓瀵勫瓨鍣ㄥ湴鍧€锛屽啓鏁版嵁锛岄兘鍦ㄨ繖涓姸鎬佸畬鎴?
        begin
           if(bcnt > 3'd0)//濡傛灉8bits娌″彂閫佸畬锛岀洿鍒板彂閫佸畬
               bcnt  <= bcnt - 1'b1; //bcnt璁℃暟鍣紝姣忓彂閫?bit鍑?
           else begin //8bits鍙戦€佸畬姣?
               wcnt <= wcnt + 1'b1; //wcnt璁℃暟鍣紝鐢ㄤ簬璁板綍宸茬粡鍐欎簡澶氬皯瀛楄妭
               IIC_S  <= W_ACK;//杩涘叆W_ACK鐘舵€?
           end
        end 
        W_ACK://绛夊緟WACK锛屾闃舵锛屼篃鍒ゆ柇鏄惁鏈夎鎿嶄綔
        begin 
           if(wcnt < I_wr_cnt)begin //鍒ゆ柇鏄惁鎵€鏈夋暟鎹彂閫?鍐?瀹屾垚
              bcnt <= 3'd7; //濡傛灉娌℃湁鍐欏畬锛岄噸缃産cnt
              IIC_S <= W_WAIT;//缁х画鍥炲埌W_WAIT绛夊緟鏁版嵁鍙戦€?鍐?瀹屾垚
           end
           else if(I_rd_cnt > 3'd0)begin//I_rd_cnt > 0浠ｈ〃鏈夋暟鎹渶瑕佽锛孖_rd_cnt鍐冲畾浜嗘湁澶氬皯鏁版嵁闇€瑕佽
              if(rd_req == 1'b0 && I_iic_mode == 1'b1)begin //瀵逛簬绗竴娆″啓瀹屽櫒浠跺湴鍧€锛屽鏋淚_iic_mode==1浠ｈ〃鏀寔闅忔満璇?
                  rd_req <= 1'b1;//璁剧疆rd_req=1锛岃姹傝鎿嶄綔
                  IIC_S <= IDLE; //璁剧疆鐘舵€佽繘鍏DLE锛屾牴鎹畆d_req鐨勫€间細閲嶆柊浜х敓涓€娆′负璇绘搷浣滆繘琛岀殑repeated閲嶅start
              end
              else //濡傛灉涔嬪墠宸茬粡瀹屾垚浜唕epeated閲嶅start锛岄偅涔堣鎿嶄綔杩涘叆璇绘暟鎹樁娈?
                  IIC_S <= R_WAIT;//杩涘叆璇荤瓑寰?
                  bcnt <= 3'd7;//璁剧疆bcnt鐨勫垵鍊? 
           end
           else //濡傛灉鎵€鏈夌殑鍙戦€佸畬鎴愶紝涔熸病鏁版嵁闇€瑕佽锛岃繘鍏ュ仠姝㈢姸鎬?
              IIC_S <= STOP1; 
        end  
        R_WAIT://绛夊緟璇绘搷浣滃畬鎴?
        begin
           rd_req <= 1'b0;//閲嶇疆璇昏姹俽d_req=0
           bcnt  <= bcnt - 1'b1; //bit 璁℃暟鍣?
           if(bcnt == 3'd0)begin //褰?bits鏁版嵁璇诲畬
              rcnt <= (rcnt < I_rd_cnt) ? (rcnt + 1'b1) : rcnt;//鍒ゆ柇鏄惁杩樻湁鏁版嵁闇€瑕佽
              IIC_S  <= R_ACK;//杩涘叆R_ACK
           end
        end
        R_ACK://R_ACK鐘舵€佷骇鐢烴ACK
        begin
           bcnt <= 3'd7;//閲嶇疆璇昏姹俠cnt璁℃暟鍣?
           IIC_S <= (rcnt < I_rd_cnt) ? R_WAIT : STOP1; //濡傛灉鎵€鏈夋暟鎹瀹岋紝杩涘叆鍋滄鐘舵€?
        end  
        STOP1:begin//浜х敓鍋滄浣?sda = 0 scl = 1
            rd_req  <= 1'b0;              
            IIC_S <= STOP2;
        end
        STOP2://浜х敓鍋滄浣? sda = 1 scl = 1
            IIC_S <= IDLE;          
        default:
            IIC_S <= IDLE;
        endcase
    end
end

endmodule

