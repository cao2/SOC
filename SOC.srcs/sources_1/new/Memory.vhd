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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Memory is
    Port (  Clock: in std_logic;
            req : in STD_LOGIC_VECTOR(49 downto 0):= (others => '0');
            res: out STD_LOGIC_VECTOR(49 downto 0));
end Memory;

architecture Behavioral of Memory is
     type rom_type is array (2**16-1 downto 0) of std_logic_vector (40 downto 0);     
     constant ROM_array : rom_type:= ((others=> (others=>'0')));
     
     type memory_type is array (31 downto 0) of std_logic_vector(49 downto 0);
     signal memory : memory_type :=(others => (others => '0'));   --memory for queue.
     signal readptr,writeptr : std_logic_vector(4 downto 0) :="00000";  --read and write pointers.

begin
    
  process (Clock)
    variable tmplog: std_logic_vector(51 downto 0);
    variable enr: boolean:=0;
    variable enw: boolean:=1; 
    variable address: integer;
    variable flag: boolean:=0;
    begin
    if (rising_edge(Clock)) then
        if req/=(others => '0') then
            if enw=1 then
                memory(conv_integer(writeptr)) <= req;
                writeptr <= writeptr + '1';
                enr<=1;
                --writeptr loops
                if(writeptr = "11111") then       
                     writeptr <= "00000";
                end if;
                --check if full
                if(writeptf=readptr) then
                     enw<=0;
                end if; 
                --send fifo full message
              elsif enw=0 then
                     res<="11"&req(47 downto 0);
              end if;
        end if;
       
        if (enr=1 and flag=0) then
                tmplog<= memory(conv_integer(readptr));
                readptr <= readptr + '1';  
                if(readptr = "11111") then      --resetting read pointer.
                     readptr <= "00000";
                end if;
                if(writeptf=readptr) then
                     enr<=0;
                end if;
                
                address:=to_int(unsigned(tmplog(47 downto 32)));
                --regular request
                if tmplog(49 downto 48)="00" or tmplog(49 downto 48)="01" then 
                    req<=tmplog(49 downto 32)&ROM_array(address);
                    flag:=1;
                --write back request 
                elsif tmplog(49 downto 48)="11" then  
                    ROM_array(address):=tmplog(31 downto 0);
                end if;  
          --wait for one cycle not doing anything
          elsif flag=1 then
                flag:=0;
        end if;

         --find the corresponding data in memeory
         --return it to bus
         --need a first in first out queue too     
               
              
       end if;
    end process;

end Behavioral;
