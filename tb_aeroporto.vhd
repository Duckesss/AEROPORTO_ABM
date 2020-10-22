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
				duracao			:  in time;
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
	signal Duracao						: time;

	signal read_data_in	: std_logic := '0';
	signal read_data_in2	: std_logic := '0';
	signal flag_write	: std_logic := '0';
	signal t1, t2, t3, t4			: time; -- t1 = duracao estado AF, t2 = duracao decola, t3 = duracao pouso
	-- e t4 = duracao espera

	file inputs_data_in	: text open read_mode is "aviao_decola.txt";
	file inputs_data_in2 : text open read_mode is "aviao_pousa.txt";
	file tempo_estado    : text open read_mode is "duracao_estado.txt";
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
		duracao=>Duracao,
		contador=>contador,
		clock=>clk
	);

------------------------------------------------------------------------------------
----------------- processo para gerar o sinal de clock 
------------------------------------------------------------------------------------		
        process    -- clock process for clock
        begin		 -- fica 10 ns em alto e 10 ns em baixo
            clock_loop : loop
                clk <= '0';
                wait for 10 ns;
                clk <= '1';
                wait for 10 ns;
            end loop clock_loop;
        end process;

------------------------------------------------------------------------------------
----------------- processo para gerar o sinal de tempo 
------------------------------------------------------------------------------------
duracao_estado : process
begin
		wait for 0.5 ns; 			-- infelizmente precisa desse delay de 0.5 ns pq a leitura das condições abaixo não
		for i in 1 to 100 loop	-- acontece imediatamente, é necessário add um tempo de espera
		if (decolar = '1' and peso = '0' and imprevisto = '0' and pistaLivre = '1') then
			tempo <= '0';		-- entrar aqui significa que o aviao está decolando
			wait for (t2/2);	-- 5 ns
			tempo <= '1';
			wait for (t2/2);	-- 5 ns, no total se passam 10 ns em cada decolagem
		elsif (pousar = '1' and peso = '0' and imprevisto = '0' and pistaLivre = '1') then
			tempo <= '0';		-- entrar aqui significa que o aviao está pousando
			wait for (t3/2);	-- 15 ns
			tempo <= '1';
			wait for (t3/2);	-- 15 ns, no total se passam 30 ns em cada pouso
		elsif ((imprevisto = '1' or peso = '1' or pistaLivre = '0') and tempestade = '0') then
			tempo <= '0';		-- entrar aqui significa que o aviao está no estado AF
			wait for (t1/2);	-- 3 ns
			tempo <= '1';
			wait for (t1/2);	-- 3 ns, no total se passam 6 ns em cada estado de AF
		elsif (tempestade = '1') then
         tempo <= '0';		-- entrar aqui significa que o aviao está no estado Espera
         wait for (t4/2);	-- 10 ns
         tempo <= '1';
         wait for (t4/2);	-- 10 ns, no total se passam 20 ns em cada estado de Espera
		else
			tempo <= '0';		-- Coloquei essa condição auxiliar, pois nem sempre uma das condições acima
         wait for 10 ns;	-- serão atendidas, então quando não for possível saber em qual estado está
         tempo <= '1';		--	o tempo passará a funcionar no mesmo tempo do clock. Isso pode ser consertado
         wait for 10 ns;
		end if;
      end loop;
		wait;
end process duracao_estado;
------------------------------------------------------------------------------------
----------------- processo para ler os dados do arquivo aviao_decola.txt
------------------------------------------------------------------------------------
read_inputs_data_in : process
		variable linea : line;
		variable input : std_logic_vector(3 downto 0);
	begin
	wait for 1.5 ns;--until falling_edge(clk);
	while not endfile(inputs_data_in) loop
		if (decolar = '1' and peso = '0' and imprevisto = '0' and pistaLivre = '1' and tempo = '0') then 
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
--read_inputs_data_in2 : process
		--variable linea : line;
		--variable input : std_logic_vector(3 downto 0);
	--begin
	--wait for 0.5 ns;
	--while not endfile(inputs_data_in2) loop
		--if (pousar = '1' and peso = '0' and imprevisto = '0' and pistaLivre = '1') then 
		-- se tempo = 0 (sem aviao decolando ou pousando) e tem aviao p/ decolar e o peso for aceitavel
		-- e a pista estiver livre, então se incia a leitura do arquivo quando isso acontece
			--readline(inputs_data_in,linea);
			--read(linea,input);
			--listaPouso <= input;
		--end if;
		--wait for period;
	--end loop;
	--wait;
--end process read_inputs_data_in2;

------------------------------------------------------------------------------------
----------------- processo para ler os dados do arquivo duracao_estado.txt
------------------------------------------------------------------------------------
dura_estado : process
	variable line1, line2, line3, line4 : line;
	variable t : time;
	begin
	wait for 0.1 ns;
	while not endfile(tempo_estado) loop
		if (flag_write = '1') then
			readline(tempo_estado, line1);
			read(line1, t);
			t1 <= t;
			duracao <= t;
			readline(tempo_estado, line2);
			read(line2, t);
			t2 <= t;
			readline(tempo_estado, line3);
			read(line3, t);
			t3 <= t;
			readline(tempo_estado, line4);
			read(line4, t);
			t4 <= t;
		end if;
		wait for period;
	end loop;
	wait;
end process dura_estado;

------------------------------------------------------------------------------------
------ processo para gerar os estimulos de escrita do arquivo de entrada
------------------------------------------------------------------------------------  
write_outputs : process
	begin
		flag_write <= '1';
		for i in 1 to 4 loop
			wait for 20 ns;
		end loop;
		flag_write <= '0';
end process write_outputs;
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
previsao_tempo : process
	begin
		tempestade_loop : loop
			tempestade <= '1';
			wait for 25 ns;
		   tempestade <= '0';
			wait for 25 ns;
      end loop tempestade_loop;
end process;

--------------------------------------------------------------------------------------
----------------- processo para gerar o sinal de decolar 
--------------------------------------------------------------------------------------
decolando : process  -- 15 ns em alto e 15 ns em baixo
	begin
		decola_loop : loop
			decolar <= '1';
			wait for 9 ns;
			decolar <= '0';
			wait for 9 ns;
      end loop decola_loop;
end process;

--------------------------------------------------------------------------------------
----------------- processo para gerar o sinal de pousar 
--------------------------------------------------------------------------------------
quero_pousar : process  -- 15 ns em alto e 15 ns em baixo
	begin
		pousa_loop : loop
			pousar <= '0';
			wait for 9 ns;
			pousar <= '1';
			wait for 9 ns;
      end loop pousa_loop;
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


