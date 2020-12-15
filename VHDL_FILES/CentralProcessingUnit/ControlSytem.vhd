library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ControlSystem is
	port(
		clk 				: in std_logic;
		
		--GET VIDEO INFO
		video_info_data_out 							 : out std_logic_vector(23 downto 0);
		video_info_cmd 									 : in std_logic_vector(1 downto 0);

		--SET VIDEO LAYERS DATA
		video_layers_data_in							 : in std_logic_vector(23 downto 0);
		video_layers_cmd								 : in std_logic_vector(3 downto 0);
		video_layers_input_enabled						 : in std_logic;
		
		we_RSP : out STD_LOGIC_VECTOR(0 DOWNTO 0);
		addr_RSP : out STD_LOGIC_VECTOR(5 DOWNTO 0);
		din_RSP : out STD_LOGIC_VECTOR(31 DOWNTO 0);
		dout_RSP : in STD_LOGIC_VECTOR(31 DOWNTO 0);
		
		addrA				: out std_logic_vector(4 downto 0);
		addrB				: out std_logic_vector(4 downto 0);
		dinA				: out std_logic_vector(31 downto 0);
		dinB				: out std_logic_vector(31 downto 0);
		doutA				: in std_logic_vector(31 downto 0);
		doutB				: in std_logic_vector(31 downto 0);
		enA				: out std_logic;
		enB				: out std_logic;
		
		enable_port 	: out std_logic;
		cmd_port 		: out std_logic_vector(2 downto 0);
		data_in_port 	: out std_logic_vector(31 downto 0);
		data_out_port 	: in std_logic_vector(31 downto 0);
		address_port 	: out std_logic_vector(23 downto 0);
		mask_port 		: out std_logic_vector(3 downto 0);
		rd_bl_in_port 	: out std_logic_Vector(5 downto 0);
		busy_port		: in std_logic;
		calib_done		: in std_logic;
		
		debug_leds 		: out std_logic_vector(7 downto 0);
		btn				: in std_logic;
		
		controller_a : in std_logic_vector(13 downto 0);
		controller_b : in std_logic_vector(13 downto 0)
	);
end ControlSystem;

architecture Behavioral of ControlSystem is

type state is (
					STATE_NOTHING,
					STATE_FETCH,
					STATE_FETCH_WAIT,
					STATE_PC_PLUS,
					STATE_DECODE,
					STATE_HALT,
					STATE_ADD,
					STATE_ADDS,
					STATE_SUB,
					STATE_SUBS,
					STATE_MUL,
					STATE_MULS,
					STATE_DIV,
					STATE_DIVS,
					STATE_AND,
					STATE_OR,
					STATE_NOT,
					STATE_XOR,
					STATE_SRL,
					STATE_SRA,
					STATE_SLL,
					STATE_LOAD,
					STATE_STORE,
					STATE_JUMP,
					STATE_GREATER,
					STATE_GREATER_2,
					STATE_EQUAL,
					STATE_EQUAL_2,
					STATE_LESS,
					STATE_LESS_2,
					STATE_RVALUP,
					STATE_RVALDOWN,
--					STATE_LITERALR1,
					STATE_BTF,
					STATE_BCF,
					STATE_BSF,
					STATE_SET_VIDR,
					STATE_GET_VIDR,
					STATE_SET_STACK_POINTER,
					STATE_LOAD_SPRITE,
					STATE_LOAD_SPRITE_WAIT,
					STATE_LOAD_SPRITE_DUMMYSTATE,
					state_load_sprite_ram,
					state_store_sprite,
					state_store_8x8,
					STATE_PUT_SP,
					STATE_POP_SP,
					STATE_PUT_SP_WAIT,
					STATE_MOV,
					STATE_GET_VIDR_DUM,
--					STATE_GET_PC
					STATE_ADDI,
					STATE_SUBI,
					STATE_MULI,
					STATE_RET,
					STATE_CALL,
					STATE_PREPARE_CALL,
					STATE_WAIT,
					STATE_SPRITE_TRANSPARENT
					);

signal actual_state : state := STATE_NOTHING;
signal next_state : state := STATE_NOTHING;

signal program_counter : std_logic_vector(24 downto 0) := (others => '0');
signal return_register : std_logic_vector(23 downto 0) := (others => '0');
signal temporal_register : std_logic_vector(23 downto 0) := (others => '0');
signal instruction : std_logic_vector(31 downto 0) := (others => '0');

type call_state is (
	PREPARE_STORE_COUNTER,
	REGISTER_WAIT,
	ADD_REGISTER_TO_FIFO,
	ADD_CURRENT_RETURN_TO_FIFO,
	ADD_CURRENT_WRITE_SIZE_TO_FIFO,
	UPDATE_INTERNAL_CALL_REGISTERS_AND_BURST_WRITE_FIFO,
	CHANGE_PROGRAM_COUNTER_AND_FETCH
);

signal call_state_system : call_state := PREPARE_STORE_COUNTER;
signal call_store_counter : std_logic_vector(4 downto 0) := "01001";
signal call_write_start : std_logic_vector(4 downto 0) := "01001";
signal call_write_size : std_logic_vector(5 downto 0) := "000000";

signal return_state_system : std_logic_vector(2 downto 0) := (others => '0');
signal return_counter : std_logic_vector(5 downto 0) := "000000";

signal STATE_REG : std_logic_vector(7 downto 0) := (others => '0');
signal stack_pointer : std_logic_vector(23 downto 0) := (others => '0');

signal doneFlag : std_logic := '0';

constant zero : integer := 0;
constant carry : integer := 1;
constant overflow : integer := 2;

