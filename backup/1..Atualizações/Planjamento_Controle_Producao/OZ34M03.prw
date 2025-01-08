#include "totvs.ch"
#include "protheus.ch"
#include "rwmake.ch"
#include "fwmvcdef.ch"
#include "fweditpanel.ch"
#include "tbiconn.ch"
#include "ozminerals.ch"

#define STATUS_RECORD    		     1
#define STATUS_NO_RECORD 		     2

/*/{Protheus.doc} OZ34M03

    Executa alteracao dos Parametros Pelo Usuario Contabil!
	Esta Rotina permite que os usuários não	façam lançamentos com periodo fechado!
	Será permitido reabri-lo, alterando os parametros!

@type function
@version  1.0
@author Fábio Santos 
@since 21/10/2023

@Obs
    MV_DATAFIN = Financeiro
    MV_DATAFIS = FIscal/Compras
    MV_DBLQMOV = FIscal/Compras

@see OZGEN18

@nested-tags:Frameworks/OZminerals
/*/
User Function OZ34M03()
	Local aSays        		    := {}  as array
	Local aButtons     		    := {}  as array
	Local nOpca        		    := 0   as numeric
	Local cTitoDlg     		    := ""  as character

	Private lFiltrado           := .F. as logical
	Private lPrevDtEnt          := .T. as Logical
	Private cDataFechamento     := ""  as character
	Private cDtUltFechamento    := ""  as character
	Private cSintaxeRotina      := ""  as character
	Private dDtaFinAtual        := ""  as character
	Private dDtaFisAtual        := ""  as character
	Private dDtaEstAtual        := ""  as character
	Private dDataFinAnterior    := ""  as character
	Private dDataFisAnterior    := ""  as character
	Private dDataEstAnterior    := ""  as character
	Private cFisDtUltFechamento := ""  as character
	Private cFinDtUltFechamento := ""  as character
	Private cEstDtUltFechamento := ""  as character

	dDtaFinAtual                := GetMv("MV_DATAFIN")
	dDtaFisAtual                := GetMv("MV_DATAFIS")
	dDtaEstAtual                := GetMv("MV_DBLQMOV")
	dDataFinAnterior            := GetMv("MV_DATAFIN")
	dDataFisAnterior            := GetMv("MV_DATAFIS")
	dDataEstAnterior            := GetMv("MV_DBLQMOV")

	cDataFechamento             := GetNewPar("MV_ULMES","20230930")
	cSintaxeRotina              := ProcName(0)

	cTitoDlg    	            := "Bloqueio de Movimentação Apos Fechamento contabil - OzMinerals"
	cDataFechamento             := GetNewPar("MV_ULMES","20230930")
	cDtUltFechamento            := Substr(Dtos(cDataFechamento),7,2)
	cDtUltFechamento            += "/" + Substr(Dtos(cDataFechamento),5,2)
	cDtUltFechamento            += "/" + Substr(Dtos(cDataFechamento),1,4)

	cFisDtUltFechamento         := Substr(Dtos(dDtaFisAtual),7,2)
	cFisDtUltFechamento         += "/" + Substr(Dtos(dDtaFisAtual),5,2)
	cFisDtUltFechamento         += "/" + Substr(Dtos(dDtaFisAtual),1,4)

	cFinDtUltFechamento         := Substr(Dtos(dDtaFinAtual),7,2)
	cFinDtUltFechamento         += "/" + Substr(Dtos(dDtaFinAtual),5,2)
	cFinDtUltFechamento         += "/" + Substr(Dtos(dDtaFinAtual),1,4)

	cEstDtUltFechamento         := Substr(Dtos(dDtaEstAtual),7,2)
	cEstDtUltFechamento         += "/" + Substr(Dtos(dDtaEstAtual),5,2)
	cEstDtUltFechamento         += "/" + Substr(Dtos(dDtaEstAtual),1,4)

	aAdd(aSays, "Esta rotina tem por objetivo Gerar o bloqueio nos modulos Estoque, Financeiro, ")
	aAdd(aSays, "Faturamento, Compras e Fiscal com a data nos 3 parametros abaixo:")
	aAdd(aSays, "MV_DATAFIN = "+cFinDtUltFechamento+" / MV_DATAFIS = "+cFisDtUltFechamento+" / MV_DBLQMOV = "+cEstDtUltFechamento+" ")
	aAdd(aSays, "A data do Ultimo fechamento de estoque foi em "+cDtUltFechamento+" - Parametro MV_ULMES!")

	aAdd(aButtons,{STATUS_RECORD   , .T., {|o| nOpca := STATUS_RECORD   , FechaBatch()}})
	aAdd(aButtons,{STATUS_NO_RECORD, .T., {|o| nOpca := STATUS_NO_RECORD, FechaBatch()}})

	FormBatch(cTitoDlg, aSays, aButtons)

	If ( nOpca == STATUS_RECORD )

		lFiltrado := PerguntaParametro()

		If lFiltrado
			If ( DtoS(MV_PAR01) < DtoS(cDataFechamento))
        		If ( MsgYesNo("Atenção! Data informada no parametro e inferior a data do ultimo fechamento, Confirma bloqueios a serem realizados ?",GRP_GROUP_NAME))
            		FWMsgRun(,{|| GravaFechamentoParamentros() } ,"Processando Bloqueios ...","Aguarde")
                EndIf 
            Else
				FWMsgRun(,{|| GravaFechamentoParamentros() } ,"Processando Bloqueios ...","Aguarde")
			EndIf
		Else
			Return
		Endif
	EndIf

Return

