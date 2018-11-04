library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library work;
use work.cpu_constants.all;

entity Top is Port ( 
		I_clk : in STD_LOGIC;
		--I_reset : in STD_LOGIC;

		O_uart_tx : out STD_LOGIC;
		I_uart_rx : in STD_LOGIC;

		I_SW0: in std_logic;
  		I_SW1: in std_logic;
  		I_SW2: in std_logic;
  		I_SW3: in std_logic;
  		I_BTN0: in std_logic;
  		I_BTN1: in std_logic;
  		I_BTN2: in std_logic;
  		I_BTN3: in std_logic;
  		O_Led0 : out STD_LOGIC;
  		O_Led1 : out STD_LOGIC;
  		O_Led2 : out STD_LOGIC;
  		O_Led3 : out STD_LOGIC;
  		O_RGBLed0R : out STD_LOGIC;
  		O_RGBLed0G : out STD_LOGIC;
  		O_RGBLed0B : out STD_LOGIC;
  		O_RGBLed1R : out STD_LOGIC;
  		O_RGBLed1G : out STD_LOGIC;
  		O_RGBLed1B : out STD_LOGIC;
  		O_RGBLed2R : out STD_LOGIC;
  		O_RGBLed2G : out STD_LOGIC;
  		O_RGBLed2B : out STD_LOGIC;
  		O_RGBLed3R : out STD_LOGIC;
  		O_RGBLed3G : out STD_LOGIC;
  		O_RGBLed3B : out STD_LOGIC
		);
end Top;

architecture Behavioral of Top is

signal W_pc: std_logic_vector(15 downto 0);
signal W_instruction: std_logic_vector(31 downto 0);

signal W_memAddress: std_logic_vector(31 downto 0);
signal W_memStore: std_logic;
signal W_memRead: std_logic;
signal W_memStoreData: std_logic_vector(31 downto 0);
signal W_memReadData: std_logic_vector(31 downto 0);

signal R_oldmemAddress: std_logic_vector(31 downto 0);

signal W_uartReadData: std_logic_vector(31 downto 0);
signal W_bramReadData: std_logic_vector(31 downto 0);
signal W_IOReadData:   std_logic_vector(31 downto 0);

component Core port(
		I_clk : in STD_LOGIC;
		I_enable : in STD_LOGIC;
		I_reset : in STD_LOGIC;

		--program counter
		O_pc : out STD_LOGIC_VECTOR (15 downto 0);
		I_instruction : in std_logic_vector(31 downto 0);

		--memory
		O_memAddress: out std_logic_vector(31 downto 0);
		O_memStore : out STD_LOGIC;
		O_memRead : out STD_LOGIC;
		O_memStoreData : out std_logic_vector(31 downto 0);
		I_memReadData : in STD_LOGIC_VECTOR (31 downto 0)
		);
end component;

component BlockRam port(
		clkA : in std_logic;
		clkB : in std_logic;
		enA : in std_logic;
		enB : in std_logic;
		weA : in std_logic;
		weB : in std_logic;
		addrA : in std_logic_vector(15 downto 0);
		addrB : in std_logic_vector(31 downto 0);
		diA : in  std_logic_vector(31 downto 0);
		diB : in  std_logic_vector(31 downto 0);
		doA : out std_logic_vector(31 downto 0);
		doB : out std_logic_vector(31 downto 0)
		);
end component;

component Uart Port (
		I_clk : in STD_LOGIC;
		I_baudcount : in STD_LOGIC_VECTOR (16 downto 0);
		I_reset : in STD_LOGIC;

		O_tx : out STD_LOGIC;
		I_rx : in STD_LOGIC;

		I_memAddress: in std_logic_vector(31 downto 0);
		I_memStore: in std_logic;
		I_memRead: in std_logic;
		I_memStoreData: in std_logic_vector(31 downto 0);
		O_memReadData: out std_logic_vector(31 downto 0)
		);
end component;

