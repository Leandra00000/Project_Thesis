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
--use work.pack_Components.all;
use std.textio.all;
 
use work.emu_Pack.all;

use work.Spacewire_Pack.all;


entity testbench is
	generic(
		test_emu_ip : std_logic;
		test_ip2_ip  : std_logic; 
		test_ip2_emu : std_logic;
		conf_fsm_ip : std_logic;
		conf_test : std_logic; 
		conf_test0 : std_logic;
		conf_test1 : std_logic;
		conf_test2 : std_logic;
		conf_test3 : std_logic;
		conf_test4 : std_logic;
		conf_test5 : std_logic;
		conf_test6 : std_logic;
		conf_test7 : std_logic;
		conf_test8 : std_logic;
		conf_test9 : std_logic;
		conf_test10 : std_logic;
		conf_test11 : std_logic;
		conf_test12 : std_logic;
		conf_test13 : std_logic;
		conf_test14 : std_logic;
		conf_test15 : std_logic;
		conf_test16 : std_logic;
		conf_test17 : std_logic;
		conf_test18 : std_logic;
		conf_test19 : std_logic;
		conf_test20 : std_logic;
		conf_test21 : std_logic;
		conf_test22 : std_logic;
		conf_test23 : std_logic;
		conf_test24 : std_logic;
		conf_test25 : std_logic;
		conf_test26 : std_logic;
		conf_test27 : std_logic;
		conf_test28 : std_logic;
		conf_test29 : std_logic;
		conf_test30 : std_logic;
		conf_test31 : std_logic;
		conf_test32 : std_logic;
		conf_test33 : std_logic;
		conf_test34 : std_logic;
		conf_test35 : std_logic;
		conf_test36 : std_logic;
		conf_test37 : std_logic;
		conf_test38 : std_logic;
		conf_test39 : std_logic;
		conf_test40 : std_logic;
		conf_test41 : std_logic;
		conf_test42 : std_logic;
		conf_test43 : std_logic;
		conf_test44 : std_logic;
		conf_test45 : std_logic;
		conf_test46 : std_logic;
		conf_test48 : std_logic;
		conf_test49 : std_logic;
		conf_test50 : std_logic;
		conf_test51 : std_logic;
		conf_test52 : std_logic;
		conf_test53 : std_logic;
		conf_test54 : std_logic;
		conf_test55 : std_logic;
		conf_test56 : std_logic;
		conf_test57 : std_logic;
		conf_test58 : std_logic;
		conf_test59 : std_logic;
		conf_test60 : std_logic;
		conf_test61 : std_logic;
		conf_test62 : std_logic;
		conf_test63 : std_logic;
		conf_test64 : std_logic;
		conf_test65 : std_logic;
		conf_test66 : std_logic;
		conf_test67 : std_logic;
		conf_test68 : std_logic;
		conf_test69 : std_logic;
		conf_test70 : std_logic;
		conf_test99  : std_logic;
		conf_test100  : std_logic;
		conf_test101  : std_logic;
		conf_test102  : std_logic;
		conf_test103  : std_logic
		);
		--port(
		--);
end testbench;

architecture T1 of testbench is

-------------------------------------------
-- CREDIT ip 8 <= CFG_MAXCREDIT <= 56
-------------------------------------------

constant cte_CFG_MAXCREDIT : integer := 56;
constant Rx_ip_MAX_CREDIT : integer := cte_CFG_MAXCREDIT;
constant TX_ip_MAX_CREDIT : integer := cte_CFG_MAXCREDIT;

-------------------------------------------
-- CTE CLOCK
-------------------------------------------

--	clock for IP without TX.
constant XT_Tck : Time := 100 ns;--
--	clock for TX IP.
constant XT_Tck_tx_spwr : Time := 100 ns;--3 x XT_Tck -- 1 bit equal XT_Tck_tx_spwr


-------------------------------------------
-- reset
-------------------------------------------

signal Reset_n_2   : std_logic;
signal Reset_n : std_logic;
signal shift_Reset_n : std_logic;
signal Remote_Reset_n : std_logic;
signal Remote_Reset_n_2 : std_logic;

-------------------------------------------
-- clk
-------------------------------------------

signal Clk : std_logic;
signal Clk_n : std_logic;
signal Tx_clk   : std_logic;
signal Tx_clk_2   : std_logic;

-------------------------------------------
--	Rx interface 
-------------------------------------------

signal State : std_logic_vector(2 downto 0);
signal Rx_Clk : std_logic;
signal got_NULL_n  :  std_logic;
signal got_FCT_n   :  std_logic;
signal got_ESC_n	:	std_logic;
signal got_EEP_n	:	std_logic;
signal got_EOP_n	:	std_logic;
signal got_NChar_n :  std_logic;
signal got_Time_n  :  std_logic;

signal Error_Par_n :  std_logic;	-- Parity error
signal Error_ESC_n :  std_logic;	-- ESC followed by ESC, EOP or EEP
signal Error_Dis_n :  std_logic;	-- Disconnected
signal Error_NChar :  std_logic;	-- NChar received but output buffer not ready
signal Error_FCT :  std_logic;	-- FCT received but transmitter not ready

signal Rx_FIFO_D : std_logic_vector(8 downto 0);
signal Rx_FIFO_Wr_n : std_logic;

signal Time_Code : std_logic_vector(7 downto 0);
signal Tick_out  : std_logic;	

signal before_errorwait : std_logic;
signal signal_errorwait : std_logic;

-------------------------------------------
--	Rx interface 2
-------------------------------------------

signal State_2 : std_logic_vector(2 downto 0);
signal Rx_Clk_2 : std_logic; 
signal got_NULL_n_2  :  std_logic;
signal got_FCT_n_2   :  std_logic;
signal got_ESC_n_2	:	std_logic;
signal got_EEP_n_2	:	std_logic;
signal got_EOP_n_2	:	std_logic;
signal got_NChar_n_2 :  std_logic;
signal got_Time_n_2  :  std_logic;

signal Error_Par_n_2 :  std_logic;	-- Parity error
signal Error_ESC_n_2 :  std_logic;	-- ESC followed by ESC, EOP or EEP
signal Error_Dis_n_2 :  std_logic;	-- Disconnected
signal Error_NChar_2 :  std_logic;	-- NChar received but output buffer not ready
signal Error_FCT_2 :  std_logic;	-- FCT received but transmitter not ready

signal Rx_FIFO_D_2 : std_logic_vector(8 downto 0);
signal Rx_FIFO_Wr_n_2 : std_logic;

signal Time_Code_2 : std_logic_vector(7 downto 0);
signal Tick_out_2  : std_logic;	

signal before_errorwait_2 : std_logic;
signal signal_errorwait_2 : std_logic;

-------------------------------------------
-- two domain clock after RX
-------------------------------------------

signal in_width_pulse_n_vector_rx : std_logic_vector(8 downto 0);
signal out_short_pulse_n_vector_rx : std_logic_vector(8 downto 0);

-------------------------------------------
-- two domain clock after RX 2
-------------------------------------------

signal in_width_pulse_n_vector_rx_2 : std_logic_vector(8 downto 0);
signal out_short_pulse_n_vector_rx_2 : std_logic_vector(8 downto 0);

-------------------------------------------
-- two domain clock before TX
-------------------------------------------

signal in_width_pulse_n_vector_tx : std_logic_vector(3 downto 0);
signal out_short_pulse_n_vector_tx : std_logic_vector(3 downto 0);

-------------------------------------------
-- two domain clock before TX 2
-------------------------------------------

signal in_width_pulse_n_vector_tx_2 : std_logic_vector(3 downto 0);
signal out_short_pulse_n_vector_tx_2 : std_logic_vector(3 downto 0);

-------------------------------------------
-- Tx interface
-------------------------------------------

signal Tx_State : std_logic_vector(2 downto 0);
signal Tx_Time_Code : std_logic_vector(7 downto 0);
signal send_eop_n : std_logic;
signal Rx_FIFO_Credit_Rd_n : std_logic;
signal Tx_Send_Time : std_logic;
signal Rx_FIFO_Credit_Empty_n : std_logic;
signal short_Rx_FIFO_Credit_Empty_n  : std_logic;
signal time_id_sended_n : std_logic;
signal Rx_FIFO_Credit_Rd_width_n  : std_logic;
signal Tx_FIFO_Rd_width_n : std_logic;
signal time_id_sended_width_n : std_logic;

-------------------------------------------
-- Tx interface 2
-------------------------------------------

signal Tx_State_2 : std_logic_vector(2 downto 0);
signal Tx_Time_Code_2 : std_logic_vector(7 downto 0);
signal send_eop_n_2 : std_logic;
signal Rx_FIFO_Credit_Rd_n_2 : std_logic;
signal Tx_Send_Time_2 : std_logic;
signal Rx_FIFO_Credit_Empty_n_2 : std_logic;
signal short_Rx_FIFO_Credit_Empty_n_2  : std_logic;
signal time_id_sended_n_2 : std_logic;
signal Rx_FIFO_Credit_Rd_width_n_2  : std_logic;
signal Tx_FIFO_Rd_width_n_2 : std_logic;
signal time_id_sended_width_n_2 : std_logic;

-------------------------------------------
-- Tx fifo
-------------------------------------------

signal Tx_Full_n : std_logic; 
signal fct_full_n : std_logic;
signal Tx_Rd_n : std_logic; 
signal Tx_Wr_n : std_logic;
signal Tx_Dout : std_logic_vector(8 downto 0); 
signal Tx_Empty_n : std_logic; 
signal Tx_Din : std_logic_vector(8 downto 0); 
signal Tx_Credit_Empty_n : std_logic;
signal Tx_credit_error_n : std_logic;
signal Tx_FIFO_Rd_n : std_logic;
signal Tx_FIFO_Empty_n : std_logic;
signal short_send_eop : std_logic;

-------------------------------------------
-- Tx fifo 2
-------------------------------------------

signal Tx_Full_n_2 : std_logic; 
signal fct_full_n_2 : std_logic;
signal Tx_Rd_n_2 : std_logic; 
signal Tx_Wr_n_2 : std_logic;
signal Tx_Dout_2 : std_logic_vector(8 downto 0); 
signal Tx_Empty_n_2 : std_logic; 
signal Tx_Din_2 : std_logic_vector(8 downto 0); 
signal Tx_Credit_Empty_n_2 : std_logic;
signal Tx_credit_error_n_2 : std_logic;
signal Tx_FIFO_Rd_n_2 : std_logic;
signal Tx_FIFO_Empty_n_2 : std_logic;
signal short_send_eop_2 : std_logic;

-------------------------------------------
-- Rx fifo
-------------------------------------------

signal Rx_Rd_n : std_logic;
signal Rx_Dout : std_logic_vector(8 downto 0); 
signal Rx_Empty_n : std_logic;
signal Rx_Full_n	:	std_logic; 
signal Rx_credit_error_n : std_logic;

-------------------------------------------
-- Rx fifo 2
-------------------------------------------

