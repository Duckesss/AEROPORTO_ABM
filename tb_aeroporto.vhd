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
				listaPouso		:	in std_logic_vector (3 downto 0);
				tempestade		:	in std_logic;
				peso				: 	in std_logic;
				imprevisto		:	in std_logic;
				tempo				:  in std_logic;
				decolar 			:  in std_logic;
				pousar 			:  in std_logic;
				pistaLivre		:  in std_logic;
				alarme			: in std_logic;
				clock 			: in std_logic);
end component;

	signal ListaDecolagem 			: std_logic_vector (3 downto 0);
	signal ListaPouso					: std_logic_vector (3 downto 0);
	signal Tempestade, Peso, Tempo: std_logic;
	signal Imprevisto, Decolar		: std_logic;
	signal Pousar, PistaLivre 		: std_logic;
	signal clk, Alarme            : std_logic;

	-- Sinais para fazer leitura e escrita nos arquivos
	signal read_data_in	: std_logic := '0';
	signal read_data_in2	: std_logic := '0';
	signal flag_write	: std_logic := '0';
	
	-- Sinais para fazer controle do tempo de diferentes estados da fsm
	signal t1, t2, t3, t4			: time; -- t1 = duracao estado AF, t2 = duracao decola, t3 = duracao pouso
	-- e t4 = duracao espera
	signal t_pouso, t_decola, t_peso, t_pista : time; -- tempo de subida e descida de cada sinal
	signal t_tempestade, t_imprevisto : time; -- tempo de subida e descida de cada sinal
	
	-- Sinais para saber em qual estado a fsm está (IMPREVISTO NÂO EH UM ESTADO,serve apenas para escrevermos na saída)
	signal p, d, e, af, imprev : std_logic := '0'; -- p = pousar, d = decolar, e = esperar e af = aeroporto funcionando
	-- i = imprevisto
	
	-- Sinal auxiliar
	signal aux : time := 2 ns;		-- sinal auxiliar para contar o tempo dos horários de transição,
	--ele é igual a 2 ns, pois é o tempo de atraso para começar o primeiro estado 
	signal r_time1, r_time2, r_time3, r_time4, r_time5	: integer; -- irão receber o valor de t1,t2,t3... porém
	--convertidos para inteiro, r de real time.

	file inputs_data_in	: text open read_mode is "aviao_decola.txt";
	file inputs_data_in2 : text open read_mode is "aviao_pousa.txt";
	file tempo_estado    : text open read_mode is "duracao_estado.txt";
	file tempo_sinal		: text open read_mode is "tempo_sinais.txt";
	file outputs1			: text open write_mode is "saida1.txt";
	
	constant decola 	: string (1 to 17) := "Tempo decolando: ";
	constant pousa 	: string (1 to 16) := "Tempo pousando: ";
	constant aeroportoFunciona 	: string (1 to 10) := "Tempo AF: ";
	constant espera 	: string (1 to 14) := "Tempo espera: ";
	constant imp		: string (1 to 18) := "Tempo imprevisto: ";
	constant t_transicao : string (1 to 17) := "    Transição: ";
	constant t_real	: string (1 to 12) := "Tempo real: ";
	constant minute	: string (1 to 4) := " min";
	constant hora		: string (1 to 8) := " hora(s)";
	constant space 	: string (1 to 5) := "     ";
	constant space1	: string (1 to 2) := "  ";
	constant space2 	: string (1 to 9) := "         "; 
	constant space3	: string (1 to 4) := "    ";
	constant space4	: string (1 to 1) := " ";

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
		clock=>clk
	);

------------------------------------------------------------------------------------
----------------- processo para gerar o sinal de clock 
------------------------------------------------------------------------------------		
        process    -- clock process for clock
        begin		 -- fica 10 ns em alto e 10 ns em baixo
            clock_loop : loop
                clk <= '1';
                wait for 5 ns;
                clk <= '0';
                wait for 5 ns;
            end loop clock_loop;
        end process;

