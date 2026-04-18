
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

//***********spi Digital tube display controller ***********//
module ui_displed#
(
parameter CLK_DIV = 100 
)
(
input  clk_i,//system clock
input  rstn_i,//reset
output spi_sclk_o,//hc595 shift clock
output spi_mosi_o,//hc595 serial data
output hc595_lach_o,//hc595 data loaded into output register
input  [3:0]disp_led0,//Display LED0
input  [3:0]disp_led1,//Display LED1
input  [3:0]disp_led2,//Display LED2
input  [3:0]disp_led3,//Display LED3
input  [3:0]disp_led4,//Display LED4
input  [3:0]disp_led5,//Display LED5
input  [3:0]disp_led6,//Display LED6
input  [3:0]disp_led7 //Display LED7
);

//Nixie tube truth table	
localparam 
			DS_0   		= 8'hC0,
			DS_1    	= 8'hF9,
			DS_2    	= 8'hA4,
			DS_3  		= 8'hB0,
			DS_4   		= 8'h99,
			DS_5   		= 8'h92,
			DS_6    	= 8'h82,
			DS_7  		= 8'hf8,
			DS_8  		= 8'h80,
			DS_9   		= 8'h90,
        	DS_A  	  	= 8'h88,	
        	DS_B 	  	= 8'h83,	
        	DS_C 	  	= 8'hc6,        
        	DS_D 	  	= 8'ha1,
        	DS_E 	  	= 8'h86,        
        	DS_F 	  	= 8'h8e,
        	DS_BC_ON  	= 8'hbf,//b c on
        	DS_BC_OFF 	= 8'hff;//b c off	

reg [7:0]	spi_tx_data = 8'd0;
reg 		spi_tx_req 	= 1'b0;
wire 		spi_busy;
reg 		lach595 	= 1'b0;
reg [3:0]	M_S  		= 4'd0;

reg [2:0]	disp_num 	= 2'd0;
reg [7:0]	disp_led_n  = 4'd0;
reg [3:0]	disp_led	= 4'd0;
reg [7:0]	disp_truth_value = 8'd0;
wire 		disp_en ;

assign hc595_lach_o = lach595; 
assign disp_en 		= (M_S == 4'd15);

//Dynamic gating digital tube
always @(posedge clk_i)begin 
    if(!rstn_i)
         disp_num <= 3'd0;
     else if( disp_en ) 
         disp_num <= disp_num + 1'b1; 	
end

always @(posedge clk_i) begin
    if(!rstn_i)begin
        spi_tx_req 	<= 1'b0;
        spi_tx_data <= 8'd0;
        lach595 	<= 1'b0;
        M_S 		<= 4'd0;
    end
    else begin
        case(M_S)
            0:if(!spi_busy)begin //Bus not busy start transfer
               spi_tx_req 		<= 1'b1;
               spi_tx_data 		<= disp_led_n;
               M_S 				<= 4'd1;   
            end
            1:if(spi_busy)begin
            	spi_tx_req 		<= 1'b0;
            	M_S 			<= 4'd2;
            end
            2:if(!spi_busy)begin //Bus not busy start transfer
                spi_tx_req 		<= 1'b1;
                spi_tx_data 	<= disp_truth_value;
                M_S 			<= 4'd3;   
            end
            3:if(spi_busy)begin
            	spi_tx_req 		<= 1'b0;
            	M_S 			<= 4'd4;
            end
        	4:if(!spi_busy)begin//launch data to hc595 output register
                lach595 		<= 1'b1;
                M_S 			<= 4'd5;
            end
            5,6,7,8,9,10,11,12,13,14:begin//Delay some clocks to meet launch timing requirements
                M_S <= M_S + 1'b1;
            end 
            15:begin
                lach595 <= 1'b0;
                M_S <= 4'd0;
            end 
            default:M_S <= 4'd0;    
        endcase
     end
end   

//Dynamic gating digital tube,hc595 first data
always @(*)begin
			case ( disp_num ) 
			0:
			begin disp_led <= disp_led0;disp_led_n <= 8'b10000000;end//digital tube 0
			1:
			begin disp_led <= disp_led1;disp_led_n <= 8'b01000000;end//digital tube 1
			2:
			begin disp_led <= disp_led2;disp_led_n <= 8'b00100000;end//digital tube 2
			3:
			begin disp_led <= disp_led3;disp_led_n <= 8'b00010000;end//digital tube 3
            4:
			begin disp_led <= disp_led4;disp_led_n <= 8'b00001000;end//digital tube 4
			5:
			begin disp_led <= disp_led5;disp_led_n <= 8'b00000100;end//digital tube 5
			6:
			begin disp_led <= disp_led6;disp_led_n <= 8'b00000010;end//digital tube 6
			7:
			begin disp_led <= disp_led7;disp_led_n <= 8'b00000001;end//digital tube 7
			endcase
end

//Dynamic gating digital tube,hc595 second data      
always @(*)begin
			case( disp_led ) 
				4'h0: disp_truth_value <= DS_0; 
				4'h1: disp_truth_value <= DS_1;
				4'h2: disp_truth_value <= DS_2;
				4'h3: disp_truth_value <= DS_3;
				4'h4: disp_truth_value <= DS_4;
				4'h5: disp_truth_value <= DS_5;
				4'h6: disp_truth_value <= DS_6;
				4'h7: disp_truth_value <= DS_7;
				4'h8: disp_truth_value <= DS_8;
				4'h9: disp_truth_value <= DS_9;
                4'ha: disp_truth_value <= DS_BC_ON;
                4'hb: disp_truth_value <= DS_BC_OFF;                        
				default : disp_truth_value <= disp_truth_value; 
			endcase
end

//spi master controller
ui_mspi_tx#
(
.CLK_DIV(CLK_DIV),
.CPOL(1'b0),
.CPHA(1'b0)
)
ui_mspi_tx_inst(
.clk_i(clk_i),
.rstn_i(rstn_i),
.spi_mosi_o(spi_mosi_o),
.spi_sclk_o(spi_sclk_o),
.spi_tx_req_i(spi_tx_req),
.spi_tx_data_i(spi_tx_data),
.spi_busy_o(spi_busy)
 );

endmodule
