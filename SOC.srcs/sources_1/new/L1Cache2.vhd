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
use IEEE.STD_LOGIC_1164.ALL;
--use iEEE.std_logic_unsigned.all ;
USE ieee.numeric_std.ALL;
use std.textio.all;
use IEEE.std_logic_textio.all; 

--use IEEE.STD_LOGIC_ARITH.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity L1Cache2 is
    Port ( 
    --packet has 2 bits command , 16 bits address, 32 bits data content
    --input from cpu
           Clock: in std_logic;
           --00 read request
           --01 write request
           req : in STD_LOGIC_VECTOR(49 downto 0):= (others => 'X');
    --input from bus about snoop request
            --00 read request snoop
            --01 write snoop request--if found, invalidate
           snoop_req : in STD_LOGIC_VECTOR(49 downto 0);
    --input from bus about response
           --00 read response
           --01 write response
           --10,11 fifo full response
           bus_res  : in  STD_LOGIC_VECTOR(49 downto 0):= (others => '0');
           
    --output to cpu's request
    --oreq has the same type as of the req 
           --01: read response
           --10: write response
           --11: fifo full response
           res : out STD_LOGIC_VECTOR(49 downto 0):= (others => '0');
    --output to bus's snoop request
           --01: read response
           --10: write response
           --11: fifo full response
           snoop_hit : out boolean;
           snoop_res : out STD_LOGIC_VECTOR(49 downto 0):= (others => '0');
     --output to ask for bus
            --01: read request
            --10: write request
            --10,11: write back function
           bus_req : out STD_LOGIC_VECTOR(49 downto 0):= (others => '0'));
end L1Cache2;

architecture Behavioral of L1Cache2 is
--IMB cache 1
--3 lsb: dirty bit, valid bit, exclusive bit
--****
--cache hold valid bit ,dirty bit, exclusive bit, 6 bits tag, 32 bits data, 41 bits in total
--****
      type rom_type is array (2**10-1 downto 0) of std_logic_vector (40 downto 0);     
      signal ROM_array : rom_type:= ((others=> (others=>'0')));
         --create fifo that can hold 32 task
         --first two digit indicate source of packet
      type memory_type is array (31 downto 0) of std_logic_vector(51 downto 0);
      signal memory : memory_type :=(others => (others => '0'));   --memory for queue.
      signal readptr,writeptr : integer range 0 to 31 := 0;  --read and write pointers.