------------------------------------------------------------------------------------
----------------- processo para gerar o sinal de tempo 
------------------------------------------------------------------------------------
duracao_estado : process
begin
		wait for 1.5 ns; 			-- infelizmente precisa desse delay de 0.5 ns pq a leitura das condições abaixo não
		for i in 1 to 100 loop	-- acontece imediatamente, é necessário add um tempo de espera
		if (decolar = '1' and peso = '0' and pistaLivre = '1' and tempestade = '0') then
			tempo <= '0';		-- entrar aqui significa que o aviao está decolando
			alarme <= '1';
			d <= '1';
			e <= '0';
			af <= '0';
			p <= '0';
			imprev <= '0';
			wait for (t2/2);	-- 5 ns
			tempo <= '1';
			alarme <= '1';
			wait for (t2/2);	-- 5 ns, no total se passam 10 ns em cada decolagem
		elsif (pousar = '1' and peso = '0' and imprevisto = '0' and pistaLivre = '1' and tempestade = '0') then
			tempo <= '0';		-- entrar aqui significa que o aviao está pousando
			alarme <= '1';
			p <= '1';
			d <= '0';
			e <= '0';
			af <= '0';
			imprev <= '0';
			wait for (t3/2);	-- 15 ns
			tempo <= '1';
			alarme <= '1';
			wait for (t3/2);	-- 15 ns, no total se passam 30 ns em cada pouso
		elsif ((imprevisto = '1' or peso = '1' or pistaLivre = '0') and tempestade = '0') then --mudar
			tempo <= '0';		-- entrar aqui significa que o aviao está no estado AF
			alarme <= '0';
			p <= '0';
			d <= '0';
			e <= '0';
			if (imprevisto = '1') then
				imprev <= '1';
				af <= '0';
			else
				af <= '1';
				imprev <= '0';
			end if;
			wait for (t1/2);	-- 3 ns
			tempo <= '1';
			alarme <= '0';
			wait for (t1/2);	-- 3 ns, no total se passam 6 ns em cada estado de AF
		elsif (tempestade = '1') then
         tempo <= '0';		-- entrar aqui significa que o aviao está no estado Espera
			alarme <= '0';
			p <= '0';
			d <= '0';
			e <= '1';
			af <= '0';
			imprev <= '0';
         wait for (t4/2);	-- 10 ns
         tempo <= '1';
			alarme <= '0';
         wait for (t4/2);	-- 10 ns, no total se passam 20 ns em cada estado de Espera
		else
			alarme <= '0';
			tempo <= '0';		-- Coloquei essa condição auxiliar, pois nem sempre uma das condições acima
         wait for 10 ns;	-- serão atendidas, então quando não for possível saber em qual estado está
         tempo <= '1';		--	o tempo passará a funcionar no mesmo tempo do clock. Isso pode ser consertado
			alarme <= '0';
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
	wait for 2.5 ns;
	while not endfile(inputs_data_in) loop
		if (decolar = '1' and peso = '0' and pistaLivre = '1' and tempestade = '0' and pousar = '0') then 
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
		variable input2 : std_logic_vector(3 downto 0);
	begin
	wait for 8 ns;	-- não sei do pq desse tempo mas foi o unico que funcionou
	while not endfile(inputs_data_in2) loop
		if (pousar = '1' and peso = '0' and imprevisto = '0' and pistaLivre = '1' and tempo = '0' 
		and decolar = '0' and tempestade = '0') then
			--wait for t2;
			readline(inputs_data_in2,linea);
			read(linea,input2);
			listaPouso <= input2;
		end if;
		wait for 5 ns; -- mesma com coisa com esse aqui. Ps.: A leitura desse arquivo e do de decolagem
	end loop;			-- estão meio zuados, se der pra arrumar isso vai ser lindo.
	--wait;
