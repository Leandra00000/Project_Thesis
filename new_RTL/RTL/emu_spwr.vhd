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

use work.emu_spwr_pack.all;
use work.emu_Pack.all;

----------------------------------------------------------------------------
----------------------------------------------------------------------------
-- com.txt
--	NULL----	0	:	for first null.
-- 	FCT-----	0	:	flow control token.
-- 	TIME_ID-	255		:	time code.
-- 	DATA_ID-	255		:	data characters.
-- 	WAIT----	1000	:	stop spacewire activity in 1000*Tclk
-- 	ESC-----	0	:	escape
-- 	EOP-----	0	:	end of packet.
-- 	EEP-----	0	:	error end of packet.
--	EEP----E	0	:	error end of packet. with error parity.
--	EOP----E	0	:	end of packet with error parity.
-- 	ESC----E	0	:	escape with error parity.
--	DATA_IDE	255		:	data characters with error parity.
--	TIME_IDE	255		:	time code with error parity.
-- 	FCT----E	0	:	flow control token error parity.
--	NULL---E	0	:	for first null error parity


-- =========================================================================

----------------------------------------------------------------------------
----------------------------------------------------------------------------
-- out_file.txt

-- =========================================================================

entity emu_spwr is
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
    
    end_com_fich : inout std_logic
  );
end emu_spwr;


-- =========================================================================
architecture RTL of emu_spwr is

--for TX
signal tx_bit : std_logic := '0';
signal parity : std_logic := '0';
signal wait_count : std_logic_vector(7 downto 0) := ( others => '0');
signal wait_max : std_logic_vector(7 downto 0):= "00000010";
signal old_std_data : std_logic_vector(7 downto 0) := "00000000";

--for RX
signal i_din : std_logic := '0';
signal i_sin : std_logic := '0';
signal i_din_old : std_logic ;
signal i_sin_old : std_logic ;
signal clk_rx : std_logic;
signal gen_char : std_logic;
signal count_dis_emu  : integer;
signal error_dis_emu : std_logic;

--for view inside TX module
signal stat1 : std_logic := '0';
signal stat2 : std_logic := '0';
signal stat3 : std_logic := '0';
signal stat4 : std_logic := '0';
signal stat5 : std_logic := '0';
signal stat6 : std_logic := '0';
signal stat7 : std_logic := '0';
signal stat8 : std_logic := '0';
signal view_std_data : std_logic_vector(7 downto 0) := "00000000";
signal view_last_parity : std_logic := '0';
--signal end_com_fich : std_logic := '0';

--for view inside RX module
signal clk_build : std_logic := '0';
signal view_data_input : std_logic_vector (1 downto 0) := (others=>'0');
signal view_count_write : integer;
signal view_stamp : std_logic_vector(7 downto 0);
signal view_current_state : state;
signal view_rx_emu_comput_parity : std_logic;
signal view_error_parity : std_logic;
--------------------------------------------------------

begin

-----------------------------------------------------------------------------------------------------------------------
--
-- EMU TX module
--
-----------------------------------------------------------------------------------------------------------------------

EMU_TX_module : process	

variable read_line : line;
variable signalread : std_logic;
variable ligne  : integer := 0; 
variable code  : integer := 0; 
variable data  : integer := 0;
variable Num  : integer := 9;
variable err_parity : std_logic := '0';
variable std_data : std_logic_vector(7 downto 0) := "00000000";
variable v_end_com_fich : std_logic;

file com_fich:text;   
begin
file_open(com_fich, "com.txt", READ_MODE);
gen_char <= '0';
	
wait until reset'event and reset='1';

