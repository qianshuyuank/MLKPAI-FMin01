/*******************************MILIANKE*******************************
*Company : MiLianKe Electronic Technology Co., Ltd.
*WebSite:https://www.milianke.com
*TechWeb:https://www.uisrc.com
*tmall-shop:https://milianke.tmall.com
*jd-shop:https://milianke.jd.com
*taobao-shop1: https://milianke.taobao.com
*Create Date: 2019/12/17
*Module Name:uart_top
*File Name:uart_top.v
*Description: 
*The reference demo provided by Milianke is only used for learning. 
*We cannot ensure that the demo itself is free of bugs, so users 
*should be responsible for the technical problems and consequences
*caused by the use of their own products.
*Copyright: Copyright (c) MiLianKe
*All rights reserved.
*Revision: 1.0
*Signal description
*1) I_ input
*2) O_ output
*3) _n activ low
*4) _dg debug signal 
*5) _r delay or register
*6) _s state mechine
*********************************************************************/
`timescale 1ns / 1ns


module sim_top_tb;

reg   I_sysclk;
reg   I_uart_rx;
wire  O_uart_tx;

uart_top u_uart_top
(
.I_sysclk       (I_sysclk),
.I_uart_rx      (I_uart_rx),
.O_uart_tx      (O_uart_tx)
);

parameter FREQ      = 25000000;
parameter BAUD      = 115200;
parameter TBAUD     = FREQ/BAUD*40;

initial
begin
      I_sysclk  = 0;
		  I_uart_rx = 1'b1;

    	#200000 // Wait  for global reset to finish

		    #TBAUD
		    I_uart_rx = 1'b1;
		    #TBAUD
        I_uart_rx = 1'b0;//start
        //1001_0101
        #TBAUD
        I_uart_rx = 1'b1;
         #TBAUD
        I_uart_rx = 1'b0;
         #TBAUD
        I_uart_rx = 1'b1;
         #TBAUD
        I_uart_rx = 1'b0;
         #TBAUD
        I_uart_rx = 1'b1;
         #TBAUD
        I_uart_rx = 1'b0;
         #TBAUD
        I_uart_rx = 1'b0;
         #TBAUD
        I_uart_rx = 1'b1;        
         #TBAUD
        I_uart_rx = 1'b1;//stop             
         #808320
        //00000101
        I_uart_rx = 1'b0;//start
        #TBAUD
        I_uart_rx = 1'b1;
         #TBAUD
        I_uart_rx = 1'b0;
         #TBAUD
        I_uart_rx = 1'b1;
         #TBAUD
        I_uart_rx = 1'b0;
         #TBAUD
        I_uart_rx = 1'b0;
          #TBAUD
        I_uart_rx = 1'b0;
          #TBAUD
        I_uart_rx = 1'b0;
          #TBAUD
        I_uart_rx = 1'b0;        
           #TBAUD
        I_uart_rx = 1'b1;//stop   
        
           #808320
      //10000100
        I_uart_rx = 1'b0;//start
        #TBAUD
        I_uart_rx = 1'b0;
        #TBAUD
        I_uart_rx = 1'b0;
        #TBAUD
        I_uart_rx = 1'b1;
        #TBAUD
        I_uart_rx = 1'b0;
        #TBAUD
        I_uart_rx = 1'b0;
        #TBAUD
        I_uart_rx = 1'b0;
        #TBAUD
        I_uart_rx = 1'b0;
        #TBAUD
        I_uart_rx = 1'b1;           
        #TBAUD
        I_uart_rx = 1'b1;//stop                     
end
always 
    begin
        #20 I_sysclk = ~I_sysclk;
    end
    
endmodule

