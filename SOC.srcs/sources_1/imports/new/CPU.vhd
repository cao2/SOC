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
     variable readsucc: integer :=0;
     variable writesucc: integer :=0;
     variable cmd: integer:=2;
     variable nilreq: std_logic_vector(50 downto 0):=(others=>'0');
     
     --if rand1 is 1 then read request
     --if rand1 is 2 then write request
     variable rand1:integer:=selection(2);
     --generate the random address & cnontent
     variable rand2: std_logic_vector(15 downto 0):=selection(2**15-1,16);
     variable rand3: std_logic_vector(31 downto 0):=selection(2**15-1,32);
    
    begin
     if (rising_edge(Clock)) then
     	cpu_req<=nilreq;
     	if (yuting=true and full_c='0') then
        	yuting<=false;
          	if (rand1 = 1) then
            	cpu_req<="101"&"0000000111111111"&"11110000001111111111111111111111";
          	elsif (rand1 =2) then
            	cpu_req<="110"&rand2&rand3;
          	end if;
      	--else if the cache buffer is full, don't send anything
       	end if;
       --if received any request from cache
       --if request valide bit is not 0
    	if cpu_res(50 downto 50)="1" then
            cmd:=to_integer(unsigned(cpu_res(49 downto 48)));
            if(cmd=0) then
                readsucc:=readsucc+1;
            elsif cmd=1 then
                writesucc:=writesucc+1;
            end if;
        end if;         
   end if;
  end process; 
 

end Behavioral;
