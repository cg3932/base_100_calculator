-- this circuit computes the log base 2 of the input
-- entity name: g30_log2

library ieee; -- allows use of the std_logic_vector type
use ieee.std_logic_1164.all;

library lpm; -- allows use of the Altera library modules
use lpm.lpm_components.all;

entity g30_log_2 is
	port ( clock : in std_logic;
	input_value : in std_logic_vector(11 downto 0);
	log2 : out std_logic_vector(15 downto 0));
end g30_log_2;

architecture a_g30_log2 of g30_log_2 is
BEGIN
	log2_table : lpm_rom -- use the altera rom library macrocell
	GENERIC MAP(
	lpm_widthad => 12, -- sets the width of the ROM address bus
	lpm_numwords => 4096, -- sets the words stored in the ROM
	lpm_outdata => "UNREGISTERED", -- no register on the output
	lpm_address_control => "REGISTERED", -- no register on the input
	lpm_file => "crc_rom.mif", -- the ascii file containing the ROM data
	lpm_width => 16) -- the width of the word stored in each ROM location
	PORT MAP(inclock => clock, address => input_value, q => log2);
end a_g30_log2;

