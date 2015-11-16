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
            memres: in STD_LOGIC_VECTOR(49 downto 0);
            
            
            res1: out STD_LOGIC_VECTOR(49 downto 0);    
            res2: out STD_LOGIC_VECTOR(49 downto 0);
            tomem: out STD_LOGIC_VECTOR(49 downto 0);
            snoop1: out STD_LOGIC_VECTOR(49 downto 0);
            snoop2: out STD_LOGIC_VECTOR(49 downto 0)
                 
     );
end AXI;

architecture Behavioral of AXI is
    type memory_type is array (31 downto 0) of std_logic_vector(51 downto 0);
    signal memory : memory_type :=(others => (others => '0'));   --memory for queue.
    signal readptr,writeptr : std_logic_vector(4 downto 0) :="00000";  --read and write pointers.
begin
    
  process (Clock)
    variable tmplog: std_logic_vector(51 downto 0);
    variable enr: boolean:=false;
    variable enw: boolean:=true; 
    variable address: integer;
    variable flag: boolean:=false;
    variable nada: std_logic_vector(49 downto 0):=(others=>'0');
    begin
    if (rising_edge(Clock)) then
        if cache_req1/=nada then
          if enw=true then
            memory(conv_integer(writeptr)) <= "00"&cache_req1;
            writeptr <= writeptr + '1';
            enr:=true;
            --writeptr loops
            if(writeptr = "11111") then       
                writeptr <= "00000";
            end if;
            --check if full
            if(writeptr=readptr) then
                enw:=false;
            end if; 
        --send fifo full message
         elsif enw=false then
            res<="11"&cache_req1(47 downto 0);
         end if;--if enw=true;
        end if;--if req1='00000'
        
        if memres/=nada then
                  if enw=true then
                    memory(conv_integer(writeptr)) <= "01"&memres;
                    writeptr <= writeptr + '1';
                    enr:=true;
                    --writeptr loops
                    if(writeptr = "11111") then       
                        writeptr <= "00000";
                    end if;
                    --check if full
                    if(writeptr=readptr) then
                        enw:=false;
                    end if; 
                --send fifo full message
                 elsif enw=false then
                    res<="11"&memres(47 downto 0);
                 end if;--if enw=true;
                end if;--if req1='00000'
        if (enr=true) then
            tmplog:= memory(conv_integer(readptr));
            readptr := readptr + '1';  
            if(readptr = "11111") then      --resetting read pointer.
                readptr <= "00000";
            end if;
            if(writeptr=readptr) then
                enr:=false;
            end if;
            --this is assuming with just 1 cpu
            if tmplog(51 downto 50)="00" then
            end if;
            tomem<=tmplog(49 downto 0);
        end if; --if enr=1
      end if;--rising clck
    
  end process;
end Behavioral;
