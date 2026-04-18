module  EG_LOGIC_BUF(o,i);     // user instantiated logic BUF
output o;      
input i;       
endmodule
module  EG_LOGIC_BUFG(o,i);  // driver for global clk resource
output o;       
input i;        
endmodule
module  EG_LOGIC_BUFIO(clki,rst,coe,clko,clkdiv1,clkdivx);  // driver for IO clk resource
input clki;                                 
input rst;                                  
input coe;                                  
output clko;                                
output clkdiv1;                             
output clkdivx;                             
parameter GSR                = "DISABLE";     // "ENABLE", "DISABLE".
parameter DIV                 = 2;            // 2, 4.
parameter STOPCLK = "DISABLE";                // "ENABLE", "DISABLE".
endmodule
module  EG_LOGIC_BUFGMUX(o,i0,i1,s); // global clk switch mux
output o;            
input i0;            
input i1;            
input s;             
parameter INIT_OUT = "0";             // "0", "1".
parameter PRESELECT_I0 = "TRUE";      // "TRUE", "FALSE".
parameter PRESELECT_I1 = "FALSE";     // "TRUE", "FALSE".
endmodule
module EG_LOGIC_MBOOT(rebootn, dynamic_addr);   // config multiboot
input       rebootn;         
input [7:0] dynamic_addr;    
  parameter ADDR_SOURCE_SEL = "STATIC";   // "STATIC", "DYNAMIC".
  parameter STATIC_ADDR = 8'b00000000;    // DEFAULT 8'b00000000.
endmodule
module EG_LOGIC_DNA(dout, clk, din, shift_en);    // config dna 
output dout;   
input  clk;                               
input  din;                               
input  shift_en;                          
endmodule
module  EG_LOGIC_GSRN(gsrn, sync_clk);     // config gsrn
input gsrn;
input sync_clk; 
  parameter GSRN_SYNC_SEL = "DISABLE";  // "ENABLE", "DISABLE".
  parameter USR_GSRN_EN   = "DISABLE";  // "ENABLE", "DISABLE".
endmodule
module EG_LOGIC_CCLK(cclk, en);        // config cclk
output cclk;
input  en;
parameter FREQ = "4.5";      // "4.5", "6.5", "10.0", "20.0", "30.0", "40.0", "60.0", "130.0".
endmodule
module  EG_LOGIC_IDELAY(o,i);
output o;          
input i;           
parameter INDEL = 1;  // 1~32.
endmodule
module EG_LOGIC_IDDR (q1, q0, clk, d, rst);
    output q1;        
    output q0;        
    input clk;        
    input d;          
    input rst;        
    parameter ASYNCRST = "ENABLE";    // "ENABLE", "DISABLE".
    parameter PIPEMODE = "PIPED";     // "PIPED", "NONE".
endmodule
module EG_LOGIC_ODDR (q, clk, d1, d0, rst);
    output q;         
    input clk;        
    input d1;         
    input d0;         
    input rst;        
    parameter ASYNCRST = "ENABLE";    // "ENABLE", "DISABLE".
endmodule
module EG_LOGIC_IDDRx2 (q3, q2, q1, q0, pclk, sclk, d, rst);
    output q3;          
    output q2;          
    output q1;          
    output q0;          
    input pclk;         
    input sclk;         
    input d;            
    input rst;          
    parameter ASYNCRST = "ENABLE";     // "ENABLE", "DISABLE".
endmodule
module  EG_LOGIC_ODELAY(o,i);
output o;         
input i;          
parameter OUTDEL = 1;    // 1~4.
endmodule
module EG_LOGIC_ODDRx2 (q, pclk, sclk, d3, d2, d1, d0, rst);
    output q;              
    input pclk;            
    input sclk;            
    input d3;              
    input d2;              
    input d1;              
    input d0;              
    input rst;             
    parameter ASYNCRST = "ENABLE";   // "ENABLE", "DISABLE".
endmodule
module EG_LOGIC_ODDRx2l (q, sclk, d3, d2, d1, d0, rst);
    output q;        
    input sclk;      
    input d3;        
    input d2;        
    input d1;        
    input d0;        
    input rst;       
    parameter ASYNCRST = "ENABLE";     // "ENABLE", "DISABLE".
