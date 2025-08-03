library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Slicer is
  port (
    input_vector : in std_logic_vector(8 downto 0);
    out0 : out std_logic;
    out1 : out std_logic;
    out2 : out std_logic;
    out3 : out std_logic;
    out4 : out std_logic;
    out5 : out std_logic;
    out6 : out std_logic;
    out7 : out std_logic;
    out8 : out std_logic
  );
end Slicer;

architecture Behavioral of Slicer is
begin

  -- Concurrent assignments
  out0 <= input_vector(0);
  out1 <= input_vector(1);
  out2 <= input_vector(2);
  out3 <= input_vector(3);
  out4 <= input_vector(4);
  out5 <= input_vector(5);
  out6 <= input_vector(6);
  out7 <= input_vector(7);
  out8 <= input_vector(8);

end Behavioral;
