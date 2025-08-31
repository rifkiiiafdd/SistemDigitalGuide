-- Template kode untuk ASCII - HEX (7 Segments) Converter
-- Kode ASCII yang harus diterjemahkan adalah:
-- angka 0, 1, 2, 3, 4, 5, 6, 7, 8, dan 9.
-- huruf A, B, C, D, E, F, G, H, I, dan J.
-- Tampilan pada HEX (7 Segments) sebagai berikut:
-- 1 -> 1
-- 2 -> 2
-- 3 -> 3
-- 4 -> 4
-- 5 -> 5
-- 6 -> 6
-- 7 -> 7
-- 8 -> 8
-- 9 -> 9
-- 0 -> 0
-- A -> A
-- B -> b
-- C -> c
-- D -> d
-- E -> E
-- F -> F
-- G -> G
-- H -> H
-- I -> I (di sebelah kiri, tidak seperti angka 1)
-- J -> j (tanpa titik)


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity asciiHex is
	port	(
				i_ascii		:		in		std_logic_vector(7 downto 0);
				hex1	:		out		std_logic_vector(6 downto 0)
			);
end asciiHex;


architecture behavior of asciiHex is
	CONSTANT NOL : STD_LOGIC_VECTOR(7 DOWNTO 0)    := "00110000";
	CONSTANT SATU : STD_LOGIC_VECTOR(7 DOWNTO 0)   := "00110001";
	CONSTANT DUA : STD_LOGIC_VECTOR(7 DOWNTO 0)    := "00110010";
	CONSTANT TIGA : STD_LOGIC_VECTOR(7 DOWNTO 0)   := "00110011";
	CONSTANT EMPAT : STD_LOGIC_VECTOR(7 DOWNTO 0)  := "00110100";
	CONSTANT LIMA : STD_LOGIC_VECTOR(7 DOWNTO 0)   := "00110101";
	CONSTANT ENAM : STD_LOGIC_VECTOR(7 DOWNTO 0)   := "00110110";
	CONSTANT TUJUH : STD_LOGIC_VECTOR(7 DOWNTO 0)  := "00110111";
	CONSTANT DELAPAN : STD_LOGIC_VECTOR(7 DOWNTO 0):= "00111000";
	CONSTANT SEMBILAN: STD_LOGIC_VECTOR(7 DOWNTO 0):= "00111001";
	CONSTANT A : STD_LOGIC_VECTOR(7 DOWNTO 0) := "01000001";
	CONSTANT B : STD_LOGIC_VECTOR(7 DOWNTO 0) := "01000010";
	CONSTANT C : STD_LOGIC_VECTOR(7 DOWNTO 0) := "01000011";
	CONSTANT D : STD_LOGIC_VECTOR(7 DOWNTO 0) := "01000100";
	CONSTANT E : STD_LOGIC_VECTOR(7 DOWNTO 0) := "01000101";
	CONSTANT F : STD_LOGIC_VECTOR(7 DOWNTO 0) := "01000110";
	CONSTANT G : STD_LOGIC_VECTOR(7 DOWNTO 0) := "01000111";
	CONSTANT H : STD_LOGIC_VECTOR(7 DOWNTO 0) := "01001000";
	CONSTANT I : STD_LOGIC_VECTOR(7 DOWNTO 0) := "01001001";
	CONSTANT J : STD_LOGIC_VECTOR(7 DOWNTO 0) := "01001010";
	CONSTANT Ai : STD_LOGIC_VECTOR(7 DOWNTO 0) := "01100001";
	CONSTANT Bi : STD_LOGIC_VECTOR(7 DOWNTO 0) := "01100010";
	CONSTANT Ci : STD_LOGIC_VECTOR(7 DOWNTO 0) := "01100011";
	CONSTANT Di : STD_LOGIC_VECTOR(7 DOWNTO 0) := "01100100";
	CONSTANT Ei : STD_LOGIC_VECTOR(7 DOWNTO 0) := "01100101";
	CONSTANT Fi : STD_LOGIC_VECTOR(7 DOWNTO 0) := "01100110";
	CONSTANT Gi : STD_LOGIC_VECTOR(7 DOWNTO 0) := "01100111";
	CONSTANT Hi : STD_LOGIC_VECTOR(7 DOWNTO 0) := "01101000";
	CONSTANT Ii : STD_LOGIC_VECTOR(7 DOWNTO 0) := "01101001";
	CONSTANT Ji : STD_LOGIC_VECTOR(7 DOWNTO 0) := "01101010";

begin

	PROCESS(i_ascii)
		BEGIN
		CASE i_ascii IS
			WHEN NOL => HEX1 <= NOT "1111110";
			WHEN SATU => HEX1 <= NOT "0110000";
			WHEN DUA => HEX1 <= NOT "1101101";
			WHEN TIGA => HEX1 <= NOT "1111001";
			WHEN EMPAT => HEX1 <= NOT "0110011";
			WHEN LIMA => HEX1 <= NOT "1011011";
			WHEN ENAM => HEX1 <= NOT "1011111";
			WHEN TUJUH => HEX1 <= NOT "1110000";
			WHEN DELAPAN => HEX1 <= NOT "1111111";
			WHEN SEMBILAN => HEX1 <= NOT "1110011";
			WHEN A | Ai  => HEX1 <= "0001000";
			WHEN B | bi => HEX1 <= "1100000";
			WHEN C | ci => HEX1 <= "0110001";
			WHEN D | di => HEX1 <= "1000010";
			WHEN E | ei => HEX1 <= "0110000";
			WHEN F | fi => HEX1 <= "0111000";
			WHEN G | gi => HEX1 <= "0000100";
			WHEN H | hi => HEX1 <= "1001000";
			WHEN I | ii => HEX1 <= "1111001";
			WHEN J | ji => HEX1 <= "1000111";

			WHEN OTHERS => HEX1 <=  "1111111";
		END CASE;
	END PROCESS;
	--- rancanglah arsitektur dari modul konverter ini.
	
end behavior;


