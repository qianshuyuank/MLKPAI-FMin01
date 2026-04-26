
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
input 	 wire   	I_sys_clk,
input 	 wire   	I_sys_rstn,
output   wire		O_HDMI_CLK_P,
output   wire[2:0]	O_HDMI_TX_P

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

wire [15:0]				W_data_i			;
											
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

wire R_FS_i;
wire R_HS_i;
wire R_rden_i;//synthesis keep
reg vid_de_r;
wire [15:0] R_data_o;

reg [15:0] rst_cnt;

assign      W_wclk_i = clk25m;
assign      W_FS_i	 = vid_vs;
assign      W_wren_i = vid_de;
assign W_data_i = {rgb_r[7:3],rgb_g[7:2],rgb_b[7:3]};

assign      R_rclk_i = clk25m;

sdram_pll u_sdram_pll(
.refclk             (I_sys_clk         	),
.reset              (!I_sys_rstn	    ),
.extlock            (pll_lock       	),
.clk1_out           (sdram_clk0         ),//75.000000MHZ	| 0 DEG 
.clk2_out           (sdram_clk180       ),//75.000000MHZ	| 180DEG 
.clk3_out           (clk25m          	),//25.000000 MHZ	| 0  DEG 
.clk4_out           (clk50m          	) //50.000000 MHZ	| 0  DEG 

);

always @(posedge I_sys_clk )begin
    if(!pll_lock)
		rst_cnt <= 16'h0000;
    else if(rst_cnt[15])
    	rst_cnt <= rst_cnt;	
	else
		rst_cnt <= rst_cnt + 1'b1;
end

uivtc#
(
.H_ActiveSize(640),          //瑙嗛鏃堕棿鍙傛暟,琛岃棰戜俊鍙凤紝涓€琛屾湁鏁?闇€瑕佹樉绀虹殑閮ㄥ垎)鍍忕礌鎵€鍗犵殑鏃堕挓鏁帮紝涓€涓椂閽熷搴斾竴涓湁鏁堝儚绱?
.H_SyncStart(640+16),        //瑙嗛鏃堕棿鍙傛暟,琛屽悓姝ュ紑濮嬶紝鍗冲灏戞椂閽熸暟鍚庡紑濮嬩骇鐢熻鍚屾淇″彿 
.H_SyncEnd(640+16+96),       //瑙嗛鏃堕棿鍙傛暟,琛屽悓姝ョ粨鏉燂紝鍗冲灏戞椂閽熸暟鍚庡仠姝骇鐢熻鍚屾淇″彿锛屼箣鍚庡氨鏄鏈夋晥鏁版嵁閮ㄥ垎
.H_FrameSize(640+16+96+41), //瑙嗛鏃堕棿鍙傛暟,琛岃棰戜俊鍙凤紝涓€琛岃棰戜俊鍙锋€昏鍗犵敤鐨勬椂閽熸暟
.V_ActiveSize(480),          //瑙嗛鏃堕棿鍙傛暟,鍦鸿棰戜俊鍙凤紝涓€甯у浘鍍忔墍鍗犵敤鐨勬湁鏁?闇€瑕佹樉绀虹殑閮ㄥ垎)琛屾暟閲忥紝閫氬父璇寸殑瑙嗛鍒嗚鲸鐜囧嵆H_ActiveSize*V_ActiveSize
.V_SyncStart(480+10),         //瑙嗛鏃堕棿鍙傛暟,鍦哄悓姝ュ紑濮嬶紝鍗冲灏戣鏁板悗寮€濮嬩骇鐢熷満鍚屾淇″彿 
.V_SyncEnd (480+10+2),        //瑙嗛鏃堕棿鍙傛暟,鍦哄悓姝ョ粨鏉燂紝澶氬皯琛屽悗鍋滄浜х敓闀垮悓姝ヤ俊鍙?
.V_FrameSize(480+10+2+33)     //瑙嗛鏃堕棿鍙傛暟,鍦鸿棰戜俊鍙凤紝涓€甯ц棰戜俊鍙锋€昏鍗犵敤鐨勮鏁伴噺    
)
uivtc_inst
(
.I_vtc_rstn(sdr_init_done),
.I_vtc_clk(clk25m),
.O_vtc_vs(vid_vs),//鍦哄悓姝ヨ緭鍑?
.O_vtc_hs(vid_hs),//琛屽悓姝ヨ緭鍑?
.O_vtc_de(vid_de)//瑙嗛鏁版嵁鏈夋晥
);

uitpg uitpg_inst	
(
.I_tpg_clk(clk25m), //绯荤粺鏃堕挓
.I_tpg_vs(vid_vs),//鍥惧儚鐨剉s淇″彿
.I_tpg_hs(vid_hs),//鍥惧儚鐨刪s淇″彿 
.I_tpg_de(vid_de),//de鏁版嵁鏈夋晥淇″彿
.O_tpg_vs(),//鍜寁tc_vs淇″彿涓€鏍?
.O_tpg_hs(),//鍜寁tc_hs淇″彿涓€鏍?
.O_tpg_de(),//鍜寁tc_de淇″彿涓€鏍?
.O_tpg_data({rgb_r,rgb_g,rgb_b})//娴嬭瘯鍥惧儚鏁版嵁杈撳嚭 
);

