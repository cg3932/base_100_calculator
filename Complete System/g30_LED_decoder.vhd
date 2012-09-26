-- Christian Gallai (260218797) & Stefanos Koskinas (260211145)
-- g30_7_segment_decoder
-- This circuit takes in a 7-bit binary code representing the 100 digits between 00 and 99
-- and generates the 7-segment display associated with the input code. A "Ripple-Blank" function
-- is also employed with the purpose of blanking leadingzeros for cascaded decoders.

library IEEE;
LIBRARY ieee;
USE ieee.std_logic_1164.all;

LIBRARY lpm;
USE lpm.all;

entity g30_LED_decoder is
	port (  
			-- Inputs
			code : in std_logic_vector(6 downto 0);
			RippleBlank_In : in std_logic;
			
			-- Outputs
			RippleBlank_Out : out std_logic;
			segments : out std_logic_vector(6 downto 0));
end g30_LED_decoder;

architecture A_LD of g30_LED_decoder is
	-- Declare signals used to perform "Ripple-Blank" Function
	signal codeb : std_logic_vector(6 downto 0);
	signal blank : std_logic;
	signal zero : std_logic;
BEGIN
	
	-- Detect if the code input is a zero
	zero <= '1' WHEN code = "0000000" else
			'0';
	
	-- If code is a zero, then blank equals a '1'	
	blank <= zero AND RippleBlank_In;			
	
	-- If blank equals a 1, then blank, otherwise, code is equal to it's
	-- initial value and display proceeds as normal.
	codeb <= "1111111" WHEN blank = '1'else
			code;
	
	-- Assign value for 'RippleBank_Out' i.e. = blank
	RippleBlank_Out <= blank;
	
	-- Determine segments [0..6] output based on code
	WITH codeb SELECT
		segments<=	"1000000" WHEN "0000000",
					"1111100" WHEN "0000001",
					"0010010" WHEN"0000010" ,
					"0011000" WHEN"0000011" ,
					"0101100" WHEN"0000100",
					"0001001" WHEN"0000101",
					"0000001" WHEN"0000110",
					"1011100" WHEN"0000111",
					"0000000" WHEN"0001000" ,
					"0001000" WHEN"0001001",
					"0000100" WHEN"0001010",
					"0100001" WHEN"0001011" ,
					"1000011" WHEN"0001100" ,
					"0110000" WHEN"0001101",
					"0000011" WHEN"0001110",
					"0000111" WHEN"0001111" ,
					"1000001" WHEN"0010000" ,
					"0100100" WHEN"0010001",
					"1111101" WHEN"0010010",
					"1111000" WHEN"0010011",
					"0100111" WHEN"0010100",
					"1100011" WHEN"0010101",
					"1000100" WHEN"0010110",
					"1100100" WHEN"0010111",
					"0110001" WHEN"0011000",
					"0000110" WHEN"0011001",
					"0001110" WHEN"0011010",
					"0000101" WHEN"0011011",
					"1010101" WHEN"0011100",
					"1000111" WHEN"0011101",
					"1100000" WHEN"0011110",
					"1110001" WHEN"0011111",
					"1100001" WHEN"0100000",
					"1101101" WHEN"0100001",
					"0101000" WHEN"0100010",
					"1010010" WHEN"0100011",
					"1111011" WHEN"0100100",
					"0111111" WHEN"0100101",
					"1011111" WHEN"0100110",
					"0011111" WHEN"0100111",
					"1011011" WHEN"0101000",
					"0111011" WHEN"0101001",
					"0011011" WHEN"0101010",
					"1001111" WHEN"0101011",
					"0001111" WHEN"0101100",
					"1101110" WHEN"0101101",
					"0101110" WHEN"0101110",
					"0111110" WHEN"0101111",
					"1011110" WHEN"0110000",
					"1001110" WHEN"0110001",
					"1110011" WHEN"0110010",
					"0111100" WHEN"0110011",
					"0111001" WHEN"0110100",
					"0011001" WHEN"0110101",
					"0010001" WHEN"0110110",
					"1010001" WHEN"0110111",
					"1010011" WHEN"0111000",
					"1011001" WHEN"0111001",
					"0010111" WHEN"0111010" ,
					"0011101" WHEN"0111011",
					"0010011" WHEN"0111100",
					"1101011" WHEN"0111101",
					"0001010" WHEN"0111110",
					"1001010" WHEN"0111111",
					"1001011" WHEN"1000000",
					"1011010" WHEN"1000001",
					"0111010" WHEN"1000010",
					"0101011" WHEN"1000011",
					"0001011" WHEN"1000100",
					"0011010" WHEN"1000101",
					"0100011" WHEN"1000110",
					"0111000" WHEN"1000111",
					"0110110" WHEN"1001000" ,
					"0010110" WHEN"1001001",
					"0110010" WHEN"1001010",
					"0101101" WHEN"1001011",
					"0001101" WHEN"1001100",
					"0101001" WHEN"1001101",
					"0100110" WHEN"1001110",
					"0011100" WHEN"1001111",
					"0001100" WHEN"1010000",
					"0010100" WHEN"1010001",
					"1100101" WHEN"1010010",
					"0010000" WHEN"1010011",
					"0100000" WHEN"1010100",
					"0100010" WHEN"1010101" ,
					"1001001" WHEN"1010110",
					"1011000" WHEN"1010111",
					"1110110" WHEN"1011000",
					"1001100" WHEN"1011001" ,
					"1101100" WHEN"1011010",
					"1010100" WHEN"1011011",
					"1000101" WHEN"1011100",
					"1010000" WHEN"1011101",
					"1100110" WHEN"1011110",
					"1100010" WHEN"1011111",
					"1101000" WHEN"1100000",
					"1001000" WHEN"1100001",
					"1000010" WHEN"1100010",
					"1101111" WHEN"1100011",
					"1111111" WHEN OTHERS;
end A_LD;