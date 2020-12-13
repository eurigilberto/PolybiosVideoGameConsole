library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity SDsender is

	port(
		clk: in std_logic;
		clk_negedge: in std_logic;
		reset: in std_logic;
		en:in std_logic;
		data:in std_logic_vector(47 downto 0);
		output:out std_logic;
		done:out std_logic
	);

end SDsender;

architecture Behavioral of SDsender is

signal bit_counter: std_logic_vector(2 downto 0) := "000";
type states is (STATE_IDLE, STATE_SYNC, STATE_ENABLED);

signal actual_state: states := STATE_IDLE;
signal saved_data: std_logic_vector(47 downto 0) := "010000000000000000000000000000000000000010010101";
signal output_index: integer range 47 downto 0 := 47;

signal flag: std_logic := '0';

signal done_signal: std_logic := '0';

begin

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
		if(reset = '1')then
			actual_state <= STATe_IDLE;
			output <= '1';
		else
			done_signal <= '0';
			case(actual_state) is
				when STATE_IDLE =>
					output <= '1';
					if(en = '1') then
						actual_state <= STATE_SYNC;
						output_index <= 47;
						saved_data <= data;
					else
						saved_data <= not(saved_data);
					end if;
				when STATE_SYNC =>
					output <= '1';
					if(bit_counter = "111") then
						flag <= '1';
						actual_state <= STATE_ENABLED;
					end if;
				when STATE_ENABLED =>
					output <= saved_data(output_index);
					if (clk_negedge = '1' and flag = '0') then
						flag <= '1';
						if(output_index = 0)then
							actual_state <= STATE_IDLE;
							done_signal <= '1';
						else
							output_index <= output_index - 1;
						end if;
					elsif (clk_negedge = '0') then
						flag <= '0';
					end if;
				end case;
		end if;
	end if;

end process;

end Behavioral;

