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

--	06/04/2009
--	B.Bertrand
--	inout signal is removed

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;



use work.Spacewire_Pack.all;

entity spwr_ip is
		port(
		
		
		Clk : in std_logic;
		--clk_n : in std_logic;
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
		
		credit_count_rx_fifo : out std_logic_vector(31 downto 0);
		short_Rx_FIFO_Wr_n  : out std_logic;
		
		-- tx fifo
		
		credit_count_tx_fifo : out std_logic_vector(31 downto 0);
		
		-- fsm 
		
		view_fsm : out std_logic_vector(3 downto 0); 
		
		--error
		

 		short_Error_Par_n : out std_logic;
 		short_Error_ESC_n : out std_logic;
 		short_Error_Dis_n : out std_logic;
 		
 		Tx_credit_error_n : out std_logic;
 		Rx_credit_error_n : out std_logic


				
		);
end spwr_ip;

architecture T1 of spwr_ip is

for Rx_ip : Rx use entity work.Rx(r1);
for Tx_ip : Tx use entity work.Tx(t1);
for Rx_fifo_ip : Rx_fifo use entity work.Rx_fifo(R1);
for Tx_fifo_ip : Tx_fifo use entity work.Tx_fifo(T1);
for fsm_ip : fsm use entity work.fsm(rtl);


-- constant cte_CFG_MAXCREDIT_integer : integer := 56;

-- constant Rx_ip_MAX_CREDIT : integer := cte_CFG_MAXCREDIT_integer;
-- constant TX_ip_MAX_CREDIT : integer := cte_CFG_MAXCREDIT_integer;

--	linkEnabled

signal linkEnabled  : std_logic;

-- Tx fifo
 
signal Tx_Dout : std_logic_vector(8 downto 0); 
signal Tx_Credit_Empty_n : std_logic;

-- Rx fifo

signal Rx_FIFO_Credit_Rd_n : std_logic;
signal Rx_FIFO_Credit_Empty_n : std_logic;

--	Rx interface 

signal State : std_logic_vector(2 downto 0); --:= Ready; 
signal Rx_Clk : std_logic;
signal Remote_Reset_n	: std_logic;
signal got_NULL_n  :  std_logic;
signal got_FCT_n   :  std_logic;
signal got_EOP_n	:	std_logic;
signal got_NChar_n :  std_logic;
signal got_Time_n  :  std_logic;

signal Error_Par_n :  std_logic;	-- Parity error
signal Error_ESC_n :  std_logic;	-- ESC followed by ESC, EOP or EEP
signal Error_Dis_n :  std_logic;	-- Disconnected

signal Rx_FIFO_D : std_logic_vector(8 downto 0);
signal Rx_FIFO_Wr_n : std_logic;

-- Tx interface

signal Tx_FIFO_Rd_n    : std_logic;
signal time_id_sended_n : std_logic;
signal send_eop_n : std_logic;

--	buffer time id

signal time_in_buffer : std_logic_vector(7 downto 0);
signal tick_in_buffer_n : std_logic;

-- generate short signal_n

signal in_width_pulse_n_vector_rx : std_logic_vector(8 downto 0);
signal out_short_pulse_n_vector_rx : std_logic_vector(8 downto 0);
signal short_got_eop_n : std_logic;

--	fsm

signal before_errorwait : std_logic;
signal signal_errorwait : std_logic;

--	for avoid inout declaration

signal	signal_short_got_Time_n	: std_logic;
signal	signal_Tx_FIFO_Empty_n	: std_logic;
signal	signal_short_got_NChar_n	: std_logic;
signal	signal_short_got_fct_n	: std_logic;
signal	signal_short_got_null_n	: std_logic;
signal	signal_short_Rx_FIFO_Wr_n	: std_logic;	
signal	signal_short_Error_Par_n	: std_logic;
signal	signal_short_Error_ESC_n	: std_logic;
signal	signal_short_Error_Dis_n	: std_logic;
signal	signal_Tx_credit_error_n	: std_logic;
signal	signal_Rx_credit_error_n	: std_logic;

begin


----------------------------------------------------------------------------------------
--
-- for avoid in_out declaration
--
------------------------------------------------------------------------------------------

