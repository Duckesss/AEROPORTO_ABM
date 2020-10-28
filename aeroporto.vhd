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
		tempestade		:	in std_logic;
		peso				: 	in std_logic;
		imprevisto		:	in std_logic;
		tempo				:  in std_logic;
		decolar 			:  in std_logic;
		pousar 			:  in std_logic;
		pistaLivre		:  in std_logic;
		clock 			:  in std_logic;
		alarme 			:  in std_logic	
		--contador			:  out integer range 0 to 10
);


-------------------------------------------------------------------------------------
------------------------   DECLARAÃ‡ÃƒO DE ATRIBUTOS    -------------------------------
-------------------------------------------------------------------------------------
--attribute temp_deco_Tempestade : std_logic;
--attribute temp_deco_Tempestade of tempestade : signal is tempestade(tempestade'last_event);


end aeroporto;



architecture arch of aeroporto is
	type estado is (AeroportoFuncionando, Pousando, Decolando, Espera);		--Os 4 estados da nossa FSM
	signal EA :estado;		--Proximo Estado, Estado Atual, Backup(Esse serve para armazenar algum
--	cancelamento de pouso ou decolagem por tempestade)
	
begin
	process(clock, EA, pousar, decolar, imprevisto, peso, tempestade, pistaLivre) -- Toda vez que o clock ou o estado mudar o process deve ser checado
	--variable count : integer := 0;
		--variavel tempo Ã© especial e vai ter que ter uma funcao p/ habilitÃ¡-la com 1 ou 0
	begin
	if (pousar = '0' and decolar = '0') then -- enquanto nÃ£o hÃ¡ trÃ¡fego o estado pernece em AF
		EA <= AeroportoFuncionando;
	elsif (clock'event and clock = '1') then
		case EA is		
			when AeroportoFuncionando => 
				
				if(pistaLivre = '0' or peso = '1') then --	Ele fica aqui se a pista não estiver livre ou o peso for maior que o suportado
					EA <= AeroportoFuncionando;
				elsif (decolar = '1' and tempestade = '0') then -- Somente quando tiver aviao p/ decolar,
					EA <= Decolando;
				elsif (pousar = '1' and imprevisto = '0' and tempestade = '0') then
					EA <= Pousando;
				elsif (tempestade = '1') then
					EA <= Espera;
				end if;
				
			when Decolando =>
				if (tempestade = '1') then
					EA <= Espera;
				elsif (tempestade = '0') then -- Tempestade passou
					EA <= AeroportoFuncionando;
				end if;
				
			when Pousando =>
				if (tempestade = '1' or imprevisto = '1' ) then
					EA <= Espera;
				elsif (pousar = '0' or decolar = '1') then			-- alterei de tempo = '1' p/ pousar = '0'
					EA <= AeroportoFuncionando;
				end if;
			
			when Espera =>
				if (tempestade = '0'and imprevisto = '0') then
					EA <= Pousando;
				elsif(decolar = '0' or pousar = '1') then
					EA <= AeroportoFuncionando;
				end if;
		end case;
	end if;
	end process;
end arch;