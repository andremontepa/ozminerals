#INCLUDE "PROTHEUS.CH"
/*
Data: 06.04.2021
    1. Feito uma Alteração nos indices da tabbela ZR4;
        1.1. Apagar os Indices existentes;
        1.2. Criar os seguintes indices na ordem descrita;
            1.2.1. ZR4_FILIAL+ZR4_TABELA+ZR4_CODIGO+ZR4_ITEM+ZR4_DATA+ZR4_HORA
            1.2.2. ZR4_FILIAL+ZR4_TABELA+ZR4_CODIGO+ZR4_ITEM
            1.2.3. ZR4_FILIAL+ZR4_IDREG
    
    2. Criação da Tabela ZR6 - Cadastro de APIs;

    3. Criação de Consultas Padrão do Cadastro de APIs;
        3.1. ZR6A - Regra Acesso - API;  
        3.2. ZR6B - Config. de Campos;
    
    4. Alteração dos Campos para a inclusão das consultas padrão Criadas;
        4.1. ZR0_SERV - ZR6A;
        4.2. ZR1_TABELA - ZR6B;
    */
