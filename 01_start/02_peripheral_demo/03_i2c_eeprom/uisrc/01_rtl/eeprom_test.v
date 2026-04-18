
/*******************************MILIANKE*******************************
*Company : MiLianKe Electronic Technology Co., Ltd.
*WebSite:https://www.milianke.com
*TechWeb:https://www.uisrc.com
*tmall-shop:https://milianke.tmall.com
*jd-shop:https://milianke.jd.com
*taobao-shop1: https://milianke.taobao.com
*Create Date: 2024/08/20
*Module Name:uii2c
*File Name:uii2c.v
*Description: 
*The reference demo provided by Milianke is only used for learning. 
*We cannot ensure that the demo itself is free of bugs, so users 
*should be responsible for the technical problems and consequences
*caused by the use of their own products.
*Copyright: Copyright (c) MiLianKe
*All rights reserved.
*Revision: 1.1
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

`timescale 1ns / 1ns//仿真时间间隔/精度

module eeprom_test#
(
parameter SYSCLKHZ     =  25_000_000 //定义系统时钟25MHZ
)
(
input  wire I_sysclk,//系统时钟输入
output wire O_iic_scl,// I2C SCL时钟
inout  wire IO_iic_sda,//I2C SDA数据总线
output wire [2:0]O_test_led,//测试LED
output wire O_error_led //error LED
);
  
localparam T500MS_CNT   = (SYSCLKHZ/2-1); //定义每500ms访问一次EEPROM 

reg [8 :0]  rst_cnt      = 9'd0;//延迟复位计数器
reg [25:0]  t500ms_cnt   = 26'd0;//500ms计数器
reg [19:0]  delay_cnt    = 20'd0;//eeprom每次读写完后，延迟操作计数器
reg [2 :0]  TS_S         = 3'd0; // 读写EEPROM状态机
reg         iic_req      = 1'b0; //i2c总线，读/写请求信号
reg [31:0]  wr_data      = 32'd0;//写数据寄存器
reg [7 :0]  wr_cnt       = 8'd0;//写数据计数器
reg [7 :0]  rd_cnt       = 8'd0;//读数据计数器
wire        iic_busy; // i2c总线忙信号标志
wire [31:0] rd_data;  // i2c读数据
wire        t500ms_en;// 500ms延迟到使能

wire IO_iic_sda_dg;
wire iic_bus_error;  //i2c总线错误
reg iic_error = 1'b0; //i2c 读出数据有错误
assign O_test_led  = ~rd_data[2:0];//测试LED输出,注意硬件上LED驱动方式
assign O_error_led = ~iic_error;//通过LED显示错误标志,注意硬件上LED驱动方式
assign t500ms_en = (t500ms_cnt==T500MS_CNT);//500ms 使能信号
                
//通过内部计数器实现复位
always@(posedge I_sysclk) begin
    if(!rst_cnt[8]) 
        rst_cnt <= rst_cnt + 1'b1;
end

//I2C总线延迟间隔操作,该时间约不能低于500us,否则会导致EEPROM操作失败
always@(posedge I_sysclk) begin
    if(!rst_cnt[8])
        delay_cnt <= 0;
    else if((TS_S == 3'd0 || TS_S == 3'd2 )) 
        delay_cnt <= delay_cnt + 1'b1;
    else 
        delay_cnt <= 0;
end

//每间隔500ms状态机运行一次
always@(posedge I_sysclk) begin
    if(!rst_cnt[8])
        t500ms_cnt <= 0;
    else if(t500ms_cnt == T500MS_CNT) 
        t500ms_cnt <= 0;
    else 
        t500ms_cnt <= t500ms_cnt + 1'b1;
end

//状态机实现每次写1字节到EEPROM然后再读1字节
always@(posedge I_sysclk) begin
    if(!rst_cnt[8])begin
        iic_req   <= 1'b0;
        wr_data   <= 32'd0;
        rd_cnt    <= 8'd0; 
        wr_cnt    <= 8'd0;
        iic_error <= 1'b0;
        TS_S      <= 3'd0;    
    end
    else begin
        case(TS_S)
        0:if(!iic_busy)begin//当总线非忙，可以开始一次I2C数据操作
            iic_req <= 1'b1;//请求发送数据
            wr_data <= {8'hfe,wr_data[15:8],wr_data[15:8],8'b10100000};//数据寄存器中8'b10100000代表需要写的器件地址，第一个wr_data[15:8]代表了EEPROM内存地址，第二个wr_data[15:8]代表了写入数据
            rd_cnt  <= 8'd0; //不需要读数据
            wr_cnt  <= 8'd3; //需要写入3个BYTES数据，包含1个器件地址，1个EEPROM 寄存器地址 1个数据   
            TS_S     <= 3'd1;//进入下一个状态      
        end
        1:if(iic_busy)begin 
            iic_req  <= 1'b0; //重置iic_req=0
            TS_S     <= 3'd2;
        end
        2:if(!iic_busy&&delay_cnt[19])begin //当总线非忙，可以开始一次I2C数据操作，该时间约不能低于500us,否则会导致EEPROM操作失败
            iic_req  <= 1'b1;//请求接收数据
            rd_cnt  <= 8'd1; //需要读1个BYTE
            wr_cnt  <= 8'd2; //需要些2个BYTE(1个器件地址8'b10100000，和1个寄存器地址wr_data[15:8])(I2C控制器会自定设置读写标志位)
            TS_S    <= 3'd3;  //进入下一个状态
        end     
        3:if(iic_busy)begin 
            iic_req  <= 1'b0; //重置iic_req=0
            TS_S     <= 3'd4;
        end    
        4:if(!iic_busy)begin//当总线非忙，代表前面读数据完成
            if(wr_data[23:16] != rd_data[7:0])//比对数据是否正确
                iic_error <= 1'b1;//如果有错误，设置iic_error=1
            else 
                iic_error <= 1'b0;//如果没有错误，设置iic_error=0
                wr_data[15:8] <= wr_data[15:8] + 1'b1;//wr_data[15:8]+1 地址和数据都加1
            TS_S    <= 3'd5;
        end
        5:if(t500ms_en)begin//延迟操作后进入下一个状态
            TS_S    <= 3'd0; 
        end 
        default:
            TS_S    <= 3'd0;
    endcase
   end
end

//例化I2C控制模块
uii2c#
(
.WMEN_LEN(4),//最大支持一次写入4BYTE(包含器件地址)
.RMEN_LEN(4),//最大支持一次读出4BYTE(包含器件地址)
.CLK_DIV(124)//100KHZ I2C总线时钟
)
uii2c_inst
(
.I_clk(I_sysclk),//系统时钟
.I_rstn(rst_cnt[8]),//系统复位
.O_iic_scl(O_iic_scl),//I2C SCL总线时钟
.IO_iic_sda(IO_iic_sda),//I2C SDA数据总线
.I_wr_data(wr_data),//写数据寄存器
.I_wr_cnt(wr_cnt),//需要写的数据BYTES
.O_rd_data(rd_data), //读数据寄存器
.I_rd_cnt(rd_cnt),//需要读的数据BYTES
.I_iic_req(iic_req),//I2C控制器请求
.I_iic_mode(1'b1),//读模式
.O_iic_busy(iic_busy),//I2C控制器忙
.O_iic_bus_error(iic_bus_error)//总线错误信号标志
//.IO_iic_sda_dg(IO_iic_sda_dg)//debug IO_iic_sda
); 

endmodule
