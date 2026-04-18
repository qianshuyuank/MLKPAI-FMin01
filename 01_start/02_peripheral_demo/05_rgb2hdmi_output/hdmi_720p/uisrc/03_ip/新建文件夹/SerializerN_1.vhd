--------------------------------------------------------------------------------
--
--  File:
--      SerializerN_1.vhd
--
--  Module:
--      SerializerN_1
--
--  Author:
--      Elod Gyorgy
--
--  Date:
--      10/27/2010
--
--  Description:
--      This module serializes N:1 data LSB-first using cascaded OSERDES
--      primitives.
--
--  Copyright notice:
--      Copyright (C) 2014 Digilent Inc.
--
--  License:
--      This program is free software; distributed under the terms of 
--      BSD 3-clause license ("Revised BSD License", "New BSD License", or "Modified BSD License")
--
--      Redistribution and use in source and binary forms, with or without modification,
--      are permitted provided that the following conditions are met:
--
--      1.    Redistributions of source code must retain the above copyright notice, this
--             list of conditions and the following disclaimer.
--      2.    Redistributions in binary form must reproduce the above copyright notice,
--             this list of conditions and the following disclaimer in the documentation
--             and/or other materials provided with the distribution.
--      3.    Neither the name(s) of the above-listed copyright holder(s) nor the names
--             of its contributors may be used to endorse or promote products derived
--             from this software without specific prior written permission.
--
--      THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
--      ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
--      WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
--      IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
--      INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
--      BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
--      DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
--      LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
--      OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
--      OF THE POSSIBILITY OF SUCH DAMAGE.
--
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
-- library UNISIM;
-- use UNISIM.VComponents.all;

entity SerializerN_1 is
    Port ( 	
			DP_I     : in  STD_LOGIC_VECTOR (9 downto 0);
			CLKDIV_I : in  STD_LOGIC                    ; 	--parallel slow clock
			SERCLK_I : in  STD_LOGIC                    ; 	--serial fast clock (CLK_I = CLKDIV_I x 10 / 2)
			RST_I    : in  STD_LOGIC                    ; 	--async reset
			DSP_O    : out STD_LOGIC                   
			);
end SerializerN_1;

architecture Behavioral of SerializerN_1 is

component EG_LOGIC_ODDR is 
generic (
    ASYNCRST : string := "ENABLE"
    );
port (
    q 	: out std_logic ;
    clk : in std_logic 	;
    d1 	: in std_logic 	;
    d0 	: in std_logic 	;
    rst : in std_logic 
    );
end component;


signal intDSOut: std_logic;
signal intDPIn : std_logic_vector(9 downto 0) ;
signal padDPIn : std_logic_vector(1 downto 0) ;
signal cascade_do, cascade_di, cascade_to, cascade_ti : std_logic;
signal gear, gear_s : std_logic := '0';
signal int_rst : std_logic;
begin

----------------------------------------------------------------------------------
-- 2:1 gearbox; SerDes is used in 5:1 ratio, we need to double that; The SerDes
-- parallel input will change twice in a pixel clock, thus the need for pixel
-- clock * 2
----------------------------------------------------------------------------------
process (CLKDIV_I, RST_I)
begin
	if (RST_I = '1') then
		gear <= '0';
	elsif Rising_Edge(CLKDIV_I) then		
		gear <= not gear;
	end if;
end process;

process (SERCLK_I)
begin
	if Rising_Edge(SERCLK_I) then		
		gear_s <= gear; --resync gear on x2 domain
	end if;
end process;

process (SERCLK_I)
begin
	if Rising_Edge(SERCLK_I) then
		if ((gear xor gear_s) = '1') then
			intDPIn <= DP_I(0)&DP_I(1)&DP_I(2)&DP_I(3)&DP_I(4)&DP_I(5)&DP_I(6)&DP_I(7)&DP_I(8)&DP_I(9);
		else
			intDPIn <= intDPIn(7 downto 0) & "00";
		end if ;
	end if;
end process ;

padDPIn(1 downto 0) <= intDPIn(9 downto 8) ;

----------------------------------------------------------------------------------
-- Cascaded OSERDES for 2:1 ratio
----------------------------------------------------------------------------------
ODDR : EG_LOGIC_ODDR 
port map(
    q 	=> DSP_O,
    clk => SERCLK_I,
    d1 	=> padDPIn(0),
    d0 	=> padDPIn(1),
    rst => RST_I
    );

end Behavioral;

