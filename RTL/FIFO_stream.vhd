library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity FIFO_stream is
	generic (
		-- Users to add parameters here
        DATA_WIDTH : integer := 8;  -- Bit-width of each FIFO entry
        FIFO_DEPTH : integer := 512;  -- Number of entries in the FIFO




		-- User parameters ends
		-- Do not modify the parameters beyond this line

		-- Width of S_AXIS address bus. The slave accepts the read and write addresses of width C_M_AXIS_TDATA_WIDTH.
		C_M_AXIS_TDATA_WIDTH	: integer	:= 8;
		-- Start count is the number of clock cycles the master will wait before initiating/issuing any transaction.
		C_M_START_COUNT	: integer	:= 8;
		-- Total number of output data                                              
	    NUMBER_OF_OUTPUT_WORDS : integer := 32  
	);
	port (
		-- Users to add ports here
        clk      : in  std_logic;                      -- Clock signal
        reset_n  : in  std_logic;                      -- Active-low reset
        write_en : in  std_logic;                      -- Write enable signal
        data_in_Rx  : in  std_logic_vector(DATA_WIDTH downto 0);
        full     : out std_logic;                      -- FIFO full flag
        empty    : out std_logic;                       -- FIFO empty flag
        Rx_Rd_n     : out std_logic;
        
        
		-- User ports ends
		-- Do not modify the ports beyond this line

		-- Master Stream Ports. TVALID indicates that the master is driving a valid transfer, A transfer takes place when both TVALID and TREADY are asserted. 
		M_AXIS_TVALID	: out std_logic;
		-- TDATA is the primary payload that is used to provide the data that is passing across the interface from the master.
		M_AXIS_TDATA	: out std_logic_vector(C_M_AXIS_TDATA_WIDTH-1 downto 0);
		-- TSTRB is the byte qualifier that indicates whether the content of the associated byte of TDATA is processed as a data byte or a position byte.
		M_AXIS_TSTRB	: out std_logic_vector((C_M_AXIS_TDATA_WIDTH/8)-1 downto 0);
		-- TLAST indicates the boundary of a packet.
		M_AXIS_TLAST	: out std_logic;
		-- TREADY indicates that the slave can accept a transfer in the current cycle.
		M_AXIS_TREADY	: in std_logic
	);
end FIFO_stream;

architecture Behavioral of FIFO_stream is

    type fifo_memory is array (0 to FIFO_DEPTH-1) of std_logic_vector(DATA_WIDTH-1 downto 0);  -- FIFO memory
    signal fifo_reg : fifo_memory; --:= (others => (others => '0'));  -- FIFO storage
    signal write_ptr : integer range 0 to FIFO_DEPTH-1 := 0;  -- Write pointer
    signal read_ptr  : integer range 0 to FIFO_DEPTH-1 := 0;  -- Read pointer
    signal count_fifo     : integer range 0 to FIFO_DEPTH := 0;    -- Number of elements in FIFO
    signal full_sig  : std_logic := '0';                      -- Internal full signal
    signal empty_sig : std_logic := '1';                      -- Internal empty signal
    type state_fifo is ( IDLE,        -- This is the initial/idle state                    
                         GET_DATA);  -- In this state the                               
	                             -- stream data is output through M_AXIS_TDATA   
	signal current_state_fifo_write: state_fifo;
	signal enough_data	: std_logic:='0';


	 -- function called clogb2 that returns an integer which has the   
	 -- value of the ceiling of the log base 2.                              
	function clogb2 (bit_depth : integer) return integer is                  
	 	variable depth  : integer := bit_depth;                               
	 	variable count  : integer := 1;                                       
	 begin                                                                   
	 	 for clogb2 in 1 to bit_depth loop  -- Works for up to 32 bit integers
	      if (bit_depth <= 2) then                                           
	        count := 1;                                                      
	      else                                                               
	        if(depth <= 1) then                                              
	 	       count := count;                                                
	 	     else                                                             
	 	       depth := depth / 2;                                            
	          count := count + 1;                                            
	 	     end if;                                                          
	 	   end if;                                                            
	   end loop;                                                             
	   return(count);        	                                              
	 end;                                                                    

	 -- WAIT_COUNT_BITS is the width of the wait counter.                       
	 constant  WAIT_COUNT_BITS  : integer := clogb2(C_M_START_COUNT-1);               
	                                                                                  
	-- In this example, Depth of FIFO is determined by the greater of                 
	-- the number of input words and output words.                                    
	constant depth : integer := NUMBER_OF_OUTPUT_WORDS;                               
	                                                                                  
	-- bit_num gives the minimum number of bits needed to address 'depth' size of FIFO
	constant bit_num : integer := clogb2(depth);                                      
	                                                                                  
	-- Define the states of state machine                                             
	-- The control state machine oversees the writing of input streaming data to the FIFO,
	-- and outputs the streaming data from the FIFO                                   
	type state is ( IDLE,        -- This is the initial/idle state                    
	                INIT_COUNTER,  -- This state initializes the counter, once        
	                                -- the counter reaches C_M_START_COUNT count,     
	                                -- the state machine changes state to SEND_STREAM  
	                SEND_STREAM);  -- In this state the                               
	                             -- stream data is output through M_AXIS_TDATA        
	-- State variable                                                                 
	signal  mst_exec_state : state;                                                   
	-- Example design FIFO read pointer                                               
	signal read_pointer : integer range 0 to depth-1;                               

	-- AXI Stream internal signals
	--wait counter. The master waits for the user defined number of clock cycles before initiating a transfer.
	signal count	: std_logic_vector(WAIT_COUNT_BITS-1 downto 0);
	--streaming data valid
	signal axis_tvalid	: std_logic;
	--streaming data valid delayed by one clock cycle
	signal axis_tvalid_delay	: std_logic;
	--Last of the streaming data 
	signal axis_tlast	: std_logic;
	--Last of the streaming data delayed by one clock cycle
	signal axis_tlast_delay	: std_logic;
	--FIFO implementation signals
	signal stream_data_out	: std_logic_vector(C_M_AXIS_TDATA_WIDTH-1 downto 0);
	signal tx_en	: std_logic;
	--The master has issued all the streaming data stored in FIFO
	signal tx_done	: std_logic;


