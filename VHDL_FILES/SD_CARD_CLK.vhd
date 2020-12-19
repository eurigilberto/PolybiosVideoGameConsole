library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.ALL;

entity SD_CARD_CLK is

	port(
		clk : in std_logic;
		sclk_reset: in std_logic;
		clk_posedge: out std_logic;
		clk_negedge: out std_logic;
		clk_freq_selector: in std_logic
	);

end SD_CARD_CLK;

architecture Behavioral of SD_CARD_CLK is

constant clk_400khz_count: std_logic_vector(8 downto 0):="101000101";
constant clk_20Mhz_count: std_logic_vector(8 downto 0):="000000111";

signal clk_counter: std_logic_vector(8 downto 0):= (others => '0');

signal clk_posedge_s : std_logic := '0';
signal clk_negedge_s : std_logic := '1';
signal clk_SD : std_logic := '0';

signal clk_count_limit: std_logic_vector(8 downto 0):= (others => '0');

begin

clk_count_limit <= clk_400khz_count when clk_freq_selector = '0' else
						 clk_20Mhz_count;

clk_posedge <= clk_SD;
clk_negedge <= not(clk_SD);

process(clk)
begin
	if(rising_edge(clk)) then
		if(sclk_reset = '1') then
			clk_counter <= (others => '0');
			clk_SD <= '0';
		else
			if(clk_counter >= clk_count_limit)then
				clk_counter <= (others => '0');
				if(clk_SD = '0') then
					clk_SD <= '1';
				else
					clk_SD <= '0';
				end if;
			else
				clk_counter <= clk_counter + 1;
			end if;
		end if;
	end if;
end process;


end Behavioral;