constant zeros : std_logic_vector(31 downto 0) := (others => '0');

signal counter_load_sprite : std_logic_vector(5 downto 0) := (others => '0');
signal counter_load_limit : std_logic_vector(5 downto 0) := (others => '0');

signal counter_store_sprite : std_logic_vector(5 downto 0) := (others => '0');
signal prev_store_sprite : std_logic_vector(5 downto 0) := (others => '0');
signal counter_store_internal : std_logic_vector(1 downto 0) := (others => '0');

constant horizontal_size : std_logic_vector(6 downto 0) := "1000100";
constant vertical_size : std_logic_vector(7 downto 0) := "11010000";

signal stateRamStore : std_logic_vector(2 downto 0) := (others => '0');

signal end_sprite_system : std_logic := '0';

signal layer_address : std_logic_vector(23 downto 0) := (others => '0');

--signal btn_flag : std_logic := '0';

signal data_in_v_s 		: std_logic_vector(23 downto 0) := (others => '0');
signal cmd_input_v_s 	: std_logic_vector(3 downto 0) := (others => '0');
signal cmd_output_v_s 	: std_logic_vector(3 downto 0) := (others => '0');
signal input_enable_v_s : std_logic := '0';

signal lastProgramCounter : std_logic_vector(23 downto 0) := (others => '0');
signal lastInstruction : std_logic_vector(31 downto 0) := (others => '0');

signal spriteTransparent : std_logic_vector(7 downto 0) := (others => '0');

begin

data_in_v <= data_in_v_s;
cmd_input_v <= cmd_input_v_s;
cmd_output_v <= cmd_output_v_s;
input_enable_v <= input_enable_v_s;

process(clk)

variable Rt : std_logic_vector(32 downto 0);
variable Rt2 : std_logic_vector(63 downto 0);
variable Rt3 : std_logic_vector(47 downto 0);
variable Rtemp : std_logic_vector(31 downto 0);
variable ind : integer range 0 to 31;

begin

	if(rising_edge(clk))then
		enable_port <= '0';
		enA <= '0';
		enB <= '0';
		input_enable_v_s <= '0';
		we_RSP <= "0";
		mask_port <= "0000";
		
		if (btn = '1') then
			debug_leds <= "000000"&controlOutA(9 downto 8);
		else
			debug_leds <= controlOutA(7 downto 0);
		end if;
		
		case(actual_state) is
			when STATE_NOTHING =>
				if (calib_done = '1')then
					actual_state <= STATE_FETCH;
					program_counter <= (others => '0');
				end if;
				--debug_leds <= "10100101";
				
			when STATE_FETCH =>
				enable_port <= '1';
				cmd_port <= "100";
				address_port <= program_counter(23 downto 0);
				rd_bl_in_port <= "000000";
				mask_port <= "0000";
				actual_state <= STATE_FETCH_WAIT;
				--debug_leds <= "00110011";
				
			when STATE_FETCH_WAIT =>
				if(busy_port = '1')then
					actual_state <= STATE_DECODE;
					lastInstruction <= instruction;
					instruction <= data_out_port;
				end if;
				--debug_leds <= "11001100";
				
			when STATE_PC_PLUS =>
--				if(btn_flag = '0' and btn = '0') then
					program_counter <= std_logic_vector(unsigned(program_counter) + 1); 
					if(program_counter > "11111111111111111111111")then
						program_counter <= (others => '0');
					end if;
					actual_state <= STATE_FETCH;
					--debug_leds <= "11000011";
					lastProgramCounter <= program_counter(23 downto 0);
--					btn_flag <= '1';
--				elsif (btn = '1') then
--					debug_leds <= "11000011";
--					btn_flag <= '0';
--				end if;
			when STATE_WAIT =>
				actual_state <= next_state;
			when STATE_DECODE =>
				actual_state <= STATE_PC_PLUS;
				case (instruction(31 downto 24)) is
					when "00000000" =>
						actual_state <= STATE_HALT;
					when "00000001" =>
						addrA <= instruction(23 downto 19);
						addrB <= instruction(18 downto 14);
						actual_state <= STATE_WAIT;
						next_state <= STATE_ADD;
					when "00000010" =>
						addrA <= instruction(23 downto 19);
						addrB <= instruction(18 downto 14);
						actual_state <= STATE_WAIT;
						next_state <= STATE_ADDS;
					when "00000011" =>
						addrA <= instruction(23 downto 19);
						addrB <= instruction(18 downto 14);
						actual_state <= STATE_WAIT;
						next_state <= STATE_SUB;
					when "00000100" =>
						addrA <= instruction(23 downto 19);
						addrB <= instruction(18 downto 14);
						actual_state <= STATE_WAIT;
						next_state <= STATE_SUBS;
					when "00000101" =>
						addrA <= instruction(23 downto 19);
						addrB <= instruction(18 downto 14);
						actual_state <= STATE_WAIT;
						next_state <= STATE_MUL;
					when "00000110" =>
						addrA <= instruction(23 downto 19);
						addrB <= instruction(18 downto 14);
						actual_state <= STATE_WAIT;
						next_state <= STATE_MULS;