endmodule
module EG_LOGIC_IBUF (
  i,
  o
);
input i;    
output o;   
endmodule
module EG_LOGIC_OBUF (
  i,
  o
);
input i;    
output o;   
endmodule
module EG_LOGIC_IOTRIBUF (
  i,
  t,
  o,
  io
);
input i;      
input t;      
output o;     
inout io;     
endmodule
module EG_LOGIC_FIFO (
    rst,
    di, clkw, we, csw, 
    do, clkr, re, csr, ore,
    empty_flag, aempty_flag,
    full_flag, afull_flag
);
parameter DATA_WIDTH_W = 9;                                          // 1~9*48.
parameter DATA_WIDTH_R = DATA_WIDTH_W;                               // 1~9*48.
parameter DATA_DEPTH_W = 1024;                                       // 512, 1024, 2048, 4096, 8192.
parameter DATA_DEPTH_R = DATA_WIDTH_W * DATA_DEPTH_W / DATA_WIDTH_R; // 512, 1024, 2048, 4096, 8192.
input   rst;                                  
input   [DATA_WIDTH_W-1:0] di;                
output  [DATA_WIDTH_R-1:0] do;                
input   clkw;    
input   we;      
input   clkr; 
input   re;   
input   ore; 
input [2:0] csw;  
input [2:0] csr;  
output  empty_flag;  
output  aempty_flag; 
output  full_flag;  
output  afull_flag; 
parameter  MODE = "FIFO8K";                  // "FIFO8K".
parameter  REGMODE_W   = "NOREG";            // "NOREG", "OUTREG".
parameter  REGMODE_R   = "NOREG";            // "NOREG", "OUTREG".
parameter  E  = 0;                           // DEFAULT 0.
parameter  AE = 6;                           // 1~DATA_DEPTH_W-1.
parameter  AF = DATA_DEPTH_W-6;              // 1~DATA_DEPTH_W-1.
parameter  F  = DATA_DEPTH_W;                // DATA_DEPTH_W.
parameter  GSR = "DISABLE";                  // "ENABLE", "DISABLE".
parameter  RESETMODE = "ASYNC";              // "SYNC", "ASYNC".
parameter  ASYNC_RESET_RELEASE = "SYNC";     // "SYNC", "ASYNC".
parameter ENDIAN = "LITTLE";                 // "LITTLE", "BIG".
endmodule
module EG_LOGIC_DRAM (
  di,
  waddr,
  we,
  wclk,
  raddr,
  do
  );
  parameter DATA_WIDTH_W = 4;                      // >0.
  parameter DATA_WIDTH_R = DATA_WIDTH_W;           // >0.
  parameter ADDR_WIDTH_W = 4;                      // >0.
  parameter ADDR_WIDTH_R = ADDR_WIDTH_W;           // >0.
  parameter DATA_DEPTH_W = 2 ** ADDR_WIDTH_W;      // 2 ** ADDR_WIDTH_W.
  parameter DATA_DEPTH_R = 2 ** ADDR_WIDTH_R;      // 2 ** ADDR_WIDTH_R.
  output  [DATA_WIDTH_R-1:0] do;                                       
  input   [DATA_WIDTH_W-1:0] di; 
  input   we; 
  input   wclk; 
  input   [ADDR_WIDTH_W-1:0] waddr; 
  input   [ADDR_WIDTH_R-1:0] raddr; 
  parameter INIT_FILE = "NONE";   // DEFAULT "NONE".
  parameter FILL_ALL = "NONE";
endmodule
module EG_LOGIC_DRAM16X4 ( di, waddr, we, wclk, raddr, do);
parameter INIT_D0=16'h0000;     // DEFAULT 16'h0000.
parameter INIT_D1=16'h0000;     // DEFAULT 16'h0000.
parameter INIT_D2=16'h0000;     // DEFAULT 16'h0000.
parameter INIT_D3=16'h0000;     // DEFAULT 16'h0000.
  input [3:0]di;                
  input [3:0]waddr;             
  input wclk;                   
  input we;                     
  input [3:0]raddr;             
  output [3:0]do;               
endmodule
module EG_LOGIC_MULT (p, a, b, cea, ceb, cepd, clk, rstan, rstbn, rstpdn); 
parameter   INPUT_WIDTH_A       = 18        ;
parameter   INPUT_WIDTH_B       = 18        ;
parameter   OUTPUT_WIDTH        = 36        ;
output      [OUTPUT_WIDTH-1:0]  p           ;                           
input       [INPUT_WIDTH_A-1:0] a           ;                           
input       [INPUT_WIDTH_B-1:0] b           ;                           
input                           cea         ; 
input                           ceb         ; 
input                           cepd        ; 
input                           clk         ; 
input                           rstan       ; 
input                           rstbn       ; 
input                           rstpdn      ; 
parameter   INPUTFORMAT     = "SIGNED"  ;      
parameter   INPUTREGA           = "ENABLE"  ;  // "ENABLE", "DISABLE".
parameter   INPUTREGB           = "ENABLE"  ;  // "ENABLE", "DISABLE".
parameter   OUTPUTREG           = "ENABLE"  ;  // "ENABLE", "DISABLE".
parameter   IMPLEMENT           = "AUTO"    ;  
parameter   SRMODE              = "ASYNC"   ;  // "ASYNC", "SYNC".
endmodule
module EG_LOGIC_SEQ_DIV (clk, rst, start, numer, denom, quotient, remain, done);
	parameter NUMER_WIDTH = 16;     // >1.
  parameter DENOM_WIDTH = 16;       // >1.
  input                     clk;          
  input                     rst;          
  input                     start;        
  input  [NUMER_WIDTH-1:0]  numer;        
  input  [DENOM_WIDTH-1:0]  denom;        
  output [NUMER_WIDTH-1:0]  quotient;     
  output [DENOM_WIDTH-1:0]  remain;       
  output                    done;         
endmodule
module EG_PHY_BRAM (
  dia, csa,
  addra, cea, ocea, clka, wea, rsta,
  dib, csb,
  addrb, ceb, oceb, clkb, web, rstb,
  doa,
  dob);
