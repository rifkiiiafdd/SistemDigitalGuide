--Nama      : Rifki Afriadi
--NIM       : 13223049
--Rombongan : C
--Kelompok  : 7
--Percobaan : 3A
--Tanggal   : 11/11/2024


--Deskripsi
--Fungsi : Mencari hasil bagi dan modulus bilangan 4 bit 
--Input  : A,B (bilangan 4 bit)
--Output : MOD_1,MOD_2,DIV_1,DIV_2 (7 bit, output untuk ditampilkan di 7 segment)

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

-- DEFINE ENTITY
ENTITY modanddiv IS
    PORT(
        A_input,B_input : IN STD_LOGIC_VECTOR(3 DOWNTO 0); -- input
        CLK, STR, RST : IN STD_LOGIC; --CLOCK, START DAN RESET
        A_out,B_out : OUT STD_LOGIC_VECTOR(3 DOWNTO 0); --OUTPUT KETIKA SWITCH DIGUNAKAN
        MOD_1,MOD_2,DIV_1,DIV_2,B1,B2 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0); --HASIL OPERASI DITAMPILKAN DENGAN 7 SEGMENT
		  led_run : out std_logic
    );
END ENTITY;


ARCHITECTURE behavioral OF modanddiv IS 
    SIGNAL next_counter, A, next_A, B, S, B_i, C  : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL counter : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0000";
    
    SIGNAL run : STD_LOGIC := '0'; -- variabel yang menenetukan operasi sedang dijalankan atau tidak
    SIGNAL F : STD_LOGIC; -- HASIL KOMPARASI A DAN B

    SIGNAL mod_bcd,div_bcd,b_bcd : STD_LOGIC_VECTOR(7 DOWNTO 0); -- dua digit bilangan dengan biner

    -- counter 1-50M
    constant max : integer := 50000000;
    constant half : integer := max/2;
    signal counter_clock : integer range 0 to max;

    signal clock1hz : std_logic;
	 
	 SIGNAL R0 : STD_LOGIC_VECTOR(6 DOWNTO 0):= "0111001";
	 SIGNAL O0 : STD_LOGIC_VECTOR(6 DOWNTO 0):= "0000001";
	 SIGNAL E0 : STD_LOGIC_VECTOR(6 DOWNTO 0):= "1100000";

    --FULLSUBTRACTOR
    COMPONENT fs IS 
    PORT(A,B,B_in :in std_logic; 
		S, B_out : out std_logic
    );
    END COMPONENT;

    -- FULLADDER
    COMPONENT fulladder IS
		PORT(A,B,C_in :in std_logic;
			S, C_out : out std_logic
    );
	END COMPONENT;
    
    -- COMPARATOR 
    COMPONENT comparator IS 
    PORT(
        A,B : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        F : OUT STD_LOGIC
    );
    END COMPONENT;

    -- DECODER BINER KE BCD
    COMPONENT binaryToBcd IS
		PORT( M : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
				X,Y : OUT STD_LOGIC_VECTOR(3 DOWNTO 0));
	END COMPONENT;
	
    -- DECODER BCD KE SEVEN SEGMENT
	COMPONENT bcdToSeven IS
		PORT( Z : IN STD_LOGIC_VECTOR(3 DOWNTO 0 );
			A,B,C,D,E,F,G : OUT STD_LOGIC);
	END COMPONENT;

BEGIN 

-- FULLADDER UNTUK MENGHITUNG CCOUNTER

FA0 : fulladder PORT MAP(A => counter(0),B => '1',C_in => '0',S => next_counter(0),C_out => C(0));

gen_FA : FOR i IN 1 TO 3 GENERATE
    FA : fulladder PORT MAP(
        A => counter(i),
        B => '0',
        C_in => C(i-1),
        S => next_counter(i),
        C_out => C(i)
    );
END GENERATE gen_FA;

------------------------------------------------------------------------
-- COMPARATOR
comp_AB : comparator PORT MAP(
    A => A,
    B => B,
    F => F
);

-- FULLSUBTRACTOR 4 BIT
FS0 : fs PORT MAP(A => A(0),B => B(0), B_in => '0', S => S(0), B_out => B_i(0));

gen_FS : FOR i IN 1 TO 3 GENERATE
    FS_AB : fs PORT MAP(
        A => A(i),
        B => B(i),
        B_in => B_i(i-1),
        S => S(i),
        B_out => B_i(i)
    );
END GENERATE gen_FS;
-------------------------------------------------------------------------------------------------------------------------------------------
-- MENAMPILKAN OUTPUT
--Menampilkan input A dan B dengan LED
gen_led : FOR i IN 0 TO 3 GENERATE
A_out(i) <= A_input(i);
B_out(i) <= B_input(i);
END generate gen_led;

-- Mengubah modulo dan counter ke BCD
bcd_0 : binaryToBcd PORT MAP(
    M(4) => '0', M(3) => A(3), M(2) => A(2), M(1) => A(1), M(0) => A(0),
    X(3) => mod_bcd(7),X(2) => mod_bcd(6),X(1) => mod_bcd(5),X(0) => mod_bcd(4),
    Y(3) => mod_bcd(3),Y(2) => mod_bcd(2),Y(1) => mod_bcd(1),Y(0) => mod_bcd(0)
);