signal Rx_Rd_n_2 : std_logic;
signal Rx_Dout_2 : std_logic_vector(8 downto 0); 
signal Rx_Empty_n_2 : std_logic;
signal Rx_Full_n_2	:	std_logic; 
signal Rx_credit_error_n_2 : std_logic;

-------------------------------------------
-- input fsm
-------------------------------------------

signal linkEnabled   : std_logic;
signal link_Enabled  : std_logic;
signal Link_start  : std_logic;
signal auto_start  : std_logic;

-------------------------------------------
-- input fsm 2
-------------------------------------------

signal linkEnabled_2   : std_logic;
signal link_Enabled_2  : std_logic;
signal Link_start_2  : std_logic;
signal auto_start_2  : std_logic;

-------------------------------------------
-- generate short signal_n
-------------------------------------------

signal short_got_fct_n : std_logic; 
signal short_Rx_FIFO_Wr_n : std_logic; 
signal short_got_null_n : std_logic; 
signal short_got_NChar_n : std_logic; 
signal short_got_Time_n  : std_logic; 
signal short_Error_Par_n  : std_logic;
signal short_Error_Dis_n : std_logic;
signal short_got_esc_n : std_logic;
signal short_got_eep_n : std_logic; 
signal short_got_eop_n : std_logic;
signal short_Error_ESC_n : std_logic;

-------------------------------------------
-- generate short signal_n 2
-------------------------------------------

signal short_got_fct_n_2 : std_logic; 
signal short_Rx_FIFO_Wr_n_2 : std_logic; 
signal short_got_null_n_2 : std_logic; 
signal short_got_NChar_n_2 : std_logic; 
signal short_got_Time_n_2  : std_logic; 
signal short_Error_Par_n_2  : std_logic;
signal short_Error_Dis_n_2 : std_logic;
signal short_got_esc_n_2 : std_logic;
signal short_got_eep_n_2 : std_logic; 
signal short_got_eop_n_2 : std_logic;
signal short_Error_ESC_n_2 : std_logic;

-------------------------------------------
--	buffer time id
-------------------------------------------

signal time_in_buffer : std_logic_vector(7 downto 0);
signal tick_in_buffer_n : std_logic;

-------------------------------------------
--	buffer time id 2
-------------------------------------------

signal time_in_buffer_2 : std_logic_vector(7 downto 0);
signal tick_in_buffer_n_2 : std_logic;

-------------------------------------------
-- input RX
-------------------------------------------

signal RX_ip_Dout : std_logic;
signal RX_ip_Sout : std_logic;

-------------------------------------------
-- emu spwr
-------------------------------------------

signal Dout , Sout : std_logic;
signal Din, Sin : std_logic;
signal end_com_fich : std_logic;



-------------------------------------------
-- read file for out ip
-------------------------------------------

signal read_file_in_ip : std_logic;

-------------------------------------------
-- read file for out ip 2
-------------------------------------------

signal read_file_in_ip_2 : std_logic;


-------------------------------------------
-- disconnect_error
-------------------------------------------

signal gen_disc_err : std_logic;

-------------------------------------------
-- procedure write file_log.txt summarize test
-------------------------------------------

procedure log(variable ligne : in string) is
variable file_one :  boolean ;--:= false;
variable MyLine : line;
file file_log : text;
begin
file_open(file_log, "file_log.txt", append_MODE);
write (MyLine,ligne);
writeline(file_log,Myline);
end log;

-------------------------------------------
-- SIMULATION EOP
-------------------------------------------

constant first_send_eop : Time := 20288 ns;
constant last_send_eop : Time := 426112 ns; 
signal eop_bit : std_logic;

-------------------------------------------
-- reset for test case
-------------------------------------------

signal Reset2, Reset0_n, Reset3, Reset4_n, Reset5_n, Reset1_n, shift_Reset0_n, shift_Reset1_n, shift_Reset2_n, shift_Reset4_n, shift_Reset5_n, shift_Reset6_n : std_logic;
signal shift_Reset7_n, shift_Reset3_n : std_logic;


----------------------------------------------
--RMAP_Decoder
-----------------------------------------------
signal buffer_data : std_logic_vector(7 downto 0);
signal buffer_wr_en : std_logic;


----------------------------------------------
--FIFO_Buffer
-----------------------------------------------
signal fifo_data_out  : std_logic_vector(7 downto 0);
signal fifo_full     : std_logic;
signal fifo_empty    : std_logic;
signal read_en : std_logic;




signal m_axis_tdata  :  std_logic_vector(8-1 downto 0);
signal m_axis_tkeep  :  std_logic_vector((8/8)-1 downto 0);
signal m_axis_tvalid :  std_logic;
signal m_axis_tlast  :  std_logic;
signal m_axis_tready :   std_logic;




begin

read_en <= '0';
 
----------------------------------------------------------------------------------------------
--
-- Reset
--
-- use reset_n for IP cesr.
-- use reset_n or shift_Reset_n for for emulator.
-- use reset_n_2 for IP2 cesr
-- use shift_reset_n for emulator shifted
----------------------------------------------------------------------------------------------

--conf_test37 = '0' and conf_test36 = '1' 
--conf_test37 = '0' and conf_test36 = '0'
Reset2 <= '0', '1' after 150 ns;


--conf_test37 = '1' and conf_test36 = '0'
Reset3 <= '0', '1' after 18300 ns;

--conf_test37 = '1' and conf_test36 = '0' 
Reset4_n <= '0', '1' after 150 ns;

--conf_test11 = '1'
Reset5_n <= '0', '1' after 550 ns;

--conf_test36 = '1' and conf_test37 = '0'
Reset1_n <= '0', '1' after 18000 ns;

--conf_test101 = '1'
shift_Reset0_n <= '0', '1' after 650 ns ;

--conf_test23 = '1'
shift_Reset1_n <= '0', '1' after 550 ns ;

--conf_test33 = '1'
shift_Reset2_n <= '0', '1' after 17000 ns ;

--conf_test34 = '1'
shift_Reset4_n <= '0', '1' after 17450 ns ;

--conf_test14 = '1'
shift_Reset5_n <= '0', '1' after 550 ns ;

--conf_test18 = '1'
shift_Reset6_n <= '0', '1' after 6746 ns ;

--conf_test21 = '1'
shift_Reset7_n <= '0', '1' after 6600 ns ;

--conf_test35 = '1'
shift_Reset3_n <= '0', '1' after 17100 ns ;

--	drive reset IP2.

reset_n_2 <= Reset3 when (conf_test37 = '1' and conf_test36 = '0') else
			reset2; 

-- drive reset emu and IP.			
			
reset_n <= Reset4_n when (conf_test37 = '1' and conf_test36 = '0') else
			Reset5_n when (conf_test11 = '1') else	
			Reset1_n when (conf_test36 = '1' and conf_test37 = '0') else
			reset_n_2;	

-- drive reset the shift emu.			
			
shift_reset_n <= shift_Reset1_n when (conf_test23 = '1') or (conf_test43 = '1') else
					shift_Reset2_n	when (conf_test33 = '1') else
					shift_Reset4_n when (conf_test34 = '1') else
					shift_Reset5_n when (conf_test14 = '1') else
					shift_Reset6_n when (conf_test18 = '1') else
					shift_Reset7_n when (conf_test21 = '1') else
					shift_Reset3_n when  (conf_test35 = '1') else
					shift_Reset1_n;


--	alternate eop sent. 					
										
test_eop : if (conf_test99 = '1') generate
					
eop_bit <= '0', '1' after first_send_eop, '0' after first_send_eop + 1 * (32 ns),
'1' after first_send_eop + 4 * (32 ns), '0' after first_send_eop + 5 * (32 ns),	
'1' after first_send_eop + 8 * (32 ns), '0' after first_send_eop + 9 * (32 ns),	
'1' after first_send_eop + 12 * (32 ns), '0' after first_send_eop + 13 * (32 ns),
'1' after first_send_eop + 16 * (32 ns), '0' after first_send_eop + 17 * (32 ns),
'1' after first_send_eop + 20 * (32 ns), '0' after first_send_eop + 21 * (32 ns),
'1' after first_send_eop + 24 * (32 ns), '0' after first_send_eop + 25 * (32 ns);

end generate;


no_test_eop : if (conf_test99 = '0') generate					
eop_bit <= '0';	
end generate;	
										  					
----------------------------------------------------------------------------------------------
--
-- Clock
--
----------------------------------------------------------------------------------------------

Clk_n <= not Clk;


----------------------------------------------------------------------------------------
--
-- clock for IP without TX
--
-----------------------------------------------------------------------------------------

generate_clk_ip_emu:	process 
begin

	Clk <= '1';
	Wait for XT_Tck/2;

	Clk <= '0';
	Wait for XT_Tck/2;

end process;

----------------------------------------------------------------------------------------
--
-- clock for IP TX
--
----------------------------------------------------------------------------------------

generate_clock_tx_ip:	process 
begin
	
	loop
	Tx_clk <= '1';
	Wait for XT_Tck_tx_spwr/2;

	Tx_clk <= '0';
	Wait for XT_Tck_tx_spwr/2;
	end loop;

end process;

-- drive clk IP2

Tx_clk_2  <= Tx_clk;

----------------------------------------------------------------------------------------
--
-- Map Emu
--
----------------------------------------------------------------------------------------

test_ip_emu : if (test_emu_ip = '1' and 
				test_ip2_emu = '0' and 
				test_ip2_ip = '0' and 
				conf_test101 = '0' and 
				conf_test14 = '0' and 
				conf_test18 = '0' and 
				conf_test21 = '0' and 
				conf_test23 = '0' and 
				conf_test43 = '0' and 
				conf_test33 = '0'and
				conf_test34 = '0' and
				conf_test35 = '0'  ) generate 
emu_spwr :   entity work.emu_spwr       
 port map (
 
   	--global
   	
    reset => Reset_n,
    clk	=> Tx_clk,
    
    --in
    
    Din => Din,
    Sin => Sin,
    
    --out
    
    Dout => Dout,
    Sout => Sout,
    
    end_com_fich => end_com_fich
    ); 
end generate;   

----------------------------------------------------------------------------------------
--
-- Map shift Emu
--
----------------------------------------------------------------------------------------

test_ip_emu_shift_reset : if (test_emu_ip = '1' and test_ip2_emu = '0' and test_ip2_ip = '0' and conf_test101 = '1' ) or
							(test_emu_ip = '1' and test_ip2_emu = '0' and test_ip2_ip = '0' and conf_test23 = '1' ) or
							(test_emu_ip = '1' and test_ip2_emu = '0' and test_ip2_ip = '0' and conf_test43 = '1' ) or
							(test_emu_ip = '1' and test_ip2_emu = '0' and test_ip2_ip = '0' and conf_test18 = '1' ) or
							(test_emu_ip = '1' and test_ip2_emu = '0' and test_ip2_ip = '0' and conf_test21 = '1' ) or
							(test_emu_ip = '1' and test_ip2_emu = '0' and test_ip2_ip = '0' and conf_test33 = '1' ) or
							(test_emu_ip = '1' and test_ip2_emu = '0' and test_ip2_ip = '0' and conf_test34 = '1' ) or
							(test_emu_ip = '1' and test_ip2_emu = '0' and test_ip2_ip = '0' and conf_test14 = '1' ) or
							(test_emu_ip = '1' and test_ip2_emu = '0' and test_ip2_ip = '0' and conf_test35 = '1' )  generate 
