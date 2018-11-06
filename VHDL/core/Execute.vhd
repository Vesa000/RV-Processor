library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library work;
use work.cpu_constants.all;


entity Execute is Port (
	I_clk : in STD_LOGIC;
	I_reset : in STD_LOGIC;

	I_instData : in STD_LOGIC_VECTOR (31 downto 0);
	--O_instData : out STD_LOGIC_VECTOR (31 downto 0);
	I_instAddr : in STD_LOGIC_VECTOR (63 downto 0);
	--O_instAddr : out STD_LOGIC_VECTOR (63 downto 0);
	--O_execute : out STD_LOGIC;

	I_instruction : in integer;
	I_rs1 : in STD_LOGIC_VECTOR (63 downto 0);
	I_rs2 : in STD_LOGIC_VECTOR (63 downto 0);
	I_rd : in STD_LOGIC_VECTOR (4 downto 0);
	I_immediate : in STD_LOGIC_VECTOR (63 downto 0);
	I_memRdy : in STD_LOGIC;
	I_memData : in STD_LOGIC_VECTOR (63 downto 0);

	O_StoreReg : out STD_LOGIC;
	O_StoreMem : out STD_LOGIC;
	O_strWidth : out STD_LOGIC_VECTOR (1 downto 0);
	O_MemRead : out STD_LOGIC;
	O_memAddr : out STD_LOGIC_VECTOR (63 downto 0);
	O_data : out STD_LOGIC_VECTOR (63 downto 0);
	O_rd : out STD_LOGIC_VECTOR(4 downto 0);
	O_PC : out STD_LOGIC_VECTOR (63 downto 0);
	O_clearFD : out STD_LOGIC;
	O_pauseFD : out STD_LOGIC
	);
end Execute;

architecture Behavioral of Execute is

signal R_instData: std_logic_vector(31 downto 0);
signal R_instAddr: std_logic_vector(63 downto 0);

signal R_oldData: std_logic_vector(63 downto 0);
signal R_oldAddress: std_logic_vector(4 downto 0);

signal R_instruction : integer;
signal R_immediate : std_logic_vector(63 downto 0);
signal R_rs1: std_logic_vector(63 downto 0);
signal R_rs2: std_logic_vector(63 downto 0);
signal R_rd : std_logic_vector(4  downto 0);

signal W_setPC: STD_LOGIC;
signal W_pausePC: STD_LOGIC;
signal W_newPC: std_logic_vector(63 downto 0);

signal W_shiftValue: std_logic_vector(63 downto 0);
signal W_shift: std_logic_vector(4 downto 0);
signal W_shiftLeftArith: std_logic_vector(63 downto 0);
signal W_shiftRightArith: std_logic_vector(63 downto 0);
signal W_shiftLeftLogic: std_logic_vector(63 downto 0);
signal W_shiftRightLogic: std_logic_vector(63 downto 0);


component ProgramCounter Port (
		I_clk : in STD_LOGIC;
		I_reset : in STD_LOGIC;
		I_setPC : in STD_LOGIC;
		I_newPC : in std_logic_vector(63 downto 0);
		I_pausePC:in  STD_LOGIC;
		O_pc : out STD_LOGIC_VECTOR (63 downto 0)
		);
		
end component;

component barrelshifter port (
        I_dIn        : in  std_logic_vector(63 downto 0);
        I_shift      : in  std_logic_vector(4  downto 0);
        O_leftArith  : out std_logic_vector(63 downto 0);
        O_rightArith : out std_logic_vector(63 downto 0);
        O_leftLogic  : out std_logic_vector(63 downto 0);
        O_rightLogic : out std_logic_vector(63 downto 0)
        );
end component;

begin

ProgCntr: ProgramCounter port map(
		I_clk => I_clk,
		I_reset => I_reset,
		I_setPC => W_setPC,
		I_newPC => W_newPC,
		I_pausePC => W_pausePC,
		O_pc => O_PC
		);

shifter: barrelshifter port map(
        I_dIn         => W_shiftValue,
        I_shift       => W_shift,
        O_leftArith   => W_shiftLeftArith,
        O_rightArith  => W_shiftRightArith,
        O_leftLogic   => W_shiftLeftLogic,
        O_rightLogic  => W_shiftRightLogic
        );


regProcess :process(all)
begin
	if(rising_edge(I_clk)) then
		if(NOT O_pauseFD) then
			R_instData <= I_instData;
			R_instAddr <= I_instAddr;

			R_instruction <= I_instruction;
			R_immediate <= I_immediate;
			R_rs1 <= I_rs1;
			R_rs2 <= I_rs2;
			R_rd  <= I_rd;
		end if;
	end if;
end process;

ExecuteProcess :process(all)
begin
	if(I_reset) then
		O_StoreReg <= '0';
		O_rd       <= (others => '0');
		O_StoreMem <= '0';
		O_MemRead  <= '0';
		O_memAddr  <= (others => '0');
		O_strWidth <= "00";
		W_setPC    <= '1';
		W_pausePC  <= '0';
		W_newPC    <= std_logic_vector(to_signed(MEM_PROG_START,64));
		O_clearFD  <= '1';
		O_pauseFD  <= '0';
		O_data     <= (others => '0');
	else
		case R_instruction is
