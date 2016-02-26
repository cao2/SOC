----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/09/2015 10:27:30 AM
-- Design Name: 
-- Module Name: AXI - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;
use std.textio.all;
use IEEE.std_logic_textio.all;          -- I/O for logic types
library xil_defaultlib;
use xil_defaultlib.writefunction.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity AXI is
    Port (
            Clock: in std_logic;
            reset: in std_logic;
            cache_req1: in STD_LOGIC_VECTOR(50 downto 0);
            cache_req2: in STD_LOGIC_VECTOR(50 downto 0);
            
            wb_req1, wb_req2: in std_logic_vector(50 downto 0);
            
            memres: in STD_LOGIC_VECTOR(51 downto 0);
           
           
            res1: out STD_LOGIC_VECTOR(50 downto 0);    
            res2: out STD_LOGIC_VECTOR(50 downto 0);
            tomem: out STD_LOGIC_VECTOR(51 downto 0);
            
            snoop_req1: out STD_LOGIC_VECTOR(50 downto 0);
            snoop_req2: out STD_LOGIC_VECTOR(50 downto 0);
            snoop_res1,snoop_res2: in STD_LOGIC_VECTOR(50 downto 0);
            snp_hit1: in std_logic;
            snp_hit2: in std_logic;
            
            full_srq1,full_srq2: in std_logic;
           	full_brs1,full_brs2: in std_logic;
           	full_crq1,full_crq2,full_wb1,full_srs1,full_wb2,full_srs2,full_mrs: out std_logic;
           	full_m: in std_logic;
            full_b_m: out std_logic:='0'
           	
                 
     );
end AXI;


