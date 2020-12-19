library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity load_buffer_system is

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

end load_buffer_system;

architecture Behavioral of load_buffer_system is

component Port3RController
    Port (
			port_cmd_bl : in std_logic_vector(5 downto 0);
			enable : in std_logic;
			clk : in std_logic;

			port_data_register : out std_logic_vector(31 downto 0);

			port_row_address : in std_logic_vector(12 downto 0);
			port_col_address : in std_logic_vector(9 downto 0);
			port_bank_address : in std_logic_vector(1 downto 0);

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
			  
			read_data : out STD_logic
			);
end component;

signal port_data_register : std_logic_vector(31 downto 0);

type states is (
					STATE_NOTHING,
					STATE_IDLE,
					STATE_READ_FIRST_PART,
					STATE_WAITING_READ,
					STATE_READING,
					STATE_CHECK_BL,
					STATE_READ_2,
					STATE_WAITING_READ_2,
					STATE_READING_2
					);
					
signal actual_state : states := STATE_NOTHING;

signal port_cmd_bl : std_logic_vector(5 downto 0) := (others => '0');

signal read_data_signal : std_logic;
					
constant horizontal_size : std_logic_vector(6 downto 0) := "1010000";
constant vertical_size : std_logic_vector(8 downto 0) := "100000000";
constant pixel_total : std_logic_vector(14 downto 0) := "101000000000000";

constant horizontal_counter_limit : std_logic_vector(6 downto 0) := "0111111";

signal port_row_address : std_logic_vector(12 downto 0);
signal port_col_address : std_logic_vector(9 downto 0);
signal port_bank_address : std_logic_vector(1 downto 0);

signal register_counter: std_logic_vector(5 downto 0);

signal BRAM_address: std_logic_vector(5 downto 0) := (others => '0');

signal BRAM_write_ena: STD_LOGIC_VECTOR(0 DOWNTO 0) := "0";

signal enable_port: std_logic := '0';

signal data_buffer: std_logic_vector(31 downto 0) := (others => '0');

begin

process(clk)

variable start_load_address: unsigned(27 downto 0):= (others => '0');
variable temporal_address : std_logic_vector(27 downto 0):= (others => '0');
variable temp : std_logic_vector(6 downto 0) := (others => '0');

begin
	if(rising_edge(clk)) then
        enable_port <= '0';
		  BRAM_write_ena <= "0";
		  busy <= '1';
		case (actual_state) is
			when STATE_NOTHING =>
				 if(start_system = '1') then
					  actual_state <= STATE_IDLE;
				 end if;
				 busy <= '0';
			when STATE_IDLE =>
				if(enable = '1') then
					actual_state <= STATE_READ_FIRST_PART;
				end if;
				busy <= '0';
			when STATE_READ_FIRST_PART =>
				 enable_port <= '1';
				 
				if(unsigned(vertical_address_offset) >= unsigned(vertical_size)) then
					start_load_address := (unsigned(vertical_address_offset) - unsigned(vertical_size)) * unsigned(horizontal_size);
				else
					start_load_address := "0000000000000" &(unsigned(vertical_address_offset) * unsigned(horizontal_size));
				end if;
				start_load_address := unsigned(base_layer_address) + unsigned(horizontal_address_offset) + start_load_address;
				 
				 temporal_address := std_logic_vector(start_load_address);
				 port_row_address <= temporal_address(23 downto 11);
				 port_bank_address <= temporal_address(10 downto 9);
				 port_col_address <= temporal_address(8 downto 0)&'0';
				 temp := std_logic_vector(unsigned(horizontal_size) - unsigned(horizontal_address_offset) - 1);
				 if(temp > "0111111") then
						temp := "0111111";
				 end if;
				 port_cmd_bl <= temp(5 downto 0);
				 register_counter <= temp(5 downto 0);
				 actual_state <= STATE_WAITING_READ;
				 BRAM_address <= (others => '0');
					
			when STATE_WAITING_READ =>
				if(read_data_signal = '1')then
				  actual_state <= STATE_READING;
				  data_buffer <= port_data_register;
				  BRAM_write_ena <= "1";
				end if;
			when STATE_READING =>
				data_buffer <= port_data_register;
				BRAM_address <= std_logic_vector(unsigned(BRAM_address) + 1);
				BRAM_write_ena <= "1";
				if(read_data_signal = '0') then
					  BRAM_write_ena <= "0";
					  BRAM_address <= BRAM_address;
					  actual_state <= STATE_CHECK_BL;
				end if;
			
			when STATE_CHECK_BL =>
				if(register_counter = "111111") then
					actual_state <= STATE_IDLE;
					
				else
					actual_state <= STATE_READ_2;
				end if;
			
			when STATE_READ_2 =>
				enable_port <= '1';
				
				if(unsigned(vertical_address_offset) >= unsigned(vertical_size)) then
					start_load_address := (unsigned(vertical_address_offset) - unsigned(vertical_size)) * unsigned(horizontal_size);
				else
					start_load_address := "0000000000000" &(unsigned(vertical_address_offset) * unsigned(horizontal_size));
				end if;
				start_load_address := unsigned(base_layer_address) + start_load_address;

				temporal_address := std_logic_vector(start_load_address);
				
				port_row_address <= temporal_address(23 downto 11);
				port_bank_address <= temporal_address(10 downto 9);
				port_col_address <= temporal_address(8 downto 0)&'0';
				
				temp := std_logic_vector(unsigned(horizontal_counter_limit) - unsigned(register_counter) - 1);
				port_cmd_bl <= temp(5 downto 0);
				register_counter <= std_logic_vector(unsigned(register_counter) + unsigned(temp(5 downto 0)));
				actual_state <= STATE_WAITING_READ_2;
			
			when STATE_WAITING_READ_2 =>
				if(read_data_signal = '1')then
				  actual_state <= STATE_READING_2;
				  data_buffer <= port_data_register;
				  BRAM_address <= std_logic_vector(unsigned(BRAM_address) + 1);
				  BRAM_write_ena <= "1";
				end if;
			when STATE_READING_2 =>
				data_buffer <= port_data_register;
				BRAM_address <= std_logic_vector(unsigned(BRAM_address) + 1);
				BRAM_write_ena <= "1";
				if(read_data_signal = '0') then
					  BRAM_write_ena <= "0";
					  actual_state <= STATE_IDLE;
					  busy <= '0';
				end if;
		end case;

	end if;

end process;

wea <= BRAM_write_ena;
addra_block <= BRAM_address;
dina <= data_buffer;

Port3RController_inst: Port3RController
    port map (
			port_cmd_bl => port_cmd_bl,
			enable => enable_port,
			clk => clk,

			port_data_register => port_data_register,

			port_row_address => port_row_address,
			port_col_address => port_col_address,
			port_bank_address => port_bank_address,

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
			  
			read_data => read_data_signal
			);

end Behavioral;

