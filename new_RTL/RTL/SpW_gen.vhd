library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.Spacewire_Pack.all;


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity SpW_gen is
	generic (
		-- Users to add parameters here
        DATA_WIDTH_OUT : integer := 8;
		-- User parameters ends
		-- Do not modify the parameters beyond this line

		-- Width of S_AXI data bus
		C_S_AXI_DATA_WIDTH	: integer	:= 32;
		-- Width of S_AXI address bus
		C_S_AXI_ADDR_WIDTH	: integer	:= 4
	);
	port (
		-- Users to add ports here
        Clk : in std_logic;
        Reset_n: in std_logic; 
        start : in std_logic;          
        
        data_in_FIFO: out std_logic_vector(DATA_WIDTH_OUT-1 downto 0);
        -- Tx_FIFO signals
        Din : out std_logic_vector(8 downto 0);
        Wr_n : out std_logic;
        Full_n : in std_logic;
        
        Din_2 : out std_logic_vector(8 downto 0);
        Wr_n_2 : out std_logic;
        
        --TX signals
        Send_Time_n : out std_logic;
        Time_Code : out std_logic_vector(7 downto 0);
        
        
        --RX
        wd_timeout: out std_logic_vector(15 downto 0);
        
        Rx_Rd_n: out std_logic;
        link_Enabled_out: out std_logic;
        Link_start_out: out std_logic;
        auto_start_out: out std_logic


	);
end SpW_gen;

architecture Behavioral of SpW_gen is
	--user parameters
	signal counter : unsigned(7 downto 0) := (others => '0');
    signal eop     : std_logic := '0';
    
    --FSM
    signal link_Enabled: std_logic:='1';
    signal Link_start: std_logic:='1';
    signal auto_start  : std_logic;
    
    --TX
    signal time_in_buffer : std_logic_vector(7 downto 0):= (others => '0');
    signal tick_in_buffer_n : std_logic:='1';
    signal Tx_Send_Time : std_logic:='0';
    signal Tx_Time_Code: std_logic_vector(7 downto 0) := (others => '0');
    signal count :integer := 0;
    
    signal Wr_n_buffer : std_logic:='1';

begin

	-- Add user logic here
    link_Enabled_out <= link_Enabled;
    Link_start_out <= Link_start;
    auto_start_out <= auto_start;
    
    Send_Time_n <= Tx_Send_Time;
    Time_Code <= Tx_Time_Code;
    
    
    wd_timeout <= x"0011";


    Rx_Rd_n <='1';
    
    Din_2 <= (others => '0');
    Wr_n_2 <= '1';
    
    data_in_FIFO <= (others => '0');
    
    
    
    
    process(Clk)
    begin
        if (rising_edge (clk)) then
            if Reset_n = '0' then
                counter <= (others => '0');
                Din <= (others => '0');
                Wr_n <= '1'; -- No write
                eop <= '0';
                count <=0;
            else 
                if Full_n = '1' and Wr_n_buffer = '1' and start='1' then  -- FIFO not full
                                 
                    -- Create the Din output: counter + EOP
                    counter <= counter + 1;
                    Din(7 downto 0) <= std_logic_vector(counter);
                    Din(8) <= eop;  -- EOP in bit 8
                    
                    Wr_n <= '0';
                    Wr_n_buffer <='0';
                    Tx_Time_Code <= std_logic_vector(counter);
                    
                else
                    Wr_n <= '1';   
                    Wr_n_buffer <='1';
                end if;
            end if;
        end if;
    end process;
	-- User logic ends



end Behavioral;

