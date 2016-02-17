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
    --input from cpu
           Clock: in std_logic;
           --00 read request --01 write request
           req : in STD_LOGIC_VECTOR(50 downto 0);
    --input from bus about snoop request
            --00 read request snoop  --01 write snoop request--if found, invalidate
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
           full_crq: out std_logic:='0';
           full_srq: out std_logic:='0';
           full_brs: out std_logic:='0';
           full_crq,full_wb,full_srs: in std_logic;
           bus_req : out STD_LOGIC_VECTOR(50 downto 0):= (others => '0')
           );
           
           
end L1Cache;

architecture Behavioral of L1Cache is
--IMB cache 1
--3 lsb: dirty bit, valid bit, exclusive bit
--cache hold valid bit ,dirty bit, exclusive bit, 6 bits tag, 32 bits data, 41 bits in total



<<<<<<< HEAD
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
=======
    type rom_type is array (2**10-1 downto 0) of std_logic_vector (40 downto 0);     
    signal ROM_array : rom_type:= ((others=> (others=>'0')));
>>>>>>> 498f55418ad5b772594bf29f2038a4b26ec20098
       
	signal we1,we2,we3,re1,re2,re3: std_logic<='0';
	signal out1,out2,out3:std_logic_vector(49 downto 0);
	signal emp1,emp2,emp3,ful1,ful2,ful3: std_logic<='0';	
	signal mem_req1,mem_req2,upd_req,write_req: std_logic_vector(50 downto 0);
	signal mem_res1,mem_res2: std_logic_vector(49 downto 0);
	signal hit1,hit2,upd_ack,write_ack,mem_ack1,mem_ack2: std_logic;
	signal in1,in2,in3: std_logic_vector(49 downto 0);
	signal cpu_res1, cpu_res2: std_logic_vector(50 downto 0);
	signal ack1, ack2: std_logic;
	variable wb_req, wb_res:integer:=1;
