LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY Cordic IS
  PORT(
    clk             : IN  std_logic;
    reset           : IN  std_logic;
    cordic_on       : IN  std_logic;
    x_in            : IN  SIGNED(10 DOWNTO 0);
    y_in            : IN  SIGNED(10 DOWNTO 0);
    z               : OUT std_logic;
    r_cordic        : OUT UNSIGNED(36 DOWNTO 0) ; -- 26 bit di belakang koma, 11 bit integer
    p_cordic        : OUT UNSIGNED(32 DOWNTO 0) := (OTHERS => '0') -- 7 bit di depan koma, 26 bit di belakang koma, 1 tanda
  );
END Cordic;

ARCHITECTURE Behavioral OF Cordic IS
  TYPE state_type IS (IDLE, START, CALCULATE, STOP);
  SIGNAL state : state_type := IDLE;
  SIGNAL multiply_result : SIGNED(54 DOWNTO 0) := (OTHERS => '0');

  SIGNAL x, y : SIGNED(27 DOWNTO 0) := (OTHERS => '0'); -- 1 SIGN, 12 INTEGER, 15 FIX
  SIGNAL iteration : SIGNED(5 DOWNTO 0) := (OTHERS => '0');
  SIGNAL shifted_x, shifted_y : SIGNED(27 DOWNTO 0);
  SIGNAL z_internal : UNSIGNED (32 DOWNTO 0) := (OTHERS => '0');
  SIGNAL r_mulitpler : SIGNED (26 DOWNTO 0) := "010011011011101001110110110" ;

  TYPE lut_array IS ARRAY(0 TO 31) OF SIGNED(31 DOWNTO 0);

    -- Deklarasi konstanta LUT dengan nilai ArcTan (16-bit fixed-point)
    CONSTANT LUT_VALUES : lut_array := (
        ("10110100000000000000000000000000"),  -- ArcTan(2^0) = atan(1) ≈ 45° -> 45 * 2^13
        ("01101010010000101010100110010011"),   -- ArcTan(2^-1) = atan(0.5) ≈ 26.565° -> 26.565 * 2^13
        ("00111000001001010001000110011100"),   -- ArcTan(2^-2) = atan(0.25) ≈ 14.036° -> 14.036 * 2^13
        ("00011100100000000000010001001001"),   -- ArcTan(2^-3) = atan(0.125) ≈ 7.125° -> 7.125 * 2^13
        ("00001110010011100010000110010110"),    -- ArcTan(2^-4) = atan(0.0625) ≈ 3.576° -> 3.576 * 2^13
        ("00000111001010001101111001010011"),    -- ArcTan(2^-5) = atan(0.03125) ≈ 1.790° -> 1.790 * 2^13
        ("00000011100101001010100001101010"),    -- ArcTan(2^-6) = atan(0.015625) ≈ 0.895° -> 0.895 * 2^13
        ("00000001110010100101101101011110"),    -- ArcTan(2^-7) = atan(0.0078125) ≈ 0.448° -> 0.448 * 2^13
        ("00000000111001010010111010010100"),     -- ArcTan(2^-8) = atan(0.00390625) ≈ 0.224° -> 0.224 * 2^13
        ("00000000011100101001011101100110"),     -- ArcTan(2^-9) = atan(0.001953125) ≈ 0.112° -> 0.112 * 2^13
        ("00000000001110010100101110110111"),     -- ArcTan(2^-10) = atan(0.0009765625) ≈ 0.056° -> 0.056 * 2^13
        ("00000000000111001010010111011011"),      -- ArcTan(2^-11) = atan(0.00048828125) ≈ 0.028° -> 0.028 * 2^13
        ("00000000000011100101001011101110"),      -- ArcTan(2^-12) = atan(0.000244140625) ≈ 0.014° -> 0.014 * 2^13
        ("00000000000001110010100101110111"),      -- ArcTan(2^-13) = atan(0.0001220703125) ≈ 0.007° -> 0.007 * 2^13
        ("00000000000000111001010010111011"),      -- ArcTan(2^-14) = atan(0.00006103515625) ≈ 0.0035° -> 0.0035 * 2^13
        ("00000000000000011100101001011101"),      -- ArcTan(2^-15) = atan(0.000030517578125) ≈ 0.0018° -> 0.0018 * 2^13
        ("00000000000000001110010100101110"),      -- ArcTan(2^-16) ≈ 0.0009° -> 0.0009 * 2^13
        ("00000000000000000111001010010111"),      -- ArcTan(2^-17)
        ("00000000000000000011100101001011"),      -- ArcTan(2^-18)
        ("00000000000000000001110010100101"),      -- ArcTan(2^-19)
        ("00000000000000000000111001010010"),      -- ArcTan(2^-20)
        ("00000000000000000000011100101001"),      -- ArcTan(2^-21)
        ("00000000000000000000001110010100"),      -- ArcTan(2^-22)
        ("00000000000000000000000111001010"),      -- ArcTan(2^-23) 0.00001
        ("00000000000000000000000011100101"),      -- ArcTan(2^-24) 0.000005
        ("00000000000000000000000001110010"),      -- ArcTan(2^-25) 0.000002
        ("00000000000000000000000000111001"),      -- ArcTan(2^-26) 0.000001
        ("00000000000000000000000000011100"),      -- ArcTan(2^-27)
        ("00000000000000000000000000001110"),      -- ArcTan(2^-28)
        ("00000000000000000000000000000111"),      -- ArcTan(2^-29)
        ("00000000000000000000000000000011"),      -- ArcTan(2^-30)
        ("00000000000000000000000000000001")       -- ArcTan(2^-31)
    );

  COMPONENT W_RShift IS
    GENERIC(Size : INTEGER := 28);
    PORT(A : IN SIGNED(Size DOWNTO 0); Shift : IN INTEGER; Result : OUT SIGNED(Size DOWNTO 0));
  END COMPONENT;



