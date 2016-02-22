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
        
       
        --deal with cpu request
        cpu_req_p:process
        variable req:std_logic_vector(50 downto 0);
        variable nilreq:std_logic_vector(50 downto 0):=(others => '0');
        file logfile: text;
    	variable linept:line;
    	variable logct: std_logic_vector(50 downto 0);
        variable logsr: string(8 downto 1);
        
        begin
                if emp1='0' then
                --read from the fifo
                    re1<='1';
                    wait for 6 ps;
                    req:=out1;
                    file_open(logfile,"C:\Users\cao2\Documents\log3.txt",write_mode);
                    logct:=req;
                    logsr:="2222111,";
                    write(linept,logsr);
                    write(linept,logct);
                    writeline(logfile,linept);
                    file_close(logfile);
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
        
        
        
            
         


end Behavioral;
