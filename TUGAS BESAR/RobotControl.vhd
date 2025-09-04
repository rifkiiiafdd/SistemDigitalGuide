-- Spesifikasi
-- Top Entity

--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity RobotControl is
	port (
		i_CLOCK     	: in std_logic;
		button_1   		: in std_logic;  -- Sinyal "tampilkan data", berasal dari komponen lain
		button_2      	: in std_logic;
		button_3     	: in std_logic;
		button_4      	: in std_logic;
		i_rst     		: in std_logic;

		i_RX       		: in std_logic;  -- Garis masukan
		o_TX        	: out std_logic := '1';  -- Garis keluaran
		
		lampu 			: out std_logic_vector(3 downto 0) := "1111";
		led             : out std_logic_vector(3 downto 0);

		o_sig_CRRP_DATA : out std_logic;  -- Sinyal data rusak
		o_sig_RX_BUSY   : out std_logic;  -- tanda jika RX sibuk atau dalam mode menerima.
		o_sig_TX_BUSY   : out std_logic;  -- tanda jika TX sibuk atau dalam mode mengirim.

		
		hex1            : out std_logic_vector(6 downto 0)  -- Sinyal HEX (7 Segmen).
	);
end RobotControl;

architecture behavioral of RobotControl is
	-- SINYAL
	signal r_TX_DATA    : std_logic_vector(209 downto 0) := (others => '1');  -- Register yang menyimpan pesan untuk dikirim
	signal s_TX_START   : std_logic := '0';  -- Sinyal yang disimpan untuk memulai transmisi
	signal s_TX_BUSY    : std_logic;  -- Sinyal yang disimpan yang mengingatkan komponen utama bahwa sub komponennya "TX" sedang sibuk
	signal s_rx_data    : std_logic_vector(7 downto 0);  -- Data RX yang dibaca dari Buffer RX
	signal s_hex        : std_logic_vector(6 downto 0);  -- Sinyal HEX (7 Segmen) dari Konverter ASCII-HEX.
	signal s_ascii      : std_logic_vector(7 downto 0);  -- Data RX yang dibaca dari Buffer RX dan menjadi input Konverter ASCII-HEX.
	signal tx_done      : std_logic := '0';
	signal s_button_counter : integer range 0 to 50000000 := 0;  -- penghitung untuk menunda penekanan tombol.
	signal s_allow_press : std_logic := '0';  -- sinyal untuk mengizinkan tombol ditekan.
	signal state        : std_logic_vector(3 downto 0) := "0001"; -- state machine for Create Message

	signal hex_1        : std_logic_vector(6 downto 0); 
	signal hex_2       : std_logic_vector(6 downto 0); 
	signal hex_3        : std_logic_vector(6 downto 0); 
	signal hex_4        : std_logic_vector(6 downto 0); 

	signal X1           : std_logic_vector(9 downto 0) := (others => '0'); -- Target Coordinate
	signal Y1           : std_logic_vector(9 downto 0) := (others => '0');

	signal X0           : std_logic_vector(9 downto 0) := (others => '0'); -- Current Coordinate
	signal Y0           : std_logic_vector(9 downto 0) := (others => '0');

	signal kuadran    	: unsigned(1 downto 0) := (others => '0'); -- Kuadran
	signal kuadran_cordic : unsigned(1 downto 0) := (others => '0'); -- Kuadran

	signal dX      		: signed(10 downto 0) := (others => '0'); -- Perubahan Koordinat
	signal dY      		: signed(10 downto 0) := (others => '0');

	signal current_T    : signed(34 downto 0):= (others => '0'); --26 fix, 1 tanda, 8 depan koma

	signal next_T 		: unsigned(32 downto 0) := (others => '0'); -- Target Angle
	signal next_T2 		: signed(34 downto 0) := (others => '0'); -- Target Angle
	signal next_T2_cordic : signed(34 downto 0) := (others => '0'); -- Target Angle
	signal next_T2_y0 	: signed(34 downto 0) := (others => '0'); -- Target Angle

	signal right_next_T :  signed(34 downto 0) := (others => '0'); -- Target Angle setelah di sederhanakan
	signal t_y0  		: signed(34 downto 0) := (others => '0'); -- Target Angle

	signal cordic_done  : std_logic := '0';
	signal dT           : signed(34 downto 0); -- Perubahan Sudut, 
	signal right_dT           : unsigned(34 downto 0); -- Perubahan Sudut, tanpa tanda
	signal temp_dT		: unsigned(34 downto 0); -- Perubahan Sudut, tanpa tanda

	signal current_T_cordic : signed(34 downto 0) := (others => '0'); -- Sudut saat ini saat cordic dijalankan

	signal R            : unsigned(36 downto 0); -- Radius
	signal R_from_cordic            : unsigned(36 downto 0); -- Radius
	signal R_y0            : unsigned(36 downto 0); -- Radius
	signal msg          : std_logic_vector(209 downto 0); -- Pesan yang akan dikirim
	signal create_done  : std_logic := '0'; -- Flag untuk menandakan pesan sudah dibuat
	signal i_start_msg  : std_logic := '0'; -- Flag untuk memulai pembuatan pesan baru 
	signal rst_msg 	: std_logic := '0';
	signal hex_bcd1 : std_logic_vector (7 downto 0) := (others => '0'); -- 7 segment
	signal hex_bcd2 : std_logic_vector (7 downto 0) := (others => '0'); -- 7 segment
	signal hex_bcd3 : std_logic_vector (7 downto 0) := (others => '0'); -- 7 segment
	signal hex_bcd4 : std_logic_vector (7 downto 0) := (others => '0'); -- 7 segment

	signal convert_bcd_r_done : std_logic := '0'; -- Flag untuk menandakan konversi BCD selesai
	signal convert_bcd_r2_done : std_logic := '0';
	signal convert_bcd_dt1_done : std_logic := '0';
	signal convert_bcd_dt2_done : std_logic := '0';

	signal dT1_bcd : unsigned(15 downto 0) := (others => '0'); -- BCD for dT and R
	signal dT2_bcd : unsigned(15 downto 0) := (others => '0');
	signal R_bcd : unsigned(15 downto 0) := (others => '0');
	signal R2_bcd : unsigned(15 downto 0) := (others => '0');

	signal dT_int_data : unsigned(10 downto 0);
	signal dt_fix_data : unsigned(10 downto 0);
	signal R_int_data : unsigned(10 downto 0);
	signal r_fix_data : unsigned(10 downto 0);
	signal input_fix_dt : unsigned(25 downto 0);

	signal input_fix_r : unsigned(25 downto 0);

	signal yIsZero      : std_logic;


	signal start_fix : std_logic := '0';
	signal fix_done : std_logic := '0';

	signal dt_fix : unsigned(9 downto 0) := (others => '0'); -- fix point yang sudah dikali 1000
	signal r_fix : unsigned(9 downto 0) := (others => '0');
	
	SIGNAL START_BCD : STD_LOGIC := '0'; -- Sinyal untuk memulai konversi BCD

	SIGNAL CORDIC_ON : STD_LOGIC := '0'; -- Sinyal untuk memulai perhitungan cordic

	TYPE state_type IS (IDLE, VERIFY, OPERATE, C_OUTPUT, DISPLAY);
	SIGNAL STATE_CORDIC : state_type := IDLE;

	SIGNAL reset_cordic : std_logic := '0';

	-- KOMPONENT

	-- cordic
	component cordic is
		PORT(
		clk             : IN  std_logic;
		reset           : IN  std_logic;
		cordic_on       : IN  std_logic;
		x_in            : IN  SIGNED(10 DOWNTO 0);
		y_in            : IN  SIGNED(10 DOWNTO 0);
		z               : OUT std_logic;
		r_cordic        : OUT UNSIGNED(36 DOWNTO 0) ; -- 15 bit di belakang koma
		p_cordic        : OUT UNSIGNED(32 DOWNTO 0) := (OTHERS => '0') -- 7 bit di depan koma, 26 bit di belakang koma, 1 tanda

	);
	end component;

	component kuadran_detector is -- Komponen detektor kuadran
	port (
        x1,y1,x0,y0 : in unsigned(9 downto 0);
        kuadran : out unsigned(1 downto 0);
        newdX : out signed(10 downto 0);
        newdY : out signed(10 downto 0)
    );
	end component;

	component kuadrandetect_decoder is -- Komponen dekoder kuadran
	PORT (
        indegree : IN signed (32 downto 0); -- 26 bit fix, 7 bit fc
        kuadran  : IN unsigned (1 downto 0); -- Kuadran 00: Kuadran 1, 01: Kuadran 2, 10: Kuadran 3, 11: Kuadran 4
        outdegree: OUT signed (34 downto 0) -- 26 bit fix, 8 bit fc, 1 bit tanda
    );
	end component;

	component shortestway  is
		port (
        current_T : in signed(34 downto 0); -- 8 depan koma, 26 belakang koma, 1 tanda
        next_T : in signed(34 downto 0)   ; -- 8 depan koma, 26 belakang koma, 1 tanda
        shortest : out signed(34 downto 0) -- 8 depan koma, 26 belakang koma, 1 tanda
    );
	end component;

	component kuadrandetect_encoder IS
    PORT (
        current_T   : IN signed (34 downto 0);
        dt          : IN   signed (34 downto 0);
        newdegree   : OUT signed (34 downto 0)
        );
	end component;


