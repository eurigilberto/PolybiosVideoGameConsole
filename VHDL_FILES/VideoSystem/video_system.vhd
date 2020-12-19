library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.numeric_std.ALL;

library work;
use work.video_system_types.all;
use work.video_system_components_declaration.all;

entity VideoSystem is

	port(
		video_clock_2x : in std_logic;
		
		video_clk : in std_logic;
		
		HSync : out std_logic;
		VSync : out std_logic;
		Red : out std_logic_vector(2 downto 0);
		Green : out std_logic_vector(2 downto 0);
		Blue : out std_logic_vector(1 downto 0);
		
		system_loaded : in std_logic;

		--GET VIDEO INFO
		video_info_data_out : out std_logic_vector(23 downto 0);
		video_info_cmd: in std_logic_vector(1 downto 0);

		--SET VIDEO LAYERS DATA
		video_layers_data_in: in std_logic_vector(23 downto 0);
		video_layers_cmd: in std_logic_vector(3 downto 0);
		video_layers_input_enabled: in std_logic;
		
		--CMD
		c3_p3_cmd_clk : out  STD_LOGIC;
		c3_p3_cmd_en : out  STD_LOGIC;
		c3_p3_cmd_instr : out  STD_LOGIC_VECTOR (2 downto 0);
		c3_p3_cmd_bl : out  STD_LOGIC_VECTOR (5 downto 0);
		c3_p3_cmd_byte_addr : out  STD_LOGIC_VECTOR (29 downto 0);
		c3_p3_cmd_empty : in  STD_LOGIC;
		c3_p3_cmd_full : in  STD_LOGIC;
			
		--READ
		c3_p3_rd_clk : out  STD_LOGIC;
		c3_p3_rd_en : out  STD_LOGIC;
		c3_p3_rd_data : in  STD_LOGIC_VECTOR (31 downto 0);
		c3_p3_rd_full : in  STD_LOGIC;
		c3_p3_rd_empty : in  STD_LOGIC;
		c3_p3_rd_count : in  std_logic_vector(6 downto 0);
		c3_p3_rd_overflow : in  STD_LOGIC;
		c3_p3_rd_error : in  STD_LOGIC
	);

end VideoSystem;

architecture Behavioral of VideoSystem is

--video loader
signal	base_layer_address : std_logic_vector(23 downto 0);
signal	horizontal_address_offset : std_logic_vector(6 downto 0);
signal	vertical_address_offset : std_logic_vector(7 downto 0);

signal	wea_load : std_logic_vector(0 downto 0);
signal	addra_block_load : STD_LOGIC_VECTOR(5 DOWNTO 0);
signal 	dina_load : STD_LOGIC_VECTOR(31 DOWNTO 0);
--video loader

--This is the bit that tells the system which part of the line buffer it should show on the screen
signal	port_block : std_logic;

--video port
signal 	horizontal_pixel_coord: std_logic_vector(7 downto 0);
signal	vertical_pixel_coord: std_logic_vector(7 downto 0);
signal 	color : std_logic_vector(7 downto 0);
signal 	blank : std_logic;
--video port


signal 	buffer_busy_signal : std_logic;

signal 	enable_load : std_logic;
signal	finish_frame : std_logic;

signal	frame_counter : std_logic_vector(23 downto 0);
signal	video_clock_2x_neg : std_logic;

--Video Layer Buffer signals
signal write_enable_a_video_layers : std_logic_vector(3 downto 0) := (others => '0');
signal address_a_video_layers : video_layers_buffer_address := (others => (others => '0'));
signal data_in_a_video_layers : video_layers_buffer_data := (others => (others => '0'));

signal address_b_video_layers : video_layers_buffer_address := (others => (others => '0'));
signal data_out_b_video_layers : video_layers_buffer_data := (others => (others => '0'));

--Layer Info signals
signal video_layers_address: video_layers_address;
signal video_layers_horizontal_address_offset: video_layers_horizontal_address_offset;
signal video_layers_vertical_address_offset: video_layers_vertical_address_offset;

signal layers_transparency_color : video_layers_transparent_color := (others => (others => '0'));

--pixel that is going to appear on screen
signal pixel : std_logic_vector(7 downto 0);

signal vertical_blanking : std_logic;

begin

video_clock_2x_neg <= not(video_clock_2x);


video_system_info_inst: video_system_info

	port map(
		clk => video_clock_2x,
		system_loaded => system_loaded,
		finish_frame => finish_frame,

		data_out => video_info_data_out,
		cmd => video_info_cmd,

		horizontal_pixel_coordinates_signal => horizontal_pixel_coord,
		vertical_pixel_coordinates_signal => vertical_pixel_coord,
		vertical_blanking => vertical_blanking
	);

layer_configuration_system_inst: layer_configuration_system

	port map(
		clk => video_clock_2x,
		
		cmd_in => video_layers_cmd,
		data_in => video_layers_data_in,
		input_enable => video_layers_input_enabled,

		video_layers_address_out => video_layers_address,
		video_layers_horizontal_address_offset_out => video_layers_horizontal_address_offset,
		video_layers_vertical_address_offset_out => video_layers_vertical_address_offset,
		transparent_color_out=> layers_transparency_color
	);

