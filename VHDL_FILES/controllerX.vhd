library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity controllerX is

	port(
		clk : in std_logic;
		volt : out std_logic_vector(3 downto 0);
		input : in std_logic_vector(3 downto 0);
		controlOut : out std_logic_vector(9 downto 0)
	);

end controllerX;

architecture Behavioral of controllerX is

signal controlVal : std_logic_vector(9 downto 0) := (others => '0');

signal counter : std_logic_vector(8 downto 0) := (others => '0');

signal clk_controller : std_logic := '0';

signal volt_signal: std_logic_vector(3 downto 0) := (others => '0');

begin

process(clk)
begin

	if(rising_edge(clk))then
		counter <= std_logic_vector(unsigned(counter) + 1);
		if(counter = "111111111")then
			counter <= (others => '0');
			clk_controller <= not(clk_controller);
		end if;
	end if;

end process;

process(clk)
begin

	if(rising_edge(clk))then
		if(volt_signal = "0001") then
			volt <= "0001";
			volt_signal <= "0010";
		
		elsif(volt_signal = "0010") then
			volt <= "0010";
			volt_signal <= "0100";
		
		elsif(volt_signal = "0100") then
			volt <= "0100";
			volt_signal <= "1000";
		
		elsif(volt_signal = "1000") then
			volt <= "1000";
			volt_signal <= "0001";

		end if;
		if(clk_controller = '1')then
			volt <= "10";
			controlVal(4 downto 0) <= input;
		else
			volt <= "01";
			controlVal(9 downto 5) <= input;
		end if;
	end if;

end process;

process(clk_controller)
begin
	if(rising_edge(clk_controller))then
		controlOut <= controlVal(9 downto 0);
	end if;
end process;

end Behavioral;

