----------------------------------------------------------------------------------
-- Company:
-- Engineer:       Jacques Pelletier
--
-- Create Date:    02:03:05 04/17/2009
-- Design Name:     MAGIC1
-- Module Name:    MAGIC1 - Behavioral
-- Project Name:   Magic-1 VHDL
-- Target Devices: Spartan3
-- Tool versions:
-- Description:
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments: en cours
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity MAGIC1 is
    Port (
		-- Clocks
		CLKS : in  STD_LOGIC;
		IOCLK : in  STD_LOGIC;
		NEG_RESET : in  STD_LOGIC;
		NEG_DMA_REQ : in  STD_LOGIC;
		NEG_FP_WRITE : in  STD_LOGIC;
		CLKM : in  STD_LOGIC;
		FP_L : in  STD_LOGIC_VECTOR(0 to 3);
		--
        NEG_IRQ0 : in  STD_LOGIC;
        NEG_IRQ1 : in  STD_LOGIC;
        NEG_IRQ2 : in  STD_LOGIC;
        NEG_IRQ3 : in  STD_LOGIC;
        NEG_IRQ4 : in  STD_LOGIC;
        NEG_IRQ5 : in  STD_LOGIC;
		-- Front panel 1
        L : out  STD_LOGIC_VECTOR (0 to 15);
		L_FPL : out  STD_LOGIC;
		L_PCODE : out  STD_LOGIC;
		MSWP : out  STD_LOGIC;
        MSWE : out  STD_LOGIC;
		MSWM : out  STD_LOGIC;
        MSWV : out  STD_LOGIC;
		MSWS : out  STD_LOGIC;
        MSWC : out  STD_LOGIC;
		MSWZ : out  STD_LOGIC;
		-- Front panel 2
		XINIT_INST : out  STD_LOGIC;
		MEMORY : out  STD_LOGIC;
		MEMREF : out  STD_LOGIC;
		NEG_STOP_CLK : in  STD_LOGIC;
		NEG_WR : out  STD_LOGIC;
		NEG_RW : out  STD_LOGIC;
		NEG_NW : out  STD_LOGIC;
		NEG_NP : out  STD_LOGIC;
		NEG_HALT : out  STD_LOGIC;
		-- PageTable
		NEG_WAIT : out  STD_LOGIC;
        A : inout  STD_LOGIC_VECTOR (0 to 21);
		DBUS : inout  STD_LOGIC_VECTOR (0 to 7);
		FAST_SRAM_A: out  STD_LOGIC_VECTOR (0 to 14);
		FAST_SRAM_D: inout  STD_LOGIC_VECTOR (0 to 15);
		NEG_FAST_SRAM_OE: out  STD_LOGIC);
end MAGIC1;

architecture Behavioral of MAGIC1 is

