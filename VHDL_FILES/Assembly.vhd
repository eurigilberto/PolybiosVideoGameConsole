library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Assembly is

	port(
      clks: in std_logic;
		sdcard_cs: out std_logic;
		sdcard_sclk: out std_logic;
		sdcard_mosi: out std_logic;
		sdcard_miso: in std_logic;
		
		dataLED: out std_logic_vector(7 downto 0);
		
		btn_reader : in std_logic_vector(5 downto 0);

		SevenSegmentEnable : out std_logic_vector(2 downto 0);
		
		DPSwitch : in std_logic_vector(7 downto 0);
        
--		calib_done_O : out std_logic;
--		error : out std_logic;
--		c3_sys_rst_n : out std_logic;

		mcb3_dram_a : out std_logic_vector(12 downto 0);
		mcb3_dram_ba : out std_logic_vector(1 downto 0);
		mcb3_dram_cas_n : out std_logic;
		mcb3_dram_ck : out std_logic;
		mcb3_dram_ck_n : out std_logic;
		mcb3_dram_cke : out std_logic;
		mcb3_dram_dm : out std_logic;
		mcb3_dram_dq : inout std_logic_vector(15 downto 0);
		mcb3_dram_dqs : inout std_logic;
		mcb3_dram_ras_n : out std_logic;
		mcb3_dram_udm : out std_logic;
		mcb3_dram_udqs : inout std_logic;
		mcb3_dram_we_n : out std_logic;
		rzq3 : inout std_logic;
		
		HSync : out std_logic;
		VSync : out std_logic;
		Red : out std_logic_vector(2 downto 0);
		Green : out std_logic_vector(2 downto 0);
		Blue : out std_logic_vector(1 downto 0);
		
		voltA : out std_logic_vector(3 downto 0);
		inputA : in std_logic_vector(3 downto 0)
	);

end Assembly;

architecture Behavioral of Assembly is

signal errorLEDS : std_logic_vector(7 downto 0) := (others => '0');
signal choose : std_logic := '0';
signal dataLEDS : std_logic_vector(7 downto 0) := (others => '0');
signal dataLEDsignal : std_logic_vector(7 downto 0) := (others => '0');
signal proLEDS : std_logic_vector(7 downto 0) := (others => '0');

component video_freq is
	port(vid_clk_2x : in std_logic;
		  video_clk : out std_logic);
end component;

component Processor
	port(
		clk												 : in std_logic;

		calib_done 										 : in std_logic;
		
		data_out_v 										 : in std_logic_vector(23 downto 0);
		data_in_v 										 : out std_logic_vector(23 downto 0);
		cmd_input_v 									 : out std_logic_vector(3 downto 0);
		cmd_output_v 									 : out std_logic_vector(3 downto 0);
		input_enable_v 								 : out std_logic;

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
        
        out_p6 : out std_logic_vector(3 downto 0);
        input_p6 : in std_logic_vector(3 downto 0);

        out_p7 : out std_logic_vector(3 downto 0);
        input_p7 : in std_logic_vector(3 downto 0)
	);
end component;

