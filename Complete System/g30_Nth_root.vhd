library IEEE;
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;

LIBRARY lpm;
USE lpm.all;

entity
g30_Nth_root is
	port ( 	X : in std_logic_vector(6 downto 0);
			N : in std_logic_vector(5 downto 0);
			START : in std_logic;
			clock : in std_logic;
			reset : in std_logic;
			Y : out std_logic_vector(20 downto 0);
			DONE : out std_logic );
end g30_Nth_root;

architecture N of g30_Nth_root is
	signal NR_state : std_logic_vector (3 downto 0);
	signal BC : integer range 0 to 20;
	signal count : integer range 0 to 100;
	signal Z : std_logic_vector (41 downto 0);
	signal X_Compare: std_logic_vector (41 downto 0);
	signal int_Y : integer range 0 to 100;
	signal int_N : integer range 0 to 100;
	signal temp_Y_21 : std_logic_vector(20 downto 0);
	signal temp_Z_old : std_logic_vector(20 downto 0);
	signal temp_product : std_logic_vector(41 downto 0);
begin

X_Compare <= "0000000" & X & "0000000000000000000000000000";

-- State Changing FSM
FSM_state_update: process (clock,reset)
	begin	
		if reset= '1'then
			NR_state <= "0000";
			DONE <= '0';
		elsif clock'EVENT and clock='1'then
			case NR_state is
				-- RESET STATE
				when "0000" =>
					
					NR_state <= "0001";

				when "0001"=>
					if START = '0' then
						NR_state <= "0010";
					end if;

				when "0010"=>
					if START = '1' then
						Temp_Y_21 <= "000000000000000000000";
						BC <= 20;
						int_N <= conv_integer(N);
						NR_state <= "0011";
					end if;
					
				when "0011"=>
					NR_state <= "0100";

				when "0100"=>
					
					temp_Y_21(BC) <= '1';
					NR_state <= "0101";

				when "0101"=>
					
					count <= 1;
					temp_Z_old <= Temp_Y_21;
					
					NR_state <= "0110";

				when "0110"=>						
						Z <= temp_Z_old * Temp_Y_21;
						count <= count + 1;
						NR_state <= "0111";
				
				when "0111"=>
						NR_state <= "1000";
												
				when "1000"=>
						temp_Z_old <= Z(34 downto 14);
												
						if Z > X_Compare then	
							Temp_Y_21(BC) <= '0';	
							NR_state <= "1001";
						elsif count = Int_N then
							NR_state <= "1001";
						else
							NR_state <= "0110";
						end if;
				when "1001"=>
					temp_product <= Temp_Y_21 * "100111000100000000000";
					NR_state <= "1010";
				
				when "1010"=>
					NR_state<= "1011";
					
				when "1011"=>
					if BC > 0 then
						BC <= BC - 1;
						NR_state <= "0011";
					elsif BC = 0 then
						Y <= Temp_Y_21;
						DONE <= '1';
						NR_state <= "0000";
					end if;
				when others =>
					NR_state <= "0000";
			end case;
		end if;
end process;
end N;