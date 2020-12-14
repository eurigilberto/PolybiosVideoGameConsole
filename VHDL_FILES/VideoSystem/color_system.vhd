library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity color_system is
	port(
			horizontal_pixel_coordinates_signal: in std_logic_vector(7 downto 0);
			vertical_pixel_coordinates_signal: in std_logic_vector(8 downto 0);
			addrb_bg : out std_logic_vector(6 downto 0);
			addrb_fg : out std_logic_vector(6 downto 0);
			blank : in std_logic;
			port_block : in std_logic;
			doutb_buffer_bg : in std_logic_vector(31 downto 0);
			doutb_buffer_fg : in std_logic_vector(31 downto 0);
			sp_color_BG_LAYER : in std_logic_vector(7 downto 0);
			sp_color_FG_LAYER : in std_logic_vector(7 downto 0);
			color : out std_logic_vector(7 downto 0);
			transparent_color : in std_logic_vector(7 downto 0);
			
			colorPixelBorder : in std_logic_vector(7 downto 0)
		);
end color_system;

architecture Behavioral of color_system is

signal color_bg : std_logic_vector(7 downto 0) := (others => '0');
signal color_fg : std_logic_vector(7 downto 0) := (others => '0');

begin

addrb_bg <= port_block&horizontal_pixel_coordinates_signal(7 downto 2) when blank = '0' else
			port_block&"000000";
			
addrb_fg <= port_block&horizontal_pixel_coordinates_signal(7 downto 2) when blank = '0' else
			port_block&"000000";

--color_bg <= colorPixelBorder when (horizontal_pixel_coordinates_signal = "00000001" or horizontal_pixel_coordinates_signal = "00000000" or vertical_pixel_coordinates_signal = "000000000" or vertical_pixel_coordinates_signal = "010111111") else
--			sp_color_BG_LAYER when horizontal_pixel_coordinates_signal(1 downto 0) = "00" else
--			doutb_buffer_bg(31 downto 24) when horizontal_pixel_coordinates_signal(1 downto 0) = "01" else
--			doutb_buffer_bg(23 downto 16) when horizontal_pixel_coordinates_signal(1 downto 0) = "10" else
--			doutb_buffer_bg(15 downto 8) when horizontal_pixel_coordinates_signal(1 downto 0) = "11" else
--			"11100000";
			
color_fg <= colorPixelBorder when (vertical_pixel_coordinates_signal = "000000000" or vertical_pixel_coordinates_signal = "010111111") else
			sp_color_FG_LAYER when horizontal_pixel_coordinates_signal(1 downto 0) = "00" else
			doutb_buffer_fg(31 downto 24) when horizontal_pixel_coordinates_signal(1 downto 0) = "01" else
			doutb_buffer_fg(23 downto 16) when horizontal_pixel_coordinates_signal(1 downto 0) = "10" else
			doutb_buffer_fg(15 downto 8) when horizontal_pixel_coordinates_signal(1 downto 0) = "11" else
			"11100000";
			
color_bg <= sp_color_BG_LAYER when horizontal_pixel_coordinates_signal(1 downto 0) = "00" else
			doutb_buffer_bg(31 downto 24) when horizontal_pixel_coordinates_signal(1 downto 0) = "01" else
			doutb_buffer_bg(23 downto 16) when horizontal_pixel_coordinates_signal(1 downto 0) = "10" else
			doutb_buffer_bg(15 downto 8) when horizontal_pixel_coordinates_signal(1 downto 0) = "11" else
			"11100000";
--			
--color_fg <= sp_color_FG_LAYER when horizontal_pixel_coordinates_siganl(1 downto 0) = "00" else
--			doutb_buffer_fg(31 downto 24) when horizontal_pixel_coordinates_siganl(1 downto 0) = "01" else
--			doutb_buffer_fg(23 downto 16) when horizontal_pixel_coordinates_siganl(1 downto 0) = "10" else
--			doutb_buffer_fg(15 downto 8) when horizontal_pixel_coordinates_siganl(1 downto 0) = "11" else
--			"11100000";
			
color <= color_fg when color_fg /= transparent_color else
			color_bg;

end Behavioral;

