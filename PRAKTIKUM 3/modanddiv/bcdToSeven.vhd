--Nama      : Rifki Afriadi
--NIM       : 13223049
--Rombongan : C
--Kelompok  : 7
--Percobaan : 2C
--Tanggal   : 14/10/2024


--Deskripsi
--Fungsi : Mengubah bilangan BCD satu digit(4bit) menjadi bentuk seven segment satu digit
--Input : Z (4 digit)
--Output : A,B,C,D,E,F,G

--Library
LIBRARY ieee;
USE ieee.std_logic_1164.all;

--Define entity
ENTITY bcdToSeven IS
	PORT( Z : IN STD_LOGIC_VECTOR(3 DOWNTO 0 );
			A,B,C,D,E,F,G : OUT STD_LOGIC);
END bcdToSeven;

--Define architecture
ARCHITECTURE behavioral OF bcdToSeven IS
BEGIN
--Implementasi fungsi logika yang diperoleh dengan POS dan SOP
A <= NOT ((Z(3) OR Z(2) OR Z(1) OR NOT Z(0)) AND (Z(3) OR NOT Z(2) OR Z(1) OR Z(0)));
B <= NOT ((Z(3) OR NOT Z(2) OR Z(1) OR NOT Z(0)) AND (Z(3) OR NOT Z(2) OR NOT Z(1) OR Z(0)));
C <= NOT (Z(3) OR Z(2) OR NOT Z(1) OR Z(0));
D <= NOT ((Z(3) OR Z(2) OR Z(1) OR NOT Z(0)) AND (Z(3) OR NOT Z(2) OR Z(1) OR Z(0)) AND (Z(3) OR NOT Z(2) OR NOT Z(1) OR NOT Z(0)));
E <= NOT ((NOT Z(2) AND NOT Z(1) AND NOT Z(0)) OR (NOT Z(3) AND Z(1) AND NOT Z(0)));
F <= NOT ((NOT Z(2) AND NOT Z(1) AND NOT Z(0)) OR (NOT Z(3) AND Z(2) AND NOT Z(1)) OR (Z(3) AND NOT Z(2) AND NOT Z(1)) OR (NOT Z(3) AND Z(2) AND NOT Z(0)));
G <= NOT ((Z(3) OR Z(2) OR Z(1)) AND (Z(3) OR NOT Z(2) OR NOT Z(1) OR NOT Z(0)));

END behavioral;
