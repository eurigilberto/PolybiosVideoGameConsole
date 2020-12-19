--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   12:50:20 12/18/2020
-- Design Name:   
-- Module Name:   /home/ise/ISE_Share/PolybiosVideoGameConsole/VHDL_FILES/VIDEO/video_buffer_simulation.vhd
-- Project Name:  VIDEO
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: video_buffer_controller
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
USE ieee.numeric_std.ALL;
 
library work;
use work.video_system_types.all; 

ENTITY video_buffer_simulation IS
END video_buffer_simulation;
 
ARCHITECTURE behavior OF video_buffer_simulation IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT video_buffer_controller
    PORT(
         clk : IN  std_logic;
         system_loaded : IN  std_logic;
         enable_load : OUT  std_logic;
         write_enable_a_video_layers : OUT  std_logic_vector(3 downto 0);
         address_a_video_layers : OUT  video_layers_buffer_address;
         data_in_a_video_layers : OUT  video_layers_buffer_data;
         video_layers_address : IN  video_layers_address;
         video_layers_horizontal_address_offset : IN  video_layers_horizontal_address_offset;
         video_layers_vertical_address_offset : IN  video_layers_vertical_address_offset;
         wea_load : IN  std_logic_vector(0 downto 0);
         addra_block_load : IN  std_logic_vector(5 downto 0);
         dina_load : IN  std_logic_vector(31 downto 0);
         base_layer_address : OUT  std_logic_vector(23 downto 0);
         horizontal_address_offset : OUT  std_logic_vector(6 downto 0);
         vertical_address_offset : OUT  std_logic_vector(7 downto 0);
         vertical_pixel_coord : IN  std_logic_vector(7 downto 0);
         buffer_busy_signal : IN  std_logic;
         port_block_p : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal system_loaded : std_logic := '0';
   signal video_layers_address : video_layers_address := (others => (others => '0'));
   signal video_layers_horizontal_address_offset : video_layers_horizontal_address_offset := (others => (others => '0'));
   signal video_layers_vertical_address_offset : video_layers_vertical_address_offset := ("00011000", "11100000", "00001110", "11000110");
   signal wea_load : std_logic_vector(0 downto 0) := (others => '0');
   signal addra_block_load : std_logic_vector(5 downto 0) := (others => '0');
   signal dina_load : std_logic_vector(31 downto 0) := (others => '0');
   signal vertical_pixel_coord : std_logic_vector(7 downto 0) := (others => '0');
   signal buffer_busy_signal : std_logic := '0';

 	--Outputs
   signal enable_load : std_logic;
   signal write_enable_a_video_layers : std_logic_vector(3 downto 0);
   signal address_a_video_layers : video_layers_buffer_address;
   signal data_in_a_video_layers : video_layers_buffer_data;
   signal base_layer_address : std_logic_vector(23 downto 0);
   signal horizontal_address_offset : std_logic_vector(6 downto 0);
   signal vertical_address_offset : std_logic_vector(7 downto 0);
   signal port_block_p : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: video_buffer_controller PORT MAP (
          clk => clk,
          system_loaded => system_loaded,
          enable_load => enable_load,
          write_enable_a_video_layers => write_enable_a_video_layers,
          address_a_video_layers => address_a_video_layers,
          data_in_a_video_layers => data_in_a_video_layers,
          video_layers_address => video_layers_address,
          video_layers_horizontal_address_offset => video_layers_horizontal_address_offset,
          video_layers_vertical_address_offset => video_layers_vertical_address_offset,
          wea_load => wea_load,
          addra_block_load => addra_block_load,
          dina_load => dina_load,
          base_layer_address => base_layer_address,
          horizontal_address_offset => horizontal_address_offset,
          vertical_address_offset => vertical_address_offset,
          vertical_pixel_coord => vertical_pixel_coord,
          buffer_busy_signal => buffer_busy_signal,
          port_block_p => port_block_p
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;
		system_loaded <= '1';
		wait for 100 ns;
		vertical_pixel_coord <= (others => '0');
		wait for 100 ns;
		vertical_pixel_coord <= "00000001";
		wait for clk_period;
		wait for clk_period;
		buffer_busy_signal <= '1';
		wait for clk_period * 10;
		buffer_busy_signal <= '0';
		wait for clk_period;
		wait for clk_period;
		wait for clk_period;
		buffer_busy_signal <= '1';
		wait for clk_period * 10;
		buffer_busy_signal <= '0';
		wait for clk_period;
		wait for clk_period;
		wait for clk_period;
		buffer_busy_signal <= '1';
		wait for clk_period * 10;
		buffer_busy_signal <= '0';
		wait for clk_period;
		wait for clk_period;
		wait for clk_period;
		buffer_busy_signal <= '1';
		wait for clk_period * 10;
		buffer_busy_signal <= '0';
      wait;
   end process;

END;
