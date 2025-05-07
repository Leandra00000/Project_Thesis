library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity test_Transmission is 
end test_Transmission;


architecture TB of test_Transmission is

component Transmission is
port (
  Clk : in STD_LOGIC;
  Reset_n : in STD_LOGIC
);
end component Transmission;

signal Clk     : STD_LOGIC := '1';
signal Reset_n : STD_LOGIC := '0'; -- start with reset active


constant XT_Tck : Time := 100 ns;

begin

  -- DUT Instantiation
  DUT: Transmission
    port map (
      Clk     => Clk,
      Reset_n => Reset_n
    );

  clk_process : process
  begin
    while true loop
      Clk <= '1';
      wait for XT_Tck/2;
      Clk <= '0';
      wait for XT_Tck/2;
    end loop;
  end process;

  -- Reset process
  reset_process : process
  begin
    -- hold reset low for 20 ns
    Reset_n <= '0';
    wait for 150 ns;
    -- release reset
    Reset_n <= '1';

    -- Let simulation run a bit
    wait for 2 ms;

    -- Finish simulation
   
    wait;
  end process;




end TB;

