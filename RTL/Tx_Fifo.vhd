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
--	03/04/2009
--	B.Bertrand
--	inout signal is removed
--	LENGTH set wide for deep.
--	First data is present " on out put before first read
----------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.spacewire_Pack.all;

entity Tx_Fifo is

	generic(
		WIDTH : integer; --:= 8;
		LENGTH : integer; --:= 128;
		MAX_CREDIT : integer --:= 7*8 
	);
	port(
		Reset_n : in std_logic;
		Clk : in std_logic;
		State : in std_logic_vector(2 downto 0);

		-- Credit

		fct_n : in std_logic;     -- allow 7 reads in the fifo
		short_send_eop_rising : in std_logic;
		fct_Full_n : out std_logic;  -- true when all the FIFO has been allowed to be read
		Credit_Empty_n : out std_logic;
		
		-- Data Input

		Din : in std_logic_vector(WIDTH-1 downto 0);
		Wr_n : in std_logic;
		Full_n : out std_logic;

		-- Data Output

		Dout : out std_logic_vector(WIDTH-1 downto 0);
		Rd_n : in std_logic;
		Empty_n : out std_logic;
		
		Credit : out std_logic_vector(31 downto 0)

	);
end entity;

architecture T1 of Tx_Fifo is

type Ram is array (integer range <>) of std_logic_vector(WIDTH-1  downto 0);
signal Data : Ram(0 to LENGTH-1 );  -- Local data
signal Rd_Ptr : integer range 0 TO LENGTH-1;
signal Wr_Ptr : integer range 0 TO LENGTH-1;
signal Cpt : integer range 0 to LENGTH;
signal Credit_signal : integer;

begin

manager:	process(State, reset_n, Clk)
variable Credit_Temp : integer range 0 to MAX_CREDIT;
begin
  if Reset_n = '0' or State = S_ErrorReset
  then
	Dout <= (others=>'0');
	Rd_Ptr <= 0;
	Wr_Ptr <= 0;
	Credit <= (others=>'0');--modify
	Credit_signal <= 0;--modify
	Credit_Temp := 0;
	Cpt <= 0;
	fct_full_n <= '1';

  else
    if falling_edge(clk)
    then

	Credit_Temp := Credit_signal;
	
	if short_send_eop_rising = '0'
	then
	Credit_Temp := Credit_Temp + 1;
	end if;
	
	if fct_n='0' and Credit_signal <= MAX_CREDIT - 8  and ( State = S_Connecting or State = S_Run ) 
	then
	Credit_Temp := Credit_Temp + 8;
	else
		if (fct_n = '0' and  (State = S_Run or State = S_connecting)) and (Credit_signal >= MAX_CREDIT)  then fct_full_n <= '0'; 
		end if;
	end if;

	if Rd_n = '0' and Cpt /= 0  and State = S_Run and Credit_signal /= 0 
	then 
	Credit_Temp := Credit_Temp - 1;
	Dout <= Data(Rd_Ptr);
    Rd_Ptr <= ( Rd_Ptr + 1 ) mod LENGTH;      
		if Wr_n = '1'
        then  --	change Cpt when read and not write.
	  	Cpt <= Cpt - 1; 
	  	end if; 
	end if;

	if Wr_n = '0' and Cpt /= LENGTH  and State = S_Run
	then	
	Data(Wr_Ptr) <= Din;
	Wr_Ptr <= ( Wr_Ptr + 1 ) mod LENGTH;	  
		if Rd_n = '1' 
		then --	change Cpt when write and not read.
		Cpt <= Cpt + 1; 
	 	end if; 	  		
	end if;

	Credit <= std_logic_vector(to_unsigned(Credit_Temp, Credit'length));
	Credit_signal <= Credit_Temp;

    end if;
  end if;
end process;

Empty_n <= '0' when Cpt=0 else '1';
Full_n  <= '0' when ( Cpt = LENGTH and State = S_run ) or State = S_Connecting or State = S_ErrorReset or State = S_ErrorWait or State = S_Ready or State = S_Started   else '1';
Credit_Empty_n <= '0' when Credit_signal = 0 else '1';

end T1;

