library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library work;
use work.cpu_constants.all;

entity ProgramCounter is Port (
		I_clk : in STD_LOGIC;
		I_reset : in STD_LOGIC;

		I_pausePC: in STD_LOGIC;
		I_setPC : in STD_LOGIC;
		I_newPC : in STD_LOGIC_VECTOR (63 downto 0);

		O_pc : out STD_LOGIC_VECTOR (63 downto 0)
		);
		
end ProgramCounter;

architecture Behavioral of ProgramCounter is

signal R_oldPC: STD_LOGIC_VECTOR (63 downto 0);
begin

--capture old pc on rising edge
process(I_clk)
begin
	if(rising_edge(I_clk)) then
		R_oldPC <= O_pc;
	end if;
end process;

process(all)
begin
	if(I_reset) then
		O_pc <= STD_LOGIC_VECTOR(to_signed(MEM_PROG_START,64));
	else
		if(I_setPC = '1') then
			O_pc <= I_newPC;
		elsif(I_pausePC = '1') then
			O_pc <= R_oldPC;
		else
			O_pc <= STD_LOGIC_VECTOR(unsigned(R_oldPC) + 4);
		end if;
	end if;

end process;
end Behavioral;
