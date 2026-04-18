
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


module eg4d_sram_fdma_test#
(
parameter  integer TEST_MEM_SIZE  	   	 = 32'd640*480,
parameter  integer TEST_MEN_ADDR_OFFSET  = 16'd0,
parameter  integer FDMA_BURST_LEN        = 16'd640,//4的整数倍
parameter  integer APP_ADDR_WIDTH        = 21,
parameter  integer APP_DATA_WIDTH        = 32
)
(
input 						clk_in	,
input						rst_n_in,
output 						led1,
output 						led2 
);

wire 						CLK  	;
wire 						CLKN 	;
wire 						CS_N 	;
wire 						CKE  	;
wire 						RAS_N	;
wire 						CAS_N	;
wire 						WE_N 	;
wire [`BA_WIDTH-1:0]		BA   	;
wire [`ROW_WIDTH-1:0]		ADDR 	;
wire [`DM_WIDTH-1:0]		DM   	;
wire [`DATA_WIDTH-1:0]		DQ   	;


wire					lock                ;
wire					rst_n               ;
wire					clk0                ;
wire					clk90               ;
wire					clk180              ;
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

wire					fdma_error			;

assign led1  = sdr_init_done ? fdma_error : 1'b1;
assign led2  = ~sdr_init_done ;

assign rst_n = !lock;

pll u_clk(
.refclk             (clk_in         ),
.reset              (!rst_n_in      ),
.extlock            (lock           ),
.clk1_out           (clk0           ),//75.000000MHZ	| 0  DEG 
.clk2_out           (clk90          ),//75.000000MHZ	| 90 DEG 
.clk3_out           (clk180         ) //75.000000MHZ	| 180DEG 
);


fdma_ddr_test#
(
.TEST_MEM_SIZE  	  (TEST_MEM_SIZE),
.TEST_MEN_ADDR_OFFSET (TEST_MEN_ADDR_OFFSET),
.FDMA_BURST_LEN       (FDMA_BURST_LEN),
.M_AXI_ADDR_WIDTH     (APP_ADDR_WIDTH),
.M_AXI_DATA_WIDTH     (APP_DATA_WIDTH)
)
fdma_ddr_test_inst0
(
.fdma_clk			(clk0	)   	   	   ,
.fdma_rstn			(sdr_init_done)  	   ,
.sdr_busy			(sdr_busy)			   ,

.fdma_waddr			(fdma_waddr)           ,
.fdma_wareq			(fdma_wareq)           ,
.fdma_wsize			(fdma_wsize)           ,                                   
.fdma_wbusy			(fdma_wbusy)           ,
				
.fdma_wdata			(fdma_wdata)		   ,
.fdma_wvalid		(fdma_wvalid)          ,
.fdma_wready		(fdma_wready)		   ,

.fdma_raddr			(fdma_raddr)           ,
.fdma_rareq			(fdma_rareq)           ,
.fdma_rsize			(fdma_rsize)           ,                                    
.fdma_rbusy			(fdma_rbusy)           ,
				
.fdma_rdata			(fdma_rdata)		   ,
.fdma_rvalid		(fdma_rvalid)          ,
.fdma_rready		(fdma_rready)		   ,

.fdma_error         (fdma_error)		   ,
.fdma_T_S           (fdma_T_S)				
);

app_fdma app_fdma_inst
(
 .fdma_clk      	(clk0) 	
,.fdma_rstn         (sdr_init_done	   )
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
		.Sdr_clk(clk0),
		.Sdr_clk_sft(clk180),
		.Rst(rst_n ),
			  			  
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
	
		.SDRAM_CLK(CLK),
		.SDR_RAS(RAS_N),
		.SDR_CAS(CAS_N),
		.SDR_WE(WE_N),
		.SDR_BA(BA),
		.SDR_ADDR(ADDR),
		.SDR_DM(DM),
		.SDR_DQ(DQ)	
	);

	IS42s32200 sdram(
		.Clk(CLK),
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

endmodule