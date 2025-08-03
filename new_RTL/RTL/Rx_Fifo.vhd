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

----------------------------------------------------------------------------------------
--	B.Bertrand
--	03/04/2009
--	inout signal is removed
--	LENGTH set wide for deep.
--	First data is present on output before first read
----------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.Spacewire_Pack.all;

entity Rx_Fifo is

	generic(
		WIDTH : integer; --:= 8;
		LENGTH : integer; --:= 128;
		MAX_CREDIT : integer --:= 7*8 
	);
	port(
		Reset_n : in std_logic;
		Clk : in std_logic;  -----CLK_n
		State : in std_logic_vector(2 downto 0);

		-- Credit

		Credit_Rd_n : in std_logic;     -- allow 8 writes in the fifo
		Credit_Empty_n : out std_logic;  -- true when all the FIFO has been allowed to be written
		credit_error_n : out std_logic;

		-- Data Input

		Din : in std_logic_vector(WIDTH-1 downto 0);
		Wr_n : in std_logic;
		Full_n : out std_logic;
		short_got_EOP_n : in std_logic;

		-- Data Output

		Dout : out std_logic_vector(WIDTH-1 downto 0);
		Rd_n : in std_logic;
		Empty_n : out std_logic;
		
		Credit : out std_logic_vector(31 downto 0)

	);
end entity;

architecture R1 of Rx_Fifo is

type Ram is array (integer range <>) of std_logic_vector(WIDTH-1  downto 0);
signal Data : Ram(0 to LENGTH-1 );  -- Local data
signal Rd_Ptr : integer range 0 TO LENGTH-1;
signal Wr_Ptr : integer range 0 TO LENGTH-1;
signal Cpt : integer range 0 to LENGTH;
signal stp_Empty_n : std_logic;
signal data_writed : std_logic;
signal Credit_signal : integer range 0 to MAX_CREDIT;

begin

manager:	process(State, reset_n, Clk)
variable Credit_Temp : integer range 0 to MAX_CREDIT;
begin
  if Reset_n = '0' or State = S_ErrorReset
  then
  	Dout <= (others=>'0');
	Rd_Ptr <= 0;
	Wr_Ptr <= 0;
	Credit <= (others=>'0');
	Credit_signal <= 0;
	Credit_Temp:=0;
	Cpt <= 0;
	credit_error_n <= '1';
	Empty_n <= '0';
	data_writed <= '0';
	
  else
	if falling_edge(clk)
	then

	Credit_Temp := Credit_signal;

	if  Credit_signal <= MAX_CREDIT - 8 and ( State = S_Connecting or State = S_Run ) and Credit_Rd_n = '0'
	then 
		Credit_Temp := Credit_Temp + 8;
 	end if;

	if Rd_n='0' and Cpt/=0 
	then 
	
		Dout <= Data(Rd_Ptr);	
        Rd_Ptr <= ( Rd_Ptr + 1 ) mod LENGTH;
        
        if Wr_n = '1'
        then  Cpt <= Cpt - 1;
	  	end if;
	  	
	  	
	end if;

	if Wr_n='0' and Credit_signal = 0 and short_got_EOP_n = '1' and ((State = S_Run) or (State = S_Connecting) or (State = S_Started)) 
	then
	credit_error_n <= '0';
	end if;
	
	if Wr_n='0' and Cpt/=LENGTH and Credit_signal /= 0 and State=S_Run
	then
				
		Data(Wr_Ptr) <= Din;
		Wr_Ptr <= ( Wr_Ptr + 1 ) mod LENGTH;
		
		if Rd_n = '1'
	  	then Cpt <= Cpt + 1;
	  	end if;
	  	
	  	if short_got_EOP_n = '1'
	  	then 
		Credit_Temp := Credit_Temp - 1;
		data_writed <= '1';
--		else
--			if short_got_EOP_n = '0' and data_writed = '1'
--			then
--			data_writed <= '0';
--			else
--				if short_got_EOP_n = '0' and data_writed = '0'
--				then
--				Credit_Temp := Credit_Temp - 1;
--				end if;
--			end if;
	  	end if;
	  	
	end if;
		
	Empty_n <= stp_Empty_n;
	Credit <= std_logic_vector(to_unsigned(Credit_Temp, Credit'length));

	Credit_signal <= Credit_Temp;
	
    end if;
  end if;
end process;

Credit_Empty_n <= '0' when (Credit_signal > MAX_CREDIT - 8) and ( State = S_Connecting or State = S_Run )  else '1';
stp_Empty_n <= '0' when Cpt = 0 else '1';
Full_n  <= '0' when Cpt = LENGTH and (State = S_run  or State = S_Connecting or State = S_ErrorReset or State = S_ErrorWait or State = S_Ready or State = S_Started)  else '1';



end R1;

