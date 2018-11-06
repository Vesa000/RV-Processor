library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library work;
use work.cpu_constants.all;

entity IO is Port (
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
end IO;

architecture Behavioral of IO is

	signal R_CNTR : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');

	type PWM_Value is array (0 to 31) of STD_LOGIC_VECTOR(63 downto 0);
    	signal PWM: PWM_Value := (others => X"0000000000000000");
    	signal PWM_Out : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');

begin

	process (all)
	begin
		if rising_edge(I_clk) then
			if (I_reset = '1') then
				--reset
			else
				-- read switches
				if(signed(I_memAddress) = MEM_IO_SWITCHES and I_memRead = '1') then
					O_memReadData(31 downto 4) <= (others => '0');
					O_memReadData(0) <= I_SW0;
					O_memReadData(1) <= I_SW1;
					O_memReadData(2) <= I_SW2;
					O_memReadData(3) <= I_SW3;
				end if;

				-- read buttons
				if(signed(I_memAddress) = MEM_IO_BUTTONS and I_memRead = '1') then
					O_memReadData(31 downto 4) <= (others => '0');
					O_memReadData(0) <= I_BTN0;
					O_memReadData(1) <= I_BTN1;
					O_memReadData(2) <= I_BTN2;
					O_memReadData(3) <= I_BTN3;
				end if;

				-- write leds
				if(signed(I_memAddress) = MEM_IO_LEDS) then
					O_Led0 <= I_memStoreData(0);
					O_Led1 <= I_memStoreData(1);
					O_Led2 <= I_memStoreData(2);
					O_Led3 <= I_memStoreData(3);
				end if;

				-- write PWM values
				if(signed(I_memAddress) = MEM_IO_RGB_0R) then
					PWM(0) <= I_memStoreData;
				end if;
				if(signed(I_memAddress) = MEM_IO_RGB_0G) then
					PWM(1) <= I_memStoreData;
				end if;
				if(signed(I_memAddress) = MEM_IO_RGB_0B) then
					PWM(2) <= I_memStoreData;
				end if;
				if(signed(I_memAddress) = MEM_IO_RGB_1R) then
					PWM(3) <= I_memStoreData;
				end if;
				if(signed(I_memAddress) = MEM_IO_RGB_1G) then
					PWM(4) <= I_memStoreData;
				end if;
				if(signed(I_memAddress) = MEM_IO_RGB_1B) then
					PWM(5) <= I_memStoreData;
				end if;
				if(signed(I_memAddress) = MEM_IO_RGB_2R) then
					PWM(6) <= I_memStoreData;
				end if;
				if(signed(I_memAddress) = MEM_IO_RGB_2G) then
					PWM(7) <= I_memStoreData;
				end if;
				if(signed(I_memAddress) = MEM_IO_RGB_2B) then
					PWM(8) <= I_memStoreData;
				end if;
				if(signed(I_memAddress) = MEM_IO_RGB_3R) then
					PWM(9) <= I_memStoreData;
				end if;
				if(signed(I_memAddress) = MEM_IO_RGB_3G) then
					PWM(10) <= I_memStoreData;
				end if;
				if(signed(I_memAddress) = MEM_IO_RGB_3B) then
					PWM(11) <= I_memStoreData;
				end if;

				-- update PWM
				if(unsigned(R_CNTR)<1048576) then
				R_CNTR <= STD_LOGIC_VECTOR(unsigned(R_CNTR) + 1);
				else
				R_CNTR <= STD_LOGIC_VECTOR(to_unsigned(0,32));
				end if;

				for i in 0 to 31 loop
					if(unsigned(R_CNTR) < unsigned(PWM(i))) then
						PWM_Out(i) <= '1';
        				else
						PWM_Out(i) <= '0';
        				end if;
      				end loop;
			end if;
		end if;
	end process;

	process (all)
	begin
		O_RGBLed0R <= PWM_Out(0);
		O_RGBLed0G <= PWM_Out(1);
		O_RGBLed0B <= PWM_Out(2);

		O_RGBLed1R <= PWM_Out(3);
		O_RGBLed1G <= PWM_Out(4);
		O_RGBLed1B <= PWM_Out(5);

		O_RGBLed2R <= PWM_Out(6);
		O_RGBLed2G <= PWM_Out(7);
		O_RGBLed2B <= PWM_Out(8);

		O_RGBLed3R <= PWM_Out(9);
		O_RGBLed3G <= PWM_Out(10);
		O_RGBLed3B <= PWM_Out(11);
	end process;
end Behavioral;
