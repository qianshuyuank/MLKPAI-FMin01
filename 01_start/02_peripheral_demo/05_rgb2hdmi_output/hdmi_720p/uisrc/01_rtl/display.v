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
input  I_sysclk,//绯荤粺鏃堕挓杈撳叆
output O_HDMI_CLK_P,//HDMI杈撳嚭鏃堕挓P绔?
output O_HDMI_CLK_N,//HDMI杈撳嚭鏃堕挓N绔?
output [2:0]O_HDMI_TX_P,//HDMI杈撳嚭鏁版嵁P绔?
output [2:0]O_HDMI_TX_N //HDMI杈撳嚭鏁版嵁N绔?
);

wire clk_25m; 
wire vid_rst,vid_clk,vid_vs,vid_hs,vid_de;//vtc vid 鐩稿叧淇″彿
wire pclkx1,pclkx5,locked;//HDMI杈撳嚭闇€瑕?涓椂閽燂紝pclkx1鏄拰鍐呴儴瑙嗛鍚屾鐨勬椂閽燂紝pclkx5鏄疕DMI IP鍐呴儴鐢ㄤ簬浜х敓杈撳嚭鏁版嵁鍜岃緭鍑烘椂閽?
wire [7 :0]	rgb_r ,rgb_g ,rgb_b;//瀹氫箟瀵勫瓨鍣ㄤ繚瀛樺浘鍍忕殑棰滆壊鏁版嵁
assign vid_clk = pclkx1;//鍐呴儴鍍忕礌鏃堕挓
assign vid_rst = locked;//鐢≒LL鐨凩OCK淇″彿澶嶄綅


reg	[7:0]	rst_cnt=0;	
always @(posedge I_sysclk)
begin
	if (rst_cnt[7])
		rst_cnt <=  rst_cnt;
	else
		rst_cnt <= rst_cnt+1'b1;
end

//PLL鏃堕挓绠＄悊IP 杈撳嚭 pclkx1鍜宲clkx5浠ュ強locked淇″彿
clk_hdmi_pll clk_hdmi_pll_inst(
.refclk(I_sysclk),//绯荤粺鏃堕挓杈撳叆
.reset(!rst_cnt[7]),
.extlock(locked),//PLL LOCKED
.clk0_out(clk_25m),
.clk1_out(pclkx1),//鍍忕礌鏃堕挓
.clk2_out(pclkx5) //HDMI IO鐨剆erdes 鏃堕挓 5鍊嶇殑鍍忕礌鏃堕挓
); 

//hdmi 杈撳嚭IP
uihdmitx #
(
.FAMILY("EG4")			
)
uihdmitx_inst
(
.RSTn_i(locked),//寮傛澶嶄綅淇″彿锛岄珮鐢靛钩鏈夋晥
.HS_i(vid_hs),//RGB杈撳叆hs琛屽悓姝?
.VS_i(vid_vs),//RGB杈撳叆vs鍦哄悓姝?
.DE_i(vid_de),//RGB杈撳叆de鏈夋晥
.RGB_i({rgb_r,rgb_g,rgb_b}), //瑙嗛杈撳叆鏁版嵁
.PCLKX1_i(pclkx1),//鍍忕礌鏃堕挓
.PCLKX5_i(pclkx5),//涓茶鍙戦€佹椂閽?
.HDMI_CLK_P(O_HDMI_CLK_P),//HDMI鏃堕挓閫氶亾
//.HDMI_CLK_N(O_HDMI_CLK_N),
.HDMI_TX_P(O_HDMI_TX_P)//HDMI鏁版嵁閫氶亾
//.HDMI_TX_N(O_HDMI_TX_N)
);

uivtc#
(
.H_ActiveSize(1280),          //瑙嗛鏃堕棿鍙傛暟,琛岃棰戜俊鍙凤紝涓€琛屾湁鏁?闇€瑕佹樉绀虹殑閮ㄥ垎)鍍忕礌鎵€鍗犵殑鏃堕挓鏁帮紝涓€涓椂閽熷搴斾竴涓湁鏁堝儚绱?
.H_SyncStart(1280+88),        //瑙嗛鏃堕棿鍙傛暟,琛屽悓姝ュ紑濮嬶紝鍗冲灏戞椂閽熸暟鍚庡紑濮嬩骇鐢熻鍚屾淇″彿 
.H_SyncEnd(1280+88+44),       //瑙嗛鏃堕棿鍙傛暟,琛屽悓姝ョ粨鏉燂紝鍗冲灏戞椂閽熸暟鍚庡仠姝骇鐢熻鍚屾淇″彿锛屼箣鍚庡氨鏄鏈夋晥鏁版嵁閮ㄥ垎
.H_FrameSize(1280+88+44+239), //瑙嗛鏃堕棿鍙傛暟,琛岃棰戜俊鍙凤紝涓€琛岃棰戜俊鍙锋€昏鍗犵敤鐨勬椂閽熸暟
.V_ActiveSize(720),          //瑙嗛鏃堕棿鍙傛暟,鍦鸿棰戜俊鍙凤紝涓€甯у浘鍍忔墍鍗犵敤鐨勬湁鏁?闇€瑕佹樉绀虹殑閮ㄥ垎)琛屾暟閲忥紝閫氬父璇寸殑瑙嗛鍒嗚鲸鐜囧嵆H_ActiveSize*V_ActiveSize
.V_SyncStart(720+4),         //瑙嗛鏃堕棿鍙傛暟,鍦哄悓姝ュ紑濮嬶紝鍗冲灏戣鏁板悗寮€濮嬩骇鐢熷満鍚屾淇″彿 
.V_SyncEnd (720+4+5),        //瑙嗛鏃堕棿鍙傛暟,鍦哄悓姝ョ粨鏉燂紝澶氬皯琛屽悗鍋滄浜х敓闀垮悓姝ヤ俊鍙?
.V_FrameSize(720+4+5+28)     //瑙嗛鏃堕棿鍙傛暟,鍦鸿棰戜俊鍙凤紝涓€甯ц棰戜俊鍙锋€昏鍗犵敤鐨勮鏁伴噺    
)
uivtc_inst
(
.I_vtc_rstn(vid_rst),
.I_vtc_clk(vid_clk),
.O_vtc_vs(vid_vs),//鍦哄悓姝ヨ緭鍑?
.O_vtc_hs(vid_hs),//琛屽悓姝ヨ緭鍑?
.O_vtc_de(vid_de)//瑙嗛鏁版嵁鏈夋晥
);

uitpg uitpg_inst	
(
.I_tpg_clk(vid_clk), //绯荤粺鏃堕挓
.I_tpg_vs(vid_vs),//鍥惧儚鐨剉s淇″彿
.I_tpg_hs(vid_hs),//鍥惧儚鐨刪s淇″彿 
.I_tpg_de(vid_de),//de鏁版嵁鏈夋晥淇″彿
.O_tpg_vs(),//鍜寁tc_vs淇″彿涓€鏍?
.O_tpg_hs(),//鍜寁tc_hs淇″彿涓€鏍?
.O_tpg_de(),//鍜寁tc_de淇″彿涓€鏍?
.O_tpg_data({rgb_r,rgb_g,rgb_b})//娴嬭瘯鍥惧儚鏁版嵁杈撳嚭 
);

endmodule
