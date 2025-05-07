library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity FIFO_stream is
    Generic (
        DATA_WIDTH : integer := 8;  -- Bit-width of each FIFO entry
        FIFO_DEPTH : integer := 512;  -- Number of entries in the FIFO
        WITH_DECODER: std_logic:='1'
    );
    Port (
        clk      : in  std_logic;                      -- Clock signal
        reset_n  : in  std_logic;                      -- Active-low reset
        write_en : in  std_logic;                      -- Write enable signal
        data_in_decoder  : in  std_logic_vector(DATA_WIDTH-1 downto 0);  -- Input data
        data_in_Rx  : in  std_logic_vector(DATA_WIDTH downto 0);
        full     : out std_logic;                      -- FIFO full flag
        empty    : out std_logic;                       -- FIFO empty flag
        Rx_Rd_n     : out std_logic;
        
        m_axis_tdata  : out std_logic_vector(DATA_WIDTH-1 downto 0);
        m_axis_tkeep  : out std_logic_vector((DATA_WIDTH/8)-1 downto 0);
        m_axis_tvalid : out std_logic;
        m_axis_tlast  : out std_logic;
        m_axis_tready : in  std_logic
    );
end FIFO_stream;

architecture Behavioral of FIFO_stream is
    type fifo_memory is array (0 to FIFO_DEPTH-1) of std_logic_vector(DATA_WIDTH-1 downto 0);  -- FIFO memory
    signal fifo_reg : fifo_memory; --:= (others => (others => '0'));  -- FIFO storage
    signal write_ptr : integer range 0 to FIFO_DEPTH-1 := 0;  -- Write pointer
    signal read_ptr  : integer range 0 to FIFO_DEPTH-1 := 0;  -- Read pointer
    signal count     : integer range 0 to FIFO_DEPTH := 0;    -- Number of elements in FIFO
    signal full_sig  : std_logic := '0';                      -- Internal full signal
    signal empty_sig : std_logic := '1';                      -- Internal empty signal
    signal byte_sent: integer range 0 to 513:=0;
    signal has_read: std_logic:='0'; 
    
    
    
begin
    -- Full and empty flags
    full  <= full_sig;
    empty <= empty_sig;
    m_axis_tkeep  <= (others => '1'); 

    -- FIFO control process
    process (clk, reset_n)
    begin
        if reset_n = '0' then
            -- Reset the FIFO
            fifo_reg   <= (others => (others => '0'));  
            write_ptr  <= 0;                            
            read_ptr   <= 0;                            
            count      <= 0;                            
            full_sig   <= '0';                          
            empty_sig  <= '1';  
            byte_sent <= 0;     
            Rx_Rd_n <= '1'; 
            has_read <='0';                  
        elsif rising_edge(clk) then
            -- Write operation
            Rx_Rd_n <= '1';
            m_axis_tvalid <= '0';
            m_axis_tlast <= '0';
            if write_en = '1' and WITH_DECODER='1' and full_sig = '0' then
                fifo_reg(write_ptr) <= data_in_decoder; 
                Rx_Rd_n <= '0';
                       
                if write_ptr = FIFO_DEPTH-1 then
                    write_ptr <= 0;                     
                else
                    write_ptr <= write_ptr + 1;         
                end if;
                count <= count + 1;   
                     
            end if;
            
            
            if write_en = '1' and WITH_DECODER='0' and full_sig = '0' then
                if has_read= '0' then
                    Rx_Rd_n <= '0';
                    has_read <='1';
                else 
                    if WITH_DECODER='1' then
                        fifo_reg(write_ptr) <= data_in_decoder; 
                    else
                        fifo_reg(write_ptr) <= data_in_Rx(7 downto 0); 
                    end if;
                    Rx_Rd_n <= '1';
                           
                    if write_ptr = FIFO_DEPTH-1 then
                        write_ptr <= 0;                     
                    else
                        write_ptr <= write_ptr + 1;         
                    end if;
                    count <= count + 1; 
                    has_read <='0';      
                end if;
            end if;

            

            -- Read operation
            if m_axis_tready = '1' and empty_sig = '0' then
                m_axis_tdata <= fifo_reg(read_ptr);          -- Read data from FIFO
                m_axis_tvalid <= '1';
                if read_ptr = FIFO_DEPTH-1 then
                    read_ptr <= 0;                      
                else
                    read_ptr <= read_ptr + 1;           
                end if;
                count <= count - 1;
                byte_sent <= byte_sent +1;
                if byte_sent = 512 then
                    m_axis_tlast <= '1';
                    byte_sent <= 0;
                end if;                     
            end if;

            -- Update full and empty flags
            if count = FIFO_DEPTH then
                full_sig  <= '1';                       
                empty_sig <= '0';                       
            elsif count = 0 then
                full_sig  <= '0';                       
                empty_sig <= '1';                       
            else
                full_sig  <= '0';                       
                empty_sig <= '0';                       
            end if;
        end if;
    end process;
end Behavioral;
