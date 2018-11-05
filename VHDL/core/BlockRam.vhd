library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;
use std.textio.all;
library work;
use work.cpu_constants.all;

entity BlockRam is
generic (
	WIDTHA : integer := 32;
	WIDTHB : integer := 64;
	SIZE : integer := 4000
	--SIZEA : integer := 40000
	);

port (
	clk : in std_logic;
	enA : in std_logic;
	enB : in std_logic;
	weB : in std_logic;
	addrA : in std_logic_vector(63 downto 0);
	addrB : in std_logic_vector(63 downto 0);
	diB : in std_logic_vector(63 downto 0);
	doA : out std_logic_vector(7 downto 0);
	doB : out std_logic_vector(7 downto 0);

	I_strWidth:in std_logic_vector(1 downto 0);
	I_readB: in std_logic;
	O_rdyB: out std_logic
	);
end BlockRam;
architecture behavioral of BlockRam is

type ramType is array (0 to SIZE-1) of std_logic_vector(7 downto 0);


impure function InitRamFromFile (RamFileName : in string) return RamType is
FILE RamFile : text is in RamFileName;
variable RamFileLine : line;
variable RAM : RamType;
begin
	for I in RamType'range loop
		readline (RamFile, RamFileLine);
		read (RamFileLine, RAM(I));
	end loop;
	return RAM;
end InitRamFromFile;
signal ram : ramType := InitRamFromFile("C:/Users/Vesa/Documents/FPGA/RV/Programs/Program.data");



signal regA   : std_logic_vector(WIDTHA-1 downto 0):= (others => '0');
signal regB   : std_logic_vector(WIDTHB-1 downto 0):= (others => '0');

begin

process (all)
begin
	if rising_edge(clk) then
		if enA = '1' then
			regA(7  downto 0)  <= ram(to_integer(unsigned(addrA)+0));
			regA(15 downto 8)  <= ram(to_integer(unsigned(addrA)+1));
			regA(23 downto 16) <= ram(to_integer(unsigned(addrA)+2));
			regA(31 downto 24) <= ram(to_integer(unsigned(addrA)+3));
		end if;

		if enB = '1' then
			if (weB = '1') then
				case(I_strWidth) is
					when "00" => 
						ram(to_integer(unsigned(addrB)+0))<= diB(7  downto 0);
					when "01" => 
						ram(to_integer(unsigned(addrB)+0))<= diB(7  downto 0);
						ram(to_integer(unsigned(addrB)+1))<= diB(15 downto 8);
					when "10" => 
						ram(to_integer(unsigned(addrB)+0))<= diB(7  downto 0);
						ram(to_integer(unsigned(addrB)+1))<= diB(15 downto 8);
						ram(to_integer(unsigned(addrB)+2))<= diB(23 downto 16);
						ram(to_integer(unsigned(addrB)+3))<= diB(31 downto 24);
					when "11" => 
						ram(to_integer(unsigned(addrB)+0))<= diB(7  downto 0);
						ram(to_integer(unsigned(addrB)+1))<= diB(15 downto 8);
						ram(to_integer(unsigned(addrB)+2))<= diB(23 downto 16);
						ram(to_integer(unsigned(addrB)+3))<= diB(31 downto 24);
						ram(to_integer(unsigned(addrB)+4))<= diB(39 downto 32);
						ram(to_integer(unsigned(addrB)+5))<= diB(47 downto 40);
						ram(to_integer(unsigned(addrB)+6))<= diB(55 downto 48);
						ram(to_integer(unsigned(addrB)+7))<= diB(63 downto 56);
					when others =>
						--there should be no other cases
				end case;
				if(O_rdyB = '1') then
					O_rdyB <= '0';
				else
					O_rdyB <= '1';
				end if;
			else
				O_rdyB <= '0';
			end if;
			regB(7  downto 0)  <= ram(to_integer(unsigned(addrB)+0));
			regB(15 downto 8)  <= ram(to_integer(unsigned(addrB)+1));
			regB(23 downto 16) <= ram(to_integer(unsigned(addrB)+2));
			regB(31 downto 24) <= ram(to_integer(unsigned(addrB)+3));
			regB(39 downto 32) <= ram(to_integer(unsigned(addrB)+4));
			regB(47 downto 40) <= ram(to_integer(unsigned(addrB)+5));
			regB(55 downto 48) <= ram(to_integer(unsigned(addrB)+6));
			regB(63 downto 56) <= ram(to_integer(unsigned(addrB)+7));
		end if;
	end if;
end process;
end behavioral;




