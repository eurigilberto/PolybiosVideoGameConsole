library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;
use IEEE.std_logic_unsigned.ALL;

entity Processor is
	port(
		clk												 : in std_logic;

		calib_done 										 : in std_logic;

		--GET VIDEO INFO
		video_info_data_out 							 : in std_logic_vector(23 downto 0);
		video_info_cmd 									 : out std_logic_vector(1 downto 0);

		--SET VIDEO LAYERS DATA
		video_layers_data_in							 : out std_logic_vector(23 downto 0);
		video_layers_cmd								 : out std_logic_vector(3 downto 0);
		video_layers_input_enabled						 : out std_logic;

		--Port 0 CMD
		c3_p0_cmd_clk                           : out std_logic;
		c3_p0_cmd_en                            : out std_logic;
		c3_p0_cmd_instr                         : out std_logic_vector(2 downto 0);
		c3_p0_cmd_bl                            : out std_logic_vector(5 downto 0);
		c3_p0_cmd_byte_addr                     : out std_logic_vector(29 downto 0);
		c3_p0_cmd_empty                         : in std_logic;
		c3_p0_cmd_full                          : in std_logic;

		--Port 0 WR
		c3_p0_wr_clk                            : out std_logic;
		c3_p0_wr_en                             : out std_logic;
		c3_p0_wr_mask                           : out std_logic_vector(3 downto 0);
		c3_p0_wr_data                           : out std_logic_vector(31 downto 0);
		c3_p0_wr_full                           : in std_logic;
		c3_p0_wr_empty                          : in std_logic;
		c3_p0_wr_count                          : in std_logic_vector(6 downto 0);
		c3_p0_wr_underrun                       : in std_logic;
		c3_p0_wr_error                          : in std_logic;

		--Port 0 RD
		c3_p0_rd_clk                            : out std_logic;
		c3_p0_rd_en                             : out std_logic;
		c3_p0_rd_data                           : in std_logic_vector(31 downto 0);
		c3_p0_rd_full                           : in std_logic;
		c3_p0_rd_empty                          : in std_logic;
		c3_p0_rd_count                          : in std_logic_vector(6 downto 0);
		c3_p0_rd_overflow                       : in std_logic;
		c3_p0_rd_error                          : in std_logic;
		
		debug_leds 		: out std_logic_vector(7 downto 0);
		btn				: in std_logic;

		controller_a : in std_logic_vector(13 downto 0);
		controller_b : in std_logic_vector(13 downto 0)
	);
end Processor;

architecture Behavioral of Processor is

component Port0BiController is
    Port ( clk : in std_logic;
--			  calib_done : in std_logic;
			  
			  --CMD
			  cmd_clk : out  STD_LOGIC;
           cmd_en : out  STD_LOGIC;
           cmd_instr : out  STD_LOGIC_VECTOR (2 downto 0);
           cmd_bl : out  STD_LOGIC_VECTOR (5 downto 0);
           cmd_byte_addr : out  STD_LOGIC_VECTOR (29 downto 0);
           cmd_empty : in  STD_LOGIC;
           cmd_full : in  STD_LOGIC;
			  
			  --WRITE
           wr_clk : out  STD_LOGIC;
           wr_en : out  STD_LOGIC;
           wr_mask : out  STD_LOGIC_VECTOR (3 downto 0);
           wr_data : out  STD_LOGIC_VECTOR (31 downto 0);
           wr_full : in  STD_LOGIC;
           wr_empty : in  STD_LOGIC;
           wr_count : in  std_logic_vector(6 downto 0);
           wr_underrun : in  STD_LOGIC;
           wr_error : in  STD_LOGIC;
			  
			  --READ
           rd_clk : out  STD_LOGIC;
           rd_en : out  STD_LOGIC;
           rd_data : in  STD_LOGIC_VECTOR (31 downto 0);
           rd_full : in  STD_LOGIC;
           rd_empty : in  STD_LOGIC;
           rd_count : in  STD_LOGIC_VECTOR (6 downto 0);
           rd_overflow : in  STD_LOGIC;
           rd_error : in  STD_LOGIC;
			  
			  --DATA+CMDS
			  enable : in std_logic;
			  cmd : in std_logic_vector(2 downto 0);
			  data_in : in std_logic_vector(31 downto 0);
			  data_out : out std_logic_vector(31 downto 0);
			  address : in std_logic_vector(23 downto 0);
			  mask : in std_logic_vector(3 downto 0);
			  rd_bl_in : in std_logic_Vector(5 downto 0);
			  busy : out std_logic
			  
			  );
