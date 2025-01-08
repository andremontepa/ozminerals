#include "protheus.ch"
#include "topconn.ch"

/*/{Protheus.doc} APIGrvZR4
Classe Responsavel por gravar os dados na Tabela ZR4.
@type class 
@author Ricardo Tavares Ferreira
@since 27/03/2021
@history 27/03/2021, Ricardo Tavares Ferreira, Construção Inicial
/*/
//=============================================================================================================================
    Class APIGrvZR4 From LongNameClass
//=============================================================================================================================
    
    Data cTabela        as Character
    Data lRegDeletado   as Logical

    Method GravaDados(aDados)       // Metodo responsavel por gravar os dados da tabela SC1 - Solicitação de Compras na tabela ZR4
    Method ExcutaGravacao(aDados)   // Metodo responsavel por executar a gravacao dos dados.
    Method Free()                   // Metodo responsável por resetar o objeto.
    Method New() Constructor        // Metodo Construtor da Classe.
EndClass

/*/{Protheus.doc} GravaSC1
Metodo responsavel por gravar os dados da tabela SC1 - Solicitação de Compras na tabela ZR4.
@type method 
@author Ricardo Tavares Ferreira
@return logical, Retorna de Gravou o registro corretamente.
@since 27/03/2021
@history 27/03/2021, Ricardo Tavares Ferreira, Construção Inicial.
@history 06/04/2021, Ricardo Tavares Ferreira, Alteração do Set de ordem dos indices, tratado para resolver o problema do retorno da PK na API.
/*/
//=============================================================================================================================
    Method GravaDados(aDados) Class APIGrvZR4
//=============================================================================================================================

    Local nX := 0

    If Len(aDados) <= 0
        APIUtil():ConsoleLog("APIGrvZR4|GravaDados","Array de Dados VAZIO. Não será possivel gravar as informações dos dados deletados",4)
        Return .F.
    Else 
        DbSelectArea("ZR4")
        ZR4->(DbSetOrder(2))
        For nX := 1 To Len(aDados)
            If ZR4->(DbSeek(aDados[nX][1]+aDados[nX][2]+aDados[nX][3]+aDados[nX][4]))
                RecLock("ZR4",.F.)
            Else
                RecLock("ZR4",.T.)
            EndIf
                ZR4->ZR4_FILIAL := aDados[nX][1]
                ZR4->ZR4_TABELA := aDados[nX][2]
                ZR4->ZR4_CODIGO := aDados[nX][3]
                ZR4->ZR4_ITEM   := aDados[nX][4]
                ZR4->ZR4_DATA   := aDados[nX][5]
                ZR4->ZR4_HORA   := StrTran(aDados[nX][6],":","")
                ZR4->ZR4_IDREG  := aDados[nX][7]
            ZR4->(MsUnlock())
            cMensagem := "Gravando registro ...: " +aDados[nX][1]+ "|" +aDados[nX][2]+ "|" +aDados[nX][3]+ "|" +aDados[nX][4]+ "|" +Dtoc(aDados[nX][5])+ "|" +StrTran(aDados[nX][6],":","")+ "|" +aDados[nX][7]+ " ..."
            APIUtil():ConsoleLog("APIGrvZR4|GravaSC1",cMensagem,1)
        Next nX 
    EndIf
Return .T. 

/*/{Protheus.doc} ExcutaGravacao
Metodo responsavel por executar a gravacao dos dados.
@type method 
@author Ricardo Tavares Ferreira
@version 12.1.27
@return logical, Retorna de Gravou o registro corretamente.
@since 27/03/2021
@history 27/03/2021, Ricardo Tavares Ferreira, Construção Inicial
/*/
//=============================================================================================================================
    Method ExcutaGravacao(aDados) Class APIGrvZR4
//=============================================================================================================================
    
    If ::cTabela == "SC1"
        If ::GravaDados(aDados)
            Return .T.
        Else 
            Return .F.
        EndIf 
    Else 
        /* Colocar na sequencia a gravação das demais tabelas */
    EndIf
    ::Free()
Return .T.

/*/{Protheus.doc} Free
Metodo responsável por resetar o objeto.
@type method 
@author Ricardo Tavares Ferreira
@since 27/03/2021
@version 12.1.27
@history 27/03/2021, Ricardo Tavares Ferreira, Construção Inicial
/*/
//====================================================================================================
    Method Free() Class APIGrvZR4
//====================================================================================================
    
    FWFreeObj(self)
Return Nil

/*/{Protheus.doc} New
Metodo New construtor da classe.
@type method 
@author Ricardo Tavares Ferreira
@since 27/03/2021
@version 12.1.27
@return object, Retorna o Objeto da Classe
@history 27/03/2021, Ricardo Tavares Ferreira, Construção Inicial
/*/
//=============================================================================================================================
    Method New(cTab,lRegDel) Class APIGrvZR4
//=============================================================================================================================
    
    Default cTab        := ""
    Default lRegDel     := .F.
    
    ::cTabela           := cTab
    ::lRegDeletado      := lRegDel
Return Self
