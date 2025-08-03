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

--	B.Bertrand
--	06/04/2009
--	inout signal is removed

library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;
---------------------------------------------------------------
--
-- PACKAGE
--
---------------------------------------------------------------
package Spacewire_Pack is

-- FSM states for main fsm spwr ip simbolx

--type FSM_State is ( ErrorReset, ErrorWait, Ready, Started, Connecting, Run);



-- Constant for tx spwr ip simbolx

constant WD_TIMEOUT	: integer :=10;
constant MAX_CREDIT 	: integer :=56;
constant constante_12_8 : std_logic_vector:= x"0080";
constant constante_3_2 : std_logic_vector:= x"0020";



constant C_FCT	: std_logic_vector :="100";	
constant C_EOP	: std_logic_vector :="101";	
constant C_EEP	: std_logic_vector :="110";	
constant C_ESC	: std_logic_vector :="111";	

constant C_NCHAR: std_logic_vector :="000";	

constant S_ErrorReset : std_logic_vector(2 downto 0) := "000";
constant S_ErrorWait  : std_logic_vector(2 downto 0) := "001";
constant S_Ready      : std_logic_vector(2 downto 0) := "010";
constant S_Started    : std_logic_vector(2 downto 0) := "011";
constant S_Connecting : std_logic_vector(2 downto 0) := "100";
constant S_Run        : std_logic_vector(2 downto 0) := "101";

-------------------------------------------------
-- Procedure comput parity for tx spwr ip simbolx
-------------------------------------------------

procedure comput_parity(
			P : out std_logic;
			Tx_FIFO_Din  : std_logic_vector(7 downto 0));

component Rx
    port (

	Reset_n : in std_logic;
	Clk : in std_logic;
	Rx_Clk : inout std_logic;
	
	-- Main FSM interface

	State : in std_logic_vector(2 downto 0); -- if you have 6 states, 3 bits are enough


	-- param
	
	wd_timeout : in std_logic_vector(15 downto 0);
	--before_errorwait : in std_logic;
	signal_errorwait	:	in std_logic;
	
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
end component;						
						
component Tx
port(

	Reset_n : in std_logic;
	Tx_Clk  : in std_logic;
	
	-- Main FSM interface

	State : in std_logic_vector(2 downto 0);
	
	-- Tx Fifo interface

	Tx_FIFO_Din : in std_logic_vector(8 downto 0);
	Tx_FIFO_Rd_n  : inout std_logic;
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
	
--	Dout_view : out std_logic;
--	Sout_view : out std_logic
);
end component;


component Rx_Fifo

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
end component;

component Tx_fifo
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
end component;

component fsm
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
--		--constante_6_4 : in std_logic_vector(15 downto 0); 
--		constante_3_2 : in std_logic_vector(15 downto 0); 
		view_fsm : out std_logic_vector(3 downto 0)		
		
	);
end component;

component spwr_ip
		port(
		
		Clk : in std_logic;
		--Clk_spw_tx : in std_logic;
		Reset_n : in std_logic;
		--Remote_Reset_n	: in std_logic;
		
		-- manage ready state
				
		link_Enabled : in std_logic;
		Link_start  : in std_logic;
		auto_start  : in std_logic;
		
		--link
		Din : in std_logic;
		Sin : in std_logic;
		
		Dout : out std_logic;
		Sout : out std_logic;
		
		-- out time id
		rx_got_time : out std_logic_vector(8 downto 0);
		short_got_Time_n  : out std_logic;
		
		-- in time id
		Tx_Send_Time : in std_logic;
		Tx_Time_Code : in std_logic_vector(7 downto 0); 
		
		-- out spwr
		
		Rx_Dout : out std_logic_vector(8 downto 0);
		Rx_Rd_n : in std_logic;
		Rx_Empty_n : out std_logic;
		
		-- in spwr
		
		Tx_Din : in std_logic_vector(8 downto 0);
		Tx_Wr_n : in std_logic;
		Tx_Full_n : out std_logic;
		
		-- spy
		Tx_FIFO_Empty_n  : out std_logic;
		Rx_Full_n	:	out std_logic;
		
		-- rx 
		
		short_got_NChar_n  : out std_logic;
		short_got_fct_n : out std_logic;
		short_got_null_n : out std_logic;
		wd_timeout : in std_logic_vector(15 downto 0);
		
		-- rx fifo
		
		credit_count_rx_fifo : out integer;
		short_Rx_FIFO_Wr_n  : out std_logic;
		
		-- tx fifo
		
		credit_count_tx_fifo : out integer;
		
		-- fsm 
		
--		constante_12_8 : in std_logic_vector(15 downto 0); 
--		constante_6_4 : in std_logic_vector(15 downto 0); 
--		constante_3_2 : in std_logic_vector(15 downto 0); 
		view_fsm : out std_logic_vector(3 downto 0); 
		
		--error
		

 		short_Error_Par_n : out std_logic;
 		short_Error_ESC_n : out std_logic;
 		short_Error_Dis_n : out std_logic;
 		
 		Tx_credit_error_n : out std_logic;
 		Rx_credit_error_n : out std_logic

--		 Dout_view : out std_logic;
--		 Sout_view : out std_logic
		 		
		);
end component;

component twodomainclock 
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
--	Clk_slow : in std_logic;
	
	in_short_pulse : in std_logic_vector(N_short_to_width - 1 downto 0);
	in_width_pulse : in std_logic_vector(N_width_to_short - 1 downto 0);
	
	out_width_pulse : inout std_logic_vector(N_short_to_width - 1 downto 0);
	out_short_pulse : out std_logic_vector(N_width_to_short - 1 downto 0);
	
	in_short_pulse_n	: in std_logic_vector(N_short_to_width_n - 1 downto 0);
	in_width_pulse_n : in std_logic_vector(N_width_to_short_n - 1 downto 0);
	
	out_width_pulse_n : inout std_logic_vector(N_short_to_width_n - 1 downto 0);
	out_short_pulse_n : out std_logic_vector(N_width_to_short_n - 1 downto 0)
    );
end component;
  
component width_to_short_n
   port (
	Rst : in std_logic;
	Clk_speed : in std_logic;
--	Clk_slow : in std_logic;
	
	in_width_pulse_n : in std_logic;
	
	out_short_pulse_n : out std_logic
	
    );
end component;    
      
end package;

---------------------------------------------------------------
--
-- BODY PACKAGE
--
---------------------------------------------------------------
package body Spacewire_Pack is

------------------------------------------------------
-- Body Procedure comput parity for tx spwr ip simbolx
------------------------------------------------------

procedure comput_parity(
			P : out std_logic;
			Tx_FIFO_Din  : std_logic_vector(7 downto 0)) is

variable comput_P : std_logic;----------option 2---------	
		
begin
comput_P := '0';
comput_P := comput_P  xor Tx_FIFO_Din(0);
comput_P := comput_P  xor Tx_FIFO_Din(1);
comput_P := comput_P  xor Tx_FIFO_Din(2);
comput_P := comput_P  xor Tx_FIFO_Din(3);
comput_P := comput_P  xor Tx_FIFO_Din(4);
comput_P := comput_P  xor Tx_FIFO_Din(5);
comput_P := comput_P  xor Tx_FIFO_Din(6);
P := comput_P  xor Tx_FIFO_Din(7);
end comput_parity;--------------------------------------
		
end Spacewire_Pack;