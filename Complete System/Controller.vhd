library IEEE;
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;

LIBRARY lpm;
USE lpm.all;

entity Controller is
	port ( 	clk : in std_logic;
			reset : in std_logic;
			
			
			IN_LATCH : in std_logic;
			IN_LATCH_VALUE : in std_logic_vector (6 downto 0);
			
			mode : out std_logic_vector(1 downto 0);
			PV : out std_logic_vector (26 downto 0);
			N : out std_logic_vector (5 downto 0);
			M : out std_logic_vector (6 downto 0);
			i : out std_logic_vector (6 downto 0);
			
			Code_To_Convert : out std_logic_vector (25 downto 0);
			Error_Input : out std_logic;
			DISPLAY_START : out std_logic;
			DONE : out std_logic);
end Controller;

architecture A_Controller of Controller is
-- State Signal
TYPE state_signal IS(RESET_STATE, Error_State, Clear_LEDs, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, S12, S13, S14, S15, S16, S17, NSMode, NSi, NSN, NSM, NSPV, D_i, D_M, D_N, D_PV, DONE_STATE);
SIGNAL state : state_signal;

-- LATCH Values
SIGNAL Value_Inputed : std_logic_vector (6 downto 0);
SIGNAL Mode_Latch : std_logic_vector (1 downto 0);
SIGNAL i_LATCH : std_logic_vector (6 downto 0);
SIGNAL N_LATCH : std_logic_vector (6 downto 0);
SIGNAL M_LATCH : std_logic_vector (6 downto 0);

SIGNAL PV1 : std_logic_vector (6 downto 0);
SIGNAL PV2 : std_logic_vector (6 downto 0);
SIGNAL PV3 : std_logic_vector (6 downto 0);
SIGNAL PV4 : std_logic_vector (6 downto 0);
SIGNAL PV_COMPARE : std_logic_vector (26 downto 0);

BEGIN