end component;

COMPONENT RAM_SPRITE
  PORT (
    clka : IN STD_LOGIC;
    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addra : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
    dina : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
  );
END COMPONENT;

component ControlSystem
	port(
		clk 				: in std_logic;
		
		--GET VIDEO INFO
		video_info_data_out 				: in std_logic_vector(23 downto 0);
		video_info_cmd 						: out std_logic_vector(1 downto 0);

		--SET VIDEO LAYERS DATA
		video_layers_data_in				: out std_logic_vector(23 downto 0);
		video_layers_cmd					: out std_logic_vector(3 downto 0);
		video_layers_input_enabled			: out std_logic;
		
		we_RSP : out STD_LOGIC_VECTOR(0 DOWNTO 0);
		addr_RSP : out STD_LOGIC_VECTOR(5 DOWNTO 0);
		din_RSP : out STD_LOGIC_VECTOR(31 DOWNTO 0);
		dout_RSP : in STD_LOGIC_VECTOR(31 DOWNTO 0);
	
		addrA				: out std_logic_vector(4 downto 0);
		addrB				: out std_logic_vector(4 downto 0);
		dinA				: out std_logic_vector(31 downto 0);
		dinB				: out std_logic_vector(31 downto 0);
		doutA				: in std_logic_vector(31 downto 0);
		doutB				: in std_logic_vector(31 downto 0);
		enA				: out std_logic;
		enB				: out std_logic;
		
		enable_port 	: out std_logic;
		cmd_port 		: out std_logic_vector(2 downto 0);
		data_in_port 	: out std_logic_vector(31 downto 0);
		data_out_port 	: in std_logic_vector(31 downto 0);
		address_port 	: out std_logic_vector(23 downto 0);
		mask_port 		: out std_logic_vector(3 downto 0);
		rd_bl_in_port 	: out std_logic_Vector(5 downto 0);
		busy_port		: in std_logic;
		calib_done		: in std_logic;
		
		debug_leds 		: out std_logic_vector(7 downto 0);
		btn				: in std_logic;
		
		controller_a : in std_logic_vector(13 downto 0);
		controller_b : in std_logic_vector(13 downto 0)
	);
end component;

COMPONENT RAM_PROCESSOR
  PORT (
    clka : IN STD_LOGIC;
    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addra : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
    dina : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    clkb : IN STD_LOGIC;
    web : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addrb : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
    dinb : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    doutb : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
  );
END COMPONENT;

-- port signals
signal enable_port 		: std_logic 							:= '0';
signal cmd_port 		: std_logic_vector(2 downto 0) 			:= "100";
signal data_in_port 	: std_logic_vector(31 downto 0) 		:= (others => '0');
signal data_out_port 	: std_logic_vector(31 downto 0) 		:= (others => '0');
signal address_port 	: std_logic_vector(23 downto 0) 		:= (others => '0');
signal mask_port 		: std_logic_vector(3 downto 0) 			:= (others => '0');
signal rd_bl_in_port 	: std_logic_Vector(5 downto 0) 			:= (others => '0');
signal busy_port		: std_logic								:= '0';
-- port signals

-- RAM ports
signal addrA			: std_logic_vector(4 downto 0) 			:= (others => '0');
signal addrB			: std_logic_vector(4 downto 0) 			:= (others => '0');

signal dinA				: std_logic_vector(31 downto 0)  		:= (others => '0');
signal dinB				: std_logic_vector(31 downto 0)  		:= (others => '0');

signal doutA			: std_logic_vector(31 downto 0);
signal doutB			: std_logic_vector(31 downto 0);

signal enA				: std_logic								:= '0';
signal enB				: std_logic								:= '0';

signal enAv				: std_logic_vector(0 downto 0)			:= "0";
signal enBv				: std_logic_vector(0 downto 0)			:= "0";
-- RAM ports

