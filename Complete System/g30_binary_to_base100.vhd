library IEEE;
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;

LIBRARY lpm;
USE lpm.all;

entity g30_binary_to_base100 is
	port ( 	binary : in std_logic_vector(25 downto 0);
			clk, reset : in std_logic;
			START : in std_logic;
			DONE : out std_logic;
			DIGIT1 : out std_logic_vector(6 downto 0);
			DIGIT2 : out std_logic_vector(6 downto 0);
			DIGIT3 : out std_logic_vector(6 downto 0);
			DIGIT4 : out std_logic_vector(6 downto 0));
end g30_binary_to_base100;

architecture A of g30_binary_to_base100 is
	-- STATE FSM Signals + Other
	TYPE state_signal IS(RESET_STATE, S2, S3, S4, S5, S6, S7, DONE_STATE);
	SIGNAL state : state_signal;
	signal count: integer range 0 to 26;
	signal count_shift: integer range 0 to 3;
	
	-- Integer Conversion Signals
	SIGNAL Int_Temp_D1 : integer range 0 to 100;
	SIGNAL Int_Temp_D2 : integer range 0 to 100;
	SIGNAL Int_Temp_D3 : integer range 0 to 100;
	SIGNAL Int_Temp_D4 : integer range 0 to 100;
	
	-- Temporary Digits
	SIGNAL Temp_D1 : std_logic_vector(6 downto 0);
	SIGNAL Temp_D2 : std_logic_vector(6 downto 0);
	SIGNAL Temp_D3 : std_logic_vector(6 downto 0);
	SIGNAL Temp_D4 : std_logic_vector(6 downto 0);
	SIGNAL Temp_BIN : std_logic_vector(25 downto 0);
	

	
BEGIN

-- State Changing FSM
FSM_state_update: process (clk,reset)
	begin
		if reset= '1'then
			DONE <= '0';
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
						state<= S3;
					end if;
				
				-- STATE 3	
				when S3=>
					count <= 0;
					DONE <= '0';
						
					state<= S4;
				
				-- STATE 4	
				when S4=>
					state<= S5;
				
				-- STATE 5	
				when S5=>

				state<= S6;
					
				-- STATE 6	
				when S6=>
				count <= count + 1;	
								
				state <= S7;
				
				-- STATE 7	
				when S7=>
					if count = 26 then
						state <= DONE_STATE;
					else
						-- 	Calculate Integer Values
						Int_Temp_D1 <= CONV_INTEGER(Temp_D1(6 downto 0));
						Int_Temp_D2 <= CONV_INTEGER(Temp_D2(6 downto 0));
						Int_Temp_D3 <= CONV_INTEGER(Temp_D3(6 downto 0));
						Int_Temp_D4 <= CONV_INTEGER(Temp_D4(6 downto 0));
						
						state <= S5;
					end if;
				
				-- DONE STATE
				when DONE_STATE=>
					DONE <= '1';
					
					-- Latch Final Values
					DIGIT1 <= Temp_D1;
					DIGIT2 <= Temp_D2;
					DIGIT3 <= Temp_D3;
					DIGIT4 <= Temp_D4;
										
					state<= RESET_STATE;
			end case;
		end if;
end process;

-- DIGIT 1 7-Bit Shift Register
DIGIT1_7_bit_shift_reg: process(clk)
begin
	if clk = '1' and clk'EVENT then
		-- Compute Addition Values
		
			
		-- Initialize Value of Temp_D1
		if state = S3 then
			Temp_D1 <= "0000000";
		
		-- Add 14 To DIGIT 1	
		elsif state = S5 then
			
			if Int_Temp_D1 > 49 then			
				Temp_D1 <= CONV_STD_LOGIC_VECTOR(Int_Temp_D1+14,7);
			end if;
		
		-- Shift	
		elsif state = S6 then 
				 Temp_D1 <= Temp_D1(5 downto 0) & TEMP_BIN(25);
		end if; --if enable
	end if; --if clear
end process;


-- DIGIT 2 7-Bit Shift Register
DIGIT2_7_bit_shift_reg: process(clk)
begin
	if clk = '1' and clk'EVENT then
		
			
		-- Initialize Value of Temp_D2
		if state = S3 then
			Temp_D2 <= "0000000";
		
		-- Add 14 To DIGIT 1	
		elsif state = S5 then
			
			if Int_Temp_D2 > 49 then			
				Temp_D2 <= CONV_STD_LOGIC_VECTOR(Int_Temp_D2+14,7);
			end if;
		
		-- Shift	
		elsif state = S6 then 
				Temp_D2 <= Temp_D2(5 downto 0) & Temp_D1(6);
		end if; --if enable
	end if; --if clear
end process;

-- DIGIT 3 7-Bit Shift Register
DIGIT3_7_bit_shift_reg: process(clk)
begin
	if clk = '1' and clk'EVENT then
		
				
		-- Initialize Value of Temp_D3
		if state = S3 then
			Temp_D3 <= "0000000";
		
		-- Add 14 To DIGIT 1	
		elsif state = S5 then
			
			if Int_Temp_D3 > 49 then			
				Temp_D3 <= CONV_STD_LOGIC_VECTOR(Int_Temp_D3+14,7);
			end if;
		
		-- Shift	
		elsif state = S6 then 
				Temp_D3 <= Temp_D3(5 downto 0) & Temp_D2(6);
		end if; --if enable
	end if; --if clear
end process;

-- DIGIT 4 7-Bit Shift Register
DIGIT4_7_bit_shift_reg: process(clk)
begin
	if clk = '1' and clk'EVENT then
		
				
		-- Initialize Value of Temp_D4
		if state = S3 then
			Temp_D4 <= "0000000";
		
		-- Add 14 To DIGIT 1
		elsif state = S5 then
			
			if Int_Temp_D4 > 49 then			
				Temp_D4 <= CONV_STD_LOGIC_VECTOR(Int_Temp_D4+14,7);
			end if;
		
		-- Shift	
		elsif state = S6 then 
				Temp_D4 <= Temp_D4(5 downto 0) & Temp_D3(6);
		end if; --if enable
	end if; --if clear
end process;

-- 26-Bit Shift Register
BINARY_26_bit_shift_reg: process(clk)
begin
	if clk = '1' and clk'EVENT then
		if state = S4 then
			TEMP_BIN <= binary; --  Load Number
		elsif state = S6 then
			TEMP_BIN <= TEMP_BIN(24 downto 0) & '1';
		end if; --if enable
	end if; --if clear
end process;

end A;