uidbuf#(
.APP_DATA_WIDTH 	(32)    ,
.APP_ADDR_WIDTH 	(21)    ,

.W_BUFDEPTH     	(4096)  ,
.W_DATAWIDTH    	(16)    ,
.W_BASEADDR     	(0)     ,
.W_XSIZE        	(640)   ,
.W_YSIZE        	(480)   ,

.R_BUFDEPTH     	(4096)  ,
.R_DATAWIDTH    	(16)    ,
.R_BASEADDR     	(0)     ,
.R_XSIZE        	(640)   ,
.R_YSIZE        	(480)   
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

uivtc#
(
.H_ActiveSize(640),          //瑙嗛鏃堕棿鍙傛暟,琛岃棰戜俊鍙凤紝涓€琛屾湁鏁?闇€瑕佹樉绀虹殑閮ㄥ垎)鍍忕礌鎵€鍗犵殑鏃堕挓鏁帮紝涓€涓椂閽熷搴斾竴涓湁鏁堝儚绱?
.H_SyncStart(640+16),        //瑙嗛鏃堕棿鍙傛暟,琛屽悓姝ュ紑濮嬶紝鍗冲灏戞椂閽熸暟鍚庡紑濮嬩骇鐢熻鍚屾淇″彿 
.H_SyncEnd(640+16+96),       //瑙嗛鏃堕棿鍙傛暟,琛屽悓姝ョ粨鏉燂紝鍗冲灏戞椂閽熸暟鍚庡仠姝骇鐢熻鍚屾淇″彿锛屼箣鍚庡氨鏄鏈夋晥鏁版嵁閮ㄥ垎
.H_FrameSize(640+16+96+41), //瑙嗛鏃堕棿鍙傛暟,琛岃棰戜俊鍙凤紝涓€琛岃棰戜俊鍙锋€昏鍗犵敤鐨勬椂閽熸暟
.V_ActiveSize(480),          //瑙嗛鏃堕棿鍙傛暟,鍦鸿棰戜俊鍙凤紝涓€甯у浘鍍忔墍鍗犵敤鐨勬湁鏁?闇€瑕佹樉绀虹殑閮ㄥ垎)琛屾暟閲忥紝閫氬父璇寸殑瑙嗛鍒嗚鲸鐜囧嵆H_ActiveSize*V_ActiveSize
.V_SyncStart(480+10),         //瑙嗛鏃堕棿鍙傛暟,鍦哄悓姝ュ紑濮嬶紝鍗冲灏戣鏁板悗寮€濮嬩骇鐢熷満鍚屾淇″彿 
.V_SyncEnd (480+10+2),        //瑙嗛鏃堕棿鍙傛暟,鍦哄悓姝ョ粨鏉燂紝澶氬皯琛屽悗鍋滄浜х敓闀垮悓姝ヤ俊鍙?
.V_FrameSize(480+10+2+33)     //瑙嗛鏃堕棿鍙傛暟,鍦鸿棰戜俊鍙凤紝涓€甯ц棰戜俊鍙锋€昏鍗犵敤鐨勮鏁伴噺    
)
uivtc_inst1
(
.I_vtc_rstn(vid_pll_locked),
.I_vtc_clk(clk25m),
.O_vtc_vs(R_FS_i),
.O_vtc_hs(R_HS_i),
.O_vtc_de(R_rden_i)
);


//************HDMI TX************************************
hdmi_pll hdmi_pll_inst(
 .refclk(clk50m)
,.reset(pll_lock==1'b0)
,.extlock(vid_pll_locked)
,.clk0_out(pclkx1)
,.clk1_out(pclkx5)); 

wire [23:0] o_gray;//synthesis keep

wire pclkx1;//synthesis keep
wire pclkx5;
assign o_gray = {R_data_o[15:11],3'b0,R_data_o[10:5],2'b0,R_data_o[4:0],3'b0};

reg de_1;
reg de_2;

always@(posedge pclkx1)begin
	de_1 <= R_rden_i;
	de_2 <= de_1;
end




uihdmitx #
(
.FAMILY("EG4")			
)
uihdmitx_inst
(
.RSTn_i(vid_pll_locked),
.HS_i(R_HS_i),
.VS_i(R_FS_i),
.DE_i(de_2),
.RGB_i(o_gray),
.PCLKX1_i(pclkx1),
.PCLKX5_i(pclkx5),
.HDMI_CLK_P(O_HDMI_CLK_P),
//.HDMI_CLK_N(HDMI_CLK_N),
.HDMI_TX_P(O_HDMI_TX_P)
//.HDMI_TX_N(HDMI_TX_N)
);

endmodule
