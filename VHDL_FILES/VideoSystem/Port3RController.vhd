library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.ALL;

entity Port3RController is
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
end Port3RController;

architecture Behavioral of Port3RController is

signal cmd_en_signal : std_logic := '0';
signal rd_en_signal : std_logic := '0';
signal c3_p3_cmd_bl_signal : std_logic_vector(5 downto 0) := (others => '0');
signal port_data_register_signal : std_logic_vector(31 downto 0) := "10101010101010101010101010101010";
signal read_data_signal : std_logic := '0';

signal requested_address : std_logic_vector (29 downto 0);

type state is (
	STATE_IDLE,
	STATE_CMD_SEND,
	STATE_WAIT_TO_READ,
	STATE_READING_DATA
);

signal actual_state : state := STATE_IDLE;

signal system_state : std_logic_vector(7 downto 0):=(others => '0');

begin

port_data_register <= port_data_register_signal;

read_data <= read_data_signal;

c3_p3_rd_en <= rd_en_signal;
c3_p3_cmd_en <= cmd_en_signal;

c3_p3_cmd_clk <= clk;
c3_p3_rd_clk <= clk;

c3_p3_cmd_byte_addr <= requested_address;
c3_p3_cmd_bl <= c3_p3_cmd_bl_signal;
c3_p3_cmd_instr <= "001";

process(clk)
begin
	if(rising_edge(clk)) then
		cmd_en_signal <= '0';
		rd_en_signal <= '0';
		read_data_signal <= '0';
		case (actual_state) is
			when STATE_IDLE =>
				if(enable = '1') then
					actual_state <= STATE_CMD_SEND;
					c3_p3_cmd_bl_signal <= port_cmd_bl;
					requested_address <= "0000"&port_row_address&port_bank_address&port_col_address&'0'; -- se quito la multiplicacion por 2
				end if;
			when STATE_CMD_SEND =>
				cmd_en_signal <= '1';
				actual_state <= STATE_WAIT_TO_READ;
			when STATE_WAIT_TO_READ =>
				if(c3_p3_rd_empty = '0' and c3_p3_rd_count = '0'&c3_p3_cmd_bl_signal + 1)then
					rd_en_signal <= '1';
					actual_state <= STATE_READING_DATA;
				end if;
			when STATE_READING_DATA =>
				port_data_register_signal <= c3_p3_rd_data;
				read_data_signal <= '1';
				rd_en_signal <= '1';
				if(c3_p3_rd_count = "0000001" or c3_p3_rd_count = "0000000") then--if(c3_p3_rd_count = "0000001" or c3_p3_rd_count = "0000000") then
					rd_en_signal <= '0'; 
					actual_state <= STATE_IDLE;
				end if;
		end case;

	end if;

end process;


end Behavioral;