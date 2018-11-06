library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library work;
use work.cpu_constants.all;

entity Top is Port ( 
		I_clk : in STD_LOGIC;
		I_reset : in STD_LOGIC;
		--Uart
		O_uart_tx : out STD_LOGIC;
		I_uart_rx : in STD_LOGIC;
		--IO
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

signal W_pc: std_logic_vector(63 downto 0);
signal W_instruction: std_logic_vector(31 downto 0);


--MemoryMap
signal W_mm_store: STD_LOGIC;
signal W_mm_storeWidth : STD_LOGIC_VECTOR (1 downto 0);
signal W_mm_load : STD_LOGIC;
signal W_mm_address : STD_LOGIC_VECTOR (63 downto 0);
signal W_mm_Idata : STD_LOGIC_VECTOR (63 downto 0);
signal W_mm_loadRdy : STD_LOGIC;
signal W_mm_Odata : STD_LOGIC_VECTOR (63 downto 0);
--Memory
signal W_MemLoadRdy : STD_LOGIC;
signal W_MemLoadData : STD_LOGIC_VECTOR (63 downto 0);
signal W_MemStore : STD_LOGIC;
signal W_MemstoreWidth : STD_LOGIC_VECTOR (1 downto 0);
signal W_MemLoad : STD_LOGIC;
signal W_MemAddress : STD_LOGIC_VECTOR (63 downto 0);
signal W_MemStoreData : STD_LOGIC_VECTOR (63 downto 0);
--IO
signal W_IOLoadRdy : STD_LOGIC;
signal W_IOLoadData : STD_LOGIC_VECTOR (63 downto 0);
signal W_IOStore : STD_LOGIC;
signal W_IOstoreWidth : STD_LOGIC_VECTOR (1 downto 0);
signal W_IOLoad : STD_LOGIC;
signal W_IOAddress : STD_LOGIC_VECTOR (63 downto 0);
signal W_IOStoreData : STD_LOGIC_VECTOR (63 downto 0);
--Uart
signal W_UartLoadRdy : STD_LOGIC;
signal W_UartLoadData : STD_LOGIC_VECTOR (63 downto 0);
signal W_UartStore : STD_LOGIC;
signal W_UartstoreWidth : STD_LOGIC_VECTOR (1 downto 0);
signal W_UartLoad : STD_LOGIC;
signal W_UartAddress : STD_LOGIC_VECTOR (63 downto 0);
signal W_UartStoreData : STD_LOGIC_VECTOR (63 downto 0);

component Core port(
		I_clk : in STD_LOGIC;
		I_reset : in STD_LOGIC;
		O_pc : out STD_LOGIC_VECTOR (63 downto 0);
		I_instruction : in std_logic_vector(31 downto 0);
		O_memAddress: out std_logic_vector(63 downto 0);
		O_memStoreData : out std_logic_vector(63 downto 0);
		O_memStoreWidth : out std_logic_vector(1 downto 0);
		O_memRead : out STD_LOGIC;
		O_memStore : out STD_LOGIC;
		I_memReadData : in STD_LOGIC_VECTOR (63 downto 0);
		I_memRdy : in STD_LOGIC
		);
end component;

component MemoryMapper port(
		I_store : in STD_LOGIC;
		I_storeWidth : in STD_LOGIC_VECTOR (1 downto 0);
		I_load : in STD_LOGIC;
		I_address : in STD_LOGIC_VECTOR (63 downto 0);
		I_data : in STD_LOGIC_VECTOR (63 downto 0);
		O_loadRdy : out STD_LOGIC;
		O_data : out STD_LOGIC_VECTOR (63 downto 0);

		I_MemLoadRdy : in STD_LOGIC;
		I_MemLoadData : in STD_LOGIC_VECTOR (63 downto 0);
		O_MemStore : out STD_LOGIC;
		O_MemstoreWidth : out STD_LOGIC_VECTOR (1 downto 0);
		O_MemLoad : out STD_LOGIC;
		O_MemAddress : out STD_LOGIC_VECTOR (63 downto 0);
		O_MemStoreData : out STD_LOGIC_VECTOR (63 downto 0);

		I_IOLoadRdy : in STD_LOGIC;
		I_IOLoadData : in STD_LOGIC_VECTOR (63 downto 0);
		O_IOStore : out STD_LOGIC;
		O_IOstoreWidth : out STD_LOGIC_VECTOR (1 downto 0);
		O_IOLoad : out STD_LOGIC;
		O_IOAddress : out STD_LOGIC_VECTOR (63 downto 0);
		O_IOStoreData : out STD_LOGIC_VECTOR (63 downto 0);

		I_UartLoadRdy : in STD_LOGIC;
		I_UartLoadData : in STD_LOGIC_VECTOR (63 downto 0);
		O_UartStore : out STD_LOGIC;
		O_UartstoreWidth : out STD_LOGIC_VECTOR (1 downto 0);
		O_UartLoad : out STD_LOGIC;
		O_UartAddress : out STD_LOGIC_VECTOR (63 downto 0);
		O_UartStoreData : out STD_LOGIC_VECTOR (63 downto 0)
		);
end component;



component BlockRam port(
		clk : in std_logic;
		enA : in std_logic;
		enB : in std_logic;
		weB : in std_logic;
		addrA : in std_logic_vector(63 downto 0);
		addrB : in std_logic_vector(63 downto 0);
		diB : in  std_logic_vector(63 downto 0);
		doA : out std_logic_vector(31 downto 0);
		doB : out std_logic_vector(63 downto 0);
		I_strWidth: in std_logic_vector(1 downto 0);
		O_rdyB : out std_logic
		);
end component;

component Uart Port (
		I_clk : in STD_LOGIC;
		I_baudcount : in STD_LOGIC_VECTOR (16 downto 0);
		I_reset : in STD_LOGIC;

		O_tx : out STD_LOGIC;
		I_rx : in STD_LOGIC;

		I_memAddress: in std_logic_vector(63 downto 0);
		I_memStore: in std_logic;
		I_memRead: in std_logic;
		I_memStoreData: in std_logic_vector(63 downto 0);
		O_memReadData: out std_logic_vector(63 downto 0)
		);
end component;

component IO port  (
		I_clk : in STD_LOGIC;
  		I_reset : in STD_LOGIC;
  		I_memAddress: in std_logic_vector(63 downto 0);
  		I_memStore: in std_logic;
  		I_memRead: in std_logic;
  		I_memStoreData: in std_logic_vector(63 downto 0);
  		O_memReadData: out std_logic_vector(63 downto 0):=(others => '0');
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
		I_clk           => I_clk, 
		I_reset         => I_reset,
		O_pc            => W_pc,
		I_instruction   => W_instruction,
		O_memAddress    => W_mm_address,
		O_memStoreData  => W_mm_Idata,
		O_memStoreWidth => W_mm_storeWidth,
		O_memRead       => W_mm_load,
		O_memStore      => W_mm_store,
		I_memReadData   => W_mm_Odata,
		I_memRdy        => W_mm_loadRdy
		);

MemoryMap: MemoryMapper port map(
		I_store         => W_mm_store,
		I_storeWidth    => W_mm_storeWidth,
		I_load          => W_mm_load,
		I_address       => W_mm_address,
		I_data          => W_mm_Idata,
		O_loadRdy       => W_mm_loadRdy,
		O_data          => W_mm_Odata,
		I_MemLoadRdy    => W_MemLoadRdy,
		I_MemLoadData   => W_MemLoadData,
		O_MemStore      => W_memStore,
		O_MemstoreWidth => W_MemstoreWidth,
		O_MemLoad       => W_MemLoad,
		O_MemAddress    => W_memAddress,
		O_MemStoreData  => W_memStoreData,
		I_IOLoadRdy     => W_IOLoadRdy,
		I_IOLoadData    => W_IOLoadData,
		O_IOStore       => W_IOStore,
		O_IOstoreWidth  => W_IOstoreWidth,
		O_IOLoad        => W_IOLoad,
		O_IOAddress     => W_IOAddress,
		O_IOStoreData   => W_IOStoreData,
		I_UartLoadRdy   => W_UartLoadRdy,
		I_UartLoadData  => W_UartLoadData,
		O_UartStore     => W_UartStore,
		O_UartstoreWidth=> W_UartstoreWidth,
		O_UartLoad      => W_UartLoad,
		O_UartAddress   => W_UartAddress,
		O_UartStoreData => W_UartStoreData
		);

Bram: BlockRam port map(
		clk => I_clk,
		enA => '1',
		enB => '1',
		weB => W_memStore,
		addrA => W_pc,
		addrB => W_memAddress, 
		diB => W_memStoreData, 
		doA => W_instruction, 
		doB => W_MemLoadData,
		I_strWidth => W_MemstoreWidth,
		O_rdyB => W_MemLoadRdy
		);

UartComponent: Uart Port map(
		I_clk 		   => I_clk,
		I_baudcount    => "00001010001011000", --19200MHz
		I_reset 	   => I_reset,
		O_tx 		   => O_uart_tx,
		I_rx 		   => I_uart_rx,
		I_memAddress   => W_UartAddress,
		I_memStore 	   => W_UartStore,
		I_memRead 	   => W_UartLoad,
		I_memStoreData => W_UartStoreData,
		O_memReadData  => W_UartLoadData
		);

IOcomponent: IO port map(
		I_clk          => I_clk,
		I_reset        => '0',
		I_memAddress   => W_IOAddress,
		I_memStore     => W_IOStore,
		I_memRead      => W_IOLoad,
		I_memStoreData => W_IOStoreData,
		O_memReadData  => W_IOLoadData,
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

end process;
end Behavioral;
