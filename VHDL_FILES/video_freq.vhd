library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity video_freq is
	port(vid_clk_2x : in std_logic;
		  video_clk : out std_logic);
end video_freq;

architecture Behavioral of video_freq is
signal clk_div : std_logic := '0';
begin
video_clk <= clk_div;
process(vid_clk_2x)
begin
	if(rising_edge(vid_clk_2x))then
		clk_div <= not(clk_div);
	end if;
end process;

end Behavioral;

