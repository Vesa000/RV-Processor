library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;

entity Top_tb is
end;

architecture bench of Top_tb is

  component Top Port ( 
  		I_clk : in STD_LOGIC;
  		I_reset : in STD_LOGIC;
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
  end component;

  signal I_clk: STD_LOGIC;
  signal I_reset: STD_LOGIC;
  signal O_uart_tx: STD_LOGIC;
  signal I_uart_rx: STD_LOGIC;
  signal I_SW0: std_logic;
  signal I_SW1: std_logic;
  signal I_SW2: std_logic;
  signal I_SW3: std_logic;
  signal I_BTN0: std_logic;
  signal I_BTN1: std_logic;
  signal I_BTN2: std_logic;
  signal I_BTN3: std_logic;
  signal O_Led0: STD_LOGIC;
  signal O_Led1: STD_LOGIC;
  signal O_Led2: STD_LOGIC;
  signal O_Led3: STD_LOGIC;
  signal O_RGBLed0R: STD_LOGIC;
  signal O_RGBLed0G: STD_LOGIC;
  signal O_RGBLed0B: STD_LOGIC;
  signal O_RGBLed1R: STD_LOGIC;
  signal O_RGBLed1G: STD_LOGIC;
  signal O_RGBLed1B: STD_LOGIC;
  signal O_RGBLed2R: STD_LOGIC;
  signal O_RGBLed2G: STD_LOGIC;
  signal O_RGBLed2B: STD_LOGIC;
  signal O_RGBLed3R: STD_LOGIC;
  signal O_RGBLed3G: STD_LOGIC;
  signal O_RGBLed3B: STD_LOGIC;

  constant clock_period: time := 10 ns;
  signal stop_the_clock: boolean;

begin

  uut: Top port map ( I_clk      => I_clk,
                      I_reset    => I_reset,
                      O_uart_tx  => O_uart_tx,
                      I_uart_rx  => I_uart_rx,
                      I_SW0      => I_SW0,
                      I_SW1      => I_SW1,
                      I_SW2      => I_SW2,
                      I_SW3      => I_SW3,
                      I_BTN0     => I_BTN0,
                      I_BTN1     => I_BTN1,
                      I_BTN2     => I_BTN2,
                      I_BTN3     => I_BTN3,
                      O_Led0     => O_Led0,
                      O_Led1     => O_Led1,
                      O_Led2     => O_Led2,
                      O_Led3     => O_Led3,
                      O_RGBLed0R => O_RGBLed0R,
                      O_RGBLed0G => O_RGBLed0G,
                      O_RGBLed0B => O_RGBLed0B,
                      O_RGBLed1R => O_RGBLed1R,
                      O_RGBLed1G => O_RGBLed1G,
                      O_RGBLed1B => O_RGBLed1B,
                      O_RGBLed2R => O_RGBLed2R,
                      O_RGBLed2G => O_RGBLed2G,
                      O_RGBLed2B => O_RGBLed2B,
                      O_RGBLed3R => O_RGBLed3R,
                      O_RGBLed3G => O_RGBLed3G,
                      O_RGBLed3B => O_RGBLed3B );

  stimulus: process
  begin
    
    I_reset <= '1';
    wait for clock_period;
    I_reset <= '0';
    wait for clock_period*1000;

    wait;
  end process;

  clocking: process
  begin
  while not stop_the_clock loop
    I_clk <= '0', '1' after clock_period / 2;
    wait for clock_period;
  end loop;
  wait;
  end process;


end;