end process read_inputs_data_in2;

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
			t1 <= t;		-- t1 = estado aeroporto funcionando
			readline(tempo_estado, line2);
			read(line2, t);
			t2 <= t;		-- t2 = estado decolando
			readline(tempo_estado, line3);
			read(line3, t);
			t3 <= t;		-- t3 = estado pousando
			readline(tempo_estado, line4);
			read(line4, t);
			t4 <= t;		-- t4 = estado espera
		end if;
		wait for period;
	end loop;
	wait;
end process dura_estado;

------------------------------------------------------------------------------------
----------------- processo para ler os dados do arquivo tempo_sinais.txt
------------------------------------------------------------------------------------
problema : process
	variable line1, line2, line3, line4, line5, line6 : line;
	variable t : time;
	begin
	wait for 0.1 ns;
	while not endfile(tempo_sinal) loop
		if (read_data_in = '1') then
			readline(tempo_sinal, line1);
			read(line1, t);
			t_decola <= t;	--tempo gasto para decolar
			readline(tempo_sinal, line2);
			read(line2, t);
			t_pouso <= t;	--tempo gasto para pousar
			readline(tempo_sinal, line3);
			read(line3, t);
			t_peso <= t;	--Tempo para mudar o sinal do peso
			readline(tempo_sinal, line4);
			read(line4, t);
			t_pista <= t;	--Tempo para mudar o sinal de pista livre
			readline(tempo_sinal, line5);
			read(line5, t);
			t_tempestade <= t;	--tempo para mudar o sinal da tempestade
			readline(tempo_sinal, line6);
			read(line6, t);
			t_imprevisto <= t;	--tempo para mudar o sinal do imprevisto
		end if;
		wait for period;
	end loop;
	wait;
end process problema;


------------------------------------------------------------------------------------
------ processo para escrever os dados de saida no saida.txt
------------------------------------------------------------------------------------ 
escreve_output : process
	variable linea : line;
	begin
	wait for 0.1 ns;
	r_time1 <= t1/time'val(1000000); -- transforma o tempo em ns para inteiro
	r_time2 <= t2/time'val(1000000);
	r_time3 <= t3/time'val(1000000);
	r_time4 <= t4/time'val(1000000);
	r_time5 <= t_imprevisto/time'val(1000000);
	
	for i in 1 to 100 loop
	if (flag_write <= '1') then
	wait for 1 ns;
		if (d = '1') then
			write (linea, decola);			--imprime o texto "Tempo decolando: "
			write (linea, t2);				--imprime o tempo desse estado
			write (linea, space4);			--imprime alguns espaços no arquivo
			write (linea, t_transicao);	--imprime o texto "Transição: "
			write (linea, aux);				--imrpime o tempo em ns de quando se incia o estado
			write (linea, space);			--imprime alguns espaços no arquivo
			write (linea, t_real);			--imprime o texto "Tempo real: "
			write (linea, (r_time2*10)/5);--imprime a conversão do tempo em ns para minutos/hora
			write (linea, minute);			--impriem o texto " min"
			writeline (outputs1, linea);
			wait for t2;
			aux <= aux + t2;					--soma a duração do estado com o tempo armazenado em aux
		elsif (p = '1') then
			write (linea, pousa);
			write (linea, t3);
			write (linea, space1);
			write (linea, t_transicao);
			write (linea, aux);
			write (linea, space);
			write (linea, t_real);
			write (linea, (r_time3*30)/2);
			write (linea, minute);
			writeline (outputs1, linea);
			wait for t3;
			aux <= aux + t3;
		elsif (af = '1') then
			write (linea, aeroportoFunciona);
			write (linea, t1);
			write (linea, space2);
			write (linea, t_transicao);
			write (linea, aux);
			write (linea, space);
			write (linea, t_real);
			write (linea, (r_time1*6)/6);
			write (linea, minute);
			writeline (outputs1, linea);
			wait for t1;
			aux <= aux + t1;
		elsif (e = '1') then
			write (linea, espera);
			write (linea, t4);
			write (linea, space3);
			write (linea, t_transicao);
			write (linea, aux);
			write (linea, space);
			write (linea, t_real);
			write (linea, (r_time4*20)/20);
			write (linea, hora);
			writeline (outputs1, linea);
			wait for t4;
			aux <= aux + t4;
		elsif (imprev = '1') then
			write (linea, imp);
			write (linea, t_imprevisto);
			write (linea, t_transicao);
			write (linea, aux);
			write (linea, space);
			write (linea, t_real);
			write (linea, (r_time5*15)*2);
			write (linea, minute);
			writeline (outputs1, linea);
			wait for t_imprevisto;
			aux <= aux + t_imprevisto;
		end if;
	end if;
	end loop;
	wait;
