library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity funcao is
port(
		x	:	in std_logic_vector (3 downto 0);
		f	:	out std_logic_vector (9 downto 0);
		clock : in std_logic
);
end funcao;

architecture arch of funcao is
	constant r : unsigned (1 downto 0) := "10";
	
begin
	process(x)
		variable a,na : unsigned (3 downto 0);
		variable b : unsigned (9 downto 0);
	begin
		a := unsigned (x);
		na := unsigned (not x);
		b := r*a*na;
		f <= std_logic_vector(b);
	end process;
	
end arch;
