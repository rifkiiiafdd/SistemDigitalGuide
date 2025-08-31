--Nama      : Rifki Afriadi
--NIM       : 13223049
--Rombongan : C
--Kelompok  : 7
--Percobaan : 2C
--Tanggal   : 14/10/2024


--Deskripsi
--Fungsi : Menjumlahkan bilangan 1 BIT
--Input : A,B (bilangan biner 1 BIT), C_in (carry awal)
--Output : S, C_out

--library
LIBRARY ieee;
USE ieee.std_logic_1164.all;

--Define entity
ENTITY fulladder IS
-- Define port
	PORT(A,B,C_in :in std_logic; 
		S, C_out : out std_logic);
END fulladder;

--Define architecture
ARCHITECTURE behavioral OF  fulladder IS
BEGIN
	S <= A XOR B XOR C_in; -- Penjumlahan S (bit paling kanan)
	C_out <= (A AND B) OR  (A AND C_in) OR (B AND C_in); -- Menghitung Carry
END behavioral;
