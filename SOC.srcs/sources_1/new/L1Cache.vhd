----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/25/2015 10:15:11 PM
-- Design Name: 
-- Module Name: L1Cache - Behavioral
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
library xil_defaultlib;
use IEEE.STD_LOGIC_1164.ALL;
--use iEEE.std_logic_unsigned.all ;
USE ieee.numeric_std.ALL;
use std.textio.all;
use IEEE.std_logic_textio.all; 
use xil_defaultlib.all;
--use IEEE.STD_LOGIC_ARITH.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity L1Cache is
    Port ( 
           Clock: in std_logic;
           reset: in std_logic;
           cpu_req : in STD_LOGIC_VECTOR(50 downto 0);
           snoop_req : in STD_LOGIC_VECTOR(50 downto 0);
           bus_res  : in  STD_LOGIC_VECTOR(50 downto 0):= (others => '0');
           --01: read response
           --10: write response
           --11: fifo full response
           cpu_res : out STD_LOGIC_VECTOR(50 downto 0):= (others => '0');
           --01: read response
           --10: write response
           --11: fifo full response
           snoop_hit : out boolean;
           snoop_res : out STD_LOGIC_VECTOR(50 downto 0):= (others => '0');
           wb_req: out std_logic_vector(50 downto 0);
            --01: read request
            --10: write request
            --10,11: write back function
           full_cprq: out std_logic:='0';
           full_srq: out std_logic:='0';
           full_brs: out std_logic:='0';
           full_crq,full_wb,full_srs: in std_logic;
           cache_req : out STD_LOGIC_VECTOR(50 downto 0):= (others => '0')
           );
           
           
end L1Cache;

architecture Behavioral of L1Cache is
--IMB cache 1
--3 lsb: dirty bit, valid bit, exclusive bit
--cache hold valid bit ,dirty bit, exclusive bit, 6 bits tag, 32 bits data, 41 bits in total
	type rom_type is array (2**10-1 downto 0) of std_logic_vector (40 downto 0);     
	signal ROM_array : rom_type:= ((others=> (others=>'0')));
	signal we1,we2,we3,re1,re2,re3: std_logic:='0';
	signal out1,out2,out3:std_logic_vector(50 downto 0);
	signal emp1,emp2,emp3,ful1,ful2,ful3: std_logic:='0';	
	signal mem_req1,mem_req2,upd_req,write_req: std_logic_vector(50 downto 0);
	signal mem_res1,mem_res2: std_logic_vector(49 downto 0);
	signal hit1,hit2,upd_ack,write_ack,mem_ack1,mem_ack2: std_logic;
	signal in1,in2,in3: std_logic_vector(50 downto 0);
	signal cpu_res1, cpu_res2: std_logic_vector(50 downto 0);
	signal ack1, ack2: std_logic;
	signal wb_req_c, wb_res_c:integer:=1;
