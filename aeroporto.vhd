library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;


entity aeroporto is
port(
		listaDecolagem	:	in std_logic_vector (3 downto 0);	--Coloquei apenas para ter uma base de vetor de avioes, acho que deviamos usar o tempo que eles querem decolar ou pousar para definir a prioridade
		listaPouso		:	in std_logic_vector (3 downto 0);
		duracao			:  in time;
		tempestade		:	in std_logic;
		peso				: 	in std_logic;
		imprevisto		:	in std_logic;
		tempo				:  in std_logic;
		decolar 			:  in std_logic;
		pousar 			:  in std_logic;
		pistaLivre		:  in std_logic;
		clock 			: in std_logic;
		alarme 			: in std_logic;
		tempo_decorrido: out std_logic;	
		contador			: out integer range 0 to 10
);


-------------------------------------------------------------------------------------
------------------------   DECLARAÇÃO DE ATRIBUTOS    -------------------------------
-------------------------------------------------------------------------------------
--attribute temp_deco_Tempestade : std_logic;
--attribute temp_deco_Tempestade of tempestade : signal is tempestade(tempestade'last_event);


end aeroporto;



architecture arch of aeroporto is
	type estado is (AeroportoFuncionando, Pousando, Decolando, Espera);		--Os 4 estados da nossa FSM
	signal EA :estado;		--Proximo Estado, Estado Atual, Backup(Esse serve para armazenar algum
--	cancelamento de pouso ou decolagem por tempestade)
	
begin
	process(clock, EA, pousar, decolar, tempo, imprevisto, peso, tempestade, pistaLivre, listaDecolagem, listaPouso) -- Toda vez que o clock ou o estado mudar o process deve ser checado
	variable count : integer := 0;
		--variavel tempo é especial e vai ter que ter uma funcao p/ habilitá-la com 1 ou 0
	begin
	if (pousar = '0' and decolar = '0') then -- enquanto não há tráfego o estado pernece em AF
		EA <= AeroportoFuncionando;
	elsif (clock'event and clock = '1') then
		case EA is		
			when AeroportoFuncionando => 
				if (decolar = '1' and pistaLivre = '1' and peso = '0') then -- Somente quando tiver aviao p/ decolar,
			--	não houver imprevistos e a pista estiver livre ele poderá decolar
					count := count + 1;
					EA <= Decolando;
					--count := count + 1; -- tentei implementar um contador mostrando que 1 aviao decolou, depois outro, etc
					-- o count não esta funcionando depois tem que arrumar ou entao nao usa-lo no codigo
					--Não faz sentido por ele aqui, pq a FSM irá entrar aqui várias vezes, acho que o correto é estar
					--na transição do fim do pouso ou decolagem
				elsif (pousar = '1' and imprevisto = '0' and peso = '0' and pistaLivre = '1') then
					EA <= Pousando;
				elsif (peso = '1' or pistaLivre = '0') then
					--EA <= Espera; --?? Quando isso acontece o aviao deve ser mandado pra outro estado de espera, não?
					EA <= AeroportoFuncionando;
				elsif (tempestade = '1') then
					EA <= Espera;
				end if;
				
			when Decolando =>
				if (tempestade = '1') then
					EA <= Espera;
				elsif (tempo = '1' and tempestade = '0') then --mexer dps na variavel tempo
					EA <= AeroportoFuncionando;
				end if;
				
			when Pousando =>
				if (tempestade = '1' or imprevisto = '1' ) then
					EA <= Espera;
				elsif (tempo= '1') then
					EA <= AeroportoFuncionando;
				end if;
			
			when Espera =>
				if (tempestade = '0'and imprevisto = '0') then
					EA <= Pousando;
				elsif(imprevisto = '1') then
					EA <= AeroportoFuncionando;
				end if;
		end case;
	end if;
	
	contador <= count; 
	
	--tempo_decorrido <= temp_deco_Tempestade;
	end process;
end arch;