--spesifikasi : menjumlahkan current t dan dt untuk memperoleh new current dt (-180<current dt< 180)

	component verificator is
		Port (
        x           : in  unsigned(9 downto 0);  -- Input x
        y           : in  unsigned(9 downto 0);  -- Input y
        dx          : in signed(10 downto 0);
        dy          : in signed(10 downto 0);
		kuadran    : in  unsigned(1 downto 0);  -- Kuadran
        r_cordic    : out unsigned(36 downto 0);     -- Resultant magnitude
		yIsZero      : out std_logic;
        next_T   : out signed(34 downto 0)     -- Phase (angle)
    );
	end component;


	component uart_tx is -- Komponen pengirim
		port (
			i_CLOCK : in std_logic;
			i_START : in std_logic;
			o_BUSY  : out std_logic;
			tx_done : out std_logic;
			i_DATA  : in std_logic_vector(209 downto 0);
			o_TX_LINE : out std_logic := '1'
		);
	end component;

	component uart_rx is -- Komponen penerima
		port (
			i_CLOCK         : in std_logic;
			i_rst           : in std_logic;
			i_RX            : in std_logic;
			o_sig_CRRP_DATA : out std_logic := '0';  -- Currupted data flag
			x_biner         : out std_logic_vector(9 downto 0) := (others => '0');
			y_biner         : out std_logic_vector(9 downto 0) := (others => '0');
			o_BUSY          : out std_logic
		);
	end component;

	component asciiHex is -- Komponen konverter ASCII ke HEX
		port (
			i_ascii : in std_logic_vector(7 downto 0);
			hex1    : out std_logic_vector(6 downto 0)
		);
	end component;

	component create_msg is -- Komponen pembuat pesan
		port (
			clk         : in std_logic;
			i_start     : in std_logic;
			create_done : out std_logic := '0';
			reset       : in std_logic;
			dT_min      : in std_logic;
			R2_bcd      : in  unsigned(11 downto 0) := (others => '0');
			dT1_bcd : in  unsigned(11 downto 0) := (others => '0');
	    	dT2_bcd : in  unsigned(11 downto 0) := (others => '0');
	    	R_bcd : in unsigned(15 downto 0) := (others => '0');
			msg         : out std_logic_vector(209 downto 0)
		);
	end component;

	component binary_to_bcd is -- Komponen konverter biner ke BCD
        port(
            i_DATA : IN UNSIGNED(10 DOWNTO 0);
            i_CLK : IN STD_LOGIC;
            i_START		:	IN STD_LOGIC;
            convert_done : OUT STD_LOGIC := '0';
            o_bcd : OUT UNSIGNED(15 DOWNTO 0)
        );
    end component;

	component fixConverter is -- Komponen konverter fix point
		port(
			
		i_fix : in unsigned(25 downto 0);
		A_out : out unsigned(9 downto 0)
	);
	end component;

	component seven_segment is
		PORT(
        i_CLK : IN STD_LOGIC;
        SEG1 : IN STD_LOGIC_VECTOR(6 DOWNTO 0);
        SEG2 : IN STD_LOGIC_VECTOR(6 DOWNTO 0);
        SEG3 : IN STD_LOGIC_VECTOR(6 DOWNTO 0);
        SEG4 : IN STD_LOGIC_VECTOR(6 DOWNTO 0);
        LED : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        SEG_out : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)

    );
	end component;

