library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library work;
use work.cpu_constants.all;

entity Fetch is Port (
		I_clk : in STD_LOGIC;
		I_reset : in std_logic;

		I_pause : in STD_LOGIC;
		I_clear : in STD_LOGIC;

		I_instruction : in STD_LOGIC_VECTOR (31 downto 0);
		O_instruction : out STD_LOGIC_VECTOR (31 downto 0);
		O_execute : out STD_LOGIC;

		I_instAddr : in STD_LOGIC_VECTOR (63 downto 0);
		O_instAddr : out STD_LOGIC_VECTOR (63 downto 0)
		);
end Fetch;

architecture Behavioral of Fetch is

signal W_instruction: STD_LOGIC;
signal W_opcode:      std_logic_vector(6  downto 0);

begin

--register process
process(all)
begin
	if(rising_edge(I_clk)) then
		if(NOT I_pause) THEN
			O_instruction <= I_instruction;
			O_instAddr <= I_instAddr;
		end if;
	end if;
end process;

process(all)
begin
	O_execute <= NOT I_clear;

end process;
end Behavioral;