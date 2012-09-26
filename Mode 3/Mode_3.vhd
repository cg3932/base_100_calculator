library ieee; -- allows use of the std_logic_vector type
use ieee.std_logic_1164.all;

library lpm; -- allows use of the Altera library modules
use lpm.lpm_components.all;

entity Mode_3 is
	port ( 	clock : in std_logic;
			reset : in std_logic;
			ERROR : out std_logic;
			START : in std_logic;
			DONE : out std_logic;
			i : in std_logic_vector(11 downto 0);
			N : out std_logic_vector(25 downto 0));
end Mode_3;

architecture A_Mode_3 of Mode_3 is
	
	signal Mif_Out : std_logic_vector (15 downto 0);
	type M3_state_signal is(M3_RESET_STATE, M3_S1, M3_S2, M3_S3, M3_DONE_STATE);
	signal M3_state : M3_state_signal;
	
BEGIN
	
	log2_table : lpm_rom -- use the altera rom library macrocell
	GENERIC MAP(
	lpm_widthad => 12, -- sets the width of the ROM address bus
	lpm_numwords => 4096, -- sets the words stored in the ROM
	lpm_outdata => "UNREGISTERED", -- no register on the output
	lpm_address_control => "REGISTERED", -- no register on the input
	lpm_file => "mode3mif.mif", -- the ascii file containing the ROM data
	lpm_width => 16) -- the width of the word stored in each ROM location
	PORT MAP(inclock => clock, address => i, q => Mif_Out);
	
	FSM_state_update: process (clock,reset)
	begin	
		if reset= '1'then
			DONE <= '0';
			ERROR <= '0';
			M3_state <= M3_RESET_STATE;
			
		elsif clock'EVENT and clock='1'then
			case M3_state is
				when M3_RESET_STATE=>
					if START <= '0' then
						M3_state <= M3_S1;
					end if;	
					
				when M3_S1=>
					if START <= '1' then
						M3_state <= M3_S2;
					end if;
					
				when M3_S2=>
					if Mif_Out < "111111" then
						M3_state <= M3_S3;
					else
						ERROR <= '1';
						M3_state <= M3_DONE_STATE;
					end if;
					
				when M3_S3=>
					N <= "0000000000" & Mif_Out;
					M3_state <= M3_DONE_STATE;
					
				when M3_DONE_STATE=>
					DONE <= '1';
					M3_state <= M3_RESET_STATE;
			end case;
		end if;
	end process;
end A_Mode_3;