library ieee;

use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

-- Conf of spw noeud 

-- constant test_emu_ip : std_logic := '';
	-- emu connect with ip
	
-- constant test_ip2_ip : std_logic := '';
	-- ip2 connect with ip
	
-- constant test_ip2_emu : std_logic := '';
	-- ip2 ip2 with emu

-- conf ip  

--constant conf_fsm_ip : std_logic := '';
	-- when false fsm on bench
	-- when true fsm in component  
	-- Conf type of test

-- By default emu can read and can write in file

--constant conf_test : std_logic := '';
	-- when constant true 
	-- ip2 and ip cant' read file therefore they can send fct and null.
	
--constant conf_test0 : std_logic := ''; 
	-- when constant true
	-- ip can't read in file
	-- ip2 can read file
	-- Tx ip send fct and null 
	-- Rx ip receive 254 data 
	
--constant conf_test1 : std_logic := ''; 
	-- when constant true
	-- ip can read in file
	-- ip2 can't read file
	-- Rx ip receive fct and null
	-- Tx ip can send 254 data  
	
--constant conf_test2 : std_logic := ''; -- Tx send 254 data to ip2 Rx receive 254 data from ip2
	-- when true
	-- ip can read in file
	-- ip2 can read file
	-- Rx ip receive 254 data 
	-- Tx ip can send 254 data
	
--constant conf_test3 : std_logic := '';
	-- when true
	-- ip can't write file therefore fifo rx ip filled 

entity test1 is
end entity;

architecture rtl of test1 is
begin

test :   entity work.testbench       
generic map (
	test_emu_ip => '0',
	test_ip2_ip  => '1', 
	test_ip2_emu => '0',
	conf_fsm_ip => '1',
	conf_test => '0', 
	conf_test0 => '0',
	conf_test1 => '1',
	conf_test2 => '0',
	conf_test3 => '0',
	conf_test4 => '0',
	conf_test5 => '0',
	conf_test6 => '0',
	conf_test7 => '0',
	conf_test8 => '0',
	conf_test9 => '0',
	conf_test10 => '0',
	conf_test11 => '0',
	conf_test12 => '0',
	conf_test13 => '0',
	conf_test14 => '0',
	conf_test15 => '0',
	conf_test16 => '0',
	conf_test17 => '0',
	conf_test18 => '0',
	conf_test19 => '0',
	conf_test20 => '0',
	conf_test21 => '0',
	conf_test22 => '0',
	conf_test23 => '0',
	conf_test24 => '0',
	conf_test25 => '0',
	conf_test26 => '0',
	conf_test27 => '0',
	conf_test28 => '0',
	conf_test29 => '0',
	conf_test30 => '0',
	conf_test31 => '0',
	conf_test32 => '0',
	conf_test33 => '0',
	conf_test34 => '0',
	conf_test35 => '0',
	conf_test36 => '0',
	conf_test37 => '0',
	conf_test38 => '0',
	conf_test39 => '0',
	conf_test40 => '0',
	conf_test41 => '0',
	conf_test42 => '0',
	conf_test43 => '0',
	conf_test44 => '0',
	conf_test45 => '0',
	conf_test46 => '0',
	conf_test48 => '0',
	conf_test49 => '0',
	conf_test50 => '0',
	conf_test51 => '0',
	conf_test52 => '0',
	conf_test53 => '0',
	conf_test54 => '0',
	conf_test55 => '0',
	conf_test56 => '0',
	conf_test57 => '0',
	conf_test58 => '0',
	conf_test59 => '0',
	conf_test60 => '0',
	conf_test61 => '0',
	conf_test62 => '0',
	conf_test63 => '0',
	conf_test64 => '0',
	conf_test65 => '0',
	conf_test66 => '0',
	conf_test67 => '0',
	conf_test68 => '0',
	conf_test69 => '0',
	conf_test70 => '0',
	conf_test99 => '0',
	conf_test100 => '0',
	conf_test101 => '0',
	conf_test102 => '0',
	conf_test103 => '0'
	);
--port map (

--);	   

end rtl;