
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.Spacewire_Pack.all;

entity Receiver_generator is
    port (
        Clk : in std_logic;
        Reset_n: in std_logic;
        State: in std_logic_vector(2 downto 0);
        
        
        m_axis_tready : out  std_logic;
        
        
        -- Tx_FIFO signals
        Din : out std_logic_vector(8 downto 0);
        Wr_n : out std_logic;
        
        --TX signals
        Send_Time_n : out std_logic;
        Time_Code : out std_logic_vector(7 downto 0);
        send_esc : out std_logic;
        time_id_sended_n: in std_logic;
        
        --twodomainclock
        in_short_pulse : out std_logic_vector(1 downto 0);
        in_width_pulse : out std_logic_vector(1 downto 0);
        in_short_pulse_n  : out std_logic_vector(1 downto 0);
        
        --RX
        wd_timeout: out std_logic_vector(15 downto 0);
        Remote_Reset_n : out std_logic;
        
        --Rx FIFO
        Rd_n : out std_logic;
        
        --FSM signals
        short_got_null_n : in std_logic;
        before_errorwait : in std_logic;
        linkEnabled : out std_logic
        
    );
end Receiver_generator;

architecture Behavioral of Receiver_generator is
   
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

    
    linkEnabled <= link_Enabled and ( Link_start or (auto_start and (not short_got_null_n)));  
    
    Send_Time_n <= tick_in_buffer_n;
    Time_Code <= time_in_buffer;
    send_esc <= '0';
    
    
    in_short_pulse <= (others => '0');
	in_width_pulse <= (others => '0');    
    in_short_pulse_n <= (others => '1');
    
    wd_timeout <= x"0011";
    
    Remote_Reset_n <= Reset_n and before_errorwait;
    
    m_axis_tready <='0';
    
    Rd_n <='1';
    
    process(Clk, Reset_n)
    begin
        if Reset_n = '0' then
            Din <= (others => '0');
            Wr_n <= '1'; -- No write
        elsif rising_edge(Clk) then
            Din <= (others => '0');
            Wr_n <= '1';
        end if;
    end process;
    
    
    
    
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
    
    


end Behavioral;