component VideoSystem

	port(
		clk : in std_logic;
		
		video_clk : in std_logic;
		
		system_loaded : in std_logic;
		
		HSync : out std_logic;
		VSync : out std_logic;
		Red : out std_logic_vector(2 downto 0);
		Green : out std_logic_vector(2 downto 0);
		Blue : out std_logic_vector(1 downto 0);
		
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

end component;

component freqDiv

	port(
		clk : in std_logic;
		clkOut1P : out std_logic;
		clkOut2P : out std_logic
	);

end component;

component SD_CARD_CLK

	port(
        clk: in std_logic;
		sclk_reset: in std_logic;
		clk_posedge: out std_logic;
		clk_negedge: out std_logic;
		clk_count_limit: in std_logic_vector(7 downto 0)
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
		clk_count_limit: out std_logic_vector(7 downto 0);
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

--CHANGE REGISTERS VIDEO SYSTEM
	signal data_out_v : std_logic_vector(23 downto 0);
	signal data_in_v : std_logic_vector(23 downto 0);
	signal cmd_input_v : std_logic_vector(3 downto 0);
	signal cmd_output_v : std_logic_vector(3 downto 0);
	signal input_enable_v : std_logic;

--MCB constant values
    constant C3_P0_MASK_SIZE           : integer := 4;
    constant C3_P0_DATA_PORT_SIZE      : integer := 32;
    constant C3_P1_MASK_SIZE           : integer := 4;
    constant C3_P1_DATA_PORT_SIZE      : integer := 32;
    constant C3_MEMCLK_PERIOD          : integer := 10000;
    constant C3_RST_ACT_LOW            : integer := 0;
    constant C3_INPUT_CLK_TYPE         : string := "SINGLE_ENDED";
    constant C3_CALIB_SOFT_IP          : string := "TRUE";
    constant C3_SIMULATION             : string := "FALSE";
    constant DEBUG_EN                  : integer := 0;
    constant C3_MEM_ADDR_ORDER         : string := "ROW_BANK_COLUMN";
    constant C3_NUM_DQ_PINS            : integer := 16;
    constant C3_MEM_ADDR_WIDTH         : integer := 13;
    constant C3_MEM_BANKADDR_WIDTH     : integer := 2;

--SIGNALS

--Port 0 CMD
    signal c3_p0_cmd_clk                           : std_logic;
    signal c3_p0_cmd_en                            : std_logic;
    signal c3_p0_cmd_instr                         : std_logic_vector(2 downto 0);
    signal c3_p0_cmd_bl                            : std_logic_vector(5 downto 0);
    signal c3_p0_cmd_byte_addr                     : std_logic_vector(29 downto 0);
    signal c3_p0_cmd_empty                         : std_logic;
    signal c3_p0_cmd_full                          : std_logic;

--Port 0 WR
    signal c3_p0_wr_clk                            : std_logic;
    signal c3_p0_wr_en                             : std_logic;
    signal c3_p0_wr_mask                           : std_logic_vector(C3_P0_MASK_SIZE - 1 downto 0);
    signal c3_p0_wr_data                           : std_logic_vector(C3_P0_DATA_PORT_SIZE - 1 downto 0);
    signal c3_p0_wr_full                           : std_logic;
    signal c3_p0_wr_empty                          : std_logic;
    signal c3_p0_wr_count                          : std_logic_vector(6 downto 0);
    signal c3_p0_wr_underrun                       : std_logic;
    signal c3_p0_wr_error                          : std_logic;

--Port 0 RD
    signal c3_p0_rd_clk                            : std_logic;
    signal c3_p0_rd_en                             : std_logic;
    signal c3_p0_rd_data                           : std_logic_vector(C3_P0_DATA_PORT_SIZE - 1 downto 0);
    signal c3_p0_rd_full                           : std_logic;
    signal c3_p0_rd_empty                          : std_logic;
    signal c3_p0_rd_count                          : std_logic_vector(6 downto 0);
    signal c3_p0_rd_overflow                       : std_logic;
    signal c3_p0_rd_error                          : std_logic;

--Port 2 CMD
    signal c3_p2_cmd_clk                           : std_logic;
    signal c3_p2_cmd_en                            : std_logic;
    signal c3_p2_cmd_instr                         : std_logic_vector(2 downto 0);
    signal c3_p2_cmd_bl                            : std_logic_vector(5 downto 0);
    signal c3_p2_cmd_byte_addr                     : std_logic_vector(29 downto 0);
    signal c3_p2_cmd_empty                         : std_logic;
    signal c3_p2_cmd_full                          : std_logic;

--Port 2 WR
    signal c3_p2_wr_clk                            : std_logic;
    signal c3_p2_wr_en                             : std_logic;
    signal c3_p2_wr_mask                           : std_logic_vector(3 downto 0);
    signal c3_p2_wr_data                           : std_logic_vector(31 downto 0);
    signal c3_p2_wr_full                           : std_logic;
    signal c3_p2_wr_empty                          : std_logic;
    signal c3_p2_wr_count                          : std_logic_vector(6 downto 0);
    signal c3_p2_wr_underrun                       : std_logic;
    signal c3_p2_wr_error                          : std_logic;

--Port 3 CMD
    signal c3_p3_cmd_clk                           : std_logic;
    signal c3_p3_cmd_en                            : std_logic;
    signal c3_p3_cmd_instr                         : std_logic_vector(2 downto 0);
    signal c3_p3_cmd_bl                            : std_logic_vector(5 downto 0);
    signal c3_p3_cmd_byte_addr                     : std_logic_vector(29 downto 0);
    signal c3_p3_cmd_empty                         : std_logic;
    signal c3_p3_cmd_full                          : std_logic;

--Port 3 RD
    signal c3_p3_rd_clk                            : std_logic;
    signal c3_p3_rd_en                             : std_logic;
    signal c3_p3_rd_data                           : std_logic_vector(31 downto 0);
    signal c3_p3_rd_full                           : std_logic;
    signal c3_p3_rd_empty                          : std_logic;
    signal c3_p3_rd_count                          : std_logic_vector(6 downto 0);
    signal c3_p3_rd_overflow                       : std_logic;
    signal c3_p3_rd_error                          : std_logic;

signal c3_calib_done : std_logic := '0';

signal write_done : std_logic := '0';

signal SevenSegmentEnableSignal : std_logic_vector(2 downto 0);

signal clk : std_logic;

--SDCARD freq
    signal sclk_reset: std_logic;
    signal clk_posedge: std_logic;
    signal clk_negedge: std_logic;
    signal clk_count_limit: std_logic_vector(7 downto 0);

signal video_clock : std_logic;
signal video_clock_2x : std_logic;

signal controller_a_signal : std_logic_vector(13 downto 0);
signal controller_b_signal : std_logic_vector(13 downto 0);

begin

SevenSegmentEnable(2) <= not(write_done);
SevenSegmentEnable(1) <= not(btn_reader(2));
SevenSegmentEnable(0) <= btn_reader(0);

dataLEDsignal <= dataLEDS when write_done = '0' else
			  errorLEDS;
			  
dataLED <= dataLEDsignal when btn_reader(2) = '0' else
              proLEDS;
              
controller_system_inst: controllers
    port map(
        clk                                     => video_clock_2x;
        
        out_p6                                  => out_p6;
        input_p6                                => input_p6;
        constroller_a                           => controller_a_signal;

        out_p7                                  => out_p7;
        input_p7                                => input_p7;
        controller_b                            => controller_b_signal
    );

Processor_inst: Processor
	port map(
		clk												 => video_clock_2x,

		calib_done 										 => write_done,
		
		data_out_v 										 => data_out_v,
		data_in_v 										 => data_in_v,
		cmd_input_v 									 => cmd_input_v,
		cmd_output_v 									 => cmd_output_v,
		input_enable_v 								 => input_enable_v,

		--Port 0 CMD
		c3_p0_cmd_clk                           => c3_p0_cmd_clk,
		c3_p0_cmd_en                            => c3_p0_cmd_en,
		c3_p0_cmd_instr                         => c3_p0_cmd_instr,
		c3_p0_cmd_bl                            => c3_p0_cmd_bl,
		c3_p0_cmd_byte_addr                     => c3_p0_cmd_byte_addr,
		c3_p0_cmd_empty                         => c3_p0_cmd_empty,
		c3_p0_cmd_full                          => c3_p0_cmd_full,

		--Port 0 WR
		c3_p0_wr_clk                            => c3_p0_wr_clk,
		c3_p0_wr_en                             => c3_p0_wr_en,
		c3_p0_wr_mask                           => c3_p0_wr_mask,
		c3_p0_wr_data                           => c3_p0_wr_data,
		c3_p0_wr_full                           => c3_p0_wr_full,
		c3_p0_wr_empty                          => c3_p0_wr_empty,
		c3_p0_wr_count                          => c3_p0_wr_count,
		c3_p0_wr_underrun                       => c3_p0_wr_underrun,
		c3_p0_wr_error                          => c3_p0_wr_error,

		--Port 0 RD
		c3_p0_rd_clk                            => c3_p0_rd_clk,
		c3_p0_rd_en                             => c3_p0_rd_en,
		c3_p0_rd_data                           => c3_p0_rd_data,
		c3_p0_rd_full                           => c3_p0_rd_full,
		c3_p0_rd_empty                          => c3_p0_rd_empty,
		c3_p0_rd_count                          => c3_p0_rd_count,
		c3_p0_rd_overflow                       => c3_p0_rd_overflow,
		c3_p0_rd_error                          => c3_p0_rd_error,
		
		debug_leds 		                        => proLEDS,--dataLED,
        btn				                        => not(btn_reader(0)),
        
		controller_a                            => controller_a_signal,
		controller_b			                => controller_b_signal
	);

SD_CARD_CLK_inst : SD_CARD_CLK

	port map(
        clk => clk,
		sclk_reset => sclk_reset,  
		clk_posedge => clk_posedge, 
		clk_negedge => clk_negedge,
		clk_count_limit => clk_count_limit
	);

LPDDR_inst : LPDDR
    generic map (
    C3_P0_MASK_SIZE => C3_P0_MASK_SIZE,
    C3_P0_DATA_PORT_SIZE => C3_P0_DATA_PORT_SIZE,
    C3_P1_MASK_SIZE => C3_P1_MASK_SIZE,
    C3_P1_DATA_PORT_SIZE => C3_P1_DATA_PORT_SIZE,
    C3_MEMCLK_PERIOD => C3_MEMCLK_PERIOD,
    C3_RST_ACT_LOW => C3_RST_ACT_LOW,
    C3_INPUT_CLK_TYPE => C3_INPUT_CLK_TYPE,
    C3_CALIB_SOFT_IP => C3_CALIB_SOFT_IP,
    C3_SIMULATION => C3_SIMULATION,
    DEBUG_EN => DEBUG_EN,
    C3_MEM_ADDR_ORDER => C3_MEM_ADDR_ORDER,
    C3_NUM_DQ_PINS => C3_NUM_DQ_PINS,
    C3_MEM_ADDR_WIDTH => C3_MEM_ADDR_WIDTH,
    C3_MEM_BANKADDR_WIDTH => C3_MEM_BANKADDR_WIDTH
)
    port map (

    c3_sys_clk  =>         video_clock_2x,
    c3_sys_rst_i    =>       '0',                        

    mcb3_dram_dq       =>    mcb3_dram_dq,  
    mcb3_dram_a        =>    mcb3_dram_a,  
    mcb3_dram_ba       =>    mcb3_dram_ba,
    mcb3_dram_ras_n    =>    mcb3_dram_ras_n,                        
    mcb3_dram_cas_n    =>    mcb3_dram_cas_n,                        
    mcb3_dram_we_n     =>    mcb3_dram_we_n,                          
    mcb3_dram_cke      =>    mcb3_dram_cke,                          
    mcb3_dram_ck       =>    mcb3_dram_ck,                          
    mcb3_dram_ck_n     =>    mcb3_dram_ck_n,       
    mcb3_dram_dqs      =>    mcb3_dram_dqs,                          
    mcb3_dram_udqs  =>       mcb3_dram_udqs,    -- for X16 parts           
    mcb3_dram_udm  =>        mcb3_dram_udm,     -- for X16 parts
    mcb3_dram_dm  =>       mcb3_dram_dm,

    c3_clk0	=>	        open,
    c3_rst0		=>        open,
    c3_calib_done      =>    c3_calib_done,

    mcb3_rzq                                =>  rzq3,

    --Port 0 CMD
    c3_p0_cmd_clk                           =>  c3_p0_cmd_clk,
    c3_p0_cmd_en                            =>  c3_p0_cmd_en,
    c3_p0_cmd_instr                         =>  c3_p0_cmd_instr,
    c3_p0_cmd_bl                            =>  c3_p0_cmd_bl,
    c3_p0_cmd_byte_addr                     =>  c3_p0_cmd_byte_addr,
    c3_p0_cmd_empty                         =>  c3_p0_cmd_empty,
    c3_p0_cmd_full                          =>  c3_p0_cmd_full,

    --Port 0 WR
    c3_p0_wr_clk                            =>  c3_p0_wr_clk,
    c3_p0_wr_en                             =>  c3_p0_wr_en,
    c3_p0_wr_mask                           =>  c3_p0_wr_mask,
    c3_p0_wr_data                           =>  c3_p0_wr_data,
    c3_p0_wr_full                           =>  c3_p0_wr_full,
    c3_p0_wr_empty                          =>  c3_p0_wr_empty,
    c3_p0_wr_count                          =>  c3_p0_wr_count,
    c3_p0_wr_underrun                       =>  c3_p0_wr_underrun,
    c3_p0_wr_error                          =>  c3_p0_wr_error,
    
    --Port 0 RD
    c3_p0_rd_clk                            =>  c3_p0_rd_clk,
    c3_p0_rd_en                             =>  c3_p0_rd_en,
    c3_p0_rd_data                           =>  c3_p0_rd_data,
    c3_p0_rd_full                           =>  c3_p0_rd_full,
    c3_p0_rd_empty                          =>  c3_p0_rd_empty,
    c3_p0_rd_count                          =>  c3_p0_rd_count,
    c3_p0_rd_overflow                       =>  c3_p0_rd_overflow,
    c3_p0_rd_error                          =>  c3_p0_rd_error,
    
    --Port 2 CMD
    c3_p2_cmd_clk                           =>  c3_p2_cmd_clk,
    c3_p2_cmd_en                            =>  c3_p2_cmd_en,
    c3_p2_cmd_instr                         =>  c3_p2_cmd_instr,
    c3_p2_cmd_bl                            =>  c3_p2_cmd_bl,
    c3_p2_cmd_byte_addr                     =>  c3_p2_cmd_byte_addr,
    c3_p2_cmd_empty                         =>  c3_p2_cmd_empty,
    c3_p2_cmd_full                          =>  c3_p2_cmd_full,
    
    --Port 2 WR
    c3_p2_wr_clk                            =>  c3_p2_wr_clk,
    c3_p2_wr_en                             =>  c3_p2_wr_en,
    c3_p2_wr_mask                           =>  c3_p2_wr_mask,
    c3_p2_wr_data                           =>  c3_p2_wr_data,
    c3_p2_wr_full                           =>  c3_p2_wr_full,
    c3_p2_wr_empty                          =>  c3_p2_wr_empty,
    c3_p2_wr_count                          =>  c3_p2_wr_count,
    c3_p2_wr_underrun                       =>  c3_p2_wr_underrun,
    c3_p2_wr_error                          =>  c3_p2_wr_error,
    
    --Port 3 CMD
    c3_p3_cmd_clk                           =>  c3_p3_cmd_clk,
    c3_p3_cmd_en                            =>  c3_p3_cmd_en,
    c3_p3_cmd_instr                         =>  c3_p3_cmd_instr,
    c3_p3_cmd_bl                            =>  c3_p3_cmd_bl,
    c3_p3_cmd_byte_addr                     =>  c3_p3_cmd_byte_addr,
    c3_p3_cmd_empty                         =>  c3_p3_cmd_empty,
    c3_p3_cmd_full                          =>  c3_p3_cmd_full,
    
    --Port 3 RD
    c3_p3_rd_clk                            =>  c3_p3_rd_clk,
    c3_p3_rd_en                             =>  c3_p3_rd_en,
    c3_p3_rd_data                           =>  c3_p3_rd_data,
    c3_p3_rd_full                           =>  c3_p3_rd_full,
    c3_p3_rd_empty                          =>  c3_p3_rd_empty,
    c3_p3_rd_count                          =>  c3_p3_rd_count,
    c3_p3_rd_overflow                       =>  c3_p3_rd_overflow,
    c3_p3_rd_error                          =>  c3_p3_rd_error
);

--SevenSegmentEnable <= SevenSegmentEnableSignal(2)&not(write_done)&not(c3_calib_done);

SD_initiator_inst : SD_initiator
port map(
    clk => clk,
    sdcard_cs => sdcard_cs,
    sdcard_sclk => sdcard_sclk,
    sdcard_mosi => sdcard_mosi,
    sdcard_miso => sdcard_miso,
	 
	 byte_see => open,
    
    dataLED => dataLEDS,
    
    SevenSegmentEnable => SevenSegmentEnableSignal,

    clk_posedge => clk_posedge,
    clk_negedge => clk_negedge,
    clk_count_limit => clk_count_limit,
    sclk_reset_out => sclk_reset,
    
    c3_p2_cmd_clk                           => c3_p2_cmd_clk,
    c3_p2_cmd_en                            => c3_p2_cmd_en,
    c3_p2_cmd_instr                         => c3_p2_cmd_instr,
    c3_p2_cmd_bl                            => c3_p2_cmd_bl,
    c3_p2_cmd_byte_addr                     => c3_p2_cmd_byte_addr,
    c3_p2_cmd_empty                         => c3_p2_cmd_empty,
    c3_p2_cmd_full                          => c3_p2_cmd_full,
    
    c3_p2_wr_clk                            => c3_p2_wr_clk,
    c3_p2_wr_en                             => c3_p2_wr_en,
    c3_p2_wr_mask                           => c3_p2_wr_mask,
    c3_p2_wr_data                           => c3_p2_wr_data,
    c3_p2_wr_full                           => c3_p2_wr_full,
    c3_p2_wr_empty                          => c3_p2_wr_empty,
    c3_p2_wr_count                          => c3_p2_wr_count,
    c3_p2_wr_underrun                       => c3_p2_wr_underrun,
    c3_p2_wr_error                          => c3_p2_wr_error,
    
    c3_calib_done                           => c3_calib_done,

    write_done								=> write_done
);
           
freqDiv_inst: freqDiv
    port map(
        clk => clks,
        clkOut1P =>video_clock_2x,
        clkOut2P =>clk
    );

video_freq_inst: video_freq
	port map(vid_clk_2x => video_clock_2x,
		  video_clk => video_clock);

VideoSystemInst : VideoSystem

	port map(
		video_clock_2x => video_clock_2x,
		
		system_loaded => write_done,
		
		video_clk => video_clock,
		
		HSync => HSync,
		VSync => VSync,
		Red => Red,
		Green => Green,
		Blue => Blue,
		
		--CHANGE REGISTERS
		data_out => data_out_v,
		data_in => data_in_v,
		cmd_input => cmd_input_v,
		cmd_output => cmd_output_v,
		input_enable => input_enable_v,
		
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
		c3_p3_rd_error => c3_p3_rd_error
	);
	
process(video_clock_2x)
begin

if(rising_edge(video_clock_2x))then
	if(write_done = '1')then
		choose <= '1';
	end if;
	if(c3_p0_wr_error = '1')then
		errorLEDS(0) <= '1';
	end if;
	if(c3_p0_rd_error = '1')then
		errorLEDS(1) <= '1';
	end if;
	if(c3_p2_wr_error = '1')then
		errorLEDS(2) <= '1';
	end if;
	if(c3_p3_rd_error = '1')then
		errorLEDS(3) <= '1';
	end if;
	if(c3_p0_wr_underrun = '1')then
		errorLEDS(4) <= '1';
	end if;
	if(c3_p0_wr_underrun = '1')then
		errorLEDS(4) <= '1';
	end if;
	if(c3_p2_wr_underrun = '1')then
		errorLEDS(5) <= '1';
	end if;
	if(c3_p3_rd_overflow = '1')then
		errorLEDS(6) <= '1';
	end if;
	if(c3_p0_rd_overflow = '1')then
		errorLEDS(7) <= '1';
	end if;
end if;

end process;

end Behavioral;

