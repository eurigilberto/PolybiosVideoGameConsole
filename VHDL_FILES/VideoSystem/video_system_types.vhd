--
--	Package File Template
--
--	Purpose: This package defines supplemental types, subtypes, 
--		 constants, and functions 
--
--   To use any of the example code shown below, uncomment the lines and modify as necessary
--

library IEEE;
use IEEE.STD_LOGIC_1164.all;

package video_system_types is

	type video_layers_buffer_address is array (3 downto 0) of std_logic_vector(6 downto 0);
	type video_layers_buffer_data is array (3 downto 0) of std_logic_vector(31 DOWNTO 0);
	type video_layers_transparent_color is array(3 downto 0) of std_logic_vector(7 downto 0);
	type video_layers_address is array (3 downto 0) of std_logic_vector(23 downto 0);
	type video_layers_horizontal_address_offset is array (3 downto 0) of std_logic_vector(6 downto 0);
	type video_layers_vertical_address_offset is array (3 downto 0) of std_logic_vector(7 downto 0);

end video_system_types;

package body video_system_types is
 
end video_system_types;
