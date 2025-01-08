#include "protheus.ch"
#include "topconn.ch"
#include "rwmake.ch"
#include 'parmtype.ch'

/*/{Protheus.doc} API97M01
Função que atualiza tabelas e campos na base de dados
@type function 
@author Ricardo Tavares Ferreira
@since 28/03/2021
@history 28/03/2021, Ricardo Tavares Ferreira, Construção Inicial.
@version 12.1.27
/*/
//=============================================================================================================================
    User Function API97M01()
//=============================================================================================================================
 
    Local lConfirm := .F.
    Local cPerg    := "API97M01

    Private oSay   := Nil

    While .T.
        ValidPerg(cPerg)
		If Pergunte(cPerg,.T.)
            lConfirm := .T.
            Exit
		Else
			If MsgNoYes("Foi detectado o cancelamento do preechimento dos parametros. Deseja realmente sair da impressao do Relatorio ( Sim | Nao )?","A T E N C A O !!!")
				Return Nil
			EndIf
		EndIf
	End

    If lConfirm
        FWMsgRun(,{|oSay| ProcAlt(oSay)},"Processamento de Dicionário de Dados","Compatibilizando informações para a tabela selecionada...")
    EndIf
Return Nil

/*/{Protheus.doc} ProcAlt
Processa a alteração no dicionario de Dados
@type function 
@author Ricardo Tavares Ferreira
@since 28/03/2021
@param oSay, object, Objeto da barra de progressao.
@history 28/03/2021, Ricardo Tavares Ferreira, Construção Inicial.
@version 12.1.27
/*/
//=============================================================================================================================
    Static Function ProcAlt(oSay)
//=============================================================================================================================
 
    Local nX        := 0 
    Local aAlias    := {}
    Local cMsgAux   := ""

    aAlias := StrTokArr(Upper(Alltrim(MV_PAR01)), "/" )

    If Len(aAlias) > 0
        __SetX31Mode(.F.)

        For nX := 1 To Len(aAlias)
            //ChkFile(aAlias[nX])
            X31UpdTable(aAlias[nX])

            //Se houve Erro na Rotina
            If __GetX31Error()
                cMsgAux := "Houveram erros na atualização da tabela "+aAlias[nX]+":"+Chr(13)+Chr(10)
                cMsgAux += __GetX31Trace()
                MsgInfo(cMsgAux,"Atenção")
                cMensagem := Alltrim(cMsgAux)
		        APIUtil():ConsoleLog("API97M01|ProcAlt",cMensagem,3)
            EndIf
            DbSelectArea(aAlias[nX])
        Next nX 
        __SetX31Mode(.T.)
    Else 
        MsgInfo("Parametro não Preenchido","Atenção")
        cMensagem := "Parametro nao Preenchido."
		APIUtil():ConsoleLog("API97M01|ProcAlt",cMensagem,3)
    EndIf
Return Nil

/*/{Protheus.doc} ValidPerg
Criacao das Perguntas da Rotina.
@type function 
@author Ricardo Tavares Ferreira
@since 28/03/2021
@param cPerg, character, Codigo do Grupo de Perguntas
@history 28/03/2021, Ricardo Tavares Ferreira, Construção Inicial.
@version 12.1.27
/*/
//=============================================================================================================================
    Static Function ValidPerg(cPerg)
//=============================================================================================================================
 
    Local aTam		:= {}
	Local aHelpPor	:= {}

    aTam 		:= TamSx3("F1_CHVNFE")
	aHelpPor 	:= {}
	aAdd(aHelpPor,"Informe as Tabelas que vai ser ") 
    aAdd(aHelpPor," utilizadas na Atualização") 
    aAdd(aHelpPor," Tabelas Separadas por '/'") 
	APIUtil():CarregaParametros(cPerg,"01","Alias das Tabelas","","","MV_CH01",aTam[3],aTam[1],aTam[2],0,"G","","","","","MV_PAR01","","","","","","","","","","","","","","","","",aHelpPor,{},{}) 
Return