output  [8:0] doa;                     
output  [8:0] dob;                     
input   [8:0] dia;                     
input   [8:0] dib;                     
input   [2:0] csa;                    
input   [2:0] csb;                    
input   cea, ocea, clka, wea, rsta;   
input   ceb, oceb, clkb, web, rstb;   
input   [12:0] addra;                  
input   [12:0] addrb;                  
parameter MODE = "DP8K";                  // "DP8K", "SP8K", "PDPW8K", "FIFO8K".
parameter DATA_WIDTH_A = "9";             // "1", "2", "4", "9", "18".
parameter DATA_WIDTH_B = "9";             // "1", "2", "4", "9", "18".
parameter READBACK = "OFF";               // "ON", "OFF".
parameter REGMODE_A = "NOREG";            // "NOREG", "OUTREG".
parameter REGMODE_B = "NOREG";            // "NOREG", "OUTREG".
parameter WRITEMODE_A = "NORMAL";         // "NORMAL", "READBEFOREWRITE", "WRITETHROUGH".
parameter WRITEMODE_B = "NORMAL";         // "NORMAL", "READBEFOREWRITE", "WRITETHROUGH".
parameter GSR = "ENABLE";                 // "DISABLE", "ENABLE".
parameter RESETMODE = "SYNC";             // "SYNC", "ASYNC".
parameter ASYNC_RESET_RELEASE = "SYNC";   // "SYNC", "ASYNC".
parameter CEAMUX = "SIG";                 // "0", "1", "INV", "SIG".
parameter CEBMUX = "SIG";                 // "0", "1", "INV", "SIG".
parameter OCEAMUX = "SIG";                // "0", "1", "INV", "SIG".
parameter OCEBMUX = "SIG";                // "0", "1", "INV", "SIG".
parameter RSTAMUX = "SIG";                // "0", "1", "INV", "SIG".
parameter RSTBMUX = "SIG";                // "0", "1", "INV", "SIG".
parameter CLKAMUX = "SIG";                // "0", "1", "INV", "SIG".
parameter CLKBMUX = "SIG";                // "0", "1", "INV", "SIG".
parameter WEAMUX = "SIG";                 // "0", "1", "INV", "SIG".
parameter WEBMUX = "SIG";                 // "0", "1", "INV", "SIG".
parameter CSA0 = "SIG" ;                  // "0", "1", "INV", "SIG".
parameter CSA1 = "SIG" ;                  // "0", "1", "INV", "SIG".
parameter CSA2 = "SIG" ;                  // "0", "1", "INV", "SIG".
parameter CSB0 = "SIG" ;                  // "0", "1", "INV", "SIG".
parameter CSB1 = "SIG" ;                  // "0", "1", "INV", "SIG".
parameter CSB2 = "SIG" ;                  // "0", "1", "INV", "SIG".
    parameter INIT_FILE = "NONE";
    parameter INITP_00 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INITP_01 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INITP_02 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INITP_03 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_00 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_01 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_02 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_03 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_04 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_05 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_06 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_07 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_08 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_09 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_0A = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_0B = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_0C = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_0D = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_0E = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_0F = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_10 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_11 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_12 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_13 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_14 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_15 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_16 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_17 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_18 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_19 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_1A = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_1B = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_1C = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_1D = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_1E = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_1F = 256'h0000000000000000000000000000000000000000000000000000000000000000;
endmodule
module EG_PHY_BRAM32K (
  doa, dia, addra, bytea, bytewea, csa, wea, clka, rsta, ocea,
  dob, dib, addrb, byteb, byteweb, csb, web, clkb, rstb, oceb
  );
output  [15:0] doa;              
output  [15:0] dob;              
input   [15:0] dia;              
input   [15:0] dib;              
input   [10:0] addra;            
input   [10:0] addrb;            
input   bytea;   	
input   bytewea;  
input   byteb;     
input   byteweb;  
input   csa;   
input   wea;   
input   csb;   
input   web;   
input   clka;  
input   rsta;  
input   clkb;  
input   rstb;  
input   ocea;  
input   oceb;  
parameter MODE = "DP16K";              // "DP16K", "SP16K".
parameter DATA_WIDTH_A = "16";         // "8", "16".
parameter DATA_WIDTH_B = "16";         // "8", "16".
parameter REGMODE_A = "NOREG";         // "NOREG", "OUTREG".
parameter REGMODE_B = "NOREG";         // "NORMAL", "WRITETHROUGH".
parameter WRITEMODE_A = "NORMAL";      // "NORMAL", "WRITETHROUGH".
parameter WRITEMODE_B = "NORMAL";      // "SYNC", "ASYNC".
parameter SRMODE = "SYNC";             // "0", "1", "INV", "SIG".
parameter CSAMUX = "SIG";              // "0", "1", "INV", "SIG".
parameter CSBMUX = "SIG";              // "0", "1", "INV", "SIG".
parameter OCEAMUX = "SIG";             // "0", "1", "INV", "SIG".
parameter OCEBMUX = "SIG";             // "0", "1", "INV", "SIG".
parameter RSTAMUX = "SIG";             // "0", "1", "INV", "SIG".
parameter RSTBMUX = "SIG";             // "0", "1", "INV", "SIG".
parameter CLKAMUX = "SIG";             // "0", "1", "INV", "SIG".
parameter CLKBMUX = "SIG";             // "0", "1", "INV", "SIG".
parameter WEAMUX = "SIG";              // "0", "1", "INV", "SIG".
parameter WEBMUX = "SIG";              // "ON", "OFF".
parameter READBACK = "OFF";         
    parameter INIT_FILE = "";
    parameter INIT_00 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_01 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_02 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_03 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_04 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_05 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_06 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_07 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_08 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_09 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_0A = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_0B = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_0C = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_0D = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_0E = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_0F = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_10 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_11 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_12 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_13 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_14 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_15 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_16 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_17 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_18 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_19 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_1A = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_1B = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_1C = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_1D = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_1E = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_1F = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_20 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_21 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_22 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_23 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_24 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_25 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_26 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_27 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_28 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_29 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_2A = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_2B = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_2C = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_2D = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_2E = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_2F = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_30 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_31 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_32 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_33 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_34 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_35 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_36 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_37 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_38 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_39 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_3A = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_3B = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_3C = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_3D = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_3E = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_3F = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_40 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_41 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_42 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_43 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_44 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_45 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_46 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_47 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_48 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_49 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_4A = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_4B = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_4C = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_4D = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_4E = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_4F = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_50 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_51 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_52 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_53 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_54 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_55 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_56 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_57 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_58 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_59 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_5A = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_5B = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_5C = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_5D = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_5E = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_5F = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_60 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_61 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_62 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_63 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_64 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_65 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_66 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_67 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_68 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_69 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_6A = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_6B = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_6C = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_6D = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_6E = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_6F = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_70 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_71 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_72 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_73 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_74 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_75 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_76 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_77 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_78 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_79 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_7A = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_7B = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_7C = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_7D = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_7E = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_7F = 256'h0000000000000000000000000000000000000000000000000000000000000000;
endmodule
module EG_PHY_FIFO (
		rst, 
            // write port
            dia,dib, csw, we, clkw, 
            // read port
            dob,doa, csr, re, clkr, rprst, orea,oreb,
            // output flag
            empty_flag, aempty_flag, afull_flag, full_flag);