architecture Behavioral of AXI is
--fifo has 53 bits
--3 bits for indicating its source
--50 bits for packet
    type memory_type is array (31 downto 0) of std_logic_vector(53 downto 0);
    signal memory : memory_type :=(others => (others => '0'));   --memory for queue.
    signal readptr,writeptr : integer range 0 to 31 := 0;  --read and write pointers.begin
    
    
    signal in1,in4,in5,in6,in7: std_logic_vector(50 downto 0);
    signal in2, out2, in3,out3: std_logic_vector(51 downto 0);
    signal we1,we2,we3,we4,we5,we6,we7,re7,re1,re2,re3,re4,re5,re6: std_logic:='0';
	signal out1,out4,out5,out6,out7:std_logic_vector(50 downto 0);
	signal emp1,emp2,emp3,emp4,emp5,emp6,emp7,ful7,ful1,ful2,ful3,ful4,ful5,ful6: std_logic:='0';
	signal bus_res1_1, bus_res1_2,bus_res2_1, bus_res2_2: std_logic_vector(50 downto 0);
	signal mem_req1, mem_req2: std_logic_vector(50 downto 50);
	signal mem_ack1,mem_ack2,mem_ack3,mem_ack4, brs1_ack1, brs1_ack2, brs2_ack1, brs2_ack2: std_logic;
	
	signal bus_res1_1, bus_res1_2,bus_res2_1, bus_res2_2 : std_logic_vector(50 downto 0);
	signal brs1_ack1, brs1_ack2,brs2_ack1, brs2_ack2 : std_logic;
	signal tmp_brs1_1, tmp_brs1_2, tmp_brs2_1, tmp_brs2_2: std_logic_vector(50 downto 0);
	
	signal tomem1, tomem2 : std_logic_vector(50 downto 0);
    signal mem_ack1, mem_ack2 : std_logic;
    signal tmp_mem1, tmp_mem2: std_logic_vector(50 downto 0);
	
	
 begin  
 
	cache_req_fif1: entity xil_defaultlib.STD_FIFO(Behavioral) port map(
		CLK=>Clock,
		RST=>reset,
		DataIn=>in1,
		WriteEn=>we1,
		ReadEn=>re1,
		DataOut=>snoop_req2,
		Full=>full_crq1,
		Empty=>emp1
		);
		
	snp_res_fif1: entity xil_defaultlib.STD_FIFO(Behavioral) port map(
		CLK=>Clock,
		RST=>reset,
		DataIn=>in2,
		WriteEn=>we2,
		ReadEn=>re2,
		DataOut=>out2,
		Full=>full_srs1,
		Empty=>emp2
		);
	mem_res_fif: entity xil_defaultlib.STD_FIFO(Behavioral) 
	generic map(
		DATA_WIDTH => 52,
		FIFO_DEPTH => 256
	)
	port map(
		CLK=>Clock,
		RST=>reset,
		DataIn=>in3,
		WriteEn=>we3,
		ReadEn=>re3,
		DataOut=>out3,
		Full=>full_mrs,
		Empty=>emp3
		); 
		
	cache_req_fif2: entity xil_defaultlib.STD_FIFO(Behavioral) port map(
		CLK=>Clock,
		RST=>reset,
		DataIn=>in4,
		WriteEn=>we4,
		ReadEn=>re4,
		DataOut=>out4,
		
		Full=>full_crq2,
		Empty=>emp4
		);
	snp_res_fif2: entity xil_defaultlib.STD_FIFO(Behavioral) port map(
		CLK=>Clock,
		RST=>reset,
		DataIn=>in5,
		WriteEn=>we5,
		ReadEn=>re5,
		DataOut=>out5,
		Full=>full_srs2,
		Empty=>emp5
		);
		
	wb_fif1: entity xil_defaultlib.STD_FIFO(Behavioral) port map(
		CLK=>Clock,
		RST=>reset,
		DataIn=>in6,
		WriteEn=>we6,
		ReadEn=>re6,
		DataOut=>out6,
		Full=>full_wb1,
		Empty=>emp6
		); 
	wb_fif2: entity xil_defaultlib.STD_FIFO(Behavioral) port map(
		CLK=>Clock,
		RST=>reset,
		DataIn=>in7,
		WriteEn=>we7,
		ReadEn=>re7,
		DataOut=>out7,
		Full=>full_wb2,
		Empty=>emp7
		); 
 
   
        
        
    snp_res1_fifo: process(reset,Clock)
	   begin
        	if reset='1' then
        		we2<='0';
            elsif rising_edge(Clock) then
            	if snoop_res1(50 downto 50)="1" then
            		if snp_hit1='0' then
						in2<='0'&snoop_res1(50 downto 0);
					else
						in2<='1'&snoop_res1;
					end if;
                    we2<='1';
                else
                	we2<='0';
                end if;
                   
             end if;
	end process;
	
	mem_res_fifo: process(reset,Clock)
		begin
        	if reset='1' then
        		we3<='0';
            elsif rising_edge(Clock) then
            	if memres(51 downto 51)="1" then
                    in3<=memres;
                    we3<='1';
                else
                	we3<='0';
                end if;
                   
             end if;
	end process;
	
	
        
    snp_res2_fifo: process(reset,Clock)
	   begin	  
        	if reset='1' then
        		we5<='0';
            elsif rising_edge(Clock) then
            	if snoop_res2(50 downto 50)="1" then
					if snp_hit2='0' then
						in5<='0' & snoop_res2;
					else
						in5<='1' & snoop_res2;
					end if;
					we5<='1';
				else
					we5<='0';
				end if;
			end if;	
	end process;
	
	wb_req1_fifo: process(reset,Clock)
	   begin	  
        	if reset='1' then
        		we6<='0';
            elsif rising_edge(Clock) then
				if(wb_req1(50 downto 50)="1") then
					in6<=wb_req1;
					we6<='1';
				else
					we6<='0';
				end if;	
			end if;
	end process;

	wb_req2_fifo: process(reset,Clock)
	begin
        if reset='1' then
        	we6<='0';
        elsif rising_edge(Clock) then
			if(wb_req2(50 downto 50)="1") then
				in7<=wb_req2;
				we7<='1';
			else
				we7<='0';
			end if;
		end if;	
	end process;
	
		
	---deal with cache request
    cache_req1_p:process(reset,Clock)
        variable nilreq:std_logic_vector(50 downto 0):=(others => '0');
    begin
        if reset='1' then
        	snoop_req2 <= nilreq;
        elsif rising_edge(Clock) then
            snoop_req2 <= nilreq;
            if cache_req1(50 downto 50) = "1" and full_crq1/='1' then
                snoop_req2 <= cache_req1;
            end if;
        end if;
    end process;
    
	---deal with cache request
    cache_req2_p:process(reset,Clock)
        variable nilreq:std_logic_vector(50 downto 0):=(others => '0');
    begin
        if reset='1' then
            snoop_req1 <= nilreq;
        elsif rising_edge(Clock) then
            snoop_req1 <= nilreq;
            if cache_req2(50 downto 50) = "1" and full_crq2/='1' then
                snoop_req1 <= cache_req2;
            end if;
        end if;
    end process;    
    
    
    
    
    snp_res2_p: process(reset, Clock)
        variable nilreq:std_logic_vector(50 downto 0):=(others => '0');
    begin
        if reset = '1' then
            r5 <= '0';
            bus_res1_2 <= nilreq;
            tomem2 <= nilreq;
            tmp_brs1_2 <= nilreq;
            tmp_mem2 <=nilreq;
            
        elsif rising_edge(Clock) then
            ---here we are waiting for the fifo
            if bus_res1_ack2 ='1' then
                bus_res1_2 <= tmp_brs1_2;
            end if;
            
            if mem_ack2 = '1' then
                tomem2 <= tmp_mem2;
            end if;
            
            if out5(50 downto 50) = "1" then
                if out5(51 downto 51) ="1" then---it's a hit
                    --send bus_res1(an arbitor)
                    if bus_res1_2(50 downto 50) ="0" then
                        bus_res1_2 <= out5;
                    else
                        tmp_brs1_2 <= out5;
                    end if;
                else--it's a miss
                    ---send mem request
                    if tomem2(50 downto 50) = "0" then
                        tomem2 <= out5;
                    else
                        tmp_mem2 <= out5;
                    end if;
                 end if;
            else
                r5 <= '1';
            end if;
        end if;
    end process;
    
    
    --bus_res1 arbitor
    brs1_arbitor: process(reset,Clock)
        variable nilreq : std_logic_vector(50 downto 0):=(others => '0');
        variable cmd: std_logic_vector( 1 downto 0);
        variable shifter: std_logic := '0';
    begin  
        if reset ='1'  then
            brs1_ack1 <= '0';
            brs1_ack2 <= '0';
        elsif rising_edge(Clock) then
            cmd:= bus_res1_1(50 downto 50)& bus_res1_2(50 downto 50);
            case cmd is
                when "00" =>
                when "01" =>
                    bus_res1 <= bus_res1_2;
                    brs1_ack2 <= '1';
                when "10" =>
                    bus_res1 <= bus_res1_1;
                    brs1_ack1 <= '1';
                when "11" =>
                    if shifter = '0' then
                        shifter := '1';
                        bus_res1 <= bus_res1_2;
                        brs1_ack2 <= '1';
                    else
                        shifter := '0';
                        bus_res1 <= bus_res1_1;
                        brs1_ack1 <= '1';
                    end if;
                when others =>
            end case;
        end if;
    end process; 
        
    --tomem aribitor
    tomem_arbitor: process (reset, Clock)
        variable nilreq : std_logic_vector(50 downto 0):=(others => '0');
        variable cmd: std_logic_vector( 1 downto 0);
        variable shifter: std_logic := '0';
    begin
        if reset = '1' then
        	mem_ack1 <= '0';
        	mem_ack2 <= '0';
        elsif rising_edge(Clock) then
        	cmd:= tomem1(50 downto 50)& tomem2(50 downto 50);
            case cmd is
                when "00" =>
                when "01" =>
                    tomem <= '0'&tomem2;
                    mem_ack2 <= '1';
                when "10" =>
                    tomem <= '1'&tomem1;
                    mem_ack1 <= '1';
                when "11" =>
                    if shifter = '0' then
                        tomem <= '0'&tomem2;
                    	mem_ack2 <= '1';
                    else
                        tomem <= '1'&tomem1;
                    	mem_ack1 <= '1';
                    end if;
                when others =>
            end case;
        end if;
    end process;    
        
        
end Behavioral;