bcd_1 : binaryToBcd PORT MAP(
    M(4) => '0', M(3) => counter(3), M(2) => counter(2), M(1) => counter(1), M(0) => counter(0),
    X(3) =>div_bcd(7),X(2) =>div_bcd(6),X(1) =>div_bcd(5),X(0) =>div_bcd(4),
    Y(3) =>div_bcd(3),Y(2) =>div_bcd(2),Y(1) =>div_bcd(1),Y(0) =>div_bcd(0)
);

bcd_b : binaryToBcd PORT MAP(
    M(4) => '0', M(3) => counter(3), M(2) => counter(2), M(1) => counter(1), M(0) => counter(0),
    X(3) =>b_bcd(7),X(2) =>b_bcd(6),X(1) =>b_bcd(5),X(0) =>b_bcd(4),
    Y(3) =>b_bcd(3),Y(2) =>b_bcd(2),Y(1) =>b_bcd(1),Y(0) =>b_bcd(0)
);

-- Mengubah BCD ke 7 Segment
Seven_MOD_1 : bcdToSeven PORT MAP(
    Z(3) => mod_bcd(7), Z(2) => mod_bcd(6),Z(1) => mod_bcd(5),Z(0) => mod_bcd(4),
    A => MOD_1(6), B => MOD_1(5), C => MOD_1(4), D => MOD_1(3), E => MOD_1(2), 
    F => MOD_1(1), G => MOD_1(0)
);

Seven_MOD_2 : bcdToSeven PORT MAP(
    Z(3) => mod_bcd(3), Z(2) => mod_bcd(2),Z(1) => mod_bcd(1),Z(0) => mod_bcd(0),
    A => MOD_2(6), B => MOD_2(5), C => MOD_2(4), D => MOD_2(3), E => MOD_2(2), 
    F => MOD_2(1), G => MOD_2(0)
);

-- Seven_DIV_1 : bcdToSeven PORT MAP(
--     Z(3) => div_bcd(7), Z(2) => div_bcd(6),Z(1) => div_bcd(5),Z(0) => div_bcd(4),
--     A => DIV_1(6), B => DIV_1(5), C => DIV_1(4), D => DIV_1(3), E => DIV_1(2), 
--     F => DIV_1(1), G => DIV_1(0)
-- );

-- Seven_DIV_2 : bcdToSeven PORT MAP(
--     Z(3) => div_bcd(3), Z(2) => div_bcd(2),Z(1) => div_bcd(1),Z(0) => div_bcd(0),
--     A => DIV_2(6), B => DIV_2(5), C => DIV_2(4), D => DIV_2(3), E => DIV_2(2), 
--     F => DIV_2(1), G => DIV_2(0)
-- );

DIV_1 <= "1111111";
DIV_2 <= "1111111";
Seven_b1 : bcdToSeven PORT MAP(
    Z(3) => B_BCD(7), Z(2) => B_BCD(6),Z(1) => B_BCD(5),Z(0) => B_BCD(4),
    A => B1(6), B => B1(5), C => B1(4), D => B1(3), E => B1(2), 
    F => B1(1), G => B1(0)
);

Seven_B2 : bcdToSeven PORT MAP(
    Z(3) => B_BCD(3), Z(2) => B_BCD(2),Z(1) => B_BCD(1),Z(0) => B_BCD(0),
    A => B2(6), B => B2(5), C => B2(4), D => B2(3), E => B2(2), 
    F => B2(1), G => B2(0)
);


led_run <= run;


--  Menentukan bilangan yang disimpan di register A
next_A <= S WHEN (F = '0') ELSE A; -- Multiplexer

-- Membuat clock 1 hz
    PROCESS(CLK)
    BEGIN 
        IF RISING_EDGE(CLK) THEN 
            IF (counter_clock < max) THEN 
                counter_clock <= counter_clock + 1;
            ELSE 
                counter_clock <= 1;
            END IF;

            IF (counter_clock <= half) THEN
                clock1hz <= '0';
            ELSE 
                clock1hz <= '1';
            END IF;
        END IF;
    END PROCESS;

    -- D FLip FLop
    PROCESS(clock1hz)
    BEGIN
        IF RST = '0' THEN
            counter <= "0000";
            A <= "0000";
            B <= "0000";
            run <= '0';

        ELSIF STR = '0' THEN
            --register
            A <= A_input;
            B <= B_input;
            run <= '1';
				counter <= "0000";
			
		ELSIF B = "0000" AND run = '1' THEN
				run <= '0' ;
				A<= "0000";
				B <= "0000"; 
				

				

        ELSIF F = '1' THEN
            run <= '0';
        
        ELSIF RISING_EDGE(clock1hz) AND (run = '1') THEN
            A <= next_A ;
            counter <= next_counter;

        END IF ;
    END PROCESS;

END behavioral;





