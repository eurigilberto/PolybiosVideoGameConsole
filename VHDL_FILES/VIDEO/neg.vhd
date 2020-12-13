library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity neg is
    Port ( input : in  STD_LOGIC;
           output : out  STD_LOGIC);
end neg;

architecture Behavioral of neg is

begin

output <= not(input);

end Behavioral;

