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

entity width_to_short_n is
	
    port (
	Rst : in std_logic;
	Clk_speed : in std_logic;
	
	in_width_pulse_n : in std_logic;
	
	out_short_pulse_n : out std_logic
	
    );
end width_to_short_n;

architecture RTL of width_to_short_n is

signal old1_width_pulse_n : std_logic;
signal old_width_pulse_n : std_logic;

begin

process(Rst, Clk_speed)
begin
if Rst = '0'
then
old1_width_pulse_n <= '1';
else
	if Clk_speed = '1' and Clk_speed 'event
	then
	old1_width_pulse_n <= in_width_pulse_n;
	end if;
end if;
end process;

process(Rst, Clk_speed)
begin
if Rst = '0'
then
old_width_pulse_n <= '1';
else
	if Clk_speed = '1' and Clk_speed 'event
	then
	old_width_pulse_n <= old1_width_pulse_n;
	end if;
end if;
end process;

out_short_pulse_n <= not(not old1_width_pulse_n and (old_width_pulse_n));

end RTL;