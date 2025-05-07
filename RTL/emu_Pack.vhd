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

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use std.textio.all;

use work.spacewire_Pack.all;
---------------------------------------------------------------
--
-- PACKAGE
--
---------------------------------------------------------------
package emu_Pack is
       
-- state for Body Procedure write file of rx emu

type state is (char_or_ctrl ,char ,ctrl ,time_or_null ,c_null ,time_id ,time_out );
 
----------------------------------------------------------------
--Procedure write file for out of RX ip simbolx
----------------------------------------------------------------
procedure write_file_rxip(
				file out_file_rx_ip :  text;
				got_NULL : in std_logic;
				got_FCT : in std_logic;
				got_ESC : in std_logic;
				got_EOP : in std_logic;
				got_EEP : in std_logic;
				got_NChar : in std_logic;
				got_Time : in std_logic;
				Error_Par : in std_logic;
				Error_ESC : in std_logic;
				Error_Dis : in std_logic;
				Error_NChar : in std_logic;
				Error_FCT : in std_logic;																				
				Time_Code : in std_logic_vector(7 downto 0);
				Rx_FIFO_D : in std_logic_vector(7 downto 0);
				code : inout string (1 to 8);
				data : inout integer);

 
----------------------------------------------------------------
--Procedure read file for input TX ip simbolx
----------------------------------------------------------------	
			
procedure readfile_tx_spwr(
			file com_fich :  text;
			state : inout std_logic_vector(2 downto 0);
			std_data : out std_logic_vector(7 downto 0);
			v_Tx_FIFO_Empty_n : inout std_logic;
			v_Rx_FIFO_Credit_Empty_n  : inout std_logic;
			v_Tx_Send_Time   : inout std_logic;
			err_parity_tx : out std_logic;
			end_com_fich : out std_logic);			             

-- component			
						
component emu_spwr 
port (
	--global
		
    reset : in std_logic;
    clk         : in     std_logic;
    
    --in
    
    Din : in std_logic;
    Sin : in std_logic;
    
    --out
    
    Dout : inout std_logic;
    Sout : inout std_logic;
    
    --for close out file
    end_com_fich : inout std_logic
    );
end component;

end emu_Pack;
---------------------------------------------------------------
--
-- BODY PACKAGE
--
---------------------------------------------------------------
package body emu_Pack is
----------------------------------------------------------------
--Body Procedure write file for out of RX ip simbolx
----------------------------------------------------------------
procedure write_file_rxip(
				file out_file_rx_ip :  text;
				got_NULL : in std_logic;
				got_FCT : in std_logic;
				got_ESC : in std_logic;
				got_EOP : in std_logic;
				got_EEP : in std_logic;
				got_NChar : in std_logic;
				got_Time : in std_logic;
				Error_Par : in std_logic;
				Error_ESC : in std_logic;
				Error_Dis : in std_logic;
				Error_NChar : in std_logic;
				Error_FCT : in std_logic;																
				Time_Code : in std_logic_vector(7 downto 0);
				Rx_FIFO_D : in std_logic_vector(7 downto 0);
				code : inout string (1 to 8);
				data : inout integer) is		
				
variable l : line;
variable tab : string(1 to 5) ;

begin

if got_null = '1'
then -- null occur in RX ip --------------------
	if code /= "ESC-----" and code /= "ESC----E" 
	then
	write(l,code);
	tab := "     ";
	write(l,tab);
	write(l,data);
	writeline(out_file_rx_ip,l);
		if Error_Par = '0' then code := "NULL----";
		else code := "NULL---E";
		end if;
	data := 0;
	else
		if Error_Par = '0' then code := "NULL----";
		else code := "NULL---E";
		end if;
	data := 0;
	end if;
else
	if got_fct = '1' 
	then	-- fct occur in Rx ip------------------------
	write(l,code);
	tab := "     ";
	write(l,tab);
	write(l,data);
	writeline(out_file_rx_ip,l);	
		if Error_Par = '0' then code := "FCT-----";
		else code := "FCT----E";
		end if;
	data := 0;
	else
		if got_NChar = '1' 
		then   -- char occur in Rx ip----------------------
			write(l,code);
			tab := "     ";
			write(l,tab);
			write(l,data);
			writeline(out_file_rx_ip,l);
				if Error_Par = '0' then code := "DATA_ID-";
				else code := "DATA_IDE";
				end if;
			data := conv_integer(Rx_FIFO_D);
		else
			if got_Time = '1'
			then  -- time occur in RX ip ------------------
				if code /= "ESC-----" and code /= "ESC----E" 
				then
				 	write(l,code);
				 	tab := "     ";
				 	write(l,tab);
				 	write(l,data);
				 	writeline(out_file_rx_ip,l);
				 		if Error_Par = '0' then code := "TIME_ID-";
						else code := "TIME_IDE";
						end if;
				 	data := conv_integer(Rx_FIFO_D);
				else
				 		if Error_Par = '0' then code := "TIME_ID-";
						else code := "TIME_IDE";
						end if;
				 	data := conv_integer(Rx_FIFO_D);
				end if;
			else
				if Error_ESC = '1' 
				then -- error esc occur in RX Ip -------------					
					write(l,code);
					tab := "     ";
					write(l,tab);
					write(l,data);
					writeline(out_file_rx_ip,l);
					code := "ERR-ESC-";
					data := 0;
				else
					if Error_Dis = '1' 
					then -- error_dis occur in Rx Ip -----------
						write(l,code);
						tab := "     ";
						write(l,tab);
						write(l,data);
						writeline(out_file_rx_ip,l);						
						code := "ERR-DISC";
						data := 0;
					else
						if Error_NChar = '1'
						then -- error in char occur in Rx ip --						
							write(l,code);
							tab := "     ";
							write(l,tab);
							write(l,data);
							writeline(out_file_rx_ip,l);							
							code := "ERRNCHAR";
							data := 0;
						else
							if Error_FCT = '1'  
							then -- error fct occur in Rx ip --								
								write(l,code);
								tab := "     ";
								write(l,tab);
								write(l,data);
								writeline(out_file_rx_ip,l);								
								code := "ERR-FCT-";
								data := 0;
							else
								if got_esc = '1' 
								then	  -- esc occur in Rx Ip -------------------
									write(l,code);
									tab := "     ";
									write(l,tab);
									write(l,data);
									writeline(out_file_rx_ip,l);
										if Error_Par = '0' then code := "ESC-----";
										else code := "ESC----E";
										end if;									
									data := 0;
								else
									if got_eop = '1'  
									then -- eop occur in Rx Ip ----------------------										
										write(l,code);
										tab := "     ";
										write(l,tab);
										write(l,data);
										writeline(out_file_rx_ip,l);										
											if Error_Par = '0' then code := "EOP-----";
											else code := "EOP----E";
											end if;
										data := 0;
									else
										if got_eep = '1'  
										then -- eep occur in Rx Ip -----------------------											
											write(l,code);
											tab := "     ";
											write(l,tab);
											write(l,data);
											writeline(out_file_rx_ip,l);										
												if Error_Par = '0' then code := "EEP-----";
												else code := "EEP----E";
												end if;
											data := 0;
										end if;
									end if;
								end if;		
							end if;
						end if;
					end if;
				end if;
			end if;
		end if;
	end if;
