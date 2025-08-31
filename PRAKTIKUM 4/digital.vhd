library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity digital is
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           leds : out STD_LOGIC_VECTOR (11 downto 0));
end digital;

architecture Behavioral of digital is
    signal counter : INTEGER := 0;
    signal led_state : STD_LOGIC_VECTOR (11 downto 0) := (others => '0');
    signal clk_div : INTEGER := 0;
    constant clk_div_max : INTEGER := 50000000; -- Assuming 50MHz clock for 1 second delay

begin
    process(clk, rst)
    begin
        if rst = '1' then
            counter <= 0;
            led_state <= (others => '0');
            clk_div <= 0;
        elsif rising_edge(clk) then
            if clk_div = clk_div_max then
                clk_div <= 0;
                counter <= counter + 1;
                if counter = 12 then
                    counter <= 0;
                end if;
                led_state <= (others => '0');
                led_state(counter) <= '1';
            else
                clk_div <= clk_div + 1;
            end if;
        end if;
    end process;

    leds <= led_state;

end Behavioral;