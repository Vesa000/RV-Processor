library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;

entity barrelshifter is port (
        I_dIn        : in std_logic_vector(63 downto 0);
        I_shift      : in std_logic_vector(63 downto 0);

        O_leftArith  : out std_logic_vector(63 downto 0);
        O_rightArith : out std_logic_vector(63 downto 0);
        
        O_leftLogic  : out std_logic_vector(63 downto 0);
        O_rightLogic : out std_logic_vector(63 downto 0)
        );
end entity barrelshifter;



architecture barrel of barrelshifter is
begin
    EachBit: for bitpos in I_dIn'range generate

      O_leftArith(bitpos)  <= I_dIn((bitpos - to_integer(unsigned(I_shift))) mod (I_dIn'high + 1));
      O_rightArith(bitpos) <= I_dIn((bitpos + to_integer(unsigned(I_shift))) mod (I_dIn'high + 1));
    end generate EachBit;

process(all)
begin
    for I in 63 downto 0 loop
      if(I < unsigned(I_shift)) then
        O_leftLogic(I) <= '0';
        O_rightLogic(63-I) <= '0';
      else
        O_rightLogic(63-I) <= O_rightArith(I);
      end if;
    end loop;

end process;
end architecture barrel;