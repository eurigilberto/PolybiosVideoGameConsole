library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;

entity video_port is

	port(
		clk : in std_logic;
		pixel : in std_logic_vector(7 downto 0);
		HSync : out std_logic;
		VSync : out std_logic;
		Red : out std_logic_vector(2 downto 0);
		Green : out std_logic_vector(2 downto 0);
		Blue : out std_logic_vector(1 downto 0);
		horizontal_pixel_coord: out std_logic_vector(7 downto 0);
		vertical_pixel_coord: out std_logic_vector(7 downto 0);
		blank : out std_logic;
		finish_frame : out std_logic;
		vertical_blanking : out std_logic
	);

end video_port;

architecture Behavioral of video_port is

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

signal pixel_value: std_logic_vector(7 downto 0) := (others => '0');
signal blank_s:std_logic := '0';

signal visible_region: std_logic := '0';

begin

process(clk)
begin

	if (rising_edge(clk)) then
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
		
		--finish Frame
		if(horizontalCounter = horizontalVisibleLimit+4 and verticalCounter = verticalVisibleLimit) then
			finish_frame <= '1';
		end if;
	end if;
end process;

-- Setting the horizontal pixel coordinate used in the system
-- The horizontal pixel coordinate sets its value to 0 right before the counter goes back to 0 because this way
-- the layer buffers have time to retrieve the corrrect values when needed. The problem comes from the fact that when 
-- an address is set the buffer takes 1 cycle to retrieve the data, and in that cycle the system would have already requested the first pixel
-- and because it is not the correct value, a vertical line of pixels out of place would be drawn.
horizontal_pixel_coord <= horizontalCounter(9 downto 2) when horizontalCounter <= horizontalVisibleLimit else
						  (others => '0');

-- Setting the vertical pixel coordinate used in the system
-- The vertical pixel coord is clamped in this way to make sure that the buffer loading system does not continue to load new layer lines
-- when they are not needed.
vertical_pixel_coord <= verticalCounter(9 downto 2) when verticalCounter <= verticalVisibleLimit else
						(others => '0');

-- Setting syncronization signals
Hsync <= '0' when ((horizontalCounter >= hsyncLowerLimit) AND (horizontalCounter < hsyncUpperLimit)) else
						  '1';
Vsync <= '0' when ((verticalCounter > vsyncLowerLimit) AND (verticalCounter <= vsyncUpperLimit)) else
						  '1';

vertical_blanking <= '1' when visible_region = '0' and verticalCounter > vsyncUpperLimit else
					 '0';

visible_region <= '1' when ((verticalCounter <= verticalVisibleLimit) AND (horizontalCounter <= horizontalVisibleLimit)) else
				  '0';

pixel_value <= pixel when visible_region = '1' else
						  (others => '0');

blank_s <= '0' when visible_region = '1' else
			'1';

blank <= blank_s;

RED <= pixel_value(7 downto 5);
GREEN <= pixel_value(4 downto 2);
BLUE <= pixel_value(1 downto 0);

end Behavioral;