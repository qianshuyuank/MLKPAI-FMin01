
/*******************************MILIANKE*******************************
*Company : MiLianKe Electronic Technology Co., Ltd.
*WebSite:https://www.milianke.com
*TechWeb:https://www.uisrc.com
*tmall-shop:https://milianke.tmall.com
*jd-shop:https://milianke.jd.com
*taobao-shop1: https://milianke.taobao.com
*Create Date: 2019/12/17
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
`timescale 1ns / 1ns


module uart_tx_block
(
input I_sysclk,
output O_uart_tx,
input [79:0] I_uart_tx_buf,
input  I_uart_tx_buf_en
);


wire     uart_rstn_i;
wire     uart_wbusy;
reg      t1s_dly_en;
reg[1:0] S_UART_TX;
reg[3:0] tx_index;
reg      uart_wreq;    
reg[7:0] uart_wdata;

reg [15:0]rst_cnt = 16'd0;

assign uart_rstn_i = rst_cnt[15];

//Power-on Reset Delay
always @(posedge I_sysclk)begin
    rst_cnt <= (rst_cnt[15] == 1'b0) ? (rst_cnt + 1'b1) : rst_cnt ;
end

always @(posedge I_sysclk)begin
    if(uart_rstn_i==1'b0)begin
        uart_wdata    <= 8'd0;
        uart_wreq     <= 1'b0;
        S_UART_TX     <= 2'd0;
        tx_index      <= 4'd0;
    end
    else begin
        case(S_UART_TX)
        0:if(!uart_wbusy && I_uart_tx_buf_en)begin
            tx_index <= 0;
            S_UART_TX <= 2'd1;
        end
        1:begin
            if(!uart_wbusy)begin//When the bus is not busy, request to send
                uart_wdata <= I_uart_tx_buf[(tx_index*8) +: 8];
                uart_wreq <= 1'b1;
            end
            else begin
                uart_wreq <= 1'b0;
                S_UART_TX <= 2'd2;
            end
        end
        2:begin//wait for the bus to be free
            S_UART_TX <= (uart_wbusy == 1'b0) ? 2'd3: S_UART_TX;
        end 
        3:begin//update index
            if(tx_index < 9)begin
                tx_index <= tx_index + 1'b1;
                S_UART_TX  <= 2'd1;
            end
            else begin
                tx_index   <= 4'd0;
                S_UART_TX  <= 2'd0; 
            end 
        end
        endcase
    end   
    
end

//uart send controller   
uiuart_tx#
(
.BAUD_DIV(25000000/115200 -1)    
)
uart_tx_u 
(
.I_clk(I_sysclk),
.I_uart_rstn(uart_rstn_i), 
.I_uart_wreq(uart_wreq), 
.I_uart_wdata(uart_wdata), 
.O_uart_wbusy(uart_wbusy),
.O_uart_tx(O_uart_tx)
);
    
endmodule

