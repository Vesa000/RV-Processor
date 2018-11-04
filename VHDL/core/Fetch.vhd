library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library work;
use work.cpu_constants.all;
use IEEE.NUMERIC_STD.ALL;

entity Fetch is Port (
		I_clk : in STD_LOGIC;
		I_reset : in std_logic;
		I_pause : in STD_LOGIC;
		I_execute : in STD_LOGIC;
		I_pc : in

		I_instruction : in STD_LOGIC_VECTOR (31 downto 0);
		O_execute : out STD_LOGIC
		O_instAddr : in STD_LOGIC_VECTOR (63 downto 0)
		);
end Fetch;

architecture Behavioral of Fetch is

signal R_instruction : std_logic_vector (31 downto 0);

begin

--register process
process(all)
begin
	if(I_enable='1') then
		R_opcode <= I_instruction(27 downto 23);
		R_condition <= I_instruction(31 downto 28);
		R_operands <= I_instruction(22 downto 0);
		
		
	end if;
end process;

process(all)
begin
	if(rising_edge(I_clk)) then
	
		--if cmp instruction
		if(I_instruction(IFO_OPCODE_BEGIN downto IFO_OPCODE_END)=OPCODE_ALU and I_instruction(IFO_ALUINS_BEGIN downto IFO_ALUINS_END) = ALUCODE_CMP) then
			R_cntr<="000";
			R_cmpNotDone<='1';
		elsif(R_cntr="011") then
			R_cntr<="011";
			R_cmpNotDone<='0';
		else
			R_cntr <= std_logic_vector(to_unsigned(to_integer(unsigned( R_cntr )) + 1, 3));
		end if;
	end if;

end process;
end Behavioral;