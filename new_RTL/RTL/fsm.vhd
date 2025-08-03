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
--	generate signal_errorwait and before_errorwait for rx component
--	inout signal is removed
----------------------------------------------------------------------------------------

library ieee;

use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
--use ieee.std_logic_arith.all;
--use ieee.numeric_std.all;

use work.Spacewire_Pack.all;

entity fsm is
	
	port(
		Reset_n : in std_logic;
		Clk : in std_logic;
		State : out std_logic_vector(2 downto 0);
		linkEnabled : in std_logic;
		
		-- input
		
		short_got_fct_n : in std_logic;
		short_got_null_n : in std_logic;
		short_got_NChar_n : in std_logic;
		short_got_Time_n : in std_logic;
		
		-- input error
		
		Rx_credit_error_n : in std_logic;
		Tx_credit_error_n : in std_logic;
		short_Error_Dis_n : in std_logic;
		short_Error_Par_n : in std_logic;  
		short_Error_ESC_n : in std_logic;
		
		
		before_errorwait	:	out std_logic;
		signal_errorwait	:	out std_logic;
--		constante_12_8 : in std_logic_vector(15 downto 0); 
--		constante_3_2 : in std_logic_vector(15 downto 0); 
		view_fsm : out std_logic_vector(3 downto 0)		
		
	);
end entity;

architecture rtl of fsm is


signal timer : std_logic_vector(15 downto 0); 
signal current_state		: std_logic_vector(2 downto 0);
signal before_errorwait_signal : std_logic;

begin

manager:	process(reset_n, Clk)
begin
  if Reset_n = '0'
  then
	State <= S_ErrorReset;
	current_state <= S_ErrorReset;
	timer <= (others => '0');
	view_fsm <= "0000";
	before_errorwait <= '0';
	before_errorwait_signal <= '0';
	signal_errorwait <= '0';
	
  else
	if Clk='1' and Clk'event
	then
		case Current_state is
			when S_ErrorReset		=>	
									view_fsm <= "0001";
									timer <= timer + 1;									
									signal_errorwait <= '0';									
									if timer = constante_3_2 and before_errorwait_signal = '0'
									then
									before_errorwait <= '1';
									before_errorwait_signal <= '1';
									timer <= (others => '0');
									else
										if timer = constante_3_2 and before_errorwait_signal = '1'
										then
										Current_state <= S_ErrorWait;
										State <= S_ErrorWait;
										timer <= (others => '0');
										end if;
									end if;	
																 
			when S_ErrorWait		=>  
									view_fsm <= "0010";
									timer <= timer + 1;
									signal_errorwait <= '1';
									if short_Error_Dis_n = '0' or 
										short_got_fct_n = '0' or 
										short_got_NChar_n = '0' or
										short_got_Time_n = '0' or
										short_Error_Par_n = '0' or
										short_Error_ESC_n = '0'	
																		
									then --disc error go to reset
									Current_state <= S_ErrorReset;
									State <= S_ErrorReset;
									timer <= (others => '0');
									before_errorwait <= '0';
									before_errorwait_signal <= '0';
									else	
										if timer = constante_12_8--128
										then 	-- after 12.8µ go to next state
										current_state <= S_Ready;
										State <= S_Ready;
										timer <= (others => '0');
										end if;
									end if;
										
			when S_Ready			=>	
									view_fsm <= "0100";
									if short_Error_Dis_n = '0' or 
										short_got_fct_n = '0' or 
										short_got_NChar_n = '0' or
										short_got_Time_n = '0' or
										short_Error_Par_n = '0' or
										short_Error_ESC_n = '0'	
												 	
									then --disc error go to reset
									Current_state <= S_ErrorReset;
									State <= S_ErrorReset;
									timer <= (others => '0');
									before_errorwait <= '0';
									before_errorwait_signal <= '0';									
									else
										if linkEnabled = '1'
										then
										current_state <= S_Started;
										State <= S_Started;
										end if;
									end if;
									
			when S_Started 		=>  
									view_fsm <= "1000";
									timer <= timer + 1;
									if timer = constante_12_8 or 
										short_Error_Dis_n = '0' or
										short_got_fct_n = '0' or 
										short_got_NChar_n = '0' or
										short_got_Time_n = '0' or
										short_Error_Par_n = '0' or
										short_Error_ESC_n = '0'	
												 
									then	-- after 12.8µ or disc error go to reset
									Current_state <= S_ErrorReset;
									State <= S_ErrorReset;
									timer <= (others => '0');
									before_errorwait <= '0';
									before_errorwait_signal <= '0';
									else
										if short_got_null_n = '0'
										then 	-- null detected
										Current_state <= S_Connecting;
										State <= S_Connecting;
										timer <= (others => '0');
										end if;
									end if;
			when S_Connecting 	=>
									view_fsm <= "1001";
									timer <= timer + 1;
									if timer = constante_12_8 or 
										short_Error_Dis_n = '0' or
										short_got_NChar_n = '0' or
										short_got_Time_n = '0' or
										short_Error_Par_n = '0' or
										short_Error_ESC_n = '0'		  	
									then		-- after 12.8µ or disc error go to reset
									Current_state <= S_ErrorReset;
									State <= S_ErrorReset;
									timer <= (others => '0');
									before_errorwait <= '0';
									before_errorwait_signal <= '0';
									
									else
										if short_got_fct_n = '0'
										then	-- fct detected
										Current_state <= S_Run;
										State <= S_Run;
										timer <= (others => '0');
										end if;
									end if;
									
			when S_Run			=>	
									view_fsm <= "1010";
									if 	Tx_credit_error_n = '0' or 
										Rx_credit_error_n = '0' or 
										short_Error_Par_n = '0' or
										short_Error_ESC_n = '0'	or
										short_Error_Dis_n = '0' 
									then	-- credit error detected or disc error		
									Current_state <= S_ErrorReset;
									State <= S_ErrorReset;
									timer <= (others => '0');
									before_errorwait <= '0';
									before_errorwait_signal <= '0';
									
									end if;
																							 
			when others 	=>
		end case;	     	      		
    end if;
  end if;
end process;

end RTL;

