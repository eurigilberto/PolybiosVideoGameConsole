library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity SD_initiator is

	port(
		clk: in std_logic;
		sdcard_cs: out std_logic;
		sdcard_sclk: out std_logic;
		sdcard_mosi: out std_logic;
		sdcard_miso: in std_logic;
		
		byte_see : out std_logic_vector(7 downto 0);
		
		clk_posedge: in std_logic;
		clk_negedge: in std_logic;
		
		clk_count_limit: out std_logic_vector(7 downto 0);

		sclk_reset_out: out std_logic;
		
		dataLED: out std_logic_vector(7 downto 0);
		
		SevenSegmentEnable : out std_logic_vector(2 downto 0);
		
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

		write_done								: out std_logic
	);

end SD_initiator;

architecture Behavioral of SD_initiator is

signal clk_400khz_count: std_logic_vector(7 downto 0):="11111001";

signal clk_posedge_flag: std_logic := '0';
signal clk_negedge_flag: std_logic := '0';

signal SevenSegmentEnableSignal : std_logic_vector(2 downto 0) := "111";

type state is (STATE_POWER_ON, 
					STATE_DUMMY_CLK, 
					STATE_CMD0_SEND, 
					STATE_CMD0_WAIT, 
					STATE_CMD0_RECV, 
					STATE_CMD0_RECV_WAIT,
					STATE_CMD1_SEND, 
					STATE_CMD1_WAIT, 
					STATE_CMD1_RECV, 
					STATE_CMD1_RECV_WAIT,
					STATE_CMD_DONE,
					STATE_CMD_ERROR,
					SPEED_UP,
					STATE_WAIT_CALIB,
					STATE_CMD16_SEND,
					STATE_CMD16_WAIT,
					STATE_CMD16_RECV,
					STATE_CMD16_RECV_WAIT,
					STATE_CMD17_SEND,
					STATE_CMD17_WAIT,
					STATE_CMD17_RECV,
					STATE_CMD17_RECV_WAIT,
					STATE_DATA_BLOCK_READ,
					STATE_DATA_BLOCK_READ_WAIT
					);
signal actual_state: state := STATE_POWER_ON;

constant power_counter_max: integer := 150000;
signal power_counter: integer range 150000 downto 0 := 0;
signal power_on_done: std_logic := '0';

signal dummy_clk_counter: integer range 250 downto 0 := 0;

signal spi_command_enable: std_logic := '0';
signal spi_command_send: std_logic_vector(47 downto 0) := "010000000000000000000000000000000000000010010101";
signal spi_command_done: std_logic := '0';
signal spi_command_reset: std_logic := '1';

signal spi_receiver_enable: std_logic := '0';
signal spi_receiver_done: std_logic := '0';
signal spi_receiver_data: std_logic_vector(39 downto 0);
signal spi_receiver_reset: std_logic := '1';

signal spi_data_packet_receiver_enable: std_logic := '0';
signal spi_data_packet_receiver_done: std_logic := '0';

signal dataLED_Signal: std_logic_vector(7 downto 0):= "00000000";

signal sclk_reset: std_logic := '0';

signal btn_flag: std_logic := '0';

signal port_block_address: std_logic_vector(16 downto 0) := (others => '0');

component SD_data_reader
	
	port(
		clk: in std_logic;
		clk_posedge: in std_logic;
		clk_negedge: in std_logic;
		reset: in std_logic;
		en: in std_logic;
		input: in std_logic;
		done: out std_logic;

		byte_see : out std_logic_vector(7 downto 0);

		block_address : in std_logic_vector (16 downto 0);
		
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

		c3_calib_done                           : in std_logic
	);

end component;

component SDsender
	port(
			clk: in std_logic;
			clk_negedge: in std_logic;
			reset: in std_logic;
			en:in std_logic;
			data:in std_logic_vector(47 downto 0);
			output:out std_logic;
			done:out std_logic
		);
end component;

