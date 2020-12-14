library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;

entity Port0BiController is
    Port ( clk : in std_logic;
--			  calib_done : in std_logic;
			  
			  --CMD
			  cmd_clk : out  STD_LOGIC;
           cmd_en : out  STD_LOGIC;
           cmd_instr : out  STD_LOGIC_VECTOR (2 downto 0);
           cmd_bl : out  STD_LOGIC_VECTOR (5 downto 0);
           cmd_byte_addr : out  STD_LOGIC_VECTOR (29 downto 0);
           cmd_empty : in  STD_LOGIC;
           cmd_full : in  STD_LOGIC;
			  
			  --WRITE
           wr_clk : out  STD_LOGIC;
           wr_en : out  STD_LOGIC;
           wr_mask : out  STD_LOGIC_VECTOR (3 downto 0);
           wr_data : out  STD_LOGIC_VECTOR (31 downto 0);
           wr_full : in  STD_LOGIC;
           wr_empty : in  STD_LOGIC;
           wr_count : in  std_logic_vector(6 downto 0);
           wr_underrun : in  STD_LOGIC;
           wr_error : in  STD_LOGIC;
			  
			  --READ
           rd_clk : out  STD_LOGIC;
           rd_en : out  STD_LOGIC;
           rd_data : in  STD_LOGIC_VECTOR (31 downto 0);
           rd_full : in  STD_LOGIC;
           rd_empty : in  STD_LOGIC;
           rd_count : in  STD_LOGIC_VECTOR (6 downto 0);
           rd_overflow : in  STD_LOGIC;
           rd_error : in  STD_LOGIC;
			  
			  --DATA+CMDS
			  enable : in std_logic;
			  cmd : in std_logic_vector(2 downto 0);
			  data_in : in std_logic_vector(31 downto 0);
			  data_out : out std_logic_vector(31 downto 0);
			  address : in std_logic_vector(23 downto 0);
			  mask : in std_logic_vector(3 downto 0);
			  rd_bl_in : in std_logic_Vector(5 downto 0);
			  busy : out std_logic
			  );
end Port0BiController;

architecture Behavioral of Port0BiController is

type state is (
--					STATE_NOTHING,
					STATE_IDLE,
--					STATE_WRITE_REG_FIFO,
					STATE_READ_REG_FIFO,
					STATE_WRITE_MEM,
					STATE_WRITE_MEM_WAIT,
					STATE_READ_MEM,
					STATE_READ_MEM_WAIT,
					STATE_READ_MEM_F,
					STATE_READ_MEM_WAIT_F,
					STATE_READ_MEM_PUT,
					STATE_WRITE_MEM_F,
					STATE_WRITE_MEM_WAIT_F,
					STATE_WRITE_MEM_PUT
					);

signal actual_state : state := STATE_IDLE;
signal data_in_signal : std_logic_vector(31 downto 0) := (others => '0');
signal counter_wr : std_logic_vector(6 downto 0) := (others => '0');
signal rd_bl_in_signal : std_logic_Vector(5 downto 0) := (others => '0');
signal address_signal : std_logic_vector(23 downto 0) := (others => '0');
signal mask_signal : std_logic_vector(3 downto 0) := (others => '0');
signal data_outs: std_logic_vector(31 downto 0) := (others => '0'); 
begin

data_out <= data_outs;
cmd_clk <= clk; 
wr_clk <= clk;
rd_clk <= clk;

process(clk)

begin

	if rising_edge(clk) then
	
		rd_en <= '0';
		wr_en <= '0';
		cmd_en <= '0';
		busy <= '0';
	
		case (actual_state) is
--			when STATE_NOTHING =>
--				if(calib_done = '1')then
--					actual_state <= STATE_IDLE;
--				end if;
			
			when STATE_IDLE =>
				address_signal <= address;
				rd_bl_in_signal <= rd_bl_in;
				data_in_signal <= data_in;
				mask_signal <= mask;
				if(enable = '1') then
					if(cmd = "000")then --write fifo
						wr_en <= '1';
						wr_data <= data_in;
						wr_mask <= mask;
						actual_state <= STATE_IDLE;
						counter_wr <= counter_wr + 1;
					elsif(cmd = "001")then
						actual_state <= STATE_READ_REG_FIFO;
						rd_en <= '1';
					elsif(cmd = "010")then
						if(counter_wr /= "0000000") then
							actual_state <= STATE_WRITE_MEM;
							counter_wr <= counter_wr - 1;
						end if;
					elsif(cmd = "011")then
						actual_state <= STATE_READ_MEM;
					elsif(cmd = "100")then
						actual_state <= STATE_READ_MEM_F;
					elsif(cmd = "101")then
						actual_state <= STATE_WRITE_MEM_PUT;
					end if;
				end if;
				
			when STATE_WRITE_MEM_PUT  =>
				wr_en <= '1';
				wr_data <= data_in_signal;
				wr_mask <= mask_signal;
				actual_state <= STATE_WRITE_MEM_F;
				
			when STATE_WRITE_MEM_F  =>
				cmd_en <= '1';
				cmd_instr <= "000";
				cmd_bl <= "000000";
				cmd_byte_addr <= "0000"&address_signal&"00";
				counter_wr <= (others => '0');
				actual_state <= STATE_WRITE_MEM_WAIT_F;
				
			when STATE_WRITE_MEM_WAIT_F =>
				if(wr_empty = '1')then
					actual_state <= STATE_IDLE;
					busy <= '1';
				end if;
				
			when STATE_READ_MEM_F =>
				cmd_en <= '1';
				cmd_instr <= "001";
				cmd_bl <= rd_bl_in_signal;
				cmd_byte_addr <= "0000"&address_signal&"00";
				actual_state <= STATE_READ_MEM_WAIT_F;
				
			when STATE_READ_MEM_WAIT_F =>
				if(rd_empty = '0' and rd_count = '0'&rd_bl_in_signal + 1)then
					actual_state <= STATE_READ_MEM_PUT;
					rd_en <= '1';
				end if;
			when STATE_READ_MEM_PUT =>
				busy <= '1';
				data_outs <= rd_data;
				actual_state <= STATE_IDLE;
			
			when STATE_READ_REG_FIFO =>
				data_outs <= rd_data;
				if(rd_empty = '1')then
					actual_state <= STATE_IDLE;
					busy <= '0';
				else
					busy <= '1';
					rd_en <= '1';
				end if;
				
			when STATE_WRITE_MEM =>
				cmd_en <= '1';
				cmd_instr <= "000";
				cmd_bl <= counter_wr(5 downto 0);
				cmd_byte_addr <= "0000"&address_signal&"00";
				counter_wr <= (others => '0');
				actual_state <= STATE_WRITE_MEM_WAIT;
			
			when STATE_WRITE_MEM_WAIT =>
				if(wr_empty = '1')then
					actual_state <= STATE_IDLE;
					busy <= '1';
				end if;
				
			when STATE_READ_MEM =>
				cmd_en <= '1';
				cmd_instr <= "001";
				cmd_bl <= rd_bl_in_signal;
				cmd_byte_addr <= "0000"&address_signal&"00";
				actual_state <= STATE_READ_MEM_WAIT;
				
			when STATE_READ_MEM_WAIT =>
				if(rd_empty = '0' and rd_count = '0'&rd_bl_in_signal + 1)then
					actual_state <= STATE_IDLE;
					busy <= '1';
				end if;
		end case;
	
	end if;

end process;


end Behavioral;

