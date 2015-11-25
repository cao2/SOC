library ieee;
use ieee.math_real.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
package nondeterminism is
  shared variable s1: integer:= 844396720;
  shared variable s2: integer:= 821616997;
  -- Returns a number between 1 and num.
 impure function selection(constant num:in integer) return integer;
  -- Returns a std_logic_vector of size bits between 1 and num.
 impure function selection(constant num:in integer;
                      constant size:in integer) return std_logic_vector;
  -- Returns random delay between lower and upper.
  impure function delay (constant l:in integer;
                    constant u:in integer) return time;
end nondeterminism;
package body nondeterminism is
   
  impure function selection(constant num:in integer) return integer is
    variable result:integer;
    variable tmp_real: real;
   
  begin
    uniform(s1,s2,tmp_real);
    result := 1 + integer(trunc(tmp_real * real(num)));
    return (result);
  end selection;
  
  impure function selection(constant num:in integer;
                       constant size:in integer)
    return std_logic_vector is
    variable result:std_logic_vector(size-1 downto 0);
    variable tmp_real:real;
  begin
    uniform(s1,s2,tmp_real);
    result := conv_std_logic_vector (integer(trunc(tmp_real * real (num)))
                                      +1,size);
    return (result);
  end selection;
  impure function delay (constant l:in integer;
                    constant u:in integer) return time is
			variable result:time;
			variable tmp : real ;
			
    begin
			uniform(s1,s2,tmp);
			result:=(((tmp * real(u - 1)) + real(l)) * 1 ns);
			return result;
	end delay;
end nondeterminism; 