component SPI_receiver
	port(
		clk: in std_logic;
		clk_posedge: in std_logic;
		clk_negedge: in std_logic;
		reset: in std_logic;
		en: in std_logic;
		input: in std_logic;
		output: out std_logic_vector (39 downto 0);
		done: out std_logic;
		stateLED: out std_logic_vector(2 downto 0);
		responseMode: in std_logic
	);
end component;

signal spi_receiver_response_mode: std_logic := '0';

signal counter_address: std_logic_vector(16 downto 0) := (others => '0');

begin

sclk_reset_out <= sclk_reset;

clk_count_limit <= clk_400khz_count;

SPI_receiver_Inst : SPI_receiver

port map (
   clk => clk,
	clk_posedge => clk_posedge,
	clk_negedge => clk_negedge,
	reset => spi_receiver_reset,
	en => spi_receiver_enable,
	input => sdcard_miso,
	output => spi_receiver_data,
	done => spi_receiver_done,
	stateLED => open,
	responseMode => spi_receiver_response_mode
);

SDsender_Inst : SDsender

port map (
   clk => clk,
	clk_negedge => clk_negedge,
	reset => spi_command_reset,
	en => spi_command_enable,
	data => spi_command_send,
	output => sdcard_mosi,
	done => spi_command_done
);

process(clk)
begin
	if(rising_edge(clk)) then
		if(power_counter = power_counter_max) then
			power_on_done <= '1';
		else
			power_counter <= power_counter + 1;
		end if;
	end if;
end process;

SevenSegmentEnable <= SevenSegmentEnableSignal;

sdcard_sclk <= clk_posedge;

dataLED <= dataLED_Signal;

