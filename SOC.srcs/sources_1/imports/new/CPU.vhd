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
           seed: in integer;
           cpu_res: in std_logic_vector(49 downto 0):= (others => '0');
           cpu_req : out std_logic_vector(49 downto 0)
           );
end CPU;



architecture Behavioral of CPU is
 signal yuting:boolean:=true;
begin
-- processor random generate read or write request
 p1 : process (Clock)
     file logfile: text;
    variable linept:line;
     variable logct: std_logic_vector(49 downto 0);
       variable logsr: string(8 downto 1);
 
     variable readsucc: integer :=0;
     variable writesucc: integer :=0;
     variable cmd: integer:=2;
     variable empcot: std_logic_vector(31 downto 0):=(others=>'0');
     variable nilreq: std_logic_vector(49 downto 0):=(others=>'0');
     --if rand1 is 1 then read request
     --if rand1 is 2 then write request
     variable rand1:integer:=selection(2);
     --generate the random address
     variable rand2: std_logic_vector(15 downto 0):=selection(2**15-1,16);
     --generate the random content
     variable rand3: std_logic_vector(31 downto 0):=selection(2**15-1,32);

     begin
     if (rising_edge(Clock) and yuting=true) then
        yuting<=false;
          if (rand1 = 1) then
            cpu_req<="00"&rand2&empcot;
            logct:="00"&rand2&empcot;
                                 file_open(logfile,"C:\Users\cao2\Documents\log.txt",append_mode);
                                 logsr:="cpu_req,";
                                 write(linept,logsr);
                                 write(linept,logct);
                                 writeline(logfile,linept);
                                 file_close(logfile);
          elsif (rand1 =2) then
            cpu_req<="01"&rand2&rand3;
            logct:="01"&rand2&rand3;
                                             file_open(logfile,"C:\Users\cao2\Documents\log.txt",append_mode);
                                             logsr:="cpu_req,";
                                             write(linept,logsr);
                                             write(linept,logct);
                                             writeline(logfile,linept);
                                             file_close(logfile);
          end if;
          
          if cpu_res/=nilreq then
            cmd:=to_integer(unsigned(cpu_res(49 downto 48)));
            if(cmd=0) then
                readsucc:=readsucc+1;
            elsif cmd=1 then
                writesucc:=writesucc+1;
            elsif cmd=3 then
                --this is when full
                cpu_req<="0"&cpu_res(48 downto 0);
                logct:="0"&cpu_res(48 downto 0);
                                                             file_open(logfile,"C:\Users\cao2\Documents\log.txt",append_mode);
                                                             logsr:="cpu_req,";
                                                             write(linept,logsr);
                                                             write(linept,logct);
                                                             writeline(logfile,linept);
                                                             file_close(logfile);
            end if;
          end if;
          
         
   end if;
  end process; 
 

end Behavioral;