input    [8:0] dia,dib;
input    [2:0] csr;
input    [2:0] csw;
input    we, re, clkw, clkr, rst, rprst,orea,oreb;
output   [8:0] dob,doa;
output   empty_flag, aempty_flag, afull_flag, full_flag;
   parameter  MODE = "FIFO8K";        // "FIFO8K".
   parameter  DATA_WIDTH_A = "18";    // "1", "2", "4", "9", "18".
   parameter  DATA_WIDTH_B = "18";    // "1", "2", "4", "9", "18".
   parameter  READBACK = "OFF";       // "ON", "OFF".
   parameter  REGMODE_A   = "NOREG";  // "NOREG", "OUTREG".
   parameter  REGMODE_B   = "NOREG";  // "NOREG", "OUTREG".
   parameter  [13:0] AE   = 14'b00000001100000;
   parameter  [13:0] AF   = 14'b01111110010000;
   parameter  [13:0] F 	  = 14'b01111111110000;
   parameter  [13:0] AEP1 = 14'b00000001110000;
   parameter  [13:0] AFM1 = 14'b01111110000000;
   parameter  [13:0] FM1  = 14'b01111111100000;   
   parameter  [4:0] E   = 5'b00000;
   parameter  [5:0] EP1 = 6'b010000;
   parameter  GSR = "ENABLE";                // "DISABLE", "ENABLE".
   parameter  RESETMODE = "ASYNC";           // "SYNC", "ASYNC".
   parameter  ASYNC_RESET_RELEASE = "SYNC";  // "SYNC", "ASYNC".
parameter CEA = "SIG";     // "0", "1", "INV", "SIG".
parameter CEB = "SIG";     // "0", "1", "INV", "SIG".
parameter OCEA = "SIG";    // "0", "1", "INV", "SIG".
parameter OCEB = "SIG";    // "0", "1", "INV", "SIG".
parameter RSTA = "SIG";    // "0", "1", "INV", "SIG".
parameter RSTB = "SIG";    // "0", "1", "INV", "SIG".
parameter CLKA = "SIG";    // "0", "1", "INV", "SIG".
parameter CLKB = "SIG";    // "0", "1", "INV", "SIG".
parameter WEA = "SIG";     // "0", "1", "INV", "SIG".
parameter WEB = "SIG";     // "0", "1", "INV", "SIG".
parameter CSA0 = "SIG" ;   // "0", "1", "INV", "SIG".
parameter CSA1 = "SIG" ;   // "0", "1", "INV", "SIG".
parameter CSA2 = "SIG" ;   // "0", "1", "INV", "SIG".
parameter CSB0 = "SIG" ;   // "0", "1", "INV", "SIG".
parameter CSB1 = "SIG" ;   // "0", "1", "INV", "SIG".
parameter CSB2 = "SIG" ;   // "0", "1", "INV", "SIG".
endmodule
module EG_PHY_MULT18 (acout, bcout, p, signeda, signedb, a, b, acin, bcin, cea, ceb, cepd, clk, rstan, rstbn, rstpdn,
            sourcea, sourceb); 
    output [17:0] acout;     
    output [17:0] bcout;     
    output [35:0] p;         
    input signeda;           
    input signedb;           
    input [17:0] a;          
    input [17:0] b;          
    input [17:0] acin;       
    input [17:0] bcin;       
    input cea;               
    input ceb;               
    input cepd;              
    input clk;               
    input rstan;             
    input rstbn;             
    input rstpdn;            
    input sourcea;           
    input sourceb;           
    parameter INPUTREGA = "ENABLE";     // "ENABLE", "DISABLE".
    parameter INPUTREGB = "ENABLE";     // "ENABLE", "DISABLE".
    parameter OUTPUTREG = "ENABLE";     // "ENABLE", "DISABLE".
    parameter SRMODE    = "ASYNC";      // "ASYNC", "SYNC".
    parameter MODE      = "MULT18X18C";// "MULT9X9C", "MULT18X18C".
    parameter CEAMUX = "SIG";          // "0", "1", "INV", "SIG".
    parameter CEBMUX = "SIG";          // "0", "1", "INV", "SIG".
    parameter CEPDMUX = "SIG";         // "0", "1", "INV", "SIG".
    parameter RSTANMUX = "SIG";        // "0", "1", "INV", "SIG".
    parameter RSTBNMUX = "SIG";        // "0", "1", "INV", "SIG".
    parameter RSTPDNMUX = "SIG";       // "0", "1", "INV", "SIG".
    parameter CLKMUX = "SIG";          // "0", "1", "INV", "SIG".
    parameter SIGNEDAMUX = "SIG";      // "0", "1", "INV", "SIG".
    parameter SIGNEDBMUX = "SIG";      // "0", "1", "INV", "SIG".
    parameter SOURCEAMUX = "SIG";      // "0", "1", "INV", "SIG".
    parameter SOURCEBMUX = "SIG";      // "0", "1", "INV", "SIG".
endmodule
module EG_PHY_GCLK (clki, clko);
    input clki;     
    output clko;    
endmodule
module EG_PHY_IOCLK (clki, stop, clko);
    input clki;       
    input stop;       
    output clko;      
    parameter  STOPCLK = "DISABLE"; // "ENABLE", "DISABLE".
endmodule
module EG_PHY_CLKDIV (clki, rst, rls, clkdiv1, clkdivx);
    output clkdiv1, clkdivx;
    input clki;
    input rst;
    input rls;
    parameter GSR = "DISABLE";    // "ENABLE", "DISABLE".
    parameter DIV = 2;            // 2, 4.
