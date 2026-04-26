
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

module uitpg
(

input           I_tpg_clk, //绯荤粺鏃堕挓
input           I_tpg_vs,  //鍦哄悓姝ヨ緭鍏?
input           I_tpg_hs,  //琛屽悓姝ヨ緭鍏?
input           I_tpg_de,  //瑙嗛鏁版嵁鏈夋晥杈撳叆   
output          O_tpg_vs,  //鍦哄悓姝ヨ緭鍑?
output          O_tpg_hs,  //琛屽悓姝ヨ緭鍑?
output          O_tpg_de,  //瑙嗛鏁版嵁鏈夋晥杈撳嚭    
output [23:0]   O_tpg_data //鏈夋晥娴嬭瘯鏁版嵁
);

reg[8:0] fcnt = 9'd0;
reg tpg_vs_r = 1'b0;
reg tpg_hs_r = 1'b0;
reg tpg_de_r = 1'b0;

always @(posedge I_tpg_clk)begin
    tpg_vs_r <= I_tpg_vs;//瀵箆s淇″彿瀵勫瓨涓€娆?
    tpg_hs_r <= I_tpg_hs;//瀵筯s淇″彿瀵勫瓨涓€娆?
    tpg_de_r <= I_tpg_de;//瀵筯s淇″彿瀵勫瓨涓€娆?
end

reg [11:0]v_cnt = 12'd0; //瑙嗛鍨傜洿鏂瑰悜锛岃璁℃暟鍣?
reg [11:0]h_cnt = 12'd0; //瑙嗛姘村钩鏂瑰悜锛屽垪璁℃暟鍣?

//v_cnt璁℃暟鍣ㄦā鍧?
always @(posedge I_tpg_clk)
  if(I_tpg_vs) //閫氳繃vs浜х敓鍚屾澶嶄綅
	v_cnt <= 12'd0; //閲嶇疆v_cnt=0
  else if((!tpg_hs_r)&&I_tpg_hs) 
  //hs淇″彿鐨勪笂鍗囨部锛寁_cnt璁℃暟锛岃繖绉嶆柟寮忓彲浠ヤ笉绠s鏈夋晥鏄珮鐢靛钩杩樻槸浣庣數骞崇殑鎯呭喌,v_cnt 瑙嗛鍨傜洿鏂瑰悜锛岃璁℃暟鍣紝璁℃暟琛屾暟閲?
	v_cnt <= v_cnt + 1'b1; 

//h_cnt璁℃暟鍣ㄦā鍧?
//璁℃暟琛屾湁鏁堝儚绱?褰揹e鏃犳晥锛岄噸缃?h_cnt=0
always @(posedge I_tpg_clk)
  if(I_tpg_de)
	h_cnt <= h_cnt + 1'b1; 
  else 
    h_cnt <= 12'd0; 
      
reg [7:0] grid_data = 8'd0;

//grid_data鍙戠敓鍣? 
always @(posedge I_tpg_clk)begin
	if((v_cnt[4]==1'b1) ^ (h_cnt[4]==1'b1))
	//鏂规牸澶у皬16*16锛岄粦鐧戒氦鏇?
	   grid_data <= 8'h00;
	else
	   grid_data <= 8'hff;
end

reg[23:0]color_bar = 24'd0;

//RGB褰╂潯鍙戠敓鍣?
always @(posedge I_tpg_clk)
begin
	if(h_cnt==260)
	color_bar	<=	24'hff0000;//绾?
	else if(h_cnt==420)
	color_bar	<=	24'h00ff00;//缁?
	else if(h_cnt==580)
	color_bar	<=	24'h0000ff;//钃?
	else if(h_cnt==740)
	color_bar	<=	24'hff00ff;//绱?
	else if(h_cnt==900)
	color_bar	<=	24'hffff00;//榛?
	else if(h_cnt==1060)
	color_bar	<=	24'h00ffff;//闈掕摑
	else if(h_cnt==1220)
	color_bar	<=	24'hffffff;//鐧?
	else if(h_cnt==1380)
	color_bar	<=	24'h000000;//榛?
	else
	color_bar	<=	color_bar;
