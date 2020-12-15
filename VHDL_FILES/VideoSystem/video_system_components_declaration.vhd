library IEEE;
use IEEE.STD_LOGIC_1164.all;

library work;
use work.video_system_types.all;

package video_system_components_declaration is

COMPONENT video_buffer
  PORT (
    clka : IN STD_LOGIC;
    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addra : IN STD_LOGIC_VECTOR(6 DOWNTO 0);
    dina : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    clkb : IN STD_LOGIC;
    web : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addrb : IN STD_LOGIC_VECTOR(6 DOWNTO 0);
    dinb : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    doutb : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
  );
END COMPONENT;

component video_system_info
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
end component;

component layer_configuration_system
	port(
		clk : in std_logic;
		cmd_in: in std_logic_vector(3 downto 0);
      data_in: in std_logic_vector(23 downto 0);
		input_enable : in std_logic;
		layer_index: in std_logic_vector(1 downto 0);
		layer_address_out: out std_logic_vector(23 downto 0);
		horizontal_address_offset_out: out std_logic_vector(6 downto 0);
		vertical_address_offset_out: out std_logic_vector(7 downto 0);
		transparent_color_out: out video_layers_transparent_color
	);
end component;

component pixel_getter
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
end component;

component video_buffer_controller
	port(
		clk : std_logic;
		system_loaded : std_logic;
		enable_load : out std_logic;
		finish_buffer : in std_logic;
		write_enable_a_video_layers: out std_logic_vector(3 downto 0);
		address_a_video_layers: out video_layers_buffer_address;
		data_in_a_video_layers: out video_layers_buffer_data;
		layer_selector: out std_logic_vector(1 downto 0);
		layer_address_selected_layer: in std_logic_vector(23 downto 0);
		horizontal_address_offset_selected_layer: in std_logic_vector(6 downto 0);
		vertical_address_offset_selected_layer: in std_logic_vector(7 downto 0);
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
end component;

component load_buffer_system
	port(
		clk : in std_logic;
		enable : in std_logic;
		start_system : in std_logic;
		base_layer_address : in std_logic_vector(23 downto 0);
		horizontal_address_offset : in std_logic_vector(6 downto 0);
		vertical_address_offset: in std_logic_vector(7 downto 0);
		--buffer stuff
		wea : out STD_LOGIC_VECTOR(0 DOWNTO 0);
		addra_block : out STD_LOGIC_VECTOR(5 DOWNTO 0);
		dina : out STD_LOGIC_VECTOR(31 DOWNTO 0);
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
		c3_p3_rd_error : in  STD_LOGIC;
		busy : out std_logic
	);
end component;

component video_port
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
		finish_buffer : out std_logic;
		finish_frame : out std_logic
	);
end component;

end video_system_components_declaration;

package body video_system_components_declaration is
 
end video_system_components_declaration;