end process escreve_output;
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
			read_data_in <= '1';
			for i in 1 to 6 loop --1 a 6 pq é a qntd de elementos na lista de tempo dos sinais
				wait for 20 ns;
			end loop;
			read_data_in <= '0';
			
END process tb_estimulo;

tb_estimulo2 : process
	begin
			read_data_in2 <= '1';
			for i in 1 to 3 loop --1 a 3 pq é a qntd de elementos na lista de problemas
				wait for 20 ns;
			end loop;
			read_data_in2 <= '0';

END process tb_estimulo2;
	
	
------------------------------------------------------------------------------------
----------------- processo para gerar os sinais de tempestade
------------------------------------------------------------------------------------
previsao_tempo : process
	begin
		wait for 0.5 ns;
		tempestade_loop : loop
			tempestade <= '0';
			wait for t_tempestade;
		   tempestade <= '1';
			wait for t_tempestade;
      end loop tempestade_loop;
end process;


--------------------------------------------------------------------------------------
----------------- processo para gerar o sinal de decolar 
--------------------------------------------------------------------------------------
decolando : process  -- 15 ns em alto e 15 ns em baixo
	begin
	wait for 0.5 ns;
		decola_loop : loop
			decolar <= '1';
			wait for t_decola;
			decolar <= '0';
			wait for t_decola;
      end loop decola_loop;
end process;


--------------------------------------------------------------------------------------
----------------- processo para gerar o sinal de pousar 
--------------------------------------------------------------------------------------
quero_pousar : process  -- 15 ns em alto e 15 ns em baixo
	begin
		wait for 0.5 ns;
		pousa_loop : loop
			pousar <= '0';
			wait for t_pouso;
			pousar <= '1';
			wait for t_pouso;
      end loop pousa_loop;
end process;


--------------------------------------------------------------------------------------
----------------- processo para gerar o sinal de peso 
--------------------------------------------------------------------------------------
sinal_peso : process -- 30 ns em alto e 30 ns em baixo
	begin
		wait for 0.5 ns;
		peso_loop : loop
			peso <= '0';
			wait for t_peso;
			peso <= '1';
			wait for t_peso;
		end loop peso_loop;
end process;


--------------------------------------------------------------------------------------
----------------- processo para gerar o sinal de imprevisto 
--------------------------------------------------------------------------------------
sinal_imprevisto : process   --15 ns em baixo e 15 ns em alto
	begin
		wait for 0.5 ns;
		imprevisto_loop : loop
			imprevisto <= '0';
			wait for t_imprevisto;
			imprevisto <= '1';
			wait for t_imprevisto;
		end loop imprevisto_loop;
end process;


--------------------------------------------------------------------------------------
----------------- processo para gerar o sinal de pistaLivre 
--------------------------------------------------------------------------------------
sinal_pistaLivre : process   -- 15 ns em alto e 15 ns em baixo
	begin
		wait for 0.5 ns;
		pista_loop : loop
			pistaLivre <= '1';
			wait for t_pista;
			pistaLivre <= '0';
			wait for t_pista;
		end loop pista_loop;
end process;




end testesucesso;