emu_spwr :   entity work.emu_spwr       
 port map (
 
   	--global
   	
    reset => shift_Reset_n,
    clk	=> Tx_clk,
    
    --in
    
    Din => Din,
    Sin => Sin,
    
    --out
    
    Dout => Dout,
    Sout => Sout,
    
    end_com_fich => end_com_fich
    ); 
end generate;   

---------------------------------
test_emu_ip2 : if test_emu_ip = '0' and test_ip2_emu = '1' and test_ip2_ip = '0' generate 
emu_spwr :   entity work.emu_spwr       
 port map (
 
   	--global
   	
    reset => Reset_n,
    clk	=> Tx_clk,
    
    --in
    
    Din => Dout,
    Sin => Sout,
    
    --out
    
    Dout => Din,
    Sout => Sin,
    
    end_com_fich => end_com_fich
    ); 
end generate;   

set_com_fich : if  test_ip2_ip = '1' generate 
end_com_fich <= '0';
end generate;   



----------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------
--
-- COMPONENT SPACEWIRE 1
--
------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------
--
-- Map Rx ip
--
------------------------------------------------------------------------------------------

map_Rx_ip : if  (test_ip2_emu = '0'and test_ip2_ip = '1') or (test_ip2_emu = '0' and test_emu_ip = '1') or conf_test42 = '1' or conf_test99 = '1'  generate

Rx_ip: entity work.Rx 
 port map (
 
	Reset_n =>  Remote_Reset_n,
	Clk => clk,
	Rx_Clk => Rx_Clk,

-- Main FSM interface

	State => State,

	-- param
	
	wd_timeout => x"0011",
	signal_errorwait	=> signal_errorwait,
	-- out
	
	got_NULL_n  => got_NULL_n,
	got_ESC_n	=> open,
	got_FCT_n   => got_FCT_n,
	got_EOP_n	=> got_EOP_n, 	
	got_EEP_n => open,
	got_NChar_n => got_NChar_n,
	
	-- error

	Error_Par_n => Error_Par_n,	-- Parity error
	Error_ESC_n => Error_ESC_n,	-- ESC followed by ESC, EOP or EEP
	Error_Dis_n => Error_Dis_n,	-- Disconnected

	-- Rx Fifo interface

	Rx_FIFO_D => Rx_FIFO_D,
	Rx_FIFO_Wr_n => Rx_FIFO_Wr_n,

	-- Time Code interface

	got_Time_n  => got_Time_n,

	-- Link

	Din => RX_ip_Dout,
	Sin => RX_ip_Sout
 	);

end generate;	
 
Remote_Reset_n <= Reset_n and before_errorwait;


---------------------------------------------------------------------------
--
-- Map Rx Fifo
--
---------------------------------------------------------------------------

map_fifoRx_ip : if  (test_ip2_emu = '0'and test_ip2_ip = '1') or (test_ip2_emu = '0' and test_emu_ip = '1') or conf_test42 = '1' or conf_test99 = '1'  generate

fifoRx_ip : entity work.Rx_Fifo 
generic map (
	WIDTH  => 9,
	LENGTH => 128,
	MAX_CREDIT => Rx_ip_MAX_CREDIT)
port map (
	Reset_n => Reset_n,
	Clk => Clk,
	State => State,
	
	-- Credit
	Credit_Rd_n => Rx_FIFO_Credit_Rd_n,
	Credit_Empty_n => Rx_FIFO_Credit_Empty_n,
	credit_error_n => Rx_credit_error_n,
	
	-- Data Input
	Din => Rx_FIFO_D,
	Wr_n => short_Rx_FIFO_Wr_n  ,
	Full_n => Rx_Full_n,
	short_got_EOP_n => short_got_EOP_n,
	
	-- Data Output
	Dout => Rx_Dout,
	Rd_n => Rx_Rd_n,
	Empty_n => Rx_Empty_n,
	
	Credit => open
);	

end generate;



---------------------------------------------------------------------------
--
-- twodomainclock component after RX
--
---------------------------------------------------------------------------

in_width_pulse_n_vector_rx <= got_EOP_n&got_fct_n & got_null_n & got_NChar_n & got_Time_n & Error_Par_n & Error_ESC_n & Error_Dis_n & Rx_FIFO_Wr_n;


map_twodmainclock_after_RX : entity work.twodomainclock
	generic map( 
			N_short_to_width => 2,
			use_short_to_width => 0,
			N_width_to_short => 2,
			use_width_to_short => 0,
			N_short_to_width_n => 2,
			use_short_to_width_n => 0,
			N_width_to_short_n => 9,
			use_width_to_short_n => 1)					
 	port map (
 	Rst => reset_n,
	Clk_speed => clk,
--	Clk_slow => Rx_clk,
		
	in_short_pulse => (others => '0'),
	in_width_pulse => (others => '0'),
	
	out_width_pulse => open,
	out_short_pulse => open,
	
	in_short_pulse_n => (others => '1'),
	in_width_pulse_n => in_width_pulse_n_vector_rx, 
	
	out_width_pulse_n => open,
	out_short_pulse_n => out_short_pulse_n_vector_rx
	
);
--short_Error_in_first_null_n <= out_short_pulse_n_vector_rx(9);
short_got_eop_n <= out_short_pulse_n_vector_rx(8);
short_got_null_n <= out_short_pulse_n_vector_rx(6);
short_got_fct_n <= out_short_pulse_n_vector_rx(7);
short_Rx_FIFO_Wr_n  <= out_short_pulse_n_vector_rx(0);
short_got_NChar_n  <= out_short_pulse_n_vector_rx(5);
short_got_Time_n  <= out_short_pulse_n_vector_rx(4);
short_Error_Par_n  <= out_short_pulse_n_vector_rx(3);
short_Error_ESC_n  <= out_short_pulse_n_vector_rx(2);
short_Error_Dis_n <= out_short_pulse_n_vector_rx(1);

---------------------------------------------------------------------------
--
-- Map Tx Fifo
--
---------------------------------------------------------------------------

map_fifoTx_ip : if  (test_ip2_emu = '0'and test_ip2_ip = '1') or (test_ip2_emu = '0' and test_emu_ip = '1') or conf_test42 = '1' or conf_test99 = '1'    generate

fifoTx_ip : entity work.Tx_Fifo 
generic map (
	WIDTH  => 9,
	LENGTH => 128,
	MAX_CREDIT => Tx_ip_MAX_CREDIT)
port map (
	Reset_n => Reset_n,
	Clk => clk,
	State => State,
	
	-- Credit
	fct_n => short_got_fct_n,--short_got_fct_n,
	short_send_eop_rising => short_send_eop,
	fct_full_n => Tx_credit_error_n,
	Credit_Empty_n => Tx_Credit_Empty_n,
	--credit_error_n => Tx_credit_error_n,
	
	-- Data Input
	Din => Tx_Din,
	Wr_n => Tx_Wr_n,
	Full_n => Tx_Full_n,
	
	-- Data Output
	Dout => Tx_Dout,
	Rd_n => Tx_FIFO_Rd_n,
	Empty_n => Tx_FIFO_Empty_n,
	
	Credit => open
);

end generate;

---------------------------------------------------------------------------
--
-- twodomainclock component before TX.
--
---------------------------------------------------------------------------

in_width_pulse_n_vector_tx <= send_eop_n&time_id_sended_width_n & Rx_FIFO_Credit_Rd_width_n & Tx_FIFO_Rd_width_n; 

-- map_twodmainclock_before_TX : entity work.twodomainclock
-- 	generic map( 
-- 			N_short_to_width => 2,
-- 			use_short_to_width => 0,
-- 			N_width_to_short => 2,
-- 			use_width_to_short => 0,
-- 			N_short_to_width_n => 2,
-- 			use_short_to_width_n => 0,
-- 			N_width_to_short_n => 4,
-- 			use_width_to_short_n => 1)	
--  	port map (
--  	Rst => reset_n,
-- 	Clk_speed => clk,
-- 	Clk_slow => tx_clk,
-- 	
-- 	in_short_pulse => (others => '0'),
-- 	in_width_pulse => (others => '0'),
-- 	
-- 	out_width_pulse => open,
-- 	out_short_pulse => open,
-- 	
-- 	in_short_pulse_n => (others => '1'),
-- 	in_width_pulse_n => in_width_pulse_n_vector_tx, 
-- 	
-- 	out_width_pulse_n => open,
-- 	out_short_pulse_n => out_short_pulse_n_vector_tx		

-- 	
-- );

-- short_send_eop <= out_short_pulse_n_vector_tx(3);
-- time_id_sended_n <=  out_short_pulse_n_vector_tx(2);
-- Rx_FIFO_Credit_Rd_n <= out_short_pulse_n_vector_tx(1);
-- Tx_FIFO_Rd_n <= out_short_pulse_n_vector_tx(0); 

----------------------------------------------------------------------------------------
--
-- Map Tx ip
--
------------------------------------------------------------------------------------------ 	

map_TX_ip : if (test_ip2_emu = '0'and test_ip2_ip = '1') or (test_ip2_emu = '0' and test_emu_ip = '1') or conf_test42 = '1' or conf_test99 = '1'   generate

Tx_ip : entity work.Tx
 port map (
 	Reset_n =>	Reset_n,	
	Tx_Clk  =>	clk,	
		
	-- Main FSM interface

	State => State,

	-- Tx Fifo interface

	Tx_FIFO_Din => Tx_Dout,
	Tx_FIFO_Rd_n  => Tx_FIFO_Rd_n,
	Tx_FIFO_Empty_n => Tx_FIFO_Empty_n,

	-- Rx Fifo interface ( FCT send interface )

	Rx_FIFO_Credit_Rd_n => Rx_FIFO_Credit_Rd_n,    -- Read one more FCT from the FIFO
	Rx_FIFO_Credit_Empty_n => Rx_FIFO_Credit_Empty_n,  -- true when there is no more FCT in the FIFO
	Tx_Credit_Empty_n => Tx_Credit_Empty_n,
	
	-- Time code

	Send_Time_n  => tick_in_buffer_n,--Tx_Send_Time,
	Time_Code  => time_in_buffer,--Tx_Time_Code,
	time_id_sended_n => time_id_sended_n,

	-- escape
	
	send_esc => '0',
	send_eop_n => send_eop_n,
		
	-- Link

	Dout => Din,
	Sout => Sin
	
 	);
 	
 	
end generate;

-- for test rx credit error

block_send_fct : if (conf_test4 = '1') generate 
Tx_Time_Code <= (others =>'0');
Tx_Send_Time <= '0', '1' after 21000 ns;
end generate;

not_send_time_id : if (conf_test4 = '0') and (conf_test29 = '0') and (conf_test38 = '0') and (conf_test99 = '0')  generate 
Tx_Send_Time <= '0';
end generate;

