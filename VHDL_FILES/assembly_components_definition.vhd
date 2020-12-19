library IEEE;
use IEEE.STD_LOGIC_1164.all;

package assembly_components_definition is

component Processor
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
end component;

component VideoSystem

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

end component;

component freqDiv

	port(
		clk : in std_logic;
		clkOut1P : out std_logic
		--clkOut2P : out std_logic
	);

end component;

component SD_CARD_CLK

	port(
        clk: in std_logic;
		sclk_reset: in std_logic;
		clk_posedge: out std_logic;
		clk_negedge: out std_logic;
		clk_freq_selector: in std_logic
	);

end component;

component SD_initiator

	port(
		clk: in std_logic;
		sdcard_cs: out std_logic;
		sdcard_sclk: out std_logic;
		sdcard_mosi: out std_logic;
		sdcard_miso: in std_logic;
		
		byte_see : out std_logic_vector(7 downto 0);
		
		dataLED: out std_logic_vector(7 downto 0);
		
		SevenSegmentEnable : out std_logic_vector(2 downto 0);

      clk_posedge: in std_logic;
		clk_negedge: in std_logic;
		clk_freq_selector: out std_logic;
		sclk_reset_out: out std_logic;
		
		c3_p2_cmd_clk                           : out std_logic;
		c3_p2_cmd_en                            : out std_logic;
		c3_p2_cmd_instr                         : out std_logic_vector(2 downto 0);
		c3_p2_cmd_bl                            : out std_logic_vector(5 downto 0);
		c3_p2_cmd_byte_addr                     : out std_logic_vector(29 downto 0);
		c3_p2_cmd_empty                         : in std_logic;
		c3_p2_cmd_full                          : in std_logic;
		
		c3_p2_wr_clk                            : out std_logic;
		c3_p2_wr_en                             : out std_logic;
		c3_p2_wr_mask                           : out std_logic_vector(3 downto 0);
		c3_p2_wr_data                           : out std_logic_vector(31 downto 0);
		c3_p2_wr_full                           : in std_logic;
		c3_p2_wr_empty                          : in std_logic;
		c3_p2_wr_count                          : in std_logic_vector(6 downto 0);
		c3_p2_wr_underrun                       : in std_logic;
		c3_p2_wr_error                          : in std_logic;

		c3_calib_done                           : in std_logic;
		write_done										: out std_logic
	);

end component;

