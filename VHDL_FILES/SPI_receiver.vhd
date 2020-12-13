library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity SPI_receiver is

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

end SPI_receiver;


architecture Behavioral of SPI_receiver is

type states is (STATE_IDLE, STATE_WAIT, STATE_ENABLED);
signal actual_state: states := STATE_IDLE;

signal bit_counter: std_logic_vector(2 downto 0) := "000";

signal input_index: std_logic_vector(5 downto 0) := "100111";

signal output_signal : std_logic_vector(39 downto 0) := (others => '0');

signal clk_flag: std_logic := '0';

signal done_signal : std_logic := '0';

signal stateLED_signal : std_logic_vector(2 downto 0) := "000";

begin

stateLED <= stateLED_signal;

output <= output_signal;

process(clk_negedge)
begin

	if(rising_edge(clk_negedge)) then
		bit_counter <= bit_counter - 1;
	end if;

end process;

done <= done_signal;

process(clk)
begin

	if(rising_edge(clk)) then
		if(reset = '1') then
			actual_state <= STATE_IDLE;
		else
			done_signal <= '0';
			case (actual_state) is
				when STATE_IDLE =>
					if(en = '1') then
						output_signal <= (others => '0');
						actual_state <= STATE_WAIT;
						input_index <= "100111";
					end if;
					stateLED_signal(2) <= '1'; 
				when STATE_WAIT =>
					if(bit_counter = "111" and input = '0') then
						actual_state <= STATE_ENABLED;
					end if;
					stateLED_signal(1) <= '1';
				when STATE_ENABLED =>
					stateLED_signal(0) <= '1';
					if(clk_posedge = '1' and clk_flag = '0')then
						clk_flag <= '1';
						if(responseMode = '0') then
							if(input_index = "000000")then
								actual_state <= STATE_IDLE;
								done_signal <= '1';
							else
								input_index <= input_index - 1;
							end if;
						else
							if(input_index = "100000")then
								actual_state <= STATE_IDLE;
								done_signal <= '1';
							else
								input_index <= input_index - 1;
							end if;
						end if;
						output_signal(to_integer(unsigned(input_index))) <= input;
					elsif(clk_posedge = '0') then
						clk_flag <= '0';
					end if;
			end case;
		end if;
	end if;

end process;

end Behavioral;
