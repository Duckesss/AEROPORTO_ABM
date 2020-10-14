library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;

entity aeroporto is
port(
		ListaDecolagem	:	in std_logic_vector (3 downto 0);	--Coloquei apenas para ter uma base de vetor de avioes, acho que deviamos usar o tempo que eles querem decolar ou pousar para definir a prioridade
		ListaPouso	:	out std_logic_vector (3 downto 0);
		Tempestade	:	in std_logic_vector (3 downto 0);
		Peso			: 	in std_logic_vector (3 downto 0);
		Incidente	:	in std_logic_vector (3 downto 0);
		clock : in std_logic
);
end aeroporto;

architecture arch of aeroporto is
	type estado is (AeroportoFuncionando, Pousando, Decolando, Espera);		--Os 4 estados da nossa FSM
	signal PE,EA,BACKUP :estado;		--Proximo Estado, Estado Atual, Backup(Esse serve para armazenar algum
--	cancelamento de pouso ou decolagem por tempestade)
	
begin
	process(clock, EA) -- Toda vez que o clock ou o estado mudar o process deve ser checado
		variable pistaLivre, pousar, decolar, imprevisto, peso, clima, tempo : std_logic;
		--variavel tempo é especial e vai ter que ter uma funcao p/ habilitá-la com 1 ou 0
	begin
	if (pousar = '0' and decolar = '0') then -- enquanto não há tráfego o estado pernece em AF
		EA <= AeroportoFuncionando;
	elsif (clock'event and clock = '1') then
		case EA is
		
			when AeroportoFuncionando => 
				if (decolar = '1' and imprevisto = '0' and pistaLivre = '1') then -- Somente quando tiver aviao p/ decolar,
			--	não houver imprevistos e a pista estiver livre ele poderá decolar
					EA <= Decolando;
				elsif (pousar = '1' and imprevisto = '0' and peso = '0' and pistaLivre = '1') then
					EA <= Pousando;
				elsif (imprevisto = '1' or peso = '1' or pistaLivre = '0') then
					--EA <= Espera; --?? Quando isso acontece o aviao deve ser mandado pra outro estado de espera, não?
					EA <= AeroportoFuncionando;
				elsif (clima = '1') then
					EA <= Espera;
				end if;
				
			when Decolando =>
				if (clima = '1') then
					EA <= Espera;
				elsif (tempo = '1' and clima = '0') then --mexer dps na variavel tempo
					EA <= AeroportoFuncionando;
				end if;
				
			when Pousando =>
				if (clima = '1') then
					EA <= Espera;
				elsif (tempo= '1') then
					EA <= AeroportoFuncionando;
				end if;
			
			when Espera =>
				if (clima = '0') then
					EA <= Pousando;
				end if;
			
		end case;
	end if;
	end process;
end arch;