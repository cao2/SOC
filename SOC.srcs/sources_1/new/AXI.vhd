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
            cache_req1 : in STD_LOGIC_VECTOR(50 downto 0):= (others => '0');
            cache_req2: in STD_LOGIC_VECTOR(50 downto 0):= (others => '0');
            
            
            memres: in STD_LOGIC_VECTOR(51 downto 0);
            full_c1_b: in std_logic;
            full_c2_b: in std_logic;
            full_m: in std_logic;
            
            full_b_m: out std_logic:='0';
            full_b_c1: out std_logic:='0';
            full_b_c2: out std_logic:='0';
            res1: out STD_LOGIC_VECTOR(50 downto 0);    
            res2: out STD_LOGIC_VECTOR(50 downto 0);
            tomem: out STD_LOGIC_VECTOR(51 downto 0);
            
            snoop_req1: out STD_LOGIC_VECTOR(50 downto 0);
            snoop_req2: out STD_LOGIC_VECTOR(50 downto 0);
            snoop_res1,snoop_res2: in STD_LOGIC_VECTOR(50 downto 0);
            snp_hit1: in boolean;
            snp_hit2: in boolean;
            
            full_srq1,full_srq2: in std_logic;
           	full_brs1,full_brs2: in std_logic;
           	full_crq1,full_crq2,full_wb1,full_srs1,full_wb2,full_srs2,full_mrs: out std_logic;
           	
                 
     );
end AXI;


architecture Behavioral of AXI is
--fifo has 53 bits
--3 bits for indicating its source
--50 bits for packet
    type memory_type is array (31 downto 0) of std_logic_vector(53 downto 0);
    signal memory : memory_type :=(others => (others => '0'));   --memory for queue.
    signal readptr,writeptr : integer range 0 to 31 := 0;  --read and write pointers.begin
    
    
    signal in1,in2,in3,in4,in5,in6,int7: std_logic_vector(50 downto 0);
    signal we1,we2,we3,we4,we5,we6,we7,re7,re1,re2,re3,re4,re5,re6: std_logic:='0';
	signal out1,out2,out3,out4,out5,outt,ou7:std_logic_vector(50 downto 0);
	signal emp1,emp2,emp3,emp4,emp5,emp6,emp7,ful7,ful1,ful2,ful3,ful4,ful5,ful6: std_logic:='0';
	signal bus_res1_1, bus_res1_2,bus_res2_1, bus_res2_2: std_logic_vector(50 downto 0);
	signal mem_req1, mem_req2: std_logic_vector(50 downto 50);
	signal mem_ack1,mem_ack2,mem_ack3,mem_ack4, brs1_ack1, brs1_ack2, brs2_ack1, brs2_ack2: std_logic;
	
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
		DATA_WIDTH => 52;
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
		Full=>full_wbrq1,
		Empty=>emp6
		); 
	wb_fif2: entity xil_defaultlib.STD_FIFO(Behavioral) port map(
		CLK=>Clock,
		RST=>reset,
		DataIn=>in7,
		WriteEn=>we7,
		ReadEn=>re7,
		DataOut=>out7,
		Full=>full_wbrq2,
		Empty=>emp7
		); 
 
   cache_req1_fifo: process(Clock)
        begin
        	if reset='1' then
        		we1<='0';
            elsif rising_edge(Clock) then
            	if cache_req1(50 downto 50)="1" then
                    in1<=cpu_req1;
                    we1<='1';
                else
                	we1<='0';
                end if;
                   
             end if;
    end process;
        
        
    snp_res1_fifo: process
	   begin
        	if reset='1' then
        		we2<='0';
            elsif rising_edge(Clock) then
            	if snoop_res1(50 downto 50)="1" then
            		if snoop_hit1='0' then
						in2<='0'&snoop_res1(49 downto 49);
					else
						in2<=cpu_req1;
					end if;
                    we2<='1';
                else
                	we2<='0';
                end if;
                   
             end if;
	end process;
	
	mem_res_fifo: process
		begin
        	if reset='1' then
        		we3<='0';
            elsif rising_edge(Clock) then
            	if memres(51 downto 51)="1" then
                    in<3=cpu_req1;
                    we3<='1';
                else
                	we3<='0';
                end if;
                   
             end if;
	end process;
	
	cache_req2_fifo: process
        begin
        	if reset='1' then
        		we4<='0';
            elsif rising_edge(Clock) then
            	if cache_req2(50 downto 50)="1" then
                    in4<=cpu_req2;
                    we4<='1';
                else
                	we4<='0';
                end if;
             end if;
    end process;
        
    snp_res2_fifo: process
	   begin	  
        	if reset='1' then
        		we5<='0';
            elsif rising_edge(Clock) then
            	if snoop_res2(50 downto 50)="1" then
					if snoop_hit2='0' then
						in5<='0'&snoop_res2(49 downto 49);
					else
						in5<=snoop_res2;
					end if;
					we5<='1';
				else
					we5<='0';
				end if;
			end if;	
	end process;
	
	wb_req1_fifo: process
	begin	  
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

	wb_req2_fifo: process
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
			wait on Clock
	end process;
	
		
	---deal with cache request
    cache_req1_p:process
        variable req:std_logic_vector(50 downto 0);
        variable nilreq:std_logic_vector(50 downto 0):=(others => '0');
        begin
        	if reset='1' then
        		re1 <= '0';
        		snp_req2=>nilreq;
        	elsif rising_edge(Clock) then
                if emp1='0' and full_srq1/='1' then
                --read from the fifo
                    re1<='1';
                else
                    re1<='0';  
                end if;
            end if;
    end process;
    
    
end Behavioral;