pixel_getter_inst: pixel_getter
	port map(
			clk => video_clk,

			layers_transparent_color => layers_transparency_color,

			horizontal_pixel_coordinates_signal => horizontal_pixel_coord,
			vertical_pixel_coordinates_signal => vertical_pixel_coord,

			address_b_video_layers => address_b_video_layers,
			port_block => port_block,
			data_out_b_video_layers => data_out_b_video_layers,

			blank => blank,
			pixel => pixel
		);
			
video_buffer_controller_inst: video_buffer_controller
	port map(
		clk => video_clock_2x,
		system_loaded => system_loaded,
		enable_load => enable_load,
		
		write_enable_a_video_layers => write_enable_a_video_layers,
		address_a_video_layers => address_a_video_layers,
		data_in_a_video_layers => data_in_a_video_layers,

		video_layers_address => video_layers_address,
		video_layers_horizontal_address_offset => video_layers_horizontal_address_offset,
		video_layers_vertical_address_offset => video_layers_vertical_address_offset,

		wea_load => wea_load,
		addra_block_load => addra_block_load,
		dina_load => dina_load,

		base_layer_address => base_layer_address,
		horizontal_address_offset => horizontal_address_offset,
		vertical_address_offset => vertical_address_offset,
		
		vertical_pixel_coord => vertical_pixel_coord,
		buffer_busy_signal => buffer_busy_signal,
		port_block_p => port_block
	);

load_buffer_system_inst : load_buffer_system

	port map(
		clk => video_clock_2x_neg,
		
		enable => enable_load,
		
		wea => wea_load,
		addra_block => addra_block_load,
		dina => dina_load,
	
		start_system => system_loaded,
		
		base_layer_address => base_layer_address,
		horizontal_address_offset => horizontal_address_offset,
		vertical_address_offset => vertical_address_offset,
	
		--CMD
		c3_p3_cmd_clk => c3_p3_cmd_clk,
		c3_p3_cmd_en => c3_p3_cmd_en,
 		c3_p3_cmd_instr => c3_p3_cmd_instr,
		c3_p3_cmd_bl => c3_p3_cmd_bl,
		c3_p3_cmd_byte_addr => c3_p3_cmd_byte_addr,
		c3_p3_cmd_empty => c3_p3_cmd_empty,
		c3_p3_cmd_full => c3_p3_cmd_full,
			
		--READ
		c3_p3_rd_clk => c3_p3_rd_clk,
		c3_p3_rd_en => c3_p3_rd_en,
		c3_p3_rd_data => c3_p3_rd_data,
		c3_p3_rd_full => c3_p3_rd_full,
		c3_p3_rd_empty => c3_p3_rd_empty,
		c3_p3_rd_count => c3_p3_rd_count,
		c3_p3_rd_overflow => c3_p3_rd_overflow,
		c3_p3_rd_error => c3_p3_rd_error,
		
		busy => buffer_busy_signal
	);

video_port_inst : video_port

   port map(
		clk => video_clk,
		pixel => pixel,
		HSync => HSync,
		VSync => VSync, 
		Red => Red,
		Green => Green,
		Blue => Blue,
		horizontal_pixel_coord => horizontal_pixel_coord,
		vertical_pixel_coord => vertical_pixel_coord,
		blank => blank,
		finish_frame => finish_frame,
		vertical_blanking => vertical_blanking
	);

video_buffer_0 : video_buffer

PORT MAP (
clka => video_clock_2x,

wea(0) => write_enable_a_video_layers(0),
addra => address_a_video_layers(0),
dina => data_in_a_video_layers(0),
douta => open,

clkb => video_clock_2x_neg,

web => "0",
addrb => address_b_video_layers(0),
dinb => (others => '0'),
doutb => data_out_b_video_layers(0)
);

video_buffer_1 : video_buffer

PORT MAP (
clka => video_clock_2x,

wea(0) => write_enable_a_video_layers(1),
addra => address_a_video_layers(1),
dina => data_in_a_video_layers(1),
douta => open,

clkb => video_clock_2x_neg,

web => "0",
addrb => address_b_video_layers(1),
dinb => (others => '0'),
doutb => data_out_b_video_layers(1)
);

video_buffer_2 : video_buffer

PORT MAP (
clka => video_clock_2x,

wea(0) => write_enable_a_video_layers(2),
addra => address_a_video_layers(2),
dina => data_in_a_video_layers(2),
douta => open,

clkb => video_clock_2x_neg,

web => "0",
addrb => address_b_video_layers(2),
dinb => (others => '0'),
doutb => data_out_b_video_layers(2)
);

video_buffer_3 : video_buffer

PORT MAP (
clka => video_clock_2x,

wea(0) => write_enable_a_video_layers(3),
addra => address_a_video_layers(3),
dina => data_in_a_video_layers(3),
douta => open,

clkb => video_clock_2x_neg,

web => "0",
addrb => address_b_video_layers(3),
dinb => (others => '0'),
doutb => data_out_b_video_layers(3)
);

end Behavioral;