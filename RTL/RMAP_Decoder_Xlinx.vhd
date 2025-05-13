library ieee;
use ieee.std_logic_1164.all;

entity RMAP_Decoder_Stream is
    generic (
        DATA_WIDTH : integer := 32
    );
    port (
        clk         : in  std_logic;
        reset_n     : in  std_logic;
        Rx_Dout     : in  std_logic_vector(8 downto 0);
        Rx_Empty_n  : in  std_logic;
        Rx_Rd_n     : out std_logic;

        m_axis_tdata  : out std_logic_vector(DATA_WIDTH-1 downto 0);
        m_axis_tkeep  : out std_logic_vector((DATA_WIDTH/8)-1 downto 0);
        m_axis_tvalid : out std_logic;
        m_axis_tlast  : out std_logic;
        m_axis_tready : in  std_logic
    );
end entity;


architecture Behavioral of RMAP_Decoder_Stream is
    type StateType is (IDLE, DATA);
    signal state        : StateType := IDLE;
    signal byte_count   : integer range 0 to 1000 := 0;

    signal data_shift   : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal byte_index   : integer range 0 to DATA_WIDTH/8 := 0;

begin
    process (clk, reset_n)
    begin
        if reset_n = '0' then
            state        <= IDLE;
            Rx_Rd_n      <= '1';
            byte_count   <= 0;
            byte_index   <= 0;

            m_axis_tdata  <= (others => '0');
            m_axis_tkeep  <= (others => '0');
            m_axis_tvalid <= '1';
            m_axis_tlast  <= '0';

        elsif rising_edge(clk) then
            -- Default values
            Rx_Rd_n        <= '1';
            m_axis_tlast   <= '0';
            m_axis_tkeep   <= (others => '0');

            case state is
                when IDLE =>
                    if Rx_Empty_n = '1' and m_axis_tready ='1' then
                        Rx_Rd_n <= '0';  
                        state   <= DATA;
                    end if;

                when DATA =>
                    if Rx_Empty_n = '1' then
                        Rx_Rd_n <= '1';
                        byte_count <= byte_count + 1;

                        
                        if byte_count >= 17+4 then
                            -- Store received byte
                            data_shift((DATA_WIDTH - 8*byte_index - 1) downto (DATA_WIDTH - 8*(byte_index + 1))) <= Rx_Dout(7 downto 0);

                            byte_index <= byte_index + 1;
          
    
                            -- Only output when full word collected
                            if byte_index = (DATA_WIDTH/8 - 1) then
                                m_axis_tdata  <= data_shift;
                                m_axis_tkeep  <= (others => '1');
                                m_axis_tvalid <= '1';
    
                                byte_index <= 0;
                                data_shift <= (others => '0');
                            end if;
                            
                            if byte_count >= 531 then
                                --m_axis_tdata  <= data_shift;
                               -- m_axis_tkeep <= '1' & (DATA_WIDTH/8 - 1 downto 1 => '0');
                               -- m_axis_tvalid <= '1';
                                m_axis_tlast  <= '1';
    
                               -- byte_index <= 0;
                               -- data_shift <= (others => '0');
                                byte_count <= 0;
                            end if;
                        end if;
                        state <= IDLE;
                    end if;

            end case;
        end if;
    end process;
end Behavioral;

