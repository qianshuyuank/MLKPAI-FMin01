/*******************************MILIANKE*******************************
*Company : MiLianKe Electronic Technology Co., Ltd.
*WebSite:https://www.milianke.com
*TechWeb:https://www.uisrc.com
*tmall-shop:https://milianke.tmall.com
*jd-shop:https://milianke.jd.com
*taobao-shop1: https://milianke.taobao.com
*Create Date: 2021/10/15
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

module sim_top_tb();

reg I_sysclk,I_rstn;      // 鏃堕挓淇″彿浠ュ強澶嶄綅淇″彿
wire [7:0]  O_LED;        // 浠跨湡鐨凩ED 淇″彿

run_led#
(
.T_INR_CNT_SET(1000)       // 璁剧疆涓€涓緝灏忕殑鏃堕挓璁℃暟鍊硷紝鍙互鍦ㄤ豢鐪熸椂鐪嬪埌杈冨皬鐨勫垏鎹㈡椂闂?
)
run_led_inst(
 .I_sysclk(I_sysclk),      // 杈撳叆鏃堕挓鎺ュ彛
 .I_rstn(I_rstn),          // 杈撳叆澶嶄綅鎺ュ彛
 .O_LED(O_LED)             // 杈撳嚭led鎺ュ彛
);

initial begin
   I_sysclk  <= 1'b0;     // 鏃堕挓淇″彿鐨勫瘎瀛樺櫒璧嬪垵鍊?
   I_rstn        <= 1'b0;     // 澶嶄綅淇″彿鐨勫瘎瀛樺櫒璧嬪垵鍊?
   #100;                  // 寤舵椂100涓椂闂村崟浣?
   I_rstn        <= 1'b1;     // 澶嶄綅鎭㈠楂樼數骞筹紝妯℃嫙澶嶄綅缁撴潫
   
   // AI Analysis Logging
   $display("Simulation Started at %t", $time);
   $monitor("Time=%t | LED Output = %b", $time, O_LED);
   
   // Run for a specific time then finish
   #200000; 
   $display("Simulation Finished at %t", $time);
   $finish;
end

always #20 I_sysclk=~I_sysclk;    // 姣忛殧20涓椂闂村懆鏈燂紝妯℃嫙浜х敓绯荤粺鏃堕挓淇″彿杩涜涓€娆＄炕杞?

endmodule
