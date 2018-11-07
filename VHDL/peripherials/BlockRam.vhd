library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;
use std.textio.all;
library work;
use work.cpu_constants.all;

entity BlockRam is port (
	clk : in std_logic;
	enA : in std_logic;
	enB : in std_logic;
	weB : in std_logic;
	addrA : in std_logic_vector(63 downto 0);
	addrB : in std_logic_vector(63 downto 0);
	diB : in std_logic_vector(63 downto 0);
	doA : out std_logic_vector(31 downto 0);
	doB : out std_logic_vector(63 downto 0);

	I_read : in std_logic;
	I_store : in std_logic;
	I_dataWidth:in std_logic_vector(1 downto 0);
	O_rdyB: out std_logic
	);
end BlockRam;
architecture behavioral of BlockRam is

signal W_weB   : std_logic_vector(7 downto 0):= (others => '0');
signal W_addrB   : std_logic_vector(11 downto 0):= (others => '0');
signal W_dinB   : std_logic_vector(63 downto 0):= (others => '0');
signal W_doutB   : std_logic_vector(63 downto 0);

signal W_dataLength: integer;
signal R_state: integer;
signal W_addr: integer;
signal W_addrMod: integer;
signal W_addrModMul: integer;

Component blk_mem_gen_0 PORT (
    clka : IN STD_LOGIC;
    ena : IN STD_LOGIC;
    wea : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    addra : IN STD_LOGIC_VECTOR(12 DOWNTO 0);
    dina : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    clkb : IN STD_LOGIC;
    enb : IN STD_LOGIC;
    web : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    addrb : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
    dinb : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
    doutb : OUT STD_LOGIC_VECTOR(63 DOWNTO 0)
  );
END Component;

begin

Bram: blk_mem_gen_0 port map(
		clka  => clk, 
		ena   => enA,
		wea   => (others => '0'),
		addra(12 downto 0) => std_logic_vector(signed(addrA)/4),
		dina  => (others => '0'),
		douta => doA,
		clkb  => clk,
		enb   => enB,
		web   => W_weB,
		addrb => W_addrB,
		dinb  => W_dinB,
		doutb => W_doutB
		);


W_addr       <= to_integer(signed(addrb)/8);
W_addrMod    <= to_integer(signed(addrb) MOD 8);
W_addrModMul <= W_addrMod * 8;

with I_dataWidth select
     W_dataLength <= 7  when "00",
           			 15 when "01",
           			 31 when "10",
           			 63 when "11",
           			 0  when others;


process(all)
begin
	if(rising_edge(clk)) then

		--bad implementation that fails on unalligned data.
		if(I_read) then
			case(R_state) is
				when 0 => --send Address
					W_addrB <= std_logic_vector(to_signed(W_addr,12));
					O_rdyB <= '0';
					R_state <= 1;

				when 1 =>
					W_addrB <= std_logic_vector(to_signed(W_addr + 1,12));
					doB <= W_doutB;
					O_rdyB <= '1';
					R_state <= 0;

				when others =>
					O_rdyB <= '0';
					R_state <= 0;
			end case;
		end if;

		/* --Fix [Synth 8-27] complex assignment not supported later
		if(I_read) then
			case(R_state) is
				when 0 => --send Address
					W_addrB <= std_logic_vector(to_signed(W_addr,12));
					O_rdyB <= '0';
					R_state <= 1;

				when 1 => --read first word
					W_addrB <= std_logic_vector(to_signed(W_addr + 1,12));
					doB((W_dataLength-W_addrModMul) downto W_addrModMul) <= W_doutB(63 downto W_addrModMul);
					if(W_addrModMul + W_dataLength < 64) then
						O_rdyB <= '1';
						R_state <= 0;
					else
						O_rdyB <= '0';
						R_state <= 2;
					end if;

				when 2 => --read second word
					doB(63 downto (64-W_addrModMul)) <= W_doutB((W_addrModMul -1) downto 0);
					O_rdyB <= '1';
					R_state <= 0;

				when others =>
					O_rdyB <= '0';
					R_state <= 0;
			end case;
		end if;

		
		if(I_store) then
			case(R_state) is
				when 0 => --send Address
					W_addrB <= std_logic_vector(to_signed(W_addr,12));
					O_rdyB <= '0';
					R_state <= 1;

				when 1 => --Store first word
					W_addrB <= std_logic_vector(to_signed(W_addr + 1,12));
					for I in 7 downto 0 loop
						if((I >= W_addrMod) AND ((8*I) + W_addrModMul < W_dataLength)) then
							W_weB(I) <= '1';
						else
							W_weB(I) <= '0';
						end if;
					end loop;

					if(W_addrModMul + W_dataLength < 64) then
						W_dinB(W_dataLength + W_addrModMul downto W_addrModMul) <= diB(W_dataLength downto W_addrModMul);
						O_rdyB <= '1';
						R_state <= 0;
					else
						W_dinB(63 downto W_addrModMul) <= diB(W_dataLength - W_addrModMul downto 0);
						O_rdyB <= '0';
						R_state <= 2;
					end if;

				when 2 => --Store second word
					for I in 7 downto 0 loop
						if((8*I) < (W_dataLength + W_addrModMul) -64) then
							W_weB(I) <= '1';
						else
							W_weB(I) <= '0';
						end if;
					end loop;

					W_dinB(W_addrModMul-1 downto 0) <= diB(63 downto (W_dataLength + W_addrModMul) -64);
					O_rdyB <= '1';
					R_state <= 0;

				when others =>
					W_dinB <= (others => '0');
					O_rdyB <= '0';
					R_state <= 0;
			end case;
		else
			W_dinB <= (others => '0');
		end if;
		*/

	end if;
end process;
end behavioral;




