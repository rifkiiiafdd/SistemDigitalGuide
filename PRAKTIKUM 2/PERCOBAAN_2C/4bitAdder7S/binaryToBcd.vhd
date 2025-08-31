--Nama      : Rifki Afriadi
--NIM       : 13223049
--Rombongan : C
--Kelompok  : 7
--Percobaan : 2C
--Tanggal   : 14/10/2024


--Deskripsi
--Fungsi : Mengubah bilangan biner 5 bit menjadi BCD dua digit
-- Input : M (5 bit)
-- Output : X (4 bit, BCD digit pertama), Y (4 bit, BCD digit kedua)


-- library
LIBRARY ieee;
USE ieee.std_logic_1164.all;

--define entity
ENTITY binaryToBcd IS
	PORT( M : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
			X,Y : OUT STD_LOGIC_VECTOR(3 DOWNTO 0));
END binaryToBcd;

--define architecture
ARCHITECTURE behavioral OF binaryToBcd IS
BEGIN
	--Implementasi fungsi logika
	X(3)<='0';
	X(2)<='0';
	X(1)<=(M(4) AND M(3)) OR (M(4) AND M(2));
	X(0)<=(NOT(M(4)) AND M(3) AND M(2)) OR (M(4) AND NOT(M(3)) AND NOT(M(2))) OR (M(3) AND M(2) AND M(1)) OR (NOT(M(4)) AND M(3) AND M(1));
	Y(3)<=(NOT M(4) AND M(3) AND NOT M(2) AND NOT M(1)) OR (M(4) AND M(3) AND M(2) AND NOT M(1)) OR (M(4) AND NOT M(3) AND NOT M(2) AND M(1)) ;
	Y(2)<=(NOT M(4) AND NOT M(3) AND M(2)) OR (NOT M(4) AND M(2) AND M(1)) OR (M(4) AND NOT M(2) AND NOT M(1)) OR (M(4) AND M(3) AND NOT M(2)) ;
	Y(1)<=(NOT M(4) AND NOT M(3) AND M(1)) OR (NOT M(4) AND M(3) AND M(2) AND NOT M(1)) OR (M(4) AND NOT M(3) AND NOT M(2) AND NOT M(1)) OR (M(4) AND NOT M(3) AND M(2) AND M(1)) OR (M(4) AND M(3) AND NOT M(2) AND M(1)) ;
	Y(0)<=M(0);

END behavioral;
	