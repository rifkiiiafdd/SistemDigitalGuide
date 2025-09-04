library ieee;
use ieee.std_logic_1164.all;
USE IEEE.numeric_std.ALL;

entity shortestWay is
    port (
        current_T : in signed(34 downto 0); -- 8 depan koma, 26 belakang koma, 1 tanda
        next_T : in signed(34 downto 0); -- 8 depan koma, 26 belakang koma, 1 tanda
        shortest : out signed(34 downto 0) -- 8 depan koma, 26 belakang koma, 1 tanda
    );
end shortestWay;

architecture behavioral of shortestWay is
    signal dt_1 : signed(35 downto 0); -- 9 depan koma, 26 belakang koma, 1 tanda
    signal dt_2 : signed(35 downto 0);
    begin
        dt_1 <= resize(next_T,36) - resize(current_T,36); -- selisih sudut
        dt_2 <= "010110100000000000000000000000000000" - abs(dt_1); -- 360 kurang selisih sudut

    process(dt_1,dt_2)
    begin
        if abs(dt_1) < dt_2 then
            shortest <= dt_1(34 downto 0);
        else
            if dt_1 < 0 then
                shortest <= dt_2(34 downto 0);
            else 
                shortest <= -dt_2(34 downto 0);
            end if;
        end if;
    end process;

end behavioral;

