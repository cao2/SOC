----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/01/2015 11:10:38 PM
-- Design Name: 
-- Module Name: Memory - Behavioral
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

entity Memory is
    Port (  Clock: in std_logic;
            full_b_m: in std_logic;
            req : in STD_LOGIC_VECTOR(51 downto 0);
            res: out STD_LOGIC_VECTOR(51 downto 0);
            full_m: out std_logic:='0');
end Memory;

architecture Behavioral of Memory is
     type rom_type is array (2**16-1 downto 0) of std_logic_vector (31 downto 0);     
     signal ROM_array : rom_type:= ((others=> (others=>'0')));
     
     type memory_type is array (31 downto 0) of std_logic_vector(51 downto 0);
     signal memory : memory_type :=(others => (others => '0'));   --memory for queue.
    signal readptr,writeptr : integer range 0 to 31 := 0;  --read and write pointers.begin

begin
    
  process (Clock)
    file logfile: text;
    variable linept:line;
     variable logct: std_logic_vector(51 downto 0);
       variable logsr: string(8 downto 1);
       
       
    variable tmplog: std_logic_vector(51 downto 0);
    variable enr: boolean:=false;
    variable enw: boolean:=true; 
    variable address: integer;
    variable flag: boolean:=false;
    variable nada: std_logic_vector(51 downto 0) :=(others=>'0');
    variable bo :boolean;
    begin
    if (rising_edge(Clock)) then
    --first set everything to default
        res<=nada;
        if req(51 downto 51)= "1" then
            if enw=true then
                memory(writeptr) <= req;
                writeptr <= writeptr + 1;
                enr:=true;
                --writeptr loops
                if(writeptr = 31) then       
                     writeptr <= 0;
                end if;
                --check if full
                if(writeptr=readptr) then
                     enw:=false;
                     full_m<='1';
                end if; 
                --send fifo full message
            end if;
        end if;
       --flag as to delay for one cycle for each request
        if (enr=true and flag=false) then
                enw:=true;
                full_m<='0';
                tmplog:= memory(readptr);
                readptr <= readptr + 1;  
                if(readptr = 31) then      --resetting read pointer.
                     readptr <= 0;
                end if;
                if(writeptr=readptr) then
                     enr:=false;
                end if;
                
                address:=to_integer(unsigned(tmplog(47 downto 32)));
                --regular request
                if tmplog(49 downto 48)="00" or tmplog(49 downto 48)="01" then
                    if full_b_m='0' then 
                        res<='1'&tmplog(50 downto 32)&ROM_array(address);
                        logct:='1'&tmplog(50 downto 32)&ROM_array(address);
                        logsr:="mem_res,";
                        bo:=write51(logct,logsr);
                        flag:=true;
                     else
                        memory(writeptr) <= tmplog;
                        writeptr <= writeptr + 1;
                        enr:=true;
                        full_m<='0';
                        --writeptr loops
                         if(writeptr = 31) then       
                             writeptr <= 0;
                         end if;
                         --check if full
                         if(writeptr=readptr) then
                             enw:=false;
                             full_m<='1';
                         end if;
                         
                     end if;             
                --write back request 
                elsif tmplog(49 downto 48)="11" then  
                    ROM_array(address)<=tmplog(31 downto 0);
                end if;  
          --wait for one cycle not doing anything
          elsif enr=true and flag=true then
                flag:=false;
        end if;

         --find the corresponding data in memeory
         --return it to bus
         --need a first in first out queue too     
               
              
       end if;
    end process;

end Behavioral;
