library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library work;
use work.cpu_constants.all;

entity Core is Port ( 
		I_clk : in STD_LOGIC;
		I_reset : in STD_LOGIC;

		--program counter
		O_pc : out STD_LOGIC_VECTOR (63 downto 0);
		I_instruction : in std_logic_vector(31 downto 0);

		--memory
		O_memAddress: out std_logic_vector(63 downto 0);
		O_memStoreData : out std_logic_vector(63 downto 0);
		O_memWidth : out std_logic_vector(1 downto 0);
		O_memRead : out STD_LOGIC;
		O_memStore : out STD_LOGIC;
		I_memReadData : in STD_LOGIC_VECTOR (63 downto 0);
		I_memRdy : in STD_LOGIC
		);
end Core;

architecture Behavioral of Core is

signal W_pause  : STD_LOGIC;
signal W_clearFD: STD_LOGIC;

--Fetch
signal W_FD_instruction : STD_LOGIC_VECTOR (31 downto 0);
signal W_FD_instAddr    : STD_LOGIC_VECTOR (63 downto 0);
signal W_FD_execute     : STD_LOGIC;
--Decode
signal W_DE_execute     : STD_LOGIC;
signal W_DE_instData    : STD_LOGIC_VECTOR (31 downto 0);
signal W_DE_instAddr    : STD_LOGIC_VECTOR (63 downto 0);
signal W_DE_instruction : integer;
signal W_DE_immediate   : STD_LOGIC_VECTOR (63 downto 0);
signal W_DE_rd          : STD_LOGIC_VECTOR (4 downto 0);
--Execute
signal W_EWB_store      : STD_LOGIC;
signal W_EWB_rd         : STD_LOGIC_VECTOR (4 downto 0);
signal W_EXE_Data       : STD_LOGIC_VECTOR (63 downto 0);
--WriteBack
signal W_WB_store       : STD_LOGIC;
signal W_WB_addr        : STD_LOGIC_VECTOR (4 downto 0);
signal W_WB_Data        : STD_LOGIC_VECTOR (63 downto 0);
--Registers
signal W_R_dataA : STD_LOGIC_VECTOR (63 downto 0);
signal W_R_dataB : STD_LOGIC_VECTOR (63 downto 0);
signal W_R_readA : STD_LOGIC_VECTOR (4 downto 0);
signal W_R_readB : STD_LOGIC_VECTOR (4 downto 0);

component Fetch port(
		I_clk         : in STD_LOGIC;
		I_reset       : in std_logic;
		I_pause       : in STD_LOGIC;
		I_clear       : in STD_LOGIC;
		I_instruction : in STD_LOGIC_VECTOR (31 downto 0);
		O_instruction : out STD_LOGIC_VECTOR (31 downto 0);
		O_execute     : out STD_LOGIC;
		I_instAddr    : in STD_LOGIC_VECTOR (63 downto 0);
		O_instAddr    : out STD_LOGIC_VECTOR (63 downto 0)
		);
end component;

component Decode port(
		I_clk : in STD_LOGIC;
		I_reset : in STD_LOGIC;
		I_instAddr : in STD_LOGIC_VECTOR (63 downto 0);
		O_instData : out STD_LOGIC_VECTOR (31 downto 0);
		O_instAddr : out STD_LOGIC_VECTOR (63 downto 0);
		I_instruction : in STD_LOGIC_VECTOR (31 downto 0);
		O_instruction : out integer;
		O_immediate : out STD_LOGIC_VECTOR (63 downto 0);
		O_rd : out STD_LOGIC_VECTOR (4 downto 0);
		O_read1 : out STD_LOGIC_VECTOR (4 downto 0);
		O_read2 : out STD_LOGIC_VECTOR (4 downto 0);
		I_pause : in STD_LOGIC;
		I_clear : in STD_LOGIC;
		I_execute : in STD_LOGIC;
		O_execute : out STD_LOGIC
		);
end component;

component Execute port(
   		I_clk : in STD_LOGIC;
		I_reset : in STD_LOGIC;
		I_instData : in STD_LOGIC_VECTOR (31 downto 0);
		I_instAddr : in STD_LOGIC_VECTOR (63 downto 0);
		I_instruction : in integer;
		I_rs1 : in STD_LOGIC_VECTOR (63 downto 0);
		I_rs2 : in STD_LOGIC_VECTOR (63 downto 0);
		I_rd : in STD_LOGIC_VECTOR (4 downto 0);
		I_immediate : in STD_LOGIC_VECTOR (63 downto 0);
		I_memRdy : in STD_LOGIC;
		I_memData : in STD_LOGIC_VECTOR (63 downto 0);
		O_StoreReg : out STD_LOGIC;
		O_StoreMem : out STD_LOGIC;
		O_memWidth : out STD_LOGIC_VECTOR (1 downto 0);
		O_MemRead : out STD_LOGIC;
		O_memAddr : out STD_LOGIC_VECTOR (63 downto 0);
		O_data : out STD_LOGIC_VECTOR (63 downto 0);
		O_rd : out STD_LOGIC_VECTOR(4 downto 0);
		O_PC : out STD_LOGIC_VECTOR (63 downto 0);
		O_clearFD : out STD_LOGIC;
		O_pauseFD : out STD_LOGIC
		);
