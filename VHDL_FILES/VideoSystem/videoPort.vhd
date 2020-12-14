library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;

entity videoPort is

	port(
		clk : in std_logic;
		color : in std_logic_vector(7 downto 0);
		HSync : out std_logic;
		VSync : out std_logic;
		Red : out std_logic_vector(2 downto 0);
		Green : out std_logic_vector(2 downto 0);
		Blue : out std_logic_vector(1 downto 0);
		horizontal_pixel_coord: out std_logic_vector(7 downto 0);
		vertical_pixel_coord: out std_logic_vector(8 downto 0);
		blank : out std_logic;
		finish_buffer : out std_logic;
		finish_frame : out std_logic
	);

end videoPort;

architecture Behavioral of videoPort is

signal horizontalCounter: std_logic_vector(10 downto 0) := (others => '0');
signal verticalCounter: std_logic_vector(9 downto 0) := (others => '0');

constant hsyncLowerLimit: std_logic_vector(10 downto 0) := "10000011000";
constant hsyncUpperLimit: std_logic_vector(10 downto 0) := "10010100000";

constant horizontalLimit: std_logic_vector(10 downto 0) := "10100111111";
constant horizontalVisibleLimit: std_logic_vector(10 downto 0) := "01111111111";

constant vsyncLowerLimit: std_logic_vector(9 downto 0) := "1100000011";
constant vsyncUpperLimit: std_logic_vector(9 downto 0) := "1100001001";

constant verticalLimit: std_logic_vector(9 downto 0) := "1100100101";
constant verticalVisibleLimit: std_logic_vector(9 downto 0) := "1011111111";

signal colorValue: std_logic_vector(7 downto 0) := (others => '0');

signal blank_s:std_logic := '0';

begin

process(clk)
begin

	if (rising_edge(clk)) then
		finish_buffer <= '0';
		finish_frame <= '0';
		-- Horizontal Counter
		if (horizontalCounter >= horizontalLimit) then
			horizontalCounter <= (others => '0');
		else
			horizontalCounter <= horizontalCounter + 1;
		end if;
		
		-- Vertical Counter
		if(horizontalCounter >= horizontalLimit) then
			if (verticalCounter >= verticalLimit) then
				verticalCounter <= (others => '0');
			else
				verticalCounter <= verticalCounter + 1;
			end if;
		end if;
		
		-- finish_buffer
		if(horizontalCounter = horizontalVisibleLimit+4 and verticalCounter(1 downto 0) = "00" and horizontalCounter(1 downto 0) = "11" and verticalCounter <= verticalVisibleLimit) then
			finish_buffer <= '1';
		end if;
		
		--finish Frame
		if(horizontalCounter = horizontalVisibleLimit+4 and verticalCounter = verticalVisibleLimit) then
			finish_frame <= '1';
		end if;
	end if;
end process;

horizontal_pixel_coord <= horizontalCounter(9 downto 2) + 1;

vertical_pixel_coord <= '0'&verticalCounter(9 downto 2);

Hsync <= '0' when ((horizontalCounter >= hsyncLowerLimit) AND (horizontalCounter < hsyncUpperLimit)) else
						  '1';
Vsync <= '0' when ((verticalCounter > vsyncLowerLimit) AND (verticalCounter <= vsyncUpperLimit)) else
						  '1';
colorValue <= color when ((verticalCounter < verticalVisibleLimit) AND (horizontalCounter < horizontalVisibleLimit)) else
						  (others => '0');

blank_s <= '0' when ((verticalCounter <= verticalVisibleLimit) AND (horizontalCounter <= horizontalVisibleLimit)) else
			'1';

blank <= blank_s;

RED <= colorValue(7 downto 5);
GREEN <= colorValue(4 downto 2);
BLUE <= colorValue(1 downto 0);

end Behavioral;