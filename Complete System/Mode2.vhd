library IEEE;
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;

LIBRARY lpm;
USE lpm.all;

entity Mode2 is
	port (  M : in std_logic_vector(6 downto 0);
			N : in std_logic_vector(5 downto 0);
			START : in std_logic;
			clock : in std_logic;
			reset : in std_logic;
			ERROR : out std_logic;
			DONE : out std_logic;
			i : out std_logic_vector(6 downto 0));
end Mode2;

architecture M2 of Mode2 is
	type state_signal is(M2_RESET_STATE, M2_S2, M2_S3, M2_S4, M2_S5, M2_S6, M2_S7, M2_S8, M2_S9, M2_DONE_STATE);
	signal M2_state : state_signal;
	signal M_ratio : std_logic_vector(6 downto 0);
	signal N_years : std_logic_vector(5 downto 0);
	signal M_root : std_logic_vector(20 downto 0);
	signal subM_root : std_logic_vector(20 downto 0);
	signal temp_i : std_logic_vector(41 downto 0);
	signal temp_100 : std_logic_vector(20 downto 0);
	signal i_rate : std_logic_vector(6 downto 0);
	signal Nth_DONE : std_logic;
	signal int_subM : integer range 0 to 128;

	component g30_Nth_root
	port (  X : in std_logic_vector(6 downto 0);
			N : in std_logic_vector(5 downto 0);
			START : in std_logic;
			clock : in std_logic;
			reset : in std_logic;
			Y : out std_logic_vector(20 downto 0);
			DONE : out std_logic );
	end component;
	
begin

-- State Changing FSM
FSM_state_update: process (clock,reset)
	begin
		M_ratio <= M;
		N_years <= N;
	
		if reset='1'then
			M2_state <= M2_RESET_STATE;
			DONE <= '0';
			ERROR <= '0';
		elsif clock'EVENT and clock='1'then
			case M2_state is
				-- RESET STATE
				when M2_RESET_STATE=>
					
					M2_state <= M2_S2;

				when M2_S2=>
					if START = '0' then
						M2_state <= M2_S3;
					end if;

				when M2_S3=>
					if START = '1' then
						M2_state <= M2_S4;
					end if;

				when M2_S4=>
					if Nth_DONE = '1' then
						subM_root <= M_root;
						M2_state <= M2_S5;
					end if;
				
				when M2_S5=>
					int_subM <= conv_integer(subM_root(20 downto 14));
					M2_state <= M2_S6;
				
				when M2_S6=>
					int_subM <= int_subM - 1;
					temp_100 <= "1100100" & "00000000000000";
					M2_state <= M2_S7;
					
				when M2_S7=>
					subM_root <= conv_std_logic_vector(int_subM, 7) & subM_root(13 downto 0);

					M2_state <= M2_S8;

				when M2_S8=>
					temp_i <= subM_root * temp_100;
					M2_state <= M2_S9;
					
				when M2_S9=>
					i_rate <= temp_i(34 downto 28);
					M2_state <= M2_DONE_STATE;
					
				when M2_DONE_STATE=>
					i <= i_rate;
					M2_state <= M2_RESET_STATE;
					DONE <= '1';	
			end case;
		end if;
end process;

M2_C : g30_Nth_root port map (X => M_ratio, N => N_years, START => START, clock => clock, reset => reset, Y => M_root, DONE => Nth_DONE);

end M2;