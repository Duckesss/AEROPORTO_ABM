library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;

entity tb_aeroporto is
end tb_aeroporto;

architecture testesucesso of tb_aeroporto is

component aeroporto is

	port (	listaDecolagem	:	in std_logic_vector (3 downto 0);	--Coloquei apenas para ter uma base de vetor de avioes, acho que deviamos usar o tempo que eles querem decolar ou pousar para definir a prioridade
				listaPouso		:	out std_logic_vector (3 downto 0);
				tempestade		:	in std_logic;
				peso				: 	in std_logic;
				imprevisto		:	in std_logic;
				tempo				:  in std_logic;
				decolar 			:  in std_logic;
				pousar 			:  in std_logic;
				pistaLivre		:  in std_logic;
				contador			: out integer range 0 to 10;
				alarme			: out std_logic;
				tempo_decorrido : out std_logic;
				clock 			: in std_logic);
end component;

	signal ListaDecolagem 			: std_logic_vector (3 downto 0);
	signal ListaPouso					: std_logic_vector (3 downto 0);
	signal Tempestade, Peso, Tempo: std_logic;
	signal Imprevisto, Decolar		: std_logic;
	signal Pousar, PistaLivre 		: std_logic;
	signal clk, Alarme            : std_logic;
	signal Temp_Decorrido			: std_logic;
	signal contador 					: integer;

	signal read_data_in	: std_logic := '0';
	signal read_data_in2	: std_logic := '0';
	signal flag_write	: std_logic := '0';

	file inputs_data_in	: text open read_mode is "aviao_decola.txt";
	file inputs_data_in2 : text open read_mode is "aviao_pousa.txt";
	--file outputs2			: text open write_mode is "saida2.txt";

	-- Clock period definitions
   constant period     : time := 20 ns;
   constant duty_cycle : real := 0.5;
   constant offset     : time := 5 ns;
	
begin
DUT : aeroporto
	port map (
		listaDecolagem=>ListaDecolagem,
		listaPouso=>ListaPouso,
		tempestade=>Tempestade,
		peso=>Peso,
		tempo=>Tempo,
		imprevisto=>Imprevisto,
		decolar=>Decolar,
		pousar=>Pousar,
		pistaLivre=>PistaLivre,
		alarme=>Alarme,
		--tempo_decorrido => Temp_Decorrido,
		contador=>contador,
		clock=>clk
	);

------------------------------------------------------------------------------------
----------------- processo para gerar o sinal de clock 
------------------------------------------------------------------------------------		
        process    -- clock process for clock
        begin		 -- fica 10 ns em alto e 10 ns em baixo
            --wait for offset;
            clock_loop : loop
                clk <= '0';
                wait for (period - (period * duty_cycle));
                clk <= '1';
                wait for (period * duty_cycle);
            end loop clock_loop;
        end process;

------------------------------------------------------------------------------------
----------------- processo para ler os dados do arquivo aviao_decola.txt
------------------------------------------------------------------------------------
read_inputs_data_in : process
		variable linea : line;
		variable input : std_logic_vector(3 downto 0);
	begin
	wait for 1 ns;--until falling_edge(clk);
	while not endfile(inputs_data_in) loop
		if (tempo = '0' and decolar = '1' and peso = '0' and imprevisto = '0' and pistaLivre = '1') then 
		-- se tempo = 0 (sem aviao decolando ou pousando) e tem aviao p/ decolar e o peso for aceitavel
		-- e a pista estiver livre, então se incia a leitura do arquivo quando isso acontece
			readline(inputs_data_in,linea);
			read(linea,input);
			listaDecolagem <= input;
		end if;
		wait for period;
	end loop;
	wait;
end process read_inputs_data_in;

