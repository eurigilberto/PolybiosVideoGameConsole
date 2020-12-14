entity controllers is

	port(
        clk : in std_logic;
        
        --header p6
		out_p6 : out std_logic_vector(3 downto 0);
        input_p6 : in std_logic_vector(3 downto 0);
        
        constroller_a : out std_logic_vector(13 downto 0);
        
        --header p7
        out_p7 : out std_logic_vector(3 downto 0);
        input_p7 : in std_logic_vector(3 downto 0);

        controller_b : out std_logic_vector(13 downto 0)
	);

end controllers;

architecture Behavioral of controllerX is

signal current_out : std_logic_vector(1 downto 0) := "00";
signal counter_clk : std_logic_vector(4 downto 0) := "00000";

signal out_p : std_logic_vector(3 downto 0) := "0000";

begin

out_p <= "0001" when current_out = "00" else
         "0010" when current_out = "01" else
         "0100" when current_out = "10" else
         "1000";

out_p6 <= out_p;
out_p7 <= out_p;

process(clk)
begin
    if(rising_edge(clk)) then
        current_out <= to_unsigned(current_out) + 1;

        case current_out is
            when "00" =>
                constroller_a(3 downto 0) <= input_p6;
                constroller_b(3 downto 0) <= input_p7;
            when "01" =>
                constroller_a(7 downto 4) <= input_p6;
                constroller_b(7 downto 4) <= input_p7;
            when "10" =>
                constroller_a(11 downto 8) <= input_p6;
                constroller_b(11 downto 8) <= input_p7;
            when "11" =>
                constroller_a(15 downto 12) <= input_p6;
                constroller_b(15 downto 12) <= input_p7;
        end case;
    end if;
end process;

end Behavioral;