endmodule
module EG_PHY_CONFIG(
  jrstn, jrti, jshift, jtck, jtdi, jupdate, jscanen, jtms, jtdo, jtag8_ipa, jtag8_ipb,
  done, highz,
  cclk, cclk_en,
  gsrn_sync_clk, usr_gsrn,
  dna_dout, dna_clk, dna_din, dna_shift_en,
  mboot_rebootn, mboot_dynamic_addr
);
  output       jrstn;
  output [1:0] jrti;
  output       jshift;
  output       jtck;
  output       jtdi;
  output       jupdate;
  output [1:0] jscanen;
  output       jtms;
  input [1:0]  jtdo;
  input [7:0]  jtag8_ipa;
  input [7:0]  jtag8_ipb;
  output       	done;
  output       	highz;
  output       	cclk;
  input	      	cclk_en;	
  input        	gsrn_sync_clk;
  input        	usr_gsrn;
  output		dna_dout;
  input		dna_clk;
  input		dna_din;
  input		dna_shift_en;
  input		mboot_rebootn;
  input [7:0] 	mboot_dynamic_addr;
  parameter MBOOT_AUTO_SEL = "DISABLE";	     // "ENABLE", "DISABLE".
  parameter ADDR_SOURCE_SEL = "STATIC";	     // "STATIC", "DYNAMIC".
  parameter STATIC_ADDR = 8'b0;		         // DEFAULT 8'b0.
  parameter DONE_PERSISTN = "ENABLE";	     // "ENABLE", "DISABLE".
  parameter INIT_PERSISTN = "ENABLE";	     // "ENABLE", "DISABLE".
  parameter PROGRAMN_PERSISTN = "DISABLE";   // "ENABLE", "DISABLE".
  parameter JTAG_PERSISTN = "DISABLE";	     // "ENABLE", "DISABLE".
  parameter GSRN_SYNC_SEL = "DISABLE";	     // "ENABLE", "DISABLE".
  parameter FREQ = "2.5";			         // "2.5", "5.0", "10.0", "30.0".
  parameter USR_GSRN_EN = "DISABLE";	     // "ENABLE", "DISABLE".
endmodule
module EG_PHY_OSC (osc_dis, osc_clk);		// osc clk
    input osc_dis;
    output osc_clk;
    parameter STDBY = "DISABLE"; 	// "ENABLE", "DISABLE".
endmodule
module EG_PHY_PWRMNT (sel_pwr, pwr_mnt_pd, pwr_dwn_n);
    output pwr_dwn_n;
    input sel_pwr;
    input pwr_mnt_pd;
  parameter MNT_LVL = 0; // 1~7.
endmodule
module EG_PHY_DDR_8M_16 (  
    clk,
    clk_n,
    ras_n,
    cas_n,
    we_n,
    cs_n,
    addr,
    ba,
    dq,
    ldqs,
    udqs,
    ldm,
    udm,
    cke
);
input         clk;     
input         clk_n;   
input         ras_n;   
input         cas_n;   
input         we_n;    
input         cs_n;    
input  [11:0] addr;    
input  [1:0]  ba;      
inout  [15:0] dq;      
inout         ldqs;    
inout         udqs;    
input         ldm;     
input         udm;     
input         cke;     
endmodule
module EG_PHY_SDRAM_2M_32 (
    clk,
    ras_n,
    cas_n,
    we_n,
    addr,
    ba,
    dq,
    cs_n,
    dm0,
    dm1,
    dm2,
    dm3,
    cke
);
input         clk;		
input         ras_n;    
input         cas_n;    
input         we_n;     
input  [10:0] addr;     
input  [1:0]  ba;       
inout  [31:0] dq;        
input         cs_n; 
input         dm0; 
input         dm1; 
input         dm2; 
input         dm3; 
input         cke; 
endmodule
module EG_PHY_PAD (ipad, opad, bpad, rst, ce, isclk, ipclk, osclk, opclk, ts, do, di, diq);
    parameter DEDCLK     = "DISABLE";   // "ENABLE", "DISABLE".
    parameter GSR        = "ENABLE";    // "ENABLE", "DISABLE".
    parameter SRMODE     = "SYNC";      // "SYNC", "ASYNC".
    parameter TSMUX      = "1";         // "1", "0", "TS", "INV".
    parameter INSCLKMUX  = "0";         // "CLK(ioclk[1:0],gclk[3:0],jclk,0(SW default))", "INV".
    parameter INPCLKMUX  = "CLK";       // "CLK(ioclk[0],gclk[1:0],jclk(as SW default=0))", "INV".
    parameter INCEMUX    = "CE";        // "CE", "INV", "1".
    parameter INRSTMUX   = "0";         // "0", "RST", "INV".
    parameter IN_REGSET  = "RESET";     // "RESET", "SET".
    parameter IN_DFFMODE = "NONE";      // "NONE", "FF", "LATCH".
    parameter IDDRMODE   = "OFF";       // "OFF", "DDRX1","DDRX2".
    parameter IDDRPIPEMODE  = "NONE";   // "NONE", "PIPED".
    parameter INDELMUX   = "NODEL";     // "NODEL", "FIXDEL".
    parameter INDEL      = 0;           // 0~31.
    parameter OUTSCLKMUX = "0";         // "CLK(ioclk[1:0],gclk[3:0],jclk,0(SW default))", "INV".
    parameter OUTPCLKMUX = "CLK";       // "CLK(ioclk[0],gclk[1:0],jclk(as SW default=0))", "INV".
    parameter OUTCEMUX   = "CE";        // "CE", "INV", "1".
    parameter OUTRSTMUX  = "0";         // "0", "RST", "INV".
    parameter DO_REGSET  = "RESET";     // "RESET", "SET".
    parameter DO_DFFMODE = "NONE";      // "NONE", "FF", "LATCH".
    parameter ODDRMODE   = "OFF";       // "OFF", "DDRX1", "DDRX2", "DDRX2L".
    parameter OUTDELMUX  = "NODEL";     // "NODEL", "FIXDEL".
    parameter OUTDEL     = 0;           // 0~3.
    parameter TO_REGSET  = "RESET";     // "RESET", "SET".
    parameter TO_DFFMODE = "NONE";      // "NONE", "FF", "LATCH".
    parameter MODE       = "IN";        // "IN", "OUT", "BI".
    parameter DRIVE      = "NONE";      // "NONE", "8", "12", "16", "20", "24".
    parameter IOTYPE     = "LVCMOS25";  // "LVCMOS25", "LVCMOS12", "LVCMOS18", "LVCMOS33", "LVDS25" ...
    input  ipad;
    output opad;
    inout  bpad;
    input  rst, ce, isclk, ipclk, osclk, opclk;
    input  ts;
    input [3:0] do;
    output di;
    output [3:0] diq;
