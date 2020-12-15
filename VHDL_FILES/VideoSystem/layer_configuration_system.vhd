library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.video_system_types.all;

entity layer_configuration_system is

	port(
		clk : in std_logic;
		
		cmd_in: in std_logic_vector(3 downto 0);
        data_in: in std_logic_vector(23 downto 0);
		input_enable : in std_logic;

		layer_index: in std_logic_vector(1 downto 0);

		layer_address_out: out std_logic_vector(23 downto 0);
		horizontal_address_offset_out: out std_logic_vector(6 downto 0);
		vertical_address_offset_out: out std_logic_vector(7 downto 0);
		transparent_color_out: out video_layers_transparent_color
	);

end layer_configuration_system;

architecture Behavioral of layer_configuration_system is

	--The start of said layer in the RAM.
	type layer_address is array (3 downto 0) of std_logic_vector(23 downto 0);
	--The horizontal offset is a 4 pixels offset. Goes from 0 to 79 after that it is going to repeat.
	type horizontal_address_offset is array (3 downto 0) of std_logic_vector(6 downto 0);
	--The vertical offset is a 1 pixel offset. Goes from 0 to 255.
	type vertical_address_offset is array (3 downto 0) of std_logic_vector(7 downto 0);

	signal layers_address : layer_address := (others=>(others=>'0'));
	signal horizontal_address_offsets : horizontal_address_offset := (others=>(others=>'0'));
	signal vertical_address_offsets : vertical_address_offset := (others=>(others=>'0'));
	signal transparent_colors : video_layers_transparent_color := (others=>(others=>'0'));

	constant LAYER_ADDRESS_CMD : std_logic_vector(1 downto 0) := "00";
	constant HORIZONTAL_ADDRESS_CMD : std_logic_vector(1 downto 0) := "01";
	constant VERTICAL_ADDRESS_CMD : std_logic_vector(1 downto 0) := "10";
	constant TRANSPARENT_ADDRESS_CMD : std_logic_vector(1 downto 0) := "11";
	
begin

process(clk)
	variable layer_index_var : integer range 0 to 3 := 0;
begin
	if(rising_edge(clk)) then
		if(input_enable = '1') then
			layer_index_var := to_integer(unsigned(cmd_in(1 downto 0)));

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
	end if;
end process;

layer_address_out <= layers_address(to_integer(unsigned(layer_index)));
horizontal_address_offset_out <= horizontal_address_offsets(to_integer(unsigned(layer_index)));
vertical_address_offset_out <= vertical_address_offsets(to_integer(unsigned(layer_index)));
transparent_color_out <= transparent_colors;

end Behavioral;