process(clk)
begin
	if(rising_edge(clk)) then
		spi_data_packet_receiver_enable <= '0';
		case(actual_state) is
			when STATE_POWER_ON =>
				write_done <= '0';
				spi_receiver_response_mode <= '0';
			
				spi_command_send <= (others => '0');
				sclk_reset <= '0';
				spi_command_enable <= '1';
				spi_command_reset <= '1';
				spi_receiver_enable <= '0';
				spi_receiver_reset <= '1';

				sclk_reset <= '1';
				sdcard_cs <= '1';
				if(power_on_done = '1') then
					dataLED_Signal(7) <= '1';
					actual_state <= STATE_DUMMY_CLK;
				else
					actual_state <= STATE_POWER_ON;
				end if;
				dataLED_Signal <= "10000001"; 
			when STATE_DUMMY_CLK =>
				spi_receiver_response_mode <= '0';
				
				spi_command_send <= (others => '0');
				sclk_reset <= '0';
				spi_command_enable <= '0';
				spi_command_reset <= '0';
				spi_receiver_enable <= '0';
				spi_receiver_reset <= '1';

				sdcard_cs <= '1';
				if(clk_negedge = '1' and clk_negedge_flag = '0') then
					clk_negedge_flag <= '1';
					if(dummy_clk_counter >= 74 and sdcard_miso = '1')then
						actual_state <= STATE_CMD0_SEND;
					else
						actual_state <= STATE_DUMMY_CLK;
					end if;
				elsif(clk_negedge = '0')then
					clk_negedge_flag <= '0';
				end if;
				
				if(clk_posedge = '1' and clk_posedge_flag = '0') then
					clk_posedge_flag <= '1';
					dummy_clk_counter <= dummy_clk_counter + 1;
				elsif(clk_posedge = '0')then
					clk_posedge_flag <= '0';
				end if;

				dataLED_Signal <= "10000011";
			when STATE_CMD0_SEND =>
			
				spi_receiver_response_mode <= '0';
			
				sclk_reset <= '0';
				spi_command_enable <= '0';
				spi_command_reset <= '0';
				spi_receiver_enable <= '0';
				spi_receiver_reset <= '0';

				sdcard_cs <= '0';
				spi_command_send <= "010000000000000000000000000000000000000010010101";
				spi_command_enable <= '1';
				actual_state <= STATE_CMD0_WAIT;

				dataLED_Signal <= "11000000";
				
			when STATE_CMD0_WAIT =>
			
				spi_receiver_response_mode <= '0';
			
				sdcard_cs <= '0';
				spi_command_send <= (others => '0');
				sclk_reset <= '0';
				spi_command_enable <= '0';
				spi_command_reset <= '0';
				spi_receiver_enable <= '0';
				spi_receiver_reset <= '0';

				dataLED_Signal(6) <= '1';
				if(spi_command_done = '1')then
					actual_state <= STATE_CMD0_RECV;
				end if;

				dataLED_Signal <= "10100000";
				
			when STATE_CMD0_RECV =>
			
				spi_receiver_response_mode <= '0';
			
				sdcard_cs <= '0';
				spi_command_send <= (others => '0');
				sclk_reset <= '0';
				spi_command_enable <= '0';
				spi_command_reset <= '0';
				spi_receiver_reset <= '0';

				spi_receiver_enable <= '1';
				actual_state <= STATE_CMD0_RECV_WAIT;

				dataLED_Signal <= "11100000";
				
			when STATE_CMD0_RECV_WAIT =>
			
				spi_receiver_response_mode <= '0';
			
				sdcard_cs <= '0';
				spi_command_send <= (others => '0');
				sclk_reset <= '0';
				spi_command_enable <= '0';
				spi_command_reset <= '0';
				spi_receiver_enable <= '0';
				spi_receiver_reset <= '0';
				dataLED_Signal(7) <= '1';
				if(spi_receiver_done = '1')then
					dataLED_Signal <= spi_receiver_data(39 downto 32);
					SevenSegmentEnableSignal <= "101";
					actual_state <= STATE_CMD1_SEND;
				end if;
				
				dataLED_Signal <= "10010000";

			when STATE_CMD1_SEND =>
				spi_receiver_response_mode <= '0';
			
				sclk_reset <= '0';
				spi_command_reset <= '0';
				spi_receiver_enable <= '0';
				spi_receiver_reset <= '0';
				dataLED_Signal(6) <= '0'; 
				sdcard_cs <= '0';
				spi_command_send <= "010000010000000000000000000000000000000001111001";
				spi_command_enable <= '1';
				actual_state <= STATE_CMD1_WAIT;
				dataLED_Signal <= "10000001";
			when STATE_CMD1_WAIT =>
				spi_receiver_response_mode <= '0';
			
				sdcard_cs <= '0';
				spi_command_send <= (others => '0');
				sclk_reset <= '0';
				spi_command_enable <= '0';
				spi_command_reset <= '0';
				spi_receiver_enable <= '0';
				spi_receiver_reset <= '0';
				dataLED_Signal(5) <= '1';
				if(spi_command_done = '1')then
					actual_state <= STATE_CMD1_RECV;
				end if;
				dataLED_Signal <= "11000001";
			when STATE_CMD1_RECV =>
				spi_receiver_response_mode <= '0';
			
				sdcard_cs <= '0';
				spi_command_send <= (others => '0');
				sclk_reset <= '0';
				spi_command_enable <= '0';
				spi_command_reset <= '0';
				spi_receiver_reset <= '0';

				spi_receiver_enable <= '1';
				actual_state <= STATE_CMD1_RECV_WAIT;

				dataLED_Signal <= "11100001";
				
			when STATE_CMD1_RECV_WAIT =>
			
				spi_receiver_response_mode <= '0';
			
				sdcard_cs <= '0';
				spi_command_send <= (others => '0');
				sclk_reset <= '0';
				spi_command_enable <= '0';
				spi_command_reset <= '0';
				spi_receiver_enable <= '0';
				spi_receiver_reset <= '0';
				
				if(spi_receiver_done = '1')then
					dataLED_Signal <= spi_receiver_data(39 downto 32);
					SevenSegmentEnableSignal <= not(SevenSegmentEnableSignal);
					if(spi_receiver_data(39 downto 32) /= "00000000") then
						actual_state <= STATE_CMD1_SEND;
					else
						actual_state <= SPEED_UP;
					end if;
				end if;
				dataLED_Signal <= "10010001";
			when SPEED_UP =>
				SevenSegmentEnableSignal <= "000";

				spi_receiver_response_mode <= '0';
				
				clk_400khz_count <= "00000100";
				actual_state <= STATE_WAIT_CALIB;

				dataLED_Signal <= "10010010";
			
			when STATE_WAIT_CALIB =>
				dataLED_Signal <= "00000010";
				if(c3_calib_done = '1') then
					actual_state <= STATE_CMD16_SEND;
				end if;
				dataLED_Signal <= "10011111";
			when STATE_CMD16_SEND =>
				spi_receiver_response_mode <= '0';
			
				sclk_reset <= '0';
				spi_command_enable <= '0';
				spi_command_reset <= '0';
				spi_receiver_enable <= '0';
				spi_receiver_reset <= '0';

				sdcard_cs <= '0';
				spi_command_send <= "01"&"010000"&"00000000000000000000001000000000"&"1111111"&'1';
				spi_command_enable <= '1';
				actual_state <= STATE_CMD16_WAIT;
				
			when STATE_CMD16_WAIT =>
			
				spi_receiver_response_mode <= '0';
			
				sdcard_cs <= '0';
				spi_command_send <= (others => '0');
				sclk_reset <= '0';
				spi_command_enable <= '0';
				spi_command_reset <= '0';
				spi_receiver_enable <= '0';
				spi_receiver_reset <= '0';

				dataLED_Signal <= "00111000";
				if(spi_command_done = '1')then
					actual_state <= STATE_CMD16_RECV;
				end if;
				
			when STATE_CMD16_RECV =>
			
				spi_receiver_response_mode <= '0';
			
				sdcard_cs <= '0';
				spi_command_send <= (others => '0');
				sclk_reset <= '0';
				spi_command_enable <= '0';
				spi_command_reset <= '0';
				spi_receiver_reset <= '0';

				spi_receiver_enable <= '1';
				actual_state <= STATE_CMD16_RECV_WAIT;
				
			when STATE_CMD16_RECV_WAIT =>
				spi_receiver_response_mode <= '0';
			
				sdcard_cs <= '0';
				spi_command_send <= (others => '0');
				sclk_reset <= '0';
				spi_command_enable <= '0';
				spi_command_reset <= '0';
				spi_receiver_enable <= '0';
				spi_receiver_reset <= '0';
				
				if(spi_receiver_done = '1')then
					dataLED_Signal <= spi_receiver_data(39 downto 32);
					SevenSegmentEnableSignal <= "101";
					if(spi_receiver_data(39 downto 32) /= "00000000") then
						actual_state <= STATE_CMD_ERROR;
						dataLED_Signal <= "00001000";
					else
						actual_state <= STATE_CMD17_SEND;
					end if;

				end if;
				
			when STATE_CMD17_SEND =>
			
				spi_receiver_response_mode <= '0';
			
				sclk_reset <= '0';
				spi_command_enable <= '0';
				spi_command_reset <= '0';
				spi_receiver_enable <= '0';
				spi_receiver_reset <= '0';

				sdcard_cs <= '0';
				spi_command_send <= "01"&"010001"&"000000"&counter_address&"000000000"&"1111111"&'1';
				spi_command_enable <= '1';
				actual_state <= STATE_CMD17_WAIT;
				
			when STATE_CMD17_WAIT =>
				spi_receiver_response_mode <= '0';
			
				sdcard_cs <= '0';
				spi_command_send <= (others => '0');
				sclk_reset <= '0';
				spi_command_enable <= '0';
				spi_command_reset <= '0';
				spi_receiver_enable <= '0';
				spi_receiver_reset <= '0';

				dataLED_Signal <= "00111001";
				if(spi_command_done = '1')then
					actual_state <= STATE_CMD17_RECV;
				end if;
				
			when STATE_CMD17_RECV =>
				spi_receiver_response_mode <= '1';
			
				sdcard_cs <= '0';
				spi_command_send <= (others => '0');
				sclk_reset <= '0';
				spi_command_enable <= '0';
				spi_command_reset <= '0';
				spi_receiver_reset <= '0';

				spi_receiver_enable <= '1';
				actual_state <= STATE_CMD17_RECV_WAIT;
				
			when STATE_CMD17_RECV_WAIT =>
				spi_receiver_response_mode <= '1';
				
				sdcard_cs <= '0';
				spi_command_send <= (others => '0');
				sclk_reset <= '0';
				spi_command_enable <= '0';
				spi_command_reset <= '0';
				spi_receiver_enable <= '0';
				spi_receiver_reset <= '0';
				
				if(spi_receiver_done = '1')then
					dataLED_Signal <= spi_receiver_data(39 downto 32);
					SevenSegmentEnableSignal <= "101";
					if(spi_receiver_data(39 downto 32) /= "00000000") then
						actual_state <= STATE_CMD_ERROR;
						dataLED_Signal <= "00001001";
					else
						actual_state <= STATE_DATA_BLOCK_READ;
					end if;

				end if;

			when STATE_DATA_BLOCK_READ =>

				spi_data_packet_receiver_enable <= '1';
				port_block_address <= counter_address;
				actual_state <= STATE_DATA_BLOCK_READ_WAIT;

			when STATE_DATA_BLOCK_READ_WAIT =>
				
				dataLED_Signal <= counter_address(16 downto 9);

				if(spi_data_packet_receiver_done = '1') then
					if(counter_address >= "11111111111111111") then
						actual_state <= STATE_CMD_DONE;
					else
						counter_address <= counter_address + 1;
						actual_state <= STATE_CMD17_SEND;
					end if;
				end if;

			when STATE_CMD_DONE =>
				write_done <= '1';
				sdcard_cs <= '0';
				sclk_reset <= '0';
				spi_command_enable <= '0';
				spi_command_reset <= '0';
				spi_receiver_enable <= '0';
				spi_receiver_reset <= '0'; 
				dataLED_Signal <= "11011011";
				SevenSegmentEnableSignal <= "011";
			
			when STATE_CMD_ERROR =>

				dataLED_Signal <= "10101010";
			when others =>
			
				sdcard_cs <= '0';
				sclk_reset <= '0';
				spi_command_enable <= '0';
				spi_command_reset <= '0';
				spi_receiver_enable <= '0';
				spi_receiver_reset <= '0';
				spi_command_send <= not(spi_command_send);
				
		end case;
	end if;
