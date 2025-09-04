library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity kuadran_detector is
    port (
        x1,y1,x0,y0 : in unsigned(9 downto 0);
        kuadran : out unsigned(1 downto 0);
        newdX : out signed(10 downto 0);
        newdY : out signed(10 downto 0)
    );
end kuadran_detector;

architecture behavioral of kuadran_detector is
    signal dX :  signed(10 downto 0);
    signal dY :  signed(10 downto 0);
begin 
    dX <= signed(resize(x1,11)) - signed(resize(x0,11));
    dY <= signed(resize(y1,11)) - signed(resize(y0,11));

    process(dX, dY)
    begin
        if (dX > 0 or dX = 0) and (dY > 0 or dY = 0) then
            kuadran <= "00";
            newdX <= dX;
            newdY <= dY;
        elsif (dX < 0 or dX = 0) and (dY > 0 or dY = 0) then
            kuadran <= "01";
            newdX <= -dX;
            newdY <= dY;
        elsif (dX < 0 or dX = 0) and (dY < 0 or dY = 0) then
            kuadran <= "10";
            newdX <= -dX;
            newdY <= -dY;
        elsif (dX > 0 or dX = 0) and (dY < 0 or dY = 0) then
            kuadran <= "11";
            newdX <= dX;
            newdY <= -dY;
        else
            kuadran <= (others => '0');
            newdX <= (others => '0');
            newdY <= (others => '0');
        end if;
    end process;

end architecture behavioral;
