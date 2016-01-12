library ieee;
use ieee.math_real.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use std.textio.all;
use IEEE.std_logic_textio.all; 
package writefunction is
 
 impure function write50( logct: std_logic_vector(50 downto 0); logsr: string(8 downto 1)) return boolean;
  -- Returns a std_logic_vector of size bits between 1 and num.
 impure function write51(logct: std_logic_vector(51 downto 0);  logsr: string(8 downto 1)) return boolean;
 
end writefunction;
package body writefunction is
   
  impure function  write50( logct: std_logic_vector(50 downto 0); logsr: string(8 downto 1)) return boolean is
    file logfile: text;
    variable linept:line;
   
  begin
    file_open(logfile,"C:\Users\cao2\Documents\log.txt",append_mode);
    write(linept,logsr);
    write(linept,logct);    
    writeline(logfile,linept);
    file_close(logfile);
    return true;
  end write50;
  
  
   impure function  write51( logct: std_logic_vector(51 downto 0); logsr: string(8 downto 1)) return boolean is
    file logfile: text;
    variable linept:line;
   
  begin
    file_open(logfile,"C:\Users\cao2\Documents\log.txt",append_mode);
    write(linept,logsr);
    write(linept,logct);    
    writeline(logfile,linept);
    file_close(logfile);
    return true;
  end write51;

  
end writefunction; 