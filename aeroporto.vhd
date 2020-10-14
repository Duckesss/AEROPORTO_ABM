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
	type estado is (AeroportoFuncionando, Pousando, Decolando, Imprevisto);		--Os 4 estados da nossa FSM
	signal PE,EA,BACKUP :estado;		--Proximo Estado, Estado Atual, Backup(Esse serve para armazenar algum cancelamento de pouso ou decolagem por tempestade)
	
begin
	process()
		variable PistaLivre : boolean;
	
	
end arch;