begin
	cpu_req_fif: entity xil_defaultlib.STD_FIFO(Behavioral) port map(
		CLK=>Clock,
		RST=>reset,
		DataIn=>in1,
		WriteEn=>we1,
		ReadEn=>re1,
		DataOut=> mem_req1,
		Full=>full_cprq,
		Empty=>emp1
		);
	snp_req_fif: entity xil_defaultlib.STD_FIFO(Behavioral) port map(
		CLK=>Clock,
		RST=>reset,
		DataIn=>in2,
		WriteEn=>we2,
		ReadEn=>re2,
		DataOut=>mem_req2,
		Full=>full_srq,
		Empty=>emp2
		);
	bus_res_fif: entity xil_defaultlib.STD_FIFO(Behavioral) port map(
		CLK=>Clock,
		RST=>reset,
		DataIn=>in3,
		WriteEn=>we3,
		ReadEn=>re3,
		DataOut=>upd_req,
		Full=>full_brs,
		Empty=>emp3
		);
	
	-- Store CPU requests into fifo	
	cpu_req_fifo: process (Clock)      
	begin
		if rising_edge(Clock) then
			if cpu_req(50 downto 50)="1" then
				in1 <= cpu_req;
				we1 <= '1';
			else
				we1 <= '0';
			end if;
		end if;
	end process;
        

	snp_req_fifo: process (Clock)
	begin	  
		if rising_edge (Clock) then
			if (snoop_req(50 downto 50)="1") then
				in2<=snoop_req;
				we2<='1';
			else
				we2<='0';
			end if;	
		end if;
	end process;
	

	bus_res_fifo: process (Clock)
	begin
		if rising_edge(Clock) then			
			if(bus_res(50 downto 50)="1") then
				in3<=bus_res;
				we3<='1';
			else
				we3<='0';
			end if;
		end if;
	end process;
		
		
	--deal with cpu request
   cpu_req_p:process (reset, Clock)
        	
        variable req:std_logic_vector(50 downto 0);
        variable nilreq:std_logic_vector(50 downto 0):=(others => '0');
        file 	 logfile: text;
        variable linept:line;
		variable logct: std_logic_vector(50 downto 0);
		variable logsr: string(8 downto 1);
		
	begin
		if (reset = '1') then
					-- reset signals
		elsif rising_edge(Clock) then
			if mem_ack1 = '1' then
				re1 <= '0'; 
				--if cache have it, make the return
				if mem_req1(49 downto 48)="10" and hit1='1' then
					if write_ack = '0' then--it's write
						write_req <= mem_req1;
					elsif write_ack = '1' then
						write_req <= (others => '0');
            	end if;
         	end if;

				if hit1 = '1' then
					cpu_res1 <= '1' & mem_res1(49 downto 0);
            	if ack1 = '1' then --after acknowlegement, reset it to empty request
            		cpu_res1 <= (others => '0');
            	end if;
				end if;

				if hit1 = '0' and full_crq = '0' then
                        --when cache request fifo is full, keep waiting
                        --what other option can i do
                     
					cache_req <= '1' & mem_res1;
				end if;
			elsif re1 = '0' and emp1 = '0' then
				re1 <= '1';
			end if;
		end if;
	end process;
        


 
        --deal with cache memory
	mem_control_unit:process(reset, Clock)
        variable res:std_logic_vector(49 downto 0);
        variable indx:integer;
        variable memcont: std_logic_vector(40 downto 0);
        variable nilmem: std_logic_vector(40 downto 0):=(others=>'0');
        variable nilreq:std_logic_vector(50 downto 0):=(others => '0');
        variable shifter:boolean:=false;
        
	begin
		if (reset = '1') then
		-- reset signals;
		elsif rising_edge(Clock) then
			if mem_req1(50 downto 50)="1" then
				indx := to_integer(unsigned(mem_req1(41 downto 32)));
         	memcont:=ROM_array(indx);
         	--if we can't find it in memory
         	if memcont=nilmem or memcont(40 downto 40)="0" or memcont(38 downto 38)="0"
                        or memcont(37 downto 32)/=mem_req1(47 downto 42) then
					mem_ack1<='1';
					hit1<='0';
					mem_res1 <= (others => '0');
				else
					mem_ack1<='1';
					hit1<='1';
					mem_res1 <= mem_req1(49 downto 32)& memcont(31 downto 0);
				end if;
			end if;
                

			if mem_req2(50 downto 50)="1" then
				indx:=to_integer(unsigned(mem_req2(41 downto 32)));
				memcont:=ROM_array(indx);
				-- if we can't find it in memory
				if memcont=nilmem or memcont(40 downto 40)="0" or memcont(38 downto 38)="0"
                        or memcont(37 downto 32)/=mem_req2(47 downto 42) then
					mem_ack2<='1';
					hit2<='0';
					mem_res2 <= (others => '0');
				else
					mem_ack2<='1';
					hit2<='1';
					mem_res2<=mem_req2(49 downto 32)&memcont(31 downto 0);
				end if;
			end if;
                
                --first deal with write request from cpu_request
                --the write is only sent here if the data exist in cahce memory
                
			-- Handling CPU write request (no update req from bus)
			if write_req(50 downto 50)="1" and upd_req(50 downto 50)="0" then
				indx := to_integer(unsigned(write_req(41 downto 32)));
				ROM_array(indx)<="100"&write_req(47 downto 42)&write_req(31 downto 0);
				write_ack<='1';    

			-- Handling update request (no write_req from CPU)
			elsif upd_req(50 downto 50)="1" and write_req(50 downto 50)="0" then
				
				indx := to_integer(unsigned(upd_req(41 downto 32)));
				memcont := ROM_array(indx);
				--if tags do not match, dirty bit is 1, and write_back fifo in BUS is not full, 
				if memcont(37 downto 32) /= upd_req(47 downto 42) and memcont(39 downto 39) = "1" and full_wb = '0' then
					wb_req <= "111"& memcont(37 downto 32)&upd_req(41 downto 32)&memcont(31 downto 0);
				end if;
				ROM_array(indx) <= "100" & upd_req(47 downto 42)&upd_req(31 downto 0);
				upd_ack<='1';

			elsif upd_req(50 downto 50)="1" and write_req(50 downto 50)="1" then
                        if shifter=true then
                            shifter:=false;
                            indx:=to_integer(unsigned(write_req(41 downto 32)));
                            ROM_array(indx)<="100"&write_req(47 downto 42)&write_req(31 downto 0);
                            write_ack<='1';    
                        else
                            shifter:=true;
                            indx:=to_integer(unsigned(upd_req(41 downto 32)));
                            memcont:=ROM_array(indx);
                            --if updating data already exist, no need to write back
                            if memcont(37 downto 32)=upd_req(47 downto 42) then
                                ROM_array(indx)<="100"&upd_req(47 downto 42)&upd_req(31 downto 0);
                                upd_ack<='1';
                            else --the position have a different data
                                if memcont(39 downto 39)="1" then -- if it's dirty
                                
                                    wb_req<="111"&memcont(37 downto 32)&upd_req(41 downto 32)&memcont(31 downto 0);
                                end if;
                                ROM_array(indx)<="100"&upd_req(47 downto 42)&upd_req(31 downto 0);
                            end if;
                            
                        end if;
                        
                    end if;
                
            
                
            end if;
        end process;

        
            
         


end Behavioral;