component LPDDR
 generic(
    C3_P0_MASK_SIZE           : integer := 4;
    C3_P0_DATA_PORT_SIZE      : integer := 32;
    C3_P1_MASK_SIZE           : integer := 4;
    C3_P1_DATA_PORT_SIZE      : integer := 32;
    C3_MEMCLK_PERIOD          : integer := 10000;
    C3_RST_ACT_LOW            : integer := 0;
    C3_INPUT_CLK_TYPE         : string := "SINGLE_ENDED";
    C3_CALIB_SOFT_IP          : string := "TRUE";
    C3_SIMULATION             : string := "FALSE";
    DEBUG_EN                  : integer := 0;
    C3_MEM_ADDR_ORDER         : string := "ROW_BANK_COLUMN";
    C3_NUM_DQ_PINS            : integer := 16;
    C3_MEM_ADDR_WIDTH         : integer := 13;
    C3_MEM_BANKADDR_WIDTH     : integer := 2
);
    port (
   mcb3_dram_dq                            : inout  std_logic_vector(C3_NUM_DQ_PINS-1 downto 0);
   mcb3_dram_a                             : out std_logic_vector(C3_MEM_ADDR_WIDTH-1 downto 0);
   mcb3_dram_ba                            : out std_logic_vector(C3_MEM_BANKADDR_WIDTH-1 downto 0);
   mcb3_dram_cke                           : out std_logic;
   mcb3_dram_ras_n                         : out std_logic;
   mcb3_dram_cas_n                         : out std_logic;
   mcb3_dram_we_n                          : out std_logic;
   mcb3_dram_dm                            : out std_logic;
   mcb3_dram_udqs                          : inout  std_logic;
   mcb3_rzq                                : inout  std_logic;
   mcb3_dram_udm                           : out std_logic;
   c3_sys_clk                              : in  std_logic;
   c3_sys_rst_i                            : in  std_logic;
   c3_calib_done                           : out std_logic;
   c3_clk0                                 : out std_logic;
   c3_rst0                                 : out std_logic;
   mcb3_dram_dqs                           : inout  std_logic;
   mcb3_dram_ck                            : out std_logic;
   mcb3_dram_ck_n                          : out std_logic;

   --Port 0 CMD
   c3_p0_cmd_clk                           : in std_logic;
   c3_p0_cmd_en                            : in std_logic;
   c3_p0_cmd_instr                         : in std_logic_vector(2 downto 0);
   c3_p0_cmd_bl                            : in std_logic_vector(5 downto 0);
   c3_p0_cmd_byte_addr                     : in std_logic_vector(29 downto 0);
   c3_p0_cmd_empty                         : out std_logic;
   c3_p0_cmd_full                          : out std_logic;

   --Port 0 WR
   c3_p0_wr_clk                            : in std_logic;
   c3_p0_wr_en                             : in std_logic;
   c3_p0_wr_mask                           : in std_logic_vector(C3_P0_MASK_SIZE - 1 downto 0);
   c3_p0_wr_data                           : in std_logic_vector(C3_P0_DATA_PORT_SIZE - 1 downto 0);
   c3_p0_wr_full                           : out std_logic;
   c3_p0_wr_empty                          : out std_logic;
   c3_p0_wr_count                          : out std_logic_vector(6 downto 0);
   c3_p0_wr_underrun                       : out std_logic;
   c3_p0_wr_error                          : out std_logic;

   --Port 0 RD
   c3_p0_rd_clk                            : in std_logic;
   c3_p0_rd_en                             : in std_logic;
   c3_p0_rd_data                           : out std_logic_vector(C3_P0_DATA_PORT_SIZE - 1 downto 0);
   c3_p0_rd_full                           : out std_logic;
   c3_p0_rd_empty                          : out std_logic;
   c3_p0_rd_count                          : out std_logic_vector(6 downto 0);
   c3_p0_rd_overflow                       : out std_logic;
   c3_p0_rd_error                          : out std_logic;

   --Port 2 CMD
   c3_p2_cmd_clk                           : in std_logic;
   c3_p2_cmd_en                            : in std_logic;
   c3_p2_cmd_instr                         : in std_logic_vector(2 downto 0);
   c3_p2_cmd_bl                            : in std_logic_vector(5 downto 0);
   c3_p2_cmd_byte_addr                     : in std_logic_vector(29 downto 0);
   c3_p2_cmd_empty                         : out std_logic;
   c3_p2_cmd_full                          : out std_logic;

   --Port 2 WR
   c3_p2_wr_clk                            : in std_logic;
   c3_p2_wr_en                             : in std_logic;
   c3_p2_wr_mask                           : in std_logic_vector(3 downto 0);
   c3_p2_wr_data                           : in std_logic_vector(31 downto 0);
   c3_p2_wr_full                           : out std_logic;
   c3_p2_wr_empty                          : out std_logic;
   c3_p2_wr_count                          : out std_logic_vector(6 downto 0);
   c3_p2_wr_underrun                       : out std_logic;
   c3_p2_wr_error                          : out std_logic;

   --Port 3 CMD
   c3_p3_cmd_clk                           : in std_logic;
   c3_p3_cmd_en                            : in std_logic;
   c3_p3_cmd_instr                         : in std_logic_vector(2 downto 0);
   c3_p3_cmd_bl                            : in std_logic_vector(5 downto 0);
   c3_p3_cmd_byte_addr                     : in std_logic_vector(29 downto 0);
   c3_p3_cmd_empty                         : out std_logic;
   c3_p3_cmd_full                          : out std_logic;

   --Port 3 RD
   c3_p3_rd_clk                            : in std_logic;
   c3_p3_rd_en                             : in std_logic;
   c3_p3_rd_data                           : out std_logic_vector(31 downto 0);
   c3_p3_rd_full                           : out std_logic;
   c3_p3_rd_empty                          : out std_logic;
   c3_p3_rd_count                          : out std_logic_vector(6 downto 0);
   c3_p3_rd_overflow                       : out std_logic;
   c3_p3_rd_error                          : out std_logic
);
end component;

component video_freq is
	port(vid_clk_2x : in std_logic;
		  video_clk : out std_logic);
end component;

component controllers is
	port(
        clk : in std_logic;
        --header p6
		  out_p6 : out std_logic_vector(3 downto 0);
        input_p6 : in std_logic_vector(3 downto 0);
        controller_a : out std_logic_vector(13 downto 0);
        --header p7
        out_p7 : out std_logic_vector(3 downto 0);
        input_p7 : in std_logic_vector(3 downto 0);
        controller_b : out std_logic_vector(13 downto 0)
	);
end component;

end assembly_components_definition;

package body assembly_components_definition is
 
end assembly_components_definition;
