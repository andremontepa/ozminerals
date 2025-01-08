#INCLUDE "PROTHEUS.CH"
/*
Documenta��o dos dados necessarios para implementa��o.

1. Parametros
    1.1. AP_JSORMSG
        a. Tipo - L�gico 
        b. Descri��o - Define se para os Met�dos PUT/POST/DELETE retorna uma mensagem de confirma��o, 
           ou o Json que foi enviado pos execu��o do met�do;
        c. Default - .T.
    1.2. AP_FFILIAL
        a. Tipo - L�gico 
        b. Descri��o - Define se filtra a filial passada na requisi��o no momento da busca dos dados;
        c. Default - .T.
    1.3. AP_VLDUSR
        a. Tipo - L�gico
        b. Descri��o - Define se realiza a valida��o de usu�rio antes de executar os met�do GET/PUT/POST/DELETE, 
           verificando se o usu�rio enviado no token tem permiss�o de executar os met�do;
        c. Default - .T.
    1.4. AP_DIRGRVA
        a. Tipo - Caracter
        b. Descri��o - Define a pasta onde ser� salvo os dados da query executada na busca dos dados do Met�do GET,
           por ser execu��o via JOB a pasta tem que ser criada dentro do protheus_data;
        c. Default - \sql_api
    1.5. AP_CHARESP
        a. Tipo - L�gico
        b. Descri��o - Define se retira do retorno da requisi��o os caracteres especiais do Json;
        c. Default - .F.
    1.6. AP_GRVLOG
        a. Tipo - Num�rico
        b. Descri��o - Define onde o log de integra��o � salvo sendo: 1=Console.log padr�o do sistema, 2=Console customizado
           gerado pela rotina e definida em uma pasta definida pelo cliente;
        c. Default - 1
    1.7. AP_DIRGLOG
        a. Tipo - Caracter
        b. Descri��o - Diret�rio onde ser� salvo o arquivo de log customizado, por ser execu��o via JOB a pasta tem que 
           ser criada dentro do protheus_data;
        c. Default - \log_api
    1.8. AP_MODLOGP
        a. Tipo - Num�rico
        b. Descri��o - Se o parametro AP_GRVLOG for igual a 1 define o tipo de log gravado no console.log padr�o do sistema
           sendo 1=Conout, 2=FWLogMsg, para que o log seja apresentado na op��o 2, � necess�rio adicionar no appserver.ini 
           as seguintes chaves: FWLOGMSG_DEBUG=1 e FWTRACELOG=1
        c. Default - 1

2. Tabelas/Campos/Indices

3. Pontos de Entrada Mapeados
    3.1. Solicita��o de Compras;
        3.1.1. MT110TOK - Respons�vel pela valida��o da GetDados da Solicita��o de Compras.
        3.1.2. M110STTS - Inclus�o de interface ap�s gravar a solicita��o.
        3.1.3. Processo 
            3.1.3.1. APIUtil():GravaDadosZR4() - Grava��o de Registros Deletados;
            3.1.3.2. APIUtil():GravaDataHora() - Grava��o de data e hora de registros alterados ou incluidos;
    
*/
