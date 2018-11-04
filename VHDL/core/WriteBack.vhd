library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library work;
use work.cpu_constants.all;

entity WriteBack is Port ( 
		I_clk : in STD_LOGIC;
		I_reset : in STD_LOGIC;
		I_instruction : in integer;
		I_execute : in STD_LOGIC;

		I_regWrite : in STD_LOGIC;
		I_address : in STD_LOGIC_VECTOR (4 downto 0);
		I_data : in STD_LOGIC_VECTOR (63 downto 0);

		O_store : out STD_LOGIC;
		O_address : out STD_LOGIC_VECTOR (4 downto 0);
		O_data : out STD_LOGIC_VECTOR (63 downto 0)
		);
end WriteBack;

architecture Behavioral of WriteBack is

begin
process(all)
begin
	O_store<=I_execute;
	O_address<=I_address;
	O_data <= I_data;
end process;

end Behavioral;