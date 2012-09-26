library IEEE;
LIBRARY ieee;
USE ieee.std_logic_1164.all;

LIBRARY lpm;
USE lpm.all;

entity g30_Flasher is
	port (	clock : 	in std_logic;
			reset : in std_logic;
			fsel : 		in std_logic_vector (1 downto 0);
			MUXCODE1 : OUT std_logic_vector (6 downto 0);
			MUXCODE2 : OUT std_logic_vector (6 downto 0)
		);
end g30_Flasher;

architecture A_F of g30_Flasher is
	signal pulse : std_logic;

	COMPONENT g30_Flasher_Timer
	PORT (
			fsel : 		in std_logic_vector (1 downto 0);
			clock_FP : 	in std_logic;
			reset : in std_logic;
			Flasher_Pulse : out Std_logic
	);
	END COMPONENT;
	
		COMPONENT g30_Flasher_Mux
	PORT (
			clock_FM : 	in std_logic;
			enable_FM : in std_logic;
			MUXOUT1 : OUT std_logic_vector (6 downto 0);
			MUXOUT2 : OUT std_logic_vector (6 downto 0)
	);
	END COMPONENT;
BEGIN
	F1 : g30_Flasher_Timer port map (fsel => fsel, clock_FP => clock, reset => reset, Flasher_Pulse => pulse);
	F2 : g30_Flasher_Mux port map (clock_FM => clock, enable_FM => pulse, MUXOUT1 => MUXCODE1, MUXOUT2 => MUXCODE2);
end A_F;