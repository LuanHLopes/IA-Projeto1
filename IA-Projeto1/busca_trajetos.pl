% -----------------------------------------------------------------------
% Função: main_menu
% Descrição: Exibe o menu principal do programa e lê a opção do usuário.
% Entrada: Nenhuma.
% Saída: Nenhuma.
% Pré-Condicao: Nenhuma.
% Pós-Condicao: Chama a operação escolhida (carregar arquivo ou sair).
% -----------------------------------------------------------------------

:- dynamic cidade_inicial/1.
:- dynamic cidade_final/1.
:- dynamic ligacao/3.
:- dynamic arquivo_carregado/1.

main_menu :-
    writeln('--- MENU PRINCIPAL ---'),
    writeln('1 - Carregar arquivo mapa txt'),
    writeln('0 - Sair'),
    read_line_to_string(user_input, Option),
    handle_main_option(Option).

% -----------------------------------------------------------------------
% Função: handle_main_option
% Descrição: Trata as opções escolhidas no menu principal.
% Entrada: Option (string lida do usuário).
% Saída: Nenhuma.
% Pré-Condicao: Nenhuma.
% Pós-Condicao: Executa a ação correspondente (carregar arquivo, sair ou mostrar erro).
% -----------------------------------------------------------------------

handle_main_option("1") :-
    load_map_file.
handle_main_option("0") :-
    writeln('Saindo do programa.'),
    halt.
handle_main_option(_) :-
    writeln('Opcao invalida!'),
    main_menu.

% -----------------------------------------------------------------------
% Função: second_menu
% Descrição: Exibe o segundo menu de operações após o arquivo de mapa ter sido carregado.
% Entrada: FilePath (string com o caminho do arquivo carregado).
% Saída: Nenhuma.
% Pré-Condicao: O arquivo de mapa já deve ter sido carregado.
% Pós-Condicao: Chama a operação escolhida (carregar outro arquivo, DFS, Dijkstra ou sair).
% -----------------------------------------------------------------------

second_menu(FilePath) :-
    writeln('--- MENU DE OPERACOES ---'),
    writeln('1 - Carregar outro arquivo mapa txt'),
    writeln('2 - Executar Depth-First Search (todos os trajetos)'),
    writeln('3 - Executar Dijkstra (melhor caminho)'),
    writeln('0 - Sair'),
    read_line_to_string(user_input, Option),
    handle_second_option(Option, FilePath).

% -----------------------------------------------------------------------
% Função: handle_second_option
% Descrição: Trata as opções escolhidas no segundo menu de operações.
% Entrada: Option (string), FilePath (string).
% Saída: Nenhuma.
% Pré-Condicao: Nenhuma.
% Pós-Condicao: Executa a operação correspondente.
% -----------------------------------------------------------------------

handle_second_option("1", _) :-
    load_map_file.
handle_second_option("2", FilePath) :-
    writeln('Executando Depth-First Search (todos os trajetos)'),
    dfs_all_paths,
    second_menu(FilePath).
handle_second_option("3", FilePath) :-
    writeln('Executando Dijkstra (melhor caminho)'),
    dijkstra_best_path,
    second_menu(FilePath).
handle_second_option("0", _) :-
    writeln('Saindo do programa.'),
    halt.
handle_second_option(_, FilePath) :-
    writeln('Opcao invalida!'),
    second_menu(FilePath).

% -----------------------------------------------------------------------
% Função: load_map_file
% Descrição: Solicita ao usuário o caminho do arquivo mapa e carrega o arquivo consultando-o.
% Entrada: Nenhuma.
% Saída: Nenhuma.
% Pré-Condicao: Nenhuma.
% Pós-Condicao: Arquivo é carregado e as regras do mapa são adicionadas ao banco de dados dinâmico do Prolog.
% -----------------------------------------------------------------------

load_map_file :-
    writeln('Digite o caminho do arquivo mapa txt (Caminho: C:/Users/SeuUsuario/Documentos/mapa.txt):'),
    write("Caminho: "),
    read_line_to_string(user_input, FilePath),
    (carregar_mapa(FilePath) -> true ; writeln('Falha ao carregar o arquivo.')),
    second_menu(FilePath).

% -----------------------------------------------------------------------
% Função: carregar_mapa
% Descrição: Carrega o arquivo de mapa fornecido, consultando-o para inserir os fatos no banco de dados.
% Entrada: FilePath (string com o caminho do arquivo).
% Saída: true se o carregamento for bem-sucedido; false caso contrário.
% Pré-Condicao: O arquivo de texto deve existir e estar no formato correto.
% Pós-Condicao: As regras presentes no arquivo são carregadas na memória Prolog.
% -----------------------------------------------------------------------

carregar_mapa(FilePath) :-
    (   arquivo_carregado(_)
    ->  retractall(cidade_inicial(_)),
        retractall(cidade_final(_)),
        retractall(ligacao(_,_,_)),
        retractall(arquivo_carregado(_))
    ;   true
    ),
    (   exists_file(FilePath)
    ->  catch(
            consult(FilePath),
            Error,
            (format('Erro ao carregar o arquivo: ~w~n', [Error]), fail)
        ),
        assertz(arquivo_carregado(FilePath)),
        writeln('Arquivo carregado com sucesso!')
    ;   writeln('Arquivo nao encontrado! Verifique o caminho e tente novamente.'), fail
    ).


