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
            cache_req1 : in STD_LOGIC_VECTOR(50 downto 0):= (others => '0');
            cache_req2: in STD_LOGIC_VECTOR(50 downto 0):= (others => '0');
            cache_hit1: in boolean;
            cache_hit2: in boolean;
            snoop_res1,snoop_res2: in STD_LOGIC_VECTOR(50 downto 0);
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
            snoop1: out STD_LOGIC_VECTOR(50 downto 0);
            snoop2: out STD_LOGIC_VECTOR(50 downto 0)
                 
     );
end AXI;


architecture Behavioral of AXI is
--fifo has 53 bits
--3 bits for indicating its source
--50 bits for packet
    type memory_type is array (31 downto 0) of std_logic_vector(52 downto 0);
    signal memory : memory_type :=(others => (others => '0'));   --memory for queue.
    signal readptr,writeptr : integer range 0 to 31 := 0;  --read and write pointers.begin
 begin  
  process (Clock)
        file logfile: text;
        variable linept:line;
        variable logct: std_logic_vector(50 downto 0);
        variable logct1: std_logic_vector(51 downto 0);
        variable logsr: string(8 downto 1);
  
        variable tmplog: std_logic_vector(52 downto 0);
        variable enr: boolean:=false;
        variable enw: boolean:=true; 
        variable address: integer;
        variable flag: boolean:=false;
        variable nada: std_logic_vector(50 downto 0):=(others=>'0');
        variable nadamem: std_logic_vector(51 downto 0):=(others=>'0');
        variable bo:boolean;
  begin
    if (rising_edge(Clock)) then
    --first set all out signal to nil
    res1<=nada;
    res2<=nada;
    tomem<=nadamem;
    snoop1<=nada;
    snoop2<=nada;
    --cache request from cpu1: 000
    --------------------cpu2:  001
    --memory response for cpu1:010
    -- for cpu2              : 011
    --snoop response from cpu1 with hit: 100
    --snoop respons from cpu1 with miss: 101
    --snoop              cpu2 hit: 110
    --                      miss:  111 
        if cache_req1(50)/='0' then
          if enw=true then
            memory(writeptr) <= "000"&cache_req1;
            writeptr <= writeptr + 1;
            enr:=true;
            --writeptr loops
            if(writeptr = 31) then       
                writeptr <= 0;
            end if;
            --check if full
            if(writeptr=readptr) then
                enw:=false;
                full_b_c1<='1';
                full_b_c2<='1';
                full_b_m<='1';
            end if; 
       
         end if;--if enw=true;
        end if;--if req1='00000'
        if cache_req2(50)/='0' then
                  if enw=true then
                    memory(writeptr) <= "001"&cache_req2;
                    writeptr <= writeptr + 1;
                    enr:=true;
                    --writeptr loops
                    if(writeptr = 31) then       
                        writeptr <= 0;
                    end if;
                    --check if full
                    if(writeptr=readptr) then
                        enw:=false; full_b_c1<='1';
                                   full_b_c2<='1';
                                   full_b_m<='1';
                    end if; 
                
                 end if;--if enw=true;
        end if;--if req2='00000'
        
        if memres(51)/='0' then
                  if enw=true then
                    if memres(50)='0' then
                        memory(writeptr) <= "010"&memres(49 downto 0);
                    elsif memres(50)='1' then
                        memory(writeptr) <="011"&memres(49 downto 0);
                    end if;
                    writeptr <= writeptr + 1;
                    enr:=true;
                    --writeptr loops
                    if(writeptr = 31) then       
                        writeptr <= 0;
                    end if;
                    --check if full
                    if(writeptr=readptr) then
                        enw:=false; full_b_c1<='1';
                                   full_b_c2<='1';
                                   full_b_m<='1';
                    end if; 
               
                 end if;--if enw=true;
            end if;--if memres/=nadamem
            
            if snoop_res1(50)/='0' then
                if enw=true then
                    if cache_hit1=true then
                        memory(writeptr)<="100"&snoop_res1;
                    else
                        memory(writeptr)<="101"&snoop_res1;
                    end if;--hit1=true
                    writeptr<=writeptr+1;
                    enr:=true;
                    if (writeptr=31) then
                        writeptr<=0;
                    end if;
                    if (writeptr=readptr) then
                        enw:=false; full_b_c1<='1';
                                   full_b_c2<='1';
                                   full_b_m<='1';
                    end if;
                
                end if;--enw=true
            end if;--if snoop_res1;
            
            if snoop_res2(50)/='0' then
                if enw=true then
                    if cache_hit2=true then
                        memory(writeptr)<="110"&snoop_res2;
                    else
                        memory(writeptr)<="111"&snoop_res2;
                    end if;--hit1=true
                    writeptr<=writeptr+1;
                    enr:=true;
                    if (writeptr=31) then
                        writeptr<=0;
                    end if;
                    if (writeptr=readptr) then
                        enw:=false; full_b_c1<='1';
                                   full_b_c2<='1';
                                   full_b_m<='1';
                    end if;
                elsif enw=false then
                    L1: while enw=false loop
                                      end loop L1;
                    if cache_hit2=true then
                        memory(writeptr)<="110"&snoop_res2;
                    else
                        memory(writeptr)<="111"&snoop_res2;
                    end if;--hit1=true
                    writeptr<=writeptr+1;
                    enr:=true;
                    if (writeptr=31) then
                        writeptr<=0;
                    end if;
                    if (writeptr=readptr) then
                        enw:=false; full_b_c1<='1';
                                   full_b_c2<='1';
                                   full_b_m<='1';
                    end if;
                end if;--enw=true
            end if;--if snoop_res1;               
                
                   --cache request from cpu1: 000
                   --------------------cpu2:  001
                   --memory response for cpu1:010
                   -- for cpu2              : 011
                   --snoop response from cpu1 with hit: 100
                   --snoop respons from cpu1 with miss: 101
                   --snoop              cpu2 hit: 110
                   --                      miss:  111     
        if (enr=true) then
            enw:=true;
            full_b_m<='0';
            full_b_c1<='0';
            full_b_c2<='0';
            tmplog:= memory(readptr);
            readptr <= readptr + 1;  
            if(readptr = 31) then      --resetting read pointer.
                readptr <= 0;
            end if;
            if(writeptr=readptr) then
                enr:=false;
            end if;
            --if it's an cache request fron cpu1, send snoop request to cpu2      
            if tmplog(52 downto 50)="000" then
              if full_c2_b='0' then
                snoop2<='1'&tmplog(49 downto 0);
                logct:='1'&tmplog(49 downto 0);
                logsr:="snoop_2,";
                bo:=write50(logct,logsr);
              else
                memory(writeptr) <= tmplog;
                writeptr <= writeptr + 1;
                enr:=true;
                full_b_c1<='0';
                full_b_c2<='0';
                full_b_m<='0';
                --writeptr loops
                if(writeptr = 31) then       
                     writeptr <= 0;
                end if;
                --check if full
                if(writeptr=readptr) then
                     enw:=false;
                     full_b_c1<='1';
                     full_b_c2<='1';
                     full_b_m<='1';
                end if;
              end if; 
            --request from cpu2
        elsif tmplog(52 downto 50)="001" then
           if full_c1_b='0' then
                snoop1<='1'&tmplog(49 downto 0);
                logct:='1'&tmplog(49 downto 0);
                logsr:="snoop_1,";
                bo:=write50(logct,logsr);
            else
              memory(writeptr) <= tmplog;
              writeptr <= writeptr + 1;
              enr:=true;
              full_b_c1<='0';
              full_b_c2<='0';
              full_b_m<='0';
              --writeptr loops
              if(writeptr = 31) then       
                   writeptr <= 0;
              end if;
              --check if full
              if(writeptr=readptr) then
                   enw:=false;
                   full_b_c1<='1';
                   full_b_c2<='1';
                   full_b_m<='1';
              end if;
            end if;                 
         -- if snoop hit from cpu2 or mem res for cpu1
         elsif tmplog(52 downto 50)="010" or tmplog(52 downto 50)="100" then
            if full_c1_b='0' then
                res1<='1'&tmplog(49 downto 0);
                logct:='1'&tmplog(49 downto 0);
                logsr:="bs1_res,";
                bo:=write50(logct,logsr);
            else
                memory(writeptr) <= tmplog;
                writeptr <= writeptr + 1;
                enr:=true;
                full_b_c1<='0';
                full_b_c2<='0';
                full_b_m<='0';
                --writeptr loops
                if(writeptr = 31) then       
                     writeptr <= 0;
                end if;
                --check if full
                if(writeptr=readptr) then
                    enw:=false;
                    full_b_c1<='1';
                    full_b_c2<='1';
                    full_b_m<='1';
                end if;
            end if;             
       --if get the stuff from cache or mem for cache2                                            
       elsif tmplog(52 downto 50)="011" or tmplog(52 downto 50)="110"then
            if full_c2_b='0' then
                res2<='1'&tmplog(49 downto 0);
                logct:='1'&tmplog(49 downto 0);
                logsr:="bs2_res,";
                bo:=write50(logct,logsr);
            else
                memory(writeptr) <= tmplog;
                writeptr <= writeptr + 1;
                enr:=true;
                full_b_c1<='0';
                full_b_c2<='0';
                full_b_m<='0';
                --writeptr loops
                if(writeptr = 31) then       
                    writeptr <= 0;
                end if;
                --check if full
                if(writeptr=readptr) then
                    enw:=false;
                    full_b_c1<='1';
                    full_b_c2<='1';
                    full_b_m<='1';
                end if;
            end if;             
            
            --if snoop miss from cache 1, means cahce2 need it from mem                                             
       elsif tmplog(52 downto 50)="101" then
            if full_m='0' then
                tomem<="11"&tmplog(49 downto 0);
                logct1:="11"&tmplog(49 downto 0);
                logsr:="axi_mem,";
                bo:=write51(logct1,logsr);
            else
                memory(writeptr) <= tmplog;
                writeptr <= writeptr + 1;
                enr:=true;
                full_b_c1<='0';
                full_b_c2<='0';
                full_b_m<='0';
                --writeptr loops
                if(writeptr = 31) then       
                    writeptr <= 0;
                end if;
                --check if full
                if(writeptr=readptr) then
                    enw:=false;
                    full_b_c1<='1';
                    full_b_c2<='1';
                    full_b_m<='1';
                end if;
            end if;             
            --if snoop miss from cache2, ask mem for cahce1                                             
      elsif tmplog(52 downto 50)="111" then
            if full_m='0' then
                tomem<="10"&tmplog(49 downto 0);
                logct1:="10"&tmplog(49 downto 0);
                logsr:="axi_mem,";
                bo:=write51(logct1,logsr);
            else
                memory(writeptr) <= tmplog;
                writeptr <= writeptr + 1;
                enr:=true;
                full_b_c1<='0';
                full_b_c2<='0';
                full_b_m<='0';
                --writeptr loops
                if(writeptr = 31) then       
                    writeptr <= 0;
                end if;
                --check if full
                if(writeptr=readptr) then
                    enw:=false;
                    full_b_c1<='1';
                    full_b_c2<='1';
                    full_b_m<='1';
                end if;
            end if;     
                    
      end if; --tmplog(52 downto 50)
            
        end if; --if enr=1
      end if;--rising clck
    
  end process;
end Behavioral;
