`timescale 1ns / 1ps
//********************************************************************** 
// -------------------------------------------------------------------
// Disclaimers
// -------------------------------------------------------------------
// When you use this source file, please note that the author assumes 
// no legal or non-legal responsibility for any consequences of your use 
// of it including, but not limited to, the specific use of the code or 
// liability to you for infringement of any patent, copyright or other 
// intellectual property rights.
// If you do not agree to the terms, please do not use the file and 
// delete the file promptly.
// -------------------------------------------------------------------
// Copyright Notice
// -------------------------------------------------------------------
// This source file may be used for personal study, provided that this 
// copyright notice is not removed from the file.
// and that derivative works of this source file contain the original 
// copyright notice and related disclaimers.
// For commercial use, please contact the author for authorization, 
// otherwise the author reserves all rights.
// ------------------------------------------------------------------- 
// Author: Geeker_FPGA 
// Email:geeker_fpga@uisrc.com v
// Date:2021/02
// Description: 
// rgb2ycbcr_algorithm
//
// 
// Web:http://www.uisrc.com
//------------------------------------------------------------------- 
//*********************************************************************/
module rgb2ycbcr_algorithm
(
	input   wire				i_clk,
	input   wire				i_rst_n,	
	input   wire				i_hsyn,		
	input   wire				i_vsyn,		
	input	wire [7:0]			i_r,
	input	wire [7:0] 			i_g,
	input	wire [7:0] 			i_b,	
	input   wire				i_de,		
	output	wire				o_hsyn,	
	output  wire				o_vsyn,	
	output  wire [7:0]			o_y,
	output  wire [7:0]			o_cb,
	output  wire [7:0]			o_cr,
	output  wire				o_de
);

// ycbcr0(:,:,1)  =  0.2568*image_in_r + 0.5041*image_in_g + 0.0979*image_in_b + 16; 
// ycbcr0(:,:,2)  = -0.1482*image_in_r - 0.2910*image_in_g + 0.4392*image_in_b + 128;
// ycbcr0(:,:,3)  =  0.4392*image_in_r - 0.3678*image_in_g - 0.0714*image_in_b + 128;

// ycbcr0(:,:,1)  = 256*( 0.2568*image_in_r + 0.5041*image_in_g + 0.0979*image_in_b + 16 )>>8; 
// ycbcr0(:,:,2)  = 256*(-0.1482*image_in_r - 0.2910*image_in_g + 0.4392*image_in_b + 128)>>8;
// ycbcr0(:,:,3)  = 256*( 0.4392*image_in_r - 0.3678*image_in_g - 0.0714*image_in_b + 128)>>8;

// ycbcr0(:,:,1)  = (66*image_in_r + 129*image_in_g + 25*image_in_b + 4096  )>>8; 
// ycbcr0(:,:,2)  = (-38*image_in_r - 74*image_in_g + 112*image_in_b + 32768)>>8;
// ycbcr0(:,:,3)  = (112*image_in_r - 94*image_in_g - 18*image_in_b + 32768 )>>8;

reg [15:0] r_d0;
reg [15:0] g_d0;
reg [15:0] b_d0;

reg [15:0] r_d1;
reg [15:0] g_d1;
reg [15:0] b_d1;

reg [15:0] r_d2;
reg [15:0] g_d2;
reg [15:0] b_d2;

reg [15:0] y_d0;
reg [15:0] cb_d0;
reg [15:0] cr_d0;

reg [1:0] hsyn;
reg [1:0] vsyn;
reg [1:0] de;

always@(posedge i_clk or negedge i_rst_n) 
begin
    if(!i_rst_n)
	begin
        r_d0 <= 16'd0;
        g_d0 <= 16'd0;
        b_d0 <= 16'd0;
		r_d1 <= 16'd0;
		g_d1 <= 16'd0;
		b_d1 <= 16'd0;
		r_d2 <= 16'd0;
		g_d2 <= 16'd0;
		b_d2 <= 16'd0;	
    end
    else 
	begin
        r_d0 <= i_de ? (66  * i_r) : 16'd0;
        g_d0 <= i_de ? (129 * i_g) : 16'd0;
        b_d0 <= i_de ? (25  * i_b) : 16'd0;
		r_d1 <= i_de ? (38  * i_r) : 16'd0;
		g_d1 <= i_de ? (74  * i_g) : 16'd0;
		b_d1 <= i_de ? (112 * i_b) : 16'd0;
		r_d2 <= i_de ? (112 * i_r) : 16'd0;
		g_d2 <= i_de ? (94  * i_g) : 16'd0;
		b_d2 <= i_de ? (18  * i_b) : 16'd0;	        	
    end
end

always@(posedge i_clk or negedge i_rst_n) 
begin
    if(!i_rst_n)
	begin
		y_d0  <= 16'd0;
		cb_d0 <= 16'd0;
		cr_d0 <= 16'd0;
    end
    else 
	begin
		y_d0  <= de[0] ? (r_d0 + g_d0 + b_d0 + 4096 ): 16'd0;
		cb_d0 <= de[0] ? (b_d1 - r_d1 - g_d1 + 32768): 16'd0;
		cr_d0 <= de[0] ? (r_d2 - g_d2 - b_d2 + 32768): 16'd0;      	
    end
end

always@(posedge i_clk ) 
begin
	hsyn	<= {hsyn[0],i_hsyn};
	vsyn	<= {vsyn[0],i_vsyn};
	de		<= {de[0],i_de};
end

assign 	o_hsyn	= hsyn[1];
assign 	o_vsyn	= vsyn[1];
assign 	o_y		= y_d0 [15:8];
assign 	o_cb	= cb_d0[15:8];
assign 	o_cr	= cr_d0[15:8];
assign 	o_de	= de[1];

endmodule