% -----------------------------------------------------------------------
% Função: dfs_all_paths
% Descrição: Executa a busca em profundidade (DFS) para encontrar todos os trajetos possíveis entre a cidade inicial e a cidade final.
% Entrada: Nenhuma.
% Saída: Nenhuma (imprime os trajetos encontrados).
% Pré-Condicao: O arquivo de mapa já deve ter sido carregado e definido cidade_inicial e cidade_final.
% Pós-Condicao: Exibe na tela todos os caminhos possíveis e suas distâncias.
% -----------------------------------------------------------------------

dfs_all_paths :-
    ( cidades_existem ->
        cidade_inicial(CidadeIni),
        cidade_final(CidadeFim),
        findall((Caminho, Distancia),
                dfs(CidadeIni, CidadeFim, [CidadeIni], Caminho, 0, Distancia),
                ListaTrajetos),
        imprimir_todos_os_caminhos(ListaTrajetos)
    ;
        writeln('Nao e possivel executar a busca. Retornando ao menu.')
    ).

% -----------------------------------------------------------------------
% Função: dfs
% Descrição: Algoritmo de busca em profundidade (DFS) recursivo para encontrar caminhos entre duas cidades.
% Entrada:
%    CidadeAtual (cidade em que está no momento),
%    CidadeFinal (cidade destino),
%    Visitados (lista de cidades já percorridas),
%    Caminho (variável que recebe o caminho completo),
%    DistanciaAcc (distância acumulada até o momento),
%    DistanciaTotal (distância total do caminho encontrado).
% Saída: Caminho e DistanciaTotal.
% Pré-Condicao: Deve existir ao menos um caminho entre CidadeAtual e CidadeFinal.
% Pós-Condicao: Retorna todos os caminhos possíveis entre as cidades.
% -----------------------------------------------------------------------

dfs(CidadeFim, CidadeFim, Visitados, Caminho, DistanciaTotal, DistanciaTotal) :-
    reverse(Visitados, Caminho).

dfs(CidadeAtual, CidadeFim, Visitados, Caminho, DistanciaAcc, DistanciaTotal) :-
    ligacao(CidadeAtual, ProximaCidade, Distancia),
    \+ member(ProximaCidade, Visitados),
    NovoAcc is DistanciaAcc + Distancia,
    dfs(ProximaCidade, CidadeFim, [ProximaCidade|Visitados], Caminho, NovoAcc, DistanciaTotal).

% -----------------------------------------------------------------------
% Função: imprimir_todos_os_caminhos
% Descrição: Imprime todos os trajetos encontrados pela DFS.
% Entrada: ListaTrajetos (lista de pares (Caminho, Distancia)).
% Saída: Nenhuma.
% Pré-Condicao: ListaTrajetos deve estar preenchida.
% Pós-Condicao: Todos os trajetos são impressos na tela.
% -----------------------------------------------------------------------

imprimir_todos_os_caminhos([]) :-
    writeln('Nao ha trajetos possiveis entre a cidade inicial e a cidade final.').

imprimir_todos_os_caminhos(ListaTrajetos) :-
    imprimir_todos_os_caminhos(ListaTrajetos, 1).

imprimir_todos_os_caminhos([], _).
imprimir_todos_os_caminhos([(Caminho, Distancia)|T], N) :-
    format('Trajeto ~w:~n', [N]),
    format('Distancia Total: ~w~n', [Distancia]),
    imprimir_caminho(Caminho),
    nl,
    N1 is N + 1,
    imprimir_todos_os_caminhos(T, N1).

% -----------------------------------------------------------------------
% Função: imprimir_caminho
% Descrição: Imprime no formato cidade -> cidade -> cidade.
% Entrada: Caminho (lista de cidades).
% Saída: Nenhuma.
% Pré-Condicao: Caminho deve ser uma lista de átomos representando cidades.
% Pós-Condicao: Caminho é exibido na tela.
% -----------------------------------------------------------------------

imprimir_caminho([H]) :-
    format('~w', [H]).
imprimir_caminho([H|T]) :-
    format('~w -> ', [H]),
    imprimir_caminho(T).

% -----------------------------------------------------------------------
% Função: dijkstra_best_path
% Descrição: Executa o algoritmo de Dijkstra para encontrar o menor caminho entre a cidade inicial e a cidade final.
% Entrada: Nenhuma.
% Saída: Nenhuma (imprime o melhor trajeto encontrado).
% Pré-Condicao: O arquivo de mapa já deve ter sido carregado e definido cidade_inicial e cidade_final.
% Pós-Condicao: Exibe o menor trajeto encontrado e sua distância.
% -----------------------------------------------------------------------

