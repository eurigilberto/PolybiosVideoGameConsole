LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
ENTITY receiverP IS
END receiverP;
 
ARCHITECTURE behavior OF receiverP IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT SPI_receiver
    PORT(
         clk : IN  std_logic;
         sclk_posedge : IN  std_logic;
         sclk_negedge : IN  std_logic;
         reset : IN  std_logic;
         en : IN  std_logic;
         input : IN  std_logic;
         output : OUT  std_logic_vector(39 downto 0);
         done : OUT  std_logic;
         stateLED : OUT  std_logic_vector(2 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal sclk_posedge : std_logic := '0';
   signal sclk_negedge : std_logic := '0';
   signal reset : std_logic := '0';
   signal en : std_logic := '0';
   signal input : std_logic := '0';

 	--Outputs
   signal output : std_logic_vector(39 downto 0);
   signal done : std_logic;
   signal stateLED : std_logic_vector(2 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: SPI_receiver PORT MAP (
          clk => clk,
          sclk_posedge => sclk_posedge,
          sclk_negedge => sclk_negedge,
          reset => reset,
          en => en,
          input => input,
          output => output,
          done => done,
          stateLED => stateLED
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 
	process
	begin
	
		en <= '1';
		wait for clk_period;
		en <= '0';
		wait;
	
	end process;
 
	process
	begin
		input <= '0';
		wait for 5 us;
		input <= '1';
		wait for 5 us;
		input <= '1';
		wait for 5 us;
		input <= '0';
		wait for 5 us;
		input <= '0';
		wait for 5 us;
		input <= '0';
		wait for 5 us;
		input <= '1';
		wait for 5 us;
		input <= '0';
		wait for 5 us;
		input <= '1';
		wait for 5 us;
		input <= '1';
		wait for 5 us;
		input <= '1';
		wait for 5 us;
		input <= '1';
		wait for 5 us;
		input <= '1';
		wait for 5 us;
		input <= '1';
		wait for 5 us;
		input <= '1';
		wait for 5 us;
		input <= '1';
		wait for 5 us;
		input <= '1';
		wait for 5 us;
		input <= '1';
		wait for 5 us;
		input <= '1';
		wait for 5 us;
		input <= '1';
		wait for 5 us;
		input <= '1';
		wait for 5 us;
		input <= '1';
		wait for 5 us;
		input <= '1';
		wait for 5 us;
		input <= '1';
		wait for 5 us;
		input <= '1';
		wait for 5 us;
		input <= '1';
		wait for 5 us;
		input <= '1';
		wait for 5 us;
		input <= '1';
		wait for 5 us;
		input <= '1';
		wait for 5 us;
		input <= '1';
		wait for 5 us;
		input <= '1';
		wait for 5 us;
		input <= '1';
		wait for 5 us;
		input <= '1';
		wait for 5 us;
		input <= '1';
		wait for 5 us;
		input <= '1';
		wait for 5 us;
		input <= '1';
		wait for 5 us;
		input <= '1';
		wait for 5 us;
		input <= '1';
		wait for 5 us;
		input <= '1';
		wait for 5 us;
		input <= '1';
		wait for 5 us;
		input <= '1';
		wait for 5 us;
		input <= '1';
		wait for 5 us;
		input <= '1';
		wait;
	end process;

   -- Stimulus process
   stim_proc: process
   begin		
      
		sclk_posedge <= '0';
		sclk_negedge <= '1';
		
      wait for 2.5 us;	

		sclk_posedge <= '1';
		sclk_negedge <= '0';
		
      wait for 2.5 us;	
   end process;

END;