end if;
end write_file_rxip; 				  

----------------------------------------------------------------
--Body Procedure read file for input TX ip simbolx
----------------------------------------------------------------	

procedure readfile_tx_spwr(
			file com_fich :  text;
			state : inout std_logic_vector(2 downto 0);
			std_data : out std_logic_vector(7 downto 0);
			v_Tx_FIFO_Empty_n : inout std_logic;
			v_Rx_FIFO_Credit_Empty_n  : inout std_logic;
			v_Tx_Send_Time   : inout std_logic;
			err_parity_tx : out std_logic;
			end_com_fich : out std_logic) is
			
variable l : line;
variable data_input : integer; 
variable code : string(1 to 8);
--variable err_parity : std_logic ;

			
begin
err_parity_tx := '0';
if not endfile(com_fich)
then  
end_com_fich := '0';
readline(com_fich,l );
read(l ,code);
read(l ,data_input);
	if code="NULL----"
	then --  read null remote for Tx Ip simbolx
	state := S_started;
	v_Tx_FIFO_Empty_n := '0'; 
	v_Rx_FIFO_Credit_Empty_n := '0';  
	v_Tx_Send_Time :=  '0';
	err_parity_tx := '0';	
	else
		if code="NULL---E"
		then -- read null and error parity remote for Tx Ip simbolx
		state := S_started;
		v_Tx_FIFO_Empty_n := '0'; 
		v_Rx_FIFO_Credit_Empty_n := '0';  
		v_Tx_Send_Time :=  '0';
		err_parity_tx := '1';	
		else 
			if	code="FCT-----"
			then --  read fct remote for Tx Ip simbolx
			state := S_run;
			v_Tx_FIFO_Empty_n := '0'; 
			v_Rx_FIFO_Credit_Empty_n := '1';  
			v_Tx_Send_Time :=  '0';
			err_parity_tx := '0';	
			else
				if	code="FCT----E"
				then -- read fct and error parity remote for Tx Ip simbolx
				state := S_run;
				v_Tx_FIFO_Empty_n := '0'; 
				v_Rx_FIFO_Credit_Empty_n := '1';  
				v_Tx_Send_Time :=  '0';
				err_parity_tx := '1';	
				else
					if code="TIME_ID-"
					then --  read time remote for Tx Ip simbolx
					state := S_Run;
					v_Tx_FIFO_Empty_n := '0'; 
					v_Rx_FIFO_Credit_Empty_n := '0';  
					v_Tx_Send_Time :=  '1';
					std_data := conv_std_logic_vector(data_input,8);
					err_parity_tx := '0';	
					else
						if code="TIME_IDE"
						then -- read time and  error parity remote for Tx Ip simbolx
						state := S_Run;
						v_Tx_FIFO_Empty_n := '0'; 
						v_Rx_FIFO_Credit_Empty_n := '0';  
						v_Tx_Send_Time :=  '1';
						std_data := conv_std_logic_vector(data_input,8);
						err_parity_tx := '1';	
						else 
							if code="DATA_ID-"
							then --  read data remote for Tx Ip simbolx
							state := S_started;
							std_data := conv_std_logic_vector(data_input,8);
							v_Tx_FIFO_Empty_n := '1'; 
							v_Rx_FIFO_Credit_Empty_n := '0';  
							v_Tx_Send_Time :=  '0';
							std_data := conv_std_logic_vector(data_input,8);
							err_parity_tx := '0';	
							else
								if 	code="DATA_IDE"
								then -- read data and error parity remote for Tx Ip simbolx
								state := S_started;
								std_data := conv_std_logic_vector(data_input,8);
								v_Tx_FIFO_Empty_n := '1'; 
								v_Rx_FIFO_Credit_Empty_n := '0';  
								v_Tx_Send_Time :=  '0';
								std_data := conv_std_logic_vector(data_input,8);
								err_parity_tx := '1';	
				 				end if;
			 				end if;
			 			end if;
					end if;
				end if;				
			end if;	 
		end if;
	end if;
else
end_com_fich := '1';
end if;
end readfile_tx_spwr;
  
end emu_Pack;