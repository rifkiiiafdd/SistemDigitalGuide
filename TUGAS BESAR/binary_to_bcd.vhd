LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY binary_to_bcd IS
    PORT(
        i_DATA		    :	IN UNSIGNED(10 DOWNTO 0);
        i_CLK		    :	IN STD_LOGIC;
        i_start		    :	IN STD_LOGIC;
        convert_done    :	OUT STD_LOGIC := '0';
        o_bcd		    :	OUT UNSIGNED(15 DOWNTO 0)
    );
END binary_to_bcd;

ARCHITECTURE behavioral OF binary_to_bcd IS
    SIGNAL BCD : UNSIGNED(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL biner : UNSIGNED(10 DOWNTO 0) := (OTHERS => '0');
    SIGNAL counter : integer := 0;
    SIGNAL running : std_logic := '0';

    SIGNAL STATE : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0000";

    BEGIN
    PROCESS(i_CLK, i_start, i_DATA)
    BEGIN
    

    -- if rising_edge(i_CLK) THEN
    --     if i_start = '1' then
    --         counter <= 0;
    --         BCD <= (OTHERS => '0');
    --         biner <= (OTHERS => '0');
    --         running <= '1';
    --         convert_done <= '0';
    --     end if;
        
        

    --     if counter < 12 and counter > 0 and running = '1' then
    --         counter <= counter + 1;
    --         BCD <= BCD(14 DOWNTO 0) & biner(10);
    --         biner <= biner(9 DOWNTO 0) & '0';
        
    --         if (BCD(3 downto 0) > 4)  then
    --             BCD(4 downto 1) <= BCD(3 downto 0) + 3;
    --         end if;

    --         if (BCD(7 downto 4) > 4)  then
    --             BCD(8 downto 5) <= BCD(7 downto 4) + 3;
    --         end if;
    --         if (BCD(11 downto 8) > 4)  then
    --             BCD(12 downto 9) <= BCD(11 downto 8) + 3;
    --         end if;
        
    --     elsif counter = 0 and running = '1' then
    --         -- convert_done <= '0';
    --         counter <= counter + 1;
    --         biner <= i_DATA;   
    --     elsif running = '1' then
    --         convert_done <= '1';
    --         running <= '0';
    --     end if;        
    -- 0000 1000 0101 1000
    -- 0010 1001 0000 0110
    -- 001 0100 1000 0011 0
    -- end if;

    IF RISING_EDGE(I_CLK) THEN
        
        CASE STATE is
            WHEN "0000" =>
            CONVERT_DONE <= '0';
            IF i_start = '1' THEN
                STATE <= "0001";
                BCD <= (OTHERS => '0');
                biner <= i_DATA;
                counter <= 0;
            ELSE
                STATE <= "0000";
            END IF;
            
            WHEN "0001" =>
                counter <= counter + 1;
                BCD <= BCD(14 DOWNTO 0) & biner(10);
                biner <= biner(9 DOWNTO 0) & '0';
            
                if (BCD(3 downto 0) > 4)  then
                    BCD(4 downto 1) <= BCD(3 downto 0) + 3;
                end if;

                if (BCD(7 downto 4) > 4)  then
                    BCD(8 downto 5) <= BCD(7 downto 4) + 3;
                end if;

                if (BCD(11 downto 8) > 4)  then
                    BCD(12 downto 9) <= BCD(11 downto 8) + 3;
                end if;
                if counter = 10 then
                    STATE <= "0000";
                    convert_done <= '1';
                ELSE
                    STATE <= "0001";
                END IF;
            
            WHEN OTHERS => NULL;
        
        END CASE;
    END IF;

    end process;
    o_bcd <= (BCD);
end behavioral;
