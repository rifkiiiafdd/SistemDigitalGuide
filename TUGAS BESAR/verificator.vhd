library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity verificator is
    Port (
        x           : in  unsigned(9 downto 0);  -- Input x
        y           : in  unsigned(9 downto 0);  -- Input y
        dx           : in signed(10 downto 0);
        dy             : in signed(10 downto 0);
        kuadran    : in  unsigned(1 downto 0);  -- Kuadran
        r_cordic    : out unsigned(36 downto 0);     -- Resultant magnitude
        yIsZero      : out std_logic;
        next_T   : out signed(34 downto 0)
    );
    
end verificator;

architecture Behavioral of verificator is

    -- Sinyal untuk hasil pergeseran x
    signal fixed_R : signed(29 downto 0);

    -- Sinyal sementara untuk hasil perhitungan
    signal temp_x       : signed(29 downto 0);
    signal temp_abs_x   : signed(29 downto 0);



begin
    -- Main Process untuk menghitung output
    yIsZero <= '1' when dy = "00000000000" else '0';
    process(x, y,dy,dx, kuadran)
    begin
        -- Nilai default
        
        r_cordic <= (others => '0');
        next_T <= (others => '0');

        -- Cek batas nilai x dan y
        if abs(to_integer(x)) > 1000 or abs(to_integer(y)) > 1000 or x =  1000 or y = 1000 then
            r_cordic <= to_unsigned(0, 37); -- Sesuaikan panjang bit dengan r_cordic
            next_T <= to_signed(0, 35); -- Sesuaikan panjang bit dengan next_T
            -- yIsZero <= '0';
        elsif dy = "00000000000" then
            -- Kasus khusus pada sumbu x
            r_cordic <= unsigned(abs(dx)) & ("00000000000000000000000000");

            if kuadran = 0 or kuadran = 3 then -- kuadran 1 dan 4
                next_T <= to_signed(0, 35); -- Sudut 0 derajat
            elsif kuadran = 1 or kuadran = 2 then -- 
                next_T <= "01011010000000000000000000000000000"; -- Sudut 180 derajat
            else
                next_T <= to_signed(0, 35); -- Tidak bergerak (origin)
        end if;
            -- Aktifkan CORDIC jika nilai valid (Hidupkan sebentar agar Cordic kerja dan ubah mode penerimaan r_cordic dan teta ke Cordic)
            -- yIsZero <= '0';
        end if;
    end process;

end Behavioral;
