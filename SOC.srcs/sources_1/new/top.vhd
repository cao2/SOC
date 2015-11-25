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
use xil_defaultlib.all;
use std.textio.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity top is
    
end top;

architecture Behavioral of top is

    -- Procedure for clock generation
  procedure clk_gen(signal clk : out std_logic; constant FREQ : real) is
    constant PERIOD    : time := 1 sec / FREQ;        -- Full period
    constant HIGH_TIME : time := PERIOD / 2;          -- High time
    constant LOW_TIME  : time := PERIOD - HIGH_TIME;  -- Low time; always >= HIGH_TIME
  begin
    -- Check the arguments
    assert (HIGH_TIME /= 0 fs) report "clk_plain: High time is zero; time resolution to large for frequency" severity FAILURE;
    -- Generate a clock cycle
    loop
      clk <= '1';
      wait for HIGH_TIME;
      clk <= '0';
      wait for LOW_TIME;
    end loop;
  end procedure;

  -- Clock frequency and signal
   signal Clock : std_logic;
   signal bus_res1, bus_res2,cpu_res1, cpu_res2, cpu_req1, cpu_req2,snoop_req1,snoop_req2: std_logic_vector (49 downto 0);
   signal snoop_hit1, snoop_hit2: boolean;
   signal snoop_res1, snoop_res2, bus_req1, bus_req2: std_logic_vector(49 downto 0);
   signal  memres, tomem : std_logic_vector(50 downto 0);
begin
    clk_gen(Clock, 166.667E6); 
    cpu1: entity xil_defaultlib.CPU(Behavioral) port map(
       Clock=>Clock,
       seed=>5,
       cpu_res=>cpu_res1,
       cpu_req=>cpu_req1
   );
   
   cpu2: entity xil_defaultlib.CPU2(Behavioral) port map(
          Clock=>Clock,
          seed=>5,
          cpu_res=>cpu_res2,
          cpu_req=>cpu_req2
      );
    cache1: entity xil_defaultlib.L1Cache(Behavioral) port map(
         Clock=>Clock,
         req=>cpu_req1,
         snoop_req=>snoop_req1,
         bus_res=>bus_res1,
         res=>cpu_res1,
         snoop_hit=>snoop_hit1,
         snoop_res=>snoop_res1,
         bus_req=>bus_req1
    );
     cache2: entity xil_defaultlib.L1Cache2(Behavioral) port map(
            Clock=>Clock,
            req=>cpu_req2,
            snoop_req=>snoop_req2,
            bus_res=>bus_res2,
            res=>cpu_res2,
            snoop_hit=>snoop_hit2,
            snoop_res=>snoop_res2,
            bus_req=>bus_req2
       );
    interconnect: entity xil_defaultlib.AXI(Behavioral) port map(
        Clock=>Clock,
        cache_req1=>bus_req1,
        cache_req2=>bus_req2,
        cache_hit1=>snoop_hit1,
        cache_hit2=>snoop_hit2,
        snoop_res1=>snoop_res1,
        snoop_res2=>snoop_res2,
        memres=>memres,
        res1=>bus_res1,
        res2=>bus_res2,
        tomem=>tomem,
        snoop1=>snoop_req1,
        snoop2=>snoop_req2
    );
    mem: entity xil_defaultlib.Memory(Behavioral) port map(   
        Clock=>Clock,
        req=>tomem,
        res=>memres
    );
end Behavioral;
