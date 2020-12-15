library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity video_system_info is

	port(
		clk : in std_logic;
		system_loaded : in std_logic;
		finish_frame : in std_logic;
		
		data_out : out std_logic_vector(23 downto 0);
		cmd : in std_logic_vector(1 downto 0);

		horizontal_pixel_coordinates_signal : in std_logic_vector(7 downto 0);
		vertical_pixel_coordinates_signal : in std_logic_vector(7 downto 0);
		
		frame_counter_o : out std_logic_vector(23 downto 0)
	);

end video_system_info;

architecture Behavioral of video_system_info is

signal startCounting : std_logic := '0';
signal finish_frame_flag : std_logic := '0';
signal frame_counter : std_logic_vector(23 downto 0) := (others => '0');

begin

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
		case cmd is
			when "00" =>
				data_out <= frame_counter;
			when "01" =>
				data_out <= "0000000000000000"&horizontal_pixel_coordinates_signal;
			when "10" =>
				data_out <= "0000000000000000"&vertical_pixel_coordinates_signal;
			when others =>
				data_out <= (others => '0');
		end case;
	end if;
end process;

end Behavioral;

