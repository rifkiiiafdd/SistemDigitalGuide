LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

-- Fungsi: Inverskan kembali ketika selesai dicordic ke kuadran semula
ENTITY kuadrandetect_decoder IS
    PORT (
        indegree : IN signed (32 downto 0); -- 26 bit fix, 7 bit fc
        kuadran  : IN unsigned (1 downto 0); -- Kuadran 00: Kuadran 1, 01: Kuadran 2, 10: Kuadran 3, 11: Kuadran 4
        outdegree: OUT signed (34 downto 0) -- 26 bit fix, 8 bit fc, 1 bit tanda
    );
END kuadrandetect_decoder;

ARCHITECTURE behavioral OF kuadrandetect_decoder IS
--  CONSTANT sembilanpuluh   : signed (34 downto 0) := "00101101000000000000000000000000000"; -- 90
 CONSTANT satudelapanpuluh: signed (34 downto 0) := "01011010000000000000000000000000000"; -- 180
--  CONSTANT duatujuhpuluh   : signed (19 downto 0) := "010000111000000000000000000000000000"; -- 270
--  CONSTANT tigaenampuluh   : signed (19 downto 0) := "01011010000000000000"; -- 360

BEGIN

    PROCESS (indegree, kuadran)
        VARIABLE indegree_extended: signed(34 downto 0);
    BEGIN
        -- Perluas indegree ke 19 bit menggunakan resize
        -- indegree_extended := resize(indegree, 20); -- Tambahkan 3 bit '0' di LSB
        indegree_extended := "00" & indegree ;

        CASE kuadran IS
            WHEN "00" => -- Kuadran 1
                outdegree <= indegree_extended;
            WHEN "01" => -- Kuadran 2
                outdegree <= satudelapanpuluh - indegree_extended;
            WHEN "10" => -- Kuadran 3
                outdegree <= -(satudelapanpuluh - indegree_extended);
            WHEN "11" => -- Kuadran 4
                outdegree <= -indegree_extended;
            WHEN OTHERS =>
                outdegree <= (OTHERS => '0'); -- Default output jika kondisi tidak terpenuhi
        END CASE;
    END PROCESS;
END behavioral;