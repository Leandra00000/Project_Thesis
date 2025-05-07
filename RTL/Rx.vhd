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


Library UNISIM;
use UNISIM.vcomponents.all;



				
					

library IEEE;
use IEEE.std_logic_1164.all;
--use IEEE.numeric_std.all;
use ieee.std_logic_unsigned.all;
--use ieee.std_logic_arith.all;


use work.Spacewire_Pack.all;

entity Rx is
   port (

	Reset_n : in std_logic;
	Clk : in std_logic;
	Rx_Clk : inout std_logic;
	
	-- Main FSM interface

	State : in std_logic_vector(2 downto 0); -- if you have 6 states, 3 bits are enough
    

	-- param
	
	wd_timeout : in std_logic_vector(15 downto 0);
	signal_errorwait : in std_logic;
	
	-- Got out
	
	got_NULL_n  : out std_logic;
	got_ESC_n  : out std_logic;
	got_FCT_n   : out std_logic;
	got_EOP_n	  : out std_logic;
	got_EEP_n   : out std_logic;	
	got_NChar_n : out std_logic;
	
	-- error
	
	Error_Par_n : out std_logic;	-- Parity error
	Error_ESC_n : out std_logic;	-- ESC followed by ESC, EOP or EEP
	Error_Dis_n : out std_logic;	-- Disconnected
	
	-- Rx Fifo interface

	Rx_FIFO_D : out std_logic_vector(8 downto 0);
	Rx_FIFO_Wr_n : out std_logic;

	-- Time Code interface

	got_Time_n  : out std_logic;
	
	-- Link

	Din : in std_logic;
	Sin : in std_logic
	

			
      );

end Rx;

architecture r1 of Rx is


type T_Rx_State is (Wait_First_bit, Wait_MSB, Ctrl, Normal);

signal Rx_State : T_Rx_State;
signal Rx_Data : std_logic_vector(13 downto 0);
signal Din_Late, Sin_Late : std_logic;
signal comput_parity: std_logic;
signal Rdata_un, Fdata_un, Rdata_deux, Fdata_deux : std_logic;
signal old_Din, old_Sin : std_logic;

signal Rx_Clk_buf: std_logic;

begin

-------------------------------------------------------------------------------------------------
-- Recover clock
-------------------------------------------------------------------------------------------------

Rx_Clk_buf <= Din xor Sin;

BUFG_inst : BUFG
   port map (
      O => Rx_Clk, -- 1-bit output: Clock output.
      I => Rx_Clk_buf  -- 1-bit input: Clock input.
   );
-------------------------------------------------------------------------------------------------
-- Decode characters
-------------------------------------------------------------------------------------------------
Rising: process(State, Reset_n, Rx_Clk)

variable Previous : std_logic_vector(2 downto 0);
variable Data : std_logic_vector(15 downto 0);
variable cpt : integer range 0 to 8;
variable stamp_Data : std_logic_vector(7 downto 0);


begin

  if Reset_n = '0' --or State=ErrorReset
  then 
	
  
	-- Got out
	
	got_NULL_n <= '1';
	got_NChar_n <= '1';
	got_FCT_n <= '1';
	got_EOP_n <= '1';
	got_EEP_n <= '1';
	got_ESC_n <= '1';

	-- Time Code
	
	got_Time_n <= '1';
	
	-- error
	
	Error_ESC_n <= '1';
	Error_Par_n <= '1';

	
	-- variable
	
	Previous := "000";--C_NCHAR;
	cpt := 0;
	Data := (others => '0');
	stamp_Data := (others => '0');
	
	-- rx fifo
	
	Rx_FIFO_D <=  (others => '0');
	Rx_FIFO_Wr_n <= '1';
	
	-- signal 
		
	comput_parity <= '0';

	Rx_State <= Wait_First_Bit;
	Rx_Data  <= (others=>'0');	


  else
    if Rx_Clk='1' and Rx_Clk'event
    then
    
    --		sample bit rising edge
	
 	
    --    make paralele data for ouptut
	Rx_Data <= Rx_Data(11 downto 0) & RData_deux & Fdata_deux;--------------------------modif effect
	
			
	--	Decode data
    Data := Rx_Data(13 downto 0) & RData_deux & Fdata_deux;

    
