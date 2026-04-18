
/*******************************MILIANKE*******************************
*Company : MiLianKe Electronic Technology Co., Ltd.
*WebSite:https://www.milianke.com
*TechWeb:https://www.uisrc.com
*tmall-shop:https://milianke.tmall.com
*jd-shop:https://milianke.jd.com
*taobao-shop1: https://milianke.taobao.com
*Create Date: 2021/10/15
*Module Name:ds1337
*File Name:ds1337.v
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
*3) IO_ input output
*4) S_ system internal signal
*5) _n activ low
*6) _dg debug signal 
*7) _r delay or register
*8) _s state mechine
*********************************************************************/

`timescale 1ns / 1ns//仿真时间刻度/精度

module rtc_clock_ds1337#
(
parameter SYSCLKHZ   =  25_000_000 //定义系统时钟
)
(
input  wire I_sysclk, //系统时钟输入
output wire O_iic_scl,  //I2C总线，SCL时钟
inout  wire IO_iic_sda, //I2C总线，SDA数据
output wire O_uart_tx   //UART串行发送总线
);

localparam T1000MS_CNT   =  (SYSCLKHZ-1); //定义访问RTC的时间间隔为1000MS
localparam [7:0] RTC_DEV_ADDR =  8'b1101_0000;

reg [8 :0]  rst_cnt       = 9'd0;//上电延迟复位
reg [29:0]  t_cnt = 30'd0;//定时计数器
wire t_en = (t_cnt==T1000MS_CNT);//定时使能  

wire [23:0] wr_data;//写数据信号
wire [23:0] rd_data;//读数据信号
wire        iic_busy;//I2C总线忙
reg  [7 :0] wr_cnt = 8'd0;//写数据计数器
reg  [7 :0] rd_cnt = 8'd0;//读数据计数器
reg         iic_req = 1'b0;//i2c 控制器请求信号
reg  [2 :0] TS_S   = 3'd0;//状态机

reg  [7 :0] rtc_addr;//RTC的寄存器地址
reg         wr_done = 1'b0; //写RTC初值完成信号
          
//初始化时间的BDC码，12:00:00
wire [7 :0] WSecond = {4'd0,4'd0};//妙
wire [7 :0] WMinute = {4'd0,4'd0};//分
wire [7 :0] WHour   = {4'd1,4'd2};//时
reg  [23:0] rtime   = 24'd0; //用于保存读取的时间，格式为BCD码

assign wr_data   = {WHour,WMinute,WSecond};//写数据初值

//**********上电延迟复位***************************/
always@(posedge I_sysclk) begin
    if(!rst_cnt[8]) 
        rst_cnt <= rst_cnt + 1'b1;
end

//**********500ms定时计数器**********************/
always@(posedge I_sysclk) begin
    if(t_cnt == T1000MS_CNT) 
        t_cnt <= 0;
    else 
        t_cnt <= t_cnt + 1'b1;
end

//读写RTC时钟芯片状态机
always@(posedge I_sysclk) begin
    if(!rst_cnt[8])begin//复位初始化寄存器
        rtc_addr <= 8'd0;
        iic_req  <= 1'b0;
        wr_done  <= 1'b0;
        rd_cnt   <= 8'd0; 
        wr_cnt   <= 8'd0;
        TS_S     <= 2'd0;    
    end
    else begin
        case(TS_S)
        0:if(wr_done == 1'b0)begin//上电后，wr_done=0，对RTC时间寄存器初始化，给定初始时间
            wr_done  <= 1'b1;//设置wr_done=1
            rtc_addr <= 8'd0;//设置需要访问的寄存器起始地址
            TS_S     <= 3'd1;//下一个状态
        end
        else begin //已经对RTC芯片初始化完成
            iic_req  <= 1'b0; //重置 iic_req =0
            if(t_en)//每间隔1000ms进行一次读操作
            TS_S     <= 3'd3;//下一个状态，进入读寄时间寄存器状态机
        end
        1:if(!iic_busy)begin//当总线非忙，才可以操作I2C控制器
            iic_req  <= 1'b1;//请求操作I2C控制器
            rd_cnt   <= 8'd0;//由于本操作是写数据，不需要读数据，读数据寄存器设置0 
            wr_cnt   <= 8'd5;//需要写入5 BYTES,包括1字节的器件地址，1字节的寄存器起始地址，3字节的BCD时间参数
            TS_S     <= 3'd2;//下一个状态机
        end
        2:if(iic_busy)begin//等待总线忙
            iic_req  <= 1'b0;//重置 iic_req =0
            TS_S     <= 3'd3;//下一个状态机   
        end
        3:if(!iic_busy)begin//该状态读RTC时间寄存器
            iic_req  <= 1'b1;//请求操作I2C控制器
            rtc_addr <= 8'd0;//读RTC寄存器的起始地址
            wr_cnt   <= 8'd2;//读操作需要些1BYTE器件地址，1BYTE 寄存器起始地址
            rd_cnt   <= 8'd3;//读取3个时间寄存器 
            TS_S     <= 3'd4;//下一个状态    
        end 
        4:if(iic_busy)begin//等待总线空闲
            iic_req  <= 1'b0;//重置 iic_req =0
            TS_S     <= 3'd0;//下一个状态    
        end   
        default: TS_S    <= 3'd0;//default状态回到0
    endcase
   end
end

//***********保存从RTC读取到的时间寄存器，时间为BCD格式***********//
always@(posedge I_sysclk) begin
    if(!rst_cnt[8])
        rtime <=0;
   else if(TS_S == 3)
        rtime[23: 0] <= rd_data;//读取的时间包括 时:分：秒，BCD格式
end

//例化I2C控制模块
uii2c#
(
.WMEN_LEN(5),//最大支持一次写入4BYTE(包含器件地址)
.RMEN_LEN(3),//最大支持一次读出3BYTE
.CLK_DIV(SYSCLKHZ/100000)//100KHZ I2C总线时钟
)
uii2c_inst
(
.I_clk(I_sysclk),//系统时钟
.I_rstn(rst_cnt[8]),//系统复位
.O_iic_scl(O_iic_scl),//I2C SCL总线时钟
.IO_iic_sda(IO_iic_sda),//I2C SDA数据总线
.I_wr_data({wr_data,rtc_addr,RTC_DEV_ADDR}),//写数据寄存器
.I_wr_cnt(wr_cnt),//需要写的数据BYTES
.O_rd_data(rd_data), //读数据寄存器
.I_rd_cnt(rd_cnt),//需要读的数据BYTES
.I_iic_req(iic_req),//I2C控制器请求
.I_iic_mode(1'b1),//读模式
.O_iic_busy(iic_busy)//I2C控制器忙
//.iic_bus_error(iic_bus_error),//总线错误信号标志
//.IO_iic_sda_dg(IO_iic_sda_dg)//debug IO_iic_sda
); 

//以下完成BCD码赚ASCII码，这样通过串口打印可以方便观察
function signed[7:0] ascii ;   //定义ascii码转换函数，只需要转换BCD数据 
    
input[7:0] bcd; //输入参数  

begin                                                    
    case(bcd)
    0 :     ascii   =   {8'h30};//ascii 码0  
    1 :     ascii   =   {8'h31};//ascii 码1      
    2 :     ascii   =   {8'h32};//ascii 码2  
    3 :     ascii   =   {8'h33};//ascii 码3
    4 :     ascii   =   {8'h34};//ascii 码4  
    5 :     ascii   =   {8'h35};//ascii 码5          
    6 :     ascii   =   {8'h36};//ascii 码6  
    7 :     ascii   =   {8'h37};//ascii 码7  
    8 :     ascii   =   {8'h38};//ascii 码8  
    9 :     ascii   =   {8'h39};//ascii 码9
    default:ascii   =   {8'h00};    
    endcase                                
end  
                                                    
endfunction   

//例化UART发送模块
uart_tx_block u_uart_tx_block
(
.I_sysclk(I_sysclk),//系统时钟输入
.O_uart_tx(O_uart_tx),//UART 串行总线数据发送
//高位，8'h0a,8'h0d，为回车+换行控制字符
.I_uart_tx_buf({8'h0a,8'h0d,ascii(rtime[3:0]),ascii(rtime[7:4]),8'h2d,ascii(rtime[11:8]),ascii(rtime[15:12]),8'h2d,ascii(rtime[19:16]),ascii(rtime[23:20])}),
.I_uart_tx_buf_en(t_en)//t_en也是发送使能
);

endmodule