dijkstra_best_path :-
    ( cidades_existem ->
        cidade_inicial(CidadeIni),
        cidade_final(CidadeFim),
        dijkstra(CidadeIni, CidadeFim, Caminho, Distancia),
        format('Melhor trajeto encontrado pelo Dijkstra:~n'),
        format('Distancia Total: ~w~n', [Distancia]),
        imprimir_caminho(Caminho),
        nl
    ;
        writeln('Nao e possivel executar a busca. Retornando ao menu.')
    ).

% -----------------------------------------------------------------------
% Função: dijkstra
% Descrição: Algoritmo principal de Dijkstra. Inicia a busca partindo da cidade de origem.
% Entrada:
%    Origem (cidade inicial),
%    Destino (cidade final),
%    Caminho (variável que recebe o melhor caminho),
%    Distancia (variável que recebe a distância total).
% Saída: Caminho e Distancia.
% Pré-Condicao: Deve existir pelo menos um caminho entre Origem e Destino.
% Pós-Condicao: Retorna o menor caminho e sua distância.
% -----------------------------------------------------------------------

dijkstra(Origem, Destino, Caminho, Distancia) :-
    dijkstra_rec([(0,[Origem])], Destino, [], CaminhoInv, Distancia),
    reverse(CaminhoInv, Caminho).

% -----------------------------------------------------------------------
% Função: dijkstra_rec
% Descrição: Implementação recursiva do algoritmo de Dijkstra. Explora os caminhos com menor custo acumulado primeiro.
% Entrada:
%    ListaCaminhos (lista de caminhos atuais, cada um no formato (Custo, CaminhoInvertido)),
%    Destino (cidade destino),
%    Visitados (lista de cidades já visitadas),
%    Caminho (variável que recebe o melhor caminho invertido),
%    Distancia (variável que recebe a distância total).
% Saída: Caminho e Distancia.
% Pré-Condicao: Deve existir pelo menos um caminho entre Origem e Destino.
% Pós-Condicao: Retorna o menor caminho e sua distância.
% -----------------------------------------------------------------------

dijkstra_rec([ (Distancia,[Destino|Rota]) | _ ], Destino, _, [Destino|Rota], Distancia).

dijkstra_rec([ (_,[CidadeAtual|_]) | OutrosCaminhos ], Destino, Visitados, Caminho, Distancia) :-
    member(CidadeAtual, Visitados), !,
    dijkstra_rec(OutrosCaminhos, Destino, Visitados, Caminho, Distancia).

dijkstra_rec([ (CustoAtual,[CidadeAtual|Rota]) | OutrosCaminhos ], Destino, Visitados, Caminho, Distancia) :-
    findall(
        (NovoCusto, [ProxCidade,CidadeAtual|Rota]),
        ( ligacao(CidadeAtual, ProxCidade, CustoLigacao),
          \+ member(ProxCidade, [CidadeAtual|Rota]),
          NovoCusto is CustoAtual + CustoLigacao
        ),
        NovosCaminhos
    ),
    append(OutrosCaminhos, NovosCaminhos, TodosCaminhos),
    sort(TodosCaminhos, CaminhosOrdenados), % Ordena pelo custo crescente
    dijkstra_rec(CaminhosOrdenados, Destino, [CidadeAtual|Visitados], Caminho, Distancia).

% -----------------------------------------------------------------------
% Função: cidades_existem
% Descrição: Verifica se cidade_inicial e cidade_final existem no grafo.
% Entrada: Nenhuma.
% Saída: true se ambas existirem; false caso contrário.
% Pré-Condicao: As cidades inicial e final devem ter sido definidas.
% Pós-Condicao: Exibe mensagem se alguma cidade não existir no grafo.
% -----------------------------------------------------------------------

cidades_existem :-
    cidade_inicial(CidadeIni),
    cidade_final(CidadeFim),
    ( cidade_existe(CidadeIni) -> true ;
      format('Cidade inicial (~w) nao existe nas ligacoes.~n', [CidadeIni]),
      fail
    ),
    ( cidade_existe(CidadeFim) -> true ;
      format('Cidade final (~w) nao existe nas ligacoes.~n', [CidadeFim]),
      fail
    ).

% -----------------------------------------------------------------------
% Função: cidade_existe
% Descrição: Verifica se uma cidade aparece em pelo menos uma ligação.
% Entrada: Cidade (átomo).
% Saída: true se a cidade existir em alguma ligação.
% Pré-Condicao: Nenhuma.
% Pós-Condicao: Nenhuma.
% -----------------------------------------------------------------------

cidade_existe(Cidade) :-
    ligacao(Cidade, _, _) ;
    ligacao(_, Cidade, _).

% -----------------------------------------------------------------------
% Função: initialization(main_menu)
% Descrição: Ponto de entrada do programa. Executa o menu principal ao iniciar o programa Prolog.
% Entrada: Nenhuma.
% Saída: Nenhuma.
% Pré-Condicao: Nenhuma.
% Pós-Condicao: O programa é iniciado e exibe o menu principal.
% -----------------------------------------------------------------------

:- initialization(main_menu).