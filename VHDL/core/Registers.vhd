library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Registers is Port ( 
	I_clk : in STD_LOGIC;
	I_reset : in STD_LOGIC;

	i_we : in STD_LOGIC;
	I_data : in  STD_LOGIC_VECTOR (31 downto 0);
	I_storeAddr : in STD_LOGIC_VECTOR (4 downto 0);

	I_readA : in STD_LOGIC_VECTOR (4 downto 0);
	I_readB : in STD_LOGIC_VECTOR (4 downto 0);
	O_dataA : out STD_LOGIC_VECTOR (31 downto 0);
	O_dataB : out STD_LOGIC_VECTOR (31 downto 0)
	);
end Registers;

architecture Behavioral of Registers is
	type store_t is array (0 to 31) of STD_LOGIC_VECTOR(63 downto 0);
	signal regs: store_t := (others => X"0000000000000000");
begin
	
process(all)
begin
	if rising_edge(I_clk) then               
		if(I_we = '1') then
		regs(to_integer(unsigned(I_storeAddr))) <= I_data;
		end if;
	end if;
end process;

process(all)
begin
	--Write reg to O_dataA
	if(i_readA = "00000") then
		O_dataA <= X"0000000000000000"; --reg 0 is 0
	elsif(I_readA = I_storeAddr) then
		O_dataA <= I_data;
	else
		O_dataA <= regs(to_integer(unsigned(I_readA)));
	end if;
	
	--Write reg to O_dataB
	if(i_readB="00000") then
		O_dataB <= X"0000000000000000"; --reg 0 is 0
	elsif(I_readB = I_storeAddr) then
		O_dataB <= I_data;
	else
		O_dataB <= regs(to_integer(unsigned(I_readB)));
	end if;
end process;
end Behavioral;