begin
	lampu(3) <= cordic_done;
	lampu(2 downto 0) <= state(2 downto 0);
	-- dT <= "110110011001000011100101";
	-- R  <= "10011010101001011101101100";

	hex_bcd1 <= "0011" & std_logic_vector(dT1_bcd(15 downto 12)); 
	hex_bcd2 <= "0011" & std_logic_vector(dT1_bcd(11 downto 8)); 
	hex_bcd3 <= "0011" & std_logic_vector(dT1_bcd(7 downto 4)); 
	hex_bcd4 <= "0011" & std_logic_vector(dT1_bcd(3 downto 0)); 
	-- hex_bcd <= "0011" & std_lodT1_bcd(3 downto 0);

	-- dX <= to_signed(to_integer(unsigned(X1)), 11) - to_signed(to_integer(unsigned(X0)), 11);
	-- dY <= to_signed(to_integer(unsigned(Y1)), 11) - to_signed(to_integer(unsigned(Y1)), 11);

	-- converter signed 
	temp_dT <= not(unsigned(dT)) + 1;

	reset_cordic <= not(i_rst);

	right_dT(33 downto 0) <= temp_dT(33 downto 0) when dT(34) = '1' else (unsigned(dT(33 downto 0)));
	right_dT(34) <= dT(34);
 

	u_cordic : cordic port map(
		clk             => i_CLOCK,
		reset           => reset_cordic,
		cordic_on       => cordic_on,
		x_in            => dX,
		y_in            => dY,
		z               => CORDIC_DONE,
		r_cordic        => R_from_cordic, -- 15 bit di belakang	 koma
		p_cordic        => next_T -- 7 bit di depan koma, 10 bit di belakang koma
	);

	u_kuadran : kuadran_detector port map(
		x1 => unsigned(X1),
		y1 => unsigned(Y1),
		x0 => unsigned(X0),
		y0 => unsigned(Y0),
		kuadran => kuadran,
		newdX => dX,
		newdY => dY
	);

	u_kuadran_decoder : kuadrandetect_decoder port map(
		indegree => signed(next_T),
		kuadran => kuadran_cordic,
		outdegree => next_T2_cordic
	);
	u_verivicator : verificator port map(
		x           => unsigned(X1),
		y           => unsigned(Y1),
		dx          => dX,
		dy          => dY,
		kuadran    => kuadran,
		yIsZero 	=> yIsZero,
		r_cordic    => (R_y0),
		next_T   => t_y0
	);

	u_find_shortest_way : shortestWay port map (
		current_T => Current_T,
		next_T => next_T2,
		shortest => dT
	);

	u_encoder : kuadrandetect_encoder port map (
		current_T => current_T_cordic,
		dt => dT,
		newDegree => right_next_T
	);




	-- Modul Penerima
	u_RX : uart_rx port map (
		i_CLOCK        => i_CLOCK,
		i_rst          => i_rst,
		i_RX           => i_RX,
		o_sig_CRRP_DATA => o_sig_CRRP_DATA,
		o_BUSY         => o_sig_RX_BUSY,
		x_biner        => X1,
		y_biner        => Y1
	);
	
	-- Modul Pengirim
	u_TX : uart_tx port map (
		i_CLOCK  => i_CLOCK,
		i_START  => s_TX_START,
		o_BUSY   => s_TX_BUSY,
		i_DATA   => r_TX_DATA,
		tx_done  => tx_done,
		o_TX_LINE => o_TX
	);

	-- Modul Pembuat Pesan
	u_convert_msg : create_msg port map (
		clk         => i_CLOCK,
		i_start     => i_start_msg,
		reset       => rst_msg,
		dT1_bcd     => dt1_bcd(11 downto 0),
		dT2_bcd     => dT2_bcd(11 downto 0),	
		R_bcd       => R_bcd,
		R2_bcd      => r2_bcd(11 downto 0),
		dt_min      => dt(23),
		create_done => create_done,
		msg         => msg
	);

	-- Modul pembatas waktu penekanan button
	p_button : process(i_CLOCK)
	begin
		if rising_edge(i_CLOCK) then
			if s_button_counter = 49999900 then
				s_button_counter <= 0;
				s_allow_press <= '1';
			else
				s_button_counter <= s_button_counter + 1;
				s_allow_press <= '0';
			end if;
		end if;
	end process;

	-- Modul Konverter Biner ke BCD
		
		dT_int_data <= "000" & right_dT(33 downto 26);
		dt_fix_data <= '0' & dt_fix;
		R_int_data <= R(36 downto 26);
		r_fix_data <= '0' & r_fix;
		input_fix_dt <= right_dT(25 downto 0);
		input_fix_r <= R(25 downto 0);
	
		u_msg_t1 : binary_to_bcd port map(
			i_DATA => dT_int_data,
			i_CLK => i_clock,
			i_start => START_BCD,
			convert_done => convert_bcd_dt1_done,
			o_bcd => dT1_bcd);
	
		u_msg_t2 : binary_to_bcd port map(
			i_DATA => dt_fix_data,
			i_CLK => i_clock,
			i_start => START_BCD,
			convert_done => convert_bcd_dt2_done,
			o_bcd => dT2_bcd);
	
		u_msg_r1 : binary_to_bcd port map(
			i_DATA => R_int_data,
			i_CLK => i_clock,
			i_start => START_BCD,
			convert_done => convert_bcd_r_done,
			o_bcd => R_bcd);
		
		u_msg_r2 : binary_to_bcd port map(
				i_DATA => r_fix_data,
				i_CLK => i_clock,
				i_start => START_BCD,
				convert_done => convert_bcd_r2_done,
				o_bcd => R2_bcd);

	-- Modul Konverter Fix Point
	u_fix_dt_converter :  fixConverter port map(
		i_fix => input_fix_dt,
		A_out => dt_fix
	);

	u_fix_r_converter :  fixConverter port map(
		i_fix =>  input_fix_r,
		A_out => r_fix
	);
	

	-- Modul Konverter ASCII ke HEX (7 Segmen)
	a2h1 : asciiHex port map (
		i_ascii => hex_bcd1,
		hex1    => hex_1
	);
	a2h2 : asciiHex port map (
		i_ascii => hex_bcd2,
		hex1    => hex_2
	);
	a2h3 : asciiHex port map (
		i_ascii => hex_bcd3,
		hex1    => hex_3
	);
	a2h4 : asciiHex port map (
		i_ascii => hex_bcd4,
		hex1    => hex_4
	);

	hex_7 : seven_segment port map(
		i_CLK => i_CLOCK,
		SEG1 => hex_1,
		SEG2 => hex_2,
		SEG3 => hex_3,
		SEG4 => hex_4,
		LED => led,
		SEG_out => hex1
	);

	s_ascii <= s_rx_data;  -- data rx yang dibaca dari buffer menjadi input konverter ascii-hex
	
			
	p_TRANSMIT	:	process(i_CLOCK) begin
	
		if(rising_edge(i_CLOCK)) then
			------------------------------------------------------------
		
			--- Jika memungkinkan, kirim byte data di input.
			if( 
				button_2 = '0' and 		----	Tombol Kirim ditekan
				s_TX_BUSY = '0' and 	----	pengirim tidak sibuk / tidak mengirim
				s_allow_press = '1'		----  	tombol diizinkan untuk ditekan
				) then 					----	Kirim pesan jika subkomponen "TX" tidak sibuk
			
				-- r_TX_DATA	<=	"1001101010100101100010011001101001101100100110011010011000001001110100101010010010011010101001100100100110100010010110001001110010100110010010011000101001011010100111010010101010001011001000";									----Berikan pesan subkomponen
				r_TX_DATA	<=	msg;									----Berikan pesan subkomponen
				s_TX_START	<=	'1';									----Beri tahu untuk mengirim

			else
			
				s_TX_START <= '0';									----Jika Subkomponen "TX" sibuk, atau tombol tidak ditekan, jangan kirim
				
			end if;	---KEY(0) = '0' dan s_TX_BUSY = '0'
		end if;
	end process;



	process (state, button_2, i_clock, create_done, tx_done)
	begin
		if rising_edge(i_clock) then

			if button_4 = '0' then
				state <= "0001";
			end if;

			case state is
				when "0001" =>  -- idle
					i_start_msg <= '0';
					if (button_1 = '0') then
						state <= "0010";
						rst_msg <= '1';
						
					end if;

				when "0010" =>
					start_bcd <= '1';
					state <= "0011";
					rst_msg <= '0';
				
				when "0011" =>
					rst_msg <= '0';
					start_bcd <= '0';
				    if convert_bcd_dt1_done = '1' then 
						i_start_msg <= '1';
					
				        state <= "0101";

				    else
				        state <= "0011";
				    end if;

				when "0101" =>
					i_start_msg <= '0';
					if create_done = '1' then
						state <= "0001";
					else
						state <= "0101";
					end if;

				when others =>
			end case;
		end if;
	end process;


	process(i_clock, i_rst, button_3, state_cordic, yIsZero, r_from_cordic, t_y0, r_y0)
		begin
			if rising_edge(i_clock) then

				IF BUTTON_4 = '0' THEN
					STATE_CORDIC <= IDLE;
					X0 <= (others => '0');
					Y0 <= (others => '0');
					CURRENT_T <= (others => '0');
				END IF;

				IF I_RST = '0' THEN 
					STATE_CORDIC <= IDLE;
				END if;

				case state_cordic is
					WHEN IDLE => 
					if button_3 = '0' then
						current_T_cordic <= current_T;
						kuadran_cordic <= kuadran;
						STATE_CORDIC <= VERIFY;
						
					end if;
					when VERIFY =>
						if yIsZero = '0' then
							STATE_CORDIC <= OPERATE;
							CORDIC_ON <= '1';
						else
							STATE_CORDIC <= C_OUTPUT;
						end if;
					
					WHEN OPERATE =>
						CORDIC_ON <= '0';

						IF CORDIC_DONE = '1' THEN
							STATE_CORDIC <= C_OUTPUT;
						END IF;	
					
					WHEN C_OUTPUT =>
						IF YIsZero = '0' then
							next_T2 <= next_T2_cordic;
							r <= r_from_cordic;
						ELSE 
							next_T2  <= next_T2_y0;
							r <= r_y0;
						end if;
						STATE_CORDIC <= DISPLAY;
					
					WHEN DISPLAY => 
						CURRENT_T <= RIGHT_NEXT_T;
						X0 <= X1;
						Y0 <= Y1;
						

					WHEN OTHERS => 
						STATE_CORDIC <= IDLE;
				end case;
				end if;
		end process;

						