---------------------------------------------------------------------------
--
-- buffer time id sende by IP
--
---------------------------------------------------------------------------
process(reset_n, clk)
begin
if reset_n = '0'
then
tick_in_buffer_n <= '1';
time_in_buffer <= (others => '0');
--time_id_sended <=
else
	if clk'event and clk = '1'
	then
		if Tx_Send_Time = '1'
		then
		tick_in_buffer_n <= '0';
		time_in_buffer <= Tx_Time_Code;
		else
			if time_id_sended_n = '0'
			then
			tick_in_buffer_n <= '1';
			end if;
		end if;
	end if;
end if;
end process;

---------------------------------------------------------------------------
--
-- Map FSM
--
---------------------------------------------------------------------------
fsm_component : if conf_fsm_ip = '1' generate
fsm : entity work.fsm
port map(

	Reset_n =>	Reset_n,	
	Clk  =>	clk,	
	
	
	State => State,
	linkEnabled => linkEnabled,
	
	--input
	
	short_got_fct_n => short_got_fct_n,
	short_got_null_n => short_got_null_n,
	short_got_NChar_n => short_got_NChar_n,
	short_got_Time_n => short_got_Time_n, 
	
	
	-- input error
	
	Rx_credit_error_n =>  Rx_credit_error_n,
	Tx_credit_error_n =>  Tx_credit_error_n,
	short_Error_Dis_n => short_Error_Dis_n,
	short_Error_Par_n => short_Error_Par_n,  
	short_Error_ESC_n => short_Error_ESC_n,
	
	
	before_errorwait => before_errorwait, 
	signal_errorwait	=> signal_errorwait,
--	constante_12_8 => constante_12_8,
--	constante_3_2 => constante_3_2,
	
	view_fsm	=>	open

	
);
end generate;
 
Link_start <= '1';

remote_links_start : if (conf_test33 = '1' or 
						conf_test34 = '1' or
						conf_test35 = '1' or
						conf_test43 = '1' or
						conf_test44 = '1' or
						conf_test7 = '1')	generate						
link_Enabled <= '0','1' after 21000 ns;
end generate;

no_remote_links_start : if (conf_test33 = '0' and  
						conf_test34 = '0' and
						conf_test35 = '0' and
						conf_test43 = '0' and
						conf_test44 = '0' and
						conf_test7 = '0')	generate						
link_Enabled <= '1';
end generate;

linkEnabled <= link_Enabled and ( Link_start or (auto_start and (not short_got_null_n)));  





----------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------
--
--
--
--
--
-- COMPONENT SPACEWIRE 2
--
--
--
--
------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------






----------------------------------------------------------------------------------------
--
-- Map Rx ip
--
------------------------------------------------------------------------------------------

map_Rx_ip_2 : if (test_ip2_ip = '1' or test_ip2_emu = '1') and 
					test_emu_ip = '0' generate

Rx_ip_2 : entity work.Rx 
 port map (
 
	Reset_n =>  Remote_Reset_n_2,
	Clk => clk,
	Rx_Clk => Rx_Clk_2,

	-- Main FSM interface

	State => State,

	wd_timeout => x"0013",
	signal_errorwait	=> signal_errorwait_2,

	
	got_NULL_n  => got_NULL_n_2,
	got_ESC_n	=> got_ESC_n_2,
	got_FCT_n   => got_FCT_n_2,
	got_EOP_n	=> got_EOP_n_2, 	
	got_EEP_n => got_EEP_n_2,
	got_NChar_n => got_NChar_n_2,
	
	-- error

	Error_Par_n => Error_Par_n_2,	-- Parity error
	Error_ESC_n => Error_ESC_n_2,	-- ESC followed by ESC, EOP or EEP
	Error_Dis_n => Error_Dis_n_2,	-- Disconnected
	--Error_NChar => Error_NChar,	-- NChar received but output buffer not ready
	--Error_FCT => Error_FCT,	-- FCT received but transmitter not ready

	-- Rx Fifo interface

	Rx_FIFO_D => Rx_FIFO_D_2,
	Rx_FIFO_Wr_n => Rx_FIFO_Wr_n_2,

	-- Time Code interface

	got_Time_n  => got_Time_n_2,

	-- Link

	Din => Din,
	Sin => Sin
 	);

end generate;	
 
Remote_Reset_n_2 <= Reset_n and before_errorwait;


---------------------------------------------------------------------------
--
-- Map Rx Fifo
--
---------------------------------------------------------------------------

map_fifoRx_ip_2 : if (test_ip2_ip = '1' or test_ip2_emu = '1') and 
					test_emu_ip = '0' generate

fifoRx_ip_2 : entity work.Rx_Fifo 
generic map (
	WIDTH  => 9,
	LENGTH => 128,
	MAX_CREDIT => Rx_ip_MAX_CREDIT)
port map (
	Reset_n => reset_n_2,
	Clk => Clk,
	State => State_2,
	
	-- Credit
	Credit_Rd_n => Rx_FIFO_Credit_Rd_n_2,
	Credit_Empty_n => Rx_FIFO_Credit_Empty_n_2,
	credit_error_n => Rx_credit_error_n_2,
	
	-- Data Input
	Din => Rx_FIFO_D_2,
	Wr_n => short_Rx_FIFO_Wr_n_2,
	Full_n => Rx_Full_n_2,
	short_got_EOP_n => short_got_EOP_n_2,
	
	-- Data Output
	Dout => Rx_Dout_2,
	Rd_n => Rx_Rd_n_2,
	Empty_n => Rx_Empty_n_2,
	
	Credit => open
);	

end generate;



---------------------------------------------------------------------------
--
-- twodomainclock component after RX 2
--
---------------------------------------------------------------------------

in_width_pulse_n_vector_rx_2 <= got_EOP_n_2 & got_fct_n_2 & got_null_n_2 & got_NChar_n_2 & got_Time_n_2 & Error_Par_n_2 & Error_ESC_n_2 & Error_Dis_n_2 & Rx_FIFO_Wr_n_2;


map_twodmainclock_after_RX_2 : entity work.twodomainclock
	generic map( 
			N_short_to_width => 2,
			use_short_to_width => 0,
			N_width_to_short => 2,
			use_width_to_short => 0,
			N_short_to_width_n => 2,
			use_short_to_width_n => 0,
			N_width_to_short_n => 9,
			use_width_to_short_n => 1)					
 	port map (
 	Rst => reset_n_2,
	Clk_speed => clk,
--	Clk_slow => Rx_clk_2,
		
	in_short_pulse => (others => '0'),
	in_width_pulse => (others => '0'),
	
	out_width_pulse => open,
	out_short_pulse => open,
	
	in_short_pulse_n => (others => '1'),
	in_width_pulse_n => in_width_pulse_n_vector_rx_2, 
	
	out_width_pulse_n => open,
	out_short_pulse_n => out_short_pulse_n_vector_rx_2
	
);

short_got_EOP_n_2 <= out_short_pulse_n_vector_rx_2(8);
short_got_null_n_2 <= out_short_pulse_n_vector_rx_2(6);
short_got_fct_n_2 <= out_short_pulse_n_vector_rx_2(7);
short_Rx_FIFO_Wr_n_2  <= out_short_pulse_n_vector_rx_2(0);
short_got_NChar_n_2  <= out_short_pulse_n_vector_rx_2(5);
short_got_Time_n_2  <= out_short_pulse_n_vector_rx_2(4);
short_Error_Par_n_2  <= out_short_pulse_n_vector_rx_2(3);
short_Error_ESC_n_2  <= out_short_pulse_n_vector_rx_2(2);
short_Error_Dis_n_2 <= out_short_pulse_n_vector_rx_2(1);

---------------------------------------------------------------------------
--
-- Map Tx Fifo 2
--
---------------------------------------------------------------------------

map_fifoTx_ip_2 : if (test_ip2_ip = '1' or test_ip2_emu = '1') and 
					test_emu_ip = '0' generate

fifoTx_ip_2 : entity work.Tx_Fifo 
generic map (
	WIDTH  => 9,
	LENGTH => 128,
	MAX_CREDIT => Tx_ip_MAX_CREDIT)
port map (
	Reset_n => reset_n_2,
	Clk => clk,
	State => State_2,
	
	-- Credit
	fct_n => short_got_fct_n_2,--short_got_fct_n,
	short_send_eop_rising => short_send_eop_2,
	fct_full_n => Tx_credit_error_n_2,
	Credit_Empty_n => Tx_Credit_Empty_n_2,
	--credit_error_n => Tx_credit_error_n,
	
	-- Data Input
	Din => Tx_Din_2,
	Wr_n => Tx_Wr_n_2,
	Full_n => Tx_Full_n_2,
	
	-- Data Output
	Dout => Tx_Dout_2,
	Rd_n => Tx_FIFO_Rd_n_2,
	Empty_n => Tx_FIFO_Empty_n_2,
	
	Credit => open
);

end generate;

-- ---------------------------------------------------------------------------
-- --
-- -- twodomainclock component before TX.
-- --
-- ---------------------------------------------------------------------------

-- in_width_pulse_n_vector_tx_2 <= send_eop_n_2 & time_id_sended_width_n_2 & Rx_FIFO_Credit_Rd_width_n_2 & Tx_FIFO_Rd_width_n_2; 

-- map_twodmainclock_before_TX_2 : entity work.twodomainclock
-- 	generic map( 
-- 			N_short_to_width => 2,
-- 			use_short_to_width => 0,
-- 			N_width_to_short => 2,
-- 			use_width_to_short => 0,
-- 			N_short_to_width_n => 2,
-- 			use_short_to_width_n => 0,
-- 			N_width_to_short_n => 4,
-- 			use_width_to_short_n => 1)	
--  	port map (
--  	Rst => reset_n_2,
-- 	Clk_speed => clk,
-- 	Clk_slow => tx_clk_2,
-- 	
-- 	in_short_pulse => (others => '0'),
-- 	in_width_pulse => (others => '0'),
-- 	
-- 	out_width_pulse => open,
-- 	out_short_pulse => open,
-- 	
-- 	in_short_pulse_n => (others => '1'),
-- 	in_width_pulse_n => in_width_pulse_n_vector_tx_2, 
-- 	
-- 	out_width_pulse_n => open,
-- 	out_short_pulse_n => out_short_pulse_n_vector_tx_2		

-- 	
-- );

-- short_send_eop_2 <= out_short_pulse_n_vector_tx_2(3);
-- time_id_sended_n_2 <=  out_short_pulse_n_vector_tx_2(2);
-- Rx_FIFO_Credit_Rd_n_2 <= out_short_pulse_n_vector_tx_2(1);
-- Tx_FIFO_Rd_n_2 <= out_short_pulse_n_vector_tx_2(0); 

----------------------------------------------------------------------------------------
--
-- Map Tx ip 2
--
------------------------------------------------------------------------------------------ 	

map_TX_ip_2 : if (test_ip2_ip = '1' or test_ip2_emu = '1') and 
					test_emu_ip = '0' generate

