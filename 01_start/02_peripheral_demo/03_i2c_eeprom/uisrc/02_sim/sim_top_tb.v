
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

`timescale 1ns / 1ns

module sim_top_tb;

reg  sysclk = 1;//绯荤粺鏃堕挓杈撳叆
wire iic_scl;// I2C SCL鏃堕挓
wire iic_sda;//I2C SDA鏁版嵁鎬荤嚎

pullup( iic_sda );

eeprom_test  eeprom_test_inst
(
.I_sysclk(sysclk),
.O_iic_scl(iic_scl),
.IO_iic_sda(iic_sda)
);
    
eeprom eeprom_inst(
.scl(iic_scl),
.sda(iic_sda)
);    

always 
    begin
        #10 sysclk = ~sysclk;
    end
 
endmodule
