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
module ui0308reg
(
input      [8 :0]  REG_INDEX,
output reg [31:0]  REG_DATA,
output     [8 :0]  REG_SIZE  
);

assign	LUT_SIZE = 9'd276;

//-----------------------------------------------------------------
/////////////////////	Config Data LUT	  //////////////////////////	
always@(*)
begin
	case(REG_INDEX)
//	GC0308 : VGA RGB565 Config
	//Read Data Index
	0 :		REG_DATA	=	{8'h00, 8'h9B};	//Manufacturer ID Byte - High (Read only)
	1 :		REG_DATA	=	{8'h00, 8'h9B};	//Manufacturer ID Byte - Low (Read only)
	//Write Data Index
    2	: 	REG_DATA	= 	{8'hfe , 8'h80};
    //  GC0308_SET_PAGE0
    3	: 	REG_DATA	= 	{8'hfe,  8'h00};
    4 	: 	REG_DATA	= 	{8'hd2 , 8'h10};	//  close AEC
    5	: 	REG_DATA	= 	{8'h22 , 8'h55};	//  close AWB
    6	: 	REG_DATA	= 	{8'h5a , 8'h56};	
    7	: 	REG_DATA	= 	{8'h5b , 8'h40};	
    8	: 	REG_DATA	= 	{8'h5c , 8'h4a};	
    9	: 	REG_DATA	= 	{8'h22 , 8'h57};	//  Open AWB
    10	: 	REG_DATA	= 	{8'h01 , 8'hfa};	
    11	: 	REG_DATA	= 	{8'h02 , 8'h70};	
    12	: 	REG_DATA	= 	{8'h0f , 8'h01};	
    13	: 	REG_DATA	= 	{8'h03 , 8'h03};	
    14	: 	REG_DATA	= 	{8'h04 , 8'h20};	
    15	: 	REG_DATA	= 	{8'he2 , 8'h00};	//  anti-flicker step [11:8]
    16	: 	REG_DATA	= 	{8'he3 , 8'h64};	//  anti-flicker step [7:0]
    17	: 	REG_DATA	= 	{8'he4 , 8'h02};	//  exp level 0  16.67fps
    18	: 	REG_DATA	= 	{8'he5 , 8'h58};	
    19	: 	REG_DATA	= 	{8'he6 , 8'h03};	//  exp level 1  12.5fps
    20	: 	REG_DATA	= 	{8'he7 , 8'h20};	
    21	: 	REG_DATA	= 	{8'he8 , 8'h04};	//  exp level 2  8.33fps
    22	: 	REG_DATA	= 	{8'he9 , 8'hb0};	
    23	: 	REG_DATA	= 	{8'hea , 8'h09};	//  exp level 3  4.00fps
    24	: 	REG_DATA	= 	{8'heb , 8'hc4};	
    25	: 	REG_DATA	= 	{8'h05 , 8'h00};	
    26	: 	REG_DATA	= 	{8'h06 , 8'h00};	
    27	: 	REG_DATA	= 	{8'h07 , 8'h00};	
    28	: 	REG_DATA	= 	{8'h08 , 8'h00};	
    29	: 	REG_DATA	= 	{8'h09 , 8'h01};	
    30	: 	REG_DATA	= 	{8'h0a , 8'he8};	
    31	: 	REG_DATA	= 	{8'h0b , 8'h02};	
    32	: 	REG_DATA	= 	{8'h0c , 8'h88};	
    33	: 	REG_DATA	= 	{8'h0d , 8'h02};	
    34	: 	REG_DATA	= 	{8'h0e , 8'h02};	
    35	: 	REG_DATA	= 	{8'h10 , 8'h22};	
    36	: 	REG_DATA	= 	{8'h11 , 8'hfd};	
    37	: 	REG_DATA	= 	{8'h12 , 8'h2a};	
    38	: 	REG_DATA	= 	{8'h13 , 8'h00};	
    39	: 	REG_DATA	= 	{8'h14 , 8'h10};	//  [0]锛氭按骞抽暅鍍忥紱[1]锛氬瀭鐩撮暅鍍?
    40	: 	REG_DATA	= 	{8'h15 , 8'h0a};	
    41	: 	REG_DATA	= 	{8'h16 , 8'h05};	
    42	: 	REG_DATA	= 	{8'h17 , 8'h01};	
    43	: 	REG_DATA	= 	{8'h18 , 8'h44};	
    44	: 	REG_DATA	= 	{8'h19 , 8'h44};	
    45	: 	REG_DATA	= 	{8'h1a , 8'h1e};	
    46	: 	REG_DATA	= 	{8'h1b , 8'h00};	
    47	: 	REG_DATA	= 	{8'h1c , 8'hc1};	
    48	: 	REG_DATA	= 	{8'h1d , 8'h08};	
    49	: 	REG_DATA	= 	{8'h1e , 8'h60};	
    50	: 	REG_DATA	= 	{8'h1f , 8'h16};	
    51	: 	REG_DATA	= 	{8'h20 , 8'hff};	
    52	: 	REG_DATA	= 	{8'h21 , 8'hf8};	
    53	: 	REG_DATA	= 	{8'h22 , 8'h57};	
    54	: 	REG_DATA	= 	{8'h24 , 8'hA6};	//  8'hb1:Y; 8'hb4:R; 8'hb5:G; 8'hb6:B
    55	: 	REG_DATA	= 	{8'h25 , 8'h0f};	
    //  output sync_mode	
    56	: 	REG_DATA	= 	{8'h26 , 8'h02};	
    57	: 	REG_DATA	= 	{8'h2f , 8'h01};	
    58	: 	REG_DATA	= 	{8'h30 , 8'hf7};	
    59	: 	REG_DATA	= 	{8'h31 , 8'h50};	
    60	: 	REG_DATA	= 	{8'h32 , 8'h00};	
    61	: 	REG_DATA	= 	{8'h39 , 8'h04};	
    62	: 	REG_DATA	= 	{8'h3a , 8'h18};	
    63	: 	REG_DATA	= 	{8'h3b , 8'h20};	
    64	: 	REG_DATA	= 	{8'h3c , 8'h00};	
    65	: 	REG_DATA	= 	{8'h3d , 8'h00};	
    66	: 	REG_DATA	= 	{8'h3e , 8'h00};	
    67	: 	REG_DATA	= 	{8'h3f , 8'h00};	
    68	: 	REG_DATA	= 	{8'h50 , 8'h10};	
    69	: 	REG_DATA	= 	{8'h53 , 8'h82};	
    70	: 	REG_DATA	= 	{8'h54 , 8'h80};	
    71	: 	REG_DATA	= 	{8'h55 , 8'h80};	
    72	: 	REG_DATA	= 	{8'h56 , 8'h82};	
    73	: 	REG_DATA	= 	{8'h8b , 8'h40};	
    74	: 	REG_DATA	= 	{8'h8c , 8'h40};	
    75	: 	REG_DATA	= 	{8'h8d , 8'h40};	
    76	: 	REG_DATA	= 	{8'h8e , 8'h2e};	
    77	: 	REG_DATA	= 	{8'h8f , 8'h2e};	
    78	: 	REG_DATA	= 	{8'h90 , 8'h2e};	
    79	: 	REG_DATA	= 	{8'h91 , 8'h3c};	
    80	: 	REG_DATA	= 	{8'h92 , 8'h50};	
    81	: 	REG_DATA	= 	{8'h5d , 8'h12};	
    82	: 	REG_DATA	= 	{8'h5e , 8'h1a};	
    83	: 	REG_DATA	= 	{8'h5f , 8'h24};	
    84	: 	REG_DATA	= 	{8'h60 , 8'h07};	
    85	: 	REG_DATA	= 	{8'h61 , 8'h15};	
    86	: 	REG_DATA	= 	{8'h62 , 8'h08};	
    87	: 	REG_DATA	= 	{8'h64 , 8'h03};	
    88	: 	REG_DATA	= 	{8'h66 , 8'he8};	
    89	: 	REG_DATA	= 	{8'h67 , 8'h86};	
    90	: 	REG_DATA	= 	{8'h68 , 8'ha2};	
    91	: 	REG_DATA	= 	{8'h69 , 8'h18};	
    92	: 	REG_DATA	= 	{8'h6a , 8'h0f};	
    93	: 	REG_DATA	= 	{8'h6b , 8'h00};	
    94	: 	REG_DATA	= 	{8'h6c , 8'h5f};	
    95	: 	REG_DATA	= 	{8'h6d , 8'h8f};	
    96	: 	REG_DATA	= 	{8'h6e , 8'h55};	
    97	: 	REG_DATA	= 	{8'h6f , 8'h38};	
    98	: 	REG_DATA	= 	{8'h70 , 8'h15};	
    99	: 	REG_DATA	= 	{8'h71 , 8'h33};	
    100	: 	REG_DATA	= 	{8'h72 , 8'hdc};	
    101	: 	REG_DATA	= 	{8'h73 , 8'h80};	
    102	: 	REG_DATA	= 	{8'h74 , 8'h02};	
    103	: 	REG_DATA	= 	{8'h75 , 8'h3f};	
    104	: 	REG_DATA	= 	{8'h76 , 8'h02};	
    105	: 	REG_DATA	= 	{8'h77 , 8'h36};	
    106	: 	REG_DATA	= 	{8'h78 , 8'h88};	
    107	: 	REG_DATA	= 	{8'h79 , 8'h81};	
    108	: 	REG_DATA	= 	{8'h7a , 8'h81};	
    109	: 	REG_DATA	= 	{8'h7b , 8'h22};	
    110	: 	REG_DATA	= 	{8'h7c , 8'hff};	
    111	: 	REG_DATA	= 	{8'h93 , 8'h48};	
    112	: 	REG_DATA	= 	{8'h94 , 8'h00};	
    113	: 	REG_DATA	= 	{8'h95 , 8'h05};	
    114	: 	REG_DATA	= 	{8'h96 , 8'he8};	
    115	: 	REG_DATA	= 	{8'h97 , 8'h40};	
    116	: 	REG_DATA	= 	{8'h98 , 8'hf0};	
    117	: 	REG_DATA	= 	{8'hb1 , 8'h38};	
    118	: 	REG_DATA	= 	{8'hb2 , 8'h38};	
    119	: 	REG_DATA	= 	{8'hbd , 8'h38};	
    120	: 	REG_DATA	= 	{8'hbe , 8'h36};	
    121	: 	REG_DATA	= 	{8'hd0 , 8'hc9};	
    122	: 	REG_DATA	= 	{8'hd1 , 8'h10};	
    // 	: 	REG_DATA	= 	{8'hd3 , 8'h80};	
    123	: 	REG_DATA	= 	{8'hd5 , 8'hf2};	
    124	: 	REG_DATA	= 	{8'hd6 , 8'h16};	
    125	: 	REG_DATA	= 	{8'hdb , 8'h92};	
    126	: 	REG_DATA	= 	{8'hdc , 8'ha5};	
    127	: 	REG_DATA	= 	{8'hdf , 8'h23};	
    128	: 	REG_DATA	= 	{8'hd9 , 8'h00};	
    129	: 	REG_DATA	= 	{8'hda , 8'h00};	
    130	: 	REG_DATA	= 	{8'he0 , 8'h09};	
    131	: 	REG_DATA	= 	{8'hec , 8'h20};	
    132	: 	REG_DATA	= 	{8'hed , 8'h04};	
    133	: 	REG_DATA	= 	{8'hee , 8'ha0};	
    134	: 	REG_DATA	= 	{8'hef , 8'h40};	
    135	: 	REG_DATA	= 	{8'h80 , 8'h03};	
    136	: 	REG_DATA	= 	{8'h80 , 8'h03};	
    137	: 	REG_DATA	= 	{8'h9F , 8'h10};	
    138	: 	REG_DATA	= 	{8'hA0 , 8'h20};	
    139	: 	REG_DATA	= 	{8'hA1 , 8'h38};	
    140	: 	REG_DATA	= 	{8'hA2 , 8'h4E};	
    141	: 	REG_DATA	= 	{8'hA3 , 8'h63};	
    142	: 	REG_DATA	= 	{8'hA4 , 8'h76};	
    143	: 	REG_DATA	= 	{8'hA5 , 8'h87};	
    144	: 	REG_DATA	= 	{8'hA6 , 8'hA2};	
    145	: 	REG_DATA	= 	{8'hA7 , 8'hB8};	
    146	: 	REG_DATA	= 	{8'hA8 , 8'hCA};	
    147	: 	REG_DATA	= 	{8'hA9 , 8'hD8};	
    148	: 	REG_DATA	= 	{8'hAA , 8'hE3};	
    149	: 	REG_DATA	= 	{8'hAB , 8'hEB};	
    150	: 	REG_DATA	= 	{8'hAC , 8'hF0};	
    151	: 	REG_DATA	= 	{8'hAD , 8'hF8};	
    152	: 	REG_DATA	= 	{8'hAE , 8'hFD};	
    153	: 	REG_DATA	= 	{8'hAF , 8'hFF};	
    154	: 	REG_DATA	= 	{8'hc0 , 8'h00};	
    155	: 	REG_DATA	= 	{8'hc1 , 8'h10};	
    156	: 	REG_DATA	= 	{8'hc2 , 8'h1C};	
    157	: 	REG_DATA	= 	{8'hc3 , 8'h30};	
    158	: 	REG_DATA	= 	{8'hc4 , 8'h43};	
    159	: 	REG_DATA	= 	{8'hc5 , 8'h54};	
    160	: 	REG_DATA	= 	{8'hc6 , 8'h65};	
    161	: 	REG_DATA	= 	{8'hc7 , 8'h75};	
    162	: 	REG_DATA	= 	{8'hc8 , 8'h93};	
    163	: 	REG_DATA	= 	{8'hc9 , 8'hB0};	
    164	: 	REG_DATA	= 	{8'hca , 8'hCB};	
    165	: 	REG_DATA	= 	{8'hcb , 8'hE6};	
    166	: 	REG_DATA	= 	{8'hcc , 8'hFF};	
    167	: 	REG_DATA	= 	{8'hf0 , 8'h02};	
    168	: 	REG_DATA	= 	{8'hf1 , 8'h01};	
    169	: 	REG_DATA	= 	{8'hf2 , 8'h01};	
    170	: 	REG_DATA	= 	{8'hf3 , 8'h30};	
    171	: 	REG_DATA	= 	{8'hf9 , 8'h9f};	
    172	: 	REG_DATA	= 	{8'hfa , 8'h78};	
    //  GC0308_SET_PAGE1	
    173	: 	REG_DATA	= 	{8'hfe,  8'h01};	
    174	: 	REG_DATA	= 	{8'h00 , 8'hf5};	
    175	: 	REG_DATA	= 	{8'h02 , 8'h1a};	
    176	: 	REG_DATA	= 	{8'h0a , 8'ha0};	
    177	: 	REG_DATA	= 	{8'h0b , 8'h60};	
    178	: 	REG_DATA	= 	{8'h0c , 8'h08};	
    179	: 	REG_DATA	= 	{8'h0e , 8'h4c};	
    180	: 	REG_DATA	= 	{8'h0f , 8'h39};	
    181	: 	REG_DATA	= 	{8'h11 , 8'h3f};	
    182	: 	REG_DATA	= 	{8'h12 , 8'h72};	
    183	: 	REG_DATA	= 	{8'h13 , 8'h13};	
    184	: 	REG_DATA	= 	{8'h14 , 8'h42};	
    185	: 	REG_DATA	= 	{8'h15 , 8'h43};	
    186	: 	REG_DATA	= 	{8'h16 , 8'hc2};	
    187	: 	REG_DATA	= 	{8'h17 , 8'ha8};	
    188	: 	REG_DATA	= 	{8'h18 , 8'h18};	
    189	: 	REG_DATA	= 	{8'h19 , 8'h40};	
    190	: 	REG_DATA	= 	{8'h1a , 8'hd0};	
    191	: 	REG_DATA	= 	{8'h1b , 8'hf5};	
    192	: 	REG_DATA	= 	{8'h70 , 8'h40};	
    193	: 	REG_DATA	= 	{8'h71 , 8'h58};	
    194	: 	REG_DATA	= 	{8'h72 , 8'h30};	
    195	: 	REG_DATA	= 	{8'h73 , 8'h48};	
    196	: 	REG_DATA	= 	{8'h74 , 8'h20};	
    197	: 	REG_DATA	= 	{8'h75 , 8'h60};	
    198	: 	REG_DATA	= 	{8'h77 , 8'h20};	
    199	: 	REG_DATA	= 	{8'h78 , 8'h32};	
    200	: 	REG_DATA	= 	{8'h30 , 8'h03};	
    201	: 	REG_DATA	= 	{8'h31 , 8'h40};	
    202	: 	REG_DATA	= 	{8'h32 , 8'he0};	
    203	: 	REG_DATA	= 	{8'h33 , 8'he0};	
    204	: 	REG_DATA	= 	{8'h34 , 8'he0};	
    205	: 	REG_DATA	= 	{8'h35 , 8'hb0};	
    206	: 	REG_DATA	= 	{8'h36 , 8'hc0};	
    207	: 	REG_DATA	= 	{8'h37 , 8'hc0};	
    208	: 	REG_DATA	= 	{8'h38 , 8'h04};	
    209	: 	REG_DATA	= 	{8'h39 , 8'h09};	
    210	: 	REG_DATA	= 	{8'h3a , 8'h12};	
    211	: 	REG_DATA	= 	{8'h3b , 8'h1C};	
    212	: 	REG_DATA	= 	{8'h3c , 8'h28};	
    213	: 	REG_DATA	= 	{8'h3d , 8'h31};	
    214	: 	REG_DATA	= 	{8'h3e , 8'h44};	
    215	: 	REG_DATA	= 	{8'h3f , 8'h57};	
    216	: 	REG_DATA	= 	{8'h40 , 8'h6C};	
    217	: 	REG_DATA	= 	{8'h41 , 8'h81};	
    218	: 	REG_DATA	= 	{8'h42 , 8'h94};	
    219	: 	REG_DATA	= 	{8'h43 , 8'hA7};	
    220	: 	REG_DATA	= 	{8'h44 , 8'hB8};	
    221	: 	REG_DATA	= 	{8'h45 , 8'hD6};	
    222	: 	REG_DATA	= 	{8'h46 , 8'hEE};	
    223	: 	REG_DATA	= 	{8'h47 , 8'h0d};	
    //  GC0308_SET_PAGE0	
    224	: 	REG_DATA	= 	{8'hfe,  8'h00};	
    225	: 	REG_DATA	= 	{8'hd2 , 8'h90};	//  Open AEC at last.
