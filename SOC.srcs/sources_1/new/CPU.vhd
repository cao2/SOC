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
use IEEE.STD_LOGIC_1164.ALL;
use iEEE.std_logic_unsigned.all ;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity CPU is
    Port ( 
           random: in STD_LOGIC;
           readreq : out STD_LOGIC;
           writereq : out STD_LOGIC;
           data : out STD_LOGIC_VECTOR(31 downto 0);
           address : out STD_LOGIC_VECTOR(15 downto 0)
           );
end CPU;

architecture Behavioral of CPU is

begin

 p1 : process (Clock, random)
     begin
     if(rising_edge(Clock)
          if(random%2==0) then
            readreq<=1;
            writereq<=0;
            data<='';
            address<=random;
          elif(random%2=1) then
            writereq<=1;
            readreq<=0;
            address=random;
            data='abcdefffffffffffffffffffffffffff';
          end if;
       end if;
        
     end process;

end Behavioral;
