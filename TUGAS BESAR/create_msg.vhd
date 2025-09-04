library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity create_msg is
    port (
        clk : in std_logic;
        i_start : IN STD_LOGIC;
        create_done : out std_logic := '0';
        reset : in std_logic;
        dT_min : in std_logic;
        dT1_bcd : in  unsigned(11 downto 0) := (others => '0');
	    dT2_bcd : in  unsigned(11 downto 0) := (others => '0');
	    R_bcd : in unsigned(15 downto 0) := (others => '0');
        R2_bcd : in  unsigned(11 downto 0) := (others => '0');

        msg : out std_logic_vector(209 downto 0)

    );
end create_msg;

architecture behavioral of create_msg is

    signal state : std_logic_vector(3 downto 0) := "1111";
    signal data_biner : unsigned(10 downto 0) := (others => '0');
    signal data_bcd : unsigned(15 downto 0) := (others => '0');
    -- signal i_RST : std_logic := '0';

    -- force -freeze sim:/create_msg/clk 1 0, 0 {25 ps} -r 50
    -- force -freeze sim:/create_msg/i_start 1 0
    -- force -freeze sim:/create_msg/reset 0 0, 1 {7000 ps} -r 14000
    -- force -freeze sim:/create_msg/dT_min 1 0
    -- force -freeze sim:/create_msg/dT1_bcd   000100100011 0
    -- force -freeze sim:/create_msg/dT2_bcd   010001010110 0
    -- force -freeze sim:/create_msg/R_bcd 1001100001111000 0
    -- force -freeze sim:/create_msg/R2_bcd    100001111000 0
    
begin

    
    
    process(i_start, dT_min, dT1_bcd, dT2_bcd, R_bcd,R2_bcd, reset, clk)
    begin
        

        if reset = '1' then
            state <= "1111";
            create_done <= '0';
            msg <= (others => '0');
        elsif rising_edge(clk) then

        case state is
            when "1111" =>-- idle
                if i_start = '1' then
                    state <= "0000";
                    create_done <= '0';
                else 
                    state <= "1111";
                end if;

            when "0000" => -- pengisian dT:
                msg(29 downto 0) <= "100111010010101010001011001000";
                state <= "0001";
            when "0001" => -- pengisian tanda - dt
                -- i_rst <= '1';
               
    
                if dT_min = '1' then
                    msg(39 downto 30) <= "1001011010";
                    
                else 
                    msg(39 downto 30) <= "1001010110";
                end if;    

                state <= "0010";

            when "0010" =>  -- pengisian angka di depan koma dT

                msg(69 downto 40) <= "10011" & std_logic_vector(dT1_bcd(3 downto 0)) & '0' 
                                    & "10011" & std_logic_vector(dT1_bcd(7 downto 4)) & '0' 
                                    & "10011" & std_logic_vector(dT1_bcd(11 downto 8)) & '0';


                -- msg(69 downto 40) <= "10011" & "0011"& '0' 
                --                     & "10011" & "0011" & '0' 
                --                     & "10011" & "0011" & '0';

                state <= "0011";


            when "0011" => -- pengisian angka di belakang koma dT
                msg(109 downto 70) <=  "10011" & std_logic_vector(dT2_bcd(3 downto 0) & '0')  
                                        & "10011" & std_logic_vector(dT2_bcd(7 downto 4)) & '0' 
                                        & "10011" & std_logic_vector(dT2_bcd(11 downto 8) & '0')  
                                        & "1001011000"; 

                state <= "0100";


            when "0100" => -- pengisian R:
                msg(129 downto 110) <= "10011101001010100100";
                state <= "0101";
            
            when "0101" =>
            
                msg(169 downto 130) <= "10011" & std_logic_vector(R_bcd(3 downto 0) & '0') & 
                "10011" & std_logic_vector(R_bcd(7 downto 4) & '0') & 
                "10011" & std_logic_vector(R_bcd(11 downto 8) & '0') & 
                "10011" & std_logic_vector(R_bcd(15 downto 12) & '0') ;


                state <= "0110";
            
            when "0110" => -- pengisian koma seetelah R
                msg(209 downto 170) <=   
                                        "10011" & std_logic_vector(R2_bcd(3 downto 0) & '0') & 
                                        "10011" & std_logic_vector(R2_bcd(7 downto 4) & '0') & 
                                        "10011" & std_logic_vector(R2_bcd(11 downto 8) & '0') &
                                        "1001011000";
                
                
                create_done <= '1';
                state <= "1111";
            

            when others =>
                state <= "1111";
                create_done <= '0';
        end case;

        end if;
    end process;

end behavioral;