endmodule
module EG_LOGIC_RAMFIFO (
                   // Inputs
                   rst, di, clk, re, we,
                   // Outputs
                   do, empty_flag, full_flag, rdusedw, wrusedw
                   );
   parameter DATA_WIDTH = 8;      // 1~432.
   parameter ADDR_WIDTH = 8;      // 2~15.
   parameter SHOWAHEAD = 0;       // 0, 1.
   parameter IMPLEMENT = "AUTO";  // "9K", "32K", "AUTO".
   input                     rst;              
   input   [DATA_WIDTH-1:0]  di;               
   input                     clk;              
   input                     re;               
   input                     we;               
   output  [DATA_WIDTH-1:0]  do;               
   output                    empty_flag;       
   output                    full_flag;        
   output  [ADDR_WIDTH:0]    rdusedw;          
   output  [ADDR_WIDTH:0]    wrusedw;          
endmodule
module EG_PHY_MSLICE
  (
  a,
  b,
  c,
  ce,
  clk,
  d,
  mi,
  sr,
  fci,
  f,
  fx,
  q,
  fco,
  dpram_mode,
  dpram_di,
  dpram_we,
  dpram_waddr,
  dpram_wclk  
  );
  input [1:0] a,b,c,d,mi;
  input clk;                 
  input ce;                  
  input sr;                  
  input fci;                 
  output [1:0] f;   
  output [1:0] fx;  
  output [1:0] q;   
  output fco;                
  input dpram_mode;          
  input [1:0] dpram_di;      
  input dpram_we;            
  input dpram_wclk;          
  input [3:0]dpram_waddr;    
parameter INIT_LUT0 = 16'h0000 ;   // 16'h0000~16'h1111.
parameter INIT_LUT1 = 16'h0000 ;   // 16'h0000~16'h1111.
parameter MODE = "LOGIC" ;         // "LOGIC", "RIPPLE", "DPRAM".
parameter ALUTYPE = "";            
parameter MSFXMUX = "OFF" ;        // "OFF", "ON".
parameter GSR = "ENABLE" ;         // "ENABLE", "DISABLE".
parameter TESTMODE = "OFF" ;       // "OFF", "ON".
parameter CEMUX = "CE" ;           // "0", "1", "INV", "CE".
parameter SRMUX = "SR" ;           // "SR", "INV", "1", "0".
parameter CLKMUX = "CLK" ;         // "0", "1", "INV", "SIG".
parameter SRMODE = "ASYNC" ;       // "SYNC", "ASYNC".
parameter DFFMODE = "FF" ;         // "FF", "LATCH".
parameter REG0_SD = "MI" ;         // "MI", "F", "FX".
parameter REG1_SD = "MI" ;         // "MI", "F", "FX".
parameter REG0_REGSET = "SET" ;    // "RESET", "SET".
parameter REG1_REGSET = "SET" ;    // "RESET", "SET".
endmodule
module EG_PHY_LSLICE
  (
  a,
  b,
  c,
  ce,
  clk,
  d,
  e,
  mi,
  sr,
  fci,
  f,
  fx,
  q,
  fco,
  dpram_mode,
  dpram_di,
  dpram_we,
  dpram_waddr,
  dpram_wclk    
  );
  input [1:0] a;   	
  input [1:0] b;      
  input [1:0] c;      
  input [1:0] d;      
  input [1:0] e;      
  input	[1:0] mi;     
  input clk;                   
  input ce;                    
  input sr;                    
  input fci;                   
  output [1:0] f;      
  output [1:0] fx;     
  output [1:0] q;      
  output fco;                  
  output [3:0] dpram_di;       
  output [3:0] dpram_waddr;    
  output dpram_wclk;           
  output dpram_we;             
  output dpram_mode;           
parameter INIT_LUTF0 = 16'h0000 ;
parameter INIT_LUTG0 = 16'h0000 ;
parameter INIT_LUTF1 = 16'h0000 ;
parameter INIT_LUTG1 = 16'h0000 ;
parameter MODE = "LOGIC" ;        // "LOGIC", "RIPPLE", "RAMW".
parameter GSR = "ENABLE" ;        // "ENABLE", "DISABLE".
parameter TESTMODE = "OFF";       // "OFF", "ON".
parameter CEMUX = "1" ;           // "CE", "INV", "1", "0".
parameter SRMUX = "SR" ; // //  "SR", "INV", "1", "0".
parameter CLKMUX = "CLK" ;        // "CLK", "INV", "1", "0".
parameter SRMODE = "ASYNC" ;      // "ASYNC", "SYNC".
parameter DFFMODE = "FF" ;        // "FF", "LATCH".
parameter REG0_SD = "MI" ;        // "MI", "F", "FX".
parameter REG1_SD = "MI" ;        // "MI", "F", "FX".
parameter REG0_REGSET = "SET" ;   // "RESET", "SET".
parameter REG1_REGSET = "SET" ;   // "RESET", "SET".
parameter DEMUX0 = "D" ;          // "D", "E".
parameter DEMUX1 = "D" ;          // "D", "E".
parameter CMIMUX0 = "C" ;         // "C", "MI".
parameter CMIMUX1 = "C" ;         // "C", "MI".
parameter LSFMUX0 = "LUTF";       // "LUTF", "FUNC5", "SUM".
parameter LSFXMUX0 = "LUTG";      // "LUTG", "FUNC6", "SUM".
parameter LSFMUX1 = "LUTF";       // "LUTF", "FUNC5", "SUM".
parameter LSFXMUX1 = "LUTG";      // "LUTG", "FUNC6", "SUM".
endmodule
module EG_PHY_PLL(clkc,extlock,stdby,refclk,fbclk,reset,load_reg,
                  psdone,psclk,psdown,psstep,psclksel,
                  do,dclk,dcs,dwe,di,daddr);