component ALU is
    Port ( R : in  STD_LOGIC_VECTOR (0 to 15);     -- Operand 1 (Big endian, MSB is bit 0)
           L : in  STD_LOGIC_VECTOR (0 to 15);		-- Operand 2
           Z : out  STD_LOGIC_VECTOR (0 to 15);		-- Result
           DO_RSHIFT : in  STD_LOGIC;					-- Right shift
           ALUOP_SZ : in  STD_LOGIC;					-- ALU in 8 or 16 bits
           MSWC : in  STD_LOGIC;							-- Carry bit
           USE_CARRY : in  STD_LOGIC;					-- Use carry
           ALUOP : in  STD_LOGIC_VECTOR (0 to 1);  -- Define ALU operations (ADD,SUB,ABD,pass to IR)
           IR : in  STD_LOGIC_VECTOR (0 to 7);		-- (1 to 3) define ALU operations
           ALUV : out  STD_LOGIC;						-- Overflow flag (Only have meaning in signed operations (and, sub)
           ALUC : out  STD_LOGIC;						-- Carry flag
           ALUS : out  STD_LOGIC;						-- Sign flag
           ALUZ : out  STD_LOGIC);						-- Zero flag
end component;

component FaultsandInterrupts is
    Port ( NEG_RESET : in  STD_LOGIC;
           NEG_IRQ0 : in  STD_LOGIC;
           NEG_IRQ1 : in  STD_LOGIC;
           NEG_IRQ2 : in  STD_LOGIC;
           NEG_IRQ3 : in  STD_LOGIC;
           NEG_IRQ4 : in  STD_LOGIC;
           NEG_IRQ5 : in  STD_LOGIC;
           NEG_EL_FCODE : in  STD_LOGIC;
           MSWM : in  STD_LOGIC;
           PRIV : in  STD_LOGIC;
           MSWV : in  STD_LOGIC;
           NEG_TRAPO : in  STD_LOGIC;
           CLKM : in  STD_LOGIC;
           NEG_DMA_REQ : in  STD_LOGIC;
           MSWE : in  STD_LOGIC;
           NEG_NP : in  STD_LOGIC;
           NEG_NW : in  STD_LOGIC;
           NEG_BKPT : in  STD_LOGIC;
           NEG_SYSCALL : in  STD_LOGIC;
           IOCLK : in  STD_LOGIC;
           NEG_NEXT0 : in  STD_LOGIC;
           CLKS : in  STD_LOGIC;
           NEG_CLR_TRAP : in  STD_LOGIC;
           L : out  STD_LOGIC_VECTOR (0 to 15);
           RL_FAULT : inout  STD_LOGIC;
           ENCODER : inout  STD_LOGIC_VECTOR (0 to 3);
           FAULT_PENDING : inout  STD_LOGIC);
end component;

component FieldDecode is
    Port ( IR : in  STD_LOGIC_VECTOR (0 to 7);
           EL : in  STD_LOGIC_VECTOR (0 to 3);
           LATCH : in  STD_LOGIC_VECTOR (0 to 3);
           RL_FPL : out  STD_LOGIC;
           FP_L : in  STD_LOGIC_VECTOR (0 to 3);
           NEG_STOP_CLK : in  STD_LOGIC;
           RCOMMIT : in  STD_LOGIC;
           MISC : in  STD_LOGIC_VECTOR (0 to 3);
           CLKS : in  STD_LOGIC;
           FAULT_PENDING : in  STD_LOGIC;
           ER : in  STD_LOGIC_VECTOR (0 to 1);
           NEG_CLKS : in  STD_LOGIC;
           RL_MDR : out  STD_LOGIC;
           RL_PTB : out  STD_LOGIC;
           RL_A_HI : out  STD_LOGIC;
           RL_B_HI : out  STD_LOGIC;
           RL_SSP : out  STD_LOGIC;
           MSWM : in  STD_LOGIC;
	   LATCH_SZ : in STD_LOGIC;
           RL_C : out  STD_LOGIC;
           RL_PC : out  STD_LOGIC;
           RL_DP : out  STD_LOGIC;
           RL_SP : out  STD_LOGIC;
           RL_A_LO : out  STD_LOGIC;
           RL_B_LO : out  STD_LOGIC;
           NEG_ER_MDR : out  STD_LOGIC;
           NEG_ER_IMM : out  STD_LOGIC;
           NEG_EL_FCODE : out  STD_LOGIC;
           NEG_EL_TPC : out  STD_LOGIC;
           NEG_EL_SSP : out  STD_LOGIC;
           NEG_EL_MDR : out  STD_LOGIC;
           NEG_DMA_ACK : inout  STD_LOGIC;
           RL_MSW : out  STD_LOGIC;
           NEG_EL_MAR : out  STD_LOGIC;
           NEG_EL_MSW : out  STD_LOGIC;
           NEG_EL_C : out  STD_LOGIC;
           NEG_EL_PC : out  STD_LOGIC;
           NEG_EL_DP : out  STD_LOGIC;
           NEG_EL_SP : out  STD_LOGIC;
           NEG_EL_A : out  STD_LOGIC;
           NEG_EL_B : out  STD_LOGIC;
           NEG_CLR_TRAP : out  STD_LOGIC;
           RL_IE : out  STD_LOGIC;
           R_L_PTE : out  STD_LOGIC;
           INIT_INST : out  STD_LOGIC;
           XINIT_INST : out  STD_LOGIC;
	   NEG_DO_RSHIFT : out STD_LOGIC;
	   NEG_DO_BRANCH : out STD_LOGIC;
           NEG_SYSCALL : out  STD_LOGIC;
           NEG_HALT : out  STD_LOGIC;
           NEG_BKPT : out  STD_LOGIC;
           NEG_TRAPO : out  STD_LOGIC;
           NEG_E_PTE : out  STD_LOGIC;
           NEG_SET_FLAGS : out  STD_LOGIC);
end component;

component FieldDecode2 is
    Port ( CLKS : in  STD_LOGIC;
           XL_MODE : in  STD_LOGIC;
           XL_PAGING : in  STD_LOGIC;
           XL_MDR_LO : in  STD_LOGIC;
           XL_MDR_HI : in  STD_LOGIC;
           XL_MAR : in  STD_LOGIC;
           R_RW : in  STD_LOGIC;
           RIMMVAL : in  STD_LOGIC_VECTOR (0 to 1);
           RL_PTB : in  STD_LOGIC;
           RL_FAULT : in  STD_LOGIC;
           FAULT_PENDING : in  STD_LOGIC;
           RCOMMIT : in  STD_LOGIC;
           RL_FPL : in  STD_LOGIC;
           RL_A_HI : in  STD_LOGIC;
           RL_B_HI : in  STD_LOGIC;
           RL_SSP : in  STD_LOGIC;
           RL_C : in  STD_LOGIC;
           RL_PC : in  STD_LOGIC;
           RL_DP : in  STD_LOGIC;
           RL_SP : in  STD_LOGIC;
           RL_A_LO : in  STD_LOGIC;
           RL_B_LO : in  STD_LOGIC;
           RL_MSW : in  STD_LOGIC;
           RL_IE : in  STD_LOGIC;
           R_L_PTE : in  STD_LOGIC;
           RL_MDR : in  STD_LOGIC;
           CLKS_NEG : out  STD_LOGIC;
           L_MODE : out  STD_LOGIC;
           L_PAGING : out  STD_LOGIC;
           L_MDR_LO : out  STD_LOGIC;
           L_MDR_HI : out  STD_LOGIC;
           L_MAR : out  STD_LOGIC;
           COMMIT : out  STD_LOGIC;
           L_FPL : out  STD_LOGIC;
           L_PTB : out  STD_LOGIC;
           L_A_HI : out  STD_LOGIC;
           L_B_HI : out  STD_LOGIC;
           L_SSP : out  STD_LOGIC;
           L_C : out  STD_LOGIC;
           L_PC : out  STD_LOGIC;
           L_DP : out  STD_LOGIC;
           L_SP : out  STD_LOGIC;
           L_A_LO : out  STD_LOGIC;
           L_B_LO : out  STD_LOGIC;
           L_MSW : out  STD_LOGIC;
           L_IE : out  STD_LOGIC;
           L_PTE : out  STD_LOGIC;
           NEG_WR : out  STD_LOGIC;
           L_FAULT : out  STD_LOGIC;
           NEG_RW : out  STD_LOGIC;
           IMMVAL : out  STD_LOGIC_VECTOR (0 to 1));
end component;

component GeneralRegisters is
    Port ( EL_A : in  STD_LOGIC;
           L_A_HI : in  STD_LOGIC;
           L_A_LO : in  STD_LOGIC;
           EL_B : in  STD_LOGIC;
           L_B_HI : in  STD_LOGIC;
           L_B_LO : in  STD_LOGIC;
           EL_C : in  STD_LOGIC;
           L_C : in  STD_LOGIC;
           EL_DP : in  STD_LOGIC;
           L_DP : in  STD_LOGIC;
           EL_SP : in  STD_LOGIC;
           L_SP : in  STD_LOGIC;
           EL_SSP : in  STD_LOGIC;
           L_SSP : in  STD_LOGIC;
           EL_PC : in  STD_LOGIC;
           L_PC : in  STD_LOGIC;
           COMMIT : in  STD_LOGIC;
           EL_TPC : in  STD_LOGIC;
           Z : in  STD_LOGIC_VECTOR (0 to 15);
           L : inout  STD_LOGIC_VECTOR (0 to 15));
end component;

component SpecialRegisters is
    Port ( IMMVAL : in  STD_LOGIC_VECTOR (0 to 1);
           ER_IMM : in  STD_LOGIC;
           R : out  STD_LOGIC_VECTOR (0 to 15);
           RESET : in  STD_LOGIC;
           L_MAR : in  STD_LOGIC;
           Z : in  STD_LOGIC_VECTOR (0 to 15);
           MAR : inout  STD_LOGIC_VECTOR (0 to 15);
           EL_MAR : in  STD_LOGIC;
           L : out  STD_LOGIC_VECTOR (0 to 15));
end component;

component Microcode is
    Port ( NEG_RESET : in  STD_LOGIC;
           CLKM : in  STD_LOGIC;
           INIT_INST : in  STD_LOGIC;
           FAULT_PENDING : in  STD_LOGIC;
           MSWC : in  STD_LOGIC;
           MSWZ : in  STD_LOGIC;
           MSWS : in  STD_LOGIC;
           MSWV : in  STD_LOGIC;
           NEG_DO_BRANCH : in  STD_LOGIC;
           ENCODER : in  STD_LOGIC_VECTOR (0 to 3);
           DBUS : in  STD_LOGIC_VECTOR (0 to 7);
           NEG_DMA_ACK : in  STD_LOGIC;
           NEG_FP_WRITE : in  STD_LOGIC;
           IR : inout  STD_LOGIC_VECTOR (0 to 7);
           NEXT_SIG : inout  STD_LOGIC_VECTOR (0 to 7);
           NEG_NEXT0 : out  STD_LOGIC;
           R_RW : out  STD_LOGIC;
           NEG_E_MDR_HI : inout  STD_LOGIC;
           NEG_E_MDR_LO : inout  STD_LOGIC;
           LATCH : out  STD_LOGIC_VECTOR (0 to 3);
           XL_MAR : out  STD_LOGIC;
           XL_MDR_LO : out  STD_LOGIC;
           XL_MDR_HI : out  STD_LOGIC;
           PRIV : out  STD_LOGIC;
           XL_MODE : out  STD_LOGIC;
           XL_PAGING : out  STD_LOGIC;
           MISC : out  STD_LOGIC_VECTOR (0 to 3);
           EL : out  STD_LOGIC_VECTOR (0 to 3);
           ER : out  STD_LOGIC_VECTOR (0 to 1);
           RIMMVAL : out  STD_LOGIC_VECTOR (0 to 1);
           ALUOP_SZ : out  STD_LOGIC;
           ALUOP : out  STD_LOGIC_VECTOR (0 to 1);
           USE_CARRY : out  STD_LOGIC;
           LATCH_SZ : out  STD_LOGIC;
           RUSER_PTB : out  STD_LOGIC;
           CODE_PTB : out  STD_LOGIC);
end component;

component MDR is
    Port ( DBUS : inout  STD_LOGIC_VECTOR (0 to 7);
           NEG_RW : in  STD_LOGIC;
           DMA_ACK : in  STD_LOGIC;
           Z : in  STD_LOGIC_VECTOR (0 to 15);
           XL_MDR_HI : in  STD_LOGIC;
           XL_MDR_LO : in  STD_LOGIC;
           L_MDR_HI : in  STD_LOGIC;
           L_MDR_LO : in  STD_LOGIC;
           COMMIT : in  STD_LOGIC;
           E_MDR_HI : in  STD_LOGIC;
           E_MDR_LO : in  STD_LOGIC;
           ER_MDR : in  STD_LOGIC;
           EL_MDR : in  STD_LOGIC;
           R : out  STD_LOGIC_VECTOR (0 to 15);
           L : out  STD_LOGIC_VECTOR (0 to 15));
end component;

component MSW is
    Port ( Z : in  STD_LOGIC_VECTOR (0 to 15);
           SET_FLAGS : in  STD_LOGIC;
           ALUV : in  STD_LOGIC;
           ALUS : in  STD_LOGIC;
           ALUC : in  STD_LOGIC;
           ALUZ : in  STD_LOGIC;
           L_MSW : in  STD_LOGIC;
           RESET : in  STD_LOGIC;
           L_MODE : in  STD_LOGIC;
           L_PAGING : in  STD_LOGIC;
           L_FAULT : in  STD_LOGIC;
           MEMREF : in  STD_LOGIC;
           xCODE_PTB : in  STD_LOGIC;
           L_EI : in  STD_LOGIC;
           EL_MSW : in  STD_LOGIC;
           MSWZ : out  STD_LOGIC;
           MSWC : out  STD_LOGIC;
           MSWS : out  STD_LOGIC;
           MSWV : out  STD_LOGIC;
           MSWM : out  STD_LOGIC;
           MSWE : out  STD_LOGIC;
           MSWP : out  STD_LOGIC;
           L : out  STD_LOGIC_VECTOR (0 to 15));
end component;

component PageTable is
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
end component;

signal R_RW : STD_LOGIC;
signal DMA_ACK : STD_LOGIC;
signal CLKS_NEG : STD_LOGIC;
-- signal CLKS : STD_LOGIC;
signal RESET : STD_LOGIC;
-- signal NEG_RESET : STD_LOGIC;
-- signal CLKM : STD_LOGIC;
signal INIT_INST : STD_LOGIC;
signal XINIT_INST_temp : STD_LOGIC;

signal R : STD_LOGIC_VECTOR (0 to 15);
signal L_temp : STD_LOGIC_VECTOR (0 to 15);
signal Z : STD_LOGIC_VECTOR (0 to 15);
signal MAR : STD_LOGIC_VECTOR (0 to 15);
signal IR : STD_LOGIC_VECTOR (0 to 7);
signal IMMVAL : STD_LOGIC_VECTOR (0 to 1);
signal RIMMVAL : STD_LOGIC_VECTOR (0 to 1);
signal MISC : STD_LOGIC_VECTOR (0 to 3);
signal EL : STD_LOGIC_VECTOR (0 to 3);
signal ER : STD_LOGIC_VECTOR (0 to 1);
signal ENCODER : STD_LOGIC_VECTOR (0 to 3);
signal NEXT_SIG : STD_LOGIC_VECTOR (0 to 7);
signal LATCH : STD_LOGIC_VECTOR (0 to 3);

signal DO_RSHIFT : STD_LOGIC;
signal ALUOP_SZ : STD_LOGIC;
signal USE_CARRY : STD_LOGIC;
signal ALUOP : STD_LOGIC_VECTOR (0 to 1);
signal ALUV : STD_LOGIC;
signal ALUC : STD_LOGIC;
signal ALUS : STD_LOGIC;
signal ALUZ : STD_LOGIC;

signal MSWZ_temp : STD_LOGIC;
signal MSWC_temp : STD_LOGIC;
signal MSWS_temp : STD_LOGIC;
signal MSWV_temp : STD_LOGIC;
signal MSWM_temp : STD_LOGIC;
signal MSWE_temp : STD_LOGIC;
signal MSWP_temp : STD_LOGIC;

signal E_MDR_HI : STD_LOGIC;
signal E_MDR_LO : STD_LOGIC;

signal COMMIT : STD_LOGIC;
signal RCOMMIT : STD_LOGIC;
signal SET_FLAGS : STD_LOGIC;
-- signal MEMORY : STD_LOGIC;
signal MEMREF_temp : STD_LOGIC;
signal xCODE_PTB : STD_LOGIC;
signal CODE_PTB : STD_LOGIC;
signal RUSER_PTB : STD_LOGIC;

signal EL_A : STD_LOGIC;
signal EL_B : STD_LOGIC;
signal EL_C : STD_LOGIC;
signal EL_DP : STD_LOGIC;
signal EL_SP : STD_LOGIC;
signal EL_SSP : STD_LOGIC;
signal EL_PC : STD_LOGIC;
signal EL_TPC : STD_LOGIC;
signal EL_MAR : STD_LOGIC;
signal EL_MDR : STD_LOGIC;
signal EL_MSW : STD_LOGIC;

signal L_EI : STD_LOGIC;
signal L_A_HI : STD_LOGIC;
signal L_A_LO : STD_LOGIC;
signal L_B_HI : STD_LOGIC;
signal L_B_LO : STD_LOGIC;
signal L_C : STD_LOGIC;
signal L_DP : STD_LOGIC;
signal L_SP : STD_LOGIC;
signal L_SSP : STD_LOGIC;
signal L_PC : STD_LOGIC;
signal L_MAR : STD_LOGIC;
signal L_MDR_HI : STD_LOGIC;
signal L_MDR_LO : STD_LOGIC;
signal L_MSW : STD_LOGIC;
signal L_MODE : STD_LOGIC;
signal L_PAGING : STD_LOGIC;
signal L_FAULT : STD_LOGIC;
-- signal L_FPL : STD_LOGIC;
signal L_PTB : STD_LOGIC;
signal L_IE : STD_LOGIC;
signal L_PTE : STD_LOGIC;

signal ER_MDR : STD_LOGIC;
signal ER_IMM : STD_LOGIC;
signal FAULT_PENDING : STD_LOGIC;
signal PRIV : STD_LOGIC;
signal XL_MAR : STD_LOGIC;
signal XL_MODE : STD_LOGIC;
signal XL_PAGING : STD_LOGIC;
signal XL_MDR_LO : STD_LOGIC;
signal XL_MDR_HI : STD_LOGIC;
signal LATCH_SZ : STD_LOGIC;
-- signal FP_L : STD_LOGIC_VECTOR (0 to 3);
-- signal RCOMMIT : STD_LOGIC;
-- signal CLKS : STD_LOGIC;
-- signal LATCH_SZ : STD_LOGIC;
signal R_L_PTE : STD_LOGIC;

signal RL_MDR : STD_LOGIC;
signal RL_PTB : STD_LOGIC;
signal RL_A_LO : STD_LOGIC;
signal RL_B_LO : STD_LOGIC;
signal RL_A_HI : STD_LOGIC;
signal RL_B_HI : STD_LOGIC;
signal RL_SSP : STD_LOGIC;
signal RL_C : STD_LOGIC;
signal RL_PC : STD_LOGIC;
signal RL_DP : STD_LOGIC;
signal RL_SP : STD_LOGIC;
signal RL_FAULT : STD_LOGIC;
signal RL_FPL : STD_LOGIC;
signal RL_MSW : STD_LOGIC;
signal RL_IE : STD_LOGIC;

signal NEG_NEXT0 : STD_LOGIC;
signal NEG_DMA_ACK : STD_LOGIC;
signal NEG_E_MDR_HI : STD_LOGIC;
signal NEG_E_MDR_LO : STD_LOGIC;
signal NEG_E_PTE : STD_LOGIC;
signal NEG_ER_MDR : STD_LOGIC;
signal NEG_ER_IMM : STD_LOGIC;
signal NEG_EL_FCODE : STD_LOGIC;
signal NEG_EL_TPC : STD_LOGIC;
signal NEG_EL_SSP : STD_LOGIC;
signal NEG_EL_MDR : STD_LOGIC;
signal NEG_EL_MAR : STD_LOGIC;
signal NEG_EL_MSW : STD_LOGIC;
signal NEG_EL_C : STD_LOGIC;
signal NEG_EL_PC : STD_LOGIC;
signal NEG_EL_DP : STD_LOGIC;
signal NEG_EL_SP : STD_LOGIC;
signal NEG_EL_A : STD_LOGIC;
signal NEG_EL_B : STD_LOGIC;
signal NEG_CLR_TRAP : STD_LOGIC;
signal NEG_DO_RSHIFT : STD_LOGIC;
signal NEG_DO_BRANCH : STD_LOGIC;
signal NEG_SYSCALL : STD_LOGIC;
-- signal NEG_HALT : STD_LOGIC;
signal NEG_BKPT : STD_LOGIC;
signal NEG_CLKS : STD_LOGIC;
signal NEG_TRAPO : STD_LOGIC;
signal NEG_SET_FLAGS : STD_LOGIC;

-- signal NEG_RESET : STD_LOGIC;
-- signal NEG_DMA_REQ : STD_LOGIC;
-- signal NEG_WAIT : STD_LOGIC;
-- signal NEG_WR : STD_LOGIC;
signal NEG_RW_temp : STD_LOGIC;
signal NEG_NP_temp : STD_LOGIC;
signal NEG_NW_temp : STD_LOGIC;
-- signal NEG_BKPT : STD_LOGIC;
-- signal NEG_SYSCALL : STD_LOGIC;
-- signal IOCLK : STD_LOGIC;
-- signal RL_FAULT : STD_LOGIC;
	   	   
begin

  ALU_1:ALU Port map( R,L_temp,Z,DO_RSHIFT,ALUOP_SZ,MSWC_temp,USE_CARRY,ALUOP,IR,ALUV,ALUC,ALUS,ALUZ);
  MDR_1:MDR Port map(DBUS,NEG_RW_temp,DMA_ACK,Z,XL_MDR_HI,XL_MDR_LO,L_MDR_HI,L_MDR_LO,COMMIT,E_MDR_HI,E_MDR_LO,ER_MDR,EL_MDR,R,L);
  MSW_1:MSW Port map( Z,SET_FLAGS,ALUV,ALUS,ALUC,ALUZ,L_MSW,RESET,L_MODE,L_PAGING,L_FAULT,MEMREF_temp,xCODE_PTB,L_EI,
			EL_MSW,MSWZ_temp,MSWC_temp,MSWS_temp,MSWV_temp,MSWM_temp,MSWE_temp,MSWP_temp,L);

  GR_1:GeneralRegisters Port map( EL_A,L_A_HI,L_A_LO,EL_B,L_B_HI,L_B_LO,EL_C,L_C,EL_DP,L_DP,EL_SP,L_SP,EL_SSP,L_SSP,EL_PC,L_PC,COMMIT,EL_TPC,Z,L_temp);

  SR_1:SpecialRegisters Port map( IMMVAL,ER_IMM,R,RESET,L_MAR,Z,MAR,EL_MAR,L);

  MCODE_1: Microcode
  	Port map( NEG_RESET,CLKM,INIT_INST,FAULT_PENDING,MSWC_temp,MSWZ_temp,MSWS_temp,MSWV_temp,NEG_DO_BRANCH,ENCODER,DBUS,
	NEG_DMA_ACK,NEG_FP_WRITE,IR,NEXT_SIG,NEG_NEXT0,R_RW,NEG_E_MDR_HI,NEG_E_MDR_LO,LATCH,
	XL_MAR,XL_MDR_LO,XL_MDR_HI,PRIV,XL_MODE,XL_PAGING,MISC,EL,ER,RIMMVAL,ALUOP_SZ,ALUOP,USE_CARRY,LATCH_SZ,RUSER_PTB,CODE_PTB);

  FD1_1: FieldDecode
  	Port map( IR,EL,LATCH,RL_FPL,FP_L,NEG_STOP_CLK,RCOMMIT,MISC,CLKS,FAULT_PENDING,ER,NEG_CLKS,
		RL_MDR,RL_PTB,RL_A_HI,RL_B_HI,RL_SSP,MSWM_temp,LATCH_SZ,
		RL_C,RL_PC,RL_DP,RL_SP,RL_A_LO,RL_B_LO,NEG_ER_MDR,NEG_ER_IMM,NEG_EL_FCODE,NEG_EL_TPC,NEG_EL_SSP,NEG_EL_MDR,
		NEG_DMA_ACK,RL_MSW,NEG_EL_MAR,NEG_EL_MSW,NEG_EL_C,NEG_EL_PC,NEG_EL_DP,NEG_EL_SP,NEG_EL_A,NEG_EL_B,NEG_CLR_TRAP,
		RL_IE,R_L_PTE,INIT_INST,XINIT_INST_temp,NEG_DO_RSHIFT,NEG_DO_BRANCH,NEG_SYSCALL,NEG_HALT,NEG_BKPT,NEG_TRAPO,NEG_E_PTE,NEG_SET_FLAGS);

  FD2_1: FieldDecode2
  	Port map( CLKS,XL_MODE,XL_PAGING,XL_MDR_LO,XL_MDR_HI,XL_MAR,R_RW,RIMMVAL,RL_PTB,RL_FAULT,FAULT_PENDING,RCOMMIT,RL_FPL,RL_A_HI,RL_B_HI,RL_SSP,
  		RL_C,RL_PC,RL_DP,RL_SP,RL_A_LO,RL_B_LO,RL_MSW,RL_IE,R_L_PTE,RL_MDR,CLKS_NEG,L_MODE,L_PAGING,L_MDR_LO,L_MDR_HI,L_MAR,COMMIT,
		L_FPL,L_PTB,L_A_HI,L_B_HI,L_SSP,L_C,L_PC,L_DP,L_SP,L_A_LO,L_B_LO,L_MSW,L_IE,L_PTE,NEG_WR,L_FAULT,NEG_RW_temp,IMMVAL);
		
  FI_1:FaultsandInterrupts
	Port map( NEG_RESET,NEG_IRQ0,NEG_IRQ1,NEG_IRQ2,NEG_IRQ3,NEG_IRQ4,NEG_IRQ5,NEG_EL_FCODE,MSWM_temp,PRIV,MSWV_temp,NEG_TRAPO,CLKM,NEG_DMA_REQ,
		MSWE_temp,NEG_NP_temp,NEG_NW_temp,NEG_BKPT,NEG_SYSCALL,IOCLK,NEG_NEXT0,CLKS,NEG_CLR_TRAP,L_temp,RL_FAULT,ENCODER,FAULT_PENDING);

  PT_1:PageTable
    Port map( NEG_RESET,CLKM,
           NEG_DMA_ACK,
		   XINIT_INST_temp,
           XL_MDR_LO,
           XL_MDR_HI,
           NEG_E_MDR_HI,
           NEG_E_MDR_LO,
           CODE_PTB,
           RUSER_PTB,	-- USER_PTB
		   L_MAR,
		   L_PTB,
           MSWM_temp,
           MSWP_temp,
		   NEG_E_PTE,
		   NEG_RW_temp,
           L_temp,
           A,
		   FAST_SRAM_A,
		   FAST_SRAM_D,		-- T
		   NEG_FAST_SRAM_OE,
		   NEG_WAIT,
		   NEG_NW_temp,
		   NEG_NP_temp,
		   MEMORY,
		   MEMREF_temp);

	L <= L_temp;
	MSWP <= MSWP_temp;
	MSWE <= MSWE_temp;
	MSWM <= MSWM_temp;
	MSWS <= MSWS_temp;
	MSWZ <= MSWZ_temp;
	MSWV <= MSWV_temp;
	MSWC <= MSWC_temp;
	NEG_RW <= NEG_RW_temp;
	NEG_NP <= NEG_NP_temp;
	NEG_NW <= NEG_NW_temp;
	MEMREF <= MEMREF_temp;
	XINIT_INST <= XINIT_INST_temp;

end Behavioral;

