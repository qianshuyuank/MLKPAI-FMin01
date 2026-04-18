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
parameter  integer                   APP_DATA_WIDTH = 32,	//SDRAM数据位宽
parameter  integer                   APP_ADDR_WIDTH = 21,	//SDRAM地址位宽

parameter  integer                   W_BUFDEPTH     = 2048,	//写通道AXI设置FIFO缓存大小
parameter  integer                   W_DATAWIDTH    = 16,	//写通道AXI设置数据位宽大小
parameter  [APP_ADDR_WIDTH -1'b1: 0] W_BASEADDR     = 0,	//写通道设置内存起始地址
parameter  integer                   W_XSIZE        = 640, //写通道设置X方向的数据大小，代表了每次FDMA 传输的数据长度
parameter  integer                   W_YSIZE        = 480, //写通道设置Y方向值，代表了进行了多少次XSIZE传输
parameter  integer                   W_BUFSIZE      = 3,	//写通道设置帧缓存大小，目前最大支持8帧，修改分辨率参数,需注意fdma_wbufn位宽

parameter  integer                   R_BUFDEPTH     = 2048,	//读通道AXI设置FIFO缓存大小
parameter  integer                   R_DATAWIDTH    = 16,   //读通道AXI设置数据位宽大小
parameter  [APP_ADDR_WIDTH -1'b1: 0] R_BASEADDR     = 0,    //读通道设置内存起始地址
parameter  integer                   R_XSIZE        = 640, //读通道设置X方向的数据大小，代表了每次FDMA 传输的数据长度
parameter  integer                   R_YSIZE        = 480, //读通道设置Y方向值，代表了进行了多少次XSIZE传输
parameter  integer                   R_BUFSIZE      = 3     //读通道设置帧缓存大小，目前最大支持8帧，修改分辨率参数,需注意fdma_rbufn位宽

)
(
input wire                                  I_ui_clk,		//SDRAM读写时钟
input wire                                  I_ui_rstn,	//SDRAM复位信号
input wire                                  I_sdr_busy,
//----------sensor input -W_FIFO--------------
input wire                                  I_W_wclk,	//写FIFO的写时钟
input wire                                  I_W_FS,		//帧同步信号
input wire                                  I_W_wren,	//写FIFO的写使能
input wire     [W_DATAWIDTH-1'b1 : 0]       I_W_data,	//写FIFO的写数据
//----------fdma signals write-------       
output wire    [APP_ADDR_WIDTH-1'b1: 0]     O_fdma_waddr,	//FDMA写通道地址
output wire                                 O_fdma_wareq,	//FDMA写通道请求
output wire    [15  :0]                     O_fdma_wsize, //FDMA写通道一次FDMA的传输大小                                    
input  wire                                 I_fdma_wbusy,	//FDMA处于BUSY状态，SDRAM正在写操作	
output wire    [APP_DATA_WIDTH-1'b1:0]      O_fdma_wdata,	//FDMA写数据
input  wire                                 I_fdma_wvalid,//FDMA 写有效
output wire                                 O_fdma_wready,//FDMA写准备好，用户可以写数据	
//----------sensor input -W_FIFO--------------
input  wire                                 I_R_rclk,	//写FIFO的写时钟
input  wire                                 I_R_FS,     //帧同步信号
input  wire                                 I_R_rden,   //写FIFO的写使能
output wire    [R_DATAWIDTH-1'b1 : 0]       O_R_data,   //写FIFO的写数据

//----------fdma signals read-------  
output wire    [APP_ADDR_WIDTH-1'b1: 0]     O_fdma_raddr,	//FDMA写通道地址
output wire                                 O_fdma_rareq, //FDMA写通道请求
output wire    [15: 0]                      O_fdma_rsize, //FDMA写通道一次FDMA的传输大小                                         
input  wire                                 I_fdma_rbusy,	//FDMA处于BUSY状态，SDRAM正在写操作		
input  wire    [APP_DATA_WIDTH-1'b1:0]      I_fdma_rdata, //FDMA写数据
input  wire                                 I_fdma_rvalid,//FDMA 写有效
output wire                                 O_fdma_rready//FDMA写准备好，用户可以写数据	

);    

// 计算Log2
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

localparam WFIFO_ADDR_WIDTH_W   = 	clog2(W_BUFDEPTH);//计算写FIFO的写深度位宽
localparam WFIFO_ADDR_WIDTH_R   = 	clog2(W_BUFDEPTH * W_DATAWIDTH / APP_DATA_WIDTH);//计算写FIFO的读深度位宽

localparam RFIFO_ADDR_WIDTH_W   = 	clog2(R_BUFDEPTH * R_DATAWIDTH / APP_DATA_WIDTH);//计算读FIFO的写深度位宽
localparam RFIFO_ADDR_WIDTH_R   = 	clog2(R_BUFDEPTH);//计算读FIFO的读深度位宽

localparam WX_BURST_ADDR_INC 	=   (W_XSIZE*W_DATAWIDTH)/APP_DATA_WIDTH;//计算写通道缓存一行需要的地址空间
localparam RX_BURST_ADDR_INC 	=   (R_XSIZE*R_DATAWIDTH)/APP_DATA_WIDTH;//计算读通道读取一行需要的地址空间

localparam WY_BURST_TIMES 		=   (W_XSIZE*(W_YSIZE-1)*W_DATAWIDTH)/APP_DATA_WIDTH;//计算写通道缓存一帧需要的地址空间
localparam RY_BURST_TIMES 		=   (R_XSIZE*(R_YSIZE-1)*R_DATAWIDTH)/APP_DATA_WIDTH;//计算读通道读取一行需要的地址空间

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


assign wrst = (wrst_cnt < 60);//复位写FIFO_60个周期
assign rrst = (rrst_cnt < 60);//复位写FIFO_60个周期

assign O_fdma_wready = 1'b1;
assign O_fdma_rready = 1'b1;

assign O_fdma_wareq = fdma_wareq_r;//FDMA写请求
assign O_fdma_wsize = WX_BURST_ADDR_INC;//FDMA一次写操作的地址空间
assign O_fdma_waddr = W_BASEADDR + {fdma_wbufn[2:0],fdma_waddr_r[17:0]};//FDMA写地址

assign O_fdma_rareq = fdma_rareq_r;//FDMA读请求
assign O_fdma_rsize = RX_BURST_ADDR_INC;//FDMA一次读操作的地址空间
assign O_fdma_raddr = R_BASEADDR + {fdma_rbufn[2:0],fdma_raddr_r[17:0]};//FDMA读地址


//复位写FIFO,进行写帧同步
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


//复位读FIFO,进行读帧同步
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


//写FIFO缓存超过两行,FDMA发送写请求
always @(posedge I_ui_clk)begin
    W_rcnt_r1 <= W_rcnt;
    W_rcnt_r2 <= W_rcnt_r1;
end

always @(posedge I_ui_clk) Wfifo_wreq <= (W_rcnt_r2 > 2*WX_BURST_ADDR_INC - 1'b1);


//读FIFO缓存少于两行,FDMA发送读请求
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
			if((~wrst && wrst_r1) || (~rrst && rrst_r1))begin//FIFO复位完成,进行读写判断操作
				fdma_waddr_r <= 'd0;
				fdma_raddr_r <= 'd0;
				STATE 		 <= WR_ARBI;
			end
		end
		WR_ARBI:begin
			if(Wfifo_wreq && !Rfifo_rreq)begin//写FIFO缓存超过两行,发送写请求
				STATE	<= W_DATA1;
				wr_flag <= 1'b0;
			end
			else if(Rfifo_rreq && !Wfifo_wreq)begin//读FIFO缓存少于两行,发送读请求
				STATE 	<= R_DATA1;
				wr_flag <= 1'b1;
			end
			else if(Wfifo_wreq && Rfifo_rreq)begin//读写同时到来,进行读写仲裁
				wr_flag <= ~wr_flag;//如果上一次发送的是写请求,本次就发送读请求,反之发送写请求
					if(wr_flag)
						STATE <= R_DATA1;
					else
						STATE <= W_DATA1;
				end
		end
		W_DATA1:begin 
			if(!I_sdr_busy && !I_fdma_wbusy)//当FDMA写不忙并且SDRAM总线不忙时,发送写请求
				fdma_wareq_r  <= 1'b1;
			else if(I_fdma_wbusy)begin
				fdma_wareq_r  <= 1'b0;
				STATE		  <= W_DATA2;
			end
        end
        W_DATA2:begin 
			if(!I_sdr_busy && !I_fdma_wbusy)begin
				if(fdma_waddr_r == WY_BURST_TIMES)begin//写完一帧,写地址进行复位,并进行帧缓存
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
			if(!I_sdr_busy && !I_fdma_rbusy)//当FDMA读不忙并且SDRAM总线不忙时,发送读请求
				fdma_rareq_r <= 1'b1;
			else if(I_fdma_rbusy)begin
				fdma_rareq_r <= 1'b0;
				STATE		 <= R_DATA2;
			end
        end
        R_DATA2:begin 
			if(!I_sdr_busy && !I_fdma_rbusy)
				if(fdma_raddr_r == RY_BURST_TIMES)begin//读完一帧,读地址进行复位,读取下一帧地址空间
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

//写帧同步
fs_cap fs_cap_W0
(
 .clk_i(I_W_wclk),
 .rstn_i(I_ui_rstn),
 .vs_i(I_W_FS),
 .fs_cap_o(W_FS)
);

//读帧同步
fs_cap fs_cap_R0
(
 .clk_i(I_R_rclk),
 .rstn_i(I_ui_rstn),
 .vs_i(I_R_FS),
 .fs_cap_o(R_FS)
);

//写FIFO
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

//读FIFO
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
