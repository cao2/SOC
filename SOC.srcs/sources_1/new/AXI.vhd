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
    variable enr: boolean:=0;
    variable enw: boolean:=1; 
    variable address: integer;
    variable flag: boolean:=0;
    begin
    if (rising_edge(Clock)) then
        if cache_req1/=(others => '0') then
          if enw=1 then
            memory(conv_integer(writeptr)) <= "00"&cache_req1;
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
            res<="11"&cache_req1(47 downto 0);
         end if;--if enw=1;
        end if;--if req1='00000'
        
        
        if memres/=(others => '0') then
                  if enw=1 then
                    memory(conv_integer(writeptr)) <= "01"&memres;
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
                    res<="11"&memres(47 downto 0);
                 end if;--if enw=1;
                end if;--if req1='00000'
        if (enr=1) then
            tmplog<= memory(conv_integer(readptr));
            readptr <= readptr + '1';  
            if(readptr = "11111") then      --resetting read pointer.
                readptr <= "00000";
            end if;
            if(writeptf=readptr) then
                enr<=0;
            end if;
            --this is assuming with just 1 cpu
            tomem<=tmplog(49 downto 0);
        end if; --if enr=1
      end if;--rising clck
    
  end process;
end Behavioral;
