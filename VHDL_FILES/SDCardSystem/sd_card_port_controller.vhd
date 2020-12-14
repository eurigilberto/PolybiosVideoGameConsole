library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity sd_card_port_controller is
  port ( 
    clk                                     : in std_logic;

    enable                                  : in std_logic;

    c3_p2_cmd_clk                           : out std_logic;
    c3_p2_cmd_en                            : out std_logic;
    c3_p2_cmd_instr                         : out std_logic_vector(2 downto 0);
    c3_p2_cmd_bl                            : out std_logic_vector(5 downto 0);
    c3_p2_cmd_byte_addr                     : out std_logic_vector(29 downto 0);
    c3_p2_cmd_empty                         : in std_logic;
    c3_p2_cmd_full                          : in std_logic;
    
    c3_p2_wr_clk                            : out std_logic;
    c3_p2_wr_en                             : out std_logic;
    c3_p2_wr_mask                           : out std_logic_vector(3 downto 0);
    c3_p2_wr_data                           : out std_logic_vector(31 downto 0);
    c3_p2_wr_full                           : in std_logic;
    c3_p2_wr_empty                          : in std_logic;
    c3_p2_wr_count                          : in std_logic_vector(6 downto 0);
    c3_p2_wr_underrun                       : in std_logic;
    c3_p2_wr_error                          : in std_logic;

    c3_calib_done                           : in std_logic;

    data_to_write                           : in std_logic_vector(31 downto 0);

    address_to_write                        : in std_logic_vector(29 downto 0)
  ) ;
end sd_card_port_controller ;

architecture Behavioral of sd_card_port_controller is

type states is (
    STATE_IDLE,
    STATE_WRITING_DATA,
    STATE_ENABLING_COMMAND
);

signal actual_state: states := STATE_IDLE;

signal flag: std_logic:= '0';
signal colorToOutputA : std_logic_vector(7 downto 0) := X"10";
signal wr_enS : std_logic := '0';
signal cmd_enS : std_logic := '0';

signal data_to_write_int : std_logic_vector(31 downto 0) := (others => '0');
signal address_to_write_int : std_logic_vector(29 downto 0) := (others => '0');

begin

c3_p2_cmd_clk <= clk;
c3_p2_wr_clk <= clk;
c3_p2_wr_en <= wr_enS;
c3_p2_cmd_en <= cmd_enS;
c3_p2_wr_data <= data_to_write_int;

c3_p2_cmd_byte_addr <= address_to_write_int;

c3_p2_cmd_bl <= "000000";

c3_p2_cmd_instr <= "000";

c3_p2_wr_mask <= "0000";

process(clk)
begin

	if(rising_edge(clk)) then
        case (actual_state) is
            when STATE_IDLE =>
                cmd_enS <= '0';
                wr_enS <= '0';
                if(enable = '1') then
                    data_to_write_int <= data_to_write;
                    address_to_write_int <= address_to_write;
                    actual_state <= STATE_WRITING_DATA;
                end if;
            when STATE_WRITING_DATA =>
                wr_enS <= '1';
                actual_state <= STATE_ENABLING_COMMAND;
            when STATE_ENABLING_COMMAND =>
                wr_enS <= '0';
                cmd_enS <= '1';
                actual_state <= STATE_IDLE;
            when others =>
                cmd_enS <= '0';
                wr_enS <= '0';
        end case;
    end if;
end process;

end architecture ; -- Behavioral