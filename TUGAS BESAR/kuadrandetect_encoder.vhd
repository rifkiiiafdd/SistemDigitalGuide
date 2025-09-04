LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

--spesifikasi : menjumlahkan current t dan dt untuk memperoleh new current dt (-180<current dt< 180)
ENTITY kuadrandetect_encoder IS
    PORT (
        current_T   : IN signed (34 downto 0);
        dt          : IN   signed (34 downto 0);
        newdegree   : OUT signed (34 downto 0) 
        );
END kuadrandetect_encoder;

ARCHITECTURE behavioral OF kuadrandetect_encoder IS
    CONSTANT nol             : signed (19 downto 0) := "00000000000000000000";
    CONSTANT sembilanpuluh   : signed (19 downto 0) := "00010110100000000000";
    CONSTANT satudelapanpuluh: signed (35 downto 0) := "001011010000000000000000000000000000";
    CONSTANT duatujuhpuluh   : signed (35 downto 0) := "010000111000000000000000000000000000";
    CONSTANT tigaenampuluh   : signed (35 downto 0) := "010110100000000000000000000000000000";

    
    SIGNAL comb_degree :  signed(35 downto 0);-- current_T + degree
    signal degree2 : signed(35 downto 0);-- current_T + degree
    signal int_comb_degree : signed(8 downto 0);-- current_T + degree di depan koma

    begin
    comb_degree <= resize(current_T,36) + resize(dt,36);
    newdegree <= degree2(34 downto 0);
    int_comb_degree <= comb_degree(34 downto 26);

    PROCESS (current_T,dt, int_comb_degree)
    BEGIN

        IF 180 > abs(to_integer(int_comb_degree)) THEN
            degree2 <= comb_degree;
        ELSIF int_comb_degree > 0 THEN
            degree2 <= (comb_degree - tigaenampuluh);
        ELSE 
            degree2 <= (tigaenampuluh + comb_degree);

        END IF;
        
    END PROCESS;

END behavioral;

-- 00010010101011100101101110000000011 dt
-- 00000000000000000000000000000000000 t