loop_bit : loop
	case Num is
 	 	  							
		when 1 => -- first NULL
			
			
			stat1<= '1';--view
		 	wait until clk'event and clk='1';
          	tx_bit <= parity xor err_parity;
          	gen_char <= '1';   
          	wait until clk'event and clk='1';              
          	tx_bit <= '1';
          	wait until clk'event and clk='1';
          	tx_bit <= '1';
          	wait until clk'event and clk='1';
          	tx_bit <= '1';
          	wait until clk'event and clk='1';
          	tx_bit <= '0';
          	wait until clk'event and clk='1';
          	tx_bit <= '1';
          	wait until clk'event and clk='1';
          	tx_bit <= '0';
          	wait until clk'event and clk='1';
          	tx_bit <= '0'; 
          	parity <= '0';--usually set to '0'
          	stat1<= '0';--view
		
        when 2 => --SEND_FCT_ID
        	stat2<= '1';--view
       		wait until clk'event and clk='1';
         	tx_bit <= parity xor err_parity;
         	view_last_parity <= parity;--view 
        	wait until clk'event and clk='1';
          	tx_bit <= '1';
          	wait until clk'event and clk='1'; 
          	tx_bit <= '0';
          	wait until clk'event and clk='1'; 
          	tx_bit <= '0';
          	parity <= '0' ;--usually set to '0'
          	stat2<= '0';--view
          	
          	
        when 3 =>  --SEND_TIME_ID 
        	stat3<= '1';--view                
        	old_std_data <= std_data; 
           	wait until clk'event and clk='1';
          	tx_bit <= parity xor err_parity; 
          	view_last_parity <= parity ;--view
          	wait until clk'event and clk='1';
          	tx_bit <= '1';
          	wait until clk'event and clk='1';
          	tx_bit <= '1';
          	wait until clk'event and clk='1';
          	tx_bit <= '1';
          	wait until clk'event and clk='1';
          	tx_bit <= '1';
          	wait until clk'event and clk='1';
          	tx_bit <= '0';
          	parity <= '0';
          		for i in 0 to 7 loop
            	wait until clk'event and clk='1';
            	tx_bit <= old_std_data(i) ;
            	parity <= parity xor old_std_data(i) ;
          		end loop;
          	stat3<= '0';--view
                 
		when 4 => --SEND_DATA_ID 
			stat4<= '1';--view
			old_std_data <= std_data ; 
			wait until clk'event and clk='1';
          	tx_bit <= (not parity) xor err_parity;
          	view_last_parity <= parity;--view
          	wait until clk'event and clk='1';
          	tx_bit <= '0';
          	parity <= '0';
          	for i in 0 to 7 loop
            	wait until clk'event and clk='1';
            	tx_bit <= old_std_data (i);
            	parity <= parity xor old_std_data (i);
          	end loop;
          	
			stat4<= '0';--view	
				
         when 5 => --wait 
			
			stat5<= '1';--view 
			wait_count <= (others => '0');
			wait_max <= std_data;
			gen_char <= '0';   
			while (wait_count <= wait_max) loop
				wait_count <= wait_count + 1; 
         		wait until clk'event and clk='1'; 
         	end loop; 
         	gen_char <= '1';   
         	wait_count <= (others => '0');
			stat5<= '0';--view 	
			
		when 6 => --esc
			
			stat6<= '1';--view
       		wait until clk'event and clk='1';
         	tx_bit <= parity xor err_parity;
         	view_last_parity <= parity;--view
        	wait until clk'event and clk='1';
          	tx_bit <= '1';
          	wait until clk'event and clk='1'; 
          	tx_bit <= '1';         	
          	wait until clk'event and clk='1'; 
          	tx_bit <= '1';
          	parity <= '0' ;--usually set to '0'
          	stat6<= '0';--view
          	
        when 7 => --eop
        
        	stat7 <= '1';--view
       		wait until clk'event and clk='1';
         	tx_bit <= parity xor err_parity;
         	view_last_parity <= parity;--view
        	wait until clk'event and clk='1';
          	tx_bit <= '1';
          	wait until clk'event and clk='1'; 
          	tx_bit <= '0';
          	wait until clk'event and clk='1'; 
          	tx_bit <= '1';
          	parity <= '1' ;--usually set to '1'
          	stat7 <= '0';--view
          	
		when 8 => --eep
		
			stat8 <= '1';--view
       		wait until clk'event and clk='1';
         	tx_bit <= parity xor err_parity;
         	view_last_parity <= parity;--view
        	wait until clk'event and clk='1';
          	tx_bit <= '1';
          	wait until clk'event and clk='1'; 
          	tx_bit <= '1';
          	wait until clk'event and clk='1'; 
          	tx_bit <= '0';
          	parity <= '1';--usually set to '1'
          	stat8 <= '0';--view
        
		when 9 =>
			wait until clk'event and clk='1';
						         	
		when others => 
        
        	wait until clk'event and clk='1';
        	
        	   
      end case;
     
      readfile(com_fich,Num,std_data,err_parity,v_end_com_fich);
	  end_com_fich <= v_end_com_fich; 
      view_std_data <= std_data;
   
    end loop loop_bit;    
