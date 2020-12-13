library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.numeric_std.ALL;

entity VideoSystem is

	port(
		clk : in std_logic;
		
		video_clk : in std_logic;
		
		HSync : out std_logic;
		VSync : out std_logic;
		Red : out std_logic_vector(2 downto 0);
		Green : out std_logic_vector(2 downto 0);
		Blue : out std_logic_vector(1 downto 0);
		
		system_loaded : in std_logic;

		--CHANGE INTERNAL REGISTERS
		data_out : out std_logic_vector(23 downto 0);
		data_in : in std_logic_vector(23 downto 0);
		cmd_input : in std_logic_vector(3 downto 0);
		cmd_output : in std_logic_vector(3 downto 0);
		input_enable : in std_logic;
		--CHANGE INTERNAL REGISTERS
		
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

component neg
    Port ( input : in  STD_LOGIC;
           output : out  STD_LOGIC);
end component;

component process_register_system

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

end component;

component special_color_buffer is
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
end component;

component load_buffer_system

	port(
		clk : in std_logic;
		
		enable : in std_logic;
	
		start_system : in std_logic;
		
		base_layer_address : in std_logic_vector(23 downto 0);
		horizontal_address_offset : in std_logic_vector(6 downto 0);
		vertical_address_offset : in std_logic_vector(8 downto 0);
		
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

component videoPort is

	port(
		clk : in std_logic;
		color : in std_logic_vector(7 downto 0);
		HSync : out std_logic;
		VSync : out std_logic;
		Red : out std_logic_vector(2 downto 0);
		Green : out std_logic_vector(2 downto 0);
		Blue : out std_logic_vector(1 downto 0);
		horizontal_pixel_coord: out std_logic_vector(7 downto 0);
		vertical_pixel_coord: out std_logic_vector(8 downto 0);
		blank : out std_logic;
		finish_buffer : out std_logic;
		finish_frame : out std_logic
	);

end component;

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

COMPONENT video_buffer_controller
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
end COMPONENT;

COMPONENT color_system
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
end COMPONENT;

--video buffer
signal	wea_bg : STD_LOGIC_VECTOR(0 DOWNTO 0);
signal	addra_block_bg : STD_LOGIC_VECTOR(6 DOWNTO 0);
signal	dina_bg : STD_LOGIC_VECTOR(31 DOWNTO 0);
--signal	douta_bg : STD_LOGIC_VECTOR(31 DOWNTO 0):= (others => '0');
signal	addrb_bg : STD_LOGIC_VECTOR(6 DOWNTO 0);
signal	doutb_bg : STD_LOGIC_VECTOR(31 DOWNTO 0);
signal	doutb_buffer_bg : STD_LOGIC_VECTOR(31 DOWNTO 0);

signal	wea_fg : STD_LOGIC_VECTOR(0 DOWNTO 0);
signal	addra_block_fg : STD_LOGIC_VECTOR(6 DOWNTO 0);
signal	dina_fg : STD_LOGIC_VECTOR(31 DOWNTO 0);
--signal	douta_fg : STD_LOGIC_VECTOR(31 DOWNTO 0):= (others => '0');
signal	addrb_fg : STD_LOGIC_VECTOR(6 DOWNTO 0);
signal	doutb_fg : STD_LOGIC_VECTOR(31 DOWNTO 0);
signal	doutb_buffer_fg : STD_LOGIC_VECTOR(31 DOWNTO 0);
--video buffer

--video loader
signal   base_layer_address_bg : std_logic_vector(23 downto 0);
signal 	horizontal_address_offset_bg : std_logic_vector(6 downto 0);
signal 	vertical_address_offset_bg : std_logic_vector(8 downto 0);

signal   base_layer_address_fg : std_logic_vector(23 downto 0);
signal 	horizontal_address_offset_fg : std_logic_vector(6 downto 0);
signal 	vertical_address_offset_fg : std_logic_vector(8 downto 0);

signal	base_layer_address : std_logic_vector(23 downto 0);
signal	horizontal_address_offset : std_logic_vector(6 downto 0);
signal	vertical_address_offset : std_logic_vector(8 downto 0);

signal	sp_color_BG_LAYER : std_logic_vector(7 downto 0);
signal	sp_color_FG_LAYER : std_logic_vector(7 downto 0);

signal 	color_bg : std_logic_vector(7 downto 0);
signal 	color_fg : std_logic_vector(7 downto 0);

signal	wea_load : std_logic_vector(0 downto 0);
signal	addra_block_load : STD_LOGIC_VECTOR(5 DOWNTO 0);
signal 	dina_load : STD_LOGIC_VECTOR(31 DOWNTO 0);
--video loader

signal 	loader_block : std_logic;
signal	port_block : std_logic;

constant horizontal_size : std_logic_vector(6 downto 0) := "1000100";
constant vertical_size : std_logic_vector(7 downto 0) := "11010000";

--video port
signal 	horizontal_pixel_coord: std_logic_vector(7 downto 0);
signal	vertical_pixel_coord: std_logic_vector(8 downto 0);
signal 	color : std_logic_vector(7 downto 0);
signal 	blank : std_logic;
signal	finish_buffer : std_logic;
--video port


signal 	buffer_busy_signal : std_logic;

signal 	enable_load : std_logic;

signal 	colorPixelBorder : std_logic_vector(7 downto 0);

signal	finish_frame : std_logic;

signal	horizontal_pixel_coordinates_signal : std_logic_vector(7 downto 0);
signal	vertical_pixel_coordinates_signal : std_logic_vector(8 downto 0);

signal	transparent_color : std_logic_vector(7 downto 0);
signal	transparent_color_sp : std_logic_vector(7 downto 0);
signal	transparent_color_tx : std_logic_vector(7 downto 0);

signal	startCounting : std_logic := '0';

signal	frame_counter : std_logic_vector(23 downto 0);

signal	clk_neg : std_logic;

begin

process_register_system_inst: process_register_system

	port map(
		clk => clk,
		system_loaded => system_loaded,
		finish_frame => finish_frame,
		
		base_layer_address_bg_s => base_layer_address_bg,
		base_layer_address_fg_s => base_layer_address_fg,
		horizontal_address_offset_bg_s => horizontal_address_offset_bg,
		horizontal_address_offset_fg_s => horizontal_address_offset_fg,
		vertical_address_offset_bg_s => vertical_address_offset_bg,
		vertical_address_offset_fg_s => vertical_address_offset_fg,
		transparent_color_s => transparent_color,
		transparent_color_sp_s => transparent_color_sp,
		transparent_color_tx_s => transparent_color_tx,
		
		horizontal_pixel_coordinates_signal => horizontal_pixel_coordinates_signal,
		vertical_pixel_coordinates_signal => vertical_pixel_coordinates_signal,
		
		data_in => data_in,
		data_out => data_out,
		
		cmd_input => cmd_input,
		cmd_output => cmd_output,
		input_enable => input_enable,
		
		frame_counter_o => frame_counter
	);

neg_inst : neg
    Port map ( input => clk,
           output => clk_neg);

special_color_buffer_inst: special_color_buffer
	port map(
		video_clk => video_clk,
		horizontal_pixel_coordinates => horizontal_pixel_coordinates_signal,
		vertical_pixel_coordinates => vertical_pixel_coordinates_signal,
		
		horizontal_pixel_coord => horizontal_pixel_coord,
		vertical_pixel_coord => vertical_pixel_coord,
		
		sp_color_BG_LAYER => sp_color_BG_LAYER,
		sp_color_FG_LAYER => sp_color_FG_LAYER,
		
		doutb_buffer_bg_o => doutb_buffer_bg,
		doutb_buffer_fg_o => doutb_buffer_fg,
		
		doutb_bg => doutb_bg,
		doutb_fg => doutb_fg
	);

color_system_inst: color_system
	port map(
			horizontal_pixel_coordinates_signal => horizontal_pixel_coordinates_signal,
			vertical_pixel_coordinates_signal => vertical_pixel_coordinates_signal,
			
			addrb_bg => addrb_bg,
			addrb_fg => addrb_fg,
			blank => blank,
			port_block => port_block,
			
			doutb_buffer_bg => doutb_buffer_bg,
			doutb_buffer_fg => doutb_buffer_fg,
			sp_color_BG_LAYER => sp_color_BG_LAYER,
			sp_color_FG_LAYER => sp_color_FG_LAYER,
			color => color,
			transparent_color => transparent_color,
			
			colorPixelBorder => colorPixelBorder
		);
			
video_buffer_controller_inst: video_buffer_controller
	port map(
		clk => clk,
		system_loaded => system_loaded,
		enable_load => enable_load,
		
		finish_buffer => finish_buffer,		
		wea_load => wea_load,
		addra_block_load => addra_block_load,
		dina_load => dina_load,
		
		wea_bg => wea_bg,
		addra_block_bg => addra_block_bg,
		dina_bg => dina_bg,
		
		wea_fg => wea_fg,
		addra_block_fg => addra_block_fg,
		dina_fg => dina_fg,
		
		base_layer_address_bg => base_layer_address_bg,
		horizontal_address_offset_bg => horizontal_address_offset_bg,
		vertical_address_offset_bg => vertical_address_offset_bg,

		base_layer_address_fg => base_layer_address_fg,
		horizontal_address_offset_fg => horizontal_address_offset_fg,
		vertical_address_offset_fg => vertical_address_offset_fg,

		base_layer_address => base_layer_address,
		horizontal_address_offset => horizontal_address_offset,
		vertical_address_offset => vertical_address_offset,
		
		vertical_pixel_coord => vertical_pixel_coord,
		
		buffer_busy_signal => buffer_busy_signal,
		
		loader_block_p => loader_block,
		port_block_p => port_block,
		
		frame_counter => frame_counter(7 downto 0),
		color_pixel_border_o => colorPixelBorder
	);

load_buffer_system_inst : load_buffer_system

	port map(
		clk => clk_neg,
		
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

videoPort_inst : videoPort

   port map(
		clk => video_clk,
		color => color,
		HSync => HSync,
		VSync => VSync, 
		Red => Red,
		Green => Green,
		Blue => Blue,
		horizontal_pixel_coord => horizontal_pixel_coord,
		vertical_pixel_coord => vertical_pixel_coord,
		blank => blank,
		finish_buffer => finish_buffer,
		finish_frame => finish_frame
	);

video_buffer_BG_inst : video_buffer

  PORT MAP (
    clka => clk,
    wea => wea_bg,
    addra => addra_block_bg,
    dina => dina_bg,
    douta => open,--douta_bg,
    clkb => clk_neg,
    web => "0",
    addrb => addrb_bg,
    dinb => (others => '0'),
    doutb => doutb_bg
  );

video_buffer_FG_inst : video_buffer

  PORT MAP (
    clka => clk,
    wea => wea_fg,
    addra => addra_block_fg,
    dina => dina_fg,
    douta => open,--douta_fg,
    clkb => clk_neg,
    web => "0",
    addrb => addrb_fg,
    dinb => (others => '0'),
    doutb => doutb_fg
  );

end Behavioral;