library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.video_system_types.all;

entity layer_configuration_system is

	port(
		clk : in std_logic;
		
		cmd_in: 									in std_logic_vector(3 downto 0);
        data_in: 									in std_logic_vector(23 downto 0);
		input_enable : 								in std_logic;

		video_layers_address_out: 					out video_layers_address;
		video_layers_horizontal_address_offset_out: out video_layers_horizontal_address_offset;
		video_layers_vertical_address_offset_out: 	out video_layers_vertical_address_offset;
		transparent_color_out: 						out video_layers_transparent_color
	);

end layer_configuration_system;

architecture Behavioral of layer_configuration_system is

	signal layers_address : video_layers_address := (others=>(others=>'0'));
	signal horizontal_address_offsets : video_layers_horizontal_address_offset := (others=>(others=>'0'));
	signal vertical_address_offsets : video_layers_vertical_address_offset := (others=>(others=>'0'));
	signal transparent_colors : video_layers_transparent_color := (others=>(others=>'0'));

	constant LAYER_ADDRESS_CMD : std_logic_vector(1 downto 0) := "00";
	constant HORIZONTAL_ADDRESS_CMD : std_logic_vector(1 downto 0) := "01";
	constant VERTICAL_ADDRESS_CMD : std_logic_vector(1 downto 0) := "10";
	constant TRANSPARENT_ADDRESS_CMD : std_logic_vector(1 downto 0) := "11";
	
begin



process(clk)
	variable layer_index_var : integer range 3 downto 0 := 0;
begin
	if(rising_edge(clk)) then
		if(input_enable = '1') then
			
			case (cmd_in(1 downto 0)) is
				when "00" =>
					layer_index_var := 0;
				when "01" =>
					layer_index_var := 1;
				when "10" =>
					layer_index_var := 2;
				when "11" =>
					layer_index_var := 3;
				when others =>
					layer_index_var := 0;
			end case;

			if(cmd_in(3 downto 2) = LAYER_ADDRESS_CMD) then
				layers_address(layer_index_var) <= data_in;

			elsif(cmd_in(3 downto 2) = HORIZONTAL_ADDRESS_CMD) then
				horizontal_address_offsets(layer_index_var) <= data_in(6 downto 0);

			elsif(cmd_in(3 downto 2) = VERTICAL_ADDRESS_CMD) then
				vertical_address_offsets(layer_index_var) <= data_in(7 downto 0);

			elsif(cmd_in(3 downto 2) = TRANSPARENT_ADDRESS_CMD) then
				transparent_colors(layer_index_var) <= data_in(7 downto 0);
			end if;
		end if;

		video_layers_address_out <= layers_address;
		video_layers_horizontal_address_offset_out <= horizontal_address_offsets;
		video_layers_vertical_address_offset_out <= vertical_address_offsets;
		transparent_color_out <= transparent_colors;
	end if;
end process;

end Behavioral;