LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY comparator IS 
    PORT(
        A,B : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        F : OUT STD_LOGIC
    );
END ENTITY;

ARCHITECTURE behavioral OF comparator IS 
    SIGNAL I : STD_LOGIC_VECTOR(3 DOWNTO 0);

BEGIN

    GEN_I : FOR N IN 0 TO 3 GENERATE
        I(N) <= A(N) XNOR B(N);
    END GENERATE GEN_I ;

    F <= (NOT A(3) AND  B(3)) OR (I(3) AND NOT A(2) AND B(2)) OR 
    (I(3) AND I(2) AND NOT A(1) AND B(1)) OR 
    (I(3) AND I(2) AND I(1) AND NOT A(0) AND B(0)) ;
    -- OR NOT(I(3) AND I(2) AND (1) AND I(0));

END behavioral;