LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY ascii_to_binary IS
    PORT (
        result_x         : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
        result_y         : OUT STD_LOGIC_VECTOR(9 DOWNTO 0)
    );
END ascii_to_binary;


ARCHITECTURE Behavioral OF ascii_to_binary IS

    TYPE binaryArray IS ARRAY (0 TO 11) OF std_logic_vector(7 downto 0);
    SIGNAL MEM_UART : binaryArray := (others => "00000000");

    signal x_bcd : std_logic_vector(15 downto 0) := (others => '0');
    signal y_bcd : std_logic_vector(15 downto 0) := (others => '0');

    component bcd_to_biner is
        Port ( bcd : in  STD_LOGIC_VECTOR (15 downto 0);
               bin : out  STD_LOGIC_VECTOR (9 downto 0));
    end component;
    
    
BEGIN 
    mem_uart(0) <= "00110000";
    mem_uart(1) <= "00110101";
    mem_uart(2) <= "00110000";
    mem_uart(3) <= "00110010";
    mem_uart(4) <= "00111011";
    mem_uart(5) <= "00110000";
    mem_uart(6) <= "00110011";
    mem_uart(7) <= "00110011";
    mem_uart(8) <= "00110101";


    x_bcd <= mem_uart(0)(3 downto 0) & mem_uart(1)(3 downto 0) & mem_uart(2)(3 downto 0) & mem_uart(3)(3 downto 0);
    y_bcd <= mem_uart(5)(3 downto 0) & mem_uart(6)(3 downto 0) & mem_uart(7)(3 downto 0) & mem_uart(8)(3 downto 0);

    x_to_biner : bcd_to_biner port map (bcd => x_bcd, bin => result_x);
    y_to_biner : bcd_to_biner port map (bcd => y_bcd, bin => result_y);



END Behavioral;