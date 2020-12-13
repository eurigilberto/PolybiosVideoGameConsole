library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity process_register_system is

	port(
		clk : in std_logic;
		system_loaded : in std_logic;
		finish_frame : in std_logic;
		
		base_layer_address_bg_s : out std_logic_vector(23 downto 0);
		base_layer_address_fg_s : out std_logic_vector(23 downto 0);
		horizontal_address_offset_bg_s : out std_logic_vector(6 downto 0);
		horizontal_address_offset_fg_s : out std_logic_vector(6 downto 0);
		vertical_address_offset_bg_s : out std_logic_vector(8 downto 0);
		vertical_address_offset_fg_s : out std_logic_vector(8 downto 0);
		transparent_color_s : out std_logic_vector(7 downto 0);
		transparent_color_sp_s : out std_logic_vector(7 downto 0);
		transparent_color_tx_s : out std_logic_vector(7 downto 0);
		
		horizontal_pixel_coordinates_signal : in std_logic_vector(7 downto 0);
		vertical_pixel_coordinates_signal : in std_logic_vector(8 downto 0);
		
		data_in : in std_logic_vector(23 downto 0);
		data_out : out std_logic_vector(23 downto 0);
		
		cmd_input : in std_logic_vector(3 downto 0);
		cmd_output : in std_logic_vector(3 downto 0);
		input_enable : in std_logic;
		
		frame_counter_o : out std_logic_vector(23 downto 0)
	);

end process_register_system;

architecture Behavioral of process_register_system is

signal startCounting : std_logic := '0';
signal finish_frame_flag : std_logic := '0';
signal frame_counter : std_logic_vector(23 downto 0) := (others => '0');

signal base_layer_address_bg : std_logic_vector(23 downto 0) := (others => '0');
signal base_layer_address_fg : std_logic_vector(23 downto 0) := (others => '0');
signal horizontal_address_offset_bg : std_logic_vector(6 downto 0) := (others => '0');
signal horizontal_address_offset_fg : std_logic_vector(6 downto 0) := (others => '0');
signal vertical_address_offset_bg : std_logic_vector(8 downto 0) := (others => '0');
signal vertical_address_offset_fg : std_logic_vector(8 downto 0) := (others => '0');
signal transparent_color : std_logic_vector(7 downto 0) := (others => '0');
signal transparent_color_sp : std_logic_vector(7 downto 0) := (others => '0');
signal transparent_color_tx : std_logic_vector(7 downto 0) := (others => '0');

begin

base_layer_address_bg_s <= base_layer_address_bg;
base_layer_address_fg_s <= base_layer_address_fg;
horizontal_address_offset_bg_s <= horizontal_address_offset_bg;
horizontal_address_offset_fg_s <= horizontal_address_offset_fg;
vertical_address_offset_bg_s <= vertical_address_offset_bg;
vertical_address_offset_fg_s <= vertical_address_offset_fg;
transparent_color_s <= transparent_color;
transparent_color_sp_s <= transparent_color_sp;
transparent_color_tx_s <= transparent_color_tx;

frame_counter_o <= frame_counter;

process(clk)
begin
	if(rising_edge(clk)) then
		if(system_loaded = '1') then
			startCounting <= '1';
		end if;
		
		if(startCounting = '1') then
			if(finish_frame_flag = '0' and finish_frame = '1')then
				frame_counter <= std_logic_vector(unsigned(frame_counter) + 1);
				finish_frame_flag <= '1';
			elsif(finish_frame = '0') then
				finish_frame_flag <= '0';
			end if;
		else
			frame_counter <= (others => '0');
		end if;
	end if;
end process;

process(clk)
begin
	if(rising_edge(clk)) then
		if(input_enable = '1') then
			--Use the current command inputs to create 2 more layers
			case cmd_input is
				when "0000" =>
					base_layer_address_bg <= data_in;
				when "0001" =>
					base_layer_address_fg <= data_in;
				when "0010" =>
					horizontal_address_offset_bg <= data_in(6 downto 0);
				when "0011" =>
					horizontal_address_offset_fg <= data_in(6 downto 0);
				when "0100" =>
					vertical_address_offset_bg <= data_in(8 downto 0);
				when "0101" =>
					vertical_address_offset_fg <= data_in(8 downto 0);
				when "0110" =>
					transparent_color <= data_in(7 downto 0);
				when "0111" =>
					transparent_color_sp <= data_in(7 downto 0);
				when others =>
					transparent_color_tx <= data_in(7 downto 0);
			end case;
		end if;
		case cmd_output is
			when "0000" =>
				data_out <= base_layer_address_bg;
			when "0001" =>
				data_out <= base_layer_address_fg;
			when "0010" =>
				data_out <= "00000000000000000"&horizontal_address_offset_bg;
			when "0011" =>
				data_out <= "00000000000000000"&horizontal_address_offset_fg;
			when "0100" =>
				data_out <= "000000000000000"&vertical_address_offset_bg;
			when "0101" =>
				data_out <= "000000000000000"&vertical_address_offset_fg;
			when "0110" =>
				data_out <= "0000000000000000"&transparent_color;
			when "0111" =>
				data_out <= "0000000000000000"&transparent_color_sp;
			when "1000" =>
				data_out <= "0000000000000000"&transparent_color_tx;
			when "1001" =>
				data_out <= frame_counter;
			when "1010" =>
				data_out <= "0000000000000000"&horizontal_pixel_coordinates_signal;
			when others =>
				data_out <= "000000000000000"&vertical_pixel_coordinates_signal;
		end case;
	end if;
end process;

end Behavioral;