begin
	cpu_req: entity xil_defaultlib.STD_FIFO(Behavioral) port map(
		CLK=>Clock,
		RST=>'0',
		DataIn=>in1,
		WriteEn=>we1,
		ReadEn=>re1,
		DataOut=>out1,
		Full=>full_crq,
		Empty=>emp1
		);
	snp_req: entity xil_defaultlib.STD_FIFO(Behavioral) port map(
		CLK=>Clock,
		RST=>'0',
		DataIn=>in2,
		WriteEn=>we2,
		ReadEn=>re2,
		DataOut=>out2,
		Full=>full_srq,
		Empty=>emp2
		);
	bus_res: entity xil_defaultlib.STD_FIFO(Behavioral) port map(
		CLK=>Clock,
		RST=>'0',
		DataIn=>in3,
		WriteEn=>we3,
		ReadEn=>re3,
		DataOut=>out3,
		Full=>full_brs,
		Empty=>emp3
		);
	
	--read request into each fifo	
	cpu_req_fifo: process(Clock)
	begin
		if rising_edge(Clock) then
			if(cpu_req(50 downto 50)="1") then
				in1<=cpu_req(49 downto 0);
				we1<='1';
				wait for 1ns;
				we1<='0';
			end if;
		end if;
	end process;
	
	
	
	snp_req_fifo: process(Clock)
	begin
		if rising_edge(Clock) then
			if(snoop_req(50 downto 50)="1") then
				in2<=snoop_req(49 downto 0);
				we2<='1';
				wait for 1ns;
				we2<='0';
			end if;
		end if;
	end process;
	
	bus_res_fifo: process(Clock)
	begin
		if rising_edge(Clock) then
			if(bus_res(50 downto 50)="1") then
				in3<=bus_res(49 downto 0);
				we3<='1';
				wait for 1ns;
				we3<='0';
			end if;
		end if;
	end process;
	
	--deal with cpu request
	cpu_req_p:process(Clock)
	variable req:std_logic_vector(49 downto 0);
	variable nilreq:std_logic_vector(50 downto 0):=(others => '0');
	
	begin
		if rising_edge(Clock) then
			cache_req<=nilreq;
			if emp1='0' then
				re1<='1';
				req:=out1;
				--first check if the requested data is in cache
				mem_req1<='1'&req;
				while mem_ack1='0' loop
				end loop;
				mem_req1<=nilreq;
				--if cache have it, make the return
				if hit1='1' then
					if req(49 downto 48)="10" then--it's write
						write_req<='1'&req;
						while write_ack='0' loop
						end loop;
						write_req<=nilreq;
					end if;
					cpu_res1<='1'&&mem_res1(49 downto 0);
					while ack1='0' loop
					end loop;
					--after acknowlegement, reset it to empty request
					cpu_res1<=nilreq;
				else
					--when cache request fifo is full, keep waiting
					--what other option can i do
					while full_crq='1' loop
					end loop;
					cache_req<='1'&req;
				end if;
			end if;
		end if;
	end process;
	
	--deal withe snoop request
	snp_req_p:process(Clock)
	variable req:std_logic_vector(49 downto 0);
	variable nilreq:std_logic_vector(50 downto 0):=(others => '0');
	begin
		if rising_edge(Clock) then
			--first reset the output
			snoop_res<=nilreq;
			snoop_hit<='0';
			if emp2='0' then
				re2<='1';
				req:=out2;
				mem_req2<='1'&req;
				while mem_ack2='0' loop
				end loop;
				mem_req2<=nilreq;
				if hit2='1' then
					--while until fifo not full
					while full_src='1' loop
					end loop;
					snoop_res<='1'&mem_res2(49 downto 0);
					snoop_hit<='1';
				else
					while full_src='1' loop
					end loop;
					snoop_hit<='0';
					snoop_res<='1'&nilreq(49 downto 0);
				end if;
				
			end if;
		end if;
	end process;
	
	--deal with bus response
	bus_res_p:process(Clock)
	variable res:std_logic_vector(49 downto 0);
	variable nilreq:std_logic_vector(50 downto 0):=(others => '0');
	begin
		if rising_edge(Clock) then
			cpu_res<=nilreq;
			if emp3='0' then
				re3<='1';
				res:=out3;
				upd_req<='1'&res;
				while upd_ack='0' loop
				end loop;
				upd_req<=nilreq;
				cpu_res<='1'&res;
			end if;
		end if;
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
		upd_ack,write_ack,mem_ack1,mem_ack2<='0';
			if mem_req1(50 downto 50)="1" then
				indx:=to_integer(unsigned(mem_req1(41 downto 32)));
				memcont:=ROM_array(indx);
				--if we can't find it in memory
				if memcont=nilmem or memcont(40 downto 40)='0' or memcont(38 downto 38)='0'
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
				if memcont=nilmem or memcont(40 downto 40)='0' or memcont(38 downto 38)='0'
					or memcont(37 downto 32)/=mem_req2(47 downto 42) then
					mem_ack2<='1';
					hit2<='0';
				else
					mem_ack2<='1';
					hit2<='1';
					mem_res<2=mem_req2(49 downto 32)&memcont(31 downto 0);
				end if;
			end if;
			
			--first deal with write request from cpu_request
			--the write is only sent here if the data exist in cahce memory
			
				if write_req(50 downto 50)="1" and npd_req(50 downto 50)="0" then
					indx:=to_integer(unsigned(write_req(41 downto 32)));
					ROM_array(indx):="100"&write_req(47 downto 42)&write_req(31 downto 0);
					write_ack<='1';	
						
				elsif upd_req(50 downto 50)="1" and write_req(50 downto 50)="1" then
					indx:=to_integer(unsigned(upd_req(41 downto 32)));
					memcont:=ROM_array(indx);
					--if updating data already exist, no need to write back
					if memcont(37 downto 32)=upd_req(47 downto 42) then
						ROM_array(indx):="100"&upd_req(47 downto 42)&upd_req(31 downto 0);
						upd_ack<='1';
					else --the position have a different data
						if memcont(39 downto 39)="1" then -- if it's dirty
							while full_wb='1' loop
							end loop;
							wb_req<="111"&memcont(37 downto 32)&upd_req(41 downto 31)&memcont(31 downto 0);
						end if;
						ROM_array(indx):="100"&upd_req(47 downto 42)&upd_req(31 downto 0);
					end if;
				else
					if shifter=true then
						shifter:=false;
						indx:=to_integer(unsigned(write_req(41 downto 32)));
						ROM_array(indx):="100"&write_req(47 downto 42)&write_req(31 downto 0);
						write_ack<='1';	
					else
						shifter:=true;
						indx:=to_integer(unsigned(upd_req(41 downto 32)));
						memcont:=ROM_array(indx);
						--if updating data already exist, no need to write back
						if memcont(37 downto 32)=upd_req(47 downto 42) then
							ROM_array(indx):="100"&upd_req(47 downto 42)&upd_req(31 downto 0);
							upd_ack<='1';
						else --the position have a different data
							if memcont(39 downto 39)="1" then -- if it's dirty
								while full_wb='1' loop
								end loop;
								wb_req<="111"&memcont(37 downto 32)&upd_req(41 downto 31)&memcont(31 downto 0);
							end if;
							ROM_array(indx):="100"&upd_req(47 downto 42)&upd_req(31 downto 0);
						end if;
						
					end if;
					
				end if;
			
		
			
		end if;
	end process;
	
	
		
     

end Behavioral;
