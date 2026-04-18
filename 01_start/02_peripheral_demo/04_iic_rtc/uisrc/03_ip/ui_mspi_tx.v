
//////////////////////////////////////////////////////////////////////////////////
/*******************************MILIANKE*******************************
*Company : MiLianKe Electronic Technology Co., Ltd.
*WebSite:https://www.milianke.com
*TechWeb:https://www.uisrc.com
*tmall-shop:https://milianke.tmall.com
*jd-shop:https://milianke.jd.com
*taobao-shop1: https://milianke.taobao.com
*Create Date: 2021/10/15
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
`timescale 1ns / 1ps

module ui_mspi_tx#
(
parameter CLK_DIV = 100,
parameter CPOL = 1'b0,
parameter CPHA = 1'b0
)
(
input 		clk_i,
input		rstn_i,
output 		spi_mosi_o,
output 		spi_sclk_o,
input  		spi_tx_req_i,
input [7:0] spi_tx_data_i,
output 		spi_busy_o
);

localparam [9:0] SPI_DIV     = CLK_DIV;//second clock edge counter
localparam [9:0] SPI_DIV1    = SPI_DIV/2;//first clock edge counter

reg [9:0] 	clk_div  = 10'd0;	
reg  		spi_en   = 1'b0;
reg     	spi_clk  = 1'b0;
reg [3:0] 	tx_cnt 	 = 4'd0;
reg [7:0] 	spi_tx_data_r=8'd0;
wire 		clk_end;
wire 		clk_en1;//first internal clock edge enable
wire 		clk_en2;//second internal clock edge enable
reg         spi_strobe_en;
wire 		spi_strobe;//CPHA=0 data is transmitted on the first clock edge, CPHA=1 data is transmitted on the second clock edge


assign 		clk_en1    	= (clk_div == SPI_DIV1);//first internal clock edge enable
assign 		clk_en2    	= (clk_div == SPI_DIV);//second internal clock edge enable
assign 		clk_end 	= (clk_div == SPI_DIV1)&&(tx_cnt==4'd8);//The counter sends the first internal clock 0 to 7 times, and when the count reaches the last 8, the clock is not sent
//When CPHA=0, the first SCLK transition edge of the data is sampled, so the data update is on the second transition edge
//When CPHA=1, the second SCLK transition edge of the data is sampled, so the data update is on the first transition edge
assign 		spi_strobe 	= CPHA ? clk_en1&spi_strobe_en : clk_en2&spi_strobe_en ;
assign 		spi_sclk_o  = (CPOL == 1'b1) ? ~spi_clk : spi_clk;//Set the initial level of the SPI clock
assign 		spi_mosi_o  = spi_tx_data_r[7];
assign 		spi_busy_o  = spi_en;

//clock division
always@(posedge clk_i)begin
    if(spi_en == 1'b0)
        clk_div <= 10'd0;
    else if(clk_div < SPI_DIV)
        clk_div <= clk_div + 1'b1;
    else 
    	clk_div <= 0;	
end
//Generate spi internal clock
always@(posedge clk_i)begin
    	if(spi_en == 1'b0)
        	spi_clk <= 1'b0;
   		else if(clk_en2) 
            spi_clk <= 1'b0;//second clock edge
    	else if(clk_en1&&(tx_cnt<4'd8))//first clock edge
            spi_clk <= 1'b1; 
end


always@(posedge clk_i)begin  
          if(rstn_i == 1'b0) 
             spi_strobe_en <= 1'b0;
          else if(tx_cnt < 4'd8)begin
               if(clk_en1) spi_strobe_en <= 1'b1;    
          end 
          else 
               spi_strobe_en <= 1'b0;         
end


always@(posedge clk_i)begin  
          if((rstn_i == 1'b0)||(spi_en == 1'b0)) 
             tx_cnt <= 4'd0;
          else if(clk_en1) 
             tx_cnt <= tx_cnt + 1'b1;      
end

//spi sending module
always@(posedge clk_i)begin
	if(rstn_i == 1'b0 || clk_end)begin
        spi_en <= 1'b0;
        spi_tx_data_r <= 8'h00;
    end
    else if(spi_tx_req_i&&(spi_en == 1'b0)) begin//enable transfer
        	spi_en <= 1'b1;
        	spi_tx_data_r <= spi_tx_data_i;
    end
    else if(spi_en)begin
         spi_tx_data_r[7:0] <= (spi_strobe) ? {spi_tx_data_r[6:0],1'b1} : spi_tx_data_r;
    end
 
end   



endmodule