--					when "00000111" =>
--						addrA <= instruction(23 downto 19);
--						addrB <= instruction(18 downto 14);
--						actual_state <= STATE_DIV;
--					when "00001000" =>
--						addrA <= instruction(23 downto 19);
--						addrB <= instruction(18 downto 14);
--						actual_state <= STATE_DIVS;
					when "00001001" =>
						addrA <= instruction(23 downto 19);
						addrB <= instruction(18 downto 14);
						actual_state <= STATE_WAIT;
						next_state <= STATE_AND;
					when "00001010" =>
						addrA <= instruction(23 downto 19);
						addrB <= instruction(18 downto 14);
						actual_state <= STATE_WAIT;
						next_state <= STATE_OR;
					when "00001011" =>
						addrA <= instruction(23 downto 19);
						actual_state <= STATE_WAIT;
						next_state <= STATE_NOT;
					when "00001100" =>
						addrA <= instruction(23 downto 19);
						addrB <= instruction(18 downto 14);
						actual_state <= STATE_WAIT;
						next_state <= STATE_XOR;
					when "00001101" =>
						addrA <= instruction(23 downto 19);
						addrB <= instruction(18 downto 14);
						actual_state <= STATE_WAIT;
						next_state <= STATE_SRL;
					when "00001110" =>
						addrA <= instruction(23 downto 19);
						addrB <= instruction(18 downto 14);
						actual_state <= STATE_WAIT;
						next_state <= STATE_SRA;
					when "00001111" =>
						addrA <= instruction(23 downto 19);
						addrB <= instruction(18 downto 14);
						actual_state <= STATE_WAIT;
						next_state <= STATE_SLL;
					when "00010000" =>
						addrA <= instruction(23 downto 19);
						actual_state <= STATE_WAIT;
						next_state <= STATE_LOAD;
					when "00010001" =>
						addrA <= instruction(23 downto 19);
						addrB <= instruction(18 downto 14);
						actual_state <= STATE_WAIT;
						next_state <= STATE_STORE;
					when "00010010" =>
						program_counter <= '0'&instruction(23 downto 0);
						actual_state <= STATE_WAIT;
						next_state <= STATE_FETCH; --JUMPI;
					when "00010011" =>
						addrA <= instruction(23 downto 19);
						actual_state <= STATE_WAIT;
						next_state <= STATE_JUMP;
					when "00010100" =>
						addrA <= instruction(23 downto 19);
						addrB <= instruction(18 downto 14);
						actual_state <= STATE_WAIT;
						next_state <= STATE_GREATER;
					when "00010101" =>
						addrA <= instruction(23 downto 19);
						addrB <= instruction(18 downto 14);
						actual_state <= STATE_WAIT;
						next_state <= STATE_EQUAL;
					when "00010110" =>
						addrA <= instruction(23 downto 19);
						addrB <= instruction(18 downto 14);
						actual_state <= STATE_WAIT;
						next_state <= STATE_LESS;
					when "00010111" =>
						addrA <= instruction(23 downto 19);
						actual_state <= STATE_WAIT;
						next_state <= STATE_RVALUP;
					when "00011000" =>
						addrA <= instruction(23 downto 19);
						actual_state <= STATE_WAIT;
						next_state <= STATE_RVALDOWN;
					when "00011001" => --LITERALR1
						addrA <= "00001";
						dinA <= "00000000"&instruction(23 downto 0);
						enA <= '1';
						actual_state <= STATE_WAIT;
						next_state <= STATE_PC_PLUS;
					when "00011010" =>
						addrA <= instruction(23 downto 19);
						addrB <= instruction(13 downto 9);
						actual_state <= STATE_WAIT;
						next_state <= STATE_BTF;
					when "00011011" =>
						addrA <= instruction(23 downto 19);
						actual_state <= STATE_WAIT;
						next_state <= STATE_BCF;
					when "00011100" =>
						addrA <= instruction(23 downto 19);
						actual_state <= STATE_WAIT;
						next_state <= STATE_BSF;
					when "00011101" =>
						addrA <= instruction(23 downto 19);
						actual_state <= STATE_WAIT;
						next_state <= STATE_SET_VIDR;
					when "00011110" =>
						cmd_output_v_s <= instruction(18 downto 15);
						actual_state <= STATE_WAIT;
						next_state <= STATE_GET_VIDR_DUM;
					when "00011111" => --GET STACK POINTER
						addrA <= instruction(23 downto 19);
						enA <= '1';
						dinA <= "00000000"&stack_pointer;
						actual_state <= STATE_PC_PLUS;
					when "00100000" => --SET STACK POINTER
						addrA <= instruction(23 downto 19);
						actual_state <= STATE_WAIT;
						next_state <= STATE_SET_STACK_POINTER;
					when "00100001" => --GET_STATE_REG
						addrA <= instruction(23 downto 19);
						enA <= '1';
						dinA <= "000000000000000000000000"&STATE_REG;
						actual_state <= STATE_PC_PLUS;
					when "00100010" =>
						addrA <= instruction(23 downto 19); -- SPRITE ADDRESS
						addrB <= instruction(18 downto 14); -- LAYER ADDRESS
						actual_state <= STATE_WAIT;
						next_state <= STATE_LOAD_SPRITE;
					when "00100011" =>
						addrA <= instruction(23 downto 19);
						actual_state <= STATE_WAIT;
						actual_state <= STATE_PUT_SP;
					when "00100100" =>
						enable_port <= '1';
						cmd_port <= "100";
						address_port <= std_logic_vector(unsigned(stack_pointer) - 1);
						rd_bl_in_port <= "000000";
						mask_port <= "0000";
						stack_pointer <= std_logic_vector(unsigned(stack_pointer) - 1);
						actual_state <= STATE_POP_SP;
					when "00100101" =>
						addrA <= instruction(23 downto 19);
						actual_state <= STATE_WAIT;
						next_state <= STATE_MOV;
					when "00100110" =>
						addrA <= instruction(23 downto 19);
						enA <= '1';
						dinA <= "0000000"&program_counter;
						actual_state <= STATE_PC_PLUS;
					when "00100111" =>
						addrA <= instruction(23 downto 19);
						actual_state <= STATE_WAIT;
						next_state <= STATE_ADDI;
					when "00101000" =>
						addrA <= instruction(23 downto 19);
						actual_state <= STATE_WAIT;
						next_state <= STATE_SUBI;
					when "00101001" =>
						addrA <= instruction(23 downto 19);
						actual_state <= STATE_WAIT;
						next_state <= STATE_MULI;