end process;

SD_data_reader_inst: SD_data_reader

port map(
	clk => clk,
	clk_posedge => clk_posedge,
	clk_negedge => clk_negedge,
	reset => '0',
	en => spi_data_packet_receiver_enable,
	input => sdcard_miso,
	done => spi_data_packet_receiver_done,

	byte_see => byte_see,

	block_address => port_block_address,
	
	c3_p2_cmd_clk => c3_p2_cmd_clk,
	c3_p2_cmd_en => c3_p2_cmd_en,
	c3_p2_cmd_instr => c3_p2_cmd_instr,
	c3_p2_cmd_bl => c3_p2_cmd_bl,
	c3_p2_cmd_byte_addr => c3_p2_cmd_byte_addr,
	c3_p2_cmd_empty => c3_p2_cmd_empty,
	c3_p2_cmd_full => c3_p2_cmd_full,
	
	c3_p2_wr_clk => c3_p2_wr_clk,
	c3_p2_wr_en => c3_p2_wr_en,
	c3_p2_wr_mask => c3_p2_wr_mask,
	c3_p2_wr_data => c3_p2_wr_data,
	c3_p2_wr_full => c3_p2_wr_full,
	c3_p2_wr_empty => c3_p2_wr_empty,
	c3_p2_wr_count => c3_p2_wr_count,
	c3_p2_wr_underrun => c3_p2_wr_underrun,
	c3_p2_wr_error => c3_p2_wr_error,

	c3_calib_done => c3_calib_done
);

end Behavioral;