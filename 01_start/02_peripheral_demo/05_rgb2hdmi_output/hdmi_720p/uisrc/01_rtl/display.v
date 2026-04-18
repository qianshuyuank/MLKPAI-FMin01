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
*1) I_ input
*2) O_ output
*3) _n activ low
*4) _dg debug signal 
*5) _r delay or register
*6) _s state mechine
*********************************************************************/
`timescale 1ns / 1ns

module display(
input  I_sysclk,//系统时钟输入
output O_HDMI_CLK_P,//HDMI输出时钟P端
output O_HDMI_CLK_N,//HDMI输出时钟N端
output [2:0]O_HDMI_TX_P,//HDMI输出数据P端
output [2:0]O_HDMI_TX_N //HDMI输出数据N端
);

wire clk_25m; 
wire vid_rst,vid_clk,vid_vs,vid_hs,vid_de;//vtc vid 相关信号
wire pclkx1,pclkx5,locked;//HDMI输出需要2个时钟，pclkx1是和内部视频同步的时钟，pclkx5是HDMI IP内部用于产生输出数据和输出时钟
wire [7 :0]	rgb_r ,rgb_g ,rgb_b;//定义寄存器保存图像的颜色数据
assign vid_clk = pclkx1;//内部像素时钟
assign vid_rst = locked;//用PLL的LOCK信号复位


reg	[7:0]	rst_cnt=0;	
always @(posedge I_sysclk)
begin
	if (rst_cnt[7])
		rst_cnt <=  rst_cnt;
	else
		rst_cnt <= rst_cnt+1'b1;
end

//PLL时钟管理IP 输出 pclkx1和pclkx5以及locked信号
clk_hdmi_pll clk_hdmi_pll_inst(
.refclk(I_sysclk),//系统时钟输入
.reset(!rst_cnt[7]),
.extlock(locked),//PLL LOCKED
.clk0_out(clk_25m),
.clk1_out(pclkx1),//像素时钟
.clk2_out(pclkx5) //HDMI IO的serdes 时钟 5倍的像素时钟
); 

//hdmi 输出IP
uihdmitx #
(
.FAMILY("EG4")			
)
uihdmitx_inst
(
.RSTn_i(locked),//异步复位信号，高电平有效
.HS_i(vid_hs),//RGB输入hs行同步
.VS_i(vid_vs),//RGB输入vs场同步
.DE_i(vid_de),//RGB输入de有效
.RGB_i({rgb_r,rgb_g,rgb_b}), //视频输入数据
.PCLKX1_i(pclkx1),//像素时钟
.PCLKX5_i(pclkx5),//串行发送时钟
.HDMI_CLK_P(O_HDMI_CLK_P),//HDMI时钟通道
//.HDMI_CLK_N(O_HDMI_CLK_N),
.HDMI_TX_P(O_HDMI_TX_P)//HDMI数据通道
//.HDMI_TX_N(O_HDMI_TX_N)
);

uivtc#
(
.H_ActiveSize(1280),          //视频时间参数,行视频信号，一行有效(需要显示的部分)像素所占的时钟数，一个时钟对应一个有效像素
.H_SyncStart(1280+88),        //视频时间参数,行同步开始，即多少时钟数后开始产生行同步信号 
.H_SyncEnd(1280+88+44),       //视频时间参数,行同步结束，即多少时钟数后停止产生行同步信号，之后就是行有效数据部分
.H_FrameSize(1280+88+44+239), //视频时间参数,行视频信号，一行视频信号总计占用的时钟数
.V_ActiveSize(720),          //视频时间参数,场视频信号，一帧图像所占用的有效(需要显示的部分)行数量，通常说的视频分辨率即H_ActiveSize*V_ActiveSize
.V_SyncStart(720+4),         //视频时间参数,场同步开始，即多少行数后开始产生场同步信号 
.V_SyncEnd (720+4+5),        //视频时间参数,场同步结束，多少行后停止产生长同步信号
.V_FrameSize(720+4+5+28)     //视频时间参数,场视频信号，一帧视频信号总计占用的行数量    
)
uivtc_inst
(
.I_vtc_rstn(vid_rst),
.I_vtc_clk(vid_clk),
.O_vtc_vs(vid_vs),//场同步输出
.O_vtc_hs(vid_hs),//行同步输出
.O_vtc_de(vid_de)//视频数据有效
);

uitpg uitpg_inst	
(
.I_tpg_clk(vid_clk), //系统时钟
.I_tpg_vs(vid_vs),//图像的vs信号
.I_tpg_hs(vid_hs),//图像的hs信号 
.I_tpg_de(vid_de),//de数据有效信号
.O_tpg_vs(),//和vtc_vs信号一样
.O_tpg_hs(),//和vtc_hs信号一样
.O_tpg_de(),//和vtc_de信号一样
.O_tpg_data({rgb_r,rgb_g,rgb_b})//测试图像数据输出 
);

endmodule