--    view_data <= Data(3 downto 0); --for view
        
	got_FCT_n <= '1';
	got_EOP_n <= '1';
	got_EEP_n <= '1';
	got_ESC_n <= '1';
	
	got_NULL_n <= '1';
	got_Time_n <= '1';
	got_NChar_n <= '1';
	Rx_FIFO_Wr_n <= '1';
	
	case Rx_State is

	when Wait_First_Bit =>
			if Data(1 downto 0)="01"
			then Rx_State<=Ctrl;				
			end if;
			
	when Wait_MSB => 	-- Wait for first Ctrl char

			cpt:=0;
			if Data(0)='1'	
			then 		-- ctrl incoming
			 	if Data(1) /= comput_parity then error_par_n <= '0';
			    else error_par_n <= '1';
 			    end if;
				Rx_State<=Ctrl;
			else 		-- data incoming
				if (Data(1) /= (not comput_parity))	then error_par_n <= '0'; 			    
				else error_par_n <= '1';				
 			    end if;
				Rx_State<=Normal;
				comput_parity<='0';
			end if;

	when Ctrl =>	
			if Data(2 downto 0) = C_FCT
			then 
				if signal_errorwait = '1'
				then
				     if Previous = C_ESC					
				     then got_NULL_n <= '0';
				     else 
				     	got_FCT_n <= '0';
				     	Error_ESC_n <= '1';
				     end if;
				 end if;
				       			
			     comput_parity <= '0';--modify 
				 	     
			     Rx_State<=Wait_MSB;
			     Previous:=Data(2 downto 0);
			     Rx_Data<=(others=>'0');

			elsif Data(2 downto 0) = C_EOP
			then 
				 if signal_errorwait = '1'
				 then 
				 got_EOP_n <= '0';
				     
				 Rx_FIFO_D <= "100000000";
	 			 Rx_FIFO_Wr_n <= '0';	
	
	
				     if (Previous = C_ESC or (Previous =  C_EOP and State /= S_Run))
				     then Error_ESC_n <= '0';
				     else Error_ESC_n <= '1';
				     end if;
			     
			     end if;
			     
			     		     
			     comput_parity <= '1'; -- usually '1' 
			     			     
			     Rx_State <= Wait_MSB;
			     Previous := Data(2 downto 0);
			     Rx_Data <= (others=>'0');

			elsif Data(2 downto 0) = C_EEP
			then 
				 if signal_errorwait = '1'
				 then 
			     got_EEP_n <= '0';

			     	if Previous = C_ESC
			    	then Error_ESC_n <= '0';
			     	else Error_ESC_n <= '1';					
			     	end if;
			     end if;
			     
			     
			     comput_parity <= '1'; -- usually '1' 
			     			     
			     Rx_State <= Wait_MSB;
			     Previous := Data(2 downto 0);
			     Rx_Data <= (others=>'0');

			elsif Data(2 downto 0) = C_ESC
			then
				 if signal_errorwait = '1'
				 then 
			     got_ESC_n <= '0';
				
			     	if Previous = C_ESC
			    	then Error_ESC_n <= '0';					
			     	else Error_ESC_n <= '1';				
			     	end if;
			     end if;
				     
			     
			     comput_parity <= '0';
			     
			     Rx_State <= Wait_MSB;
			     Previous := Data(2 downto 0);
			     Rx_Data <= (others=>'0');
			end if; 
			
	when Normal =>
			cpt := cpt+1;
			comput_parity <= comput_parity xor (Data(0) xor Data(1));
			if cpt=4 
			then 
			    if signal_errorwait = '1'
				then 
				stamp_Data := Data(0)&Data(1)&Data(2)&Data(3)&Data(4)&Data(5)&Data(6)&Data(7);
			  	Rx_FIFO_D <='0' & stamp_Data;
			  		if Previous = C_ESC
			  		then 
			  		got_Time_n <= '0';
			  		Previous := "000";
			  		else 
			  		got_NChar_n <= '0';
			  		Rx_FIFO_Wr_n <= '0';
			  		end if;
			  	end if;
			  			  	
			Rx_State <= Wait_MSB;
			end if;
		
	when others =>
			Rx_State <= Wait_First_Bit;

	end case;

    end if;
  end if;