end process EMU_TX_module;
--------------------------XOR AND OUT SPW------
out_spw : process(clk,gen_char)
  begin
  if gen_char = '0'
  then
   Sout <= '0';
   Dout <= '0';
  else
  	if (clk'event and clk='1') 
  	then
      if (tx_bit=Dout) then
        Sout <= not Sout;
      else
        Dout <= tx_bit;
      end if;
    end if;
  end if;
end process out_spw;  

clk_build <= Dout xor Sout; --for view

-----------------------------------------------------------------------------------------------------------------------
--
-- EMU RX module
--
-----------------------------------------------------------------------------------------------------------------------

---------------------------BUILD RX CLOCK---------
build_rx_clk : process(Din,Sin)
	begin
	clk_rx <= Din xor Sin;
	i_din <= Din;
	i_sin <= Sin;
end process build_rx_clk;

--------------------------BUILD DATA INPUT------
EMU_RX_module : process   --(clk_rx,reset)
variable data_input : std_logic_vector(1 downto 0);
--variable treat_case : std_logic;
variable count_write : integer;
variable stamp : std_logic_vector(7 downto 0);
file out_file: text;
variable current_state		: state;
variable rx_emu_comput_parity : std_logic :='0';
variable code : string(1 to 8);
variable data : integer;
variable error_parity : std_logic := '0';

begin

file_open(out_file, "out_file.txt", write_MODE);
data_input := (others => '0');
count_write := 0;
current_state := char_or_ctrl;
stamp := (others => '0');

wait until reset'event and reset='1';
loop
		
	wait until clk_rx'event and clk_rx='1';
	
	data_input(1) := Din;
	view_count_write <= count_write ;
	--treat_case :='1';
	
	wait until clk_rx'event and clk_rx='0';
	
	data_input(0) := Din;
		--if end_com_fich = '0'
		--then
		writefile(out_file,current_state,data_input,count_write,stamp,rx_emu_comput_parity,code,data,error_parity);--go to procedure
		--end if;
	view_error_parity <= error_parity; 
	view_stamp <= stamp;
	view_data_input <= data_input;--view 
	view_count_write <= count_write ; 
	view_current_state <= current_state;
	view_rx_emu_comput_parity <= rx_emu_comput_parity;
end loop;
end process EMU_RX_module;

disc_time_out : process(clk,reset)

variable l : line;

begin
if reset = '0'
then
i_din_old <= '0';
i_sin_old <= '0'; 
count_dis_emu <= 0;
error_dis_emu <= '0';
else
	if (clk'event and clk = '1')
	then
	i_din_old <= i_din;
	i_sin_old <= i_sin; 
		if i_din_old = i_din and i_sin_old = i_sin
		then
		count_dis_emu  <= count_dis_emu + 1;
			if 	count_dis_emu = 10
			then
			error_dis_emu <= '1';
			end if;
		else
		count_dis_emu <= 0;
		end if; 
	end if;--clk
end if;--reset
end process;

end RTL; -- end of architecture