--					when "00101010" =>
--						addrA <= instruction(23 downto 19);
--						actual_state <= STATE_DIVI;
					when "00101011" => --CALL
						addrA <= instruction(23 downto 19);
						addrB <= instruction(18 downto 14);
						actual_state <= STATE_WAIT;
						next_state <= STATE_PREPARE_CALL;
						call_state_system <= PREPARE_STORE_COUNTER;
--					when "00101100" =>
--						temporal_register <= instruction(23 downto 0);
--						actual_state <= STATE_CALL;
--						call_state_system <= "110";
--						call_write_start <= "01001";
					when "00101101" =>
						stack_pointer <= std_logic_vector(unsigned(stack_pointer) - unsigned(call_write_size));
						actual_state <= STATE_WAIT;
						next_state <= STATE_RET;
					when "00101110" =>
						dinA <= "0000000000000000000000"&controlOutA;
						addrA <= instruction(23 downto 19);
						enA <= '1';
					when "00101111" =>
						addrA <= instruction(23 downto 19);
						actual_state <= STATE_WAIT;
						next_state <= STATE_SPRITE_TRANSPARENT;
					when others =>
						actual_state <= STATE_PC_PLUS;
				end case;
				
			when STATE_ADD =>
				rt := std_logic_vector(resize(unsigned(doutA),33) + resize(unsigned(doutB),33));
				
				--register part
				dinB <= std_logic_vector(unsigned(doutA) + unsigned(doutB));
				enB <= '1';
				addrB <= instruction(13 downto 9);
				--register part
				
				--status change
				STATE_REG(carry) <= rt(32);
				if(rt(31 downto 0) = zeros)then
					STATE_REG(zero) <= '1';
				else
					STATE_REG(zero) <= '0';
				end if;
				--status change
				
				actual_state <= STATE_PC_PLUS;
			
			when STATE_ADDS =>
			
				--register part
				dinB <= std_logic_vector(signed(doutA) + signed(doutB));
				enB <= '1';
				addrB <= instruction(13 downto 9);
				--register part
				
				--status change
				if(signed(doutA) + signed(doutB) = signed(zeros))then
					STATE_REG(zero) <= '1';
				else
					STATE_REG(zero) <= '0';
				end if;
				--status change
				
				actual_state <= STATE_PC_PLUS;
				
			when STATE_SUB =>
				
				rt := std_logic_vector(resize(unsigned(doutA),33) - resize(unsigned(doutB),33));
				
				--register part
				dinB <= std_logic_vector(unsigned(doutA) - unsigned(doutB));
				enB <= '1';
				addrB <= instruction(13 downto 9);
				--register part
				
				--status change
				STATE_REG(carry) <= rt(32);
				if(rt(31 downto 0) = zeros)then
					STATE_REG(zero) <= '1';
				else
					STATE_REG(zero) <= '0';
				end if;
				--status change
				
				actual_state <= STATE_PC_PLUS;
				
			when STATE_SUBS =>
			
				--register part
				dinB <= std_logic_vector(signed(doutA) - signed(doutB));
				enB <= '1';
				addrB <= instruction(13 downto 9);
				--register part
				
				--status change
				if(signed(doutA) - signed(doutB) = signed(zeros))then
					STATE_REG(zero) <= '1';
				else
					STATE_REG(zero) <= '0';
				end if;
				--status change
				
				actual_state <= STATE_PC_PLUS;
				
			when STATE_MUL =>
				rt2 := std_logic_vector(unsigned(doutA)*unsigned(doutB));
				
				--register part
				dinB <= rt2(31 downto 0);
				enB <= '1';
				addrB <= instruction(13 downto 9);
				
				dinA <= rt2(63 downto 32);
				enA <= '1';
				addrA <= std_logic_vector(unsigned(instruction(13 downto 9)) + "00001");
				--register part
				
				--status change
				if(rt2 = zeros&zeros)then
					STATE_REG(zero) <= '1';
				else
					STATE_REG(zero) <= '0';
				end if;
				--status change
				
				actual_state <= STATE_PC_PLUS;
			
			when STATE_MULS =>
				rt2 := std_logic_vector(signed(doutA)*signed(doutB));
				
				--register part
				dinB <= rt2(31 downto 0);
				enB <= '1';
				addrB <= instruction(13 downto 9);
				
				dinA <= rt2(63 downto 32);
				enA <= '1';
				addrA <= std_logic_vector(unsigned(instruction(13 downto 9)) + "00001");
				--register part
				
				--status change
				if(rt2 = zeros&zeros)then
					STATE_REG(zero) <= '1';
				else
					STATE_REG(zero) <= '0';
				end if;
				--status change
				
				actual_state <= STATE_PC_PLUS;
				