------------------------------------------------------------------------------------
----------------- processo para ler os dados do arquivo aviao_pousa.txt
------------------------------------------------------------------------------------
read_inputs_data_in2 : process
		variable linea : line;
		variable input : std_logic_vector(3 downto 0);
	begin
	wait for 1 ns;--until falling_edge(clk);
	while not endfile(inputs_data_in2) loop
		if (tempo = '0' and decolar = '1' and peso = '0' and imprevisto = '0' and pistaLivre = '1') then 
		-- se tempo = 0 (sem aviao decolando ou pousando) e tem aviao p/ decolar e o peso for aceitavel
		-- e a pista estiver livre, então se incia a leitura do arquivo quando isso acontece
			readline(inputs_data_in,linea);
			read(linea,input);
			listaPouso <= input;
		end if;
		wait for period;
	end loop;
	wait;
end process read_inputs_data_in2;

------------------------------------------------------------------------------------
----------------- processo para gerar os estimulos de entrada
------------------------------------------------------------------------------------
tb_estimulo : process
	begin
		--wait for 5 ns;
			read_data_in <= '1';
			for i in 1 to 8 loop --1 a 8 pq é a qntd de elementos na lista de decolagem
				wait for 20 ns;
			end loop;
			read_data_in <= '0';
		--wait;

END process tb_estimulo;

tb_estimulo2 : process
	begin
		--wait for 5 ns;
			read_data_in2 <= '1';
			for i in 1 to 8 loop --1 a 8 pq é a qntd de elementos na lista de decolagem
				wait for 20 ns;
			end loop;
			read_data_in2 <= '0';
		--wait;

END process tb_estimulo2;
	
------------------------------------------------------------------------------------
----------------- processo para gerar os sinais de tempestade
------------------------------------------------------------------------------------
--previsao_tempo : process
	--begin
		--wait for 10 ns;
		--tempestade_loop : loop
			--tempestade <= '1';
			--wait for 10 ns;
		--	tempestade <= '0';
	--		wait for 10 ns;
  --    end loop tempestade_loop;
--end process;

--------------------------------------------------------------------------------------
----------------- processo para gerar o sinal de decolar 
--------------------------------------------------------------------------------------
decolando : process  -- 15 ns em alto e 15 ns em baixo
	begin
		decola_loop : loop
			decolar <= '1';
			wait for 15 ns;
			decolar <= '0';
			wait for 15 ns;
      end loop decola_loop;
end process;

--------------------------------------------------------------------------------------
----------------- processo para gerar o sinal de tempo 
--------------------------------------------------------------------------------------
tempo_decolar : process  -- 10 ns em baixo (pode decolar) e 20 ns em alto (tem aviao decolando)
	begin
		tempo_decola_loop : loop
			if (Decolar = '1' and PistaLivre = '1' and Peso = '0' and Imprevisto = '0') then
			-- se as condicoes acima forem atendidas o tempo deve começar a contar
			--porem na simulacao o tempo só é igual a 1 depois de 1 ns por conta do "wait for 1 ns"
			--nao sei como conserta isso, quando tiro dá erro na simulacao
				Tempo <= '1';			
				wait for 20 ns;
			else
				Tempo <= '0';
				wait for 1 ns;				
			end if;
		end loop tempo_decola_loop;
end process;

--------------------------------------------------------------------------------------
----------------- processo para gerar o sinal de peso 
--------------------------------------------------------------------------------------
sinal_peso : process -- 30 ns em alto e 30 ns em baixo
	begin
		peso_loop : loop
			peso <= '0';
			wait for 30 ns;
			peso <= '1';
			wait for 30 ns;
		end loop peso_loop;
end process;

--------------------------------------------------------------------------------------
----------------- processo para gerar o sinal de imprevisto 
--------------------------------------------------------------------------------------
sinal_imprevisto : process   --15 ns em baixo e 15 ns em alto
	begin
		imprevisto_loop : loop
			imprevisto <= '0';
			wait for 15 ns;
			imprevisto <= '1';
			wait for 15 ns;
		end loop imprevisto_loop;
end process;

--------------------------------------------------------------------------------------
----------------- processo para gerar o sinal de pistaLivre 
--------------------------------------------------------------------------------------
sinal_pistaLivre : process   -- 15 ns em alto e 15 ns em baixo
	begin
		pista_loop : loop
			pistaLivre <= '1';
			wait for 15 ns;
			pistaLivre <= '0';
			wait for 15 ns;
		end loop pista_loop;
end process;




end testesucesso;


