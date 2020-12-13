library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity special_color_buffer is
	port(
		video_clk : in std_logic;
		horizontal_pixel_coordinates : out std_logic_vector(7 downto 0);
		vertical_pixel_coordinates : out std_logic_vector(8 downto 0);
		
		horizontal_pixel_coord : in std_logic_vector(7 downto 0);
		vertical_pixel_coord : in std_logic_vector(8 downto 0);
		
		sp_color_BG_LAYER : out std_logic_vector(7 downto 0);
		sp_color_FG_LAYER : out std_logic_vector(7 downto 0);
		
		doutb_buffer_bg_o : out std_logic_vector(31 downto 0);
		doutb_buffer_fg_o : out std_logic_vector(31 downto 0);
		
		doutb_bg : in std_logic_vector(31 downto 0);
		doutb_fg : in std_logic_vector(31 downto 0)
	);
end special_color_buffer;

architecture Behavioral of special_color_buffer is

signal doutb_buffer_bg : std_logic_vector(31 downto 0) := (others => '0');
signal doutb_buffer_fg : std_logic_vector(31 downto 0) := (others => '0');

signal horizontal_pixel_coordinates_signal : std_logic_vector(7 downto 0) := (others => '0');
--signal vertical_pixel_coordinates_signal : std_logic_vector(8 downto 0) := (others => '0');

begin

horizontal_pixel_coordinates <= horizontal_pixel_coord;
vertical_pixel_coordinates <= vertical_pixel_coord;

doutb_buffer_bg_o <= doutb_buffer_bg;
doutb_buffer_fg_o <= doutb_buffer_fg;

process(video_clk)
begin
	if(rising_edge(video_clk))then
--		horizontal_pixel_coordinates_signal <= horizontal_pixel_coord;
--		vertical_pixel_coordinates_signal <= vertical_pixel_coord;
		doutb_buffer_bg <= doutb_bg;
		doutb_buffer_fg <= doutb_fg;
		if(horizontal_pixel_coord(1 downto 0) = "01") then
			sp_color_BG_LAYER <= doutb_buffer_bg(7 downto 0);
			sp_color_FG_LAYER <= doutb_buffer_fg(7 downto 0);
		end if;
	end if;
end process;

end Behavioral;

