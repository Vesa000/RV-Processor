library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ProgramCounter is Port (
		I_clk : in STD_LOGIC;
		I_reset : in STD_LOGIC;

		I_setPC : in STD_LOGIC;
		I_newPC : in
		I_pausePC

		O_pc : out STD_LOGIC_VECTOR (63 downto 0)
		);
		
end ProgramCounter;

architecture Behavioral of ProgramCounter is

signal R_oldPC: STD_LOGIC_VECTOR (63 downto 0);
signal W_curPC: STD_LOGIC_VECTOR (63 downto 0);
begin

--capture old pc on rising edge
process(I_clk)
begin
	if(rising_edge(I_clk)) then
	R_oldPC <= W_curPC;
	end if;
end process;

process(all)
begin
	if(I_setPC = "1") then
		W_curPC <= I_newPC;
	elsif(I_pausePC = "1") then
		W_curPC <= R_oldPC;
	else
		W_curPC <= R_oldPC + 4;
	end if;

	O_pc <= W_curPC;

end process;
end Behavioral;