short_got_Time_n	<=	signal_short_got_Time_n;
Tx_FIFO_Empty_n	<= 	signal_Tx_FIFO_Empty_n;
short_got_NChar_n	<=	signal_short_got_NChar_n;
short_got_fct_n	<=	signal_short_got_fct_n;
short_got_null_n	<=	signal_short_got_null_n;
short_Rx_FIFO_Wr_n	<=	signal_short_Rx_FIFO_Wr_n;	
short_Error_Par_n 	<=	signal_short_Error_Par_n;
short_Error_ESC_n 	<= 	signal_short_Error_ESC_n;
short_Error_Dis_n	<=	signal_short_Error_Dis_n;
Tx_credit_error_n 	<=	signal_Tx_credit_error_n;
Rx_credit_error_n 	<=	signal_Rx_credit_error_n;

----------------------------------------------------------------------------------------
--
-- Map Rx ip
--
------------------------------------------------------------------------------------------


Rx_ip: Rx 
 port map (
 
	Reset_n =>  Remote_Reset_n,
	Clk => clk,
	Rx_Clk => Rx_Clk,
	
	-- Main FSM interface

	State => State,

	-- param
	
	wd_timeout => wd_timeout,
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

	Din => Din,
	Sin => Sin
	
	 	);

Remote_Reset_n <= Reset_n and before_errorwait;

---------------------------------------------------------------------------
--
-- Map Rx Fifo
--
---------------------------------------------------------------------------

--fifoRx_ip : entity work.Rx_Fifo 
Rx_fifo_ip : Rx_fifo 
generic map (
	WIDTH  => 9,
	LENGTH => 128,
	MAX_CREDIT => MAX_CREDIT)
port map (
	Reset_n => Reset_n,
	Clk => Clk,
	State => State,
	
	-- Credit
	Credit_Rd_n => Rx_FIFO_Credit_Rd_n,
	Credit_Empty_n => Rx_FIFO_Credit_Empty_n,
	credit_error_n => signal_Rx_credit_error_n,
	
	-- Data Input
	Din => Rx_FIFO_D,
	Wr_n => signal_short_Rx_FIFO_Wr_n,
	Full_n => Rx_Full_n,
	short_got_EOP_n => short_got_EOP_n,
	
	-- Data Output
	Dout => Rx_Dout,
	Rd_n => Rx_Rd_n,
	Empty_n => Rx_Empty_n,
	
	credit => credit_count_rx_fifo
);	

rx_got_time <= Rx_FIFO_D;
---------------------------------------------------------------------------
--
-- twodomainclock component after RX
--
---------------------------------------------------------------------------

in_width_pulse_n_vector_rx <= got_EOP_n & got_fct_n & got_null_n & got_NChar_n & got_Time_n & Error_Par_n & Error_ESC_n & Error_Dis_n & Rx_FIFO_Wr_n;


change_clock_after_RX : entity work.twodomainclock
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
signal_short_got_null_n <= out_short_pulse_n_vector_rx(6);
signal_short_got_fct_n <= out_short_pulse_n_vector_rx(7);
signal_short_Rx_FIFO_Wr_n  <= out_short_pulse_n_vector_rx(0);
signal_short_got_NChar_n  <= out_short_pulse_n_vector_rx(5);
signal_short_got_Time_n  <= out_short_pulse_n_vector_rx(4);
signal_short_Error_Par_n  <= out_short_pulse_n_vector_rx(3);
signal_short_Error_ESC_n  <= out_short_pulse_n_vector_rx(2);
signal_short_Error_Dis_n <= out_short_pulse_n_vector_rx(1);


---------------------------------------------------------------------------
--
-- buffer time id sende by IP
--
---------------------------------------------------------------------------
process(reset_n, clk, State)
begin
if reset_n = '0' or State=S_ErrorReset 
then
tick_in_buffer_n <= '1';
time_in_buffer <= (others => '0');
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
-- Map Tx Fifo
--
---------------------------------------------------------------------------

--fifoTx_ip : entity work.Tx_Fifo
Tx_fifo_ip : Tx_fifo 
generic map (
	WIDTH  => 9,
	LENGTH => 128,
	MAX_CREDIT => MAX_CREDIT)
