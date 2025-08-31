library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_rx is
	port	(
				i_CLOCK			:	in std_logic;
				i_RX			:	in std_logic;
				o_DATA			:	out std_logic_vector(7 downto 0)	;
				i_log_ADDR		:	in std_logic_vector( 7 downto 0 )	;
				o_sig_CRRP_DATA	:	out std_logic := '0'			;	---Currupted data flag
				o_BUSY			:	out std_logic
			);
end uart_rx;


architecture behavior of uart_rx is

	signal r_PRESCALER			:	integer range 0 to 5206 := 0	;----5206 = ( 50MHz[clock] / 9600[bitrate] )
	signal r_INDEX				:	integer range 0 to 9 := 0		;----Used to select bits from vector		
	signal r_DATA_BUFFER		:	std_logic_vector(9 downto 0)	;----Data register, needs to be padded with [0] on the beggining and [1] at the end
	signal s_RECIEVING_FLAG		:	std_logic := '0'				;----Signal holding the current state [ 1 if recieving, 0 if not recieving ]
		
	type t_MEM_UART is array ( 0 to 255 ) of std_logic_vector( 7 downto 0 );
	signal MEM_UART	:	t_MEM_UART;
		
	signal r_COUNTER	:	std_logic_vector( 7 downto 0 ) := ( others => '0' );
		
	begin
	
	process( i_CLOCK , i_log_ADDR , MEM_UART ) begin
	
		if( rising_edge(i_CLOCK) ) then
		
			------------------------------------------------------------
			
			---	A transmission beggins as a falling edge of the line, this condition checks if there
			---is already a reception, and if there is none, beggin recieving.
			---	Recieving restarts the INDEX to the beggining of the vector to be given to the top component,
			---and this subcomponent's busy flag is set high. Along with this subcoponents internal recieving flag to beggin
			---its subroutine.
			---	Remember that UART is duplex, so a transmission and reception can be done at the same time, so this subcomponent
			---must not cause interference on te TX line.
		
			if( s_RECIEVING_FLAG = '0' and i_RX = '0' ) then
			
				r_INDEX <= 0;
				r_PRESCALER	<= 0;
				o_BUSY<=	'1';
				
				s_RECIEVING_FLAG	<=	'1';
			
			end if;	--s_RECIEVING_FLAG = '0' and RX_LINE = '0'
			
			------------------------------------------------------------
			
			------------------------------------------------------------
			
			---	This is the reception subroutine, the data buffer must be filled and sento to the top.
			
			if( s_RECIEVING_FLAG = '1' ) then
			
				r_DATA_BUFFER(r_INDEX)	<= i_RX;
				
				------------------------------------------------------------
				
				---This is the clock divider, sets the baud rate for this subcomponent.
				
				if( r_PRESCALER < 5207 ) then
				
					r_PRESCALER	<=	r_PRESCALER + 1;
				
				else		----r_PRESCALER > 5207
				
					r_PRESCALER <= 0;
				
				end if; --r_PRESCALER < 5207
				
				------------------------------------------------------------
				
				------------------------------------------------------------
				
				---	When the clock reaches the middle of the expected bit, read from it and store it i a buffer,
				---once the buffer is filled, send it to the top component.
				
				if( r_PRESCALER = 2500 ) then
				
					if( r_INDEX < 9 ) then
					
						r_INDEX <= r_INDEX + 1;
						
					else		--r_INDEX > 9
					
						------------------------------------------------------------
						
						---	It must be checked if the data sent is indeed correct, or there was some interference,
						---this condition checks if the first and last bits are as expected, if not, send nothing.
					
						if( r_DATA_BUFFER(0) = '0' and r_DATA_BUFFER(9) = '1' ) then
						
							if( not(r_COUNTER = "11111111") ) then
								r_COUNTER	<= std_logic_vector( unsigned( r_COUNTER ) + 1 );
							else
								r_COUNTER	<= (others => '0');
							end if;
							
							MEM_UART( to_integer( unsigned ( r_COUNTER ) ) )	<=	r_DATA_BUFFER(8 downto 1);
--							
						else 
							o_sig_CRRP_DATA	<=	'1';
						end if;	--r_DATA_BUFFER(0) = '0' and r_DATA_BUFFER(9) = '1'
						
						------------------------------------------------------------
						
						s_RECIEVING_FLAG	<=	'0';
						o_BUSY		<= '0';
						
					end if;	--r_INDEX < 9
				
				end if;	--r_PRESCALER = 2500
				
				------------------------------------------------------------
			
			end if;	--s_RECIEVING_FLAG = '1'
			
			------------------------------------------------------------
		
		end if; -- rising_edge(i_CLOCK)
		
		o_DATA	<=	MEM_UART( to_integer( unsigned ( i_log_ADDR ) ) );
	end process;

end behavior;