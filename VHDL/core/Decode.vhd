library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
library work;
use work.cpu_constants.all;

entity Decode is Port ( 
		I_clk : in STD_LOGIC;
		I_reset : in STD_LOGIC;

		I_instAddr : in STD_LOGIC_VECTOR (63 downto 0);
		O_instData : out STD_LOGIC_VECTOR (31 downto 0);
		O_instAddr : out STD_LOGIC_VECTOR (63 downto 0);

		I_instruction : in STD_LOGIC_VECTOR (31 downto 0);
		O_instruction : out integer;
		O_immediate : out STD_LOGIC_VECTOR (63 downto 0);
		
		O_rd : out STD_LOGIC_VECTOR (4 downto 0);
		O_read1 : out STD_LOGIC_VECTOR (4 downto 0);
		O_read2 : out STD_LOGIC_VECTOR (4 downto 0);

		I_pause : in STD_LOGIC;
		I_clear : in STD_LOGIC;
		I_execute : in STD_LOGIC;
		O_execute : out STD_LOGIC
		);
end Decode;

architecture Behavioral of Decode is

signal R_instruction: STD_LOGIC_VECTOR (31 downto 0);
signal W_instruction: integer;

signal R_execute: STD_LOGIC;

signal W_opcode:      std_logic_vector(6  downto 0);
signal W_rs2:         std_logic_vector(4  downto 0);
signal W_rs1:         std_logic_vector(4  downto 0);
signal W_funct3:      std_logic_vector(2  downto 0);
signal W_funct7:      std_logic_vector(6  downto 0);
signal W_funct6:      std_logic_vector(5  downto 0);
signal W_rd:          std_logic_vector(4  downto 0);
signal W_shamt:       std_logic_vector(63 downto 0);
signal W_shamtw:      std_logic_vector(63 downto 0);

signal W_I_immediate: std_logic_vector(63 downto 0);
signal W_S_immediate: std_logic_vector(63 downto 0);
signal W_B_immediate: std_logic_vector(63 downto 0);
signal W_U_immediate: std_logic_vector(63 downto 0);
signal W_J_immediate: std_logic_vector(63 downto 0);

signal W_imm_11_0:    std_logic_vector(63 downto 0);
signal W_imm_31_12:   std_logic_vector(63 downto 0);

begin
process(all)
begin
	if(rising_edge(I_clk)) then
		if(NOT I_pause) then
			R_instruction <= I_instruction;
			R_execute     <= I_execute;
			O_instAddr    <= I_instAddr;
		end if;
	end if;
end process;