output [4:0] clkc;      
output extlock;         
input  stdby;           
input  refclk;          
input  fbclk;           
input  reset;           
input  load_reg;        
output psdone;          
input  psclk;           
input  psdown;          
input  psstep;          
input  [2:0] psclksel;  
output [7:0]do;         
input  dclk;            
input  dcs;             
input  dwe;             
input  [7:0] di;        
input  [5:0] daddr;     
parameter DYNCFG = "DISABLE";          // "ENABLE","DISABLE".
parameter IF_ESCLKSTSW = "DISABLE";    // "ENABLE","DISABLE".
parameter REFCLK_SEL = "INTERNAL";     // "INTERNAL", "EXTRNAL".
parameter FIN = "100.0000";              // "ENABLE","DISABLE".
parameter REFCLK_DIV    = 1;             // 1~128.
parameter FBCLK_DIV     = 1;             // 1~128.
parameter CLKC0_DIV     = 1;             // 1~128.
parameter CLKC1_DIV     = 1;             // 1~128.
parameter CLKC2_DIV     = 1;             // 1~128.
parameter CLKC3_DIV     = 1;             // 1~128.
parameter CLKC4_DIV     = 1;             // 1~128.
parameter CLKC0_ENABLE  = "DISABLE";     // "ENABLE", "DISABLE", "SIGNAL".
parameter CLKC1_ENABLE  = "DISABLE";     // "ENABLE", "DISABLE", "SIGNAL".
parameter CLKC2_ENABLE  = "DISABLE";     // "ENABLE", "DISABLE", "SIGNAL".
parameter CLKC3_ENABLE  = "DISABLE";     // "ENABLE", "DISABLE", "SIGNAL".
parameter CLKC4_ENABLE  = "DISABLE";     // "ENABLE", "DISABLE", "SIGNAL".
parameter CLKC0_DIV2_ENABLE = "DISABLE";   // "ENABLE", "DISABLE".
parameter CLKC1_DIV2_ENABLE = "DISABLE";   // "ENABLE", "DISABLE".
parameter CLKC2_DIV2_ENABLE = "DISABLE";   // "ENABLE", "DISABLE".
parameter CLKC3_DIV2_ENABLE = "DISABLE";   // "ENABLE", "DISABLE".
parameter CLKC4_DIV2_ENABLE = "DISABLE";   // "ENABLE", "DISABLE".
parameter FEEDBK_MODE   = "NORMAL";    // "NORMAL", "SOURCESYNC", "NOCOMP", "ZERODELAY".
parameter FEEDBK_PATH   = "VCO_PHASE_0";  
parameter STDBY_ENABLE  = "ENABLE";   // ENABLE/DISABLE
parameter CLKC0_FPHASE     = 0;    // 0~7.
parameter CLKC1_FPHASE     = 0;    // 0~7.
parameter CLKC2_FPHASE     = 0;    // 0~7.
parameter CLKC3_FPHASE     = 0;    // 0~7.
parameter CLKC4_FPHASE     = 0;    // 0~7.
parameter CLKC0_CPHASE     = 1;    // 1~127  ,CLKC0_CPHASE <= CLKC0_DIV
parameter CLKC1_CPHASE     = 1;    // 1~127  ,CLKC1_CPHASE <= CLKC1_DIV
parameter CLKC2_CPHASE     = 1;    // 1~127  ,CLKC2_CPHASE <= CLKC2_DIV
parameter CLKC3_CPHASE     = 1;    // 1~127  ,CLKC3_CPHASE <= CLKC3_DIV
parameter CLKC4_CPHASE     = 1;    // 1~127  ,CLKC4_CPHASE <= CLKC4_DIV
parameter GMC_GAIN         = 7;  // 0~7.
parameter GMC_TEST         = 14; // 0~15.
parameter ICP_CURRENT      = 14;   // 1~32.
parameter KVCO             = 7;  // 0~7.
parameter LPF_CAPACITOR    = 3;  // 0~3.
parameter LPF_RESISTOR     = 1;    // 1~128.
parameter PLLRST_ENA       = "ENABLE";     // "ENABLE", "DISABLE".
parameter PLLMRST_ENA      = "DISABLE";    // "ENABLE", "DISABLE".
parameter PLLC2RST_ENA     = "DISABLE";    // "ENABLE", "DISABLE".
parameter PLLC34RST_ENA    = "DISABLE";    // "ENABLE", "DISABLE".
parameter PREDIV_MUXC0 = "VCO";    // VCO/CLKMINUS1/CLKPLUS1/REFCLK
parameter PREDIV_MUXC1 = "VCO";    // VCO/CLKMINUS1/CLKPLUS1/REFCLK
parameter PREDIV_MUXC2 = "VCO";    // VCO/CLKMINUS1/CLKPLUS1/REFCLK
parameter PREDIV_MUXC3 = "VCO";    // VCO/CLKMINUS1/CLKPLUS1/REFCLK
parameter PREDIV_MUXC4 = "VCO";    // VCO/CLKMINUS1/CLKPLUS1/REFCLK
parameter ODIV_MUXC0 = "DIV";     // "VCO", "CLKMINUS1", "CLKPLUS1", "REFCLK".
parameter ODIV_MUXC1 = "DIV";     // "VCO", "CLKMINUS1", "SSCCLK","REFCLK".
parameter ODIV_MUXC2 = "DIV";     // "VCO", "CLKMINUS1", "SSCCLK","REFCLK".
parameter ODIV_MUXC3 = "DIV";     // "VCO", "CLKMINUS1", "SSCCLK","REFCLK".
parameter ODIV_MUXC4 = "DIV";     // "VCO", "CLKMINUS1", "CLKPLUS1", "REFCLK".
parameter FREQ_LOCK_ACCURACY = 2; // 0~3
parameter PLL_LOCK_MODE = 0;    // 0~7, 2 => sticky, 0 => non-sticky
parameter INTFB_WAKE      = "DISABLE"; // "ENBALE", "DISABLE".
parameter DPHASE_SOURCE   = "DISABLE"; // "ENABLE", "DISABLE".
parameter VCO_NORESET     = "DISABLE"; // "ENABLE", "DISABLE".
parameter STDBY_VCO_ENA   = "DISABLE"; // "ENABLE", "DISABLE".
parameter NORESET         = "DISABLE"; // "ENABLE", "DISABLE".
parameter SYNC_ENABLE     = "ENABLE";  // "ENABLE", "DISABLE".
parameter DERIVE_PLL_CLOCKS = "DISABLE";   // "ENABLE", "DISABLE".
parameter GEN_BASIC_CLOCK   = "DISABLE";   // "ENABLE", "DISABLE".
endmodule
module EG_PHY_CSB (clko, ce, clki,  sel, ignr);//changed in v1
    output clko;
    input [1:0] ce;
    input [1:0] clki;
    input [1:0] sel;
    input [1:0] ignr;
    parameter HOLD      = "YES";      // "YES", "NO".
    parameter INITOUT   = "0";        // "0", "1".
    parameter PRESELECT = "NONE";     // "CLK0", "CLK1", "NONE".
    parameter TESTMODE  = "DISABLE";  // "ENABLE", "DISABLE".
