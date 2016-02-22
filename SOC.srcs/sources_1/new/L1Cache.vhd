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
		DataOut=>out1,
		Full=>full_cprq,
		Empty=>emp1
		);
	snp_req_fif: entity xil_defaultlib.STD_FIFO(Behavioral) port map(
		CLK=>Clock,
		RST=>reset,
		DataIn=>in2,
		WriteEn=>we2,
		ReadEn=>re2,
		DataOut=>out2,
		Full=>full_srq,
		Empty=>emp2
		);
	bus_res_fif: entity xil_defaultlib.STD_FIFO(Behavioral) port map(
		CLK=>Clock,
		RST=>reset,
		DataIn=>in3,
		WriteEn=>we3,
		ReadEn=>re3,
		DataOut=>out3,
		Full=>full_brs,
		Empty=>emp3
		);
	
	--read request into each fifo	
        cpu_req_fifo: process
        file logfile: text;
             variable linept:line;
             variable logct: std_logic_vector(50 downto 0);
             variable logsr: string(8 downto 1);
        begin
            if cpu_req(50 downto 50)="1" then
                    in1<=cpu_req;
                    we1<='1';
                    wait for 4 ps;
                    we1<='0';
                    
                    file_open(logfile,"C:\Users\cao2\Documents\log3.txt",write_mode);
                    logct:=cpu_req;
                    logsr:="1111111,";
                    write(linept,logsr);
                    write(linept,logct);
                    writeline(logfile,linept);
                    file_close(logfile);
                    
                end if;
                
             
             wait on Clock;
        end process;
        
        snp_req_fifo: process
        begin      
            
                if(snoop_req(50 downto 50)="1") then
                    in2<=snoop_req;
                    we2<='1';
                    wait for 4 ps;
                    we2<='0';
                end if;    
           wait;
        end process;
        
        bus_res_fifo: process
        begin
              
                if(bus_res(50 downto 50)="1") then
                    in3<=bus_res;
                    we3<='1';
                    wait for 4 ps;
                    we3<='0';
                end if;
            wait;
        end process;
        
        --deal with cpu request
        cpu_req_p:process
        variable req:std_logic_vector(50 downto 0);
        variable nilreq:std_logic_vector(50 downto 0):=(others => '0');
        begin
            
                if emp1='0' then
                --read from the fifo
                    re1<='1';
                    wait for 2 ps;
                    req:=out1;
                    re1<='0';
                    --first check if the requested data is in cache
                    mem_req1<=req;
                    while mem_ack1='0' loop
                    end loop;
                    mem_req1<=nilreq;
                    --if cache have it, make the return
                    if hit1='1' then
                        if req(49 downto 48)="10" then--it's write
                            write_req<=req;
                            while write_ack='0' loop
                            end loop;
                            write_req<=nilreq;
                        end if;
                        cpu_res1<='1'&mem_res1(49 downto 0);
                        while ack1='0' loop
                        end loop;
                        --after acknowlegement, reset it to empty request
                        cpu_res1<=nilreq;
                    else
                        --when cache request fifo is full, keep waiting
                        --what other option can i do
                        while full_crq='1' loop
                        end loop;
                        cache_req<=req;
                    end if;
                end if;
            
            wait on Clock;
        end process;
        
        --deal withe snoop request
        snp_req_p:process
        variable req:std_logic_vector(50 downto 0);
        variable nilreq:std_logic_vector(50 downto 0):=(others => '0');
        begin
           wait for 2 ps;
            
                --first reset the output
                snoop_res<=nilreq;
                snoop_hit<=false;
                wait for 2 ps;
                if emp2='0' then
                    re2<='1';
                    req:=out2;
                    mem_req2<=req;
                    while mem_ack2='0' loop
                    end loop;
                    mem_req2<=nilreq;
                    if hit2='1' then
                        --while until fifo not full
                        while full_srs='1' loop
                        end loop;
                        snoop_res<='1'&mem_res2(49 downto 0);
                        snoop_hit<=true;
                    else
                        while full_srs='1' loop
                        end loop;
                        snoop_hit<=false;
                        snoop_res<='1'&nilreq(49 downto 0);
                    end if;
                    
                end if;
           wait;
        end process;
        
        --deal with bus response
        bus_res_p:process
        variable res:std_logic_vector(50 downto 0);
        variable nilreq:std_logic_vector(50 downto 0):=(others => '0');
        begin
           wait for 20 ps;
            
                cpu_res<=nilreq;
                if emp3='0' then
                    re3<='1';
                    wait for 2 ps;
                    res:=out3;
                    upd_req<=res;
                    while upd_ack='0' loop
                    end loop;
                    upd_req<=nilreq;
                    cpu_res<=res;
                end if;
           wait;
        end process;
        
        
        --deal with cache memory
        mem_control_unit:process(Clock)
        variable res:std_logic_vector(49 downto 0);
        variable indx:integer;
        variable memcont: std_logic_vector(40 downto 0);
        variable nilmem: std_logic_vector(40 downto 0):=(others=>'0');
        variable nilreq:std_logic_vector(50 downto 0):=(others => '0');
        variable shifter:boolean:=false;
        
        begin
            if rising_edge(Clock) then
            --reset all acknowlege
            upd_ack<='0';
            write_ack<='0';
            mem_ack1<='0';
            mem_ack2<='0';
                if mem_req1(50 downto 50)="1" then
                    indx:=to_integer(unsigned(mem_req1(41 downto 32)));
                    memcont:=ROM_array(indx);
                    --if we can't find it in memory
                    if memcont=nilmem or memcont(40 downto 40)="0" or memcont(38 downto 38)="0"
                        or memcont(37 downto 32)/=mem_req1(47 downto 42) then
                        mem_ack1<='1';
                        hit1<='0';
                    else
                        mem_ack1<='1';
                        hit1<='1';
                        mem_res1<=mem_req1(49 downto 32)&memcont(31 downto 0);
                    end if;
                end if;
                
                if mem_req2(50 downto 50)="1" then
                    indx:=to_integer(unsigned(mem_req2(41 downto 32)));
                    memcont:=ROM_array(indx);
                    --if we can't find it in memory
                    if memcont=nilmem or memcont(40 downto 40)="0" or memcont(38 downto 38)="0"
                        or memcont(37 downto 32)/=mem_req2(47 downto 42) then
                        mem_ack2<='1';
                        hit2<='0';
                    else
                        mem_ack2<='1';
                        hit2<='1';
                        mem_res2<=mem_req2(49 downto 32)&memcont(31 downto 0);
                    end if;
                end if;
                
                --first deal with write request from cpu_request
                --the write is only sent here if the data exist in cahce memory
                
                    if write_req(50 downto 50)="1" and upd_req(50 downto 50)="0" then
                        indx:=to_integer(unsigned(write_req(41 downto 32)));
                        ROM_array(indx)<="100"&write_req(47 downto 42)&write_req(31 downto 0);
                        write_ack<='1';    
                            
                    elsif upd_req(50 downto 50)="1" and write_req(50 downto 50)="0" then
                        indx:=to_integer(unsigned(upd_req(41 downto 32)));
                        memcont:=ROM_array(indx);
                        --if updating data already exist, no need to write back
                        if memcont(37 downto 32)=upd_req(47 downto 42) then
                            ROM_array(indx)<="100"&upd_req(47 downto 42)&upd_req(31 downto 0);
                            upd_ack<='1';
                        else --the position have a different data
                            if memcont(39 downto 39)="1" then -- if it's dirty
                                while full_wb='1' loop
                                end loop;
                                wb_req<="111"&memcont(37 downto 32)&upd_req(41 downto 32)&memcont(31 downto 0);
                            end if;
                            ROM_array(indx)<="100"&upd_req(47 downto 42)&upd_req(31 downto 0);
                        end if;
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
                                    while full_wb='1' loop
                                    end loop;
                                    wb_req<="111"&memcont(37 downto 32)&upd_req(41 downto 32)&memcont(31 downto 0);
                                end if;
                                ROM_array(indx)<="100"&upd_req(47 downto 42)&upd_req(31 downto 0);
                            end if;
                            
                        end if;
                        
                    end if;
                
            
                
            end if;
        end process;
        
        
            
         


end Behavioral;
