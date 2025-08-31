--Nama      : Rifki Afriadi
--NIM       : 13223049
--Rombongan : C
--Kelompok  : 7
--Percobaan : 2C
--Tanggal   : 1/11/2024


--Deskripsi
--Fungsi : Mengurangkan bilangan 1 BIT
--Input : A,B (bilangan biner 1 BIT), B_in (carry awal)
--Output : S, B_out

--library
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

--Define entity
ENTITY fs IS
-- Define port
	PORT(A,B,B_in :in std_logic; 
		S, B_out : out std_logic);
END fs;

--Define architecture
ARCHITECTURE behavioral OF  fs IS
BEGIN
	S <= A XOR B XOR B_in; -- Pengurangan S (bit paling kanan)
	B_out <= (NOT A AND B) OR  (B AND B_in) OR (NOT A AND B_in); -- Menghitung Carry
END behavioral;
