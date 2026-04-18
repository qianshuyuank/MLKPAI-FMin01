
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

module cam_test
(
input 	 wire   		I_sysclk  ,

input 	 wire 		    I_cmos_pclk,
input 	 wire 		    I_cmos_href,
input 	 wire 		    I_cmos_vsync,
input 	 wire[7:0]	    I_cmos_data,
output 	 wire 		    O_cmos_xclk,
output 	 wire			O_cmos_scl,
inout  	 wire			IO_cmos_sda,

output   wire			O_HDMI_CLK_P,
output   wire[2:0]		O_HDMI_TX_P
);

wire					ddr_pll_lock        ;
wire					sdram_clk0          ;
wire					sdram_clk180        ;
wire  					clk25m				;
wire  					clk50m				;
		
wire 					cam_de_o			;
wire 					cam_vs_o			;
wire 					cam_hs_o			;
wire 					cfg_done			;
wire [15:0] 			cam_rgb_o			;
		
		
wire 					sdr_init_done       ;
wire 					sdr_init_ref_vld    ;
wire 					app_wr_en           ;
wire [22 :0]			app_wr_addr         ;
wire [1  :0]			app_wr_dm           ;
wire [31 :0]			app_wr_din          ;
wire 					app_rd_en           ;
wire [22 :0]			app_rd_addr         ;
wire 					sdr_rd_en           ;
wire [31 :0]			sdr_rd_dout         ;
wire            		sdr_busy			;
		
wire [23: 0] 			fdma_waddr          ;
wire  	     			fdma_wareq          ;
wire [15: 0] 			fdma_wsize          ;                                    
wire         			fdma_wbusy          ;	
wire [31 :0] 			fdma_wdata			;
wire         			fdma_wvalid         ;
		
wire [23: 0] 			fdma_raddr          ;
wire         			fdma_rareq          ;
wire [15: 0] 			fdma_rsize          ;                                 
wire         			fdma_rbusy          ;
wire [31 :0] 			fdma_rdata			;
wire         			fdma_rvalid         ;
		
wire   					fdma_clk  			;
wire   					fdma_rstn 			;

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
		
wire           			R_rclk_i 			;
wire            		R_FS_i	 			;
wire            		R_rden_i 			;
wire [15 : 0]   		R_data_o			;
		
wire 					pclkx1				;
wire 					pclkx5				;
wire 					vid_pll_locked		;
		
wire 					vid_clk				;
wire 					vid_vs				;
wire 					vid_hs				;
wire 					vid_de				;
		
wire 					o_de				;
wire	[7:0]   		o_r  				;
wire	[7:0]   		o_g  				;
wire	[7:0]   		o_b  				;
		
wire	[7:0]   		rgb_b  				;
wire	[7:0]   		rgb_g  				;
wire	[7:0]   		rgb_r  				;

assign      W_wclk_i = I_cmos_pclk;
assign      W_FS_i	 = cam_vs_o;
assign      W_wren_i = cam_de_o;
assign      W_data_i = cam_rgb_o;

assign      vid_clk  = pclkx1;
assign 		vid_rst  = vid_pll_locked;

assign      R_rclk_i = vid_clk;
assign      R_FS_i	 = vid_vs;
assign      R_rden_i = vid_de;

assign  	rgb_b 	  = o_de ? o_r : 8'hff;
assign  	rgb_g 	  = o_de ? o_g : 8'h00 ;
assign  	rgb_r 	  = o_de ? o_b : 8'hff ;

reg	[15:0]	rst_cnt=0;	
reg	[24:0]	dly_cnt=0;

reg 		vid_de_r1;
reg 		vid_de_r2;

always @(posedge I_sysclk )begin
    if(ddr_pll_lock==0)
		rst_cnt <= rst_cnt+1'b1;
    else 
    	rst_cnt <= 16'hffff;	
end

