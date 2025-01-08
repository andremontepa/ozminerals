#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "fileio.ch"

/*/{Protheus.doc} APIValChv
Classe responsavel por realizar a validação da chave nos codigos fonte comercializados.
@type class 
@author Ricardo Tavares Ferreira
@since 15/05/2021
@version 12.1.27
@history 15/05/2021, Ricardo Tavares Ferreira, Construção Inicial
/*/
//=============================================================================================================================
    Class APIValChv from LongNameClass
//=============================================================================================================================

    Data cFuncName as String

    Method New(cFuncName) Constructor

EndClass

 /*/{Protheus.doc} New
Metodo New construtor da Classe.
@type Method 
@author Ricardo Tavares Ferreira
@since 28/03/2021
@version 12.1.27
@param cIdServ, character, Id do serviço cadastrado na tabela ZR0.
@param cItemServ, character, Codigo do Item do serviço cadastrado na tabelas ZR0.
@param cIdUser, character, Codigo do Ususario.
@param cOper, character, Tipo da operação executada.
@param cCompany, character, Codigo da Empresa passado como parametro.
@param cBranch, character, Codigo da filial passada como parametro.
@param aTab, array, Array contendo as tabelas executadas neste processo.
@return object, Retorna o Objeto da Classe
@history 28/03/2021, Ricardo Tavares Ferreira, Construção Inicial
/*/
//=============================================================================================================================
    Method New(cFuncName) Class APIValChv
//=============================================================================================================================

    ::cFuncName   := cFuncName
Return Self