end behavioral;

	-- force -freeze sim:/robotcontrol/i_CLOCK 1 0, 0 {25 ps} -r 50
	-- force -freeze sim:/robotcontrol/button_4 1 0
	-- force -freeze sim:/robotcontrol/button_3 0 0
	-- force -freeze sim:/robotcontrol/i_rst 1 0
	-- force -freeze sim:/robotcontrol/X1 0111110100 0
	-- force -freeze sim:/robotcontrol/Y1 0111110100 0
	-- run 100
	-- force -freeze sim:/robotcontrol/button_3 1 0
	-- run 2000

	-- force -freeze sim:/robotcontrol/i_rst 0 0
	-- run 100
	-- force -freeze sim:/robotcontrol/i_rst 1 0
	-- force -freeze sim:/robotcontrol/X1 1110000100 0
	-- force -freeze sim:/robotcontrol/Y1 1100100000 0
	-- force -freeze sim:/robotcontrol/button_3 0 0
	-- run 100
	-- force -freeze sim:/robotcontrol/button_3 1 0
	-- run 2000

	-- force -freeze sim:/robotcontrol/i_rst 0 0
	-- run 100
	-- force -freeze sim:/robotcontrol/i_rst 1 0
	-- force -freeze sim:/robotcontrol/X1 0001100100 0
	-- force -freeze sim:/robotcontrol/Y1 0011001000 0
	-- force -freeze sim:/robotcontrol/button_3 0 0
	-- run 100
	-- force -freeze sim:/robotcontrol/button_3 1 0
	-- run 2000


	-- force -freeze sim:/robotcontrol/R 1010101100111001100100001100000111000 0
	-- force -freeze sim:/robotcontrol/right_dT 00101011110011001000011000001110000 0
	-- force -freeze sim:/robotcontrol/i_CLOCK 1 0, 0 {25 ps} -r 50
	-- force -freeze sim:/robotcontrol/i_rst 1 0
	-- force -freeze sim:/robotcontrol/button_1 0 0
	-- run 100
	-- force -freeze sim:/robotcontrol/button_1 1 0
	-- run 2000

	-- force -freeze sim:/robotcontrol/R 1000001100111001100100000000000111000 0
	-- force -freeze sim:/robotcontrol/right_dT 00111111110011001000011001011110000 0
	-- force -freeze sim:/robotcontrol/i_rst 1 0
	-- force -freeze sim:/robotcontrol/button_1 0 0
	-- run 100
	-- force -freeze sim:/robotcontrol/button_1 1 0
	-- run 2000