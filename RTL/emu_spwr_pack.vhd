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
use ieee.std_logic_textio.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use std.textio.all;
use work.emu_Pack.all;
---------------------------------------------------------------
--
-- PACKAGE
--
---------------------------------------------------------------
package emu_spwr_pack is

-- 

constant C_FCT	:	std_logic_vector(2 downto 0)	:= "100";
constant C_EOP	:	std_logic_vector(2 downto 0)	:= "101";
constant C_EEP	:	std_logic_vector(2 downto 0)	:= "110";
constant C_ESC	:	std_logic_vector(2 downto 0)	:=	"111";
constant C_TIME	:	std_logic_vector(1 downto 0)	:=	"10";

----------------------------------------------------------------
--Procedure read file for tx emu
----------------------------------------------------------------
procedure readfile(
			file com_fich :  text;
			Num  : out integer;
			std_data : out std_logic_vector(7 downto 0);
			err_parity : inout std_logic;
			v_end_com_fich : out std_logic);
			
----------------------------------------------------------------
--Procedure write file for rx emu
----------------------------------------------------------------
procedure writefile(
			file out_file : text;	
			current_state : inout state;
    	    data_input :inout std_logic_vector(1 downto 0);
			count_write : inout integer;
			stamp : inout std_logic_vector(7 downto 0);
			rx_emu_comput_parity : inout std_logic;
			code :inout string(1 to 8);
			data : inout integer;
			error_parity : inout std_logic);
			
end emu_spwr_pack;

---------------------------------------------------------------
--
-- BODY PACKAGE
--
---------------------------------------------------------------

package body emu_spwr_pack is
----------------------------------------------------------------
--Body Procedure Procedure read file for tx emu
----------------------------------------------------------------
procedure readfile(	
			file com_fich :  text;
    	    Num : out integer;
    	    std_data : out std_logic_vector(7 downto 0);
    	    err_parity : inout std_logic;
    	    v_end_com_fich : out std_logic) is	
    	    	
variable l : line;
variable data_input : integer; 
variable code : string(1 to 8); 


begin
if not endfile(com_fich)
then
v_end_com_fich := '0';
readline(com_fich,l );
read(l ,code);
read(l ,data_input);
	if code="NULL----"
	then
	Num  := 1;
	err_parity := '0';
	else
		if	code="FCT-----"
		then
		Num  := 2;
		err_parity := '0';
		else
			if code="TIME_ID-"
			then
			Num  := 3;
			std_data := conv_std_logic_vector(data_input,8);
			err_parity := '0';
			else
				if code="DATA_ID-"
				then
				Num  := 4;
				std_data := conv_std_logic_vector(data_input,8);	
				err_parity := '0';		
				else
					if code="WAIT----"
					then
					Num  := 5;
					std_data := conv_std_logic_vector(data_input,8);
					err_parity := '0';			
					else
						if code="ESC-----"
						then
						Num  := 6;
						err_parity := '0';
						else						
							if code="EOP-----"
							then
							Num  := 7;
							err_parity := '0';
							else
								if code="EEP-----"
								then
								Num  := 8;
								err_parity := '0';
								else
									if code = "DATA_IDE"
									then
									Num  := 4;
									std_data := conv_std_logic_vector(data_input,8);
									err_parity := '1';
									else
										if code = "FCT----E"
										then
										Num  := 2;
										err_parity := '1';
										else
											if code="NULL---E"
											then
											Num  := 1;
											err_parity := '1';
											else
												if code="TIME_IDE"
												then
												Num  := 3;
												std_data := conv_std_logic_vector(data_input,8);
												err_parity := '1';
												else
													if code="ESC----E"
													then
													Num  := 6;
													err_parity := '1';
													else
														if code="EOP----E"
														then
														Num  := 7;
														err_parity := '1';
														else
															if code="EEP----E"
															then
															Num  := 8;
															err_parity := '1';
															else
																if code="CYCLE---"
																then
																Num  := 9;
																err_parity := '0';
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
					end if;
				end if;
			end if;				
		end if;	 
	end if;
else
v_end_com_fich := '1';
end if;	
end readfile;

----------------------------------------------------------------
--Body Procedure write file for rx emu
----------------------------------------------------------------

procedure writefile(
			file out_file : text;
			current_state : inout state;		
    	    data_input :inout std_logic_vector(1 downto 0);
			count_write : inout integer;
			stamp : inout std_logic_vector(7 downto 0);
			rx_emu_comput_parity: inout std_logic;
			code :inout string(1 to 8);
			data : inout integer;
			error_parity : inout std_logic) is			

variable l : line;
variable tab : string(1 to 5) ;
variable std_stamp : std_logic_vector(7 downto 0);