Tx_ip_2 : entity work.Tx
 port map (
 	Reset_n =>	reset_n_2,	
	Tx_Clk  =>	clk,	
		
	-- Main FSM interface

	State => State_2,

	-- Tx Fifo interface

	Tx_FIFO_Din => Tx_Dout_2,
	Tx_FIFO_Rd_n  => Tx_FIFO_Rd_n_2,
	Tx_FIFO_Empty_n => Tx_FIFO_Empty_n_2,

	-- Rx Fifo interface ( FCT send interface )

	Rx_FIFO_Credit_Rd_n => Rx_FIFO_Credit_Rd_n_2,    -- Read one more FCT from the FIFO
	Rx_FIFO_Credit_Empty_n => Rx_FIFO_Credit_Empty_n_2,--Rx_FIFO_Credit_Empty_n,  -- true when there is no more FCT in the FIFO
	Tx_Credit_Empty_n => Tx_Credit_Empty_n_2,
	
	-- Time code

	Send_Time_n  => tick_in_buffer_n_2,--Tx_Send_Time,
	Time_Code  => time_in_buffer_2,--Tx_Time_Code,
	time_id_sended_n => time_id_sended_n_2,

	send_esc => '0',
	send_eop_n => send_eop_n_2,
	
	-- Link

	Dout => Dout,
	Sout => Sout
	
 	);
 	
end generate;

-- for test rx credit error
block_send_fct_2 : if (conf_test4 = '1') generate 
Tx_Time_Code_2 <= (others =>'0');
Tx_Send_Time_2 <= '0', '1' after 21000 ns;
end generate;

not_send_time_id_2 : if (conf_test4 = '0') and (conf_test30 = '0') and (conf_test39 = '0') and (conf_test99 = '0')  generate 
Tx_Send_Time_2 <= '0';
end generate;

---------------------------------------------------------------------------
--
-- buffer time id sende by IP 2
--
---------------------------------------------------------------------------
process(reset_n_2, clk)
begin
if reset_n_2 = '0'
then
tick_in_buffer_n_2 <= '1';
time_in_buffer_2 <= (others => '0');
else
	if clk'event and clk = '1'
	then
		if Tx_Send_Time_2 = '1'
		then
		tick_in_buffer_n_2 <= '0';
		time_in_buffer_2 <= Tx_Time_Code_2;
		else
			if time_id_sended_n_2 = '0'
			then
			tick_in_buffer_n_2 <= '1';
			end if;
		end if;
	end if;
end if;
end process;

---------------------------------------------------------------------------
--
-- Map FSM 2
--
---------------------------------------------------------------------------
fsm_component_2 : if (test_ip2_ip = '1' or test_ip2_emu = '1') and 
					test_emu_ip = '0' generate
fsm_2 : entity work.fsm
port map(

	reset_n => reset_n_2,	
	Clk  =>	clk,	
	
	State => State_2,
	linkEnabled => linkEnabled_2,
	
	--input
	
	short_got_fct_n => short_got_fct_n_2,
	short_got_null_n => short_got_null_n_2,
	short_got_NChar_n => short_got_NChar_n_2,
	short_got_Time_n => short_got_Time_n_2, 
	
	-- input error
	
	Rx_credit_error_n =>  Rx_credit_error_n_2,
	Tx_credit_error_n =>  Tx_credit_error_n_2,
	short_Error_Dis_n => short_Error_Dis_n_2,
	short_Error_Par_n => short_Error_Par_n_2,  
	short_Error_ESC_n => short_Error_ESC_n_2,
	
	before_errorwait => before_errorwait_2, 
	signal_errorwait	=> signal_errorwait_2,

	
	view_fsm => open

	
);
end generate;
 
Link_start_2 <= '1';

remote_links_start_2 : if (conf_test33 = '1' or 
						conf_test34 = '1' or
						conf_test35 = '1' or
						conf_test43 = '1' or
						conf_test44 = '1' or
						conf_test7 = '1')	generate						
link_Enabled_2 <= '0','1' after 21000 ns;
end generate;

no_remote_links_start_2 : if (conf_test33 = '0' and  
						conf_test34 = '0' and
						conf_test35 = '0' and
						conf_test43 = '0' and
						conf_test44 = '0' and
						conf_test7 = '0')	generate						
link_Enabled_2 <= '1';
end generate;

linkEnabled_2 <= link_Enabled_2 and ( Link_start_2 or (auto_start_2 and (not short_got_null_n_2)));  




----------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------
---
--
--
--
-- FILE ACCES SPACEWIRE 1
---
--
--
--
------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------






----------------------------------------------------------------------------------------
--
-- loop  read DATA file for out tx ip
--
-----------------------------------------------------------------------------------------
enable_read_file_in_ip : if conf_test31 = '0' generate
read_file_in_ip <= '1';
end generate;

shift_read_file_in_ip : if conf_test31 = '1' generate
read_file_in_ip <= '0', '1' after 1 ms;
end generate;

data_for_tx_ip : if (conf_test1 = '1' and conf_test = '0' and conf_test0 = '0') or 
					(conf_test2 = '1' and conf_test = '0' and conf_test0 = '0') or
					(conf_test31 = '1' and conf_test = '0' and conf_test0 = '0') or
					(conf_test32 = '1' and conf_test = '0' and conf_test0 = '0') or
					(conf_test36 = '1' and conf_test = '0' and conf_test0 = '0') or
					(conf_test37 = '1' and conf_test = '0' and conf_test0 = '0') or
					(conf_test38 = '1' and conf_test = '0' and conf_test0 = '0') or
					conf_test99 = '1'  generate  

process

------------------------------------------------------------------
file file_in_ip : text;
variable l : line;
variable Value : integer;--std_logic_vector(7 downto 0);
-------------------------------------------------------------------
begin
Tx_Din <= (others =>'0');
Tx_Wr_n <= '1';

