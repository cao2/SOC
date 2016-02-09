----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/25/2015 08:51:49 PM
-- Design Name: 
-- Module Name: SOC - Behavioral
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
USE ieee.numeric_std.ALL;
use xil_defaultlib.nondeterminism.all;
use std.textio.all;
use IEEE.std_logic_textio.all; 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;
-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity CPU is
    Port ( 
           Clock: in std_logic;
           cpu_res: in std_logic_vector(50 downto 0);
           cpu_req : out std_logic_vector(50 downto 0);
           full_c: in std_logic
           );
end CPU;



architecture Behavioral of CPU is
 signal yuting:boolean:=true;
 
begin
-- processor random generate read or write request
 p1 : process (Clock)
     file logfile: text;
    variable linept:line;
     variable logct: std_logic_vector(50 downto 0);
       variable logsr: string(8 downto 1);
 
     variable readsucc: integer :=0;
     variable writesucc: integer :=0;
     variable cmd: integer:=2;
     variable empcot: std_logic_vector(31 downto 0):=(others=>'0');
     variable nilreq: std_logic_vector(50 downto 0):=(others=>'0');
     --if rand1 is 1 then read request
     --if rand1 is 2 then write request
     variable rand1:integer:=selection(2);
     --generate the random address
     variable rand2: std_logic_vector(15 downto 0):=selection(2**15-1,16);
     --generate the random content
     variable rand3: std_logic_vector(31 downto 0):=selection(2**15-1,32);
    variable count: integer:=0;
     begin
     if (rising_edge(Clock)) then
     count:=count+1;
     cpu_req<=nilreq;
     if (yuting=true and full_c='0') then
        yuting<=false;
          if (rand1 = 1) then
            cpu_req<="100"&"0000000111111111"&"11110000001111111111111111111111";
            logct:="100"&"0000000111111111"&"11110000001111111111111111111111";
                                 file_open(logfile,"C:\Users\cao2\Documents\log.txt",append_mode);
                                 logsr:="cp1_req,";
                                 write(linept,logsr);
                                 write(linept,logct);
                                 writeline(logfile,linept);
                                 file_close(logfile);
          elsif (rand1 =2) then
            cpu_req<="101"&rand2&rand3;
            logct:="101"&rand2&rand3;
                                             file_open(logfile,"C:\Users\cao2\Documents\log.txt",append_mode);
                                             logsr:="cp1_req,";
                                             write(linept,logsr);
                                             write(linept,logct);
                                             writeline(logfile,linept);
                                             file_close(logfile);
          end if;
      --else if the cache buffer is full, don't send anything
      
       end if;
       
       --if received any request from cache
       --if request valide bit is not 0
          if cpu_res(50)/='0' then
            cmd:=to_integer(unsigned(cpu_res(49 downto 48)));
            if(cmd=0) then
                readsucc:=readsucc+1;
            elsif cmd=1 then
                writesucc:=writesucc+1;
--here i delete the cmd=3 for full situation of cache since cache has its own full_c signal, request wont even be sent there if it's set true
            end if;
          end if;
          
         
   end if;
  end process; 
 

end Behavioral;