begin
case Current_state is
			when char_or_ctrl		=>	------------------- search char or ctrl 							    
											if data_input(0) = '0' 
											then 						-- char is detected
											Current_state := char;
											error_parity := '0';
												if not rx_emu_comput_parity /= data_input(1) 
												then
												error_parity := '1';												
												end if; 
											rx_emu_comput_parity := '0'; 
											else 						-- ctrl is detected
											Current_state := ctrl;
											error_parity := '0';
												if rx_emu_comput_parity /= data_input(1) 
												then
												error_parity := '1';												
												end if;  
											end if;
																	
			when char =>		-------------------- build char	 							 								
	 							stamp(7 downto 2) := stamp(5 downto 0);
	 							stamp(1 downto 0) := data_input;
	 							count_write := count_write + 1;
	 							rx_emu_comput_parity := rx_emu_comput_parity xor data_input(0) xor data_input(1); 
	 								if count_write = 4
	 								then 				-- char is made				
										write(l,code);
										tab := "     ";
										write(l,tab);
										write(l,data);
										writeline(out_file,l);										
										std_stamp(7 downto 0) := stamp(0) & stamp(1) & stamp(2) & stamp(3) 
										& stamp(4) & stamp(5) & stamp(6) & stamp(7);										
											if error_parity = '0' then 	 code := "DATA_ID-";
											else code := "DATA_IDE";
											end if;											
		 							 	data := conv_integer(std_stamp);
	 									current_state := char_or_ctrl;
	 									stamp := (others => '0');
	 									count_write := 0;
	 								end if;			
			
			when ctrl =>		------------------- search which control char 
								if data_input= "00"
								then					-- fct detected							
									write(l,code);
									tab := "     ";
									write(l,tab);
									write(l,data);
									writeline(out_file,l);
 										if error_parity = '0' then 	 code := "FCT-----";
										else code := "FCT----E";
										end if;
 									data := 0;
 									rx_emu_comput_parity := '0';
 									current_state := char_or_ctrl;
 								else
 									if data_input= "01"
									then				-- eop detected								
										write(l,code);
										tab := "     ";
										write(l,tab);
										write(l,data);
										writeline(out_file,l);
	 										if error_parity = '0' then 	 code := "EOP-----";
											else code := "EOP----E";
											end if;
	 									data := 0;
	 									rx_emu_comput_parity := '1';
	 									current_state := char_or_ctrl;
	 								else
	 									if data_input= "10"
										then			-- eep detected									
											write(l,code);
											tab := "     ";
											write(l,tab);
											write(l,data);
											writeline(out_file,l);
		 										if error_parity = '0' then 	 code := "EEP-----";
												else code := "EEP----E";
												end if;
		 									data := 0;
		 									rx_emu_comput_parity := '1';
		 									current_state := char_or_ctrl;
		 								else
		 									if data_input= "11"
											then		-- esc detected got to search time or null											
												write(l,code);
												tab := "     ";
												write(l,tab);
												write(l,data);
												writeline(out_file,l);		 									
		 											if error_parity = '0' then 	 code := "ESC-----";
													else code := "ESC----E";
													end if;
		 										data := 0;
		 										rx_emu_comput_parity := '0';
		 										current_state := time_or_null;
		 									end if;
		 								end if;
		 							end if;
 								end if;
							
			when time_or_null =>		-------------- search time or null or error escape
								if data_input(0) = '1' 
								then		-- go to search null
								current_state := c_null;
								else
									if data_input= "10"
									then	-- go to search time_id
									current_state := time_id;
									else
	 				 					write(l,code);
										tab := "     ";
										write(l,tab);
										write(l,data);
										writeline(out_file,l);	  									
	  									code := "ERR-ESC1";
	  									data := 0;
	  									current_state := char_or_ctrl;
	 								end if;
	 							end if;
	 						
 			when c_null	=>				------------ treat null or error escape 							
	 							if data_input = "00"
	 							then		-- null detected
	 								if code /= "ESC-----" and  code /= "ESC----E"
	 								then -- no escape detected before null 
						 				write(l,code);
										tab := "     ";
										write(l,tab);
										write(l,data);
										writeline(out_file,l);		 							
		 									if error_parity = '0' then 	 code := "NULL----";
											else code := "NULL---E";
											end if;
		 								data := 0;
		 							else -- escape detected before null 
	 									if error_parity = '0' then 	 code := "NULL----";
										else code := "NULL---E";
										end if;
		 								data := 0;
		 							end if;
	 								rx_emu_comput_parity := '0';
	 								current_state := char_or_ctrl;
	 							else		-- err-esc detected 								
					 				write(l,code);
									tab := "     ";
									write(l,tab);
									write(l,data);
									writeline(out_file,l);	 								
	 								code := "ERR-ESC2";
	 								data := 0;
	 								current_state := char_or_ctrl;
	 									if data_input = "11" then rx_emu_comput_parity := '0'; -- comput parity on an esc-err
	 									else rx_emu_comput_parity := '1';
	 									end if;
	 							end if;
 							
 			when time_id => 				-- build time_id								
	 							stamp(7 downto 2) := stamp(5 downto 0);
	 							stamp(1 downto 0) := data_input;
	 							count_write := count_write + 1;
	 							rx_emu_comput_parity := rx_emu_comput_parity xor data_input(0) xor data_input(1); 
	 								if count_write = 4
	 								then   -- time id is made								 								
	 									if code /= "ESC-----" and  code /= "ESC----E"
	 									then --  no escape detected before time id 
											write(l,code);
											tab := "     ";
											write(l,tab);
											write(l,data);
											writeline(out_file,l);										
											std_stamp(7 downto 0) := stamp(0) & stamp(1) & stamp(2) & stamp(3) 
											& stamp(4) & stamp(5) & stamp(6) & stamp(7);	 
		 							 			if error_parity = '0' then 	 code := "TIME_ID-";
												else code := "TIME_IDE";
												end if;
		 							 		data := conv_integer(std_stamp);	 							 	
		 							 	else	-- escape detected before time id 
		 							 		std_stamp(7 downto 0) := stamp(0) & stamp(1) & stamp(2) & stamp(3) 
											& stamp(4) & stamp(5) & stamp(6) & stamp(7);	 
		 							 			if error_parity = '0' then 	 code := "TIME_ID-";
												else code := "TIME_IDE";
												end if;
		 							 		data := conv_integer(std_stamp);
		 							 	end if;
	 									current_state := char_or_ctrl;
	 									stamp := (others => '0');
	 									count_write := 0;
	 								end if;
	 						
			when others 	=>
end case;	 
end writefile;
------------------------------------------------------------------
end emu_spwr_pack;