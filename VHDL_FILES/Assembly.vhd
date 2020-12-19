library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library work;
use work.assembly_components_definition.all;

entity Assembly is

	port(
      clks: in std_logic;
		sdcard_cs: out std_logic;
		sdcard_sclk: out std_logic;
		sdcard_mosi: out std_logic;
		sdcard_miso: in std_logic;
		
		dataLED: out std_logic_vector(7 downto 0);
		
		selector_button : in std_logic;
		processor_button : in std_logic;

		SevenSegmentEnable : out std_logic_vector(2 downto 0);
        
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
		
		out_p6 : out std_logic_vector(3 downto 0);
		input_p6 : in std_logic_vector(3 downto 0);
		
		out_p7 : out std_logic_vector(3 downto 0);
		input_p7 : in std_logic_vector(3 downto 0)
	);

end Assembly;

architecture Behavioral of Assembly is

signal errorLEDS : std_logic_vector(7 downto 0) := (others => '0');
signal choose : std_logic := '0';
signal dataLEDS : std_logic_vector(7 downto 0) := (others => '0');
signal dataLEDsignal : std_logic_vector(7 downto 0) := (others => '0');
signal proLEDS : std_logic_vector(7 downto 0) := (others => '0');

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

--SDCARD freq
    signal sclk_reset: std_logic;
    signal clk_posedge: std_logic;
    signal clk_negedge: std_logic;
    signal clk_freq_selector: std_logic;

signal video_clock : std_logic;
signal video_clock_2x : std_logic;

signal controller_a_signal : std_logic_vector(13 downto 0);
signal controller_b_signal : std_logic_vector(13 downto 0);

--GET VIDEO INFO
signal video_info_data_out : std_logic_vector(23 downto 0);
signal video_info_cmd: std_logic_vector(1 downto 0);

--SET VIDEO LAYERS DATA
signal video_layers_data_in: std_logic_vector(23 downto 0);
signal video_layers_cmd: std_logic_vector(3 downto 0);
signal video_layers_input_enabled: std_logic;

begin

SevenSegmentEnable(2) <= not(write_done);
SevenSegmentEnable(1) <= not(selector_button);
SevenSegmentEnable(0) <= processor_button;

dataLEDsignal <= dataLEDS when write_done = '0' else
			  errorLEDS;
			  
dataLED <= dataLEDsignal when selector_button = '0' else
              proLEDS;
              
controller_system_inst: controllers
    port map(
        clk                                     => video_clock_2x,
        
        out_p6                                  => out_p6,
        input_p6                                => input_p6,
        controller_a                           => controller_a_signal,

        out_p7                                  => out_p7,
        input_p7                                => input_p7,
        controller_b                            => controller_b_signal
    );

Processor_inst: Processor
	port map(
		clk												 => video_clock_2x,

		calib_done 										 => write_done,
		
		--GET VIDEO INFO
		video_info_data_out => video_info_data_out,
		video_info_cmd => video_info_cmd,

		--SET VIDEO LAYERS DATA
		video_layers_data_in => video_layers_data_in,
		video_layers_cmd => video_layers_cmd,
		video_layers_input_enabled => video_layers_input_enabled,

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
      btn				                        => not(processor_button),
        
		controller_a                            => controller_a_signal,
		controller_b			                => controller_b_signal
	);

SD_CARD_CLK_inst : SD_CARD_CLK

	port map(
      clk => video_clock_2x,
		sclk_reset => sclk_reset,  
		clk_posedge => clk_posedge, 
		clk_negedge => clk_negedge,
		clk_freq_selector => clk_freq_selector
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

SD_initiator_inst : SD_initiator
port map(
    clk => video_clock_2x,
    sdcard_cs => sdcard_cs,
    sdcard_sclk => sdcard_sclk,
    sdcard_mosi => sdcard_mosi,
    sdcard_miso => sdcard_miso,
	 
	 byte_see => open,
    
    dataLED => dataLEDS,
    
    SevenSegmentEnable => SevenSegmentEnableSignal,

    clk_posedge => clk_posedge,
    clk_negedge => clk_negedge,
    clk_freq_selector => clk_freq_selector,
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
        clkOut1P =>video_clock_2x
    );

video_freq_inst: video_freq
	port map(vid_clk_2x => video_clock_2x,
		  video_clk => video_clock);

VideoSystemInst : VideoSystem
	port map(
		video_clock_2x => video_clock_2x,
		video_clk => video_clock,
		
		HSync => HSync,
		VSync => VSync,
		Red => Red,
		Green => Green,
		Blue => Blue,
		
		system_loaded => write_done,

		--GET VIDEO INFO
		video_info_data_out => video_info_data_out,
		video_info_cmd => video_info_cmd,

		--SET VIDEO LAYERS DATA
		video_layers_data_in => video_layers_data_in,
		video_layers_cmd => video_layers_cmd,
		video_layers_input_enabled => video_layers_input_enabled,
		
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