-- RAM sprite
	signal we_RSP : std_logic_vector(0 downto 0) := "0";
	signal addr_RSP : std_logic_vector(5 downto 0) := (others => '0');
	signal din_RSP : std_logic_vector(31 downto 0) := (others => '0');
	signal dout_RSP : std_logic_vector(31 downto 0) := (others => '0');
-- RAM sprite

signal clk_neg : std_logic := '0';
signal controlOutA : std_logic_vector(9 downto 0);

begin

enAv(0) <= enA;
enBv(0) <= enB;
clk_neg <= not(clk);

RAM_SPRITE_inst : RAM_SPRITE
  PORT MAP (
    clka => clk_neg,
    wea => we_RSP,
    addra => addr_RSP,
    dina => din_RSP,
    douta => dout_RSP
  );

RAM_PROCESSOR_inst : RAM_PROCESSOR
  PORT MAP (
    clka 				=> clk_neg,
    wea 					=> enAv,
    addra 				=> addrA,
    dina 				=> dinA,
    douta 				=> doutA,
    clkb 				=> clk_neg,
    web 					=> enBv,
    addrb 				=> addrB,
    dinb 				=> dinB,
    doutb 				=> doutB
  );

ControlSysteminst : ControlSystem
	port map(
		clk 				=> clk,
		
		--GET VIDEO INFO
		video_info_data_out 							 => video_info_data_out,
		video_info_cmd 									 => video_info_cmd,

		--SET VIDEO LAYERS DATA
		video_layers_data_in							 => video_layers_data_in,
		video_layers_cmd								 => video_layers_cmd,
		video_layers_input_enabled						 => video_layers_input_enabled,
		
		we_RSP => we_RSP,
		addr_RSP => addr_RSP,
		din_RSP => din_RSP,
		dout_RSP => dout_RSP,
	
		addrA				=> addrA,
		addrB				=> addrB,
		dinA				=> dinA,
		dinB				=> dinB,
		doutA				=> doutA,
		doutB				=> doutB,
		enA				=> enA,
		enB				=> enB,
		
		enable_port 	=> enable_port,
		cmd_port 		=> cmd_port,
		data_in_port 	=> data_in_port,
		data_out_port 	=> data_out_port,
		address_port 	=> address_port,
		mask_port 		=> mask_port,
		rd_bl_in_port 	=> rd_bl_in_port,
		busy_port		=> busy_port,
		calib_done		=> calib_done,
		
		debug_leds 		=> debug_leds,
		btn				=> btn,
		
		--Controllers
		controller_a => controller_a,
		controller_b => controller_b
	);

Port0BiController_inst: Port0BiController
    port map( clk => clk,
--			  calib_done => calib_done,
			  
			  --CMD
			  cmd_clk => c3_p0_cmd_clk,
           cmd_en => c3_p0_cmd_en,
           cmd_instr => c3_p0_cmd_instr,
           cmd_bl => c3_p0_cmd_bl,
           cmd_byte_addr => c3_p0_cmd_byte_addr,
           cmd_empty => c3_p0_cmd_empty,
           cmd_full => c3_p0_cmd_full,
			  
			  --WRITE
           wr_clk => c3_p0_wr_clk,
           wr_en => c3_p0_wr_en,
           wr_mask => c3_p0_wr_mask,
           wr_data => c3_p0_wr_data,
           wr_full => c3_p0_wr_full,
           wr_empty => c3_p0_wr_empty,
           wr_count => c3_p0_wr_count,
           wr_underrun => c3_p0_wr_underrun,
           wr_error => c3_p0_wr_error,
			  
			  --READ
           rd_clk => c3_p0_rd_clk,
           rd_en => c3_p0_rd_en,
           rd_data => c3_p0_rd_data,
           rd_full => c3_p0_rd_full,
           rd_empty => c3_p0_rd_empty,
           rd_count => c3_p0_rd_count,
           rd_overflow => c3_p0_rd_overflow,
           rd_error => c3_p0_rd_error,
			  
			  --DATA+CMDS
			  enable => enable_port,
			  cmd => cmd_port,
			  data_in => data_in_port,
			  data_out => data_out_port,
			  address => address_port,
			  mask => mask_port,
			  rd_bl_in => rd_bl_in_port,
			  busy => busy_port
			  );

end Behavioral;

