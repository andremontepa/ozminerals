#INCLUDE "PROTHEUS.CH"
/*
--------------OK - 01 - Tratar campos Virtuais.
--------------OK - 02 - Buscar função que retorna o indice da tabela passada como parametro.
--------------OK - 03 - Incluir a PK na consulta retorno.
--------------OK - 04 - Tratar o filtro de PK quando utilizado.
--------------OK - 05 - Verificar o motivo do arquivo SQL nao estar sendo salvo na pasta. (Falha ao criar o arquivo).
06 - Criar os Pontos de Entrada nas rotinas que tenha API para salvar os registros deletados.
07 - Para bases que sejam cloud criar pontos de entrada para salvar os dados de data e hora de alteração.
--------------OK - 08 - Criar a Tabela e Rotina para o cadastro de APIs.
--------------OK - 09 - Criar 2 Consultas padrao para colocar nas rotinas de usuario de api e configuração de campos api.
--------------OK - 10 - Criar o metodo que valida a operação que esta sendo executada pelo usuario.
--------------OK - 11 - Tratar as operaçoes quando o metodo possuir cabeçalho e grid. (Tratar para cada caso).
--------------OK - 12 - Verificar o motivo do ExecAuto estar excluindo os 2 itens do pedido quando manda somente 1. (Solução Mudar Metodo de Gravação das Informaçoes para MVC.
--------------OK - 13 - Criar o ponto de entrada que salva a exclusao da SC item a Item.
--------------OK - 14 - Nas operaçoes de POST/PUT/DELETE retornar o json ao inves da mensagem.
--------------OK - 15 - Criar um parametro para controlar o filtro de Filial das consultas (analisar o impacto dessa alteração nos metodos POST/PUT/DELETE. 
--------------OK - 16 - Construir a opção de salvamento do console.log local.
--------------OK - 17 - Contruir um Metodo que valida o Filtro enviado como paramentro para identificar possiveis erros de campos errados e Scripts de SQL maliciosos.
*/
