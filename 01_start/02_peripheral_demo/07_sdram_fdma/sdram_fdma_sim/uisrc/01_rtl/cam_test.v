
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

`define   DATA_WIDTH                        32
`define   ADDR_WIDTH                        21
`define   DM_WIDTH                          4
`define   ROW_WIDTH                         11
`define   BA_WIDTH                          2
`define	  SDR_CLK_PERIOD				1000000000/150000000
`define   SELF_REFRESH_INTERVAL			64000000/`SDR_CLK_PERIOD/2**(`ROW_WIDTH)

module cam_test(
input 	 wire   	sysclk_i,
input 	 wire   	sysrst_i
);


wire					pll_lock        	;
wire					sdram_clk0          ;
wire					sdram_clk180        ;
wire					clk25m        		;
wire					clk50m        		;

wire 					vid_vs				;
wire 	                vid_hs              ;
wire 	                vid_de              ;
wire 	                tpg_de              ;

wire [7:0]				rgb_r				;
wire [7:0]              rgb_g				;
wire [7:0]              rgb_b               ;

wire 					sdr_init_done       ;
wire 					sdr_init_ref_vld    ;
wire 					app_wr_en           ;
wire [`ADDR_WIDTH-1 :0]	app_wr_addr         ;
wire [`DM_WIDTH-1  	:0]	app_wr_dm           ;
wire [`DATA_WIDTH-1 :0]	app_wr_din          ;
wire 					app_rd_en           ;
wire [`ADDR_WIDTH-1 :0]	app_rd_addr         ;
wire 					sdr_rd_en           ;
wire [`DATA_WIDTH-1 :0]	sdr_rd_dout         ;
wire           			sdr_busy;

wire [`ADDR_WIDTH-1: 0] fdma_waddr          ;
wire  	     			fdma_wareq          ;
wire [15: 0] 			fdma_wsize          ;                                    
wire         			fdma_wbusy          ;	
wire [`DATA_WIDTH-1 :0] fdma_wdata			;
wire         			fdma_wvalid         ;
wire         			fdma_wready         ;

wire [`ADDR_WIDTH-1: 0] fdma_raddr          ;
wire         			fdma_rareq          ;
wire [15: 0] 			fdma_rsize          ;                                 
wire         			fdma_rbusy          ;
wire [`DATA_WIDTH-1 :0] fdma_rdata			;
wire         			fdma_rvalid         ;

wire 					SDRAM_CLK  			;
wire 					CLKN 				;
wire 					CS_N 				;
wire 					CKE  				;
wire 					RAS_N				;
wire 					CAS_N				;
wire 					WE_N 				;
wire [`BA_WIDTH-1:0]	BA   				;
wire [`ROW_WIDTH-1:0]	ADDR 				;
wire [`DM_WIDTH-1:0]	DM   				;
wire [`DATA_WIDTH-1:0]	DQ   				;

wire           			W_wclk_i 			;
wire            		W_FS_i	 			;
wire            		W_wren_i 			;
wire [15 : 0]   		W_data_i 			;


wire        R_rclk_i;
wire        R_FS_i;
wire        R_rden_i;
wire [15:0] R_data_o;

reg [15:0] rst_cnt;

assign      W_wclk_i = clk25m;
assign      W_FS_i	 = vid_vs;
assign      W_wren_i = vid_de;
assign      W_data_i = ({rgb_r[7:3],rgb_g[7:2],rgb_b[7:3]});

assign      R_rclk_i = clk25m;

sdram_pll u_sdram_pll(
.refclk             (sysclk_i         	),
.reset              (!sysrst_i	        ),
.extlock            (pll_lock       	),
.clk1_out           (sdram_clk0         ),//75.000000MHZ	| 0 DEG 
.clk2_out           (sdram_clk180       ),//75.000000MHZ	| 180DEG 
.clk3_out           (clk25m          	)//25.000000 MHZ	| 0  DEG 

);

always @(posedge sysclk_i )begin
    if(!pll_lock)
		rst_cnt <= 16'h0000;
    else if(rst_cnt[15])
    	rst_cnt <= rst_cnt;	
	else
		rst_cnt <= rst_cnt + 1'b1;
end

