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

entity L1Cache is
    Port ( 
    --packet has 2 bits command , 16 bits address, 32 bits data content
    --input from cpu
           Clock: in std_logic;
           --00 read request
           --01 write request
           req : in STD_LOGIC_VECTOR(50 downto 0);
    --input from bus about snoop request
            --00 read request snoop
            --01 write snoop request--if found, invalidate
           snoop_req : in STD_LOGIC_VECTOR(50 downto 0);
    --input from bus about response
           --00 read response
           --01 write response
           --10,11 fifo full response
           bus_res  : in  STD_LOGIC_VECTOR(50 downto 0):= (others => '0');
           
    --output to cpu's request
    --oreq has the same type as of the req 
           --01: read response
           --10: write response
           --11: fifo full response
           res : out STD_LOGIC_VECTOR(50 downto 0):= (others => '0');
    --output to bus's snoop request
           --01: read response
           --10: write response
           --11: fifo full response
           snoop_hit : out boolean;
           snoop_res : out STD_LOGIC_VECTOR(50 downto 0):= (others => '0');
     --output to ask for bus
            --01: read request
            --10: write request
            --10,11: write back function
           full_c_u: out std_logic:='0';
           full_c_b: out std_logic:='0';
           full_b_c: in std_logic;
           bus_req : out STD_LOGIC_VECTOR(50 downto 0):= (others => '0')
           );
           
           
end L1Cache;

