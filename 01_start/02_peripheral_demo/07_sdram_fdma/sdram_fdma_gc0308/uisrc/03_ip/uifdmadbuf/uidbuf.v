`timescale 1ns / 1ns
/*******************************MILIANKE*******************************
*Company : MiLianKe Electronic Technology Co., Ltd.
*WebSite:https://www.milianke.com
*TechWeb:https://www.uisrc.com
*tmall-shop:https://milianke.tmall.com
*jd-shop:https://milianke.jd.com
*taobao-shop: https://milianke.taobao.com
*Create Date: 2021/04/25
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

module uidbuf#(
parameter  integer                   APP_DATA_WIDTH = 32,	//SDRAM鏁版嵁浣嶅
parameter  integer                   APP_ADDR_WIDTH = 21,	//SDRAM鍦板潃浣嶅

parameter  integer                   W_BUFDEPTH     = 2048,	//鍐欓€氶亾AXI璁剧疆FIFO缂撳瓨澶у皬
parameter  integer                   W_DATAWIDTH    = 16,	//鍐欓€氶亾AXI璁剧疆鏁版嵁浣嶅澶у皬
parameter  [APP_ADDR_WIDTH -1'b1: 0] W_BASEADDR     = 0,	//鍐欓€氶亾璁剧疆鍐呭瓨璧峰鍦板潃
parameter  integer                   W_XSIZE        = 640, //鍐欓€氶亾璁剧疆X鏂瑰悜鐨勬暟鎹ぇ灏忥紝浠ｈ〃浜嗘瘡娆DMA 浼犺緭鐨勬暟鎹暱搴?
parameter  integer                   W_YSIZE        = 480, //鍐欓€氶亾璁剧疆Y鏂瑰悜鍊硷紝浠ｈ〃浜嗚繘琛屼簡澶氬皯娆SIZE浼犺緭
parameter  integer                   W_BUFSIZE      = 3,	//鍐欓€氶亾璁剧疆甯х紦瀛樺ぇ灏忥紝鐩墠鏈€澶ф敮鎸?甯э紝淇敼鍒嗚鲸鐜囧弬鏁?闇€娉ㄦ剰fdma_wbufn浣嶅

parameter  integer                   R_BUFDEPTH     = 2048,	//璇婚€氶亾AXI璁剧疆FIFO缂撳瓨澶у皬
parameter  integer                   R_DATAWIDTH    = 16,   //璇婚€氶亾AXI璁剧疆鏁版嵁浣嶅澶у皬
parameter  [APP_ADDR_WIDTH -1'b1: 0] R_BASEADDR     = 0,    //璇婚€氶亾璁剧疆鍐呭瓨璧峰鍦板潃
parameter  integer                   R_XSIZE        = 640, //璇婚€氶亾璁剧疆X鏂瑰悜鐨勬暟鎹ぇ灏忥紝浠ｈ〃浜嗘瘡娆DMA 浼犺緭鐨勬暟鎹暱搴?
parameter  integer                   R_YSIZE        = 480, //璇婚€氶亾璁剧疆Y鏂瑰悜鍊硷紝浠ｈ〃浜嗚繘琛屼簡澶氬皯娆SIZE浼犺緭
parameter  integer                   R_BUFSIZE      = 3     //璇婚€氶亾璁剧疆甯х紦瀛樺ぇ灏忥紝鐩墠鏈€澶ф敮鎸?甯э紝淇敼鍒嗚鲸鐜囧弬鏁?闇€娉ㄦ剰fdma_rbufn浣嶅

)
(
input wire                                  I_ui_clk,		//SDRAM璇诲啓鏃堕挓
input wire                                  I_ui_rstn,	//SDRAM澶嶄綅淇″彿
input wire                                  I_sdr_busy,
//----------sensor input -W_FIFO--------------
input wire                                  I_W_wclk,	//鍐橣IFO鐨勫啓鏃堕挓
input wire                                  I_W_FS,		//甯у悓姝ヤ俊鍙?
input wire                                  I_W_wren,	//鍐橣IFO鐨勫啓浣胯兘
input wire     [W_DATAWIDTH-1'b1 : 0]       I_W_data,	//鍐橣IFO鐨勫啓鏁版嵁
//----------fdma signals write-------       
output wire    [APP_ADDR_WIDTH-1'b1: 0]     O_fdma_waddr,	//FDMA鍐欓€氶亾鍦板潃
output wire                                 O_fdma_wareq,	//FDMA鍐欓€氶亾璇锋眰
output wire    [15  :0]                     O_fdma_wsize, //FDMA鍐欓€氶亾涓€娆DMA鐨勪紶杈撳ぇ灏?                                   
input  wire                                 I_fdma_wbusy,	//FDMA澶勪簬BUSY鐘舵€侊紝SDRAM姝ｅ湪鍐欐搷浣?
output wire    [APP_DATA_WIDTH-1'b1:0]      O_fdma_wdata,	//FDMA鍐欐暟鎹?
input  wire                                 I_fdma_wvalid,//FDMA 鍐欐湁鏁?
output wire                                 O_fdma_wready,//FDMA鍐欏噯澶囧ソ锛岀敤鎴峰彲浠ュ啓鏁版嵁	
//----------sensor input -W_FIFO--------------
input  wire                                 I_R_rclk,	//鍐橣IFO鐨勫啓鏃堕挓
input  wire                                 I_R_FS,     //甯у悓姝ヤ俊鍙?
input  wire                                 I_R_rden,   //鍐橣IFO鐨勫啓浣胯兘
output wire    [R_DATAWIDTH-1'b1 : 0]       O_R_data,   //鍐橣IFO鐨勫啓鏁版嵁

//----------fdma signals read-------  
output wire    [APP_ADDR_WIDTH-1'b1: 0]     O_fdma_raddr,	//FDMA鍐欓€氶亾鍦板潃
output wire                                 O_fdma_rareq, //FDMA鍐欓€氶亾璇锋眰
output wire    [15: 0]                      O_fdma_rsize, //FDMA鍐欓€氶亾涓€娆DMA鐨勪紶杈撳ぇ灏?                                        
input  wire                                 I_fdma_rbusy,	//FDMA澶勪簬BUSY鐘舵€侊紝SDRAM姝ｅ湪鍐欐搷浣?	
input  wire    [APP_DATA_WIDTH-1'b1:0]      I_fdma_rdata, //FDMA鍐欐暟鎹?
input  wire                                 I_fdma_rvalid,//FDMA 鍐欐湁鏁?
output wire                                 O_fdma_rready//FDMA鍐欏噯澶囧ソ锛岀敤鎴峰彲浠ュ啓鏁版嵁	

);    

// 璁＄畻Log2
function integer clog2;
  input integer value;
  begin
    for (clog2 = 0; value > 0; clog2 = clog2 + 1) value = value >> 1;
  end
endfunction

localparam TS_IDLE = 'd0;  
localparam WR_ARBI = 'd1;  
localparam W_DATA1 = 'd2;   
localparam W_DATA2 = 'd3; 
localparam R_DATA1 = 'd4; 
localparam R_DATA2 = 'd5;

localparam WFIFO_ADDR_WIDTH_W   = 	clog2(W_BUFDEPTH);//璁＄畻鍐橣IFO鐨勫啓娣卞害浣嶅
localparam WFIFO_ADDR_WIDTH_R   = 	clog2(W_BUFDEPTH * W_DATAWIDTH / APP_DATA_WIDTH);//璁＄畻鍐橣IFO鐨勮娣卞害浣嶅

localparam RFIFO_ADDR_WIDTH_W   = 	clog2(R_BUFDEPTH * R_DATAWIDTH / APP_DATA_WIDTH);//璁＄畻璇籉IFO鐨勫啓娣卞害浣嶅
localparam RFIFO_ADDR_WIDTH_R   = 	clog2(R_BUFDEPTH);//璁＄畻璇籉IFO鐨勮娣卞害浣嶅

localparam WX_BURST_ADDR_INC 	=   (W_XSIZE*W_DATAWIDTH)/APP_DATA_WIDTH;//璁＄畻鍐欓€氶亾缂撳瓨涓€琛岄渶瑕佺殑鍦板潃绌洪棿
localparam RX_BURST_ADDR_INC 	=   (R_XSIZE*R_DATAWIDTH)/APP_DATA_WIDTH;//璁＄畻璇婚€氶亾璇诲彇涓€琛岄渶瑕佺殑鍦板潃绌洪棿

localparam WY_BURST_TIMES 		=   (W_XSIZE*(W_YSIZE-1)*W_DATAWIDTH)/APP_DATA_WIDTH;//璁＄畻鍐欓€氶亾缂撳瓨涓€甯ч渶瑕佺殑鍦板潃绌洪棿
localparam RY_BURST_TIMES 		=   (R_XSIZE*(R_YSIZE-1)*R_DATAWIDTH)/APP_DATA_WIDTH;//璁＄畻璇婚€氶亾璇诲彇涓€琛岄渶瑕佺殑鍦板潃绌洪棿

wire 							W_FS;
wire 							R_FS;
							
wire 							wrst;
wire 							rrst;

reg [5:0]						wrst_cnt;
reg [5:0]						rrst_cnt;

reg								wrst_lock; 
reg								rrst_lock; 

wire [15:0] 						W_rcnt;
wire [15:0] 						R_wcnt;
	  
reg  [15:0] 						W_rcnt_r1;
reg  [15:0] 						W_rcnt_r2;
						
reg  [15:0] 						R_wcnt_r1;
reg  [15:0] 						R_wcnt_r2;

reg  							Rfifo_rreq;
reg  							Wfifo_wreq;

reg 							wrst_r1		;
reg 							rrst_r1		;

reg	[2 : 0]                     STATE		;
reg 							wr_flag		;

reg [2:0]						fdma_wbufn	;
reg 							fdma_wareq_r;
reg [17: 0]						fdma_waddr_r;


reg [2:0]						fdma_rbufn	;
reg 							fdma_rareq_r;
reg [17: 0]						fdma_raddr_r;


assign wrst = (wrst_cnt < 60);//澶嶄綅鍐橣IFO_60涓懆鏈?
assign rrst = (rrst_cnt < 60);//澶嶄綅鍐橣IFO_60涓懆鏈?

assign O_fdma_wready = 1'b1;
assign O_fdma_rready = 1'b1;

assign O_fdma_wareq = fdma_wareq_r;//FDMA鍐欒姹?
assign O_fdma_wsize = WX_BURST_ADDR_INC;//FDMA涓€娆″啓鎿嶄綔鐨勫湴鍧€绌洪棿
assign O_fdma_waddr = W_BASEADDR + {fdma_wbufn[2:0],fdma_waddr_r[17:0]};//FDMA鍐欏湴鍧€

assign O_fdma_rareq = fdma_rareq_r;//FDMA璇昏姹?
assign O_fdma_rsize = RX_BURST_ADDR_INC;//FDMA涓€娆¤鎿嶄綔鐨勫湴鍧€绌洪棿
assign O_fdma_raddr = R_BASEADDR + {fdma_rbufn[2:0],fdma_raddr_r[17:0]};//FDMA璇诲湴鍧€


//澶嶄綅鍐橣IFO,杩涜鍐欏抚鍚屾
always@(posedge I_ui_clk)begin
	if(~I_ui_rstn)begin
		wrst_cnt  <= 6'd0;
		wrst_lock <= 1'b0;
	end
	else if(W_FS)
		wrst_lock <= 1'b1;
	else if(wrst_lock && wrst_cnt < 60)
		wrst_cnt <= wrst_cnt + 1'b1;
	else begin
		wrst_cnt  <= wrst_cnt;
		wrst_lock <= wrst_lock;
	end
end

always@(posedge I_ui_clk)wrst_r1 <= wrst;


//澶嶄綅璇籉IFO,杩涜璇诲抚鍚屾
always@(posedge I_ui_clk)begin
	if(~I_ui_rstn)begin
		rrst_cnt  <= 6'd0;
		rrst_lock <= 1'b0;
	end
	else if(R_FS)
		rrst_lock <= 1'b1;
	else if (rrst_lock && rrst_cnt < 60)
		rrst_cnt  <= rrst_cnt + 1'b1;
	else begin
		rrst_cnt  <= rrst_cnt;
		rrst_lock <= rrst_lock;
	end
end

always@(posedge I_ui_clk)rrst_r1 <= rrst;


//鍐橣IFO缂撳瓨瓒呰繃涓よ,FDMA鍙戦€佸啓璇锋眰
always @(posedge I_ui_clk)begin
    W_rcnt_r1 <= W_rcnt;
    W_rcnt_r2 <= W_rcnt_r1;
end

always @(posedge I_ui_clk) Wfifo_wreq <= (W_rcnt_r2 > 2*WX_BURST_ADDR_INC - 1'b1);


//璇籉IFO缂撳瓨灏戜簬涓よ,FDMA鍙戦€佽璇锋眰
always @(posedge I_ui_clk)begin
    R_wcnt_r1 <= R_wcnt;
    R_wcnt_r2 <= R_wcnt_r1;
end

always @(posedge I_ui_clk) Rfifo_rreq <= ((R_wcnt_r2 < 2*RX_BURST_ADDR_INC - 1'b1));


 always @(posedge I_ui_clk) begin
	if(!I_ui_rstn)begin
		STATE 		 <= TS_IDLE;
		fdma_wareq_r <= 'd0;
		fdma_waddr_r <= 'd0;		
		fdma_rareq_r <= 'd0;
		fdma_raddr_r <= 'd0;
		fdma_wbufn   <= 'd0;
		fdma_rbufn   <= 'd0;
		wr_flag   	 <= 'd0;
    end   
    else begin
      case(STATE)
        TS_IDLE:begin
			if((~wrst && wrst_r1) || (~rrst && rrst_r1))begin//FIFO澶嶄綅瀹屾垚,杩涜璇诲啓鍒ゆ柇鎿嶄綔
				fdma_waddr_r <= 'd0;
				fdma_raddr_r <= 'd0;
				STATE 		 <= WR_ARBI;
			end
		end
		WR_ARBI:begin
			if(Wfifo_wreq && !Rfifo_rreq)begin//鍐橣IFO缂撳瓨瓒呰繃涓よ,鍙戦€佸啓璇锋眰
				STATE	<= W_DATA1;
				wr_flag <= 1'b0;
			end
			else if(Rfifo_rreq && !Wfifo_wreq)begin//璇籉IFO缂撳瓨灏戜簬涓よ,鍙戦€佽璇锋眰
				STATE 	<= R_DATA1;
				wr_flag <= 1'b1;
			end
			else if(Wfifo_wreq && Rfifo_rreq)begin//璇诲啓鍚屾椂鍒版潵,杩涜璇诲啓浠茶
				wr_flag <= ~wr_flag;//濡傛灉涓婁竴娆″彂閫佺殑鏄啓璇锋眰,鏈灏卞彂閫佽璇锋眰,鍙嶄箣鍙戦€佸啓璇锋眰
					if(wr_flag)
						STATE <= R_DATA1;
					else
						STATE <= W_DATA1;
				end
		end
		W_DATA1:begin 
			if(!I_sdr_busy && !I_fdma_wbusy)//褰揊DMA鍐欎笉蹇欏苟涓擲DRAM鎬荤嚎涓嶅繖鏃?鍙戦€佸啓璇锋眰
				fdma_wareq_r  <= 1'b1;
			else if(I_fdma_wbusy)begin
				fdma_wareq_r  <= 1'b0;
				STATE		  <= W_DATA2;
			end
        end
        W_DATA2:begin 
			if(!I_sdr_busy && !I_fdma_wbusy)begin
				if(fdma_waddr_r == WY_BURST_TIMES)begin//鍐欏畬涓€甯?鍐欏湴鍧€杩涜澶嶄綅,骞惰繘琛屽抚缂撳瓨
						fdma_waddr_r   <= 'd0;
						STATE 		   <= WR_ARBI;
						//if((fdma_wbufn == W_BUFSIZE - 1'b1 && fdma_rbufn == 0) || fdma_wbufn + 1 ==fdma_rbufn)
						//	fdma_wbufn    <= fdma_wbufn;
						if(fdma_wbufn < W_BUFSIZE - 1'b1)
							fdma_wbufn <= fdma_wbufn + 1'b1;
						else
							fdma_wbufn <= 'd0;
				end
				else begin
					fdma_waddr_r  <= fdma_waddr_r + WX_BURST_ADDR_INC;
					STATE		  <= WR_ARBI;
				end
			end
        end	
		R_DATA1:begin 
			if(!I_sdr_busy && !I_fdma_rbusy)//褰揊DMA璇讳笉蹇欏苟涓擲DRAM鎬荤嚎涓嶅繖鏃?鍙戦€佽璇锋眰
				fdma_rareq_r <= 1'b1;
			else if(I_fdma_rbusy)begin
				fdma_rareq_r <= 1'b0;
				STATE		 <= R_DATA2;
			end
        end
        R_DATA2:begin 
			if(!I_sdr_busy && !I_fdma_rbusy)
				if(fdma_raddr_r == RY_BURST_TIMES)begin//璇诲畬涓€甯?璇诲湴鍧€杩涜澶嶄綅,璇诲彇涓嬩竴甯у湴鍧€绌洪棿
					fdma_raddr_r   <= 'd0;
					STATE 		   <= WR_ARBI;
					if((fdma_rbufn == R_BUFSIZE - 1'b1) && (fdma_wbufn == 1'b0) || (fdma_rbufn + 1'b1 == fdma_wbufn))
						fdma_rbufn <= fdma_rbufn;
					else if(fdma_rbufn < R_BUFSIZE - 1'b1)
						fdma_rbufn 	<= fdma_rbufn + 1'b1;
					else
						fdma_rbufn 	<= 'd0;
				end
				else begin 
					fdma_raddr_r  <= fdma_raddr_r + RX_BURST_ADDR_INC;
					STATE 		  <= WR_ARBI;
				end
        end
        default:STATE <= TS_IDLE;
      endcase
   end
end 

//鍐欏抚鍚屾
fs_cap fs_cap_W0
(
 .clk_i(I_W_wclk),
 .rstn_i(I_ui_rstn),
 .vs_i(I_W_FS),
 .fs_cap_o(W_FS)
);

//璇诲抚鍚屾
fs_cap fs_cap_R0
(
 .clk_i(I_R_rclk),
 .rstn_i(I_ui_rstn),
 .vs_i(I_R_FS),
 .fs_cap_o(R_FS)
);

//鍐橣IFO
wfifo #(
	.DATA_WIDTH_W  (W_DATAWIDTH), 
    .DATA_WIDTH_R  (APP_DATA_WIDTH), 
    .ADDR_WIDTH_W  (WFIFO_ADDR_WIDTH_W), 
    .ADDR_WIDTH_R  (WFIFO_ADDR_WIDTH_R), 
    .AL_FULL_NUM   (W_BUFDEPTH - 3), 
    .AL_EMPTY_NUM  (3), 
    .SHOW_AHEAD_EN (1'b1), 
    .OUTREG_EN ("NOREG"))
wfifo_inst(
	.rst(~I_ui_rstn | wrst),
	.di(I_W_data),
	.clkw(I_W_wclk),
	.we(I_W_wren),
	.dout(O_fdma_wdata),
	.clkr(I_ui_clk),
	.re(I_fdma_wvalid),
	.empty_flag(wfifo_empty_flag),
	.rdusedw(W_rcnt),
	.full_flag(),
	.afull()
); 

//璇籉IFO
rfifo #(
	.DATA_WIDTH_W  (APP_DATA_WIDTH), 
    .DATA_WIDTH_R  (R_DATAWIDTH), 
    .ADDR_WIDTH_W  (RFIFO_ADDR_WIDTH_W), 
    .ADDR_WIDTH_R  (RFIFO_ADDR_WIDTH_R), 
    .AL_FULL_NUM   (R_BUFDEPTH * R_DATAWIDTH / APP_DATA_WIDTH - 3), 
    .AL_EMPTY_NUM  (3), 
    .SHOW_AHEAD_EN (1'b1), 
    .OUTREG_EN ("NOREG"))
rfifoinst(
	.rst(~I_ui_rstn | rrst),
	.di(I_fdma_rdata),
	.clkw(I_ui_clk),
	.we(I_fdma_rvalid),
	.dout(O_R_data),
	.clkr(I_R_rclk),
	.re(I_R_rden),
	.valid(),
	.empty_flag(rfifo_empty_flag),
    .wrusedw(R_wcnt),
	.full_flag(),
	.afull()
);

endmodule