Controller_state_update: process (clk,reset)
		begin
		if reset= '1'then
			mode <= "00";
			Error_Input <= '0';
			DONE <= '0';
			state <= RESET_STATE;
			DISPLAY_START <= '0';
		elsif clk = '1' and clk'EVENT then
			case state is
				-- RESET STATE
				when RESET_STATE=>
					
				state <= Clear_LEDs;
				
				-- Error State, only left through resetting
				when Error_State=>
					Error_Input <= '1';
					
				when Clear_LEDs=>
	
					-- Get Mode
					if IN_LATCH = '1'then
						Value_Inputed <= IN_LATCH_VALUE;
						
						-- Set to input mode
						mode <= "00";
						Code_To_Convert <= "00000000000000000000000000";
						DISPLAY_START <= '1'; 
						state<= S2;
					end if;
					
				-- STATE 2 - LATCH VALUE FOR MODE
				when S2=>
					DISPLAY_START <= '0';
					Mode_Latch <= Value_Inputed(1 downto 0);
					
					if IN_LATCH = '0' then 
						state <= S3;
					end if;
					
				-- STATE 3 - DISPLAY & MOVE TO STATE BASED ON MODE
				when S3=>
					Code_To_Convert <= "000000000000000000000000" & Mode_Latch;
					DISPLAY_START <= '1';
					state <= NSMode;
					
				-- state NSMode;
				when NSMode=>
					DISPLAY_START <= '0';
				
					if Mode_Latch = "01" then
						state <= S4;
					elsif Mode_Latch = "10" then
						state <= S6;
					elsif Mode_Latch = "11" then
						state <= S4;
					else
						Error_Input <= '1';	
						state <= Error_State;
					end if;
					
					
					
				
				-- STATE 4 - LATCH VALUE FOR i
				when S4=>
				if IN_LATCH = '1'then
						Value_Inputed <= IN_LATCH_VALUE; 
						state<= S5;
				end if;
				
				-- STATE 5 -- LATCH i
				when S5=>
					i_LATCH <= Value_Inputed;
					
					if IN_LATCH = '0' then 
						state <= D_i;
					end if;
					
				-- STATE D_i
				when D_i=>
					if i_LATCH > "1100011" then
						Error_Input <= '1';	
						state <= Error_State;
					else
						Code_To_Convert <= "0000000000000000000" & i_LATCH;
						DISPLAY_START <= '1';
						state <= NSi;
					end if;
					
				when NSi=>
					DISPLAY_START <= '0';
					
				-- Choose next stage to input or terminate
					
					if Mode_Latch = "01" then
						state <= S6;
					elsif Mode_Latch = "10" then
						Error_Input <= '1';	
						state <= Error_State;
					elsif Mode_Latch = "11" then
						state <= DONE_STATE;
					else
						Error_Input <= '1';	
						state <= Error_State;
					end if;

					
					
					
					
					
				
				-- STATE 6 -- LATCH VALUE FOR N
				when S6=>
					if IN_LATCH = '1'then
						Value_Inputed <= IN_LATCH_VALUE; 
						state<= S7;
				end if;
				
				-- STATE 7 - LATCH N
				when S7=>
					N_LATCH <= Value_Inputed;
					
					if IN_LATCH = '0' then 
						state <= D_N;
					end if;
					
				-- STATE D_N
				when D_N=>
					if N_LATCH > "0111111" then
						Error_Input <= '1';	
						state <= Error_State;
					else
						Code_To_Convert <= "0000000000000000000" & N_LATCH;
						DISPLAY_START <= '1';
						state <= NSN;
					end if;
					
				when NSN=>
					DISPLAY_START <= '0';
					
					-- Choose next stage to input or terminate
					
						if Mode_Latch = "01" then
							state <= S10;
						elsif Mode_Latch = "10" then
							state <= S8;
						elsif Mode_Latch = "11" then
							Error_Input <= '1';	
							state <= Error_State;
						else
							Error_Input <= '1';	
							state <= Error_State;
						end if;
					
					
					
				-- STATE 8 - LATCH VALUE FOR M
				when S8 =>
					if IN_LATCH = '1'then
						Value_Inputed <= IN_LATCH_VALUE; 
						state<= S9;
				end if;
				
				-- STATE 9 - LATCH M
				when S9=>
					M_LATCH <= Value_Inputed;
					
					if IN_LATCH = '0' then
						state <= D_M;
					end if;
					
				-- STATE D_M
				when D_M=>
					-- CHECK FOR OVERFLOW OF INPUT
					if M_LATCH > "1100011" then
						Error_Input <= '1';	
						state <= Error_State;
					else
						Code_To_Convert <= "0000000000000000000" & M_LATCH;
						DISPLAY_START <= '1';
						state <= NSM;
					end if;
					
				when NSM=>
					DISPLAY_START <= '0';
					
					-- Choose next stage to input or terminate
						if Mode_Latch = "01" then
							Error_Input <= '1';	
							state <= Error_State;
						elsif Mode_Latch = "10" then
							state <= DONE_STATE;
						elsif Mode_Latch = "11" then
							Error_Input <= '1';	
							state <= Error_State;
						else
							Error_Input <= '1';	
							state <= Error_State;
						end if;
					
					
					
					
					
				-- STATE 10 - LATCH VALUE FOR PV
				when S10=>
					if IN_LATCH = '1'then
						Value_Inputed <= IN_LATCH_VALUE; 
						state<= S11;
					end if;
				
				-- STATE 11 - LATCH PV1
				when S11=>
					PV1 <= Value_Inputed;
					
					if IN_LATCH = '0' then 
						state <= S12;
					end if;
					
				-- STATE 12 - LATCH PV2
				when S12=>
					if IN_LATCH = '1'then
						Value_Inputed <= IN_LATCH_VALUE; 
						state<= S13;
					end if;
				
				-- STATE 13 - LATCH PV2
				when S13=>
					PV2 <= Value_Inputed;
					
					if IN_LATCH = '0' then 
						state <= S14;
					end if;
					
				-- STATE 13 - LATCH PV3
				when S14=>
					if IN_LATCH = '1'then
						Value_Inputed <= IN_LATCH_VALUE; 
						state<= S15;
					end if;
				
				-- STATE 14 - LATCH PV3
				when S15=>
					PV3 <= Value_Inputed;
					
					if IN_LATCH = '0' then 
						state <= S16;
					end if;
				
				-- STATE 15 - LATCH PV4
				when S16=>
					if IN_LATCH = '1'then
						Value_Inputed <= IN_LATCH_VALUE; 
						state<= S17;
					end if;
				
				-- STATE 16 - LATCH PV4
				when S17=>
					PV4 <= Value_Inputed;
					
					if IN_LATCH = '0' then 
						state <= D_PV;
					end if;
					
				when D_PV=>
					Code_To_Convert <= PV4(4 downto 0) & PV3 & PV2 & PV1;
					DISPLAY_START <= '1';
					state <= NSPV;
					
				when NSPV=>
					DISPLAY_START <= '0';
					
					-- Latch Final PV For Comparison & Output
					PV_COMPARE <= PV4(5 downto 0) & PV3 & PV2 & PV1;
					
					-- Choose next stage to input or terminate
					if Mode_Latch = "01" then
						state <= DONE_STATE;
					elsif Mode_Latch = "10" then
						Error_Input <= '1';	
						state <= Error_State;
					elsif Mode_Latch = "11" then
						Error_Input <= '1';	
						state <= Error_State;
					else
						Error_Input <= '1';	
						state <= Error_State;
					end if;

					
				-- DONE STATE
				when DONE_STATE=>
					-- Latch all final values
					mode <= Mode_Latch;
					PV <= PV_COMPARE;
					N <= N_LATCH(5 downto 0);
					M <= M_LATCH;
					i <= i_LATCH;
					
					-- FINISH
					if PV_COMPARE > "111101000010001111111111111" then
						Error_Input <= '1';
						state <= Error_State;
					else
						DONE <= '1';
						state <= RESET_STATE;
					end if;
					
			end case;
		end if;
	end process;

end A_Controller;