end process;





----------------------------------------------------------------------------
-- input on falling edge
----------------------------------------------------------------------------
FF_Fun : process(Reset_n, Rx_Clk)
begin
  if Reset_n = '0' --or State = ErrorReset
  then 
  FData_un <= '0';
  else
    if Rx_Clk = '0' and Rx_Clk 'event
    then 
    FData_un <= Din;
    end if;
  end if;
end process;




----------------------------------------------------------------------------
-- input on falling edge
----------------------------------------------------------------------------
FF_Fdeux : process(Reset_n, Rx_Clk)
begin
  if Reset_n = '0' --or State = ErrorReset
  then 
  FData_deux <= '0';
  else
    if Rx_Clk = '0' and Rx_Clk'event
    then 
    FData_deux <= FData_un;
    end if;
  end if;
end process;

----------------------------------------------------------------------------
-- input on rasing edge
----------------------------------------------------------------------------
FF_Run : process(Reset_n, Rx_Clk)
begin
  if Reset_n = '0' --or State = ErrorReset
  then 
  RData_un <= '0';
  else
    if Rx_Clk = '1' and Rx_Clk 'event
    then  
    RData_un <= Din;
    end if;
  end if;
end process;


----------------------------------------------------------------------------
-- input on rasing edge
----------------------------------------------------------------------------
FF_Rdeux : process(Reset_n, Rx_Clk)
begin
  if Reset_n = '0' --or State = ErrorReset
  then 
  RData_deux <= '0';
  else
    if Rx_Clk='1' and Rx_Clk'event
    then  
    RData_deux <= RData_un;
    end if;
  end if;
end process;


-------------------------------------------------------------------------------------------------
-- Disconnection watch-dog
-------------------------------------------------------------------------------------------------

Disconnection_Detect: process(Reset_n, Clk)
variable WD_Cpt :  std_logic_vector(15 downto 0);
begin
  if Reset_n = '0' --or State=ErrorReset
  then 
	Error_Dis_n <= '1';
	WD_Cpt := (others => '0');
	Din_Late <= '0';
	Sin_Late <= '0';
	
  else
    if Clk='1' and Clk'event
    then 
	Din_Late<=old_Din;
	Sin_Late<=old_Sin;
		if Rx_State /= Wait_First_Bit
		then
			if WD_Cpt = wd_timeout
			then 	
			Error_Dis_n <= '0';
			else 	
			Error_Dis_n <= '1';
				if Din_Late/=old_Din or Sin_Late/=old_Sin
				then 
				WD_Cpt := (others => '0');
				else 
				WD_Cpt := WD_Cpt + 1;
				end if;
			end if;
		end if;
    end if;
  end if;
end process;

----------------------------------------------------------------------------
-- resynchro din on clk
----------------------------------------------------------------------------

process(Reset_n, Clk)
begin
if Reset_n = '0' --or State = ErrorReset
then 
old_Din <= '0';
else
    if Clk='1' and Clk'event
    then 
	old_Din <= Din;
	
    end if;
	
end if;
end process;

----------------------------------------------------------------------------
-- resynchro sin on clk
----------------------------------------------------------------------------

process(Reset_n, Clk)
begin
if Reset_n = '0' --or State = ErrorReset
then 
old_Sin <= '0';
else
    if Clk='1' and Clk'event
    then 
	old_Sin <= Sin;
	
    end if;
	
end if;
end process;


end r1;