end

reg[10:0]dis_mode = 10'd0;

//鏄剧ず妯″紡鍒囨崲
always @(posedge I_tpg_clk)
    if((!tpg_vs_r)&&I_tpg_vs) dis_mode <= dis_mode + 1'b1;

reg[7:0]  r_reg = 8'd0;
reg[7:0]  g_reg = 8'd0;
reg[7:0]  b_reg = 8'd0;

//娴嬭瘯鍥惧舰杈撳嚭
always @(posedge I_tpg_clk)
begin
    case(dis_mode[3:0])//鎴彇楂樹綅锛屾帶鍒跺垏鎹㈡樉绀洪€熷害
        4'd0:begin
			r_reg <= v_cnt[7:0];                 //绾㈠瀭鐩存笎鍙?
            g_reg <= 0;
            b_reg <= 0;
		end
        4'd1:begin
			r_reg <= 0;                          //缁垮瀭鐩存笎鍙?
            g_reg <= h_cnt[7:0];
            b_reg <= 0;
		end
        4'd2,4'd3:begin  //杩炵画涓や釜鐘舵€佽緭鍑虹浉鍚屽浘褰?
			r_reg <= 0;                          //钃濆瀭鐩存笎鍙?
            g_reg <= 0;
            b_reg <= h_cnt[7:0];
		end			  
        4'd4,4'd5:begin  //杩炵画涓や釜鐘舵€佽緭鍑虹浉鍚屽浘褰?
			r_reg <= 0;                         //缁?
            g_reg <= 8'b11111111;
            b_reg <= 0; 
		end					  
        4'd6:begin     
			r_reg <= 0;                         //钃?
            g_reg <= 0;
            b_reg <= 8'b11111111;
		end
        4'd7,4'd8:begin  //杩炵画涓や釜鐘舵€佽緭鍑虹浉鍚屽浘褰?
			r_reg <= grid_data;                 //鏂规牸
            g_reg <= grid_data;
            b_reg <= grid_data;
		end					  
        4'd9:begin    
			r_reg <= h_cnt[7:0];                //姘村钩娓愬彉
            g_reg <= h_cnt[7:0];
            b_reg <= h_cnt[7:0];
		end
        4'd10,4'd11:begin   //杩炵画涓や釜鐘舵€佽緭鍑虹浉鍚屽浘褰? 
			r_reg <= v_cnt[7:0];                 //鍨傜洿娓愬彉
            g_reg <= v_cnt[7:0];
            b_reg <= v_cnt[7:0];
		end
        4'd12:begin     
			r_reg <= v_cnt[7:0];                 //绾㈠瀭鐩存笎鍙?
            g_reg <= 0;
            b_reg <= 0;
		end
        4'd13:begin     
			r_reg <= 0;                          //缁垮瀭鐩存笎鍙?
            g_reg <= h_cnt[7:0];
            b_reg <= 0;
		end
        4'd14:begin     
			r_reg <= 0;                          //钃濆瀭鐩存笎鍙?
            g_reg <= 0;
            b_reg <= h_cnt[7:0];			
		end
        4'd15:begin     
			r_reg <= color_bar[23:16];           //褰╂潯
            g_reg <= color_bar[15:8];
            b_reg <= color_bar[7:0];			
		end				  
        endcase
end

assign O_tpg_data = {r_reg,g_reg,b_reg};//娴嬭瘯鍥惧舰RGB鏁版嵁杈撳嚭
assign O_tpg_vs = I_tpg_vs;  //VS鍚屾淇″彿
assign O_tpg_hs = I_tpg_hs;  //HS鍚屾淇″彿
assign O_tpg_de = tpg_de_r;  //DE鏁版嵁鏈夋晥淇″彿

endmodule