process(all)
begin
	if(I_clear OR I_reset) then
		O_execute <= '0';
	else
		O_execute <= R_execute;
	end if;
	O_instData <= R_instruction;

	W_opcode <= R_instruction(BP_OPCODE_END downto BP_OPCODE_BEGIN);
	W_rs2    <= R_instruction(BP_RS2_END downto BP_RS2_BEGIN);
	W_rs1    <= R_instruction(BP_RS1_END downto BP_RS1_BEGIN);
	W_funct7 <= R_instruction(BP_FUNCT7_END downto BP_FUNCT7_BEGIN);
	W_funct6 <= R_instruction(BP_FUNCT6_END downto BP_FUNCT6_BEGIN);
	W_funct3 <= R_instruction(BP_FUNCT3_END downto BP_FUNCT3_BEGIN);
	W_rd     <= R_instruction(BP_RD_END downto BP_RD_BEGIN);

	W_shamt (4  downto 0) <= R_instruction(BP_SHAMT_END downto BP_SHAMT_BEGIN);
	W_shamt (63 downto 5) <= (others => W_shamt(4));
	W_shamtW(3  downto 0) <= R_instruction(BP_SHAMTW_END downto BP_SHAMTW_BEGIN);
	W_shamtW(63 downto 4) <= (others => W_shamtW(3));

	W_I_immediate(0)            <= R_instruction(20);
	W_I_immediate(4 downto 1)   <= R_instruction(24 downto 21);
	W_I_immediate(10 downto 5)  <= R_instruction(30 downto 25);
	W_I_immediate(63 downto 11) <= (others => R_instruction(31));

	W_S_immediate(0)            <= R_instruction(7);
	W_S_immediate(4 downto 1)   <= R_instruction(11 downto 8);
	W_S_immediate(10 downto 5)  <= R_instruction(30 downto 25);
	W_S_immediate(63 downto 11) <= (others => R_instruction(31));

	W_B_immediate(0)            <= '0';
	W_B_immediate(4 downto 1)   <= R_instruction(11 downto 8);
	W_B_immediate(10 downto 5)  <= R_instruction(30 downto 25);
	W_B_immediate(11)           <= R_instruction(7);
	W_B_immediate(63 downto 12) <= (others => R_instruction(31));

	W_U_immediate(11 downto 0)  <= (others =>'0');
	W_U_immediate(19 downto 12) <= R_instruction(19 downto 12);
	W_U_immediate(30 downto 20) <= R_instruction(30 downto 20);
	W_U_immediate(63 downto 31) <= (others => R_instruction(31));

	W_J_immediate(0)            <= '0';
	W_J_immediate(4 downto 1)   <= R_instruction(24 downto 21);
	W_J_immediate(10 downto 5)  <= R_instruction(30 downto 25);
	W_J_immediate(11)           <= R_instruction(20);
	W_J_immediate(19 downto 12) <= R_instruction(19 downto 12);
	W_J_immediate(63 downto 20) <= (others => R_instruction(31));

	W_imm_11_0(11 downto 0)     <= R_instruction(BP_IMM_11_0_END downto BP_IMM_11_0_BEGIN);
	W_imm_11_0(63 downto 12)    <= (others => R_instruction(BP_IMM_11_0_END));

	W_imm_31_12(11 downto 0)    <= (others =>'0');
	W_imm_31_12(31 downto 12)   <= R_instruction(BP_IMM_31_12_END downto BP_IMM_31_12_BEGIN);
	W_imm_31_12(63 downto 32)   <= (others => R_instruction(BP_IMM_31_12_END));


	-- get instruction from opcode and funct3
	case W_opcode is

		when OPCODE_LUI => 
			W_instruction <= INSTRUCTION_LUI;

		when OPCODE_AUIPC =>
			W_instruction <= INSTRUCTION_AUIPC;

		when OPCODE_JAL =>
			W_instruction <= INSTRUCTION_JAL;

		when OPCODE_JALR =>
			W_instruction <= INSTRUCTION_JALR;

		when OPCODE_BRANCH =>
			case W_funct3 is
				when "000" =>
					W_instruction <= INSTRUCTION_BEQ;
				when "001" =>
					W_instruction <= INSTRUCTION_BNE;
				when "100" =>
					W_instruction <= INSTRUCTION_BLT;
				when "101" =>
					W_instruction <= INSTRUCTION_BGE;
				when "110" =>
					W_instruction <= INSTRUCTION_BLTU;
				when "111" =>
					W_instruction <= INSTRUCTION_BGEU;
				when others =>
					W_instruction <= INSTRUCTION_NOP;
			end case;

		when OPCODE_LOAD =>
			case W_funct3 is
				when "000" =>
					W_instruction <= INSTRUCTION_LB;
				when "001" =>
					W_instruction <= INSTRUCTION_LH;
				when "010" =>
					W_instruction <= INSTRUCTION_LW;
				when "100" =>
					W_instruction <= INSTRUCTION_LBU;
				when "101" =>
					W_instruction <= INSTRUCTION_LHU;
				when "110" =>
					W_instruction <= INSTRUCTION_LWU;
				when "011" =>
					W_instruction <= INSTRUCTION_LD;
				when others =>
					W_instruction <= INSTRUCTION_NOP;
			end case;

		when OPCODE_STORE =>
			case W_funct3 is
				when "000" =>
					W_instruction <= INSTRUCTION_SB;
				when "001" =>
					W_instruction <= INSTRUCTION_SH;
				when "010" =>
					W_instruction <= INSTRUCTION_SW;
				when "011" =>
					W_instruction <= INSTRUCTION_SD;
				when others =>
					W_instruction <= INSTRUCTION_NOP;
			end case;

		when OPCODE_ARITHMETIC_1 =>
			case W_funct3 is
				when "000" =>
					W_instruction <= INSTRUCTION_ADDI;
				when "010" =>
					W_instruction <= INSTRUCTION_SLTI;
				when "011" =>
					W_instruction <= INSTRUCTION_SLTIU;
				when "100" =>
					W_instruction <= INSTRUCTION_XORI;
				when "110" =>
					W_instruction <= INSTRUCTION_ORI;
				when "111" =>
					W_instruction <= INSTRUCTION_ANDI;
				when "001" =>
					if(W_funct6 = "000000") then
						W_instruction <= INSTRUCTION_SLLI;
					else
						W_instruction <= INSTRUCTION_NOP;
					end if;
				when "101" =>
					if(W_funct6 = "000000") then
						W_instruction <= INSTRUCTION_SRLI;
					elsif (W_funct6 = "010000") then
						W_instruction <= INSTRUCTION_SRAI;
					else
						W_instruction <= INSTRUCTION_NOP;
					end if;
				when others =>
					W_instruction <= INSTRUCTION_NOP;
			end case;

		when OPCODE_ARITHMETIC_2 =>
			case W_funct3 is
				when "000" =>
					if(W_funct7 = "0000000") then
						W_instruction <= INSTRUCTION_ADDI;
					elsif (W_funct7 = "0100000") then
						W_instruction <= INSTRUCTION_SUB;
					else
						W_instruction <= INSTRUCTION_NOP;
					end if;
				when "001" =>
					if(W_funct7 = "0000000") then
						W_instruction <= INSTRUCTION_SLL;
					else
						W_instruction <= INSTRUCTION_NOP;
					end if;	
				when "010" =>
					if(W_funct7 = "0000000") then
						W_instruction <= INSTRUCTION_SLT;
					else
						W_instruction <= INSTRUCTION_NOP;
					end if;	
				when "011" =>
					if(W_funct7 = "0000000") then
						W_instruction <= INSTRUCTION_SLTU;
					else
						W_instruction <= INSTRUCTION_NOP;
					end if;
				when "100" =>
					if(W_funct7 = "0000000") then
						W_instruction <= INSTRUCTION_XOR;
					else
						W_instruction <= INSTRUCTION_NOP;
					end if;
				when "101" =>
					if(W_funct7 = "0000000") then
						W_instruction <= INSTRUCTION_SRL;
					elsif (W_funct7 = "0100000") then
						W_instruction <= INSTRUCTION_SRA;
					else
						W_instruction <= INSTRUCTION_NOP;
					end if;
				when "110" =>
					if(W_funct7 = "0000000") then
						W_instruction <= INSTRUCTION_OR;
					else
						W_instruction <= INSTRUCTION_NOP;
					end if;
				when "111" =>
					if(W_funct7 = "0000000") then
						W_instruction <= INSTRUCTION_AND;
					else
						W_instruction <= INSTRUCTION_NOP;
					end if;
				when others =>
					W_instruction <= INSTRUCTION_NOP;
			end case;

		when OPCODE_FENCE => 
			W_instruction <= INSTRUCTION_NOP;-- Fence is not used

		when OPCODE_CONTROLL =>
			case W_funct3 is
				when "000" =>
					if(W_imm_11_0(11 downto 0) = "000000000000" AND W_rs1 = "00000" AND W_rd = "00000") then
						W_instruction <= INSTRUCTION_ECALL;
					elsif (W_imm_11_0(11 downto 0) = "000000000001" AND W_rs1 = "00000" AND W_rd = "00000") then
						W_instruction <= INSTRUCTION_EBREAK;
					else
						W_instruction <= INSTRUCTION_NOP;
					end if;
				when "001" =>
					W_instruction <= INSTRUCTION_CSRRW;
				when "010" =>
					W_instruction <= INSTRUCTION_CSRRS;
				when "011" =>
					W_instruction <= INSTRUCTION_CSRRC;
				when "101" =>
					W_instruction <= INSTRUCTION_CSRRWI;
				when "110" =>
					W_instruction <= INSTRUCTION_CSRRSI;
				when "111" =>
					W_instruction <= INSTRUCTION_CSRRCI;
				when others =>
					W_instruction <= INSTRUCTION_NOP;
			end case;

		when OPCODE_ARITHMETIC_3 =>
			case W_funct3 is
				when "000" =>
					W_instruction <= INSTRUCTION_ADDIW;
				when "001" =>
					if(W_funct7 = "0000000") then
						W_instruction <= INSTRUCTION_SLLIW;
					else
						W_instruction <= INSTRUCTION_NOP;
					end if;
				when "101" =>
					if(W_funct7 = "0000000") then
						W_instruction <= INSTRUCTION_SRLIW;
					elsif (W_funct7 = "0100000") then
						W_instruction <= INSTRUCTION_SRAIW;
					else
						W_instruction <= INSTRUCTION_NOP;
					end if;
				when others =>
					W_instruction <= INSTRUCTION_NOP;
			end case;

		when OPCODE_ARITHMETIC_4 =>
			case W_funct3 is
				when "000" =>
					if(W_funct7 = "0000000") then
						W_instruction <= INSTRUCTION_ADDW;
					elsif (W_funct7 = "0100000") then
						W_instruction <= INSTRUCTION_SUBW;
					else
						W_instruction <= INSTRUCTION_NOP;
					end if;
				when "001" =>
					if(W_funct7 = "0000000") then
						W_instruction <= INSTRUCTION_SLLW;
					else
						W_instruction <= INSTRUCTION_NOP;
					end if;
				when "101" =>
					if(W_funct7 = "0000000") then
						W_instruction <= INSTRUCTION_SRLW;
					elsif (W_funct7 = "0100000") then
						W_instruction <= INSTRUCTION_SRAW;
					else
						W_instruction <= INSTRUCTION_NOP;
					end if;
				when others =>
					W_instruction <= INSTRUCTION_NOP;
			end case;

		when others =>
			W_instruction <= INSTRUCTION_NOP;
	end case;


	--Read registers
	O_read1 <= W_rs1;
	O_read2 <= W_rs2;

	--Send values to Execute based on instruction
	case W_instruction is

		when INSTRUCTION_NOP =>
			O_instruction <= W_instruction;
			O_immediate(63 downto 0) <= (others => '0');
			O_rd <= W_rd;

		when INSTRUCTION_LUI =>
			O_instruction <= W_instruction;
			O_immediate <= W_imm_31_12;
			O_rd <= W_rd;

		when INSTRUCTION_AUIPC =>
			O_instruction <= W_instruction;
			O_immediate <= W_imm_31_12;
			O_rd <= W_rd;

		when INSTRUCTION_JAL =>
			O_instruction <= W_instruction;
			O_immediate <= W_J_immediate;
			O_rd <= W_rd;

		when INSTRUCTION_JALR =>
			O_instruction <= W_instruction;
			O_immediate   <= W_imm_11_0;
			O_rd <= W_rd;

		when INSTRUCTION_BEQ =>
			O_instruction <= W_instruction;
			O_immediate   <= W_B_immediate;
			O_rd <= W_rd;

		when INSTRUCTION_BNE =>
			O_instruction <= W_instruction;
			O_immediate   <= W_B_immediate;
			O_rd <= W_rd;

		when INSTRUCTION_BLT =>
			O_instruction <= W_instruction;
			O_immediate   <= W_B_immediate;
			O_rd <= W_rd;

		when INSTRUCTION_BGE =>
			O_instruction <= W_instruction;
			O_immediate   <= W_B_immediate;
			O_rd <= W_rd;

		when INSTRUCTION_BLTU =>
			O_instruction <= W_instruction;
			O_immediate   <= W_B_immediate;
			O_rd <= W_rd;

		when INSTRUCTION_BGEU =>
			O_instruction <= W_instruction;
			O_immediate   <= W_B_immediate;
			O_rd <= W_rd;

		when INSTRUCTION_LB =>
			O_instruction <= W_instruction;
			O_immediate   <= W_imm_11_0;
			O_rd <= W_rd;

		when INSTRUCTION_LH =>
			O_instruction <= W_instruction;
			O_immediate   <= W_imm_11_0;
			O_rd <= W_rd;

		when INSTRUCTION_LW =>
			O_instruction <= W_instruction;
			O_immediate   <= W_imm_11_0;
			O_rd <= W_rd;

		when INSTRUCTION_LBU =>
			O_instruction <= W_instruction;
			O_immediate   <= W_imm_11_0;
			O_rd <= W_rd;

		when INSTRUCTION_LHU =>
			O_instruction <= W_instruction;
			O_immediate   <= W_imm_11_0;
			O_rd <= W_rd;

		when INSTRUCTION_SB =>
			O_instruction <= W_instruction;
			O_immediate   <= W_S_immediate;
			O_rd <= W_rd;

		when INSTRUCTION_SH =>
			O_instruction <= W_instruction;
			O_immediate   <= W_S_immediate;
			O_rd <= W_rd;

		when INSTRUCTION_SW =>
			O_instruction <= W_instruction;
			O_immediate   <= W_S_immediate;
			O_rd <= W_rd;

		when INSTRUCTION_ADDI =>
			O_instruction <= W_instruction;
			O_immediate   <= W_imm_11_0;
			O_rd <= W_rd;

		when INSTRUCTION_SLTI =>
			O_instruction <= W_instruction;
			O_immediate   <= W_imm_11_0;
			O_rd <= W_rd;

		when INSTRUCTION_SLTIU =>
			O_instruction <= W_instruction;
			O_immediate   <= W_imm_11_0;
			O_rd <= W_rd;

		when INSTRUCTION_XORI =>
			O_instruction <= W_instruction;
			O_immediate   <= W_imm_11_0;
			O_rd <= W_rd;

		when INSTRUCTION_ORI =>
			O_instruction <= W_instruction;
			O_immediate   <= W_imm_11_0;
			O_rd <= W_rd;

		when INSTRUCTION_ANDI =>
			O_instruction <= W_instruction;
			O_immediate   <= W_imm_11_0;
			O_rd <= W_rd;

		when INSTRUCTION_SLLI =>
			O_instruction <= W_instruction;
			O_immediate   <= W_shamt;
			O_rd <= W_rd;

		when INSTRUCTION_SRLI =>
			O_instruction <= W_instruction;
			O_immediate   <= W_shamt;
			O_rd <= W_rd;

		when INSTRUCTION_SRAI =>
			O_instruction <= W_instruction;
			O_immediate   <= W_shamt;
			O_rd <= W_rd;

		when INSTRUCTION_ADD =>
			O_instruction <= W_instruction;
			O_immediate   <= (others => '0');
			O_rd <= W_rd;

		when INSTRUCTION_SUB =>
			O_instruction <= W_instruction;
			O_immediate   <= (others => '0');
			O_rd <= W_rd;

		when INSTRUCTION_SLL =>
			O_instruction <= W_instruction;
			O_immediate   <= (others => '0');
			O_rd <= W_rd;

		when INSTRUCTION_SLT =>
			O_instruction <= W_instruction;
			O_immediate   <= (others => '0');
			O_rd <= W_rd;

		when INSTRUCTION_SLTU =>
			O_instruction <= W_instruction;
			O_immediate   <= (others => '0');
			O_rd <= W_rd;

		when INSTRUCTION_XOR =>
			O_instruction <= W_instruction;
			O_immediate   <= (others => '0');
			O_rd <= W_rd;

		when INSTRUCTION_SRL =>
			O_instruction <= W_instruction;
			O_immediate   <= (others => '0');
			O_rd <= W_rd;

		when INSTRUCTION_SRA =>
			O_instruction <= W_instruction;
			O_immediate   <= (others => '0');
			O_rd <= W_rd;

		when INSTRUCTION_OR =>
			O_instruction <= W_instruction;
			O_immediate   <= (others => '0');
			O_rd <= W_rd;

		when INSTRUCTION_AND =>
			O_instruction <= W_instruction;
			O_immediate   <= (others => '0');
			O_rd <= W_rd;

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
			O_instruction <= W_instruction;
			O_immediate   <= W_imm_11_0;
			O_rd <= W_rd;

		when INSTRUCTION_LD =>
			O_instruction <= W_instruction;
			O_immediate   <= W_imm_11_0;
			O_rd <= W_rd;

		when INSTRUCTION_SD =>
			O_instruction <= W_instruction;
			O_immediate   <= W_S_immediate;
			O_rd <= W_rd;

		when INSTRUCTION_ADDIW =>
			O_instruction <= W_instruction;
			O_immediate   <= W_imm_11_0;
			O_rd <= W_rd;

		when INSTRUCTION_SLLIW =>
			O_instruction <= W_instruction;
			O_immediate   <= W_shamtW;
			O_rd <= W_rd;

		when INSTRUCTION_SRLIW =>
			O_instruction <= W_instruction;
			O_immediate   <= W_shamtW;
			O_rd <= W_rd;

		when INSTRUCTION_SRAIW =>
			O_instruction <= W_instruction;
			O_immediate   <= W_shamtW;
			O_rd <= W_rd;

		when INSTRUCTION_ADDW =>
			O_instruction <= W_instruction;
			O_immediate   <= (others => '0');
			O_rd <= W_rd;

		when INSTRUCTION_SUBW =>
			O_instruction <= W_instruction;
			O_immediate   <= (others => '0');
			O_rd <= W_rd;

		when INSTRUCTION_SLLW =>
			O_instruction <= W_instruction;
			O_immediate   <= (others => '0');
			O_rd <= W_rd;

		when INSTRUCTION_SRLW =>
			O_instruction <= W_instruction;
			O_immediate   <= (others => '0');
			O_rd <= W_rd;

		when INSTRUCTION_SRAW =>
			O_instruction <= W_instruction;
			O_immediate   <= (others => '0');
			O_rd <= W_rd;

		when others =>

	end case;



end process;

end Behavioral;
