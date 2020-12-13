library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity SD_data_reader is

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

end SD_data_reader;

architecture Behavioral of SD_data_reader is

type states is (STATE_IDLE, 
				STATE_WAIT, 
				STATE_DATA_TOKEN_READ,
				STATE_CHECK_DATA_TOKEN,
				STATE_WAIT_2,
				STATE_READING_DATA,
				STATE_WRITE_REGISTER,
				STATE_INCREASE_ADDRESS,
				STATE_WAIT_3,
				STATE_CRC
				);
signal actual_state: states := STATE_IDLE;

signal bit_counter: std_logic_vector(2 downto 0) := "000";

signal data_token_counter: std_logic_vector(2 downto 0) := "111";

signal data_token : std_logic_vector(7 downto 0) := "00000000";

signal data_register_counter : std_logic_vector(4 downto 0) := (others => '1');

signal data_register : std_logic_vector(31 downto 0) := (others => '0');

signal clk_flag: std_logic := '0';

signal done_signal : std_logic := '0';

signal stateLED_signal : std_logic_vector(2 downto 0) := "000";

signal memory_port_enable: std_logic := '0';

signal memory_port_address_block: std_logic_vector(8 downto 0) := (others => '0');

signal address_to_write_signal : std_logic_vector(29 downto 0) := (others => '0');

signal crc_counter : std_logic_vector(7 downto 0) := (others => '0');

signal block_address_signal : std_logic_vector (16 downto 0) := (others => '0');

component sd_card_port_controller
	port (
	  clk                                     : in std_logic;
  
	  enable                                  : in std_logic;
  
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
  
	  data_to_write                           : in std_logic_vector(31 downto 0);
  
	  address_to_write                        : in std_logic_vector(29 downto 0)
	) ;
end component;

signal byte_see_signal : std_logic_vector(7 downto 0) := (others => '1');

--BEGIN--BEGIN--BEGIN--BEGIN--BEGIN--BEGIN--BEGIN--BEGIN--BEGIN--BEGIN--BEGIN--BEGIN--BEGIN
--BEGIN--BEGIN--BEGIN--BEGIN--BEGIN--BEGIN--BEGIN--BEGIN--BEGIN--BEGIN--BEGIN--BEGIN--BEGIN
--BEGIN--BEGIN--BEGIN--BEGIN--BEGIN--BEGIN--BEGIN--BEGIN--BEGIN--BEGIN--BEGIN--BEGIN--BEGIN

begin

byte_see <= byte_see_signal;

done <= done_signal;

process(clk_negedge)
begin

	if(rising_edge(clk_negedge)) then
		bit_counter <= bit_counter - 1;
	end if;

end process;