architecture Behavioral of L1Cache is
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
    variable logct: std_logic_vector(50 downto 0);
      variable logsr: string(8 downto 1);

    variable req_index: integer;
    variable req_cmd: integer;
    variable cache_bits: std_logic_vector(2 downto 0);
    variable tmplog: std_logic_vector(51 downto 0);
    variable enr: boolean:=false;
    variable enw: boolean:=true;
    variable nilmem: std_logic_vector(40 downto 0):=(others=>'0');
    variable nilbit: std_logic_vector(0 downto 0):=(others=>'0');
    variable memcont:std_logic_vector(31 downto 0);
    variable nilreq:std_logic_vector(50 downto 0):=(others => '0');
  	begin   
	    if rising_edge(Clock) then   
	               --set all output signal to its default value first, to flush out the old requst
                   res<=nilreq;
                   snoop_res<=nilreq;
                   bus_req<=nilreq;
                   snoop_hit<=false;
        --if valid bit of cpu request is not 0                                                     
           if req(50 downto 50)= "1" then
                if enw=true then
                    memory(writeptr) <= "10"&req(49 downto 0);
                    writeptr <= writeptr + 1;
                    enr:=true;
                    --writeptr loops
                    if(writeptr = 31) then       
                        writeptr <= 0;
                    end if;
                    --check if full
                    if(writeptr=readptr) then
                        enw:=false;
                        full_c_u<='1';
                        full_c_b<='1';
                    end if; 
                end if;
                --if it's not there
            end if;--end if req/=xx
            
            --recieving response from bus
            if bus_res(50 downto 50)="1" then
                    if enw=true then
                           memory(writeptr) <= "01"&bus_res(49 downto 0);
                           writeptr <= writeptr + 1;
                           enr:=true;
                           --writeptr loops
                           if(writeptr = 31) then       
                                  writeptr <= 0;
                           end if;
                           --check if full
                           if(writeptr=readptr) then
                                 enw:=false;
                                 full_c_u<='1';
                                                         full_c_b<='1';
                           end if; 
                         
                    end if;
            end if;--end if bus_res/= 
            
            if snoop_req(50 downto 50)= "1" then
                    if enw=true then
                           memory(writeptr) <= "11"&snoop_req(49 downto 0);
                           writeptr <= writeptr + 1;
                           enr:=true;
                           --writeptr loops
                           if(writeptr = 31) then       
                                  writeptr <= 0;
                           end if;
                           --check if full
                           if(writeptr=readptr) then
                                 enw:=false;
                                 full_c_u<='1';
                                                         full_c_b<='1';
                           end if; 
                          --send fifo full message
                   
                    end if;
            end if;--end if snoop_req/= 
       -----done with add to fifo 
       -----start read one from fifo
       if (enr=true)then
            tmplog:= memory(readptr);
            logct:=tmplog(51 downto 1);
                                                                            file_open(logfile,"C:\Users\cao2\Documents\log.txt",append_mode);
                                                                            logsr:="bbb_bbb,";
                                                                            write(linept,logsr);
                                                                            write(linept,logct);
                                                                            writeline(logfile,linept);
                                                                            file_close(logfile);   
            readptr <= readptr + 1;  
            if(readptr = 31) then      --resetting read pointer.
                readptr <= 0;
            end if;
            --set enw to true and notify others
            enw:=true;
            full_c_u<='0';
            full_c_b<='0';
            if(writeptr=readptr) then
                enr:=false;
            end if;
            req_index:= to_integer(unsigned(tmplog(41 downto 32)));
            req_cmd:= to_integer(unsigned(tmplog(49 downto 48)));
            --request from cpu
           if tmplog(51 downto 50)="10" then
            if full_b_c='0' then
                
                if ROM_array(req_index)= nilmem  then
                    --send request to bus
                    bus_req<='1'&tmplog(49 downto 0);
                    logct:='1'&tmplog(49 downto 0);
                                                    file_open(logfile,"C:\Users\cao2\Documents\log.txt",append_mode);
                                                    logsr:="1ca_req,";
                                                    write(linept,logsr);
                                                    write(linept,logct);
                                                    writeline(logfile,linept);
                                                    file_close(logfile);                
                --if not valid
                elsif ROM_array(req_index)(40) ='0' then
                    --send request to bus
                    bus_req<='1'&tmplog(49 downto 0);
                    logct:='1'&tmplog(49 downto 0);
                                                                        file_open(logfile,"C:\Users\cao2\Documents\log.txt",append_mode);
                                                                        logsr:="1cb_req,";
                                                                        write(linept,logsr);
                                                                        write(linept,logct);
                                                                        writeline(logfile,linept);
                                                                        file_close(logfile);                          
                --if tag doesn't match
                --****is this how i should compare????????
                elsif  ROM_array(req_index)(37 downto 32)/=tmplog(47 downto 42)  then
                    bus_req<='1'&tmplog(49 downto 0);
                     logct:='1'&tmplog(49 downto 0);
                                                                        file_open(logfile,"C:\Users\cao2\Documents\log.txt",append_mode);
                                                                        logsr:="1cb_req,";
                                                                        write(linept,logsr);
                                                                        write(linept,logct);
                                                                        writeline(logfile,linept);
                                                                        file_close(logfile);                        
                --if valid, but shared
                elsif unsigned(ROM_array(req_index)(38 downto 38))=0 then
                    --send request to bus
                     bus_req<='1'&tmplog(49 downto 0);
                     logct:='1'&tmplog(49 downto 0);
                                                                         file_open(logfile,"C:\Users\cao2\Documents\log.txt",append_mode);
                                                                         logsr:="1cb_req,";
                                                                         write(linept,logsr);
                                                                         write(linept,logct);
                                                                         writeline(logfile,linept);
                                                                         file_close(logfile);         
                else
                    --if read from cpu
                    if req_cmd=0 then
                        res<="100"&tmplog(47 downto 32)&(ROM_array(req_index)(31 downto 0));
                        logct:="100"&tmplog(47 downto 32)&(ROM_array(req_index)(31 downto 0));
                                                                            file_open(logfile,"C:\Users\cao2\Documents\log.txt",append_mode);
                                                                            logsr:="1cp_res,";
                                                                            write(linept,logsr);
                                                                            write(linept,logct);
                                                                            writeline(logfile,linept);
                                                                            file_close(logfile);         
                        --if write from cpu
                    elsif req_cmd=1 then
                        res<=(50=>'1',49=>'0', 48=>'1',others=>'0');
                        ROM_array(req_index)<="111"&tmplog(47 downto 42)&tmplog(31 downto 0);
                        logct:=(50=>'1',49=>'0', 48=>'1',others=>'0');
                                                                                                    file_open(logfile,"C:\Users\cao2\Documents\log.txt",append_mode);
                                                                                                    logsr:="1cp_res,";
                                                                                                    write(linept,logsr);
                                                                                                    write(linept,logct);
                                                                                                    writeline(logfile,linept);
                                                                                                    file_close(logfile);      
                    end if; --end of returning data to cpu or bus
                end if;--end of finding data in array 
              --else if full_b_c=1 
              else
                if ROM_array(req_index)= nilmem or ROM_array(req_index)(40) ='0' or ROM_array(req_index)(37 downto 32)/=tmplog(47 downto 42) or unsigned(ROM_array(req_index)(38 downto 38))=0 then
                    --put it back to buffer
                                               memory(writeptr) <= tmplog;
                                               writeptr <= writeptr + 1;
                                               enr:=true;
                                               --writeptr loops
                                               if(writeptr = 31) then       
                                                      writeptr <= 0;
                                               end if;
                                               --check if full
                                               if(writeptr=readptr) then
                                                     enw:=false;
                                                     full_c_u<='1';
                                                     full_c_b<='1';
                                               end if; 
                 else
                    --if read from cpu
                                     if req_cmd=0 then
                                         res<="100"&tmplog(47 downto 32)&(ROM_array(req_index)(31 downto 0));
                                         logct:="100"&tmplog(47 downto 32)&(ROM_array(req_index)(31 downto 0));
                                                                                             file_open(logfile,"C:\Users\cao2\Documents\log.txt",append_mode);
                                                                                             logsr:="1cp_res,";
                                                                                             write(linept,logsr);
                                                                                             write(linept,logct);
                                                                                             writeline(logfile,linept);
                                                                                             file_close(logfile);         
                                         --if write from cpu
                                     elsif req_cmd=1 then
                                         res<=(50=>'1',49=>'0', 48=>'1',others=>'0');
                                         ROM_array(req_index)<="111"&tmplog(47 downto 42)&tmplog(31 downto 0);
                                         logct:=(50=>'1',49=>'0', 48=>'1',others=>'0');
                                                                                                                     file_open(logfile,"C:\Users\cao2\Documents\log.txt",append_mode);
                                                                                                                     logsr:="1cp_res,";
                                                                                                                     write(linept,logsr);
                                                                                                                     write(linept,logct);
                                                                                                                     writeline(logfile,linept);
                                                                                                                     file_close(logfile);      
                                     end if; --end of returning data to cpu or bus
                  end if; --if full=0
                  end if;
            --snoop request from bus
            elsif tmplog(51 downto 50)="11" then
                --if can't find in cache memory, return can't find
                if ROM_array(req_index)=nilmem
                    or ROM_array(req_index)(40)='0'
                    or ROM_array(req_index)(37 downto 32)/=tmplog(47 downto 42) then
                      snoop_hit<=false;
                      snoop_res<='1'&tmplog(49 downto 0);
                --if cache hit, return the data to bus
                else
                    if full_b_c='0' then
                      snoop_hit<=true;
                      snoop_res<='1'&tmplog(49 downto 32)&ROM_array(req_index)(31 downto 0);
                      logct:='1'&tmplog(49 downto 32)&ROM_array(req_index)(31 downto 0);
                      file_open(logfile,"C:\Users\cao2\Documents\log.txt",append_mode);
                                                                                                                                           logsr:="1sp_res,";
                                                                                                                                           write(linept,logsr);
                                                                                                                                           write(linept,logct);
                                                                                                                                           writeline(logfile,linept);
                                                                                                                                           file_close(logfile); 
                      --invalidate the data so the other one have exlusive right
                      ROM_array(req_index)(40)<='0';
                    --rewrite the request back to buffer if bus buffer is full
                    else
                                                                   memory(writeptr) <= tmplog;
                                                                   writeptr <= writeptr + 1;
                                                                   enr:=true;
                                                                   --writeptr loops
                                                                   if(writeptr = 31) then       
                                                                          writeptr <= 0;
                                                                   end if;
                                                                   --check if full
                                                                   if(writeptr=readptr) then
                                                                         enw:=false;
                                                                         full_c_u<='1';
                                                                         full_c_b<='1';
                                                                   end if; 
                      end if;
                end if;
                
            --response from bus
            elsif tmplog(51 downto 50)="01" then
                
                    if req_cmd=0 then
                        cache_bits:="100";
                        --send read response to cpu
                        res<="100"&tmplog(47 downto 0);
                        logct:="100"&tmplog(47 downto 0);
                                                                                                                                        file_open(logfile,"C:\Users\cao2\Documents\log.txt",append_mode);
                                                                                                                                        logsr:="1cp_res,";
                                                                                                                                        write(linept,logsr);
                                                                                                                                        write(linept,logct);
                                                                                                                                        writeline(logfile,linept);
                                                                                                                                        file_close(logfile); 
                    elsif req_cmd=1 then
                        cache_bits:="111";
                        --send write response to cpu
                        res<="101"&tmplog(48 downto 0);
                        logct:="101"&tmplog(48 downto 0);
                                                                                                                                        file_open(logfile,"C:\Users\cao2\Documents\log.txt",append_mode);
                                                                                                                                        logsr:="1cp_res,";
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
                                                                                                                                                                logsr:="1cb_req,";
                                                                                                                                                                write(linept,logsr);
                                                                                                                                                                write(linept,logct);
                                                                                                                                                                writeline(logfile,linept);
                                                                                                                                                                file_close(logfile); 
                    else
                        ROM_array(req_index)<=cache_bits&tmplog(47 downto 42)&tmplog(31 downto 0);
                    end if;--req_indx=0
                    
            end if;--end if ='01'
       end if;--enr=1     
       
       end if;   --end if clock rise
  end process;   

end Behavioral;
