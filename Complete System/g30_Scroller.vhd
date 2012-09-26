library IEEE;
LIBRARY ieee;
USE ieee.std_logic_1164.all;

LIBRARY lpm;
USE lpm.all;

entity g30_Scroller is
	port (  clock : in std_logic;
			reset : in std_logic;
			direction : in std_logic;
			fsel : in std_logic_vector (1 downto 0);
			code_out1 : out std_logic_vector (6 downto 0);
			code_out2 : out std_logic_vector (6 downto 0);
			code_out3 : out std_logic_vector (6 downto 0);
			code_out4 : out std_logic_vector (6 downto 0)
		);
end g30_Scroller;

architecture A_S of g30_Scroller is
	signal state : std_logic_vector (2 downto 0);
	signal pulse : std_logic;
	
	COMPONENT lpm_counter_state
	PORT (
		clock		: IN STD_LOGIC ;
		cnt_en		: IN STD_LOGIC ;
		updown		: IN STD_LOGIC ;
		q		: OUT STD_LOGIC_VECTOR (2 DOWNTO 0)
	);
	END COMPONENT;
	
		COMPONENT g30_Flasher_Timer
	PORT (
			fsel : 		in std_logic_vector (1 downto 0);
			clock_FP : 	in std_logic;
			reset : in std_logic;
			Flasher_Pulse : out Std_logic
	);
	END COMPONENT;
begin
	S1 : lpm_counter_state port map (clock => clock, cnt_en => pulse, updown => direction, q => state);
	S2 : g30_Flasher_Timer port map (fsel => fsel, clock_FP => clock, reset => reset, Flasher_Pulse => pulse);

	code_out1 	<= "0011101" when state = "000" else
				 "0001110" when state = "001" else
				 "1111111" when state = "010" else
				 "1111111" when state = "011" else
				 "1111111" when state = "100" else
				 "1111111" when state = "101" else
				 "0011101";
				
	code_out2 	<= "0011101" when state = "000" else
				 "0011101" when state = "001" else
				 "0001110" when state = "010" else
				 "1111111" when state = "011" else
				 "1111111" when state = "100" else
				 "1111111" when state = "101" else
				 "1111111";
				
	code_out3 	<= "1111111" when state = "000" else
				 "0011101" when state = "001" else
				 "0011101" when state = "010" else
				 "0001110" when state = "011" else
				 "1111111" when state = "100" else
				 "1111111" when state = "101" else
				 "1111111";
				
	code_out4 	<= "1111111" when state = "000" else
				 "1111111" when state = "001" else
				 "0011101" when state = "010" else
				 "0011101" when state = "011" else
				 "0001110" when state = "100" else
				 "1111111" when state = "101" else
				 "1111111";
				
end A_S;