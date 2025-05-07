--
-- Copyright CESR CNRS 
-- 	      9 avenue du Colonel Roche
-- 	      31028 Toulouse Cedex 4
--
-- Contributor(s) : 
--
--  - Bernard Bertrand 
--    
--
-- This software is a computer program whose purpose is to implement a spacewire 
-- link according to the ECSS-E-50-12A.
--
-- This software is governed by the CeCILL-C license under French law and
-- abiding by the rules of distribution of free software.  You can  use, 
-- modify and/ or redistribute the software under the terms of the CeCILL-C
-- license as circulated by CEA, CNRS and INRIA at the following URL
-- "http://www.cecill.info". 
--
-- As a counterpart to the access to the source code and  rights to copy,
-- modify and redistribute granted by the license, users are provided only
-- with a limited warranty  and the software's author,  the holder of the
-- economic rights,  and the successive licensors  have only  limited
-- liability. 
--
-- In this respect, the user's attention is drawn to the risks associated
-- with loading,  using,  modifying and/or developing or reproducing the
-- software by the user in light of its specific status of free software,
-- that may mean  that it is complicated to manipulate,  and  that  also
-- therefore means  that it is reserved for developers  and  experienced
-- professionals having in-depth computer knowledge. Users are therefore
-- encouraged to load and test the software's suitability as regards their
-- requirements in conditions enabling the security of their systems and/or 
-- data to be ensured and,  more generally, to use and operate it in the 
-- same conditions as regards security. 
--
-- The fact that you are presently reading this means that you have had
-- knowledge of the CeCILL-C license and that you accept its terms.
--

library IEEE;
use IEEE.std_logic_1164.all ;
use IEEE.std_logic_unsigned.all;

use work.Spacewire_Pack.all;

entity twodomainclock is
	generic( N_short_to_width : integer;
			use_short_to_width : integer;
			N_width_to_short : integer;
			use_width_to_short : integer;
			N_short_to_width_n : integer;
			use_short_to_width_n : integer;
			N_width_to_short_n : integer;
			use_width_to_short_n : integer
			); 
    port (
	Rst : in std_logic;
	Clk_speed : in std_logic;
	
	in_short_pulse : in std_logic_vector(N_short_to_width - 1 downto 0);
	in_width_pulse : in std_logic_vector(N_width_to_short - 1 downto 0);
	
	out_width_pulse : inout std_logic_vector(N_short_to_width - 1 downto 0);
	out_short_pulse : out std_logic_vector(N_width_to_short - 1 downto 0);
	
	in_short_pulse_n	: in std_logic_vector(N_short_to_width_n - 1 downto 0);
	in_width_pulse_n : in std_logic_vector(N_width_to_short_n - 1 downto 0);
	
	out_width_pulse_n : inout std_logic_vector(N_short_to_width_n - 1 downto 0);
	out_short_pulse_n : out std_logic_vector(N_width_to_short_n - 1 downto 0)
    );
end twodomainclock;


architecture RTL of twodomainclock is

begin

-- ----------------------------------------------------------------------------------------------
-- --
-- -- generate signal short to width NO USE CURRENTLY
-- --
-- ----------------------------------------------------------------------------------------------

-- label_use_short_to_width : if use_short_to_width = 1 generate
-- 	label_short_to_width : for i in 0 to (N_short_to_width - 1) generate
-- 	shorttowidth : entity work.short_to_width(RTL)
-- 		port map(
-- 		Rst => Rst,
-- 		Clk_speed => Clk_speed,
-- 		Clk_slow => Clk_slow,
-- 		in_short_pulse => in_short_pulse(i),
-- 		out_width_pulse => out_width_pulse(i)
-- 		);
-- 	end generate;
-- end generate;

label_NO_use_short_to_width : if use_short_to_width = 0 generate
	out_width_pulse <= (others => '0');
end generate;
	

-- ----------------------------------------------------------------------------------------------
-- --
-- -- generate signal width to short NO USE CURRENTLY 
-- --
-- ----------------------------------------------------------------------------------------------

-- label_use_width_to_short : if use_width_to_short = 1 generate
-- 	label_width_to_short : for i in 0 to (N_width_to_short - 1) generate
-- 	widthtoshort : entity work.width_to_short(RTL)
-- 		port map(
-- 		Rst => Rst,
-- 		Clk_speed => Clk_speed,
-- 		Clk_slow => Clk_slow,
-- 		in_width_pulse => in_width_pulse(i),
-- 		out_short_pulse => out_short_pulse(i)
-- 		);
-- 	end generate;
-- end generate;

label_NO_use_width_to_short : if use_width_to_short = 0 generate
	out_short_pulse <= (others => '0');
end generate;



-- -- ----------------------------------------------------------------------------------------------
-- -- --
-- -- -- generate signal_n short to width NO USE CURRENTLY
-- -- --
-- -- ----------------------------------------------------------------------------------------------

-- label_use_short_to_width_n : if use_short_to_width_n = 1 generate
-- 	label_short_to_width_n : for i in 0 to (N_short_to_width_n - 1) generate
-- 	shorttowidth_n : entity work.short_to_width_n(RTL)
-- 		port map(
-- 		Rst => Rst,
-- 		Clk_speed => Clk_speed,
-- 		Clk_slow => Clk_slow,
-- 		in_short_pulse_n => in_short_pulse_n(i),
-- 		out_width_pulse_n => out_width_pulse_n(i)
-- 		);
-- 	end generate;
-- end generate;

label_NO_use_short_to_width_n : if use_short_to_width_n = 0 generate
	out_width_pulse_n <= (others => '0');
end generate;

-- ----------------------------------------------------------------------------------------------
-- --
-- -- generate signal_n width to short 
-- --
-- ----------------------------------------------------------------------------------------------

label_use_width_to_short_n : if use_width_to_short_n = 1 generate
	label_width_to_short_n : for i in 0 to (N_width_to_short_n - 1) generate
	widthtoshort_n : entity work.width_to_short_n(RTL)
		port map(
		Rst => Rst,
		Clk_speed => Clk_speed,
		in_width_pulse_n => in_width_pulse_n(i),
		out_short_pulse_n => out_short_pulse_n(i)
		);
	end generate;
end generate;

label_NO_use_width_to_short_n : if use_width_to_short_n = 0 generate
	out_short_pulse_n <= (others => '0');
end generate;

end RTL;