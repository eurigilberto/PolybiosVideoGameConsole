library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

library work;
use work.video_system_types.all;

entity video_buffer_controller is
	port(
		clk : std_logic;
		system_loaded : std_logic;
		enable_load : out std_logic;
		
		write_enable_a_video_layers: out std_logic_vector(3 downto 0);
		address_a_video_layers: out video_layers_buffer_address;
		data_in_a_video_layers: out video_layers_buffer_data;

		video_layers_address: 					in video_layers_address;
		video_layers_horizontal_address_offset: in video_layers_horizontal_address_offset;
		video_layers_vertical_address_offset: 	in video_layers_vertical_address_offset;

		--This comes from the buffer loader
		wea_load : in std_logic_vector(0 downto 0);
		addra_block_load : in STD_LOGIC_VECTOR(5 DOWNTO 0);
		dina_load : in STD_LOGIC_VECTOR(31 DOWNTO 0);

		--This goes directly to the buffer loader
		base_layer_address : out std_logic_vector(23 downto 0);
		horizontal_address_offset : out std_logic_vector(6 downto 0);
		vertical_address_offset : out std_logic_vector(7 downto 0);
		
		vertical_pixel_coord : in std_logic_vector(7 downto 0);
		buffer_busy_signal : in std_logic;
		port_block_p : out std_logic
	);
end video_buffer_controller;

architecture Behavioral of video_buffer_controller is

type buffer_states is (
	STATE_WATING_SYSTEM_LOAD,
	STATE_IDLE,
	STATE_INITIALIZE_BUFFER_LOAD,
	STATE_WAIT_LOAD_START,
	STATE_LOAD_NEXT_BUFFER,
	STATE_WAIT_BUFFER_LOAD
);

signal actual_state : buffer_states := STATE_WATING_SYSTEM_LOAD;

signal loader_block : std_logic := '0';

signal last_vertical_counter : std_logic_vector(7 downto 0) := (others => '0');

--Video layers signals
signal current_buffer : unsigned(1 downto 0) := "00";
signal write_enabled_a : std_logic := '0';
signal address_a : std_logic_vector(5 downto 0) := (others => '0');
signal data_in_a : std_logic_vector(31 downto 0) := (others => '0');

signal pass_data : std_logic := '0';

signal enable_load_s : std_logic := '0';
signal base_layer_address_s : std_logic_vector(23 downto 0) := (others => '0');
signal horizontal_address_offset_s : std_logic_vector(6 downto 0) := (others => '0');
signal vertical_address_offset_s : std_logic_vector(7 downto 0) := (others => '0');
begin

enable_load <= enable_load_s;
base_layer_address <= base_layer_address_s;
horizontal_address_offset <= horizontal_address_offset_s;
vertical_address_offset <= vertical_address_offset_s;

--The block the system is going to use to show the pixels on screen
port_block_p <= not(loader_block);

--Sets the write enable for port A on the different video layers
write_enable_a_video_layers(0) <= write_enabled_a when current_buffer = "00" else
								  '0';
write_enable_a_video_layers(1) <= write_enabled_a when current_buffer = "01" else
								  '0';
write_enable_a_video_layers(2) <= write_enabled_a when current_buffer = "10" else
								  '0';
write_enable_a_video_layers(3) <= write_enabled_a when current_buffer = "11" else
								  '0';

--Sets the address for port A on the different video layers
address_a_video_layers(0) <= loader_block & address_a when current_buffer = "00" else
							 (others => '0');
address_a_video_layers(1) <= loader_block & address_a when current_buffer = "01" else
							 (others => '0');
address_a_video_layers(2) <= loader_block & address_a when current_buffer = "10" else
							 (others => '0');
address_a_video_layers(3) <= loader_block & address_a when current_buffer = "11" else
							 (others => '0');

--Sets the data in for port A on the different video layers
data_in_a_video_layers(0) <= data_in_a when current_buffer = "00" else
							 (others => '0');
data_in_a_video_layers(1) <= data_in_a when current_buffer = "01" else
							 (others => '0');
data_in_a_video_layers(2) <= data_in_a when current_buffer = "10" else
							 (others => '0');
data_in_a_video_layers(3) <= data_in_a when current_buffer = "11" else
							 (others => '0');

--Passing the data that came from the buffer loader to the currently selected layer 
write_enabled_a <= wea_load(0) when pass_data = '1' else
						'0';
				
address_a <= addra_block_load when pass_data = '1' else
				(others => '0');

data_in_a <= dina_load when pass_data = '1' else
				 (others => '0');

process(clk)
variable current_index: integer := 0;
begin

	if(rising_edge(clk)) then
		enable_load_s <= '0';
		case (actual_state) is
			when STATE_WATING_SYSTEM_LOAD =>
				if(system_loaded = '1') then
					actual_state <= STATE_IDLE;
				end if;
			when STATE_IDLE =>
				--Wait for the system to end displaying the current line to start loading the next one
				--This assumes the system was able to load every buffer before the current vertical line finished showing
				
				last_vertical_counter <= vertical_pixel_coord;
				if(vertical_pixel_coord /= last_vertical_counter)then
					--The block of the buffer that the loader is going to load the data on
					loader_block <= not(loader_block);
					actual_state <= STATE_INITIALIZE_BUFFER_LOAD;
					current_buffer <= "00";
				end if;
			when STATE_INITIALIZE_BUFFER_LOAD =>
				enable_load_s <= '1';
				current_index := to_integer(current_buffer);

				--Passing to the buffer loading system the data it needs to start the loading process
				base_layer_address_s <= video_layers_address(current_index);
				horizontal_address_offset_s <= video_layers_horizontal_address_offset(current_index);
				vertical_address_offset_s <= std_logic_vector(unsigned(video_layers_vertical_address_offset(current_index)) + unsigned(last_vertical_counter));

				pass_data <= '1';

				actual_state <= STATE_WAIT_LOAD_START;
			when STATE_WAIT_LOAD_START => 
				
				--If the buffer signal is 1 then it means the load started
				if(buffer_busy_signal = '1')then
					actual_state <= STATE_WAIT_BUFFER_LOAD;
				end if;

			when STATE_WAIT_BUFFER_LOAD =>

				--If the buffer stoped working then it means that the load was completed
				if(buffer_busy_signal = '0')then
					--Sending the system to change the layer selector to load the next layer 
					actual_state <= STATE_LOAD_NEXT_BUFFER;
				end if;

			when STATE_LOAD_NEXT_BUFFER =>
				pass_data <= '0';
				--If the currently selected buffer is the 4th one then go to idle
				if(current_buffer = "11") then
					actual_state <= STATE_IDLE;
					current_buffer <= "00";
				else
					current_buffer <= current_buffer + 1;
					actual_state <= STATE_INITIALIZE_BUFFER_LOAD;
				end if;
		end case;
	end if;

end process;

end Behavioral;