--			when STATE_DIV =>
--				
--				--register part
--				dinB <= std_logic_vector(unsigned(doutA)/unsigned(doutB));
--				enB <= '1';
--				addrB <= instruction(13 downto 9);
--				--register part
--				
--				--status change
--				if(std_logic_vector(unsigned(doutA)/unsigned(doutB)) = zeros)then
--					STATE_REG(zero) <= '1';
--				else
--					STATE_REG(zero) <= '0';
--				end if;
--				--status change
--				
--				actual_state <= STATE_PC_PLUS;
--			
--			when STATE_DIVS =>
--				
--				--register part
--				dinB <= std_logic_vector(signed(doutA)/signed(doutB));
--				enB <= '1';
--				addrB <= instruction(13 downto 9);
--				--register part
--				
--				--status change
--				if(std_logic_vector(signed(doutA)/signed(doutB)) = zeros)then
--					STATE_REG(zero) <= '1';
--				else
--					STATE_REG(zero) <= '0';
--				end if;
--				--status change
--				
--				actual_state <= STATE_PC_PLUS;
			
			when STATE_AND =>
				
				--register part
				dinB <= doutA and doutB;
				enB <= '1';
				addrB <= instruction(13 downto 9);
				--register part
				
				--status change
				if((doutA and doutB) = zeros)then
					STATE_REG(zero) <= '1';
				else
					STATE_REG(zero) <= '0';
				end if;
				--status change
				
				actual_state <= STATE_PC_PLUS;
				
			when STATE_OR =>
				
				--register part
				dinB <= doutA or doutB;
				enB <= '1';
				addrB <= instruction(13 downto 9);
				--register part
				
				--status change
				if((doutA or doutB) = zeros)then
					STATE_REG(zero) <= '1';
				else
					STATE_REG(zero) <= '0';
				end if;
				--status change
				
				actual_state <= STATE_PC_PLUS;
				
			when STATE_NOT =>
				
				--register part
				dinB <= not(doutA);
				enB <= '1';
				addrB <= instruction(18 downto 14);
				--register part
				
				--status change
				if(not(doutA) = zeros)then
					STATE_REG(zero) <= '1';
				else
					STATE_REG(zero) <= '0';
				end if;
				--status change
				
				actual_state <= STATE_PC_PLUS;
			
			when STATE_XOR =>
				
				--register part
				dinB <= doutA xor doutB;
				enB <= '1';
				addrB <= instruction(13 downto 9);
				--register part
				
				--status change
				if((doutA xor doutB) = zeros)then
					STATE_REG(zero) <= '1';
				else
					STATE_REG(zero) <= '0';
				end if;
				--status change
				
				actual_state <= STATE_PC_PLUS;
			
			when STATE_SRL =>
				
				if(instruction(0) = '1')then
					ind := to_integer(unsigned(doutB(4 downto 0)));
				else
					ind := to_integer(unsigned(instruction(18 downto 14)));
				end if;
				--register part
				dinB <= std_logic_vector(SHIFT_RIGHT(unsigned(doutA), ind));
				enB <= '1';
				addrB <= instruction(13 downto 9);
				--register part
				
				actual_state <= STATE_PC_PLUS;
				
			when STATE_SRA =>
				
				if(instruction(0) = '1')then
					ind := to_integer(unsigned(doutB(4 downto 0)));
				else
					ind := to_integer(unsigned(instruction(18 downto 14)));
				end if;
				--register part
				dinB <= std_logic_vector(SHIFT_RIGHT(signed(doutA), ind));
				enB <= '1';
				addrB <= instruction(13 downto 9);
				--register part
				
				actual_state <= STATE_PC_PLUS;
				
			when STATE_SLL =>
			
				if(instruction(0) = '1')then
					ind := to_integer(unsigned(doutB(4 downto 0)));
				else
					ind := to_integer(unsigned(instruction(18 downto 14)));
				end if;
				--register part
				dinB <= std_logic_vector(SHIFT_LEFT( unsigned(doutA), ind));
				enB <= '1';
				addrB <= instruction(13 downto 9);
				--register part
				
				--status change
				if(doutA(31 - ind downto 0)&zeros(ind downto 0) = zeros)then
					STATE_REG(zero) <= '1';
				else
					STATE_REG(zero) <= '0';
				end if;
				--status change
				
				actual_state <= STATE_PC_PLUS;
				
			when STATE_LOAD =>
				if(doneFlag = '0')then
					enable_port <= '1';
					cmd_port <= "100";
					address_port <= doutA(23 downto 0);
					rd_bl_in_port <= "000000";
					mask_port <= "0000";
					doneFlag <= '1';
				end if;
				
				if(busy_port = '1' and doneFlag = '1')then
					addrB <= instruction(18 downto 14);
					dinB <= data_out_port;
					enB <= '1';
					actual_state <= STATE_PC_PLUS;
					doneFlag <= '0';
				end if;
			
			when STATE_STORE =>
				if(doneFlag = '0')then
					enable_port <= '1';
					cmd_port <= "101";
					address_port <= doutA(23 downto 0);
					data_in_port <= doutB;
					mask_port <= instruction(13 downto 10);
					doneFlag <= '1';
				end if;
				
				if(busy_port = '1' and doneFlag = '1')then
					actual_state <= STATE_PC_PLUS;
					doneFlag <= '0';
				end if;
				
			when STATE_JUMP =>
				program_counter <= '0'&doutA(23 downto 0);
				actual_state <= STATE_FETCH;
				
			when STATE_GREATER =>
				if(to_integer(unsigned(doutA)) > to_integer(unsigned(doutB)))then
					if(instruction(13 downto 9) = "00000") then
						program_counter <= std_logic_vector(unsigned(program_counter) + 2);
						actual_state <= STATE_FETCH;
					else
						addrA <= instruction(13 downto 9);
						actual_state <= STATE_GREATER_2;
					end if;
				else
					actual_state <= STATE_PC_PLUS;
				end if;
				
			when STATE_GREATER_2 =>
				program_counter <= '0'&doutA(23 downto 0);
				actual_state <= STATE_FETCH;
				
			when STATE_EQUAL =>
				if(to_integer(unsigned(doutA)) = to_integer(unsigned(doutB)))then
					if(instruction(13 downto 9) = "00000") then
						program_counter <= std_logic_vector(unsigned(program_counter) + 2);
						actual_state <= STATE_FETCH;
					else
						addrA <= instruction(13 downto 9);
						actual_state <= STATE_EQUAL_2;
					end if;
				else
					actual_state <= STATE_PC_PLUS;
				end if;
				
			when STATE_EQUAL_2 =>
				program_counter <= '0'&doutA(23 downto 0);
				actual_state <= STATE_FETCH;
				
			when STATE_LESS =>
				if(to_integer(unsigned(doutA)) < to_integer(unsigned(doutB)))then
					if(instruction(13 downto 9) = "00000") then
						program_counter <= std_logic_vector(unsigned(program_counter) + 2);
						actual_state <= STATE_FETCH;
					else
						addrA <= instruction(13 downto 9);
						actual_state <= STATE_LESS_2;
					end if;
				else
					actual_state <= STATE_PC_PLUS;
				end if;
				
			when STATE_LESS_2 =>
				program_counter <= '0'&doutA(23 downto 0);
				actual_state <= STATE_FETCH;
				
			when STATE_RVALUP =>
				addrA <= instruction(23 downto 19);
				dinA <= instruction(15 downto 0)&doutA(15 downto 0);
				enA <= '1';
				actual_state <= STATE_PC_PLUS;
				
			when STATE_RVALDOWN =>
				addrA <= instruction(23 downto 19);
				dinA <= doutA(31 downto 16)&instruction(15 downto 0);
				enA <= '1';
				actual_state <= STATE_PC_PLUS;
				
			when STATE_BTF =>
				if(doutA(to_integer(unsigned(instruction(18 downto 14)))) = '1') then
					if(instruction(13 downto 9) = "00000")then
						program_counter <= std_logic_vector(unsigned(program_counter) + 2);
					else
						program_counter <= '0'&doutB(23 downto 0);
					end if;
					actual_state <= STATE_FETCH;
				else
					actual_state <= STATE_PC_PLUS;
				end if;
				
			when STATE_BCF =>
				Rtemp := doutA;
				Rtemp(to_integer(unsigned(instruction(18 downto 14)))) := '0';
				dinA <= Rtemp;
				addrA <= instruction(23 downto 19);
				enA <= '1';
				actual_state <= STATE_PC_PLUS;
				
			when STATE_BSF =>
				Rtemp := doutA;
				Rtemp(to_integer(unsigned(instruction(18 downto 14)))) := '1';
				dinA <= Rtemp;
				addrA <= instruction(23 downto 19);
				enA <= '1';
				actual_state <= STATE_PC_PLUS;
				
			when STATE_SET_VIDR =>
				data_in_v_s <= doutA(23 downto 0);
				cmd_input_v_s <= instruction(18 downto 15);
				input_enable_v_s <= '1';
				actual_state <= STATE_PC_PLUS;
				
			when STATE_GET_VIDR_DUM =>
				actual_state <= STATE_GET_VIDR;
				
			when STATE_GET_VIDR =>
				dinA <= "00000000"&data_out_v;
				addrA <= instruction(23 downto 19);
				enA <= '1';
				actual_state <= STATE_PC_PLUS;
				
			when STATE_SET_STACK_POINTER =>
				stack_pointer <= doutA(23 downto 0);
				actual_state <= STATE_PC_PLUS;
			
			when STATE_SPRITE_TRANSPARENT =>
				spriteTransparent <= doutA(7 downto 0);
				actual_state <= STATE_PC_PLUS;
			
			when STATE_LOAD_SPRITE =>
				counter_load_sprite <= (others => '0');
				counter_store_sprite <= (others => '0');
				cmd_port <= "011";
				address_port <= doutA(23 downto 0);
				layer_address <= doutB(23 downto 0);
				enable_port <= '1';
				case(instruction(13 downto 12)) is
					when "00" =>
						rd_bl_in_port <= "001111";
						counter_load_limit <= "001111";
					when "01" =>
						rd_bl_in_port <= "011111";
						counter_load_limit <= "011111";
					when "10" =>
						rd_bl_in_port <= "011111";
						counter_load_limit <= "011111";
					when others =>
						rd_bl_in_port <= "111111";
						counter_load_limit <= "111111";
				end case;
				actual_state <= STATE_LOAD_SPRITE_WAIT;
				
			when STATE_LOAD_SPRITE_WAIT =>
				if(busy_port = '1') then
					cmd_port <= "001";
					enable_port <= '1';
					actual_state <= STATE_LOAD_SPRITE_DUMMYSTATE;
				end if;
			
			when STATE_LOAD_SPRITE_DUMMYSTATE =>
				counter_load_sprite <= (others => '0');
				if(busy_port = '1')then
					we_RSP <= "1";
					din_RSP <= data_out_port;
					addr_RSP <= counter_load_sprite;
					counter_load_sprite <= std_logic_vector(unsigned(counter_load_sprite) + 1);
					actual_state <= STATE_LOAD_SPRITE_RAM;
				end if;
			
			when STATE_LOAD_SPRITE_RAM =>
				if(busy_port = '1')then
					we_RSP <= "1";
					din_RSP <= data_out_port;
					addr_RSP <= counter_load_sprite;
					counter_load_sprite <= std_logic_vector(unsigned(counter_load_sprite) + 1);
				else
					we_RSP <= "0";
					actual_state <= STATE_STORE_SPRITE;
				end if;
				
			when STATE_STORE_SPRITE =>
				addrA <= instruction(11 downto 7); -- HORIZONTAL
				addrB <= instruction(6 downto 2); -- VERTICAL
				actual_state <= STATE_STORE_8x8;
				counter_store_sprite <= "000000";
			
			when STATE_STORE_8x8 => --Works for every size
				case (stateRamStore) is
					when "000" =>
						addr_RSP <= counter_store_sprite;
						if(counter_store_sprite = counter_load_limit)then
							end_sprite_system <= '1';
						end if;
						stateRamStore <= "001";
					when "001" =>
						data_in_port <= dout_RSP;
						if(dout_RSP(31 downto 24) = spriteTransparent) then
							mask_port(3) <= '1';
						else
							mask_port(3) <= '0';
						end if;
						if(dout_RSP(23 downto 16) = spriteTransparent) then
							mask_port(2) <= '1';
						else
							mask_port(2) <= '0';
						end if;
						if(dout_RSP(15 downto 8) = spriteTransparent) then
							mask_port(1) <= '1';
						else
							mask_port(1) <= '0';
						end if;
						if(dout_RSP(7 downto 0) = spriteTransparent) then
							mask_port(0) <= '1';
						else
							mask_port(0) <= '0';
						end if;
						enable_port <= '1';
						cmd_port <= "000";
						stateRamStore <= "000";
						prev_store_sprite <= counter_store_sprite;
						counter_store_sprite <= std_logic_vector(unsigned(counter_store_sprite) + 1);
						case(instruction(13 downto 12)) is
							when "00" =>
								if(counter_store_sprite(0) = '1')then
									stateRamStore <= "010";
								end if;
							when "01" =>
								if(counter_store_sprite(1 downto 0) = "11")then
									stateRamStore <= "011";
								end if;
							when "10" =>
								if(counter_store_sprite(0) = '1')then
									stateRamStore <= "010";
								end if;
							when others =>
								if(counter_store_sprite(1 downto 0) = "11")then
									stateRamStore <= "011";
								end if;
						end case;
					when "010" =>
						cmd_port <= "010";
						enable_port <= '1';
						address_port <= std_logic_vector(unsigned(layer_address) + unsigned(doutA(6 downto 0)) + (unsigned(doutB(7 downto 0)) + unsigned(prev_store_sprite(5 downto 1)))*unsigned(horizontal_size));
						stateRamStore <= "100";
					when "011" =>
						cmd_port <= "010";
						enable_port <= '1';
						address_port <= std_logic_vector(unsigned(layer_address) + unsigned(doutA(6 downto 0)) + (unsigned(doutB(7 downto 0)) + unsigned(prev_store_sprite(5 downto 2)))*unsigned(horizontal_size));
						stateRamStore <= "100";
					when others =>
						if(busy_port = '1')then
							if(end_sprite_system = '1')then
								actual_state <= STATE_PC_PLUS;
								end_sprite_system <= '0';
								counter_store_sprite <= (others => '0');
							end if;
							stateRamStore <= "000";
						end if;
				end case;
			
			when STATE_PUT_SP =>
				enable_port <= '1';
				cmd_port <= "101";
				address_port <= stack_pointer;
				data_in_port <= doutA;
				mask_port <= "0000";
				stack_pointer <= std_logic_vector(unsigned(stack_pointer) + 1);
				actual_state <= STATE_PUT_SP_WAIT;
				
			when STATE_PUT_SP_WAIT =>
				if(busy_port = '1') then
					actual_state <= STATE_PC_PLUS;
				end if;
			
			when STATE_POP_SP =>
				if(busy_port = '1')then
					addrB <= instruction(23 downto 19);
					dinB <= data_out_port;
					enB <= '1';
					actual_state <= STATE_PC_PLUS;
				end if;
			when STATE_MOV =>
				addrB <= instruction(18 downto 14);
				dinB <= doutA;
				enB <= '1';
				if(doutA = X"00000000") then
					STATE_REG(zero) <= '1';
				end if;
				actual_state <= STATE_PC_PLUS;
			when STATE_ADDI =>
				addrA <= instruction(23 downto 19);
				dinA <= std_logic_vector(unsigned(doutA) + unsigned(instruction(15 downto 0)));
				enA <= '1';
				actual_state <= STATE_PC_PLUS;
			when STATE_SUBI =>
				addrA <= instruction(23 downto 19);
				dinA <= std_logic_vector(unsigned(doutA) - unsigned(instruction(15 downto 0)));
				enA <= '1';
				actual_state <= STATE_PC_PLUS;
			when STATE_MULI =>
				addrA <= instruction(23 downto 19);
				Rt3 := std_logic_vector(unsigned(doutA) * unsigned(instruction(15 downto 0)));
				dinA <= Rt3(31 downto 0);
				addrB <= std_logic_vector(unsigned(instruction(23 downto 19)) + 1);
				dinB <= "0000000000000000"&Rt3(47 downto 32);
				enA <= '1';
				enB <= '1';
				actual_state <= STATE_PC_PLUS;
			when STATE_PREPARE_CALL =>
				temporal_register <= doutA(23 downto 0);
				actual_state <= STATE_CALL;
				if(instruction(0) = '1') then
					call_write_start <= doutB(4 downto 0);
				else
					call_write_start <= instruction(18 downto 14);
				end if;
			when STATE_CALL =>
				--debug_leds <= "00000"&call_state_system;
				--This system should be using the pop instruction
				--The control of the stack pointer should be deferred to a sub module inside the control system
				case call_state_system is
					when PREPARE_STORE_COUNTER =>
					
						call_store_counter <= call_write_start;
						addrA <= call_write_start;
						call_state_system <= REGISTER_WAIT;
					
					when REGISTER_WAIT =>
						
						call_state_system <= ADD_REGISTER_TO_FIFO;
					
					when ADD_REGISTER_TO_FIFO =>
						--Add register to port FIFO
						cmd_port <= "000";
						enable_port <= '1';
						data_in_port <= doutA;

						--Update count and get the next register
						call_store_counter <= std_logic_vector(unsigned(call_store_counter) + 1);
						addrA <= std_logic_vector(unsigned(call_store_counter) + 1);

						call_state_system <= REGISTER_WAIT;
						
						--If current count is alredy the last register, go to the next step
						if(call_store_counter = "11111") then
							call_state_system <= ADD_CURRENT_RETURN_TO_FIFO;
						end if;
					when ADD_CURRENT_RETURN_TO_FIFO =>
						--Write the current return register to the port fifo
						cmd_port <= "000";
						enable_port <= '1';
						data_in_port <= "00000000"&return_register;
						call_state_system <= ADD_CURRENT_WRITE_SIZE_TO_FIFO;

					when ADD_CURRENT_WRITE_SIZE_TO_FIFO =>
						--Write the current call write size to the port fifo
						data_in_port <= "00000000000000000000000000"&call_write_size;
						cmd_port <= "000";
						enable_port <= '1';
						call_state_system <= UPDATE_INTERNAL_CALL_REGISTERS_AND_BURST_WRITE_FIFO;

					when UPDATE_INTERNAL_CALL_REGISTERS_AND_BURST_WRITE_FIFO =>
						--Update return register
						return_register <= std_logic_vector(unsigned(program_counter(23 downto 0)) + 1);
						--Burst write to memory, using the stack pointer as the base register
						cmd_port <= "010";
						enable_port <= '1';
						address_port <= stack_pointer;
						--Update the stack pointer value
						stack_pointer <= std_logic_vector(unsigned(stack_pointer) + 33 - unsigned(call_write_start) + 1);
						--Update the call write size value
						call_write_size <= std_logic_vector(to_unsigned(33,6) - unsigned(call_write_start) + 1);
						call_state_system <= CHANGE_PROGRAM_COUNTER_AND_FETCH;
					when CHANGE_PROGRAM_COUNTER_AND_FETCH =>
						if(busy_port = '1')then
							program_counter <= '0'&temporal_register;
							actual_state <= STATE_FETCH;
							call_state_system <= PREPARE_STORE_COUNTER;
						end if;
					when others =>
						call_state_system <= PREPARE_STORE_COUNTER;
				end case;
			when STATE_RET =>
				case return_state_system is
					when "000" =>
						cmd_port <= "011";
						rd_bl_in_port <= call_write_size;
						enable_port <= '1';
						address_port <= stack_pointer;
						return_state_system <= "001";
						program_counter <= '0'&return_register;
					when "001" =>
						if(busy_port = '1')then
							cmd_port <= "001";
							enable_port <= '1';
							return_state_system <= "010";
							return_counter <= (others => '0');
						end if;
					when "010" =>
						if(busy_port = '1')then
							if(return_counter = std_logic_vector(unsigned(call_write_size) - 3)) then
								return_register <= data_out_port(23 downto 0);
							elsif(return_counter = std_logic_vector(unsigned(call_write_size) - 2))then
								call_write_size <= data_out_port(5 downto 0);
							else
								addrA <= return_counter(4 downto 0);
								enA <= '1';
								dinA <= data_out_port;
								return_counter <= std_logic_vector(unsigned(return_counter) + 1);
							end if;
							return_state_system <= "011";
						end if;
					when "011" =>
						if(busy_port = '1') then
							if(return_counter = std_logic_vector(unsigned(call_write_size) - 3)) then
								return_register <= data_out_port(23 downto 0);
							elsif(return_counter = std_logic_vector(unsigned(call_write_size) - 2))then
								call_write_size <= data_out_port(5 downto 0);
							else
								addrA <= return_counter(4 downto 0);
								enA <= '1';
								dinA <= data_out_port;
								return_counter <= std_logic_vector(unsigned(return_counter) + 1);
							end if;
						else
							return_state_system <= "100";
						end if;
					when others =>
						return_state_system <= "000";
						actual_state <= STATE_FETCH;
				end case;
			when STATE_HALT =>
				if(controlOutA(0) = '1')then
					--debug_leds <= lastProgramCounter(7 downto 0);
				elsif(controlOutA(1) = '1')then
					--debug_leds <= lastProgramCounter(15 downto 8);
				elsif(controlOutA(2) = '1')then
					--debug_leds <= lastProgramCounter(23 downto 16);
				elsif(controlOutA(3) = '1')then
					--debug_leds <= lastInstruction(31 downto 24);
				elsif(controlOutA(4) = '1')then
					--debug_leds <= lastInstruction(23 downto 16);
				elsif(controlOutA(5) = '1')then
					--debug_leds <= lastInstruction(15 downto 8);
				elsif(controlOutA(6) = '1')then
					--debug_leds <= lastInstruction(7 downto 0);
				elsif(controlOutA(7) = '1')then
					--debug_leds <= program_counter(7 downto 0);
				elsif(controlOutA(8) = '1')then
					--debug_leds <= program_counter(15 downto 8);
				elsif(controlOutA(9) = '1')then
					--debug_leds <= program_counter(23 downto 16);
				else
					debug_leds <= "01010101";
				end if;
				
			when others =>
				actual_state <= STATE_PC_PLUS;
			
		end case;
	end if;

end process;

end Behavioral;