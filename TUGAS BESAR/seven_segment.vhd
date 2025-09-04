LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY seven_segment IS 
    PORT(
        i_CLK : IN STD_LOGIC;
        SEG1 : IN STD_LOGIC_VECTOR(6 DOWNTO 0);
        SEG2 : IN STD_LOGIC_VECTOR(6 DOWNTO 0);
        SEG3 : IN STD_LOGIC_VECTOR(6 DOWNTO 0);
        SEG4 : IN STD_LOGIC_VECTOR(6 DOWNTO 0);
        LED : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        SEG_out : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)

    );
END seven_segment;

ARCHITECTURE BEHAVIORAL OF seven_segment is
    signal counter : integer := 0; 

    begin

    PROCESS(i_CLK, counter)

    BEGIN
        IF rising_edge(i_CLK) THEN
            IF counter = 0 THEN
                SEG_out <= SEG1;
                LED <= "0111";
                counter <= counter + 1;
            ELSIF counter = 1 THEN
                SEG_out <= SEG2;
                LED <= "1011";
                counter <= counter + 1;
            ELSIF counter = 2 THEN
                SEG_out <= SEG3;
                LED <= "1101";
                counter <= counter + 1;
            ELSIF counter = 3 THEN
                SEG_out <= SEG4;
                LED <= "1110";
                counter <= 0;
            END IF;
            
            IF COUNTER > 3 THEN
                counter <= 0;
            ELSE 
                counter <= counter + 1;
            END IF;

        END IF;
    END PROCESS;

    end BEHAVIORAL;
    
    -- force -freeze sim:/seven_segment/SEG1 1001101 0
    -- force -freeze sim:/seven_segment/SEG2 1001110 0
    -- force -freeze sim:/seven_segment/SEG3 1111101 0
    -- force -freeze sim:/seven_segment/SEG4 1000101 0
    -- force -freeze sim:/seven_segment/i_CLK 1 0, 0 {25 ps} -r 50
    -- run 500
