library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;

entity tb_funcao is
end tb_funcao;

architecture testesucesso of tb_funcao is

component funcao is

	port (	x	:	in std_logic_vector(3 downto 0);
			f	:	out std_logic_vector (9 downto 0);
			clock: in std_logic); --m
end component;

	signal X 	: std_logic_vector (3 downto 0);
	signal F	: std_logic_vector (9 downto 0);
	signal clk              : std_logic; --m

	signal read_data_in	: std_logic := '0';
	signal flag_write	: std_logic := '0';

	file inputs_data_in	: text open read_mode is "arquivo.txt";
	file outputs 		: text open write_mode is "saida1.txt";
	file outputs2		: text open write_mode is "saida2.txt";

	type aux is array (integer range <>) of std_logic_vector (9 downto 0);
	constant igual		: string (1 to 15) := "Valor Correto: ";
	constant diferente	: string (1 to 17) := "Valor Incorreto: ";
	constant comparador	: aux (1 to 14) := ("0000000000", "0000011100", "0000110100", "0001001000",
	 "0001011000", "0001100100", "0001101100", "0001110000", "0001110000", "0001101100", "0001100100",
	 "0001001000", "0000011100", "0000000000");

	-- Clock period definitions
   	constant PERIOD     : time := 20 ns;
   	constant DUTY_CYCLE : real := 0.5;
   	constant OFFSET     : time := 5 ns;

begin
DUT: funcao
	port map(x=>X, f=>F, clock=>clk);


------------------------------------------------------------------------------------
----------------- processo para gerar o sinal de clock 
------------------------------------------------------------------------------------		
        PROCESS    -- clock process for clock
        BEGIN
            WAIT for OFFSET;
            CLOCK_LOOP : LOOP --?
                clk <= '0';
                WAIT FOR (PERIOD - (PERIOD * DUTY_CYCLE));
                clk <= '1';
                WAIT FOR (PERIOD * DUTY_CYCLE);
            END LOOP CLOCK_LOOP;
        END PROCESS;

------------------------------------------------------------------------------------
----------------- processo para ler os dados do arquivo arquivo.txt
------------------------------------------------------------------------------------
read_inputs_data_in : process
		variable linea : line;
		variable input : std_logic_vector(3 downto 0);
	begin
	--wait for 7 ns;
	wait until falling_edge(clk);
	while not endfile(inputs_data_in) loop
		if read_data_in = '1' then
			readline(inputs_data_in,linea);
			read(linea,input);
			X <= input;
		end if;
		wait for PERIOD;
	end loop;
	wait;
end process read_inputs_data_in;

------------------------------------------------------------------------------------
----------------- processo para gerar os estimulos de entrada
------------------------------------------------------------------------------------
tb_stimuli : process
	begin
		wait for 5 ns;
			read_data_in <= '1';
			for i in 1 to 15 loop
				wait for 20 ns;
			end loop;
			read_data_in <= '0';
		wait;

END process tb_stimuli;	

------------------------------------------------------------------------------------
------ processo para gerar os estimulos de escrita do arquivo de saida
------------------------------------------------------------------------------------  
write_outputs : process
	begin
	--wait for 10 ns;
		flag_write <= '1';
		for i in 1 to 15 loop
			wait for 20 ns;
		end loop;
		flag_write <= '0';
	wait;
end process write_outputs;

------------------------------------------------------------------------------------
------ processo para escrever os dados de saida no saida1.txt
------------------------------------------------------------------------------------     
escreve_outputs : process
	variable linea, lineb  : line;
	variable output : std_logic_vector (9 downto 0);
	begin
	while true loop
		if (flag_write ='1')then
			write(linea,F);
			writeline(outputs,linea);
		end if;
		wait for 20 ns;
	end loop;
end process escreve_outputs;


------------------------------------------------------------------------------------
------ processo para escrever os dados de saida no saida2.txt
------------------------------------------------------------------------------------     
escreve_outputs2 : process
	variable linea	: line;
	variable output : std_logic_vector (9 downto 0);
	begin
	wait for 20 ns;
		flag_write <= '1';
		for i in 1 to 14 loop
			wait for 20 ns;
			output := F;		
			if (comparador(i) = output) then 
				assert (comparador(i) /= output) report igual severity note;
				write (linea, igual);
				write (linea, comparador(i));
				writeline (outputs2, linea);

			else
				assert (comparador(i) = output) report diferente severity warning;
				write (linea, diferente);
				write (linea, comparador(i));
				writeline (outputs2, linea);
			end if;
		end loop;
		flag_write <= '0';
	wait;
end process escreve_outputs2; 



end testesucesso;


		