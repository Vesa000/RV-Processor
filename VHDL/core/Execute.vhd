library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library work;
use work.cpu_constants.all;


entity Execute is Port (
	I_clk : in STD_LOGIC;
	I_reset : in STD_LOGIC;

	I_instData : in STD_LOGIC_VECTOR (31 downto 0);
	I_instAddr : in STD_LOGIC_VECTOR (63 downto 0);

	I_instruction : in integer;
	I_rs1 : in STD_LOGIC_VECTOR (63 downto 0);
	I_rs2 : in STD_LOGIC_VECTOR (63 downto 0);
	I_rd : in STD_LOGIC_VECTOR (4 downto 0);
	I_immediate : in STD_LOGIC_VECTOR (63 downto 0);

	O_StoreReg : out STD_LOGIC;
	O_StoreMem : out STD_LOGIC;
	O_MemRead : out STD_LOGIC;
	O_instAddr : out STD_LOGIC_VECTOR (63 downto 0);
	O_regAddress : out STD_LOGIC_VECTOR (4 downto 0);
	O_memAddress : out STD_LOGIC_VECTOR (63 downto 0);
	O_data : out STD_LOGIC_VECTOR (63 downto 0);
	O_rd : out STD_LOGIC_VECTOR(4 downto 0);
	O_PC : out STD_LOGIC_VECTOR (63 downto 0);
	O_clearFD : out STD_LOGIC
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

component ProgramCounter Port (
		I_clk : in STD_LOGIC;
		I_reset : in STD_LOGIC;
		I_setPC : in STD_LOGIC;
		I_newPC : in std_logic_vector(63 downto 0);
		I_pausePC:in  STD_LOGIC;
		O_pc : out STD_LOGIC_VECTOR (63 downto 0)
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

regProcess :process(all)
begin
	if(rising_edge(I_clk)) then
		if(I_reset='1') then

		else
			R_oldData<= O_data;
			R_oldAddress<= O_regAddress;

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

	case R_instruction is

		when INSTRUCTION_NOP =>
			O_StoreReg <= '0';
			O_rd       <= (others => '0');
			O_StoreMem <= '0';
			O_MemRead  <= '0';
			W_setPC    <= '0';
			W_pausePC  <= '0';
			W_newPC    <= (others => '0');
			O_clearFD  <= '0';
			O_data     <= (others => '0');

		when INSTRUCTION_LUI =>
			O_StoreReg <= '1';
			O_rd       <= R_rd;
			O_StoreMem <= '0';
			O_MemRead  <= '0';
			W_setPC    <= '0';
			W_pausePC  <= '0';
			W_newPC    <= (others => '0');
			O_clearFD  <= '0';
			O_data     <= R_immediate;

		when INSTRUCTION_AUIPC =>
			O_StoreReg <= '1';
			O_rd       <= R_rd;
			O_StoreMem <= '0';
			O_MemRead  <= '0';
			W_setPC    <= '0';
			W_pausePC  <= '0';
			W_newPC    <= (others => '0');
			O_clearFD  <= '0';
			O_data     <= std_logic_vector(unsigned(R_immediate) + unsigned(R_instAddr));

		when INSTRUCTION_JAL =>
			O_StoreReg <= '1';
			O_rd       <= R_rd;
			O_StoreMem <= '0';
			O_MemRead  <= '0';
			W_setPC    <= '1';
			W_pausePC  <= '0';
			W_newPC    <= std_logic_vector(unsigned(R_instAddr) + unsigned(R_immediate));
			O_clearFD  <= '1';
			O_data     <= std_logic_vector(unsigned(R_instAddr) + 4);

		when INSTRUCTION_JALR =>
			O_StoreReg <= '1';
			O_rd       <= R_rd;
			O_StoreMem <= '0';
			O_MemRead  <= '0';
			W_setPC    <= '1';
			W_pausePC  <= '0';
			W_newPC    <= std_logic_vector(unsigned(R_rs1) + unsigned(R_immediate));
			W_newPC(0) <= '0';
			O_clearFD  <= '1';
			O_data     <= std_logic_vector(unsigned(R_instAddr) + 4);

		when INSTRUCTION_BEQ =>
			if(R_rs1 = R_rs2) then
				O_StoreReg <= '0';
				O_rd       <= (others => '0');
				O_StoreMem <= '0';
				O_MemRead  <= '0';
				W_setPC    <= '1';
				W_pausePC  <= '0';
				W_newPC    <= std_logic_vector(unsigned(R_instAddr) + unsigned(R_immediate));
				O_clearFD  <= '1';
				O_data     <= (others => '0');
			else
				O_StoreReg <= '0';
				O_rd       <= (others => '0');
				O_StoreMem <= '0';
				O_MemRead  <= '0';
				W_setPC    <= '0';
				W_pausePC  <= '0';
				W_newPC    <= (others => '0');
				O_clearFD  <= '0';
				O_data     <= (others => '0');
			end if;

		when INSTRUCTION_BNE =>
			if(R_rs1 /= R_rs2) then
				O_StoreReg <= '0';
				O_rd       <= (others => '0');
				O_StoreMem <= '0';
				O_MemRead  <= '0';
				W_setPC    <= '1';
				W_pausePC  <= '0';
				W_newPC    <= std_logic_vector(unsigned(R_instAddr) + unsigned(R_immediate));
				O_clearFD  <= '1';
				O_data     <= (others => '0');
			else
				O_StoreReg <= '0';
				O_rd       <= (others => '0');
				O_StoreMem <= '0';
				O_MemRead  <= '0';
				W_setPC    <= '0';
				W_pausePC  <= '0';
				W_newPC    <= (others => '0');
				O_clearFD  <= '0';
				O_data     <= (others => '0');
			end if;

		when INSTRUCTION_BLT =>
			if(signed(R_rs1) < signed(R_rs2)) then
				O_StoreReg <= '0';
				O_rd       <= (others => '0');
				O_StoreMem <= '0';
				O_MemRead  <= '0';
				W_setPC    <= '1';
				W_pausePC  <= '0';
				W_newPC    <= std_logic_vector(unsigned(R_instAddr) + unsigned(R_immediate));
				O_clearFD  <= '1';
				O_data     <= (others => '0');
			else
				O_StoreReg <= '0';
				O_rd       <= (others => '0');
				O_StoreMem <= '0';
				O_MemRead  <= '0';
				W_setPC    <= '0';
				W_pausePC  <= '0';
				W_newPC    <= (others => '0');
				O_clearFD  <= '0';
				O_data     <= (others => '0');
			end if;

		when INSTRUCTION_BGE =>
			if(NOT(signed(R_rs1) < signed(R_rs2))) then
				O_StoreReg <= '0';
				O_rd       <= (others => '0');
				O_StoreMem <= '0';
				O_MemRead  <= '0';
				W_setPC    <= '1';
				W_pausePC  <= '0';
				W_newPC    <= std_logic_vector(unsigned(R_instAddr) + unsigned(R_immediate));
				O_clearFD  <= '1';
				O_data     <= (others => '0');
			else
				O_StoreReg <= '0';
				O_rd       <= (others => '0');
				O_StoreMem <= '0';
				O_MemRead  <= '0';
				W_setPC    <= '0';
				W_pausePC  <= '0';
				W_newPC    <= (others => '0');
				O_clearFD  <= '0';
				O_data     <= (others => '0');
			end if;

		when INSTRUCTION_BLTU =>
			if(unsigned(R_rs1) < unsigned(R_rs2)) then
				O_StoreReg <= '0';
				O_rd       <= (others => '0');
				O_StoreMem <= '0';
				O_MemRead  <= '0';
				W_setPC    <= '1';
				W_pausePC  <= '0';
				W_newPC    <= std_logic_vector(unsigned(R_instAddr) + unsigned(R_immediate));
				O_clearFD  <= '1';
				O_data     <= (others => '0');
			else
				O_StoreReg <= '0';
				O_rd       <= (others => '0');
				O_StoreMem <= '0';
				O_MemRead  <= '0';
				W_setPC    <= '0';
				W_pausePC  <= '0';
				W_newPC    <= (others => '0');
				O_clearFD  <= '0';
				O_data     <= (others => '0');
			end if;

		when INSTRUCTION_BGEU =>
			if(NOT(unsigned(R_rs1) < unsigned(R_rs2))) then
				O_StoreReg <= '0';
				O_rd       <= (others => '0');
				O_StoreMem <= '0';
				O_MemRead  <= '0';
				W_setPC    <= '1';
				W_pausePC  <= '0';
				W_newPC    <= std_logic_vector(unsigned(R_instAddr) + unsigned(R_immediate));
				O_clearFD  <= '1';
				O_data     <= (others => '0');
			else
				O_StoreReg <= '0';
				O_rd       <= (others => '0');
				O_StoreMem <= '0';
				O_MemRead  <= '0';
				W_setPC    <= '0';
				W_pausePC  <= '0';
				W_newPC    <= (others => '0');
				O_clearFD  <= '0';
				O_data     <= (others => '0');
			end if;

		when INSTRUCTION_LB =>

		when INSTRUCTION_LH =>

		when INSTRUCTION_LW =>

		when INSTRUCTION_LBU =>

		when INSTRUCTION_LHU =>

		when INSTRUCTION_SB =>

		when INSTRUCTION_SH =>

		when INSTRUCTION_SW =>

		when INSTRUCTION_ADDI =>

		when INSTRUCTION_SLTI =>

		when INSTRUCTION_SLTIU =>

		when INSTRUCTION_XORI =>

		when INSTRUCTION_ORI =>

		when INSTRUCTION_ANDI =>

		when INSTRUCTION_SLLI =>

		when INSTRUCTION_SRLI =>

		when INSTRUCTION_SRAI =>

		when INSTRUCTION_ADD =>

		when INSTRUCTION_SUB =>

		when INSTRUCTION_SLL =>

		when INSTRUCTION_SLT =>

		when INSTRUCTION_SLTU =>

		when INSTRUCTION_XOR =>

		when INSTRUCTION_SRL =>

		when INSTRUCTION_SRA =>

		when INSTRUCTION_OR =>

		when INSTRUCTION_AND =>

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

		when INSTRUCTION_LD =>

		when INSTRUCTION_SD =>

		when INSTRUCTION_ADDIW =>

		when INSTRUCTION_SLLIW =>

		when INSTRUCTION_SRLIW =>

		when INSTRUCTION_SRAIW =>

		when INSTRUCTION_ADDW =>

		when INSTRUCTION_SUBW =>

		when INSTRUCTION_SLLW =>

		when INSTRUCTION_SRLW =>

		when INSTRUCTION_SRAW =>

		when others =>

	end case;












end process;
end Behavioral;
