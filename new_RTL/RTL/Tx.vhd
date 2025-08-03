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
--	data signal is pipelined on two bits
--	Tx can send eop.
--	TX can send eep
--	signal state is removed in process sensitivity list
-- 	out is generate by sequential process name make_out
--	resampling_out process allow to generate enable_reset
--	enable_reset allow to stop output signal on the end of caractere
--	inout signal is removed
----------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.Spacewire_Pack.all;

entity Tx is
port(

	Reset_n : in std_logic;
	Tx_Clk  : in std_logic;
	
	-- Main FSM interface

	State : in std_logic_vector(2 downto 0);
	
	-- Tx Fifo interface

	Tx_FIFO_Din : in std_logic_vector(8 downto 0);
	Tx_FIFO_Rd_n  : out std_logic;
	Tx_FIFO_Empty_n : in std_logic;
	
	-- credit 

	Rx_FIFO_Credit_Rd_n : out std_logic;    -- Read one more FCT from the FIFO
	Rx_FIFO_Credit_Empty_n : in std_logic;  -- true when there is no more FCT in the FIFO	
	Tx_Credit_Empty_n : in std_logic;

	-- Time code

	Send_Time_n  : in std_logic;
	Time_Code  : in std_logic_vector(7 downto 0);
	time_id_sended_n  : out std_logic;

	-- escape
	
	send_esc :in std_logic;
	send_eop_n : out std_logic;

	-- Link

	Dout : out std_logic;
	Sout : out std_logic

);
end entity;


architecture t1 of Tx is

signal D_Clk : std_logic; 
signal Data : std_logic_vector(16 downto 0);
signal first_null,first_null_two,first_null_three : std_logic;
signal char_length : integer;
signal view_i : integer;
signal sampled_data : std_logic;
signal Sout_internal,Dout_internal  : std_logic;
signal reset_enable  : std_logic;
signal Tx_FIFO_Rd_n_signal : std_logic;

begin

-----------------------------------------------------------------------------------
-- Tx strobe generator
-----------------------------------------------------------------------------------

Transmitter:	process(Reset_n, Tx_Clk)


variable i : integer;
variable P : std_logic;
variable date_reverse : std_logic_vector( 7 downto 0);

procedure procedure_Reset is
begin

	--signal
	
	D_Clk <= '1';
	Data <= (others => '0');
	first_null <= '0';

	-- Tx Fifo interface
	
	Tx_FIFO_Rd_n <= '1';
	Tx_FIFO_Rd_n_signal <= '1';
	
	-- credit
		 
	Rx_FIFO_Credit_Rd_n <= '1';
	
	--variable

	i := 0;
	
	char_length <= 4;
	P := '0';
	
	-- Time code
	
	time_id_sended_n <= '1';
	date_reverse := (others => '0');
	
	view_i <= 0;
		
	sampled_data <= '0';
	
	send_eop_n <= '1';
	
--  	Dout_internal <= '0';
--  	Sout_internal <= '0';
	
end procedure;

begin
if Reset_n = '0' --or State = ErrorReset
then procedure_Reset;
else
	if Tx_Clk='1' and Tx_Clk'event
	then

		if ((State = S_ErrorReset) and reset_enable = '1')--and (Dout_internal  = '0') and (Sout_internal  = '0'))
		 or State=S_ErrorWait 
		or State=S_Ready
		then
		procedure_Reset;
		else

--  		Dout_internal <= Data(16);
--  		Sout_internal <= (Data(16) xor D_Clk) and first_null_three;
		
		-- Tx clock generator

		D_Clk <= not D_Clk;

		-- Host Credits management

		Rx_FIFO_Credit_Rd_n<='1';
		
		send_eop_n <= '1';

		-- Shift register

		Data(15) <= Data(14);
		Data(16) <= Data(15);
		

		if Tx_FIFO_Rd_n_signal = '0' and sampled_data = '0' 
		then
			--	diseable read
			Tx_FIFO_Rd_n <= '1';
			Tx_FIFO_Rd_n_signal <= '1';
			sampled_data <= '1';
		else
			if Tx_FIFO_Rd_n_signal = '1' and sampled_data = '1' 
			then
				if Tx_FIFO_Din(8) = '0'
				then
				--	make next send : data
				Data(15) <= (not P); 
				date_reverse := Tx_FIFO_Din(0)&Tx_FIFO_Din(1)&Tx_FIFO_Din(2)&Tx_FIFO_Din(3)&Tx_FIFO_Din(4)&Tx_FIFO_Din(5)&Tx_FIFO_Din(6)&Tx_FIFO_Din(7);	
				Data(14 downto 6) <= '0' & date_reverse ;
				char_length <= 13;
				
				comput_parity(P ,date_reverse );-- parity for after next send
				sampled_data <= '0';
				else
					if Tx_FIFO_Din(7 downto 0) = x"00"
					then
					--	make next send : EOP
					Data(15) <= P;
					Data(14 downto 12) <= C_EOP;
					char_length <= 7;
					send_eop_n <= '0';
					
					P := '1';-- parity for after next send
					sampled_data <= '0';
					else
						if Tx_FIFO_Din(7 downto 0) = x"01"
						then
						--	make next send : EEP
						Data(15) <= P;
						Data(14 downto 12) <= C_EEP;
						char_length <= 7;
						--send_eop_n <= '0';
					
						P := '1';-- parity for after next send
						sampled_data <= '0';
						else
						Data(14 downto 0) <= Data (13 downto 0) & '0';
						end if;
					end if;
				end if;
			else
			Data(14 downto 0) <= Data (13 downto 0) & '0';
			end if;
		end if;						

		

			i := i + 1;

			time_id_sended_n <= '1';


			if i = char_length - 3
			then
			i:=0;
				if Send_Time_n = '0' and ( State=S_Run )
				then	
				-- Time code 				
				date_reverse := Time_Code(0)&Time_Code(1)&Time_Code(2)&Time_Code(3)&Time_Code(4)&Time_Code(5)&Time_Code(6)&Time_Code(7);		 		
				Data(13 downto 0) <= P & C_ESC & '1' & '0' & date_reverse;
				comput_parity(P ,date_reverse);
				char_length<=17;
				time_id_sended_n <= '0';									
				else				
					if Rx_FIFO_Credit_Empty_n = '1' and ( State=S_Connecting or State=S_Run ) and first_null = '1'
					then
					-- FCT									  		
					Data(13 downto 10) <= P & C_FCT ;
					P := '0'; 
					Rx_FIFO_Credit_Rd_n <= '0'; --modify
					char_length<=7;
					else	
						if send_esc = '1'
						then
						-- ESC						
						Data(13 downto 10) <= P & C_ESC ;
						P := '0'; 
						char_length<=7;							
						else
							if Tx_FIFO_Empty_n='1' and Tx_Credit_Empty_n = '1' and ( State=S_Started or State=S_Connecting or State=S_Run ) 
							then	
							--	send char			  		
							Tx_FIFO_Rd_n <= '0';
							Tx_FIFO_Rd_n_signal <= '0';
							char_length <= 13;							
							else	
							--	send null
							Data(13 downto 6) <= P & C_ESC & '0' & C_FCT;
							P := '0'; 
							char_length <= 11;
							first_null <= '1';
							end if;
						end if;
					end if;	
				end if;	
			end if;	
		view_i <= i; 		     
		end if;--	state
	end if;	--	tx clock