/*
	Executa a alteração nos parametros para fechamento 
*/
Static Function GravaFechamentoParamentros()
	Local lDataFin          := .F. as logical
	Local lDataFis          := .F. as logical
	Local lDataEst          := .F. as logical
	Local cFinMvPar01       := ""  as character
	Local cFisMvPar02       := ""  as character
	Local cEstMvPar03       := ""  as character
	Local cLogAlteracao     := ""  as character
	Local cLogTentativa     := ""  as character
    Local cLogSucesso       := ""  as character

	dbSelectArea("SX6")
	dbSetOrder(1)

	If ( !Empty(Dtos(MV_PAR01)) .And. Dtos(MV_PAR01) <= Dtos(dDatabase))
		lDataFin := .T.
	EndIf 

    If ( !Empty(Dtos(MV_PAR02)) .And. Dtos(MV_PAR02) <= Dtos(dDatabase))
		lDataFis := .T.
	EndIf

    If ( !Empty(Dtos(MV_PAR03)) .And. Dtos(MV_PAR03) <= Dtos(dDatabase))
		lDataEst := .T.
	EndIf 

	cFinMvPar01      := Substr(Dtos(MV_PAR01),7,2)
	cFinMvPar01      += "/" + Substr(Dtos(MV_PAR01),5,2)
	cFinMvPar01      += "/" + Substr(Dtos(MV_PAR01),1,4)
	cFisMvPar02      := Substr(Dtos(MV_PAR02),7,2)
	cFisMvPar02      += "/" + Substr(Dtos(MV_PAR02),5,2)
	cFisMvPar02      += "/" + Substr(Dtos(MV_PAR02),1,4)
	cEstMvPar03      := Substr(Dtos(MV_PAR03),7,2)
	cEstMvPar03      += "/" + Substr(Dtos(MV_PAR03),5,2)
	cEstMvPar03      += "/" + Substr(Dtos(MV_PAR03),1,4)

	cLogAlteracao    := "Bloqueio Financeiro :" + CRLF
	cLogAlteracao    += "Será Alterado de   : " + cFinDtUltFechamento + CRLF
	cLogAlteracao    += "Será Alterado para : " + cFinMvPar01 + CRLF
	cLogAlteracao    += " " + CRLF
	cLogAlteracao    += "Bloqueio Fiscal :" + CRLF
	cLogAlteracao    += "Será Alterado de   : " + cFisDtUltFechamento + CRLF
	cLogAlteracao    += "Será Alterado para : " + cFisMvPar02 + CRLF
	cLogAlteracao    += " " + CRLF
	cLogAlteracao    += "Bloqueio Movimentação Estoque:" + CRLF
	cLogAlteracao    += "Será Alterado de   : " + cEstDtUltFechamento + CRLF
	cLogAlteracao    += "Será Alterado para : " + cEstMvPar03 + CRLF

	If ( lDataFin .Or. lDataFis .Or. lDataEst )

		If ( MsgYesNo("Confirma bloqueios a serem realizados ?",GRP_GROUP_NAME))

			If ( lDataFin )
				PutMV("MV_DATAFIN",  Dtos(MV_PAR01))
			EndIf

			If ( lDataFis )
				PutMV("MV_DATAFIS",  Dtos(MV_PAR02))
			EndIf

			If ( lDataEst )
				PutMV("MV_DBLQMOV",  Dtos(MV_PAR03))
			EndIf

    		cLogSucesso := "Data de bloquieo Realizado com sucesso!!!" + CRLF  
            cLogSucesso += "Analisar alterações abaixo:" + CRLF  
            Aviso("Atenção !!!" ,cLogSucesso + cLogAlteracao,{"OK"})
		EndIf
	Else
        cLogTentativa := "As Datas de bloquieos não podem ser maior que a data base do Sistema!!!" + CRLF  
        cLogTentativa += "Analisar os parametros abaixo e a database do sistema!" + CRLF  
		Aviso("Atenção !!!" ,cLogTentativa + cLogAlteracao ,{"OK"})
	EndIf

Return Nil

/*
    Carrega perguntas da rotina PARAMBOX
*/
Static Function PerguntaParametro() As Logical
	Local   lRet        := .F. as logical
	Local   aPergunta   := {}  as array
	Local   aRetorno    := {}  as array
	Local   dFinData    := ""  as character
	Local   dFisData    := ""  as character
	Local   dEstData    := ""  as character

	dFinData    		:= dDataBase
	dFisData    		:= dDataBase
	dEstData     		:= dDataBase

	aAdd( aPergunta , { 1, "Dt. Bloqueio Financeiro: " , dFinData    , "@ 99/99/9999"          , ".T.",       , ".T.", 50    , .T. } )
	aAdd( aPergunta , { 1, "Dt. Bloqueio Fiscal:     " , dFisData    , "@ 99/99/9999"          , ".T.",       , ".T.", 50    , .T. } )
	aAdd( aPergunta , { 1, "Dt. Bloqueio Mov.Estoque:" , dEstData    , "@ 99/99/9999"          , ".T.",       , ".T.", 50    , .T. } )

	If ( ParamBox(aPergunta ,"Parametros ",aRetorno, /*4*/, /*5*/, /*6*/, /*7*/, /*8*/, /*9*/, /*10*/, .F.))

		If ( ValType(aRetorno[01]) != "D" )
			Mv_Par01 := CtoD(aRetorno[01])
		EndIf

		If ( ValType(aRetorno[02]) != "D" )
			Mv_Par02 := CtoD(aRetorno[02])
		EndIf

		If ( ValType(aRetorno[03]) != "D" )
			Mv_Par02 := CtoD(aRetorno[03])
		EndIf

		lRet := .T.
	EndIf

Return lRet