port map (
	Reset_n => Reset_n,
	Clk => clk,
	State => State,
	
	-- Credit
	fct_n => signal_short_got_fct_n,--short_got_fct_n,
	short_send_eop_rising => send_eop_n,
	fct_full_n => signal_Tx_credit_error_n,
	Credit_Empty_n => Tx_Credit_Empty_n,
	--credit_error_n => Tx_credit_error_n,
	
	-- Data Input
	Din => Tx_Din,
	Wr_n => Tx_Wr_n,
	Full_n => Tx_Full_n,
	
	-- Data Output
	Dout => Tx_Dout,
	Rd_n => Tx_FIFO_Rd_n,
	Empty_n => signal_Tx_FIFO_Empty_n,
	
	credit => credit_count_tx_fifo
);



-----------------------------------------------------------------------------
----
---- twodomainclock component before TX.
----
-----------------------------------------------------------------------------
--
--in_width_pulse_n_vector_tx <= send_eop_n&time_id_sended_width_n & Rx_FIFO_Credit_Rd_width_n & Tx_FIFO_Rd_width_n; 
--
--change_clock_before_tx : entity work.twodomainclock
--	generic map( 
--			N_short_to_width => 2,
--			use_short_to_width => 0,
--			N_width_to_short => 2,
--			use_width_to_short => 0,
--			N_short_to_width_n => 2,
--			use_short_to_width_n => 0,
--			N_width_to_short_n => 4,
--			use_width_to_short_n => 1)	
-- 	port map (
-- 	Rst => reset_n,
--	Clk_speed => clk,
--	Clk_slow => Clk_spw_tx,
--	
--	in_short_pulse => (others => '0'),
--	in_width_pulse => (others => '0'),
--	
--	out_width_pulse => open,
--	out_short_pulse => open,
--	
--	in_short_pulse_n => (others => '1'),
--	in_width_pulse_n => in_width_pulse_n_vector_tx, 
--	
--	out_width_pulse_n => open,
--	out_short_pulse_n => out_short_pulse_n_vector_tx		
--
--	
--);
--
--short_send_eop <= out_short_pulse_n_vector_tx(3);
--time_id_sended_n <=  out_short_pulse_n_vector_tx(2);
--Rx_FIFO_Credit_Rd_n <= out_short_pulse_n_vector_tx(1);
--Tx_FIFO_Rd_n <= out_short_pulse_n_vector_tx(0); 

----------------------------------------------------------------------------------------
--
-- Map Tx ip
--
------------------------------------------------------------------------------------------ 	

--Tx_ip : entity work.Tx

Tx_ip : Tx port map (
 	Reset_n =>	Reset_n,	
	Tx_Clk  =>	Clk,	
		
	-- Main FSM interface

	State => State,

	-- Tx Fifo interface

	Tx_FIFO_Din => Tx_Dout(8 downto 0),
	Tx_FIFO_Rd_n  => Tx_FIFO_Rd_n,
	Tx_FIFO_Empty_n => signal_Tx_FIFO_Empty_n,

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

	Dout => Dout,
	Sout => Sout

--	 Dout_view => Dout_view,
--	 Sout_view => Sout_view
	
 	);	
	
---------------------------------------------------------------------------
--
-- Map FSM
--
---------------------------------------------------------------------------

linkEnabled <= link_Enabled and ( Link_start or (auto_start and (not signal_short_got_null_n)));   

--fsm : entity work.fsm
fsm_ip : fsm port map(
	Reset_n =>	Reset_n,	
	Clk  =>	clk,
	linkEnabled	=>	linkEnabled,	
	
	State => State,
	
	--input
	
	short_got_fct_n => signal_short_got_fct_n,
	short_got_null_n => signal_short_got_null_n,
	short_got_NChar_n => signal_short_got_NChar_n,
	short_got_Time_n => signal_short_got_Time_n, 
	
	
	-- input error
	
	Rx_credit_error_n =>  signal_Rx_credit_error_n,
	Tx_credit_error_n =>  signal_Tx_credit_error_n,
	short_Error_Dis_n => signal_short_Error_Dis_n,
	short_Error_Par_n => signal_short_Error_Par_n,  
	short_Error_ESC_n => signal_short_Error_ESC_n,
	
	
	before_errorwait => before_errorwait, 
	signal_errorwait	=> signal_errorwait,

	view_fsm	=>	view_fsm
);


end T1;