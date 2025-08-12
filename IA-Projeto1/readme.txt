Projeto 1 - Inteligência Artificial - Prolog
Alunos: José Lucas Hoppe Macedo e Luan Henrique Lopes Santana

INTRUÇÕES PARA EXECUÇÃO:
    1. Instale o SWI-Prolog:
	Caso ainda não tenha, baixe e instale o [SWI-Prolog](https://www.swi-prolog.org/Download.html).
    2. Abra o SWI-Prolog e carregue o arquivo do projeto:
	- Abra o SWI-Prolog.
	- No menu superior, clique em File → Consult...
	- Na janela que abrir, navegue até a pasta onde está o seu arquivo busca_trajetos.pl.
	- Selecione o arquivo busca_trajetos.pl e clique em Open.
    3. Execute o Programa:
	Após carregar o arquivo, o menu principal do programa aparecerá automaticamente. Siga as instruções exibidas na tela para continuar.
    4. Terminar:
	Quando finalizar os testes, digite 0 para finalizar a execução do programa.
	
IMPORTANTE: Para o arquivo .txt com o mapa das cidades e ligações, seu arquivo deve seguir o exemplo abaixo:

% Formato do Arquivo Texto
% Existência de Ligação entre Cidades
% Simbologia:
% 	a: cidade de origem
%	b: cidade de destino
%	dist: distância entre a e b
% 	ligacao(a,b,dist): relação sobre a ligação entre a e b com distância dist.
% 	Deve existir um fato para cada combinação de cidades que possuem ligação 
% 	entre si.
cidade_inicial(I). % I indica a partir de onde a busca deve começar.
cidade_final(F). % F indica onde a busca deve terminar.
ligacao(a,b,dist).

OBS: Na pasta consta dois arquivos exemplos: "mapa1.txt" e "mapa2.txt", esses arquivos estão como exemplo e podem ser utilizados ou modificados.

Certifique-se que todos os arquivos não (.txt ou .pl) não possuem caracteres especiais em seu nome.