begin

    process (Clock)
        file logfile: text;
   variable linept:line;
    variable logct: std_logic_vector(49 downto 0);
      variable logsr: string(9 downto 1);

    variable req_index: integer;
    variable req_cmd: integer;
    variable cache_bits: std_logic_vector(2 downto 0);
    variable tmplog: std_logic_vector(51 downto 0);
    variable enr: boolean:=false;
    variable enw: boolean:=true;
    variable nilmem: std_logic_vector(40 downto 0):=(others=>'0');
    variable nilbit: std_logic_vector(0 downto 0):=(others=>'0');
    variable memcont:std_logic_vector(31 downto 0);
    variable nilreq:std_logic_vector(49 downto 0):=(others => '0');
  	begin   
	    if rising_edge(Clock) then   
	    --deal with  request first
	    --is it how i should compare?
	    --00+request
                                                             
           if req /= nilreq then
                if enw=true then
                    memory(writeptr) <= "00"&req;
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
                    res<="11"&req(47 downto 0);
                end if;
                --if it's not there
                
            end if;--end if req/=xx
            
            --recieving response from bus
            if bus_res/=nilreq then
                    if enw=true then
                           memory(writeptr) <= "01"&bus_res;
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
                          res<="11"&bus_res(47 downto 0);
                    end if;
            end if;--end if bus_res/= 
            
            if snoop_req/=nilreq then
                    if enw=true then
                           memory(writeptr) <= "11"&snoop_req;
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
                          res<="11"&snoop_req(47 downto 0);
                    end if;
            end if;--end if snoop_req/= 
       -----done with add to fifo 
       -----start read one from fifo
       if (enr=true) then
            tmplog:= memory(readptr);
            readptr <= readptr + 1;  
            if(readptr = 31) then      --resetting read pointer.
                readptr <= 0;
            end if;
            if(writeptr=readptr) then
                enr:=false;
            end if;
            req_index:= to_integer(unsigned(tmplog(41 downto 32)));
            req_cmd:= to_integer(unsigned(tmplog(49 downto 48)));
            
            --request from cpu
            if tmplog(51 downto 50)="00" then
                if ROM_array(req_index)= nilmem then
                    --send request to bus
                    bus_req<=tmplog(49 downto 0);
                     logct:=tmplog(49 downto 0);
                                                    file_open(logfile,"C:\Users\cao2\Documents\log.txt",append_mode);
                                                    logsr:="2c_b_req,";
                                                    write(linept,logsr);
                                                    write(linept,logct);
                                                    writeline(logfile,linept);
                                                    file_close(logfile);                
                --if not valid
                elsif ROM_array(req_index)(40) ='0' then
                    --send request to bus
                    bus_req<=tmplog(49 downto 0);
                    logct:=tmplog(49 downto 0);
                                                                        file_open(logfile,"C:\Users\cao2\Documents\log.txt",append_mode);
                                                                        logsr:="2c_b_req,";
                                                                        write(linept,logsr);
                                                                        write(linept,logct);
                                                                        writeline(logfile,linept);
                                                                        file_close(logfile);                          
                --if tag doesn't match
                --****is this how i should compare????????
                elsif  ROM_array(req_index)(37 downto 32)/=tmplog(47 downto 42)then
                    bus_req<=tmplog(49 downto 0);
                     logct:=tmplog(49 downto 0);
                                                                        file_open(logfile,"C:\Users\cao2\Documents\log.txt",append_mode);
                                                                        logsr:="2c_b_req,";
                                                                        write(linept,logsr);
                                                                        write(linept,logct);
                                                                        writeline(logfile,linept);
                                                                        file_close(logfile);                        
                --if valid, but shared
                elsif unsigned(ROM_array(req_index)(38 downto 38))=0 then
                    --send request to bus
                     bus_req<=tmplog(49 downto 0);
                     logct:=tmplog(49 downto 0);
                                                                         file_open(logfile,"C:\Users\cao2\Documents\log.txt",append_mode);
                                                                         logsr:="2c_b_req,";
                                                                         write(linept,logsr);
                                                                         write(linept,logct);
                                                                         writeline(logfile,linept);
                                                                         file_close(logfile);         
                else  
                    --if read from cpu
                    if req_cmd=0 then
                        res<="00"&tmplog(47 downto 32)&(ROM_array(req_index)(31 downto 0));
                        logct:="00"&tmplog(47 downto 32)&(ROM_array(req_index)(31 downto 0));
                                                                            file_open(logfile,"C:\Users\cao2\Documents\log.txt",append_mode);
                                                                            logsr:="2c_p_res,";
                                                                            write(linept,logsr);
                                                                            write(linept,logct);
                                                                            writeline(logfile,linept);
                                                                            file_close(logfile);         
                        --if write from cpu
                    elsif req_cmd=1 then
                        res<=(49=>'0', 48=>'1',others=>'0');
                        ROM_array(req_index)<="111"&tmplog(47 downto 42)&tmplog(31 downto 0);
                        logct:=(49=>'0', 48=>'1',others=>'0');
                                                                                                    file_open(logfile,"C:\Users\cao2\Documents\log.txt",append_mode);
                                                                                                    logsr:="2c_p_res,";
                                                                                                    write(linept,logsr);
                                                                                                    write(linept,logct);
                                                                                                    writeline(logfile,linept);
                                                                                                    file_close(logfile);      
                    end if; --end of returning data to cpu or bus
                end if;--end of finding data in array    
            
            --snoop request from bus
            elsif tmplog(51 downto 50)="11" then
                --if can't find in cache memory, return can't find
                if ROM_array(req_index)=nilmem
                or ROM_array(req_index)(40)='0'
                or ROM_array(req_index)(37 downto 32)/=tmplog(47 downto 42) then
                      snoop_hit<=false;
                --if cache hit, return the data to bus
                else
                      snoop_hit<=true;
                      snoop_res<=tmplog(49 downto 32)&ROM_array(req_index)(31 downto 0);
                      ROM_array(req_index)(40)<='0';
                end if;
            --response from bus
            elsif tmplog(51 downto 50)="01" then
                --if it's read request fifo full 
                if req_cmd=2 then
                    bus_req<="00"&tmplog(47 downto 0);
                    logct:="00"&tmplog(47 downto 0);
                                                                                            file_open(logfile,"C:\Users\cao2\Documents\log.txt",append_mode);
                                                                                            logsr:="2c_b_req,";
                                                                                            write(linept,logsr);
                                                                                            write(linept,logct);
                                                                                            writeline(logfile,linept);
                                                                                            file_close(logfile); 
                elsif req_cmd=3 then
                    bus_req<="01"&tmplog(48 downto 0);
                    logct:="01"&tmplog(48 downto 0);
                                                                                                                file_open(logfile,"C:\Users\cao2\Documents\log.txt",append_mode);
                                                                                                                logsr:="2c_b_req,";
                                                                                                                write(linept,logsr);
                                                                                                                write(linept,logct);
                                                                                                                writeline(logfile,linept);
                                                                                                                file_close(logfile); 
                else
                    if req_cmd=0 then
                        cache_bits:="100";
                        --send read response to cpu
                        res<="00"&tmplog(47 downto 0);
                        logct:="00"&tmplog(47 downto 0);
                                                                                                                                        file_open(logfile,"C:\Users\cao2\Documents\log.txt",append_mode);
                                                                                                                                        logsr:="2c_p_res,";
                                                                                                                                        write(linept,logsr);
                                                                                                                                        write(linept,logct);
                                                                                                                                        writeline(logfile,linept);
                                                                                                                                        file_close(logfile); 
                    elsif req_cmd=1 then
                        cache_bits:="111";
                        --send write response to cpu
                        res<="01"&tmplog(48 downto 0);
                        logct:="01"&tmplog(48 downto 0);
                                                                                                                                        file_open(logfile,"C:\Users\cao2\Documents\log.txt",append_mode);
                                                                                                                                        logsr:="2c_p_res,";
                                                                                                                                        write(linept,logsr);
                                                                                                                                        write(linept,logct);
                                                                                                                                        writeline(logfile,linept);
                                                                                                                                        file_close(logfile); 
                    end if;
                    ----put data in cache memory 
                ---assum when get data for reading purpose, it's always shared cauz now we have no way of knowing
                    if ROM_array(req_index)=nilmem then
                        ROM_array(req_index)<=cache_bits&tmplog(47 downto 42)&tmplog(31 downto 0);
                --if not valid
                    elsif ROM_array(req_index)(40 downto 40)="0" then
                        --send request to bus
                        ROM_array(req_index)<=cache_bits&tmplog(47 downto 42)&tmplog(31 downto 0);
                   --if tag doesn't match
                    --****is this how i should compare????????
                    elsif  ROM_array(req_index)(37 downto 32)/=tmplog(47 downto 42)then
                        ---issue an write bace
                        bus_req<="11"&tmplog(41 downto 32)&ROM_array(req_index)(37 downto 32)&tmplog(31 downto 0);  
                          
                        ROM_array(req_index)<=cache_bits&tmplog(47 downto 42)&tmplog(31 downto 0);
                        logct:="11"&tmplog(41 downto 32)&ROM_array(req_index)(37 downto 32)&tmplog(31 downto 0);
                                                                                                                                                                file_open(logfile,"C:\Users\cao2\Documents\log.txt",append_mode);
                                                                                                                                                                logsr:="2c_b_req,";
                                                                                                                                                                write(linept,logsr);
                                                                                                                                                                write(linept,logct);
                                                                                                                                                                writeline(logfile,linept);
                                                                                                                                                                file_close(logfile); 
                    else
                        ROM_array(req_index)<=cache_bits&tmplog(47 downto 42)&tmplog(31 downto 0);
                    end if;--req_indx=0
                    
                end if;--if req_cmd=2
            end if;--end if ='01'
       end if;--enr=1     
       
       end if;   --end if clock rise
  end process;   

end Behavioral;
