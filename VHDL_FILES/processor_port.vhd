library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity processor_port is

	port(
		clk												 : in std_logic;
		
		command											 : in std_logic_vector(1 downto 0);
		enable											 : in std_logic;
	
		--Port 0 CMD
		c3_p0_cmd_clk                           : out std_logic;
		c3_p0_cmd_en                            : out std_logic;
		c3_p0_cmd_instr                         : out std_logic_vector(2 downto 0);
		c3_p0_cmd_bl                            : out std_logic_vector(5 downto 0);
		c3_p0_cmd_byte_addr                     : out std_logic_vector(29 downto 0);
		c3_p0_cmd_empty                         : in std_logic;
		c3_p0_cmd_full                          : in std_logic;

		--Port 0 WR
		c3_p0_wr_clk                            : out std_logic;
		c3_p0_wr_en                             : out std_logic;
		c3_p0_wr_mask                           : out std_logic_vector(3 downto 0);
		c3_p0_wr_data                           : out std_logic_vector(31 downto 0);
		c3_p0_wr_full                           : in std_logic;
		c3_p0_wr_empty                          : in std_logic;
		c3_p0_wr_count                          : in std_logic_vector(6 downto 0);
		c3_p0_wr_underrun                       : in std_logic;
		c3_p0_wr_error                          : in std_logic;

		--Port 0 RD
		c3_p0_rd_clk                            : out std_logic;
		c3_p0_rd_en                             : out std_logic;
		c3_p0_rd_data                           : in std_logic_vector(31 downto 0);
		c3_p0_rd_full                           : in std_logic;
		c3_p0_rd_empty                          : in std_logic;
		c3_p0_rd_count                          : in std_logic_vector(6 downto 0);
		c3_p0_rd_overflow                       : in std_logic;
		c3_p0_rd_error                          : in std_logic;
	);

end processor_port;

architecture Behavioral of processor_port is

begin


end Behavioral;