component IO port  (
		I_clk : in STD_LOGIC;
  		I_reset : in STD_LOGIC;
  		I_memAddress: in std_logic_vector(31 downto 0);
  		I_memStore: in std_logic;
  		I_memRead: in std_logic;
  		I_memStoreData: in std_logic_vector(31 downto 0);
  		O_memReadData: out std_logic_vector(31 downto 0):=(others => '0');
  		I_SW0: in std_logic;
  		I_SW1: in std_logic;
  		I_SW2: in std_logic;
  		I_SW3: in std_logic;
  		I_BTN0: in std_logic;
  		I_BTN1: in std_logic;
  		I_BTN2: in std_logic;
  		I_BTN3: in std_logic;
  		O_Led0 : out STD_LOGIC;
  		O_Led1 : out STD_LOGIC;
  		O_Led2 : out STD_LOGIC;
  		O_Led3 : out STD_LOGIC;
  		O_RGBLed0R : out STD_LOGIC;
  		O_RGBLed0G : out STD_LOGIC;
  		O_RGBLed0B : out STD_LOGIC;
  		O_RGBLed1R : out STD_LOGIC;
  		O_RGBLed1G : out STD_LOGIC;
  		O_RGBLed1B : out STD_LOGIC;
  		O_RGBLed2R : out STD_LOGIC;
  		O_RGBLed2G : out STD_LOGIC;
  		O_RGBLed2B : out STD_LOGIC;
  		O_RGBLed3R : out STD_LOGIC;
  		O_RGBLed3G : out STD_LOGIC;
  		O_RGBLed3B : out STD_LOGIC
  		);
end component;

begin

ProcessorCore: Core port map(
		I_clk 			=> I_clk,
		I_enable		=> '1',
		I_reset			=> '0',

		--program counter
		O_pc 			=> W_pc,
		I_instruction	=> W_instruction,

		--memory
		O_memAddress	=> W_memAddress,
		O_memStore		=> W_memStore,
		O_memRead		=> W_memRead,
		O_memStoreData	=> W_memStoreData,
		I_memReadData	=> W_memReadData
		);

Bram: BlockRam port map(
		clkA => I_clk,
		clkB => I_clk,
		enA => '1',
		enB => '1',
		weA => '0',
		weB => W_memStore,
		addrA => W_pc,
		addrB => W_memAddress, 
		diA => "00000000000000000000000000000000",
		diB => W_memStoreData, 
		doA => W_instruction, 
		doB => W_bramReadData
		);

UartComponent: Uart Port map(
		I_clk 			=> I_clk,
		I_baudcount 	=> "00001010001011000", --19200MHz
		I_reset 		=> '0',

		O_tx 			=> O_uart_tx,
		I_rx 			=> I_uart_rx,

		I_memAddress	=> W_memAddress,
		I_memStore 		=> W_memStore,
		I_memRead 		=> W_memRead,
		I_memStoreData	=> W_memStoreData,
		O_memReadData 	=> W_uartReadData
		);

IOcomponent: IO port map(
		I_clk          => I_clk,
		I_reset        => '0',
		I_memAddress   => W_memAddress,
		I_memStore     => W_memStore,
		I_memRead      => W_memRead,
		I_memStoreData => W_memStoreData,
		O_memReadData  => W_IOReadData,
		I_SW0          => I_SW0,
		I_SW1          => I_SW1,
		I_SW2          => I_SW2,
		I_SW3          => I_SW3,
		I_BTN0         => I_BTN0,
		I_BTN1         => I_BTN1,
		I_BTN2         => I_BTN2,
		I_BTN3         => I_BTN3,
		O_Led0         => O_Led0,
		O_Led1         => O_Led1,
		O_Led2         => O_Led2,
		O_Led3         => O_Led3,
		O_RGBLed0R     => O_RGBLed0R,
		O_RGBLed0G     => O_RGBLed0G,
		O_RGBLed0B     => O_RGBLed0B,
		O_RGBLed1R     => O_RGBLed1R,
		O_RGBLed1G     => O_RGBLed1G,
		O_RGBLed1B     => O_RGBLed1B,
		O_RGBLed2R     => O_RGBLed2R,
		O_RGBLed2G     => O_RGBLed2G,
		O_RGBLed2B     => O_RGBLed2B,
		O_RGBLed3R     => O_RGBLed3R,
		O_RGBLed3G     => O_RGBLed3G,
		O_RGBLed3B     => O_RGBLed3B
		);

process(all)
begin
	if(rising_edge(I_clk)) then
		R_oldmemAddress<=W_memAddress;
	end if;
end process;

process(all)
begin
	-- Ram
	if(R_oldmemAddress < std_logic_vector(to_unsigned(MEM_RAM_END,32))) then
		W_memReadData	<= W_bramReadData;

	--Uart
	elsif (R_oldmemAddress = std_logic_vector(to_unsigned(MEM_UART_DATA,32)) or R_oldmemAddress = std_logic_vector(to_unsigned(MEM_UART_STATUS,32))) then
		W_memReadData	<= W_uartReadData;

	--IO
	elsif (R_oldmemAddress = std_logic_vector(to_unsigned(MEM_IO_BUTTONS,32)) or R_oldmemAddress = std_logic_vector(to_unsigned(MEM_IO_SWITCHES,32))) then
		W_memReadData	<= W_IOReadData;

	else
		W_memReadData <= (others => '0');

	end if;
		
end process;
end Behavioral;