endmodule
module EG_LOGIC_BRAM (
  dia,
  addra, cea, ocea, clka, wea, rsta, bea,
  dib,
  addrb, ceb, oceb, clkb, web, rstb, beb,
  doa,
  dob);
  parameter DATA_WIDTH_A = 9;                                                // DEFAULT 9.
  parameter DATA_WIDTH_B = DATA_WIDTH_A;                                     // DEFAULT 9.
  parameter ADDR_WIDTH_A = 10;                                               // DEFAULT 10.
  parameter ADDR_WIDTH_B = ADDR_WIDTH_A;                                     // DEFAULT 10.
  parameter DATA_DEPTH_A = 2 ** ADDR_WIDTH_A;                                // DEFAULT 1024.
  parameter DATA_DEPTH_B = 2 ** ADDR_WIDTH_B;                                // DEFAULT 1024.
  parameter BYTE_ENABLE = 0;                                                 // 0, 8, 9.
  parameter BYTE_A = BYTE_ENABLE == 0 ? 1 : DATA_WIDTH_A / BYTE_ENABLE;      
  parameter BYTE_B = BYTE_ENABLE == 0 ? 1 : DATA_WIDTH_B / BYTE_ENABLE;      
  output  [DATA_WIDTH_A-1:0] doa;                                             
  output  [DATA_WIDTH_B-1:0] dob;                                             
  input   [DATA_WIDTH_A-1:0] dia; 
  input   [DATA_WIDTH_B-1:0] dib; 
  input   cea;   
  input   ocea;  
  input   clka;  
  input   wea;   
  input   rsta; 
  input   ceb;   
  input	  oceb; 
  input   clkb; 
  input   web; 
  input   rstb; 
  input [BYTE_A - 1 : 0] bea; 
  input [BYTE_B - 1 : 0] beb; 
  input   [ADDR_WIDTH_A-1:0] addra; 
  input   [ADDR_WIDTH_B-1:0] addrb; 
  parameter MODE = "DP";                  // "DP", "SP", "PDPW", "FIFO".
  parameter REGMODE_A = "NOREG";          // "NOREG", "OUTREG".
  parameter REGMODE_B = "NOREG";          // "NOREG", "OUTREG".
  parameter WRITEMODE_A = "NORMAL";       // "NORMAL", "READBEFOREWRITE", "WRITETHROUGH".
  parameter WRITEMODE_B = "NORMAL";       // "NORMAL", "READBEFOREWRITE", "WRITETHROUGH".
  parameter RESETMODE = "SYNC";           // "SYNC", "ASYNC".
  parameter DEBUGGABLE = "NO";            // "YES", "NO".
  parameter PACKABLE = "NO";              // "YES", "NO".
  parameter FORCE_KEEP = "OFF";           // "ON", "OFF".
  parameter INIT_FILE = "NONE";           // DEFAULT "NONE".
  parameter FILL_ALL = "NONE";            // "NONE", "0101".
  parameter IMPLEMENT = "9K";             // "9K", "9K(FAST)", "32K(all capitalized)".
endmodule
module EG_PHY_ADC(clk, pd, s, soc, eoc, dout);
input clk;          
input pd;           
input [2:0] s;      
input soc;          
output eoc;         
output [11:0] dout; 
parameter CH0 = "DISABLE" ;      // "ENABLE", "DISABLE".
parameter CH1 = "DISABLE" ;      // "ENABLE", "DISABLE".
parameter CH2 = "DISABLE" ;      // "ENABLE", "DISABLE".
parameter CH3 = "DISABLE" ;      // "ENABLE", "DISABLE".
parameter CH4 = "DISABLE" ;      // "ENABLE", "DISABLE".
parameter CH5 = "DISABLE" ;      // "ENABLE", "DISABLE".
parameter CH6 = "DISABLE" ;      // "ENABLE", "DISABLE".
parameter CH7 = "DISABLE" ;      // "ENABLE", "DISABLE".
parameter VREF = "DISABLE" ;     // "ENABLE", "DISABLE".
endmodule
