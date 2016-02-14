----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 		 Jacques Pelletier
-- 
-- Create Date:    21:46:13 04/21/2009 
-- Design Name:    PageTable Magic-1
-- Module Name:    PageTable - Behavioral 
-- Project Name:   Magic-1 VHDL
-- Target Devices: Spartan3
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: completed,unchecked
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

-- The fast Static Ram is implemented outside the MAGIC1 core

entity PageTable is
    Port ( NEG_RESET : in  STD_LOGIC;
           CLKM : in  STD_LOGIC;
           NEG_DMA_ACK : in  STD_LOGIC;
		   XINIT_INST : in  STD_LOGIC;
           XL_MDR_LO : in  STD_LOGIC;
           XL_MDR_HI : in  STD_LOGIC;
           NEG_E_MDR_HI : in  STD_LOGIC;
           NEG_E_MDR_LO : in  STD_LOGIC;
           CODE_PTB : in  STD_LOGIC;
           USER_PTB : in  STD_LOGIC;
		   L_MAR : in  STD_LOGIC;
		   L_PTB : in  STD_LOGIC;
           MSWM : in  STD_LOGIC;
           MSWP : in  STD_LOGIC;
		   NEG_E_PTE : in  STD_LOGIC;
		   NEG_RW : in  STD_LOGIC;
           L : in  STD_LOGIC_VECTOR (0 to 15);
           A : inout  STD_LOGIC_VECTOR (0 to 21);
		   FAST_SRAM_A: out  STD_LOGIC_VECTOR (0 to 14);
		   T: inout  STD_LOGIC_VECTOR (0 to 15);
		   NEG_FAST_SRAM_OE: out  STD_LOGIC;
		   NEG_WAIT : out  STD_LOGIC;
		   NEG_NW : out  STD_LOGIC;
		   NEG_NP : out  STD_LOGIC;
		   MEMORY : out  STD_LOGIC;
		   MEMREF: out  STD_LOGIC);
end PageTable;

architecture Behavioral of PageTable is

signal xCODE_PTB : STD_LOGIC;
signal xUSER_PTB : STD_LOGIC;
signal xMSWM : STD_LOGIC;
signal xMSWP : STD_LOGIC;
signal W : STD_LOGIC;
signal F : STD_LOGIC;
signal P : STD_LOGIC;
signal M : STD_LOGIC;
signal MAR : STD_LOGIC_VECTOR(0 to 15);
signal U12_Q : STD_LOGIC_VECTOR(0 to 7);
signal MUX : STD_LOGIC_VECTOR(0 to 15);
signal MEMREF_TEMP: STD_LOGIC;
signal MASK : STD_LOGIC_VECTOR(0 to 7);

begin
	NEG_FAST_SRAM_OE <= not NEG_E_PTE;
	MEMREF_TEMP <= not(NEG_E_MDR_LO and NEG_E_MDR_HI and not(XINIT_INST or XL_MDR_LO or XL_MDR_HI));
	NEG_WAIT <= not(MEMREF_TEMP and not(F and xMSWP));
	NEG_NW <= not(MEMREF_TEMP and xMSWP and NEG_RW and not W);
	NEG_NP <= not(MEMREF_TEMP and xMSWP and not P);

	MEMREF <= MEMREF_TEMP;
	
	MASK(0) <= xMSWM or xUSER_PTB;
	MASK(1) <= xMSWM or xUSER_PTB;
	MASK(2) <= xMSWM or xUSER_PTB;
	MASK(3) <= xMSWM or xUSER_PTB;
	MASK(4) <= xMSWM or xUSER_PTB;
	MASK(5) <= xMSWM or xUSER_PTB;
	MASK(6) <= xMSWM or xUSER_PTB;
	MASK(7) <= xMSWM or xUSER_PTB;

	FAST_SRAM_A <= (MASK and U12_Q) & xCODE_PTB & MAR(0 to 4);

	-- Process to describe U31
	process (NEG_RESET,L_MAR,MSWM,MSWP,CODE_PTB,USER_PTB)
	begin		
		if NEG_RESET = '0' then
				xMSWM <= '0';
				xMSWP <= '0';
				xCODE_PTB <= '0';
				xUSER_PTB <= '0';
		else
			-- Load Register U31
			if rising_edge(L_MAR) then
				xMSWM <= MSWM;
				xMSWP <= MSWP;
				xCODE_PTB <= CODE_PTB;
				xUSER_PTB <= USER_PTB;
			end if;											
		end if;
	end process;
	
	-- Process to describe U12
	process (NEG_RESET,L_PTB,L)
	begin		
		if NEG_RESET = '0' then
				U12_Q <= "00000000";
		else
			-- Load Register U12
			if rising_edge(L_PTB) then
				U12_Q <= L(8 to 15);
			end if;											
		end if;
	end process;

	-- MUX U7 to U10
	process (xMSWP,T,MAR)
	begin
		if xMSWP = '1' then
			MUX <= T;
		else
			MUX <= "00000000000" & MAR(0 to 4);
		end if;
	end process;

	-- U32, U33 buffers
	process (NEG_E_PTE,L)
	begin
		if NEG_E_PTE = '0' then
			T <= L;
		else
			T <= (others => 'Z');
		end if;
	end process;

	-- U3,U4,U5,U6
	process(NEG_DMA_ACK,L_PTB,xMSWP,MUX,MAR)
	begin
		if NEG_DMA_ACK = '1' then
			MEMORY <= 'Z';
			P <= 'Z';
			W <= 'Z';
			M <= 'Z';
			F <= 'Z';
			A <= (others => 'Z');
		else
			if rising_edge(L_PTB) then
				MEMORY <= xMSWP and MUX(2);
				P <= MUX(0);
				W <= MUX(1);
				M <= MUX(2);
				F <= MUX(3);
				A <= MUX(5 to 15) & MAR(5 to 15);
			end if;											
		end if;
	end process;
end Behavioral;

