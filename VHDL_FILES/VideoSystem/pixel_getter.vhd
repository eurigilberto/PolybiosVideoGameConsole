library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

library work;
use work.video_system_types.all;

entity pixel_getter is
	port(
			clk: in std_logic;

			layers_transparent_color: in video_layers_transparent_color;

			horizontal_pixel_coordinates_signal: in std_logic_vector(7 downto 0);
			vertical_pixel_coordinates_signal: in std_logic_vector(7 downto 0);

			address_b_video_layers : out video_layers_buffer_address;
			port_block : in std_logic;

			data_out_b_video_layers : in video_layers_buffer_data;

			blank : in std_logic;
			
			pixel : out std_logic_vector(7 downto 0)
		);
end pixel_getter;

architecture Behavioral of pixel_getter is

type video_layers_pixels is array (3 downto 0) of std_logic_vector(7 downto 0);
signal pixels : video_layers_pixels;
signal saved_pixels : video_layers_pixels;
signal blended_pixel : std_logic_vector(7 downto 0);

signal address_b_video_layer_signal : std_logic_vector(6 downto 0) := (others => '0');

begin

address_b_video_layer_signal <= std_logic_vector(unsigned(port_block&horizontal_pixel_coordinates_signal(7 downto 2)) + 1) when horizontal_pixel_coordinates_signal(1 downto 0) = "11" else
								port_block&horizontal_pixel_coordinates_signal(7 downto 2) when blank = '0' else
								port_block&"000000";

address_b_video_layers(0) <= address_b_video_layer_signal;

address_b_video_layers(1) <= address_b_video_layer_signal;

address_b_video_layers(2) <= address_b_video_layer_signal;

address_b_video_layers(3) <= address_b_video_layer_signal;

blended_pixel <= 	pixels(3) when pixels(3) /= layers_transparent_color(3) else
						pixels(2) when pixels(2) /= layers_transparent_color(2) else
						pixels(1) when pixels(1) /= layers_transparent_color(1) else
						pixels(0) when pixels(0) /= layers_transparent_color(0) else
						(others => '0');

pixel <= "00011100" when (vertical_pixel_coordinates_signal = "00000000" or vertical_pixel_coordinates_signal = "10111111") else
			 blended_pixel;

process(clk)
begin

	if(rising_edge(clk)) then
		
		if(horizontal_pixel_coordinates_signal(1 downto 0) = "01") then
			saved_pixels(0) <= data_out_b_video_layers(0)(7 downto 0);
			saved_pixels(1) <= data_out_b_video_layers(1)(7 downto 0);
			saved_pixels(2) <= data_out_b_video_layers(2)(7 downto 0);
			saved_pixels(3) <= data_out_b_video_layers(3)(7 downto 0);
		end if;
	end if;

end process;

process(clk)
begin
	if(rising_edge(clk)) then
		case (horizontal_pixel_coordinates_signal(1 downto 0)) is
			when "00" => 
				pixels(0) <= data_out_b_video_layers(0)(31 downto 24);
				pixels(1) <= data_out_b_video_layers(1)(31 downto 24);
				pixels(2) <= data_out_b_video_layers(2)(31 downto 24);
				pixels(3) <= data_out_b_video_layers(3)(31 downto 24);
			when "01" =>
				pixels(0) <= data_out_b_video_layers(0)(23 downto 16);
				pixels(1) <= data_out_b_video_layers(1)(23 downto 16);
				pixels(2) <= data_out_b_video_layers(2)(23 downto 16);
				pixels(3) <= data_out_b_video_layers(3)(23 downto 16);
			when "10" =>
				pixels(0) <= data_out_b_video_layers(0)(15 downto 8);
				pixels(1) <= data_out_b_video_layers(1)(15 downto 8);
				pixels(2) <= data_out_b_video_layers(2)(15 downto 8);
				pixels(3) <= data_out_b_video_layers(3)(15 downto 8);
			when "11" =>
				pixels(0) <= saved_pixels(0);
				pixels(1) <= saved_pixels(1);
				pixels(2) <= saved_pixels(2);
				pixels(3) <= saved_pixels(3);
			when others =>
				pixels(0) <= "11100000";
				pixels(1) <= "11100000";
				pixels(2) <= "11100000";
				pixels(3) <= "11100000";
		end case;
	end if;
end process;

end Behavioral;

