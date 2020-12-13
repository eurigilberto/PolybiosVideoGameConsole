library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.numeric_std.ALL;

entity video_buffer_controller is
	port(
		clk : std_logic;
		system_loaded : std_logic;
		enable_load : out std_logic;
		
		finish_buffer : in std_logic;
		
		wea_load : in std_logic_vector(0 downto 0);
		addra_block_load : in STD_LOGIC_VECTOR(5 DOWNTO 0);
		dina_load : in STD_LOGIC_VECTOR(31 DOWNTO 0);
		
		wea_bg : out STD_LOGIC_VECTOR(0 DOWNTO 0);
		addra_block_bg : out STD_LOGIC_VECTOR(6 DOWNTO 0);
		dina_bg : out STD_LOGIC_VECTOR(31 DOWNTO 0);
		
		wea_fg : out STD_LOGIC_VECTOR(0 DOWNTO 0);
		addra_block_fg : out STD_LOGIC_VECTOR(6 DOWNTO 0);
		dina_fg : out STD_LOGIC_VECTOR(31 DOWNTO 0);
		
		base_layer_address_bg : in std_logic_vector(23 downto 0);
		horizontal_address_offset_bg : in std_logic_vector(6 downto 0);
		vertical_address_offset_bg : in std_logic_vector(8 downto 0);

		base_layer_address_fg : in std_logic_vector(23 downto 0);
		horizontal_address_offset_fg : in std_logic_vector(6 downto 0);
		vertical_address_offset_fg : in std_logic_vector(8 downto 0);

		base_layer_address : out std_logic_vector(23 downto 0);
		horizontal_address_offset : out std_logic_vector(6 downto 0);
		vertical_address_offset : out std_logic_vector(8 downto 0);
		
		vertical_pixel_coord : in std_logic_vector(8 downto 0);
		
		buffer_busy_signal : std_logic;
		
		loader_block_p : out std_logic;
		port_block_p : out std_logic;
		
		frame_counter : in std_logic_vector(7 downto 0);
		color_pixel_border_o : out std_logic_vector(7 downto 0)
	);
end video_buffer_controller;

architecture Behavioral of video_buffer_controller is

type buffer_states is (
								STATE_NOTHING,
								STATE_IDLE,
								STATE_LOAD_BUFFER,
								STATE_WAITING_LOAD_1,
								STATE_LOAD_BUFFER_2,
								STATE_WAITING_LOAD_2,
								STATE_DUMMY_STATE
								);
signal actual_state : buffer_states := STATE_NOTHING;
signal next_state : buffer_states := STATE_NOTHING;

signal 	loader_block : std_logic := '0';
signal	port_block : std_logic := '1';

constant	colorPixelBorder : std_logic_vector(7 downto 0) :="00011100";

signal	finish_buffer_flag : std_logic := '0';
signal	vertical_counter : std_logic_vector(8 downto 0) := (others => '0');
signal	last_vertical_counter : std_logic_vector(8 downto 0) := (others => '0');

begin

loader_block_p <= loader_block;
port_block_p <= port_block;
color_pixel_border_o <= colorPixelBorder;

process(clk)

begin

	if rising_edge(clk) then
		enable_load <= '0';

		wea_bg <= (others => '0');
		addra_block_bg <= (others => '0');
		dina_bg <= (others => '0');

		wea_fg <= (others => '0');
		addra_block_fg <= (others => '0');
		dina_fg <= (others => '0');
		case (actual_state) is
			when STATE_NOTHING =>
			
				if(system_loaded = '1') then
					actual_state <= STATE_IDLE;
				end if;
			
			when STATE_DUMMY_STATE =>
				actual_state <= next_state;
				
			when STATE_IDLE =>
				last_vertical_counter <= vertical_pixel_coord;
				if(vertical_pixel_coord /= last_vertical_counter)then
					loader_block <= not(loader_block);
					port_block <= not(port_block);
					finish_buffer_flag <= '1';
					actual_state <= STATE_LOAD_BUFFER;
					vertical_counter <= vertical_pixel_coord;
				end if;
				
			when STATE_LOAD_BUFFER =>
				
				enable_load <= '1';
				base_layer_address <= base_layer_address_bg;
				horizontal_address_offset <= horizontal_address_offset_bg;
				vertical_address_offset <= std_logic_vector(unsigned(vertical_address_offset_bg) + unsigned(vertical_counter));
				next_state <= STATE_WAITING_LOAD_1;
				actual_state <= STATE_DUMMY_STATE;
				
			when STATE_WAITING_LOAD_1 =>
			
				wea_bg <= wea_load;
				addra_block_bg <= loader_block&addra_block_load;
				dina_bg <= dina_load;
				if(buffer_busy_signal = '0')then
					actual_state <= STATE_LOAD_BUFFER_2;
				end if;
			when STATE_LOAD_BUFFER_2 =>
			
				enable_load <= '1';
				base_layer_address <= base_layer_address_fg;
				horizontal_address_offset <= horizontal_address_offset_fg;
				vertical_address_offset <= std_logic_vector(unsigned(vertical_address_offset_fg) + unsigned(vertical_counter));
				next_state <= STATE_WAITING_LOAD_2;
				actual_state <= STATE_DUMMY_STATE;
				
			when STATE_WAITING_LOAD_2 =>
			
				wea_fg <= wea_load;
				addra_block_fg <= loader_block&addra_block_load;
				dina_fg <= dina_load;
				if(buffer_busy_signal = '0')then
					actual_state <= STATE_IDLE;
				end if;
		end case;
	end if;

end process;

end Behavioral;

