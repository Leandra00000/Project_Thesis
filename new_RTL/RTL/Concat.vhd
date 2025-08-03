----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 27.04.2025 12:09:48
-- Design Name: 
-- Module Name: Concat - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Concat is

port (
    in0 : in std_logic;
    in1 : in std_logic;
    in2 : in std_logic;
    in3 : in std_logic;
    in4 : in std_logic;
    in5 : in std_logic;
    in6 : in std_logic;
    in7 : in std_logic;
    in8 : in std_logic;
    output_vector : out std_logic_vector(8 downto 0)
  );
end Concat;

architecture Behavioral of Concat is

begin

     -- Concurrent assignments
  output_vector(0) <= in0;
  output_vector(1) <= in1;
  output_vector(2) <= in2;
  output_vector(3) <= in3;
  output_vector(4) <= in4;
  output_vector(5) <= in5;
  output_vector(6) <= in6;
  output_vector(7) <= in7;
  output_vector(8) <= in8;

end Behavioral;
