library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity FIFO_stream_tb is
end FIFO_stream_tb;

architecture tb of FIFO_stream_tb is
    -- Constants matching the design
    constant DATA_WIDTH          : integer := 8;
    constant FIFO_DEPTH          : integer := 512;
    constant C_M_AXIS_TDATA_WIDTH : integer := 8;
    constant C_M_START_COUNT     : integer := 8;
    constant NUMBER_OF_OUTPUT_WORDS : integer := 32;

    -- Signals for DUT
    signal clk         : std_logic := '0';
    signal reset_n     : std_logic := '0';
    signal write_en    : std_logic := '0';
    signal data_in_Rx  : std_logic_vector(DATA_WIDTH downto 0) := (others => '0');
    signal full        : std_logic;
    signal empty       : std_logic;
    signal Rx_Rd_n     : std_logic;
    signal M_AXIS_TVALID : std_logic;
    signal M_AXIS_TDATA  : std_logic_vector(C_M_AXIS_TDATA_WIDTH-1 downto 0);
    signal M_AXIS_TSTRB  : std_logic_vector((C_M_AXIS_TDATA_WIDTH/8)-1 downto 0);
    signal M_AXIS_TLAST  : std_logic;
    signal M_AXIS_TREADY : std_logic := '0';

    -- Clock generation
    constant clk_period : time := 10 ns;
begin
    -- Clock process
    clk_process : process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    -- Instantiate the Unit Under Test (UUT)
    uut: entity work.FIFO_stream
        generic map (
            DATA_WIDTH             => DATA_WIDTH,
            FIFO_DEPTH             => FIFO_DEPTH,
            C_M_AXIS_TDATA_WIDTH   => C_M_AXIS_TDATA_WIDTH,
            C_M_START_COUNT        => C_M_START_COUNT,
            NUMBER_OF_OUTPUT_WORDS => NUMBER_OF_OUTPUT_WORDS
        )
        port map (
            clk          => clk,
            reset_n      => reset_n,
            write_en     => write_en,
            data_in_Rx   => data_in_Rx,
            full         => full,
            empty        => empty,
            Rx_Rd_n      => Rx_Rd_n,
            M_AXIS_TVALID => M_AXIS_TVALID,
            M_AXIS_TDATA  => M_AXIS_TDATA,
            M_AXIS_TSTRB  => M_AXIS_TSTRB,
            M_AXIS_TLAST  => M_AXIS_TLAST,
            M_AXIS_TREADY => M_AXIS_TREADY
        );

    -- Stimulus process
    stim_proc: process
    begin
        -- Reset
        reset_n <= '0';
        wait for 3 * clk_period;
        reset_n <= '1';
        wait for 2 * clk_period;

        -- Write data to FIFO
        for i in 0 to NUMBER_OF_OUTPUT_WORDS - 1 loop
            if full = '0' then
                write_en <= '1';
                data_in_Rx <= std_logic_vector(to_unsigned(i, DATA_WIDTH + 1));
            end if;
            wait for clk_period;
            write_en <= '0';
            wait for clk_period;
        end loop;

        -- Start receiving
        wait for 10 * clk_period;
        M_AXIS_TREADY <= '1';

        wait for 10 * clk_period;
        M_AXIS_TREADY <= '0';
        
        wait for 10 * clk_period;
        M_AXIS_TREADY <= '1';
        -- Wait until transmission completes
        wait for 300 * clk_period;

        -- Stop simulation
        assert false report "Simulation complete" severity failure;
    end process;

end tb;