file_open(file_in_ip, "in_ip.txt", READ_MODE);
wait until reset_n = '0' and reset_n'event;
	loop
  	wait until (clk='1' and clk'event) and read_file_in_ip = '1';
  	
		if Tx_Full_n = '1' and Tx_Wr_n = '1'  and (not endfile(file_in_ip)) 
		then	
 		Tx_Wr_n <= '0';
 		readline(file_in_ip,l );
 		read(l ,value);
 		Tx_Din(7 downto 0) <= conv_std_logic_vector(value,8);
 		Tx_Din(8) <= eop_bit;
		else
		Tx_Wr_n <= '1';
		end if;
		
	end loop;
end process;

end generate;

----------------------------------------------------------------------------------------
--
-- loop  write DATA file  for out rx ip
--
-----------------------------------------------------------------------------------------

out_file_rx_ip : if conf_test3 = '0' generate
write_file_out_ip: process
------------------------------------------------------------------
file file_out_ip : text;
variable l : line;
variable Value : integer;--std_logic_vector(7 downto 0);
-------------------------------------------------------------------

begin-------------begin of process-----
file_open(file_out_ip, "out_ip.txt", WRITE_MODE);
Rx_Rd_n <= '1';	 
wait until reset_n = '1' and reset_n'event;

 	loop
   	wait until (clk='1' and clk'event) ;
  		if (Rx_Rd_n = '1') and (Rx_Empty_n = '1')
  		then 
  		Rx_Rd_n <= '0';	
        else
        	Rx_Rd_n <= '1';
        		if (Rx_Empty_n = '1')
        		then
        		Value := conv_integer(Rx_Dout);  
  	   			--value := Rx_Dout;
   				write(l, Value); 
        		writeline(file_out_ip, l);
        		end if;
        end if;  
     end loop;-----------------------------------------------------
end process;------------------------------------------------------

end generate;

-- for test rx credit error
block_read_ip : if conf_test4 = '1' or conf_test3 = '1'  generate
Rx_Rd_n <= '1';
end generate;

----------------------------------------------------------------------------------------
--
-- loop  read file for out tx ip send TIME ID
--
-----------------------------------------------------------------------------------------

time_for_tx_ip : if conf_test29 = '1' or conf_test38 = '1' or conf_test99 = '1'    generate  

process

------------------------------------------------------------------
file file_in_ip_time : text;
variable l : line;
variable Value : integer;--std_logic_vector(7 downto 0);
variable count :integer;
-------------------------------------------------------------------
begin

Tx_Time_Code <= (others => '0');
Tx_Send_Time <= '0';
count := 0;
file_open(file_in_ip_time, "in_ip_time.txt", READ_MODE);
wait until reset_n = '0' and reset_n'event;
	loop
  	wait until (clk='1' and clk'event) and state = S_run;
		if  Tx_Send_Time = '1'  --and count >14 
		then	
 		Tx_Send_Time  <= '0';
		else
			if count > 200 and (not endfile(file_in_ip_time)) 
			then
			Tx_Send_Time <= '1';
			readline(file_in_ip_time,l );
 			read(l ,value);
 			Tx_Time_Code <= conv_std_logic_vector(value,8);
 			count := 0;
			else
			count := count + 1;
			Tx_Send_Time <= '0';
			end if;
		end if;		
	end loop;
end process;

end generate;


----------------------------------------------------------------------------------------
--
-- loop  write file TIME ID become out of RX ip
--
-----------------------------------------------------------------------------------------

out_ip_time_id : if conf_test30 = '1' or conf_test39 = '1' or conf_test99 = '1'    generate  
write_file_out_ip: process
------------------------------------------------------------------
file out_ip_time : text;
variable l : line;
variable Value : integer;--std_logic_vector(7 downto 0);

-------------------------------------------------------------------

begin-------------begin of process-----
file_open(out_ip_time, "out_ip_time.txt", WRITE_MODE); 
wait until reset_n = '0' and reset_n'event;
 	loop
   	wait until (clk='1' and clk'event) ;
  		if (short_got_Time_n = '0') 
  		then 
 		Value := conv_integer(Rx_FIFO_D);  
  	   	write(l, Value); 
        writeline(out_ip_time, l);
        end if;  
     end loop;-----------------------------------------------------
end process;------------------------------------------------------
end generate;






----------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------
--
-- FILE ACCES SPACEWIRE 2
--
------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------







----------------------------------------------------------------------------------------
--
-- loop  read DATA file for out tx ip 2
--
-----------------------------------------------------------------------------------------
enable_read_file_in_ip_2 : if conf_test31 = '0' generate
read_file_in_ip_2 <= '1';
end generate;

shift_read_file_in_ip_2 : if conf_test31 = '1' generate
read_file_in_ip_2 <= '0', '1' after 1 ms;
end generate;

data_for_tx_ip_2 : if (conf_test0 = '1' and conf_test = '0') 
					or (conf_test2 = '1' and conf_test = '0')
					or (conf_test3 = '1' and conf_test = '0')    
					or (conf_test31 = '1' and conf_test = '0')   
					or (conf_test32 = '1' and conf_test = '0')
					or (conf_test36 = '1' and conf_test = '0')
					or (conf_test37 = '1' and conf_test = '0') 
					or (conf_test39 = '1' and conf_test = '0')    generate  

process

------------------------------------------------------------------
file file_in_ip_2 : text;
variable l : line;
variable Value : integer;--std_logic_vector(7 downto 0);
-------------------------------------------------------------------
begin
Tx_Din_2 <= (others =>'0');
Tx_Wr_n_2 <= '1';

file_open(file_in_ip_2, "in_ip_2.txt", READ_MODE);
wait until reset_n = '0' and reset_n'event;
	loop
  	wait until (clk='1' and clk'event) and read_file_in_ip_2 = '1';
  	
		if Tx_Full_n_2 = '1' and Tx_Wr_n_2 = '1'  and (not endfile(file_in_ip_2)) 
		then	
 		Tx_Wr_n_2 <= '0';
 		readline(file_in_ip_2,l );
 		read(l ,value);
 		Tx_Din_2(7 downto 0) <= conv_std_logic_vector(value,8);
 		Tx_Din_2(8) <= '0';
		else
		Tx_Wr_n_2 <= '1';
		end if;
		
	end loop;
end process;

end generate;

----------------------------------------------------------------------------------------
--
-- loop  write DATA file  for out rx ip
--
-----------------------------------------------------------------------------------------

out_file_rx_ip_2 : if conf_test3 = '0' generate
write_file_out_ip_2: process
------------------------------------------------------------------
file file_out_ip_2 : text;
variable l : line;
variable Value : integer;--std_logic_vector(7 downto 0);
-------------------------------------------------------------------

begin-------------begin of process-----
file_open(file_out_ip_2, "out_ip_2.txt", WRITE_MODE);
--Rx_Rd_n_2 <= '1';	 
wait until reset_n = '1' and reset_n'event;

 	loop
   	wait until (clk='1' and clk'event) ;
  		if (Rx_Rd_n_2 = '1') and (Rx_Empty_n_2 = '1')
  		then 
  		--Rx_Rd_n_2 <= '0';	
        else
        	--Rx_Rd_n_2 <= '1';
        		if (Rx_Empty_n_2 = '1')
        		then
        		Value := conv_integer(Rx_Dout_2);  
  	   			--value := Rx_Dout;
   				write(l, Value); 
        		writeline(file_out_ip_2, l);
        		end if;
        end if;  
     end loop;-----------------------------------------------------
end process;------------------------------------------------------

end generate;

-- for test rx credit error
block_read_ip_2 : if conf_test4 = '1' or conf_test3 = '1'  generate
Rx_Rd_n_2 <= '1';
end generate;

----------------------------------------------------------------------------------------
--
-- loop  read file for out tx ip send TIME ID
--
-----------------------------------------------------------------------------------------

time_for_tx_ip_2 : if conf_test30 = '1' or conf_test39 = '1' generate  

process

------------------------------------------------------------------
file file_in_ip_time_2 : text;
variable l : line;
variable Value : integer;--std_logic_vector(7 downto 0);
variable count_2 :integer;
-------------------------------------------------------------------
begin

Tx_Time_Code_2 <= (others => '0');
Tx_Send_Time_2 <= '0';
count_2 := 0;
file_open(file_in_ip_time_2, "in_ip_time_2.txt", READ_MODE);
wait until reset_n = '0' and reset_n'event;
	loop
  	wait until (clk='1' and clk'event) and state_2 = S_run;
		if  Tx_Send_Time_2 = '1'  --and count >14 
		then	
 		Tx_Send_Time_2  <= '0';
		else
			if count_2 > 200 and (not endfile(file_in_ip_time_2)) 
			then
			Tx_Send_Time_2 <= '1';
			readline(file_in_ip_time_2,l );
 			read(l ,value);
 			Tx_Time_Code_2 <= conv_std_logic_vector(value,8);
 			count_2 := 0;
			else
			count_2 := count_2 + 1;
			Tx_Send_Time_2 <= '0';
			end if;
		end if;		
	end loop;
end process;

end generate;

----------------------------------------------------------------------------------------
--
-- loop  write file TIME ID become out of RX ip
--
-----------------------------------------------------------------------------------------

out_ip_time_id_2 : if conf_test29 = '1' or conf_test38 = '1'   generate 
write_file_out_ip_2: process
------------------------------------------------------------------
file out_ip_time_2 : text;
variable l : line;
variable Value : integer;--std_logic_vector(7 downto 0);

-------------------------------------------------------------------

begin-------------begin of process-----
file_open(out_ip_time_2, "out_ip_time_2.txt", WRITE_MODE); 
wait until reset_n = '0' and reset_n'event;
 	loop
   	wait until (clk='1' and clk'event) ;
  		if (short_got_Time_n_2 = '0') 
  		then 
 		Value := conv_integer(Rx_FIFO_D_2);  
  	   	write(l, Value); 
        writeline(out_ip_time_2, l);
        end if;  
     end loop;-----------------------------------------------------
end process;------------------------------------------------------
end generate;


----------------------------------------------------------------------------------------
--
-- watch credit error in Rx fifo ip for log file  and console
--
-----------------------------------------------------------------------------------------

process(Rx_credit_error_n)
variable MyLine : line;
variable ligne : string(1 to 52);

begin
if Rx_credit_error_n'event and Rx_credit_error_n = '0'
then
ligne := "----------------CREDIT ERROR IN RX FIFO APPEARE-----";  
log(ligne);
write (MyLine,string'("-------CREDIT ERROR IN RX FIFO APPEARE------- "));
writeline(output,Myline);
end if;
end process;

----------------------------------------------------------------------------------------
--
-- watch full rx fifo for log file  and console
--
-----------------------------------------------------------------------------------------

process(Rx_Full_n)
variable MyLine : line;
variable ligne : string(1 to 52);

begin
if Rx_Full_n'event and Rx_Full_n = '0' and State /= S_ErrorReset
then  
ligne := "------------------FULL APPEARE in RX fifo-----------";  
log(ligne);
write (MyLine,string'("-------FULL APPEARE in RX fifo------- "));
writeline(output,Myline);
end if;
end process;
	  
----------------------------------------------------------------------------------------
--
-- watch credit error in Tx fifo ip for log file  and console
--
-----------------------------------------------------------------------------------------

process(Tx_credit_error_n)
variable MyLine : line;
variable ligne : string(1 to 52);

begin
if Tx_credit_error_n'event and Tx_credit_error_n = '0'
then
ligne := "----------------CREDIT ERROR IN TX FIFO APPEARE-----";  
log(ligne);
write (MyLine,string'("-------CREDIT ERROR IN TX FIFO APPEARE------- "));
writeline(output,Myline);
end if;
end process;

----------------------------------------------------------------------------------------
--
-- watch state for log file and console
--
-----------------------------------------------------------------------------------------

enable_watch_state : if conf_test3 = '0' and 
						conf_test4 = '0' and 
						conf_test5 = '0'  generate 

process(state)
variable MyLine : line;
variable count_fsm_message : integer := 0;
variable ligne : string(1 to 52);

begin
count_fsm_message := count_fsm_message+1;
if count_fsm_message < 15
then
	if state = S_ErrorReset
	then
	write (MyLine,string'("------ERROR RESET STATE------- "));
	writeline(output,Myline);
	ligne := "----------------ERROR RESET STATE-------------------"; 
	log(ligne);
	else
		if state = S_ErrorWait
		then
		write (MyLine,string'("------error wait state ------- "));
		ligne := "---------------error wait state --------------------";
		log(ligne);
		writeline(output,Myline);
		else
			if state = S_Ready
			then
			write (MyLine,string'("------ready state------- "));
			ligne := "----------------ready state-------------------------";
			log(ligne);
			writeline(output,Myline);
			else
				if state = S_Started 
				then
				write (MyLine,string'("------started state------- "));
				writeline(output,Myline);
				ligne := "---------started state------------------------------";
				log(ligne);
				else
					if state = S_Connecting 
					then
					write (MyLine,string'("------connecting state------- "));
					writeline(output,Myline);
					ligne := "---------connecting state---------------------------";
					log(ligne);
					else
						if state = S_run
						then
						write (MyLine,string'("------run state------- "));
						writeline(output,Myline);
						ligne := "---------run state----------------------------------";
						log(ligne);
						end if;
					end if;
				end if;
			end if;
		end if;
	end if;
end if;
end process;
end generate;

-- IP loop

out_to_in_ip_disconnect : if conf_test42 = '1' generate
RX_ip_Dout <= Din and gen_disc_err;
RX_ip_Sout <= Sin and gen_disc_err;
end generate;

out_to_in_ip_eop_test : if conf_test99 = '1' generate
RX_ip_Dout <= Din;
RX_ip_Sout <= Sin;
end generate;

----------------------------------------------------------------------------------------
--
-- manage signal disconnect
--
----------------------------------------------------------------------------------------- 

-- manage signal disconnect 
connect_disconnect : if conf_test6 = '1' or conf_test7 = '1' or conf_test8 = '1' or conf_test9 = '1' or conf_test10 = '1'    generate
RX_ip_Dout <= Dout and  gen_disc_err;
RX_ip_Sout <= Sout and  gen_disc_err;
end generate;

not_connect_disconnect : if  conf_test6 = '0' and conf_test7 = '0' and conf_test8 = '0' and conf_test9 = '0' and conf_test10 = '0' and conf_test42 = '0' and conf_test99 = '0'  generate
RX_ip_Dout <= Dout;
RX_ip_Sout <= Sout;
gen_disc_err <= '0';
end generate;



disconnect_errro_wait_state : if conf_test6 = '1' generate
gen_disc_err <= '1','0' after 7220 ns,'1' after 10000 ns;
end generate;

disconnect_ready_state : if conf_test7 = '1' generate
gen_disc_err <= '1','0' after 18412 ns, '1' after 22412 ns;
end generate;

disconnect_started_state : if conf_test8 = '1' generate
gen_disc_err <= '1','0' after 18550 ns, '1' after 21500 ns;
end generate;

disconnect_connecting_state : if conf_test9 = '1' generate
gen_disc_err <= '1','0' after 20500 ns ,'1' after 23000 ns;
end generate;

disconnect_run_state : if conf_test10 = '1' generate
gen_disc_err <= '1','0' after 40000 ns,'1' after 80000 ns;
end generate;

disconnect_on_ip_reboucle : if conf_test42 = '1' generate
gen_disc_err <= '1','0' after 31000 ns ,'1' after 33000 ns;
end generate;


----------------------------------------------------------------------------------------
--
-- watch disconnect for log file  and console
--
----------------------------------------------------------------------------------------- 

disconnect_log : if conf_test6 = '1' or 
					conf_test7 = '1' or 
					conf_test8 = '1' or
					conf_test9 = '1' or
					conf_test10 = '1' generate
process(Error_Dis_n)
variable MyLine : line;
variable count_fsm_message : integer := 0;
variable ligne : string(1 to 52);

begin
if Error_Dis_n = '0' and count_fsm_message < 1 and conf_test6 = '1' and state = S_ErrorWait
then
write (MyLine,string'("------generate disconnect in Error wait state------"));
writeline(output,Myline);
ligne := "-----disconnect appear in Error wait state----------";
log(ligne);
count_fsm_message := count_fsm_message+1; 
else
	if Error_Dis_n = '0' and count_fsm_message < 1 and conf_test7 = '1' and state = S_Ready
	then
	write (MyLine,string'("------generate disconnect in ready state------"));
	writeline(output,Myline);
	ligne := "-----disconnect appear in ready state---------------";
	log(ligne);
	count_fsm_message := count_fsm_message+1; 
	else
		if Error_Dis_n = '0' and count_fsm_message < 1 and conf_test8 = '1' and state = S_Started
		then
		write (MyLine,string'("------generate disconnect in started state------"));
		writeline(output,Myline);
		ligne := "----disconnect appear in started state--------------";
		log(ligne);
		count_fsm_message := count_fsm_message+1; 
		else
			if Error_Dis_n = '0'  and count_fsm_message < 1 and conf_test9 = '1' and state = S_Connecting
			then
			write (MyLine,string'("------generate disconnect in connecting state------"));
			writeline(output,Myline);
			ligne := "-----disconnect appear in connecting state----------";
			log(ligne);
			count_fsm_message := count_fsm_message+1; 
			else
				if Error_Dis_n = '0' and count_fsm_message < 1 and conf_test10 = '1' and state = S_Run
				then
				write (MyLine,string'("------generate disconnect in Run state------"));
				writeline(output,Myline);
				ligne := "--------disconnect appear in Run state--------------";
				log(ligne);
				count_fsm_message := count_fsm_message+1;
				end if;
			end if;
		end if;
	end if;		
end if;
end process;
end generate;

----------------------------------------------------------------------------------------
--
-- watch short_got for log file  and console
--
----------------------------------------------------------------------------------------- 
	
enable_watch_short_got : if conf_test2 = '0' and 
							conf_test1 = '0' and 
							conf_test0 = '0' and 
							conf_test3 = '0' and
						  	conf_test4 = '0' and 
						  	conf_test5 = '0' and 
						  	conf_test7 = '0' and
						  	conf_test8 = '0' and
						  	conf_test9 = '0' and 
						  	conf_test10 = '0' and
						  	conf_test30 = '0' and
						  	conf_test31 = '0' and 
						  	conf_test32 = '0' and
						  	conf_test36 = '0' and  
						  	conf_test37 = '0' and 
						  	conf_test38 = '0' and 
						  	conf_test99 = '0' and
						  	conf_test39 = '0' generate 

process(short_got_null_n, short_got_fct_n, short_got_NChar_n, short_got_Time_n, short_Error_Par_n, short_Error_ESC_n,short_Error_ESC_n)
variable MyLine : line;
variable ligne : string(1 to 52);

begin
--count_fsm_message := count_fsm_message+1;
--if count_fsm_message < 12
--then
-- 	if short_got_null_n = '0'
-- 	then
-- 	ligne := "---------------------null is appear in rx-----------";
-- 	log(ligne);
-- 	write (MyLine,string'("------null is appear in rx------- "));
-- 	writeline(output,Myline);
-- 	else
		if short_got_fct_n = '0'
		then
		ligne := "--------------fct is appear in rx-------------------";
		log(ligne);
		write (MyLine,string'("------fct is appear in rx------- "));
		writeline(output,Myline);
		else
			if short_got_NChar_n = '0'
			then
			ligne := "---------char is appear in rx-----------------------";
			log(ligne);
			write (MyLine,string'("------char is appear in rx------- "));
			writeline(output,Myline);
			else
				if short_got_Time_n = '0' 
				then
				ligne := "--------time id is appear in rx---------------------";
				log(ligne);
				write (MyLine,string'("------time id is appear in rx------- "));
				writeline(output,Myline);
				end if;
			end if;
		end if;
--	end if;
--end if;
end process;
end generate;

----------------------------------------------------------------------------------------
--
-- short got error for log file  and console
--
----------------------------------------------------------------------------------------- 

enable_watch_short_got_error : if conf_test21 = '1' or
								conf_test22 = '1' or 
								conf_test23 = '1' or 
								conf_test24 = '1' or
								conf_test25 = '1' or
								conf_test26 = '1' or
								conf_test27 = '1' or
								conf_test28 = '1'  or
								conf_test40 = '1'  or
								conf_test43 = '1' or
								conf_test44 = '1' or
								conf_test41 = '1'  generate 

process(short_Error_Par_n,short_Error_ESC_n)
variable ligne : string(1 to 52);
variable MyLine : line;
begin								
if short_Error_Par_n = '0'
then
ligne := "--------rx generate error parity--------------------";
log(ligne);
write (MyLine,string'("------rx generate error parity------- "));
writeline(output,Myline);
else
	if short_Error_ESC_n = '0'
	then
		ligne := "--------rx generate error escape--------------------";
		log(ligne);
		write (MyLine,string'("------rx generate error escape------- "));
		writeline(output,Myline);
	end if;
end if;	
end process;
end generate;							
								

----------------------------------------------------------------------------------------
--
-- write test for log file  and console
--
----------------------------------------------------------------------------------------- 
 

process
variable ligne : string(1 to 52);
variable count : std_logic := '0';
begin
loop
wait until reset_n = '0' and reset_n'event;
	if conf_test = '1' and count = '0'
	then
	ligne := "----------------------------------------------------";
	log(ligne);
	ligne := "TEST------TEST INITIALISATION ENTRE IP2 ET IP-------";
	log(ligne);
	ligne := "----------------------------------------------------";
	log(ligne);
	count := '1';
	else
		if conf_test0 = '1' and count = '0'
		then
		ligne := "----------------------------------------------------";
		log(ligne);
		ligne := "TEST0------IP2 ENVOI des donnees a l'IP-------------";
		log(ligne);
		ligne := "----------------------------------------------------";
		log(ligne);
		count := '1';
		else
			if conf_test1 = '1' and count = '0'
			then
			ligne := "----------------------------------------------------";
			log(ligne);
			ligne := "TEST1----L'IP ENVOI des donnees a IP2---------------";
			log(ligne);
			ligne := "----------------------------------------------------";
			log(ligne);
			count := '1';
			else
				if conf_test2 = '1' and count = '0'
				then
				ligne := "----------------------------------------------------";
				log(ligne);
				ligne := "ENVOI bidirectionnel de données entre IP2 et l'IP---";
				log(ligne);
				ligne := "----------------------------------------------------";
				log(ligne);
				count := '1';
				else
					if conf_test3 = '1' and count = '0'
					then
					ligne := "----------------------------------------------------";
					log(ligne);
					ligne := "TEST3-------TEST FULL FIFO RX IP--------------------";
					log(ligne);
					ligne := "----------------------------------------------------";
					log(ligne);
					count := '1';
					else
						if conf_test4 = '1' and count = '0'
						then
						ligne := "----------------------------------------------------";
						log(ligne);
						ligne := "TEST4------TEST CREDIT ERROR in RX IP---------------";
						log(ligne);
						ligne := "----------------------------------------------------";
						log(ligne);
						count := '1';
						else
							if conf_test5 = '1' and count = '0'
							then
							ligne := "----------------------------------------------------";
							log(ligne);
							ligne := "TEST5-------TEST CREDIT ERROR in TX IP--------------";
							log(ligne);
							ligne := "----------------------------------------------------";
							log(ligne);
							count := '1';
							else
								if conf_test6 = '1' and count = '0'
								then
								ligne := "----------------------------------------------------";
								log(ligne);
								ligne := "TEST6--TEST DISCONNECT ERROR IN ErrorWAIT STATE-----";
								log(ligne);
								ligne := "----------------------------------------------------";
								log(ligne);
								count := '1';
								else
									if conf_test7 = '1' and count = '0'
									then
									ligne := "----------------------------------------------------";
									log(ligne);
									ligne := "TEST7---TEST DISCONNECT ERROR IN Ready STATE--------";
									log(ligne);
									ligne := "----------------------------------------------------";
									log(ligne);
									count := '1';
									else
										if conf_test8 = '1' and count = '0'
										then
										ligne := "----------------------------------------------------";
										log(ligne);
										ligne := "TEST8TEST DISCONNECT ERROR IN STARTED STATE---------";
										log(ligne);
										ligne := "----------------------------------------------------";
										log(ligne);
										count := '1';
										else
											if conf_test9 = '1' and count = '0'
											then
											ligne := "----------------------------------------------------";
											log(ligne);
											ligne := "TEST9TEST DISCONNECT ERROR IN CONNECTING STATE------";
											log(ligne);
											ligne := "----------------------------------------------------";
											log(ligne);
											count := '1';
											else
												if conf_test10 = '1' and count = '0'
												then
												ligne := "----------------------------------------------------";
												log(ligne);
												ligne := "TEST10---TEST DISCONNECT ERROR IN RUN STATE --------";
												log(ligne);
												ligne := "----------------------------------------------------";
												log(ligne);
												count := '1';
												else
													if conf_test11 = '1' and count = '0'
													then
													ligne := "----------------------------------------------------";
													log(ligne);
													ligne := "TEST11TEST continuous CHAR ERROR since reset--------";
													log(ligne);
													ligne := "----------------------------------------------------";
													log(ligne);
													count := '1';
													else
														if conf_test12 = '1' and count = '0'
														then
														ligne := "----------------------------------------------------";
														log(ligne);
														ligne := "TEST12-TEST receive FCT ERROR in ErrorWait----------";
														log(ligne);
														ligne := "----------------------------------------------------";
														log(ligne);
														count := '1';
														else
															if conf_test13 = '1' and count = '0'
															then
															ligne := "----------------------------------------------------";
															log(ligne);
															ligne := "TEST13TEST receive TIME ID ERROR in ErrorWait-------";
															log(ligne);
															ligne := "----------------------------------------------------";
															log(ligne);
															count := '1';
															else
																if conf_test14 = '1' and count = '0'
																then
																ligne := "----------------------------------------------------";
																log(ligne);
																ligne := "TEST14--TEST receive CHAR ID ERROR in ErrorWait-----";
																log(ligne);
																ligne := "----------------------------------------------------";
																log(ligne);
																count := '1';
																else
																	if conf_test15 = '1' and count = '0'
																	then
																	ligne := "----------------------------------------------------";
																	log(ligne);
																	ligne := "TEST15TEST receive FCT ERROR in ErrorWait-----------";
																	log(ligne);
																	ligne := "----------------------------------------------------";
																	log(ligne);
																	count := '1';
																	else
																		if conf_test16 = '1' and count = '0'
																		then
																		ligne := "----------------------------------------------------";
																		log(ligne);
																		ligne := "TEST16TEST receive TIME ID ERROR in started state---";
																		log(ligne);
																		ligne := "----------------------------------------------------";
																		log(ligne);
																		count := '1';
																		else
																			if conf_test17 = '1' and count = '0'
																			then
																			ligne := "----------------------------------------------------";
																			log(ligne);
																			ligne := "TEST17TEST receive DATA ERROR in started state------";
																			log(ligne);
																			ligne := "----------------------------------------------------";
																			log(ligne);
																			count := '1';
																			else
																				if conf_test18 = '1' and count = '0'
																				then
																				ligne := "----------------------------------------------------";
																				log(ligne);
																				ligne := "TEST18-TEST receive FCT ERROR in started state------";
																				log(ligne);
																				ligne := "----------------------------------------------------";
																				log(ligne);
																				count := '1';
																				else
																					if conf_test19 = '1' and count = '0'
																					then
																					ligne := "----------------------------------------------------";
																					log(ligne);
																					ligne := "TEST19-TEST receive DATA in connecting state--------";
																					log(ligne);
																					ligne := "----------------------------------------------------";
																					log(ligne);
																					count := '1';
																					else
																						if conf_test20 = '1' and count = '0'
																						then
																						ligne := "----------------------------------------------------";
																						log(ligne);
																						ligne := "TEST20-TEST receive TIME ID in connecting state-----";
																						log(ligne);
																						ligne := "----------------------------------------------------";
																						log(ligne);
																						count := '1';
																						else
																							if conf_test21 = '1' and count = '0'
																							then
																							ligne := "----------------------------------------------------";
																							log(ligne);
																							ligne := "TEST21-TEST parity error in error wait state--------";
																							log(ligne);
																							ligne := "----------------------------------------------------";
																							log(ligne);
																							count := '1';
																							else
																								if conf_test22 = '1' and count = '0'
																								then
																								ligne := "----------------------------------------------------";
																								log(ligne);
																								ligne := "TEST22--TEST esc error in error wait state----------";
																								log(ligne);
																								ligne := "----------------------------------------------------";
																								log(ligne);
																								count := '1';
																								else
																									if conf_test23 = '1' and count = '0'
																									then
																									ligne := "----------------------------------------------------";
																									log(ligne);
																									ligne := "TEST23-TEST parity error in started state-----------";
																									log(ligne);
																									ligne := "----------------------------------------------------";
																									log(ligne);
																									count := '1';
																									else
																										if conf_test24 = '1' and count = '0'
																										then
																										ligne := "----------------------------------------------------";
																										log(ligne);
																										ligne := "TEST24-----TEST esc error in started state----------";
																										log(ligne);
																										ligne := "----------------------------------------------------";
																										log(ligne);
																										count := '1';
																										else
																											if conf_test25 = '1' and count = '0'
																											then
																											ligne := "----------------------------------------------------";
																											log(ligne);
																											ligne := "TEST25-TEST parity error in connecting state--------";
																											log(ligne);
																											ligne := "----------------------------------------------------";
																											log(ligne);
																											count := '1';
																											else
																												if conf_test26 = '1' and count = '0'
																												then
																												ligne := "----------------------------------------------------";
																												log(ligne);
																												ligne := "TEST26-TEST esc error in connecting state-----------";
																												log(ligne);
																												ligne := "----------------------------------------------------";
																												log(ligne);
																												count := '1';
																												else
																													if conf_test27 = '1' and count = '0'
																													then
																													ligne := "----------------------------------------------------";
																													log(ligne);
																													ligne := "----TEST27 parity error in Run state----------------";
																													log(ligne);
																													ligne := "----------------------------------------------------";
																													log(ligne);
																													count := '1';
																													else
																														if conf_test28 = '1' and count = '0'
																														then
																														ligne := "----------------------------------------------------";
																														log(ligne);
																														ligne := "--------------TEST28 esc error in Run state---------";
																														log(ligne);
																														ligne := "----------------------------------------------------";
																														log(ligne);
																														count := '1';
																														else
																															if conf_test29 = '1' and count = '0'
																															then
																															ligne := "----------------------------------------------------";
																															log(ligne);
																															ligne := "TEST29--IP send time id to IP2----------------------";
																															log(ligne);
																															ligne := "----------------------------------------------------";
																															log(ligne);
																															count := '1';
																															else
																																if conf_test30 = '1' and count = '0'
																																then
																																ligne := "----------------------------------------------------";
																																log(ligne);
																																ligne := "TEST30-----IP2 send time id to IP-------------------";
																																log(ligne);
																																ligne := "----------------------------------------------------";
																																log(ligne);
																																count := '1';
																																else
																																	if conf_test31 = '1' and count = '0'
																																	then
																																	ligne := "----------------------------------------------------";
																																	log(ligne);
																																	ligne := "--IP2 - IP full duplex shifted, IP send after IP2---";
																																	log(ligne);
																																	ligne := "----------------------------------------------------";
																																	log(ligne);
																																	count := '1';
																																	else
																																		if conf_test32 = '1' and count = '0'
																																		then
																																		ligne := "----------------------------------------------------";
																																		log(ligne);
																																		ligne := "----IP2 - IP full duplex shifted, IP2 send after IP-";
																																		log(ligne);
																																		ligne := "----------------------------------------------------";
																																		log(ligne);
																																		count := '1';
																																		else
																																			if conf_test33 = '1' and count = '0'
																																			then
																																			ligne := "----------------------------------------------------";
																																			log(ligne);
																																			ligne := "TEST33 TEST receive FCT ERROR in READY state--------";
																																			log(ligne);
																																			ligne := "----------------------------------------------------";
																																			log(ligne);
																																			count := '1';
																																			else
																																				if conf_test34 = '1' and count = '0'
																																				then
																																				ligne := "----------------------------------------------------";
																																				log(ligne);
																																				ligne := "TEST34 TEST receive char ERROR in READY state-------";
																																				log(ligne);
																																				ligne := "----------------------------------------------------";
																																				log(ligne);
																																				count := '1';
																																				else
																																					if conf_test35 = '1' and count = '0'
																																					then
																																					ligne := "----------------------------------------------------";
																																					log(ligne);
																																					ligne := "TEST35 TEST receive time-id ERROR in READY state----";
																																					log(ligne);
																																					ligne := "----------------------------------------------------";
																																					log(ligne);
																																					count := '1';
																																					else
																																						if conf_test36 = '1' and count = '0'
																																						then
																																						ligne := "----------------------------------------------------";
																																						log(ligne);
																																						ligne := "TEST36 full duplex reset IP after reset IP2---------";
																																						log(ligne);
																																						ligne := "----------------------------------------------------";
																																						log(ligne);
																																						count := '1';
																																						else
																																							if conf_test37 = '1' and count = '0'
																																							then
																																							ligne := "----------------------------------------------------";
																																							log(ligne);
																																							ligne := "TEST37 full duplex reset IP2-- after reset IP-------";
																																							log(ligne);
																																							ligne := "----------------------------------------------------";
																																							log(ligne);
																																							count := '1';
																																							else
																																								if conf_test38 = '1' and count = '0'
																																								then
																																								ligne := "----------------------------------------------------";
																																								log(ligne);
																																								ligne := "--TEST38 ip to IP2-- send mixe time id and data id--";
																																								log(ligne);
																																								ligne := "----------------------------------------------------";
																																								log(ligne);
																																								count := '1';
																																								else
																																									if conf_test39 = '1' and count = '0'
																																									then
																																									ligne := "----------------------------------------------------";
																																									log(ligne);
																																									ligne := "---TEST39 IP2 send to ip mixe time id and data id---";
																																									log(ligne);
																																									ligne := "----------------------------------------------------";
																																									log(ligne);
																																									count := '1';
																																									else
																																										if conf_test40 = '1' and count = '0'
																																										then
																																										ligne := "----------------------------------------------------";
																																										log(ligne);
																																										ligne := "--TEST40 esc+eop escape error in error wait state---";
																																										log(ligne);
																																										ligne := "----------------------------------------------------";
																																										log(ligne);
																																										count := '1';
																																										else
																																											if conf_test41 = '1' and count = '0'
																																											then
																																											ligne := "----------------------------------------------------";
																																											log(ligne);
																																											ligne := "--TEST41 esc+eep escape error in error wait state---";
																																											log(ligne);
																																											ligne := "----------------------------------------------------";
																																											log(ligne);
																																											count := '1';
																																											else
																																												if conf_test42 = '1' and count = '0'
																																												then
																																												ligne := "----------------------------------------------------";
																																												log(ligne);
																																												ligne := "-----TEST42 out to in ip with disconnect------------";
																																												log(ligne);
																																												ligne := "----------------------------------------------------";
																																												log(ligne);
																																												count := '1';
																																												else
																																													if conf_test99 = '1' and count = '0'
																																													then
																																													ligne := "----------------------------------------------------";
																																													log(ligne);
																																													ligne := "-----TEST a EFFECTUER A 33 MHZ----------------------";
																																													log(ligne);
																																													ligne := "-----TEST43 out to in ip with data, eop, time id----";
																																													log(ligne);
																																													ligne := "----------------------------------------------------";
																																													log(ligne);
																																													count := '1';
																																													else
																																														if conf_test43 = '1' and count = '0'
																																														then
																																														ligne := "----------------------------------------------------";
																																														log(ligne);
																																														ligne := "TEST43-TEST parity error in ready state-------------";
																																														log(ligne);
																																														ligne := "----------------------------------------------------";
																																														log(ligne);
																																														count := '1';
																																														else
																																															if conf_test44 = '1' and count = '0'
																																															then
																																															ligne := "----------------------------------------------------";
																																															log(ligne);
																																															ligne := "TEST44-----TEST esc error in ready state------------";
																																															log(ligne);
																																															ligne := "----------------------------------------------------";
																																															log(ligne);
																																															count := '1';
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
end loop;
end process;

process
variable count : integer := 0;
variable ligne : string(1 to 52);
begin
loop
wait until (clk='1' and clk'event);
	if count = 39000
	then
	ligne := "----------------------------------------------------";
	log(ligne);
	ligne := "####################################################";
	log(ligne);
	count := count + 1;
	else
	count := count + 1;
	end if;
end loop;
end process;

m_axis_tready <= '1';



RMAP_Decoder_inst : entity work.RMAP_Decoder
        port map (
            clk         => Clk,          
            reset_n     => Reset_n_2,      
            Rx_Dout     => Rx_Dout_2,      
            Rx_Empty_n  => Rx_Empty_n_2,   
            buffer_full => fifo_full,
            Rx_Rd_n     => Rx_Rd_n_2,      
            buffer_wr_en => buffer_wr_en,
            buffer_data => buffer_data   
        );

--FIFO_buffer_inst : entity work.FIFO_buffer
--        generic map (
--            DATA_WIDTH => 8,  
--            FIFO_DEPTH => 517  
--        )
--        port map (
--            clk      => clk,
--            reset_n  => reset_n,
--            write_en => buffer_wr_en,
--            data_in  => buffer_data,
--            read_en  => read_en,
--            data_out => fifo_data_out,
--            full     => fifo_full,
--            empty    => fifo_empty
--        );




FIFO_buffer_stream_inst : entity work.FIFO_stream
        generic map (
            DATA_WIDTH => 8,  
            FIFO_DEPTH => 517,
            WITH_DECODER =>'1' 
        )
        port map (
            clk      => clk,
            reset_n  => reset_n,
            write_en => buffer_wr_en,
            data_in_decoder  => buffer_data,
            data_in_Rx => (others => '0'),
            full     => fifo_full,
            empty    => fifo_empty,
            m_axis_tdata => m_axis_tdata,
            m_axis_tkeep => m_axis_tkeep,
            m_axis_tvalid => m_axis_tvalid,
            m_axis_tlast => m_axis_tlast,
            m_axis_tready => m_axis_tready,
            Rx_Rd_n => open
        );








end T1;