uivtc#
(
.H_ActiveSize(640),          //视频时间参数,行视频信号，一行有效(需要显示的部分)像素所占的时钟数，一个时钟对应一个有效像素
.H_SyncStart(640+16),        //视频时间参数,行同步开始，即多少时钟数后开始产生行同步信号 
.H_SyncEnd(640+16+96),       //视频时间参数,行同步结束，即多少时钟数后停止产生行同步信号，之后就是行有效数据部分
.H_FrameSize(640+16+96+44), //视频时间参数,行视频信号，一行视频信号总计占用的时钟数
.V_ActiveSize(20),          //视频时间参数,场视频信号，一帧图像所占用的有效(需要显示的部分)行数量，通常说的视频分辨率即H_ActiveSize*V_ActiveSize
.V_SyncStart(20+4),         //视频时间参数,场同步开始，即多少行数后开始产生场同步信号 
.V_SyncEnd (20+4+5),        //视频时间参数,场同步结束，多少行后停止产生长同步信号
.V_FrameSize(20+4+5+28)     //视频时间参数,场视频信号，一帧视频信号总计占用的行数量    
)
uivtc_inst
(
.I_vtc_rstn(sdr_init_done),
.I_vtc_clk(clk25m),
.O_vtc_vs(vid_vs),//场同步输出
.O_vtc_hs(vid_hs),//行同步输出
.O_vtc_de(vid_de)//视频数据有效
);

uitpg uitpg_inst	
(
.I_tpg_clk(clk25m), //系统时钟
.I_tpg_vs(vid_vs),//图像的vs信号
.I_tpg_hs(vid_hs),//图像的hs信号 
.I_tpg_de(vid_de),//de数据有效信号
.O_tpg_vs(),//和vtc_vs信号一样
.O_tpg_hs(),//和vtc_hs信号一样
.O_tpg_de(tpg_de),//和vtc_de信号一样
.O_tpg_data({rgb_r,rgb_g,rgb_b})//测试图像数据输出 
);

uidbuf#(
.APP_DATA_WIDTH 	(32)    ,
.APP_ADDR_WIDTH 	(21)    ,

.W_BUFDEPTH     	(4096)  ,
.W_DATAWIDTH    	(16)    ,
.W_BASEADDR     	(0)     ,
.W_XSIZE        	(640)   ,
.W_YSIZE        	(20)   ,
.W_BUFSIZE        	(3)     ,

.R_BUFDEPTH     	(4096)  ,
.R_DATAWIDTH    	(16)    ,
.R_BASEADDR     	(0)     ,
.R_XSIZE        	(640)   ,
.R_YSIZE        	(20)   ,
.R_BUFSIZE        	(3)     
)
uidbuf_inst
(
.I_ui_clk		(sdram_clk0   ),
.I_ui_rstn		(sdr_init_done),
.I_sdr_busy		(sdr_busy	 ),
//----------sensor input -W_FIFO--------------
.I_W_wclk		(W_wclk_i    ),
.I_W_FS			(W_FS_i      ),
.I_W_wren		(W_wren_i    ),
.I_W_data		(W_data_i 	 ),	 
//----------fdma signals write-------          
.O_fdma_waddr	(fdma_waddr  ),
.O_fdma_wareq	(fdma_wareq  ),
.O_fdma_wsize	(fdma_wsize  ),                                    
.I_fdma_wbusy	(fdma_wbusy  ),	
.O_fdma_wdata	(fdma_wdata  ),
.I_fdma_wvalid	(fdma_wvalid ),
.O_fdma_wready	(fdma_wready ),
//----------sensor input -W_FIFO--------------
.I_R_rclk		(R_rclk_i    ),
.I_R_FS			(R_FS_i      ),
.I_R_rden		(R_rden_i    ),
.O_R_data		(R_data_o    ),
//----------fdma signals read-------  
.O_fdma_raddr	(fdma_raddr  ),
.O_fdma_rareq	(fdma_rareq  ),
.O_fdma_rsize	(fdma_rsize  ),                                  
.I_fdma_rbusy	(fdma_rbusy  ),
.I_fdma_rdata	(fdma_rdata  ),
.I_fdma_rvalid	(fdma_rvalid ),
.O_fdma_rready	(fdma_rready )
); 

