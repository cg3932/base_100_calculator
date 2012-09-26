library IEEE;
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;

LIBRARY lpm;
USE lpm.all;

entity Mode_1 is
	port ( 	clk : in std_logic;
			START : in std_logic;
			reset : in std_logic;
			i : in std_logic_vector (6 downto 0);
			N : in std_logic_vector (5 downto 0);
			PV : in std_logic_vector (26 downto 0);
			FV : out std_logic_vector (26 downto 0);
			OUT_TO_MULTIPLY : out std_logic_vector (26 downto 0);
			OUT_DECIMAL : out std_logic_vector (19 downto 0);
			OUT_FRACTIONAL : out std_logic_vector (6 downto 0);
			ERROR : out std_logic;
			DONE : out std_logic);
end Mode_1;

architecture A_Mode_1 of Mode_1 is

-- State Signal
TYPE state_signal IS(RESET_STATE, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, S12, DONE_STATE);
SIGNAL state : state_signal;

-- Temporary Inputs
SIGNAL TEMP_i : std_logic_vector (6 downto 0);
SIGNAL TEMP_N : std_logic_vector (5 downto 0);
SIGNAL TEMP_PV : std_logic_vector (26 downto 0);

--Temporary Outputs
SIGNAL TEMP_FV : std_logic_vector (26 downto 0);
SIGNAL TEMP_FINAL_PRODUCT : std_logic_vector (53 downto 0);

-- Other
SIGNAL MODE1_COUNT: integer range 0 to 63;
SIGNAL INT_N: integer range 0 to 63;
SIGNAL TEMP_TO_MULTIPLY : std_logic_vector (26 downto 0);
SIGNAL TEMP_DIVISION_i : std_logic_vector (29 downto 0);
SIGNAL TEMP_DIVISION : std_logic_vector (59 downto 0);
SIGNAL TEMP_NTH_POWER : std_logic_vector (53 downto 0);
SIGNAL TEMP_NTH_POWER_OLD : std_logic_vector (26 downto 0);
SIGNAL TEMP_PRODUCT : std_logic_vector (26 downto 0);

BEGIN

Mode1_state_update: process (clk,reset)
	begin
		if reset= '1'then
			DONE <= '0';
			ERROR <= '0';
			state <= RESET_STATE;
		elsif clk = '1' and clk'EVENT then

			case state is
				-- RESET STATE
			when RESET_STATE=>
			if START = '0'then
						state<= S2;
					end if;
				
				-- STATE 2	
				when S2=>
					if START = '1'then
						INT_N <= conv_integer(N);
						state<= S3;
					end if;
				
				-- STATE 3	
				when S3=>
					MODE1_COUNT <= 0;
					DONE <= '0';
					TEMP_DIVISION_i <= "000" & i & "00000000000000000000";
						
					state<= S4;
				
				-- STATE 4	
				when S4=>
					TEMP_DIVISION <= TEMP_DIVISION_i * "000000000000000010100011110110";
					
					state<= S5;
					
				-- STATE 5
				when S5=>
					
					TEMP_DIVISION(40) <= '1';
					state<= S6;
				
				-- STATE 6	
				when S6=>
					
					TEMP_TO_MULTIPLY <= TEMP_DIVISION(59 downto 33);
					
					state<= S7;
					
				-- STATE 7
				when S7=>
					MODE1_COUNT <= 1;
					TEMP_NTH_POWER_OLD <= TEMP_TO_MULTIPLY;
					
					OUT_TO_MULTIPLY <= TEMP_TO_MULTIPLY; 
					
					state <= S8;
					
				-- STATE 8
				when S8=>
					TEMP_NTH_POWER <= TEMP_NTH_POWER_OLD * TEMP_TO_MULTIPLY;
					MODE1_COUNT <= MODE1_COUNT +1 ;
					state <= S9;
				
				-- STATE 9
				when S9=>
					if TEMP_NTH_POWER > "000000000000000000000000000000000011110100001001000000" then
						ERROR <= '1';
						state <= RESET_STATE;
					else
						TEMP_NTH_POWER_OLD <= TEMP_NTH_POWER(33 downto 7);
						state <= S10;
					end if;
					
				-- STATE 10
				when S10=>
					if MODE1_COUNT = INT_N then
						TEMP_PV <= PV;
						TEMP_FV <= TEMP_NTH_POWER(33 downto 7);
						state <= S11;
					else
						state <= S8;
					end if;
					
				-- STATE 11
				when S11=>
					TEMP_FINAL_PRODUCT <= TEMP_FV * TEMP_PV;
					state <= S12;
					
				-- STATE 12
				when S12=>
					-- Latch Final Values
					TEMP_FV <= TEMP_FINAL_PRODUCT(33 downto 7);
					state <= DONE_STATE;
				
				-- DONE STATE
				when DONE_STATE=>
					DONE <= '1';
					OUT_DECIMAL <= TEMP_FV (26 downto 7);
					OUT_FRACTIONAL <= TEMP_FV (6 downto 0);
					FV <= TEMP_FV;
										
					state<= RESET_STATE;
			end case;
		end if;
end process;

end A_Mode_1;