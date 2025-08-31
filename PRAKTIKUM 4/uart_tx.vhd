library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity uart_tx is
	port	(
				i_CLOCK	:	in std_logic							;
				i_START	:	in std_logic							;		----Signal from TOP to begin transmission
				o_BUSY	:	out std_logic							;		----Signal to TOP to wait until transmission has finished
				i_DATA	:	in std_logic_vector(7 downto 0)			;		----Data vector from TOP
				o_TX_LINE:	out std_logic	:='1'							----Uart output to TOP
	

			);
end uart_tx;


architecture behavior of uart_tx is

	signal r_PRESCALER					:	integer range 0 to 5206 := 0					;----5206 = ( 50MHz[clock] / 9600[bitrate] )
	signal r_INDEX						:	integer range 0 to 9 := 0						;----Used to select bits from vector		
	signal r_DATA_BUFFER				:	std_logic_vector(9 downto 0) := (others => '1')	;----Data register, needs to be padded with [0] on the beggining and [1] at the end
	signal s_TRANSMITING_FLAG			:	std_logic := '0'								;----Signal holding the current state [ 1 if transmitting, 0 if not transmitting ]
	
	
	begin
	
	process(i_CLOCK) begin
	
		if( rising_edge(i_CLOCK) ) then
		
			------------------------------------------------------------
				
			--		If there is no transmission beinf performed and the start signal was activated
			--		prepare the buffer for transmission.
			--		The buffer recieves a '0' at the beggining in case the first real bit of data is high,
			--		that would cause an error  upon reading. The end recieves a 1 to signal the reciever that the byte has ended.
			--		The transmission flag is also turned high, making any changes to the inpt data not affect the buffer.
			--		Along with the busy flag being turned high, making it impossible to request a new transmission until it is done.
			
		
			if( s_TRANSMITING_FLAG = '0' and i_START = '1' ) then 
			
				
				r_DATA_BUFFER(0)				<=	'0'	;
				r_DATA_BUFFER(9)				<=	'1'	;
				r_DATA_BUFFER(8 downto 1)		<= i_DATA;
				s_TRANSMITING_FLAG				<=	'1'	;
				o_BUSY							<=	'1'	;
				
			end if;	---s_TRANSMITING_FLAG = '0' and i_START = '1'
			
			------------------------------------------------------------
			
			------------------------------------------------------------
			
			--		If transmission flag has been set, begin transmission and do not allow any
			--	changes of inputs change states or values during process.
			
			if( s_TRANSMITING_FLAG = '1' ) then
			
				--///////////////////////////////////////////////////////
				
				--		Clock divider depends on this register to count up.
				
			
				if( r_PRESCALER < 5205 ) then
				
					r_PRESCALER <= r_PRESCALER + 1;
					
				else		---r_PRESCALER > 5207
				
					r_PRESCALER <= 0					;
			
				end if;	---r_PRESCALER < 5207
				--///////////////////////////////////////////////////////
				
				--///////////////////////////////////////////////////////
				
				--		When the clock divider register hits the middle, change value of output TX to match the data at index,
				--	it is done in the half of the clock divider cicle to avoid sending signals to early or too late.
				--		It will cicle through the indexes and when it reaches the end, the flags and the index will reset to default,
				--	allowing for another transission request.
				
			
				if( r_PRESCALER = 2607 ) then
				
					o_TX_LINE	<=	r_DATA_BUFFER(r_INDEX);
					
					if( r_INDEX < 9 ) then
					
						r_INDEX	<=	r_INDEX + 1;
						
					else		---r_INDEX > 9
					
						s_TRANSMITING_FLAG		<=	'0'	;
						o_BUSY					<=	'0'	;
						r_INDEX					<=	0	;
						
					
					end if;	---r_INDEX < 9
				
				end if;	---r_PRESCALER = 2607
				--///////////////////////////////////////////////////////
			
			end if;	---s_TRANSMITING_FLAG = '1'
			------------------------------------------------------------
			
		
		end if;	---rising_edge(i_CLOCK)
	
	end process;

end behavior;