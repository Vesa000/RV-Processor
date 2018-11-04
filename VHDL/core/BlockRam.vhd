library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;
use std.textio.all;
library work;
use work.cpu_constants.all;

entity BlockRam is
generic (
	WIDTHA : integer := 32;
	SIZEA : integer := 4000;
	--SIZEA : integer := 40000;
	ADDRWIDTHA : integer := 16;
	WIDTHB : integer := 32;
	SIZEB : integer := 30000;
	ADDRWIDTHB : integer := 16
	);

port (
	clkA : in std_logic;
	clkB : in std_logic;
	enA : in std_logic;
	enB : in std_logic;
	weA : in std_logic;
	weB : in std_logic;
	addrA : in std_logic_vector(15 downto 0);
	addrB : in std_logic_vector(31 downto 0);
	diA : in std_logic_vector(31 downto 0);
	diB : in std_logic_vector(31 downto 0);
	doA : out std_logic_vector(31 downto 0);
	doB : out std_logic_vector(31 downto 0)
	);
end BlockRam;
architecture behavioral of BlockRam is

type ramType is array (0 to SIZEA-1) of std_logic_vector(WIDTHA-1 downto 0);


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
signal ram : ramType := InitRamFromFile("C:/Users/Vesa/Documents/FPGA/VHDL-Processor/Programs/Program.data");



signal readA : std_logic_vector(WIDTHA-1 downto 0):= (others => '0');
signal readB : std_logic_vector(WIDTHB-1 downto 0):= (others => '0');
signal regA  : std_logic_vector(WIDTHA-1 downto 0):= (others => '0');
signal regB  : std_logic_vector(WIDTHB-1 downto 0):= (others => '0');

begin

process (clkA,clkB)
begin
	if rising_edge(clkA) then
		if enA = '1' then
			if weA = '1' then
				ram(to_integer(unsigned(addrA))) <= diA;
			end if;
			regA <= ram(to_integer(unsigned(addrA)));
			--readA <= ram(to_integer(unsigned(addrA)));
		end if;
		--regA <= readA;
	end if;
	if rising_edge(clkB) then
		if enB = '1' then
			if (weB = '1' and addrB < std_logic_vector(to_unsigned(MEM_RAM_END,32))) then
				ram(to_integer(unsigned(addrB)))<= diB;
			end if;

			if(addrB < std_logic_vector(to_unsigned(MEM_RAM_END,32))) then
				regB <= ram(to_integer(unsigned(addrB)));
			end if;
		end if;
		--regB <= readB;
	end if;
end process;

process(all)
begin
	doA <= regA;
	doB <= regB;
end process;

end behavioral;