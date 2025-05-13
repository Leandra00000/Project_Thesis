library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity FIFO_buffer is
    Generic (
        DATA_WIDTH : integer := 8;  -- Bit-width of each FIFO entry
        FIFO_DEPTH : integer := 512  -- Number of entries in the FIFO
    );
    Port (
        clk      : in  std_logic;                      -- Clock signal
        reset_n  : in  std_logic;                      -- Active-low reset
        write_en : in  std_logic;                      -- Write enable signal
        data_in  : in  std_logic_vector(DATA_WIDTH-1 downto 0);  -- Input data
        read_en  : in  std_logic;                      -- Read enable signal
        data_out : out std_logic_vector(DATA_WIDTH-1 downto 0);  -- Output data
        full     : out std_logic;                      -- FIFO full flag
        empty    : out std_logic                       -- FIFO empty flag
    );
end FIFO_buffer;

architecture Behavioral of FIFO_buffer is
    type fifo_memory is array (0 to FIFO_DEPTH-1) of std_logic_vector(DATA_WIDTH-1 downto 0);  -- FIFO memory
    signal fifo_reg : fifo_memory; --:= (others => (others => '0'));  -- FIFO storage
    signal write_ptr : integer range 0 to FIFO_DEPTH-1 := 0;  -- Write pointer
    signal read_ptr  : integer range 0 to FIFO_DEPTH-1 := 0;  -- Read pointer
    signal count     : integer range 0 to FIFO_DEPTH := 0;    -- Number of elements in FIFO
    signal full_sig  : std_logic := '0';                      -- Internal full signal
    signal empty_sig : std_logic := '1';                      -- Internal empty signal
begin
    -- Full and empty flags
    full  <= full_sig;
    empty <= empty_sig;

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
        elsif rising_edge(clk) then
            -- Write operation
            if write_en = '1' and full_sig = '0' then
                fifo_reg(write_ptr) <= data_in;         
                if write_ptr = FIFO_DEPTH-1 then
                    write_ptr <= 0;                     
                else
                    write_ptr <= write_ptr + 1;         
                end if;
                count <= count + 1;                     
            end if;

            -- Read operation
            if read_en = '1' and empty_sig = '0' then
                data_out <= fifo_reg(read_ptr);          -- Read data from FIFO
                if read_ptr = FIFO_DEPTH-1 then
                    read_ptr <= 0;                      
                else
                    read_ptr <= read_ptr + 1;           
                end if;
                count <= count - 1;                     
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