process(clk)
begin

	if(rising_edge(clk)) then
		if(reset = '1') then
			actual_state <= STATE_IDLE;
		else
			done_signal <= '0';
			memory_port_enable <= '0';
			case (actual_state) is
				when STATE_IDLE =>
				
					if(en = '1') then
						block_address_signal <= block_address;
						data_token_counter <= "111";
						actual_state <= STATE_WAIT;
					end if;
					memory_port_address_block <= (others => '0');
					stateLED_signal(2) <= '1';
					
				when STATE_WAIT =>
				
					if(bit_counter = "111") then
						actual_state <= STATE_DATA_TOKEN_READ;
					end if;
					stateLED_signal(1) <= '1';
					
				when STATE_DATA_TOKEN_READ =>
				
					stateLED_signal(0) <= '1';
					
					if(clk_posedge = '1' and clk_flag = '0')then
						clk_flag <= '1';
						if(data_token_counter = "000")then
							actual_state <= STATE_CHECK_DATA_TOKEN;
							data_token_counter <= "111";
						else
							data_token_counter <= data_token_counter - 1;
						end if;
						data_token(to_integer(unsigned(data_token_counter))) <= input;
					elsif(clk_posedge = '0') then
						clk_flag <= '0';
					end if;
				
				when STATE_CHECK_DATA_TOKEN =>
						
					if(data_token = "11111110") then
						actual_state <= STATE_WAIT_2;
					else
						actual_state <= STATE_WAIT;
					end if;
				when STATE_WAIT_2 =>

					if(bit_counter = "111") then
						actual_state <= STATE_READING_DATA;
					end if;
					stateLED_signal(1) <= '1';
					
				when STATE_READING_DATA => 

					if(clk_posedge = '1' and clk_flag = '0')then
						clk_flag <= '1';
						if(data_register_counter = "00000")then
							actual_state <= STATE_WRITE_REGISTER;
							if(memory_port_address_block = "000000001") then
								byte_see_signal <= data_register(15 downto 8);
							end if;
							data_register_counter <= (others => '1');
						else
							data_register_counter <= data_register_counter - 1;
						end if;
						data_register <= data_register(30 downto 0)&input;
					elsif(clk_posedge = '0') then
						clk_flag <= '0';
					end if;
				
				when STATE_WRITE_REGISTER =>

					memory_port_enable <= '1';
					actual_state <= STATE_INCREASE_ADDRESS;

				when STATE_INCREASE_ADDRESS =>

					if(memory_port_address_block = "001111111") then
						actual_state <= STATE_WAIT_3;
						memory_port_address_block <= (others => '0');
					else
						memory_port_address_block <= memory_port_address_block + 1;
						actual_state <= STATE_WAIT_2;
					end if;

				when STATE_WAIT_3 =>
				
					if(bit_counter = "111") then
						actual_state <= STATE_CRC;
						crc_counter <= "00000000";
					end if;
					stateLED_signal(1) <= '1';

				when STATE_CRC =>

					if(clk_posedge = '1' and clk_flag = '0')then
						clk_flag <= '1';
						if(crc_counter = "01111111")then
							actual_state <= STATE_IDLE;
							crc_counter <= (others => '0');
							done_signal <= '1';
						else
							crc_counter <= crc_counter + 1;
						end if;
						--data_register(to_integer(unsigned(data_token_counter))) <= input;
					elsif(clk_posedge = '0') then
						clk_flag <= '0';
					end if;
				
				when others =>

					memory_port_address_block <= (others => '0');
			end case;
		end if;
	end if;

end process;

sd_card_port_controller_inst : sd_card_port_controller
	port map(
	
	  clk => clk,
  
	  enable => memory_port_enable,
  
	  c3_p2_cmd_clk => c3_p2_cmd_clk,
	  c3_p2_cmd_en => c3_p2_cmd_en,
	  c3_p2_cmd_instr => c3_p2_cmd_instr,
	  c3_p2_cmd_bl => c3_p2_cmd_bl,
	  c3_p2_cmd_byte_addr => c3_p2_cmd_byte_addr,
	  c3_p2_cmd_empty => c3_p2_cmd_empty,
	  c3_p2_cmd_full => c3_p2_cmd_full,
	  
	  c3_p2_wr_clk  => c3_p2_wr_clk,
	  c3_p2_wr_en => c3_p2_wr_en,
	  c3_p2_wr_mask => c3_p2_wr_mask,
	  c3_p2_wr_data => c3_p2_wr_data,
	  c3_p2_wr_full => c3_p2_wr_full,
	  c3_p2_wr_empty => c3_p2_wr_empty,
	  c3_p2_wr_count => c3_p2_wr_count,
	  c3_p2_wr_underrun => c3_p2_wr_underrun,
	  c3_p2_wr_error => c3_p2_wr_error,
  
	  c3_calib_done => c3_calib_done,
  
	  data_to_write => data_register,
  
	  address_to_write => address_to_write_signal
		) ;

address_to_write_signal <= "0000"&block_address_signal(16 downto 0)&memory_port_address_block(6 downto 0)&"00";

end Behavioral;

