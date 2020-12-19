library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

Library UNISIM;
use UNISIM.vcomponents.all;

entity freqDiv is

	port(
		clk : in std_logic;
		clkOut1P : out std_logic
		--clkOut2P : out std_logic
	);

end freqDiv;

architecture Behavioral of freqDiv is

signal CLKIN: std_logic := '0';
signal CLKBUFGOUT: std_logic := '0';
signal clkOut1: std_logic := '0';
--signal clkOut2: std_logic := '0';
signal clkOut1Int: std_logic := '0';
--signal clkOut2Int: std_logic := '0';
begin

	IBUFG_inst : IBUFG
   generic map (
      IBUF_LOW_PWR => TRUE, -- Low power (TRUE) vs. performance (FALSE) setting for referenced I/O standards
      IOSTANDARD => "DEFAULT")
   port map (
      O => CLKBUFGOUT, -- Clock buffer output
      I => clk  -- Clock buffer input (connect directly to top-level port)
   );

   DCM_SP_inst : DCM_SP
   generic map (
      CLKDV_DIVIDE => 2.0,                   -- CLKDV divide value
                                             -- (1.5,2,2.5,3,3.5,4,4.5,5,5.5,6,6.5,7,7.5,8,9,10,11,12,13,14,15,16).
      CLKFX_DIVIDE => 20,                     -- Divide value on CLKFX outputs - D - (1-32)
      CLKFX_MULTIPLY => 26,                   -- Multiply value on CLKFX outputs - M - (2-32)
      CLKIN_DIVIDE_BY_2 => FALSE,            -- CLKIN divide by two (TRUE/FALSE)
      CLKIN_PERIOD => 10.0,                  -- Input clock period specified in nS
      CLKOUT_PHASE_SHIFT => "NONE",          -- Output phase shift (NONE, FIXED, VARIABLE)
      CLK_FEEDBACK => "NONE",                  -- Feedback source (NONE, 1X, 2X)
      DESKEW_ADJUST => "SYSTEM_SYNCHRONOUS", -- SYSTEM_SYNCHRNOUS or SOURCE_SYNCHRONOUS
      DFS_FREQUENCY_MODE => "LOW",           -- Unsupported - Do not change value
      DLL_FREQUENCY_MODE => "LOW",           -- Unsupported - Do not change value
      DSS_MODE => "NONE",                    -- Unsupported - Do not change value
      DUTY_CYCLE_CORRECTION => TRUE,         -- Unsupported - Do not change value
      FACTORY_JF => X"c080",                 -- Unsupported - Do not change value
      PHASE_SHIFT => 0,                      -- Amount of fixed phase shift (-255 to 255)
      STARTUP_WAIT => FALSE                  -- Delay config DONE until DCM_SP LOCKED (TRUE/FALSE)
   )
   port map (
      CLK0 => open,--clkOut2,         -- 1-bit output: 0 degree clock output
      CLK180 => open,     -- 1-bit output: 180 degree clock output
      CLK270 => open,     -- 1-bit output: 270 degree clock output
      CLK2X => open,       -- 1-bit output: 2X clock frequency clock output
      CLK2X180 => open, -- 1-bit output: 2X clock frequency, 180 degree clock output
      CLK90 => open,       -- 1-bit output: 90 degree clock output
      CLKDV => open,       -- 1-bit output: Divided clock output
      CLKFX => clkOut1,       -- 1-bit output: Digital Frequency Synthesizer output (DFS)
      CLKFX180 => open, -- 1-bit output: 180 degree CLKFX output
      LOCKED => open,     -- 1-bit output: DCM_SP Lock Output
      PSDONE => open,     -- 1-bit output: Phase shift done output
      STATUS => open,     -- 8-bit output: DCM_SP status output
      CLKFB => open,       -- 1-bit input: Clock feedback input
      CLKIN => CLKBUFGOUT,       -- 1-bit input: Clock input
      DSSEN => open,       -- 1-bit input: Unsupported, specify to GND.
      PSCLK => open,       -- 1-bit input: Phase shift clock input
      PSEN => open,         -- 1-bit input: Phase shift enable
      PSINCDEC => open, -- 1-bit input: Phase shift increment/decrement input
      RST => open            -- 1-bit input: Active high reset input
   );
	
	BUFG_inst_OUT1 : BUFG
   port map (
      O => clkOut1Int, -- 1-bit output: Clock buffer output
      I => clkOut1  -- 1-bit input: Clock buffer input
   );
	
--	BUFG_inst_OUT2 : BUFG
--   port map (
--      O => clkOut2Int, -- 1-bit output: Clock buffer output
--      I => clkOut2  -- 1-bit input: Clock buffer input
--   );

clkOut1P<= clkOut1Int;
--clkOut2P<= clkOut2Int;
end Behavioral;