end if;	--	reset
end process;

-- -----------------------------------------------------------------------------------
-- -- Spacewire Tx signals generator
-- -----------------------------------------------------------------------------------
-- Dout_internal <= Data(16) when ((State=Started) or (State=Connecting) or (State=Run)) else '0';
-- Sout_internal <= (Data(16) xor D_Clk) and first_null_three  when ((State=Started) or (State=Connecting) or (State=Run)) else '0';
-- --Sout <= (Data(16) xor D_Clk) when (((State=Started) or (State=Connecting) or (State=Run)) and first_null_three  = '1') else '0';

-----------------------------------------------------------------------------------
-- start sout
-----------------------------------------------------------------------------------

start_sout	:	process(Reset_n, Tx_Clk)
begin
if Reset_n = '0'
then
first_null_two <= '0';
first_null_three <= '0';
else
	if Tx_Clk='1' and Tx_Clk'event
	then
		if ((State = S_ErrorReset) and reset_enable = '1')--and (Dout_internal  = '0') and (Sout_internal  = '0'))
		or State=S_ErrorWait 
		or State=S_Ready
		then
		first_null_two <= '0';
		first_null_three <= '0';
		else
			if first_null = '1' and first_null_two = '0'
			then
			first_null_two <= '1';
			else
				if first_null_two = '1' and first_null_three = '0'
				then
				first_null_three <= '1';
				end if;			
			end if;
		end if;--state
	end if;--clk
end if;--reset
end process;

-----------------------------------------------------------------------------------
-- sequential output.
-----------------------------------------------------------------------------------

make_out	:	process(Reset_n, Tx_Clk)
begin
if Reset_n = '0' --or State = ErrorReset or State=ErrorWait or State=Ready
then
Dout_internal <= '0';
Sout_internal  <= '0';
else
	if Tx_Clk='1' and Tx_Clk'event
	then
		if ((State = S_ErrorReset) and reset_enable = '1')--and (Dout_internal  = '0') and (Sout_internal  = '0'))
		or State=S_ErrorWait 
		or State=S_Ready
		then
		Dout_internal  <= '0';
		Sout_internal  <= '0';
		else
			if first_null_three = '1'
			then 
			Dout_internal  <= Data(16);
			Sout_internal  <= (Data(16) xor D_Clk); --and first_null_three;
			else
			Dout_internal  <= '0';
			Sout_internal  <= '0';
			end if;
		end if;--state
	end if;--clk
end if;--reset
end process;

-----------------------------------------------------------------------------------
-- resampling output spacewire
-----------------------------------------------------------------------------------

resampling_out	:	process(Reset_n, Tx_Clk)
begin
if Reset_n = '0' --or State = ErrorReset or State=ErrorWait or State=Ready
then
Dout <= '0';
Sout <= '0';
else
	if Tx_Clk='1' and Tx_Clk'event
	then
		if ((State = S_ErrorReset) and reset_enable = '1')--and (Dout_internal  = '0') and (Sout_internal  = '0'))
		or State=S_ErrorWait 
		or State=S_Ready
		then
		Dout <= '0';
		Sout <= '0';
		else
		Dout <= Dout_internal;
        Sout <= Sout_internal;
		end if;--state
	end if;--clk
end if;--reset
end process;

-----------------------------------------------------------------------------------
-- drive reset enable signal 
-----------------------------------------------------------------------------------

reset_enable <= (not(Dout_internal)) and (not(Sout_internal));

-- process(Reset_n, Tx_Clk)
-- begin
-- if Reset_n = '0' 
-- then
-- reset_enable <= '0';
-- else
-- 	if Tx_Clk='1' and Tx_Clk'event
-- 	then
-- 		if Dout_internal = '0' and Sout_internal = '0'
-- 		then
-- 		reset_enable <= '1';
-- 		else
-- 		reset_enable <= '0';
-- 		end if;
-- 	end if;--clk
-- end if;--reset
-- end process;

end T1;