/*
			when INSTRUCTION_NOP =>
				O_StoreReg <= '0';
				O_rd       <= (others => '0');
				O_StoreMem <= '0';
				O_MemRead  <= '0';
				O_memAddr  <= (others => '0');
				O_strWidth <= "00";
				W_setPC    <= '0';
				W_pausePC  <= '0';
				W_newPC    <= (others => '0');
				O_clearFD  <= '0';
				O_pauseFD  <= '0';
				O_data     <= (others => '0');

			when INSTRUCTION_LUI =>
				O_StoreReg <= '1';
				O_rd       <= R_rd;
				O_StoreMem <= '0';
				O_MemRead  <= '0';
				O_memAddr  <= (others => '0');
				O_strWidth <= "00";
				W_setPC    <= '0';
				W_pausePC  <= '0';
				W_newPC    <= (others => '0');
				O_clearFD  <= '0';
				O_pauseFD  <= '0';
				O_data     <= R_immediate;

			when INSTRUCTION_AUIPC =>
				O_StoreReg <= '1';
				O_rd       <= R_rd;
				O_StoreMem <= '0';
				O_MemRead  <= '0';
				O_memAddr  <= (others => '0');
				O_strWidth <= "00";
				W_setPC    <= '0';
				W_pausePC  <= '0';
				W_newPC    <= (others => '0');
				O_clearFD  <= '0';
				O_pauseFD  <= '0';
				O_data     <= std_logic_vector(unsigned(R_immediate) + unsigned(R_instAddr));

			when INSTRUCTION_JAL =>
				O_StoreReg <= '1';
				O_rd       <= R_rd;
				O_StoreMem <= '0';
				O_MemRead  <= '0';
				O_memAddr  <= (others => '0');
				O_strWidth <= "00";
				W_setPC    <= '1';
				W_pausePC  <= '0';
				W_newPC    <= std_logic_vector(unsigned(R_instAddr) + unsigned(R_immediate));
				O_clearFD  <= '1';
				O_pauseFD  <= '0';
				O_data     <= std_logic_vector(unsigned(R_instAddr) + 4);

			when INSTRUCTION_JALR =>
				O_StoreReg <= '1';
				O_rd       <= R_rd;
				O_StoreMem <= '0';
				O_MemRead  <= '0';
				O_memAddr  <= (others => '0');
				O_strWidth <= "00";
				W_setPC    <= '1';
				W_pausePC  <= '0';
				W_newPC    <= std_logic_vector(unsigned(R_rs1) + unsigned(R_immediate));
				W_newPC(0) <= '0';
				O_clearFD  <= '1';
				O_pauseFD  <= '0';
				O_data     <= std_logic_vector(unsigned(R_instAddr) + 4);

			when INSTRUCTION_BEQ =>
				if(R_rs1 = R_rs2) then
					O_StoreReg <= '0';
					O_rd       <= (others => '0');
					O_StoreMem <= '0';
					O_MemRead  <= '0';
					O_memAddr  <= (others => '0');
					O_strWidth <= "00";
					W_setPC    <= '1';
					W_pausePC  <= '0';
					W_newPC    <= std_logic_vector(unsigned(R_instAddr) + unsigned(R_immediate));
					O_clearFD  <= '1';
					O_pauseFD  <= '0';
					O_data     <= (others => '0');
				else
					O_StoreReg <= '0';
					O_rd       <= (others => '0');
					O_StoreMem <= '0';
					O_MemRead  <= '0';
					O_memAddr  <= (others => '0');
					O_strWidth <= "00";
					W_setPC    <= '0';
					W_pausePC  <= '0';
					W_newPC    <= (others => '0');
					O_clearFD  <= '0';
					O_pauseFD  <= '0';
					O_data     <= (others => '0');
				end if;

			when INSTRUCTION_BNE =>
				if(R_rs1 /= R_rs2) then
					O_StoreReg <= '0';
					O_rd       <= (others => '0');
					O_StoreMem <= '0';
					O_MemRead  <= '0';
					O_memAddr  <= (others => '0');
					O_strWidth <= "00";
					W_setPC    <= '1';
					W_pausePC  <= '0';
					W_newPC    <= std_logic_vector(unsigned(R_instAddr) + unsigned(R_immediate));
					O_clearFD  <= '1';
					O_pauseFD  <= '0';
					O_data     <= (others => '0');
				else
					O_StoreReg <= '0';
					O_rd       <= (others => '0');
					O_StoreMem <= '0';
					O_MemRead  <= '0';
					O_memAddr  <= (others => '0');
					O_strWidth <= "00";
					W_setPC    <= '0';
					W_pausePC  <= '0';
					W_newPC    <= (others => '0');
					O_clearFD  <= '0';
					O_pauseFD  <= '0';
					O_data     <= (others => '0');
				end if;

			when INSTRUCTION_BLT =>
				if(signed(R_rs1) < signed(R_rs2)) then
					O_StoreReg <= '0';
					O_rd       <= (others => '0');
					O_StoreMem <= '0';
					O_MemRead  <= '0';
					O_memAddr  <= (others => '0');
					O_strWidth <= "00";
					W_setPC    <= '1';
					W_pausePC  <= '0';
					W_newPC    <= std_logic_vector(unsigned(R_instAddr) + unsigned(R_immediate));
					O_clearFD  <= '1';
					O_pauseFD  <= '0';
					O_data     <= (others => '0');
				else
					O_StoreReg <= '0';
					O_rd       <= (others => '0');
					O_StoreMem <= '0';
					O_MemRead  <= '0';
					O_memAddr  <= (others => '0');
					O_strWidth <= "00";
					W_setPC    <= '0';
					W_pausePC  <= '0';
					W_newPC    <= (others => '0');
					O_clearFD  <= '0';
					O_pauseFD  <= '0';
					O_data     <= (others => '0');
				end if;

			when INSTRUCTION_BGE =>
				if(NOT(signed(R_rs1) < signed(R_rs2))) then
					O_StoreReg <= '0';
					O_rd       <= (others => '0');
					O_StoreMem <= '0';
					O_MemRead  <= '0';
					O_memAddr  <= (others => '0');
					O_strWidth <= "00";
					W_setPC    <= '1';
					W_pausePC  <= '0';
					W_newPC    <= std_logic_vector(unsigned(R_instAddr) + unsigned(R_immediate));
					O_clearFD  <= '1';
					O_pauseFD  <= '0';
					O_data     <= (others => '0');
				else
					O_StoreReg <= '0';
					O_rd       <= (others => '0');
					O_StoreMem <= '0';
					O_MemRead  <= '0';
					O_memAddr  <= (others => '0');
					O_strWidth <= "00";
					W_setPC    <= '0';
					W_pausePC  <= '0';
					W_newPC    <= (others => '0');
					O_clearFD  <= '0';
					O_pauseFD  <= '0';
					O_data     <= (others => '0');
				end if;

			when INSTRUCTION_BLTU =>
				if(unsigned(R_rs1) < unsigned(R_rs2)) then
					O_StoreReg <= '0';
					O_rd       <= (others => '0');
					O_StoreMem <= '0';
					O_MemRead  <= '0';
					O_memAddr  <= (others => '0');
					O_strWidth <= "00";
					W_setPC    <= '1';
					W_pausePC  <= '0';
					W_newPC    <= std_logic_vector(unsigned(R_instAddr) + unsigned(R_immediate));
					O_clearFD  <= '1';
					O_pauseFD  <= '0';
					O_data     <= (others => '0');
				else
					O_StoreReg <= '0';
					O_rd       <= (others => '0');
					O_StoreMem <= '0';
					O_MemRead  <= '0';
					O_memAddr  <= (others => '0');
					O_strWidth <= "00";
					W_setPC    <= '0';
					W_pausePC  <= '0';
					W_newPC    <= (others => '0');
					O_clearFD  <= '0';
					O_pauseFD  <= '0';
					O_data     <= (others => '0');
				end if;

			when INSTRUCTION_BGEU =>
				if(NOT(unsigned(R_rs1) < unsigned(R_rs2))) then
					O_StoreReg <= '0';
					O_rd       <= (others => '0');
					O_StoreMem <= '0';
					O_MemRead  <= '0';
					O_memAddr  <= (others => '0');
					O_strWidth <= "00";
					W_setPC    <= '1';
					W_pausePC  <= '0';
					W_newPC    <= std_logic_vector(unsigned(R_instAddr) + unsigned(R_immediate));
					O_clearFD  <= '1';
					O_pauseFD  <= '0';
					O_data     <= (others => '0');
				else
					O_StoreReg <= '0';
					O_rd       <= (others => '0');
					O_StoreMem <= '0';
					O_MemRead  <= '0';
					O_memAddr  <= (others => '0');
					O_strWidth <= "00";
					W_setPC    <= '0';
					W_pausePC  <= '0';
					W_newPC    <= (others => '0');
					O_clearFD  <= '0';
					O_pauseFD  <= '0';
					O_data     <= (others => '0');
				end if;

			when INSTRUCTION_LB =>
				if(NOT I_memRdy)then
					O_StoreReg <= '0';
					O_rd       <= (others => '0');
					O_StoreMem <= '0';
					O_MemRead  <= '1';
					O_memAddr  <= std_logic_vector(signed(R_rs1) + signed(R_immediate));
					O_strWidth <= "00";
					W_setPC    <= '0';
					W_pausePC  <= '1';
					W_newPC    <= (others => '0');
					O_clearFD  <= '0';
					O_pauseFD  <= '1';
					O_data     <= (others => '0');
				else
					O_StoreReg <= '1';
					O_rd       <= R_rd;
					O_StoreMem <= '0';
					O_MemRead  <= '0';
					O_memAddr  <= (others => '0');
					O_strWidth <= "00";
					W_setPC    <= '0';
					W_pausePC  <= '0';
					W_newPC    <= (others => '0');
					O_clearFD  <= '0';
					O_pauseFD  <= '0';
					O_data(7  downto 0) <= I_memData(7 downto 0);
					O_data(63 downto 8) <= (others => I_memData(7));--sext
				end if;

			when INSTRUCTION_LH =>
				if(NOT I_memRdy)then
					O_StoreReg <= '0';
					O_rd       <= (others => '0');
					O_StoreMem <= '0';
					O_MemRead  <= '1';
					O_memAddr  <= std_logic_vector(signed(R_rs1) + signed(R_immediate));
					O_strWidth <= "00";
					W_setPC    <= '0';
					W_pausePC  <= '1';
					W_newPC    <= (others => '0');
					O_clearFD  <= '0';
					O_pauseFD  <= '1';
					O_data     <= (others => '0');
				else
					O_StoreReg <= '1';
					O_rd       <= R_rd;
					O_StoreMem <= '0';
					O_MemRead  <= '0';
					O_memAddr  <= (others => '0');
					O_strWidth <= "00";
					W_setPC    <= '0';
					W_pausePC  <= '0';
					W_newPC    <= (others => '0');
					O_clearFD  <= '0';
					O_pauseFD  <= '0';
					O_data(15  downto 0) <= I_memData(15 downto 0);
					O_data(63 downto 16) <= (others => I_memData(15));--sext
				end if;

			when INSTRUCTION_LW =>
				if(NOT I_memRdy)then
					O_StoreReg <= '0';
					O_rd       <= (others => '0');
					O_StoreMem <= '0';
					O_MemRead  <= '1';
					O_memAddr  <= std_logic_vector(signed(R_rs1) + signed(R_immediate));
					O_strWidth <= "00";
					W_setPC    <= '0';
					W_pausePC  <= '1';
					W_newPC    <= (others => '0');
					O_clearFD  <= '0';
					O_pauseFD  <= '1';
					O_data     <= (others => '0');
				else
					O_StoreReg <= '1';
					O_rd       <= R_rd;
					O_StoreMem <= '0';
					O_MemRead  <= '0';
					O_memAddr  <= (others => '0');
					O_strWidth <= "00";
					W_setPC    <= '0';
					W_pausePC  <= '0';
					W_newPC    <= (others => '0');
					O_clearFD  <= '0';
					O_pauseFD  <= '0';
					O_data(31  downto 0) <= I_memData(31 downto 0);
					O_data(63 downto 32) <= (others => I_memData(31));--sext
				end if;

			when INSTRUCTION_LBU =>
				if(NOT I_memRdy)then
					O_StoreReg <= '0';
					O_rd       <= (others => '0');
					O_StoreMem <= '0';
					O_MemRead  <= '1';
					O_memAddr  <= std_logic_vector(signed(R_rs1) + signed(R_immediate));
					O_strWidth <= "00";
					W_setPC    <= '0';
					W_pausePC  <= '1';
					W_newPC    <= (others => '0');
					O_clearFD  <= '0';
					O_pauseFD  <= '1';
					O_data     <= (others => '0');
				else
					O_StoreReg <= '1';
					O_rd       <= R_rd;
					O_StoreMem <= '0';
					O_MemRead  <= '0';
					O_memAddr  <= (others => '0');
					O_strWidth <= "00";
					W_setPC    <= '0';
					W_pausePC  <= '0';
					W_newPC    <= (others => '0');
					O_clearFD  <= '0';
					O_pauseFD  <= '0';
					O_data(7  downto 0) <= I_memData(7 downto 0);
					O_data(63 downto 8) <= (others => '0');
				end if;

			when INSTRUCTION_LHU =>
				if(NOT I_memRdy)then
					O_StoreReg <= '0';
					O_rd       <= (others => '0');
					O_StoreMem <= '0';
					O_MemRead  <= '1';
					O_memAddr  <= std_logic_vector(signed(R_rs1) + signed(R_immediate));
					O_strWidth <= "00";
					W_setPC    <= '0';
					W_pausePC  <= '1';
					W_newPC    <= (others => '0');
					O_clearFD  <= '0';
					O_pauseFD  <= '1';
					O_data     <= (others => '0');
				else
					O_StoreReg <= '1';
					O_rd       <= R_rd;
					O_StoreMem <= '0';
					O_MemRead  <= '0';
					O_memAddr  <= (others => '0');
					O_strWidth <= "00";
					W_setPC    <= '0';
					W_pausePC  <= '0';
					W_newPC    <= (others => '0');
					O_clearFD  <= '0';
					O_pauseFD  <= '0';
					O_data(15  downto 0) <= I_memData(15 downto 0);
					O_data(63 downto 16) <= (others => '0');
				end if;

			when INSTRUCTION_SB =>
				O_StoreReg <= '0';
				O_rd       <= (others => '0');
				O_StoreMem <= '1';
				O_MemRead  <= '0';
				O_memAddr  <= std_logic_vector(signed(R_rs1) + signed(R_immediate));
				O_strWidth <= "00";
				W_setPC    <= '0';
				W_pausePC  <= '0';
				W_newPC    <= (others => '0');
				O_clearFD  <= '0';
				O_pauseFD  <= '0';
				O_data     <= I_rs2;

			when INSTRUCTION_SH =>
				O_StoreReg <= '0';
				O_rd       <= (others => '0');
				O_StoreMem <= '1';
				O_MemRead  <= '0';
				O_memAddr  <= std_logic_vector(signed(R_rs1) + signed(R_immediate));
				O_strWidth <= "01";
				W_setPC    <= '0';
				W_pausePC  <= '0';
				W_newPC    <= (others => '0');
				O_clearFD  <= '0';
				O_pauseFD  <= '0';
				O_data     <= I_rs2;
*/
			when INSTRUCTION_SW =>
				O_StoreReg <= '0';
				O_rd       <= (others => '0');
				O_StoreMem <= '1';
				O_MemRead  <= '0';
				O_memAddr  <= std_logic_vector(signed(R_rs1) + signed(R_immediate));
				O_strWidth <= "10";
				W_setPC    <= '0';
				W_pausePC  <= '0';
				W_newPC    <= (others => '0');
				O_clearFD  <= '0';
				O_pauseFD  <= '0';
				O_data     <= I_rs2;