app_fdma app_fdma_inst
(
 .fdma_clk      	(sdram_clk0) 	
,.fdma_rstn         (sdr_init_done)
//===========fdma interface=======
,.fdma_waddr        (fdma_waddr)
,.fdma_wareq        (fdma_wareq)
,.fdma_wsize        (fdma_wsize)                                     
,.fdma_wbusy        (fdma_wbusy)
,.fdma_wdata		(fdma_wdata)
,.fdma_wvalid       (fdma_wvalid)


,.fdma_raddr        (fdma_raddr)
,.fdma_rareq        (fdma_rareq)
,.fdma_rsize        (fdma_rsize)                                     
,.fdma_rbusy        (fdma_rbusy)
,.fdma_rdata		(fdma_rdata)
,.fdma_rvalid       (fdma_rvalid)

//===========ddr interface===============
,.sdr_init_done   	(sdr_init_done)
,.sdr_init_ref_vld	(sdr_init_ref_vld)
	
,.app_wr_en       	(app_wr_en)
,.app_wr_addr     	(app_wr_addr) 
,.app_wr_dm       	(app_wr_dm)
,.app_wr_din     	(app_wr_din)
	
,.app_rd_en       	(app_rd_en)
,.app_rd_addr     	(app_rd_addr)
,.sdr_rd_en       	(sdr_rd_en)
,.sdr_rd_dout       (sdr_rd_dout)
,.sdr_busy			(sdr_busy)
);

sdr_as_ram  #( .self_refresh_open(1'b1))
	u2_ram( 
		.Sdr_clk(sdram_clk0),
		.Sdr_clk_sft(sdram_clk180),
		.Rst(~rst_cnt[15] ),
			  			  
		.Sdr_init_done(sdr_init_done),
		.Sdr_init_ref_vld(Sdr_init_ref_vld),
		.Sdr_busy(sdr_busy),
		
		.App_ref_req(1'b0),
		
        .App_wr_en(app_wr_en), 
        .App_wr_addr(app_wr_addr),  	
		.App_wr_dm(app_wr_dm),
		.App_wr_din(app_wr_din),

		.App_rd_en(app_rd_en),
		.App_rd_addr(app_rd_addr),
		.Sdr_rd_en	(sdr_rd_en),
		.Sdr_rd_dout(sdr_rd_dout),
	
		.SDRAM_CLK(SDRAM_CLK),
		.SDR_RAS(RAS_N),
		.SDR_CAS(CAS_N),
		.SDR_WE(WE_N),
		.SDR_BA(BA),
		.SDR_ADDR(ADDR),
		.SDR_DM(DM),
		.SDR_DQ(DQ)	
	);

	IS42s32200 sdram(
		.Clk(SDRAM_CLK),
		.Ras_n(RAS_N),
		.Cas_n(CAS_N),
		.We_n(WE_N),
		.Addr(ADDR[10:0]),
		.Ba(BA),
		.Dq(DQ),
		.Cs_n(1'b0),
		.Dqm(DM),
		.Cke(1'b1)
		);
uivtc_hdmi#
(
.H_ActiveSize(640),          //视频时间参数,行视频信号，一行有效(需要显示的部分)像素所占的时钟数，一个时钟对应一个有效像素
.H_SyncStart(640+16),        //视频时间参数,行同步开始，即多少时钟数后开始产生行同步信号 
.H_SyncEnd(640+16+96),       //视频时间参数,行同步结束，即多少时钟数后停止产生行同步信号，之后就是行有效数据部分
.H_FrameSize(640+16+96+44), //视频时间参数,行视频信号，一行视频信号总计占用的时钟数
.V_ActiveSize(20),          //视频时间参数,场视频信号，一帧图像所占用的有效(需要显示的部分)行数量，通常说的视频分辨率即H_ActiveSize*V_ActiveSize
.V_SyncStart(20+9),         //视频时间参数,场同步开始，即多少行数后开始产生场同步信号 
.V_SyncEnd (20+9+5),        //视频时间参数,场同步结束，多少行后停止产生长同步信号
.V_FrameSize(20+9+5+28)     //视频时间参数,场视频信号，一帧视频信号总计占用的行数量    
)
uivtc_inst1
(
 .vtc_rstn_i(sdr_init_done)
,.vtc_clk_i(clk25m)
,.vtc_vs_o(R_FS_i)
,.vtc_hs_o()
,.vtc_de_o(R_rden_i)	

,.vtc2_offset_x(0)
,.vtc2_offset_y(0)
,.vtc2_de_o()
);

endmodule
