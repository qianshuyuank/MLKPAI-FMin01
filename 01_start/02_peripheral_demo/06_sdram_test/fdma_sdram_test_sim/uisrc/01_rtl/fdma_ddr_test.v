/*******************************MILIANKE*******************************
*Company : MiLianKe Electronic Technology Co., Ltd.
*WebSite:https://www.milianke.com
*TechWeb:https://www.uisrc.com
*tmall-shop:https://milianke.tmall.com
*jd-shop:https://milianke.jd.com
*taobao-shop1: https://milianke.taobao.com
*Create Date: 2021/04/25
*Module Name:fdma_bram_test
*File Name:fdma_bram_test.v
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
`timescale 1ns / 1ps 

module fdma_ddr_test#
(
parameter  integer TEST_MEM_SIZE  	   	 = 32'd256*1024*1024,
parameter  integer TEST_MEN_ADDR_OFFSET  = 16'd512,
parameter  integer FDMA_BURST_LEN        = 16'd512,
parameter  integer M_AXI_ADDR_WIDTH      = 32,
parameter  integer M_AXI_DATA_WIDTH      = 128
)
(
input 	 wire   							sdr_busy			, //synthesis keep
input 	 wire   							fdma_clk			, //synthesis keep
input 	 wire   							fdma_rstn			,
output   wire [M_AXI_ADDR_WIDTH-1 : 0]      fdma_waddr          ,
output   reg                                fdma_wareq          ,
output   wire [15 : 0]                      fdma_wsize          ,                                     
input                                       fdma_wbusy          ,
				
output   wire [M_AXI_DATA_WIDTH-1 :0]       fdma_wdata			,
input  	 wire                               fdma_wvalid         ,
output	 wire                               fdma_wready			,

output   wire [M_AXI_ADDR_WIDTH-1 : 0]      fdma_raddr          ,
output   reg                                fdma_rareq          ,
output   wire [15 : 0]                      fdma_rsize          ,             
input                                       fdma_rbusy          ,
				
input    wire [M_AXI_DATA_WIDTH-1 :0]       fdma_rdata			,//synthesis keep
input    wire                               fdma_rvalid         ,//synthesis keep
output	 wire                               fdma_rready			,

output	 wire 							    fdma_error			,
output   wire  [2  :0] 						fdma_T_S			
);

localparam WRITE1 = 0;
localparam WRITE2 = 1;
localparam WAIT   = 2;
localparam READ1  = 3;
localparam READ2  = 4;

reg [31: 0] t_data=0;//synthesis keep
reg [15: 0] t_data_r=0;//synthesis keep
reg [21: 0] fdma_waddr_r=0;
reg [2  :0] T_S = 0;


assign fdma_wready = 1'b1;
assign fdma_rready = 1'b1;

assign fdma_wsize = FDMA_BURST_LEN - 1'b1;
assign fdma_rsize = FDMA_BURST_LEN - 1'b1;

assign fdma_waddr = fdma_waddr_r + TEST_MEN_ADDR_OFFSET;
assign fdma_raddr = fdma_waddr;

assign fdma_wdata = {t_data }; 
  
wire cwc_clk = fdma_clk; //synthesis keep
  
//delay reset
reg [8:0] rst_cnt = 0;
always @(posedge fdma_clk)
	if(fdma_rstn==1'b0)
		rst_cnt <= 9'd0;
	else if(rst_cnt[8] == 1'b0 )
         rst_cnt <= rst_cnt + 1'b1;
     else 
         rst_cnt <= rst_cnt;

always @(posedge fdma_clk)begin
    if(rst_cnt[8] == 1'b0)begin
        T_S <=0;   
        fdma_wareq  <= 1'b0; 
        fdma_rareq  <= 1'b0; 
        t_data<=0;
        fdma_waddr_r <=0;       
    end 
    else begin
        case(T_S)      
        WRITE1:begin
            if(fdma_waddr_r>= TEST_MEM_SIZE) fdma_waddr_r<=0; 
                if(!fdma_wbusy && !sdr_busy)begin
                    fdma_wareq  <= 1'b1; 
                    t_data  <= 0;
                end
                if(fdma_wareq&&fdma_wbusy)begin
                    fdma_wareq  <= 1'b0; 
                    T_S         <= WRITE2;
                end
        end
        WRITE2:begin
            if(!fdma_wbusy) begin
                 T_S <= WAIT;
                 t_data  <= 32'd0;
            end 
            else if(fdma_wvalid) begin
                t_data <= t_data + 1'b1;
            end
        end
        WAIT:begin//not needed
            T_S <= READ1;
        end
        READ1:begin
            if(!fdma_rbusy && !sdr_busy)begin
                fdma_rareq  <= 1'b1; 
                t_data   <= 0;
            end
            if(fdma_rareq&&fdma_rbusy)begin
                 fdma_rareq  <= 1'b0; 
                 T_S         <= READ2;
            end 
        end
        READ2:begin
            if(!fdma_rbusy && !sdr_busy) begin
                 T_S <= WRITE1;
                 t_data  <= 32'd0;
                 fdma_waddr_r  <= fdma_waddr_r + FDMA_BURST_LEN;
            end 
            else if(fdma_rvalid) begin
                t_data <= t_data + 1'b1;
            end
        end   
        default:
            T_S <= WRITE1;     
        endcase
    end
  end

reg [15:0] fdma_rdata_r;
reg fdma_rvalid_r;

always @(posedge fdma_clk)begin
        fdma_rvalid_r <= fdma_rvalid;
        fdma_rdata_r  <= fdma_rdata;
        t_data_r      <= t_data[15:0];
end

wire 	test_error 	 = (fdma_rvalid_r && (t_data_r[15:0] != fdma_rdata_r[15:0]));//synthesis keep
assign  fdma_error	 = test_error;
assign  fdma_T_S 	 = T_S;

//wc
//
// 
//     .probe0(fdma_wvalid),
//     .probe1(t_data_r),
//     .probe2(fdma_rvalid),
//     .probe3(fdma_rdata_r),
//     .probe4(fdma_error),
//     .clk(fdma_clk)
// );

endmodule
