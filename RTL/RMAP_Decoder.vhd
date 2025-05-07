library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity RMAP_Decoder is
    Port (
        clk         : in  std_logic;
        reset_n     : in  std_logic;
        Rx_Dout     : in  std_logic_vector(8 downto 0); -- Includes parity bit, ignore LSB if needed
        Rx_Empty_n  : in  std_logic;
        buffer_full : in  std_logic;
        Rx_Rd_n     : out std_logic;
        buffer_wr_en: out std_logic;
        buffer_data : out std_logic_vector(7 downto 0) 
    );
end RMAP_Decoder;

architecture Behavioral of RMAP_Decoder is
    type StateType is (IDLE, DATA);
    signal state      : StateType := IDLE;
    signal byte_count : integer range 0 to 1000 := 0;

begin
    process (clk, reset_n)
    begin
        if reset_n = '0' then
            state      <= IDLE;
            buffer_wr_en <= '0';
            Rx_Rd_n    <= '1';
        elsif rising_edge(clk) then
            case state is
                when IDLE =>
                    buffer_wr_en <='0';
                    if Rx_Empty_n = '1' and buffer_full ='0' then
                        Rx_Rd_n <= '0';
                        state   <= DATA;
                    end if;
                    
                when DATA =>
                    if Rx_Empty_n = '1' then
                        buffer_data <= Rx_Dout(7 downto 0);
                        Rx_Rd_n <= '1';
                        byte_count <= byte_count+1;
                        if byte_count >= 531 then
                            byte_count <= 0;
                        elsif byte_count >= 17+4 then
                            if buffer_full = '0' then
                                buffer_wr_en <='1';
                            else
                                buffer_wr_en <='0';
                            end if;
                        end if;
                        state <= IDLE;
                    end if;
            end case;
        end if;
    end process;
end Behavioral;
