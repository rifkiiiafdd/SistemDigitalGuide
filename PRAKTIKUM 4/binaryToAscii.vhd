--Nama      : Rifki Afriadi
--NIM       : 13223049
--Rombongan : C
--Kelompok  : 7
--Percobaan : 2A
--Tanggal   : 22/11/2024


--Deskripsi
--Fungsi : mengubah biner ke ascii
--Input : biner (4 bit)
--Output : ascii(8 bit)

library ieee;
use ieee.std_logic_1164.all;

entity binarytoascii is
    port(
        ascii : out std_logic_vector(7 downto 0);
        binary : in std_logic_vector(3 downto 0)
    );
end entity;

architecture behavioral of binarytoascii is
begin
    ascii <= "0011" & binary;

end behavioral;