begin
	-- I/O Connections assignments

	M_AXIS_TVALID	<= axis_tvalid_delay;
	M_AXIS_TDATA	<= stream_data_out;
	M_AXIS_TLAST	<= axis_tlast_delay;
	M_AXIS_TSTRB	<= (others => '1');


	-- Control state machine implementation                                               
	process(clk)                                                                        
	begin                                                                                       
	  if (rising_edge (clk)) then                                                       
	    if(reset_n = '0') then                                                           
	      -- Synchronous reset (active low)                                                     
	      mst_exec_state      <= IDLE;                                                          
	      count <= (others => '0');                                                             
	    else                                                                                    
	      case (mst_exec_state) is                                                              
	        when IDLE     =>                                                                    
	          -- The slave starts accepting tdata when                                          
	          -- there tvalid is asserted to mark the                                           
	          -- presence of valid streaming data                                               
	          --if (count = "0")then                                                            
	            mst_exec_state <= INIT_COUNTER;                                                 
	          --else                                                                              
	          --  mst_exec_state <= IDLE;                                                         
	          --end if;                                                                           
	                                                                                            
	          when INIT_COUNTER =>                                                              
	            -- This state is responsible to wait for user defined C_M_START_COUNT           
	            -- number of clock cycles.                                                      
	            if ( count = std_logic_vector(to_unsigned((C_M_START_COUNT - 1), WAIT_COUNT_BITS))) then
                  mst_exec_state  <= SEND_STREAM;
                  count <= (others => '0');                                           
	            else                                                                            
	              count <= std_logic_vector (unsigned(count) + 1);                              
	              mst_exec_state  <= INIT_COUNTER;                                              
	            end if;                                                                         
	                                                                                            
	        when SEND_STREAM  =>                                                                
	          -- The example design streaming master functionality starts                       
	          -- when the master drives output tdata from the FIFO and the slave                
	          -- has finished storing the S_AXIS_TDATA                                          
	          if (tx_done = '1') then                                                           
	            mst_exec_state <= IDLE;  
	                                                                   
	          else                                                                              
	            mst_exec_state <= SEND_STREAM;                                                  
	          end if;                                                                           
	                                                                                            
	        when others    =>                                                                   
	          mst_exec_state <= IDLE;                                                           
	                                                                                            
	      end case;                                                                             
	    end if;                                                                                 
	  end if;                                                                                   
	end process;                                                                                


	--tvalid generation
	--axis_tvalid is asserted when the control state machine's state is SEND_STREAM and
	--number of output streaming data is less than the NUMBER_OF_OUTPUT_WORDS.
	axis_tvalid <= '1' when ((mst_exec_state = SEND_STREAM) and (read_pointer < NUMBER_OF_OUTPUT_WORDS) and enough_data='1') else '0';
	                                                                                               
	-- AXI tlast generation                                                                        
	-- axis_tlast is asserted number of output streaming data is NUMBER_OF_OUTPUT_WORDS-1          
	-- (0 to NUMBER_OF_OUTPUT_WORDS-1)                                                             
	axis_tlast <= '1' when (read_pointer = NUMBER_OF_OUTPUT_WORDS-1) else '0';                     
	                                                                                               
	-- Delay the axis_tvalid and axis_tlast signal by one clock cycle                              
	-- to match the latency of M_AXIS_TDATA                                                        
	process(clk)                                                                           
	begin                                                                                          
	  if (rising_edge (clk)) then                                                          
	    if(reset_n = '0') then                                                              
	      axis_tvalid_delay <= '0';                                                                
	      axis_tlast_delay <= '0';                                                                 
	    else                                                                                       
	      axis_tvalid_delay <= axis_tvalid;                                                        
	      axis_tlast_delay <= axis_tlast;                                                          
	    end if;                                                                                    
	  end if;                                                                                      
	end process;                                                                                   


	--read_pointer pointer

	process(clk)                                                       
	begin                                                                            
	  if (rising_edge (clk)) then                                            
	    if(reset_n = '0') then                                                
	      read_pointer <= 0;                                                         
	      tx_done  <= '0';                                                           
	    else                                                                         
	      if (read_pointer <= NUMBER_OF_OUTPUT_WORDS-1) then 
	        tx_done <= '0';                        
	        if (tx_en = '1') then                                                    
	          -- read pointer is incremented after every read from the FIFO          
	          -- when FIFO read signal is enabled.                                   
	          read_pointer <= read_pointer + 1;                                                                                          
	        end if;                                                                  
	      elsif (read_pointer = NUMBER_OF_OUTPUT_WORDS) then                         
	        -- tx_done is asserted when NUMBER_OF_OUTPUT_WORDS numbers of streaming data
	        -- has been out.        
	        read_pointer <= read_pointer + 1;                                                 
	        tx_done <= '1'; 
	      elsif (read_pointer > NUMBER_OF_OUTPUT_WORDS) then  
	        read_pointer <= 0; 
	        tx_done <= '0';                                                        
	      end  if;                                                                   
	    end  if;                                                                     
	  end  if;                                                                       
	end process;                                                                     


	--FIFO read enable generation 

	tx_en <= '1' when (M_AXIS_TREADY = '1' and axis_tvalid = '1') else '0';                                 
	                                                                                
	-- FIFO Implementation                                                          
	                                                                                
	-- Streaming output data is read from FIFO                                      
	  process(clk)                                                                                                     
	  begin                                                                         
	    if (rising_edge (clk)) then                                         
	      if(reset_n = '0') then   
	        read_ptr   <= 0;                                          
	    	stream_data_out <= "11111111";  
	      elsif (tx_en = '1') then                   
	        stream_data_out <= fifo_reg(read_ptr);          -- Read data from FIFO
            if read_ptr = FIFO_DEPTH-1 then
                read_ptr <= 0;                      
            else
                read_ptr <= read_ptr + 1;           
            end if;
	      end if;                                                                   
	     end if;                                                                    
	   end process;                                                                 

	-- Add user logic here
	
	
	full  <= full_sig;
    empty <= empty_sig;

    -- FIFO control process
    process (clk, reset_n)
    begin
        if rising_edge(clk) then
            if(reset_n = '0') then
                fifo_reg   <= (others => (others => '0'));  
                write_ptr  <= 0;                                                        
                count_fifo      <= 0;                            
                full_sig   <= '0';                          
                empty_sig  <= '1';      
                Rx_Rd_n <= '1'; 
                current_state_fifo_write <=IDLE;
                enough_data <='0'; 
            else
                case(current_state_fifo_write) is                
                    when IDLE =>                 
                        if write_en = '1' and full_sig = '0' then
                            current_state_fifo_write <= GET_DATA;
                            Rx_Rd_n <= '0';
                        else
                            current_state_fifo_write <= IDLE;
                            Rx_Rd_n <= '1';
                        end if; 
                                         
                    when GET_DATA =>
                        fifo_reg(write_ptr) <= data_in_Rx(7 downto 0); 
                        Rx_Rd_n <= '1';
                               
                        if write_ptr = FIFO_DEPTH-1 then
                            write_ptr <= 0;                     
                        else
                            write_ptr <= write_ptr + 1;         
                        end if;
                        count_fifo <= count_fifo + 1; 
                        current_state_fifo_write <= IDLE;
           
                    
                    when others =>
                        current_state_fifo_write <= IDLE;
                    
                end case;     
                
                
                if tx_en = '1' and empty_sig = '0' then
                    count_fifo <= count_fifo - 1; 
                end if;
                
                if read_pointer = NUMBER_OF_OUTPUT_WORDS then
                    enough_data <='0';  
                elsif count_fifo >= NUMBER_OF_OUTPUT_WORDS then
                    enough_data <='1';          
                end if;      
    
                -- Update full and empty flags
                if count_fifo = FIFO_DEPTH then
                    full_sig  <= '1';                       
                    empty_sig <= '0';                         
                elsif count_fifo = 0 then
                    full_sig  <= '0';                       
                    empty_sig <= '1';                       
                else
                    full_sig  <= '0';                       
                    empty_sig <= '0';                        
                end if;
            end if;
        end if;
    end process;

	-- User logic ends

end Behavioral;

