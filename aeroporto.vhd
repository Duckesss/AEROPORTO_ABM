library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;


entity aeroporto is
port(
		listaDecolagem	:	in std_logic_vector (3 downto 0);	--Coloquei apenas para ter uma base de vetor de avioes, acho que deviamos usar o tempo que eles querem decolar ou pousar para definir a prioridade
		listaPouso		:	out std_logic_vector (3 downto 0);
		tempestade		:	in std_logic;
		peso				: 	in std_logic;
		imprevisto		:	in std_logic;
		tempo				:  in std_logic; --Não sei se de fato o tempo será booleano, minha ideia é fazer igual ao flag_write
		--que tá no código do tb_funcao da pratica 10
		decolar 			:  in std_logic;
		pousar 			:  in std_logic;
		pistaLivre		:  in std_logic;
		clock 			: in std_logic;
		alarme 			: out std_logic;
		contador			: out integer range 0 to 10
);
end aeroporto;

architecture arch of aeroporto is
	type estado is (AeroportoFuncionando, Pousando, Decolando, Espera);		--Os 4 estados da nossa FSM
	signal EA :estado;		--Proximo Estado, Estado Atual, Backup(Esse serve para armazenar algum
--	cancelamento de pouso ou decolagem por tempestade)
	
begin
	process(clock, EA, pousar, decolar, tempo, imprevisto, pistaLivre, listaDecolagem) -- Toda vez que o clock ou o estado mudar o process deve ser checado
	variable count : integer := 0;
		--variavel tempo é especial e vai ter que ter uma funcao p/ habilitá-la com 1 ou 0
	begin
	if (pousar = '0' and decolar = '0') then -- enquanto não há tráfego o estado pernece em AF
		EA <= AeroportoFuncionando;
	elsif (clock'event and clock = '1') then
		case EA is		
			when AeroportoFuncionando => 
				if (decolar = '1' and imprevisto = '0' and pistaLivre = '1' and tempo = '0') then -- Somente quando tiver aviao p/ decolar,
			--	não houver imprevistos e a pista estiver livre ele poderá decolar
					EA <= Decolando;
					count := count + 1; -- tentei implementar um contador mostrando que 1 aviao decolou, depois outro, etc
					-- o count não esta funcionando depois tem que arrumar ou entao nao usa-lo no codigo
				elsif (pousar = '1' and imprevisto = '0' and peso = '0' and pistaLivre = '1') then
					EA <= Pousando;
					--alarme <= '1';
				elsif (imprevisto = '1' or peso = '1' or pistaLivre = '0') then
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
				if (tempestade = '1') then
					EA <= Espera;
				elsif (tempo= '1') then
					EA <= AeroportoFuncionando;
				end if;
			
			when Espera =>
				if (tempestade = '0') then
					EA <= Pousando;
				end if;
		end case;
	end if;
	alarme <= tempo; -- o alarme deve ser igual ao tempo, pq enquanto ele for 1 tem aviao decolando ou pousando
						  -- e quando o tempo for 0 nao tem nada acontecendo
	contador <= count; 
	end process;
end arch;