/*				
			when INSTRUCTION_ADDI =>
				O_StoreReg <= '1';
				O_rd       <= R_rd;
				O_StoreMem <= '0';
				O_MemRead  <= '0';
				O_memAddr  <= (others => '0');
				O_strWidth <= "00";
				W_setPC    <= '0';
				W_pausePC  <= '0';
				W_newPC    <= (others => '0');
				O_clearFD  <= '0';
				O_pauseFD  <= '0';
				O_data     <= std_logic_vector(signed(R_rs1) + signed(R_immediate));

			when INSTRUCTION_SLTI =>
				O_StoreReg <= '1';
				O_rd       <= R_rd;
				O_StoreMem <= '0';
				O_MemRead  <= '0';
				O_memAddr  <= (others => '0');
				O_strWidth <= "00";
				W_setPC    <= '0';
				W_pausePC  <= '0';
				W_newPC    <= (others => '0');
				O_clearFD  <= '0';
				O_pauseFD  <= '0';
				if(signed(R_rs1) < signed(R_immediate)) then
					O_data(0) <= '1';
				else
					O_data(0) <= '0';
				end if;
				O_data(63 downto 1) <= (others => '0');

			when INSTRUCTION_SLTIU =>
				O_StoreReg <= '1';
				O_rd       <= R_rd;
				O_StoreMem <= '0';
				O_MemRead  <= '0';
				O_memAddr  <= (others => '0');
				O_strWidth <= "00";
				W_setPC    <= '0';
				W_pausePC  <= '0';
				W_newPC    <= (others => '0');
				O_clearFD  <= '0';
				O_pauseFD  <= '0';
				if(unsigned(R_rs1) < unsigned(R_immediate)) then
					O_data(0) <= '1';
				else
					O_data(0) <= '0';
				end if;
				O_data(63 downto 1) <= (others => '0');

			when INSTRUCTION_XORI =>
				O_StoreReg <= '1';
				O_rd       <= R_rd;
				O_StoreMem <= '0';
				O_MemRead  <= '0';
				O_memAddr  <= (others => '0');
				O_strWidth <= "00";
				W_setPC    <= '0';
				W_pausePC  <= '0';
				W_newPC    <= (others => '0');
				O_clearFD  <= '0';
				O_pauseFD  <= '0';
				O_data     <= std_logic_vector(R_rs1 xor R_immediate);

			when INSTRUCTION_ORI =>
				O_StoreReg <= '1';
				O_rd       <= R_rd;
				O_StoreMem <= '0';
				O_MemRead  <= '0';
				O_memAddr  <= (others => '0');
				O_strWidth <= "00";
				W_setPC    <= '0';
				W_pausePC  <= '0';
				W_newPC    <= (others => '0');
				O_clearFD  <= '0';
				O_pauseFD  <= '0';
				O_data     <= std_logic_vector(R_rs1 or R_immediate);

			when INSTRUCTION_ANDI =>
				O_StoreReg <= '1';
				O_rd       <= R_rd;
				O_StoreMem <= '0';
				O_MemRead  <= '0';
				O_memAddr  <= (others => '0');
				O_strWidth <= "00";
				W_setPC    <= '0';
				W_pausePC  <= '0';
				W_newPC    <= (others => '0');
				O_clearFD  <= '0';
				O_pauseFD  <= '0';
				O_data     <= std_logic_vector(R_rs1 and R_immediate);

			when INSTRUCTION_SLLI =>
				O_StoreReg <= '1';
				O_rd       <= R_rd;
				O_StoreMem <= '0';
				O_MemRead  <= '0';
				O_memAddr  <= (others => '0');
				O_strWidth <= "00";
				W_setPC    <= '0';
				W_pausePC  <= '0';
				W_newPC    <= (others => '0');
				O_clearFD  <= '0';
				O_pauseFD  <= '0';
				W_shiftValue<= R_rs1;
				W_shift    <= R_immediate(4 downto 0);
				O_data     <= W_shiftLeftLogic;

			when INSTRUCTION_SRLI =>
				O_StoreReg <= '1';
				O_rd       <= R_rd;
				O_StoreMem <= '0';
				O_MemRead  <= '0';
				O_memAddr  <= (others => '0');
				O_strWidth <= "00";
				W_setPC    <= '0';
				W_pausePC  <= '0';
				W_newPC    <= (others => '0');
				O_clearFD  <= '0';
				O_pauseFD  <= '0';
				W_shiftValue<= R_rs1;
				W_shift    <= R_immediate(4 downto 0);
				O_data     <= W_shiftRightLogic;

			when INSTRUCTION_SRAI =>
				O_StoreReg <= '1';
				O_rd       <= R_rd;
				O_StoreMem <= '0';
				O_MemRead  <= '0';
				O_memAddr  <= (others => '0');
				O_strWidth <= "00";
				W_setPC    <= '0';
				W_pausePC  <= '0';
				W_newPC    <= (others => '0');
				O_clearFD  <= '0';
				O_pauseFD  <= '0';
				W_shiftValue<= R_rs1;
				W_shift    <= R_immediate(4 downto 0);
				O_data     <= W_shiftRightArith;

			when INSTRUCTION_ADD =>
				O_StoreReg <= '1';
				O_rd       <= R_rd;
				O_StoreMem <= '0';
				O_MemRead  <= '0';
				O_memAddr  <= (others => '0');
				O_strWidth <= "00";
				W_setPC    <= '0';
				W_pausePC  <= '0';
				W_newPC    <= (others => '0');
				O_clearFD  <= '0';
				O_pauseFD  <= '0';
				O_data     <= std_logic_vector(signed(R_rs1) + signed(R_rs2));

			when INSTRUCTION_SUB =>
				O_StoreReg <= '1';
				O_rd       <= R_rd;
				O_StoreMem <= '0';
				O_MemRead  <= '0';
				O_memAddr  <= (others => '0');
				O_strWidth <= "00";
				W_setPC    <= '0';
				W_pausePC  <= '0';
				W_newPC    <= (others => '0');
				O_clearFD  <= '0';
				O_pauseFD  <= '0';
				O_data     <= std_logic_vector(signed(R_rs1) - signed(R_rs2));

			when INSTRUCTION_SLL =>
				O_StoreReg <= '1';
				O_rd       <= R_rd;
				O_StoreMem <= '0';
				O_MemRead  <= '0';
				O_memAddr  <= (others => '0');
				O_strWidth <= "00";
				W_setPC    <= '0';
				W_pausePC  <= '0';
				W_newPC    <= (others => '0');
				O_clearFD  <= '0';
				O_pauseFD  <= '0';
				W_shiftValue<= R_rs1;
				W_shift(4 downto 0)<= R_rs2(4 downto 0);
				O_data     <= W_shiftLeftLogic;

			when INSTRUCTION_SLT =>
				O_StoreReg <= '1';
				O_rd       <= R_rd;
				O_StoreMem <= '0';
				O_MemRead  <= '0';
				O_memAddr  <= (others => '0');
				O_strWidth <= "00";
				W_setPC    <= '0';
				W_pausePC  <= '0';
				W_newPC    <= (others => '0');
				O_clearFD  <= '0';
				O_pauseFD  <= '0';
				if(signed(R_rs1) < signed(R_rs2)) then
					O_data(0) <= '1';
				else
					O_data(0) <= '0';
				end if;
				O_data(63 downto 1) <= (others => '0');

			when INSTRUCTION_SLTU =>
				O_StoreReg <= '1';
				O_rd       <= R_rd;
				O_StoreMem <= '0';
				O_MemRead  <= '0';
				O_memAddr  <= (others => '0');
				O_strWidth <= "00";
				W_setPC    <= '0';
				W_pausePC  <= '0';
				W_newPC    <= (others => '0');
				O_clearFD  <= '0';
				O_pauseFD  <= '0';
				if(unsigned(R_rs1) < unsigned(R_rs2)) then
					O_data(0) <= '1';
				else
					O_data(0) <= '0';
				end if;
				O_data(63 downto 1) <= (others => '0');

			when INSTRUCTION_XOR =>
				O_StoreReg <= '1';
				O_rd       <= R_rd;
				O_StoreMem <= '0';
				O_MemRead  <= '0';
				O_memAddr  <= (others => '0');
				O_strWidth <= "00";
				W_setPC    <= '0';
				W_pausePC  <= '0';
				W_newPC    <= (others => '0');
				O_clearFD  <= '0';
				O_pauseFD  <= '0';
				O_data     <= std_logic_vector(R_rs1 xor R_rs2);

			when INSTRUCTION_SRL =>
				O_StoreReg <= '1';
				O_rd       <= R_rd;
				O_StoreMem <= '0';
				O_MemRead  <= '0';
				O_memAddr  <= (others => '0');
				O_strWidth <= "00";
				W_setPC    <= '0';
				W_pausePC  <= '0';
				W_newPC    <= (others => '0');
				O_clearFD  <= '0';
				O_pauseFD  <= '0';
				W_shiftValue<= R_rs1;
				W_shift(4 downto 0)<= R_rs2(4 downto 0);
				O_data     <= W_shiftRightLogic;

			when INSTRUCTION_SRA =>
				O_StoreReg <= '1';
				O_rd       <= R_rd;
				O_StoreMem <= '0';
				O_MemRead  <= '0';
				O_memAddr  <= (others => '0');
				O_strWidth <= "00";
				W_setPC    <= '0';
				W_pausePC  <= '0';
				W_newPC    <= (others => '0');
				O_clearFD  <= '0';
				O_pauseFD  <= '0';
				W_shiftValue<= R_rs1;
				W_shift(4 downto 0)<= R_rs2(4 downto 0);
				O_data     <= W_shiftRightArith;

			when INSTRUCTION_OR =>
				O_StoreReg <= '1';
				O_rd       <= R_rd;
				O_StoreMem <= '0';
				O_MemRead  <= '0';
				O_memAddr  <= (others => '0');
				O_strWidth <= "00";
				W_setPC    <= '0';
				W_pausePC  <= '0';
				W_newPC    <= (others => '0');
				O_clearFD  <= '0';
				O_pauseFD  <= '0';
				O_data     <= std_logic_vector(R_rs1 or R_rs2);

			when INSTRUCTION_AND =>
				O_StoreReg <= '1';
				O_rd       <= R_rd;
				O_StoreMem <= '0';
				O_MemRead  <= '0';
				O_memAddr  <= (others => '0');
				O_strWidth <= "00";
				W_setPC    <= '0';
				W_pausePC  <= '0';
				W_newPC    <= (others => '0');
				O_clearFD  <= '0';
				O_pauseFD  <= '0';
				O_data     <= std_logic_vector(R_rs1 and R_rs2);

			when INSTRUCTION_FENCE =>

			when INSTRUCTION_FENCE_I =>

			when INSTRUCTION_ECALL =>

			when INSTRUCTION_EBREAK =>

			when INSTRUCTION_CSRRW =>

			when INSTRUCTION_CSRRS =>

			when INSTRUCTION_CSRRC =>

			when INSTRUCTION_CSRRWI =>

			when INSTRUCTION_CSRRSI =>

			when INSTRUCTION_CSRRCI =>

			when INSTRUCTION_LWU =>
				if(NOT I_memRdy)then
					O_StoreReg <= '0';
					O_rd       <= (others => '0');
					O_StoreMem <= '0';
					O_MemRead  <= '1';
					O_memAddr  <= std_logic_vector(signed(R_rs1) + signed(R_immediate));
					O_strWidth <= "00";
					W_setPC    <= '0';
					W_pausePC  <= '1';
					W_newPC    <= (others => '0');
					O_clearFD  <= '0';
					O_pauseFD  <= '1';
					O_data     <= (others => '0');
				else
					O_StoreReg <= '1';
					O_rd       <= R_rd;
					O_StoreMem <= '0';
					O_MemRead  <= '0';
					O_memAddr  <= (others => '0');
					O_strWidth <= "00";
					W_setPC    <= '0';
					W_pausePC  <= '0';
					W_newPC    <= (others => '0');
					O_clearFD  <= '0';
					O_pauseFD  <= '0';
					O_data(31  downto 0) <= I_memData(31 downto 0);
					O_data(63 downto 32) <= (others => '0');
				end if;

			when INSTRUCTION_LD =>
				if(NOT I_memRdy)then
					O_StoreReg <= '0';
					O_rd       <= (others => '0');
					O_StoreMem <= '0';
					O_MemRead  <= '1';
					O_memAddr  <= std_logic_vector(signed(R_rs1) + signed(R_immediate));
					O_strWidth <= "00";
					W_setPC    <= '0';
					W_pausePC  <= '1';
					W_newPC    <= (others => '0');
					O_clearFD  <= '0';
					O_pauseFD  <= '1';
					O_data     <= (others => '0');
				else
					O_StoreReg <= '1';
					O_rd       <= R_rd;
					O_StoreMem <= '0';
					O_MemRead  <= '0';
					O_memAddr  <= (others => '0');
					O_strWidth <= "00";
					W_setPC    <= '0';
					W_pausePC  <= '0';
					W_newPC    <= (others => '0');
					O_clearFD  <= '0';
					O_pauseFD  <= '0';
					O_data     <= I_memData;
				end if;

			when INSTRUCTION_SD =>
				O_StoreReg <= '0';
				O_rd       <= (others => '0');
				O_StoreMem <= '1';
				O_MemRead  <= '0';
				O_memAddr  <= std_logic_vector(signed(R_rs1) + signed(R_immediate));
				O_strWidth <= "11";
				W_setPC    <= '0';
				W_pausePC  <= '0';
				W_newPC    <= (others => '0');
				O_clearFD  <= '0';
				O_pauseFD  <= '0';
				O_data     <= I_rs2;

			when INSTRUCTION_ADDIW =>
				O_StoreReg <= '1';
				O_rd       <= R_rd;
				O_StoreMem <= '0';
				O_MemRead  <= '0';
				O_memAddr  <= (others => '0');
				O_strWidth <= "00";
				W_setPC    <= '0';
				W_pausePC  <= '0';
				W_newPC    <= (others => '0');
				O_clearFD  <= '0';
				O_pauseFD  <= '0';
				O_data     <= std_logic_vector(signed(R_rs1) + signed(R_immediate));
				O_data(63 downto 32) <= (others => O_data(31));

			when INSTRUCTION_SLLIW =>
				O_StoreReg <= '1';
				O_rd       <= R_rd;
				O_StoreMem <= '0';
				O_MemRead  <= '0';
				O_memAddr  <= (others => '0');
				O_strWidth <= "00";
				W_setPC    <= '0';
				W_pausePC  <= '0';
				W_newPC    <= (others => '0');
				O_clearFD  <= '0';
				O_pauseFD  <= '0';
				W_shiftValue<= R_rs1;
				W_shift     <= R_immediate(4 downto 0);
				O_data      <= W_shiftLeftLogic;
				O_data(63 downto 32) <= (others => W_shiftLeftLogic(31));

			when INSTRUCTION_SRLIW =>
				O_StoreReg <= '1';
				O_rd       <= R_rd;
				O_StoreMem <= '0';
				O_MemRead  <= '0';
				O_memAddr  <= (others => '0');
				O_strWidth <= "00";
				W_setPC    <= '0';
				W_pausePC  <= '0';
				W_newPC    <= (others => '0');
				O_clearFD  <= '0';
				O_pauseFD  <= '0';
				W_shiftValue<= R_rs1;
				W_shift     <= R_immediate(4 downto 0);
				O_data      <= W_shiftRightLogic;
				O_data(63 downto 32) <= (others => W_shiftRightLogic(31));

			when INSTRUCTION_SRAIW =>
				O_StoreReg <= '1';
				O_rd       <= R_rd;
				O_StoreMem <= '0';
				O_MemRead  <= '0';
				O_memAddr  <= (others => '0');
				O_strWidth <= "00";
				W_setPC    <= '0';
				W_pausePC  <= '0';
				W_newPC    <= (others => '0');
				O_clearFD  <= '0';
				O_pauseFD  <= '0';
				W_shiftValue<= R_rs1;
				W_shift     <= R_immediate(4 downto 0);
				O_data      <= W_shiftRightArith;
				O_data(63 downto 32) <= (others => W_shiftRightArith(31));

			when INSTRUCTION_ADDW =>
				O_StoreReg <= '1';
				O_rd       <= R_rd;
				O_StoreMem <= '0';
				O_MemRead  <= '0';
				O_memAddr  <= (others => '0');
				O_strWidth <= "00";
				W_setPC    <= '0';
				W_pausePC  <= '0';
				W_newPC    <= (others => '0');
				O_clearFD  <= '0';
				O_pauseFD  <= '0';
				O_data     <= std_logic_vector(signed(R_rs1) + signed(R_rs2));
				O_data(63 downto 32)<= (others => O_data(31));

			when INSTRUCTION_SUBW =>
				O_StoreReg <= '1';
				O_rd       <= R_rd;
				O_StoreMem <= '0';
				O_MemRead  <= '0';
				O_memAddr  <= (others => '0');
				O_strWidth <= "00";
				W_setPC    <= '0';
				W_pausePC  <= '0';
				W_newPC    <= (others => '0');
				O_clearFD  <= '0';
				O_pauseFD  <= '0';
				O_data     <= std_logic_vector(signed(R_rs1) - signed(R_rs2));
				O_data(63 downto 32)<= (others => O_data(31));

			when INSTRUCTION_SLLW =>
				O_StoreReg <= '1';
				O_rd       <= R_rd;
				O_StoreMem <= '0';
				O_MemRead  <= '0';
				O_memAddr  <= (others => '0');
				O_strWidth <= "00";
				W_setPC    <= '0';
				W_pausePC  <= '0';
				W_newPC    <= (others => '0');
				O_clearFD  <= '0';
				O_pauseFD  <= '0';
				W_shiftValue<= R_rs1;
				W_shift(4 downto 0)<= R_rs2(4 downto 0);
				O_data      <= W_shiftLeftLogic;
				O_data(63 downto 32) <= (others => W_shiftLeftLogic(31));

			when INSTRUCTION_SRLW =>
				O_StoreReg <= '1';
				O_rd       <= R_rd;
				O_StoreMem <= '0';
				O_MemRead  <= '0';
				O_memAddr  <= (others => '0');
				O_strWidth <= "00";
				W_setPC    <= '0';
				W_pausePC  <= '0';
				W_newPC    <= (others => '0');
				O_clearFD  <= '0';
				O_pauseFD  <= '0';
				W_shiftValue<= R_rs1;
				W_shift(4 downto 0)<= R_rs2(4 downto 0);
				O_data      <= W_shiftRightLogic;
				O_data(63 downto 32) <= (others => W_shiftRightLogic(31));

			when INSTRUCTION_SRAW =>
				O_StoreReg <= '1';
				O_rd       <= R_rd;
				O_StoreMem <= '0';
				O_MemRead  <= '0';
				O_memAddr  <= (others => '0');
				O_strWidth <= "00";
				W_setPC    <= '0';
				W_pausePC  <= '0';
				W_newPC    <= (others => '0');
				O_clearFD  <= '0';
				O_pauseFD  <= '0';
				W_shiftValue<= R_rs1;
				W_shift(4 downto 0)<= R_rs2(4 downto 0);
				O_data      <= W_shiftRightArith;
				O_data(63 downto 32) <= (others => W_shiftRightArith(31));
*/
			when others =>

		end case;
	end if;

end process;
end Behavioral;
