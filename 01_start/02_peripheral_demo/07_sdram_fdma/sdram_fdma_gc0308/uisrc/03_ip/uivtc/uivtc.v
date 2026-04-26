
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

module uivtc#
(
parameter H_ActiveSize  =   1920,               //瑙嗛鏃堕棿鍙傛暟,琛岃棰戜俊鍙凤紝涓€琛屾湁鏁?闇€瑕佹樉绀虹殑閮ㄥ垎)鍍忕礌鎵€鍗犵殑鏃堕挓鏁帮紝涓€涓椂閽熷搴斾竴涓湁鏁堝儚绱?parameter H_FrameSize   =   1920+88+44+148,     //瑙嗛鏃堕棿鍙傛暟,琛岃棰戜俊鍙凤紝涓€琛岃棰戜俊鍙锋€昏鍗犵敤鐨勬椂閽熸暟
parameter H_SyncStart   =   1920+88,            //瑙嗛鏃堕棿鍙傛暟,琛屽悓姝ュ紑濮嬶紝鍗冲灏戞椂閽熸暟鍚庡紑濮嬩骇鐢熻鍚屾淇″彿 
parameter H_SyncEnd     =   1920+88+44,         //瑙嗛鏃堕棿鍙傛暟,琛屽悓姝ョ粨鏉燂紝鍗冲灏戞椂閽熸暟鍚庡仠姝骇鐢熻鍚屾淇″彿锛屼箣鍚庡氨鏄鏈夋晥鏁版嵁閮ㄥ垎

parameter V_ActiveSize  =   1080,               //瑙嗛鏃堕棿鍙傛暟,鍦鸿棰戜俊鍙凤紝涓€甯у浘鍍忔墍鍗犵敤鐨勬湁鏁?闇€瑕佹樉绀虹殑閮ㄥ垎)琛屾暟閲忥紝閫氬父璇寸殑瑙嗛鍒嗚鲸鐜囧嵆H_ActiveSize*V_ActiveSize
parameter V_FrameSize   =   1080+4+5+36,        //瑙嗛鏃堕棿鍙傛暟,鍦鸿棰戜俊鍙凤紝涓€甯ц棰戜俊鍙锋€昏鍗犵敤鐨勮鏁伴噺
parameter V_SyncStart   =   1080+4,             //瑙嗛鏃堕棿鍙傛暟,鍦哄悓姝ュ紑濮嬶紝鍗冲灏戣鏁板悗寮€濮嬩骇鐢熷満鍚屾淇″彿 
parameter V_SyncEnd     =   1080+4+5            //瑙嗛鏃堕棿鍙傛暟,鍦哄悓姝ョ粨鏉燂紝鍗冲灏戝満鏁板悗鍋滄浜х敓鍦哄悓姝ヤ俊鍙凤紝涔嬪悗灏辨槸鍦烘湁鏁堟暟鎹儴鍒?)
(
input           I_vtc_rstn,//绯荤粺澶嶄綅
input			I_vtc_clk,//绯荤粺鏃堕挓
output	reg		O_vtc_vs,//鍦哄悓姝ヨ緭鍑?output  reg     O_vtc_hs,//琛屽悓姝ヨ緭鍑?output  reg     O_vtc_de//瑙嗛鏁版嵁鏈夋晥 
);

reg [11:0] hcnt = 12'd0;    //瑙嗛姘村钩鏂瑰悜锛屽垪璁℃暟鍣紝瀵勫瓨鍣?reg [11:0] vcnt = 12'd0;    //瑙嗛鍨傜洿鏂瑰悜锛岃璁℃暟鍣紝瀵勫瓨鍣?  
reg [2 :0] rst_cnt = 3'd0;  //澶嶄綅璁℃暟鍣紝瀵勫瓨鍣?wire rst_sync = rst_cnt[2]; //鍚屾澶嶄綅

//閫氳繃璁℃暟鍣ㄤ骇鐢熷悓姝ュ浣?always @(posedge I_vtc_clk)begin
    if(!I_vtc_rstn)
        rst_cnt <= 3'd0;
    else if(rst_cnt[2] == 1'b0)
        rst_cnt <= rst_cnt + 1'b1;
end    

//瑙嗛姘村钩鏂瑰悜锛屽垪璁℃暟鍣?always @(posedge I_vtc_clk)begin
    if(rst_sync == 1'b0) //澶嶄綅
        hcnt <= 12'd0;
    else if(hcnt < (H_FrameSize - 1'b1))//璁℃暟鑼冨洿浠? ~ H_FrameSize-1
        hcnt <= hcnt + 1'b1;
    else 
        hcnt <= 12'd0;
end   

//瑙嗛鍨傜洿鏂瑰悜锛岃璁℃暟鍣紝鐢ㄤ簬璁℃暟宸茬粡瀹屾垚鐨勮瑙嗛淇″彿
always @(posedge I_vtc_clk)begin
    if(rst_sync == 1'b0)
        vcnt <= 12'd0;
    else if(hcnt == (H_ActiveSize  - 1'b1)) begin//瑙嗛姘村钩鏂瑰悜锛屾槸鍚︿竴琛岀粨鏉?           vcnt <= (vcnt == (V_FrameSize - 1'b1)) ? 12'd0 : vcnt + 1'b1;//瑙嗛鍨傜洿鏂瑰悜锛岃璁℃暟鍣ㄥ姞1锛岃鏁拌寖鍥?~V_FrameSize - 1
    end
end 

wire hs_valid  =  hcnt < H_ActiveSize; //琛屼俊鍙锋湁鏁堝儚绱犻儴鍒?wire vs_valid  =  vcnt < V_ActiveSize; //鍦轰俊鍙锋湁鏁堝儚绱犻儴鍒?wire vtc_hs    =  (hcnt >= H_SyncStart && hcnt < H_SyncEnd);//浜х敓hs锛岃鍚屾淇″彿
wire vtc_vs    =  (vcnt > V_SyncStart && vcnt <= V_SyncEnd);//浜х敓vs锛屽満鍚屾淇″彿      
wire vtc_de    =  hs_valid && vs_valid;//鍙湁褰撹棰戞按骞虫柟鍚戯紝鍒楁湁鏁堝拰瑙嗛鍨傜洿鏂瑰悜锛岃鍚屾椂鏈夋晥锛岃棰戞暟鎹儴鍒嗘墠鏄湁鏁?
always @(posedge I_vtc_clk)begin
	if(rst_sync == 1'b0)begin
		O_vtc_vs <= 1'b0;
		O_vtc_hs <= 1'b0;
		O_vtc_de <= 1'b0;
	end
	else begin
		O_vtc_vs <= vtc_vs;
		O_vtc_hs <= vtc_hs;
		O_vtc_de <= vtc_de;	
	end
end

endmodule