//    226	: 	REG_DATA	= 	{8'hd2 , 8'h10};	//  Open AEC at last.
    227	: 	REG_DATA	= 	{8'h10 , 8'h26};	
    228	: 	REG_DATA	= 	{8'h11 , 8'h0d};	
    229	: 	REG_DATA	= 	{8'h1a , 8'h2a};	
    230	: 	REG_DATA	= 	{8'h1c , 8'h49};	
    231	: 	REG_DATA	= 	{8'h1d , 8'h9a};	
    232	: 	REG_DATA	= 	{8'h1e , 8'h61};	
    233	: 	REG_DATA	= 	{8'h3a , 8'h20};	
    234	: 	REG_DATA	= 	{8'h50 , 8'h14};	
    235	: 	REG_DATA	= 	{8'h53 , 8'h80};	
    236	: 	REG_DATA	= 	{8'h56 , 8'h80};	
    237	: 	REG_DATA	= 	{8'h8b , 8'h20};	//  LSC
    238	: 	REG_DATA	= 	{8'h8c , 8'h20};	
    239	: 	REG_DATA	= 	{8'h8d , 8'h20};	
    240	: 	REG_DATA	= 	{8'h8e , 8'h14};	
    241	: 	REG_DATA	= 	{8'h8f , 8'h10};	
    242	: 	REG_DATA	= 	{8'h90 , 8'h14};	
    243	: 	REG_DATA	= 	{8'h94 , 8'h02};	
    244	: 	REG_DATA	= 	{8'h95 , 8'h07};	
    245	: 	REG_DATA	= 	{8'h96 , 8'he0};	
    246	: 	REG_DATA	= 	{8'hb1 , 8'h40};	//  YCPT
    247	: 	REG_DATA	= 	{8'hb2 , 8'h40};	
    248	: 	REG_DATA	= 	{8'hb3 , 8'h40};	
    249	: 	REG_DATA	= 	{8'hb6 , 8'he0};	
    250	: 	REG_DATA	= 	{8'hd0 , 8'hcb};	//  AECT c9,modifed by mormo 2010/07/06
    251	: 	REG_DATA	= 	{8'hd3 , 8'h48};	//  80,modified by mormor 2010/07/06
    252	: 	REG_DATA	= 	{8'hf2 , 8'h02};	
    253	: 	REG_DATA	= 	{8'hf7 , 8'h12};	
    254	: 	REG_DATA	= 	{8'hf8 , 8'h0a};	
    //  GC0308_SET_PAGE1	
    255	: 	REG_DATA	= 	{8'hfe,  8'h01};	
    256	: 	REG_DATA	= 	{8'h02 , 8'h20};	
    257	: 	REG_DATA	= 	{8'h04 , 8'h10};	
    258	: 	REG_DATA	= 	{8'h05 , 8'h08};	
    259	: 	REG_DATA	= 	{8'h06 , 8'h20};	
    260	: 	REG_DATA	= 	{8'h08 , 8'h0a};	
    261	: 	REG_DATA	= 	{8'h0e , 8'h44};	
    262	: 	REG_DATA	= 	{8'h0f , 8'h32};	
    263	: 	REG_DATA	= 	{8'h10 , 8'h41};	
    264	: 	REG_DATA	= 	{8'h11 , 8'h37};	
    265	: 	REG_DATA	= 	{8'h12 , 8'h22};	
    266	: 	REG_DATA	= 	{8'h13 , 8'h19};	
    267	: 	REG_DATA	= 	{8'h14 , 8'h44};	
    268	: 	REG_DATA	= 	{8'h15 , 8'h44};	
    269	: 	REG_DATA	= 	{8'h19 , 8'h50};	
    270	: 	REG_DATA	= 	{8'h1a , 8'hd8};	
    271	: 	REG_DATA	= 	{8'h32 , 8'h10};	
    272	: 	REG_DATA	= 	{8'h35 , 8'h00};	
    273	: 	REG_DATA	= 	{8'h36 , 8'h80};	
    274	: 	REG_DATA	= 	{8'h37 , 8'h00};	
    //  GC0308_SET_PAGE0	
    275	: 	REG_DATA	= 	{8'hfe , 8'h00};	
	default:REG_DATA	=	{8'h00,  8'h8B};	
	endcase
end

endmodule
