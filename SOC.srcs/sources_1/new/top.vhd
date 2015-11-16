----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/15/2015 07:57:21 PM
-- Design Name: 
-- Module Name: top - Behavioral
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
use iEEE.std_logic_unsigned.all ;
USE ieee.numeric_std.ALL;
use xil_defaultlib.CPU;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity top is
    Port ( 
          Clock: in std_logic
    );
end top;

architecture Behavioral of top is
   signal bus_res1, bus_res2,cpu_res1, cpu_res2, cpu_req1, cpu_req2,snoop_req1,snoop_req2: std_logic_vector (51 downto 0);
   signal snoop_hit1, snoop_hit2: boolean;
   signal snoop_res1, snoop_res1, bus_req1, bus_req2, memres, tomem: std_logic_vector(49 downto 0);
begin
    cpu1: CPU port map(
       Clock=>Clock,
       seed=>5,
       cpu_res=>cpu_res1,
       cpu_req=>cpu_req1
   );
    cache1: L1Cache port map(
         Clock=>Clock,
         req=>cpu_req1,
         snoop_req=>snoop_req1,
         bus_res=>bus_res1,
         res=>cpu_res1,
         snoop_hit=>snoop_hit1,
         snoop_res=>snoop_res1,
         bus_req=>bus_req1
    );
    interconnect: AXI port map(
        Clock=>Clock,
        cache_req1=>bus_req1,
        snoop_hit1=>snoop_hit1,
        snoop_res1=>snoop_res1,
        memeres=>memres,
        res1=>bus_res1,
        tomem=>tomem,
        snoop1=>snoop_req1
    );
    mem: Memory port map(   
        Clock=>Clock,
        req=>tomem,
        res=>memres
    );
end Behavioral;