pll u_pll(
.refclk             (I_sysclk         	),
.reset              (rst_cnt[15]==1'b0  ),
.extlock            (ddr_pll_lock       ),
.clk0_out           (clk50m       		),//50.000000 MHZ	| 0  DEG 
.clk1_out           (sdram_clk0         ),//150.000000MHZ	| 0  DEG 
.clk2_out           (sdram_clk180       ),//150.000000MHZ	| 180DEG 
.clk3_out           (clk25m          	)//24.000000 MHZ	| 0  DEG 
);

always @(posedge clk25m )begin	
	if(sdr_init_done==1'b0)
    	dly_cnt <=0;
    else if (dly_cnt[24])
		dly_cnt <=  dly_cnt;
	else
		dly_cnt <= dly_cnt+1'b1;
end

uicfg0308#(
.CLK_DIV(16'd239)
)
uicfg0308_inst
(
.clk_i(clk25m),
.rst_n(dly_cnt[24]),
.cmos_scl(O_cmos_scl),
.cmos_sda(IO_cmos_sda),
.cfg_done(cfg_done)
);

uiSensorRGB565 uiSensorRGB565_inst
(
.rstn_i(cfg_done),
.cmos_clk_i(clk25m),//cmos senseor clock.
.cmos_pclk_i(I_cmos_pclk),//input pixel clock.
.cmos_href_i(I_cmos_href),//input pixel hs signal.
.cmos_vsync_i(I_cmos_vsync),//input pixel vs signal.
.cmos_data_i(I_cmos_data),//data.
.cmos_xclk_o(O_cmos_xclk),//output clock to cmos sensor.
.rgb565_o(cam_rgb_o),
.de_o(cam_de_o),
.vs_o(cam_vs_o),
.hs_o(cam_hs_o)
);


uidbuf#(
.APP_DATA_WIDTH 	(32)    ,
.APP_ADDR_WIDTH 	(21)    ,

.W_BUFDEPTH     	(4096)  ,
.W_DATAWIDTH    	(16)    ,
.W_BASEADDR     	(0)     ,
.W_XSIZE        	(640)   ,
.W_YSIZE        	(480)   ,
.W_BUFSIZE        	(3)     ,

.R_BUFDEPTH     	(4096)  ,
.R_DATAWIDTH    	(16)    ,
.R_BASEADDR     	(0)     ,
.R_XSIZE        	(640)   ,
.R_YSIZE        	(480)   ,
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

	EG_PHY_SDRAM_2M_32 sdram(
		.clk(SDRAM_CLK),
		.ras_n(RAS_N),
		.cas_n(CAS_N),
		.we_n(WE_N),
		.addr(ADDR[10:0]),
		.ba(BA),
		.dq(DQ),
		.cs_n(1'b0),
		.dm0(DM[0]),
		.dm1(DM[1]),
		.dm2(DM[2]),
		.dm3(DM[3]),
		.cke(1'b1)
		);
		
hdmi_pll hdmi_pll_inst(
 .refclk(clk50m)
,.reset(ddr_pll_lock==1'b0)
,.extlock(vid_pll_locked)
,.clk0_out(pclkx1)
,.clk1_out(pclkx5)); 

uivtc#
(
.H_ActiveSize(640),          //视频时间参数,行视频信号，一行有效(需要显示的部分)像素所占的时钟数，一个时钟对应一个有效像素
.H_SyncStart(640+16),        //视频时间参数,行同步开始，即多少时钟数后开始产生行同步信号 
.H_SyncEnd(640+16+96),       //视频时间参数,行同步结束，即多少时钟数后停止产生行同步信号，之后就是行有效数据部分
.H_FrameSize(640+16+96+41), //视频时间参数,行视频信号，一行视频信号总计占用的时钟数
.V_ActiveSize(480),          //视频时间参数,场视频信号，一帧图像所占用的有效(需要显示的部分)行数量，通常说的视频分辨率即H_ActiveSize*V_ActiveSize
.V_SyncStart(480+10),         //视频时间参数,场同步开始，即多少行数后开始产生场同步信号 
.V_SyncEnd (480+10+2),        //视频时间参数,场同步结束，多少行后停止产生长同步信号
.V_FrameSize(480+10+2+33)     //视频时间参数,场视频信号，一帧视频信号总计占用的行数量    
)


uivtc_inst
(
.I_vtc_rstn(vid_rst),
.I_vtc_clk(vid_clk),
.O_vtc_vs(vid_vs),//场同步输出
.O_vtc_hs(vid_hs),//行同步输出
.O_vtc_de(vid_de)//视频数据有效
);

//*******************rgb to middiff******************************
always @(posedge vid_clk)begin
vid_de_r1 <= vid_de; 
vid_de_r2 <= vid_de_r1; 
end

image_median_filtering u_image_median_filtering
(
	.i_clk        (vid_clk        ),//input   wire		
	.i_rst_n      (vid_rst        ),//input   wire		
	.i_hsyn       (vid_hs         ),//input	wire		
	.i_vsyn       (vid_vs         ),//input	wire		
	.i_en         (vid_de_r2      ),//input	wire			
	.i_r          ({R_data_o[15:11],3'd0} ),//input	wire [7:0]	
	.i_g          ({R_data_o[11 :5],2'd0} ),//input	wire [7:0] 	
	.i_b          ({R_data_o[4 : 0],3'd0} ),//input	wire [7:0] 	
	.o_hs         (o_hsyn         ),//output	wire 		
	.o_vs         (o_vsyn         ),//output	wire 		
	.o_en         (o_de           ),//output	wire 		
	.o_r          (o_r            ),//output  wire [7:0]	
	.o_g          (o_g            ),//output  wire [7:0]	
	.o_b	      (o_b            ) //output  wire [7:0]	
);   

//************HDMI TX************************************
uihdmitx #
(
.FAMILY("EG4")			
)
uihdmitx_inst
(
.RSTn_i(vid_pll_locked),
.HS_i(vid_hs),
.VS_i(vid_vs),
.DE_i(o_de),
.RGB_i({rgb_b,rgb_g,rgb_r}),
.PCLKX1_i(pclkx1),
.PCLKX5_i(pclkx5),
.HDMI_CLK_P(O_HDMI_CLK_P),
.HDMI_TX_P(O_HDMI_TX_P)
);

endmodule