BEGIN
  -- Port mapping for W_RShift
  
  RShiftX_Instance: W_RShift GENERIC MAP (Size => 27) PORT MAP (A => x, Shift => to_integer((iteration)), Result => shifted_x);
  RShiftY_Instance: W_RShift GENERIC MAP (Size => 27) PORT MAP (A => y, Shift => to_integer((iteration)), Result => shifted_y);

  -- Multiplier for scaling x
  -- Multiplier_Instance: W_Multiplier GENERIC MAP (Size => 14) PORT MAP (A => x, B => to_signed(6072, 14), Result => r_unadjusted);

  r_cordic <= unsigned(multiply_result(51 downto 15));
  p_cordic <= z_internal;

  PROCESS (clk, reset)
  BEGIN
    IF reset = '1' THEN
      state <= IDLE;
      x <= (OTHERS => '0');
      y <= (OTHERS => '0');
      z_internal <= (OTHERS => '0');
      iteration <= (OTHERS => '0');
      z <= '0';
    ELSIF rising_edge(clk) THEN
    
    
      CASE state IS
        WHEN IDLE =>
          IF cordic_on = '1' THEN state <= START; END IF;

        WHEN START =>
          -- -- konverter kuadran
          -- if x_in < 0  and y_in  0 then
          --   x <= -x_in;
          --   y <= -y_in;:

          X <= "00" & x_in & "000000000000000";
          Y <= "00" & y_in & "000000000000000";

          z_internal <= (OTHERS => '0');
          iteration <= (OTHERS => '0');
          state <= CALCULATE;

        WHEN CALCULATE =>
          IF ((to_integer(unsigned(iteration)) < 31)) THEN
          
            IF y < 0 THEN
              z_internal <= z_internal - (('0') & unsigned(LUT_VALUES(to_integer(iteration)))); -- Gunakan LUT
              x <= x - shifted_y;
              y <= y + shifted_x;
            ELSE
              z_internal <= z_internal + (('0') & unsigned(LUT_VALUES(to_integer(iteration)))); -- Gunakan LUT
              x <= x + shifted_y;
              y <= y - shifted_x;
            END IF;
            iteration <= iteration + 1;

          ELSE
            state <= STOP;
          END IF;

        WHEN STOP =>
          multiply_result <= (x) * (r_mulitpler);
          
          z <= '1';
          state <= IDLE;

        WHEN OTHERS =>
          state <= IDLE;
      END CASE;
    END IF;
  END PROCESS;

END Behavioral;

-- 0110101 00010101110111111101011011

-- force -freeze sim:/cordic/clk 1 0, 0 {25 ps} -r 50
-- force -freeze sim:/cordic/reset 0 0
-- force -freeze sim:/cordic/cordic_on 1 0
-- force -freeze sim:/cordic/x_in 01100100000 0
-- force -freeze sim:/cordic/y_in 01100100000 0
-- run 100
-- force -freeze sim:/cordic/cordic_on 0 0
-- run 2000

