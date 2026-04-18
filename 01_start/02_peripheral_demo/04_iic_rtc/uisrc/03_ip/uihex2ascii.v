`timescale 1ns / 1ps
/*******************************MILIANKE*******************************
*Company : MiLianKe Electronic Technology Co., Ltd.
*WebSite:https://www.milianke.com
*TechWeb:https://www.uisrc.com
*tmall-shop:https://milianke.tmall.com
*jd-shop:https://milianke.jd.com
*taobao-shop1: https://milianke.taobao.com
*Create Date: 2021/10/15
*File Name: ui5640reg.v
*Description: 
*Declaration:
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
module uihex2ascii
(
input         	 [7 :0]  hex,
output   reg   	 [7 :0]  assii  
);

always@(*)
begin
	case(hex)
	0 :		assii	=	{8'h30};//0	
	1 :		assii	=	{8'h31};//1		
	2 :		assii	=	{8'h32};//2	
	3 :		assii	=	{8'h33};//3
	4 :		assii	=	{8'h34};//4	
	5 :		assii	=	{8'h35};//5			
	6 :		assii	=	{8'h36};//6	
	7 :		assii	=	{8'h37};//7	
	8 :		assii	=	{8'h38};//8	
	9 :		assii	=	{8'h39};//9
	default:assii	=	{8'h00};	
	endcase
end

endmodule
