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
            cache_req1 : in STD_LOGIC_VECTOR(49 downto 0):= (others => '0');
            cache_req2: in STD_LOGIC_VECTOR(49 downto 0):= (others => '0');
            cache_hit1: in boolean;
            cache_hit2: in boolean;
            snoop_res1,snoop_res2: in STD_LOGIC_VECTOR(49 downto 0);
            memres: in STD_LOGIC_VECTOR(50 downto 0);
            
            
            res1: out STD_LOGIC_VECTOR(49 downto 0);    
            res2: out STD_LOGIC_VECTOR(49 downto 0);
            tomem: out STD_LOGIC_VECTOR(50 downto 0);
            snoop1: out STD_LOGIC_VECTOR(49 downto 0);
            snoop2: out STD_LOGIC_VECTOR(49 downto 0)
                 
     );
end AXI;

architecture Behavioral of AXI is
--fifo has 53 bits
--3 bits for indicating its source
--50 bits for packet
    type memory_type is array (31 downto 0) of std_logic_vector(53 downto 0);
    signal memory : memory_type :=(others => (others => '0'));   --memory for queue.
    signal readptr,writeptr : integer range 0 to 31 := 0;  --read and write pointers.begin
 begin  
  process (Clock)
   file logfile: text;
     variable linept:line;
      variable logct: std_logic_vector(49 downto 0);
      variable logct1: std_logic_vector(50 downto 0);
        variable logsr: string(8 downto 1);
  
    variable tmplog: std_logic_vector(53 downto 0);
    variable enr: boolean:=false;
    variable enw: boolean:=true; 
    variable address: integer;
    variable flag: boolean:=false;
    variable nada: std_logic_vector(49 downto 0):=(others=>'0');
    variable nadamem: std_logic_vector(50 downto 0):=(others=>'0');
    begin
    if (rising_edge(Clock)) then
    --cache request from cpu1: 000
    --------------------cpu2:  001
    --memory response for cpu1:010
    -- for cpu2              : 011
    --snoop response from cpu1 with hit: 100
    --snoop respons from cpu1 with miss: 101
    --snoop              cpu2 hit: 110
    --                      miss:  111 
        if cache_req1/=nada then
          if enw=true then
            memory(writeptr) <= "0000"&cache_req1;
            writeptr <= writeptr + 1;
            enr:=true;
            --writeptr loops
            if(writeptr = 31) then       
                writeptr <= 0;
            end if;
            --check if full
            if(writeptr=readptr) then
                enw:=false;
            end if; 
        --send fifo full message
         elsif enw=false then
            res1<="110"&cache_req1(47 downto 0);
         end if;--if enw=true;
        end if;--if req1='00000'
        if cache_req2/=nada then
                  if enw=true then
                    memory(writeptr) <= "0010"&cache_req2;
                    writeptr <= writeptr + 1;
                    enr:=true;
                    --writeptr loops
                    if(writeptr = 31) then       
                        writeptr <= 0;
                    end if;
                    --check if full
                    if(writeptr=readptr) then
                        enw:=false;
                    end if; 
                --send fifo full message
                 elsif enw=false then
                    res2<="110"&cache_req2(47 downto 0);
                 end if;--if enw=true;
        end if;--if req2='00000'
        if memres/=nadamem then
                  if enw=true then
                    memory(writeptr) <= "010"&memres;
                    writeptr <= writeptr + 1;
                    enr:=true;
                    --writeptr loops
                    if(writeptr = 31) then       
                        writeptr <= 0;
                    end if;
                    --check if full
                    if(writeptr=readptr) then
                        enw:=false;
                    end if; 
                --send fifo full message
                 elsif enw=false then
                    res1<="11"&memres(47 downto 0);
                 end if;--if enw=true;
                end if;--if req1='00000'
                
                
                   --cache request from cpu1: 000
                   --------------------cpu2:  001
                   --memory response for cpu1:010
                   -- for cpu2              : 011
                   --snoop response from cpu1 with hit: 100
                   --snoop respons from cpu1 with miss: 101
                   --snoop              cpu2 hit: 110
                   --                      miss:  111        
        if (enr=true) then
            tmplog:= memory(readptr);
            readptr <= readptr + 1;  
            if(readptr = 31) then      --resetting read pointer.
                readptr <= 0;
            end if;
            if(writeptr=readptr) then
                enr:=false;
            end if;
            --if it's an cache request fron cpu1, send snoop request to cpu2      
            if tmplog(53 downto 51)="000" then
                snoop2<=tmplog(49 downto 0);
                logct:=tmplog(49 downto 0);
                file_open(logfile,"C:\Users\cao2\Documents\log.txt",append_mode);
                                                         logsr:="snoop_2,";
                                                         write(linept,logsr);
                                                         write(linept,logct);
                                                         writeline(logfile,linept);
                                                         file_close(logfile);
            elsif tmplog(53 downto 51)="001" then
                snoop1<=tmplog(49 downto 0);
                logct:=tmplog(49 downto 0);
                file_open(logfile,"C:\Users\cao2\Documents\log.txt",append_mode);
                                                         logsr:="snoop_1,";
                                                         write(linept,logsr);
                                                         write(linept,logct);
                                                         writeline(logfile,linept);
                                                         file_close(logfile);
            elsif tmplog(53 downto 51)="010" or tmplog(52 downto 50)="110" then
                res1<=tmplog(49 downto 0);
                logct:=tmplog(49 downto 0);
                file_open(logfile,"C:\Users\cao2\Documents\log.txt",append_mode);
                                                         logsr:="ac1_res,";
                                                         write(linept,logsr);
                                                         write(linept,logct);
                                                         writeline(logfile,linept);
                                                         file_close(logfile);
            elsif tmplog(53 downto 51)="011" or tmplog(52 downto 50)="100"then
                res2<=tmplog(49 downto 0);
                logct:=tmplog(49 downto 0);
                file_open(logfile,"C:\Users\cao2\Documents\log.txt",append_mode);
                                                         logsr:="ac2_res,";
                                                         write(linept,logsr);
                                                         write(linept,logct);
                                                         writeline(logfile,linept);
                                                         file_close(logfile);
            elsif tmplog(53 downto 51)="101" then
                tomem<="1"&tmplog(49 downto 0);
                logct1:="1"&tmplog(49 downto 0);
                file_open(logfile,"C:\Users\cao2\Documents\log.txt",append_mode);
                                                         logsr:="axi_mem,";
                                                         write(linept,logsr);
                                                         write(linept,logct1);
                                                         writeline(logfile,linept);
                                                         file_close(logfile);
            elsif tmplog(53 downto 51)="111" then
                tomem<="0"&tmplog(49 downto 0);
                logct1:="1"&tmplog(49 downto 0);
                file_open(logfile,"C:\Users\cao2\Documents\log.txt",append_mode);
                                                         logsr:="axi_mem,";
                                                         write(linept,logsr);
                                                         write(linept,logct1);
                                                         writeline(logfile,linept);
                                                         file_close(logfile);
            end if;
            tomem<='1'&tmplog(49 downto 0);
        end if; --if enr=1
      end if;--rising clck
    
  end process;
end Behavioral;
