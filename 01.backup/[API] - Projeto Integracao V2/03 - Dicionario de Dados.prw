#INCLUDE "PROTHEUS.CH"
/*
Documentação dos dados necessarios para implementação.

1. Parametros
    1.1. AP_JSORMSG
        a. Tipo - Lógico 
        b. Descrição - Define se para os Metódos PUT/POST/DELETE retorna uma mensagem de confirmação, 
           ou o Json que foi enviado pos execução do metódo;
        c. Default - .T.
    1.2. AP_FFILIAL
        a. Tipo - Lógico 
        b. Descrição - Define se filtra a filial passada na requisição no momento da busca dos dados;
        c. Default - .T.
    1.3. AP_VLDUSR
        a. Tipo - Lógico
        b. Descrição - Define se realiza a validação de usuário antes de executar os metódo GET/PUT/POST/DELETE, 
           verificando se o usuário enviado no token tem permissão de executar os metódo;
        c. Default - .T.
    1.4. AP_DIRGRVA
        a. Tipo - Caracter
        b. Descrição - Define a pasta onde será salvo os dados da query executada na busca dos dados do Metódo GET,
           por ser execução via JOB a pasta tem que ser criada dentro do protheus_data;
        c. Default - \sql_api
    1.5. AP_CHARESP
        a. Tipo - Lógico
        b. Descrição - Define se retira do retorno da requisição os caracteres especiais do Json;
        c. Default - .F.
    1.6. AP_GRVLOG
        a. Tipo - Numérico
        b. Descrição - Define onde o log de integração é salvo sendo: 1=Console.log padrão do sistema, 2=Console customizado
           gerado pela rotina e definida em uma pasta definida pelo cliente;
        c. Default - 1
    1.7. AP_DIRGLOG
        a. Tipo - Caracter
        b. Descrição - Diretório onde será salvo o arquivo de log customizado, por ser execução via JOB a pasta tem que 
           ser criada dentro do protheus_data;
        c. Default - \log_api
    1.8. AP_MODLOGP
        a. Tipo - Numérico
        b. Descrição - Se o parametro AP_GRVLOG for igual a 1 define o tipo de log gravado no console.log padrão do sistema
           sendo 1=Conout, 2=FWLogMsg, para que o log seja apresentado na opção 2, é necessário adicionar no appserver.ini 
           as seguintes chaves: FWLOGMSG_DEBUG=1 e FWTRACELOG=1
        c. Default - 1

2. Tabelas/Campos/Indices

3. Pontos de Entrada Mapeados
    3.1. Solicitação de Compras;
        3.1.1. MT110TOK - Responsável pela validação da GetDados da Solicitação de Compras.
        3.1.2. M110STTS - Inclusão de interface após gravar a solicitação.
        3.1.3. Processo 
            3.1.3.1. APIUtil():GravaDadosZR4() - Gravação de Registros Deletados;
            3.1.3.2. APIUtil():GravaDataHora() - Gravação de data e hora de registros alterados ou incluidos;
    
*/