end component;

component WriteBack port(
		I_clk : in STD_LOGIC;
		I_reset : in STD_LOGIC;
		I_regWrite : in STD_LOGIC;
		I_address : in STD_LOGIC_VECTOR (4 downto 0);
		I_data : in STD_LOGIC_VECTOR (63 downto 0);
		O_store : out STD_LOGIC;
		O_address : out STD_LOGIC_VECTOR (4 downto 0);
		O_data : out STD_LOGIC_VECTOR (63 downto 0)
	   	);
end component;

component Registers port(
		I_clk : in STD_LOGIC;
		I_reset : in STD_LOGIC;
		i_we : in STD_LOGIC;
		I_data : in  STD_LOGIC_VECTOR (63 downto 0);
		I_storeAddr : in STD_LOGIC_VECTOR (4 downto 0);
		I_readA : in STD_LOGIC_VECTOR (4 downto 0);
		I_readB : in STD_LOGIC_VECTOR (4 downto 0);
		O_dataA : out STD_LOGIC_VECTOR (63 downto 0);
		O_dataB : out STD_LOGIC_VECTOR (63 downto 0)
		);
end component;

begin

FetchStage: Fetch port map(
		I_clk         => I_clk,
		I_reset       => I_reset,
		I_pause       => W_pause,
		I_clear       => W_clearFD,
		I_instruction => I_instruction,
		O_instruction => W_FD_instruction,
		O_execute     => W_FD_execute,
		I_instAddr    => O_pc,
		O_instAddr    => W_FD_instAddr
		);
						
DecodeStage: Decode port map(

		I_clk         => I_clk,
		I_reset       => I_reset,
		I_instAddr    => W_FD_instAddr,
		O_instData    => W_DE_instData,
		O_instAddr    => W_DE_instAddr,
		I_instruction => W_FD_instruction,
		O_instruction => W_DE_instruction,
		O_immediate   => W_DE_immediate,
		O_rd          => W_DE_rd,
		O_read1       => W_R_readA,
		O_read2       => W_R_readB,
		I_pause       => W_pause,
		I_clear       => W_clearFD,
		I_execute     => W_FD_execute,
		O_execute     => W_DE_execute
		);

ExecuteStage: Execute port map(
		I_clk         => I_clk,
		I_reset       => I_reset,
		I_instData    => W_DE_instData,
		I_instAddr    => W_DE_instAddr,
		I_instruction => W_DE_instruction,
		I_rs1         => W_R_dataA,
		I_rs2         => W_R_dataB,
		I_rd          => W_DE_rd,
		I_immediate   => W_DE_immediate,
		I_memRdy      => I_memRdy,
		I_memData     => I_memReadData,
		O_StoreReg    => W_EWB_store,
		O_StoreMem    => O_memStore,
		O_memWidth    => O_memWidth,
		O_MemRead     => O_memRead,
		O_memAddr     => O_memAddress,
		O_data        => W_EXE_Data,
		O_rd          => W_EWB_rd,
		O_PC          => O_pc,
		O_clearFD     => W_clearFD,
		O_pauseFD     => W_pause
		);

WriteBackStage: WriteBack port map(
		I_clk         => I_clk,
		I_reset       => I_reset,
		I_regWrite    => W_EWB_store,
		I_address     => W_EWB_rd,
		I_data        => W_EXE_Data,
		O_store       => W_WB_store,
		O_address     => W_WB_addr,
		O_data        => W_WB_Data
		);

Registers32: Registers port map(
		I_clk => I_clk,
		I_reset => I_reset,
		i_we=> W_WB_store,
		I_data=>W_WB_Data,
		I_storeAddr=>W_WB_addr,
		I_readA=>W_R_readA,
		I_readB=>W_R_readB,
		O_dataA=>W_R_dataA,
		O_dataB=>W_R_dataB
		);
 
process(all)
begin
	O_memStoreData <= W_EXE_Data;
end process;

end Behavioral;
