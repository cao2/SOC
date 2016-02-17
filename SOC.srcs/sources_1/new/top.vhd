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
  

  -- Clock frequency and signal
   signal Clock : std_logic;
   signal full_c1_u, full_c2_u, full_b_c1, full_b_c2, full_c1_b, full_c2_b, full_b_m, full_m:std_logic;
   signal bus_res1, bus_res2,cpu_res1, cpu_res2, cpu_req1, cpu_req2,snoop_req1,snoop_req2: std_logic_vector (50 downto 0);
   signal snoop_hit1, snoop_hit2: boolean;
   signal snoop_res1, snoop_res2, bus_req1, bus_req2: std_logic_vector(50 downto 0);
   signal  memres, tomem : std_logic_vector(51 downto 0);
   signal full_crq1, full_srq1, full_brs1,full_wb1,full_srs1,full_crq2, full_srq2, full_brs2,full_wb2,full_srs2:std_logic;
begin
    clk_gen : process
    	file logfile: text;
        variable linept:line;
        variable logct: std_logic_vector(50 downto 0);
        variable logct1: std_logic_vector(51 downto 0);
        variable logsr: string(8 downto 1);
    begin
    -- Generate a clock cycle
    file_open(logfile,"C:\Users\cao2\Documents\log.txt",append_mode);
    
    loop
      Clock <= '1';
      
      
      wait for 1 ns;
      --print out the signal
      if cup_req1(50 downto 50)="1" then
      	logct:=cpu_req1;
      	logsr:="cpureq1,";
      	write(linept,logsr);
      	write(linept,logct);    
      	writeline(logfile,linept);
      end if;
      
      if cup_req2(50 downto 50)="1" then
      	logct:=cpu_req2;
      	logsr:="cpureq2,";
      	write(linept,logsr);
      	write(linept,logct);    
      	writeline(logfile,linept);
      end if;
      
      if bus_req1(50 downto 50)="1" then
      	logct:=bus_req1;
      	logsr:="busreq1,";
      	write(linept,logsr);
      	write(linept,logct);    
      	writeline(logfile,linept);
      end if;
      if bus_req2(50 downto 50)="1" then
      	logct:=bus_req2;
      	logsr:="busreq2,";
      	write(linept,logsr);
      	write(linept,logct);    
      	writeline(logfile,linept);
      end if;
      
      Clock <= '0';
      wait for 1 ns;
    end loop;
    file_close(logfile);
  end process;
  
  
    cpu1: entity xil_defaultlib.CPU(Behavioral) port map(
       Clock=>Clock,
       seed=>5,
       cpu_res=>cpu_res1,
       cpu_req=>cpu_req1,
       full_c=>full_c1_u
   );
   
   cpu2: entity xil_defaultlib.CPU2(Behavioral) port map(
          Clock=>Clock,
          seed=>5,
          cpu_res=>cpu_res2,
          cpu_req=>cpu_req2,
          full_c=>full_c2_u
      );
    cache1: entity xil_defaultlib.L1Cache(Behavioral) port map(
         Clock=>Clock,
         req=>cpu_req1,
         snoop_req=>snoop_req1,
         bus_res=>bus_res1,
         res=>cpu_res1,
         snoop_hit=>snoop_hit1,
         snoop_res=>snoop_res1,
         cache_req=>bus_req1,
         full_srq=>full_srq1,
         full_brs=>full_brs1,
         full_crq=>full_crq1,
         full_wb=>full_wb1,
         full_srs=>full_srs1
          
    );
     cache2: entity xil_defaultlib.L1Cache2(Behavioral) port map(
            Clock=>Clock,
            req=>cpu_req2,
            snoop_req=>snoop_req2,
            bus_res=>bus_res2,
            res=>cpu_res2,
            snoop_hit=>snoop_hit2,
            snoop_res=>snoop_res2,
            cache_req=>bus_req2,
            full_srq=>full_srq2,
         	full_brs=>full_brs2,
         	full_crq=>full_crq2,
         	full_wb=>full_wb2,
         	full_srs=>full_srs2
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
        snoop2=>snoop_req2,
        full_c1_b=>full_c1_b,
        full_c2_b=>full_c2_b,
        full_b_c1=>full_b_c1,
        full_b_c2=>full_b_c2,
        full_b_m=>full_b_m,
        full_m=>full_m
    );
    mem: entity xil_defaultlib.Memory(Behavioral) port map(   
        Clock=>Clock,
        req=>tomem,
        res=>memres,
        full_b_m=>full_b_m,
        full_m=>full_m
    );
end Behavioral;
