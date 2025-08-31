--Nama      : Rifki Afriadi
--NIM       : 13223049
--Rombongan : C
--Kelompok  : 7
--Percobaan : 2A
--Tanggal   : 22/11/2024


--Deskripsi
--Fungsi : mengubah ascii ke biner
--Input : ascii (8 bit)
--Output : biner(4 bit)

library ieee;
use ieee.std_logic_1164.all;

entity asciitobinary is
    port(
        ascii : in std_logic_vector(7 downto 0);
        binary : out std_logic_vector(3 downto 0)
    );
end entity;

architecture behavioral of asciitobinary is
    
begin
    binary <= ascii(3 downto 0);

end behavioral;