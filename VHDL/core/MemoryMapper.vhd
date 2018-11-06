library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library work;
use work.cpu_constants.all;

entity MemoryMapper is Port (
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
end MemoryMapper;

architecture Behavioral of MemoryMapper is

begin

process(all)
begin
	if(signed(I_address) >= MEM_MEM_BEGIN AND signed(I_address) <= MEM_MEM_END) then
		O_loadRdy      <= I_MemLoadRdy;
		O_data         <= I_MemLoadData;
		O_MemStore     <= I_store;
		O_MemstoreWidth<= I_storeWidth;
		O_MemLoad      <= I_load;
		O_MemAddress   <= I_address;
		O_MemStoreData <= I_data;
	else
		O_MemStore     <= '0';
		O_MemLoad      <= '0';
		O_MemAddress   <= (others => '0');
		O_MemStoreData <= (others => '0');
	end if;

	if(signed(I_address) >= MEM_IO_BEGIN )then --AND signed(I_address) <= MEM_IO_END) then
		O_loadRdy      <= I_IOLoadRdy;
		O_data         <= I_IOLoadData;
		O_IOStore     <= I_store;
		O_IOstoreWidth<= I_storeWidth;
		O_IOLoad      <= I_load;
		O_IOAddress   <= I_address;
		O_IOStoreData <= I_data;
	else
		O_IOStore     <= '0';
		O_IOLoad      <= '0';
		O_IOAddress   <= (others => '0');
		O_IOStoreData <= (others => '0');
	end if;

	if(signed(I_address) >= MEM_UART_BEGIN AND signed(I_address) <= MEM_UART_END) then
		O_loadRdy       <= I_UartLoadRdy;
		O_data          <= I_UartLoadData;
		O_UartStore     <= I_store;
		O_UartstoreWidth<= I_storeWidth;
		O_UartLoad      <= I_load;
		O_UartAddress   <= I_address;
		O_UartStoreData <= I_data;
	else
		O_UartStore     <= '0';
		O_UartLoad      <= '0';
		O_UartAddress   <= (others => '0');
		O_UartStoreData <= (others => '0');
	end if;

end process;
end Behavioral;