
/*******************************MILIANKE*******************************
*Company : MiLianKe Electronic Technology Co., Ltd.
*WebSite:https://www.milianke.com
*TechWeb:https://www.uisrc.com
*tmall-shop:https://milianke.tmall.com
*jd-shop:https://milianke.jd.com
*taobao-shop1: https://milianke.taobao.com
*Create Date: 2022/05/15
*File Name: 
*Description: 
*Declaration:
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
`timescale 1ns / 1ps

module app_fdma#(
parameter  integer APP_ADDR_WIDTH	= 'd21,
parameter  integer APP_DATA_WIDTH	= 'd32,
parameter  integer APP_DATA_DM   	= 'd4
)
(
input   wire            				   	fdma_clk       		,
input   wire            				   	fdma_rstn         	,
//===========fdma interface=======
input   wire [APP_ADDR_WIDTH - 1'b1: 0]     fdma_waddr          ,
input   wire  	                            fdma_wareq          ,
input   wire [15: 0]                      	fdma_wsize          ,                                     
output  reg                                 fdma_wbusy          ,
				
input   wire [APP_DATA_WIDTH - 1'b1 :0]     fdma_wdata			, //synthesis keep
output  wire                               	fdma_wvalid         ,
//input	wire                               	fdma_wready			,

input   wire [APP_ADDR_WIDTH - 1'b1: 0]     fdma_raddr          ,
input   wire                                fdma_rareq          ,
input   wire [15: 0]                      	fdma_rsize          ,                                     
output  reg                                 fdma_rbusy          ,
				
output  wire [APP_DATA_WIDTH - 1'b1 :0]     fdma_rdata			,
output  wire                               	fdma_rvalid         ,
//input	wire                               	fdma_rready			
//===========ddr interface===============
input	wire								sdr_init_done   	,
input	wire								sdr_init_ref_vld	,
	
output	reg   								app_wr_en       	,//synthesis keep
output 	reg  [APP_ADDR_WIDTH - 1'b1 :0]		app_wr_addr     	,//synthesis keep
output 	wire [APP_DATA_DM  :0]				app_wr_dm       	,
output 	wire [APP_DATA_WIDTH - 1'b1 :0]		app_wr_din     	 	,//synthesis keep
	
output	reg 								app_rd_en       	,//synthesis keep
output 	reg  [APP_ADDR_WIDTH - 1'b1 :0]		app_rd_addr     	,//synthesis keep
input	wire 								sdr_rd_en       	,//synthesis keep
input  	wire [APP_DATA_WIDTH - 1'b1 :0]		sdr_rd_dout         ,//synthesis keep
input   wire  								sdr_busy			 //synthesis keep
);

assign fdma_wvalid  = app_wr_en;
assign app_wr_din   = fdma_wdata ;//synthesis keep
assign app_wr_dm    = 4'b0000;

assign fdma_rvalid  = sdr_rd_en;
assign fdma_rdata   = sdr_rd_dout;

reg 		app_wr_en_r1;
reg 		app_rd_en_r1;
reg [20:0] 	waddr_cnt;
reg [20:0] 	raddr_cnt;

wire   wlast;
wire   rlast;

assign wlast	= (waddr_cnt == fdma_wsize);
assign rlast	= (raddr_cnt == fdma_rsize);

//app write
always@(posedge fdma_clk or negedge fdma_rstn )begin
	if(!fdma_rstn || wlast)begin
		app_wr_en_r1 <= 1'b0;
		app_wr_en 	 <= 1'b0;
		fdma_wbusy	 <= 1'b0;
	end
	else if(fdma_wareq)begin
		app_wr_en_r1 <= 1'b1;
		fdma_wbusy	 <= 1'b1;
	end
	else begin
		app_wr_en_r1 <= app_wr_en_r1;
		app_wr_en 	 <= app_wr_en_r1;
		fdma_wbusy	 <= fdma_wbusy;
	end
end

always@(posedge fdma_clk or negedge fdma_rstn )begin
	if(!fdma_rstn)
		app_wr_addr <= 21'd0;
	else if(fdma_wareq)
		app_wr_addr <= fdma_waddr;
	else if(app_wr_en)
		app_wr_addr <= app_wr_addr + 1'b1;
	else
		app_wr_addr <= app_wr_addr;
end


always@(posedge fdma_clk or negedge fdma_rstn )begin
	if(!fdma_rstn || wlast)
		waddr_cnt <= 21'd0;
	else if(app_wr_en)
		waddr_cnt <= waddr_cnt + 1'b1;
	else
		waddr_cnt <= waddr_cnt;
end

//app read
always@(posedge fdma_clk or negedge fdma_rstn )begin
	if(!fdma_rstn || rlast)begin
		app_rd_en_r1 <= 1'b0;
		app_rd_en 	 <= 1'b0;
		fdma_rbusy	 <= 1'b0;
	end
	else if(fdma_rareq)begin
		app_rd_en_r1 <= 1'b1;
		fdma_rbusy	 <= 1'b1;
	end
	else begin
		app_rd_en_r1 <= app_rd_en_r1;
		app_rd_en	 <= app_rd_en_r1;
		fdma_rbusy	 <= fdma_rbusy;
	end
end

always@(posedge fdma_clk or negedge fdma_rstn )begin
	if(!fdma_rstn)
		app_rd_addr <= 21'd0;
	else if(fdma_rareq)
		app_rd_addr <= fdma_raddr;	
	else if(app_rd_en)
		app_rd_addr <= app_rd_addr + 1'b1;
	else
		app_rd_addr <= app_rd_addr;
end


always@(posedge fdma_clk or negedge fdma_rstn )begin
	if(!fdma_rstn || rlast)
		raddr_cnt <= 21'd0;
	else if(app_rd_en)
		raddr_cnt <= raddr_cnt + 1'b1;
	else
		raddr_cnt <= raddr_cnt;
end

endmodule
