library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity PCstack is Port (
		I_clk : in STD_LOGIC;
		I_reset : in STD_LOGIC;
		I_push : in STD_LOGIC;
		I_pop : in STD_LOGIC;
		I_data : in STD_LOGIC_VECTOR (15 downto 0);
		O_data : out STD_LOGIC_VECTOR (15 downto 0);
		O_sp : out integer);
end PCstack;

architecture Behavioral of PCstack is

type mem_type is array (0 to 255) of std_logic_vector(15 downto 0);
signal stack_mem : mem_type := (others => (others => '0'));
signal full,empty : std_logic := '0';
signal prev_PP : std_logic := '0';
signal SP : integer := 0;  --for simulation and debugging. 

begin
--PUSH and POP process for the stack.
process(I_clk,I_reset)--push

variable stack_ptr : integer := 255;

begin
     if(I_reset = '1') then
	stack_ptr := 255;  --stack grows downwards.
	full <= '0';
	empty <= '0';
	O_data <= (others => '0');
	prev_PP <= '0';
    elsif(rising_edge(I_clk)) then
    
	--POP section.
	if (I_pop = '1' and empty = '0') then
	--setting empty flag.           
		if(stack_ptr = 254) then
			full <= '0';
			empty <= '1';
		else
			full <= '0';
			empty <= '0';
		end if;
		--increase sp if not empty
		if(empty = '0') then
			stack_ptr := stack_ptr + 1;
		end if;  
	end if;
      
	  --PUSH section.
	if (I_push = '1' and full = '0') then
		--setting full flag.
		if(stack_ptr = 0) then
			full <= '1';
			empty <= '0';
		else
			full <= '0';
			empty <= '0';
		end if; 
		
		if(full = '0') then
			stack_ptr := stack_ptr - 1;
		end if;
		--Data pushed to the current address.       
		stack_mem(stack_ptr) <= I_data;
	end if;
	
	SP <= stack_ptr;  --for debugging/simulation.
	O_sp <= stack_ptr;
	O_data <= stack_mem(stack_ptr);
	
    end if;
    
end process;
end Behavioral;