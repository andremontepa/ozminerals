//Bibliotecas
#Include "Totvs.ch"
#Include "Protheus.ch"
#Include "FWMVCDef.ch"
#INCLUDE "topconn.ch"

/*/{Protheus.doc} User Function MATA094
P.E da Aprovação de Documentos
@author LUCAS PEREIRA DA COSTA
@since 08/01/2021
@version 1.0
@type function
@history 19/08/2024, Adalberto Mendes, utilização do parametro OZ_VLDPRIO no ponto de entrada FORMCOMMITTTSPOS
		na condição SC1->C1_XPRIORI $ cMVVALID  para query na SCR
@history 21/08/2024, Adalberto, compilando para ambiente OZTESTE
/*/

User Function MATA094()
	Local aArea 	:= GetArea()
	Local aParam 	:= PARAMIXB
	Local xRet 		:= .T.
	Local oObj		:= Nil
	Local cIdPonto 	:= ""
	Local cIdModel 	:= ""
	Local cCodUsr  	:= ""
	Local aPass    	:= {}
	Local cQry, cQuery
	Local cMVVALID 	:= GetMv("OZ_VLDPRIO")

	Private cSc1Fil	:= SCR->CR_FILIAL
	Private cSc1Num := SCR->CR_NUM
	Private _cNivel := SCR->CR_NIVEL
	Private nStart  := 0

    //-- Toni Aguiar TOTVS STARSOFT em 08/03/2021
    //-- Valida se há ní­veis pendentes de aprovação.
    //-- Situação Paliativa até que o Chamado TOTVS n. 9999 se ja resolvido.
	PswOrder(2)
    PswSeek(cUserName)
    aPass   := PswRet(1)
    cCodUsr := aPass[1][1]

    cQuery:="SELECT * FROM "+RetSqlName("SAL")+" WHERE AL_FILIAL='"+xFilial("SAL")+"' AND AL_USER='"+cCodUsr+"' "
    cQuery+="   AND AL_XESTOQ = 'T' AND D_E_L_E_T_ = ' ' "
    ChangeQuery(cQuery)
    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"SALA",.T.,.T.)
    If !SALA->(Eof())
       cQry:="SELECT * FROM "+RetSqlName("SCR")+" WHERE CR_FILIAL='"+SCR->CR_FILIAL+"' AND CR_NUM='"+SCR->CR_NUM+"' "
       cQry+="AND CR_USER<>'"+cCodUsr+"' AND CR_NIVEL <> '"+_cNivel+"' AND CR_STATUS NOT IN ('03','05') AND CR_TIPO = 'SC' AND D_E_L_E_T_ = ' ' "
       ChangeQuery(cQry)
       dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"SCR1",.T.,.T.)
       If !SCR1->(Eof())
          Alert("Atenção! Ainda há aprovações pendentes.")
          SCR1->(dbCloseArea())
          SALA->(dbCloseArea())
          Return
       Endif
       SCR1->(dbCloseArea())
    Endif
    SALA->(dbCloseArea())
	//

	//Se tiver parametros
	If aParam != Nil
		//Pega informacoes dos parametros
		oObj := aParam[1]
		cIdPonto := aParam[2]
		cIdModel := aParam[3]
		//	Alert(cIdPonto + " " + cIdModel)

		//Antes da alteracao de qualquer campo do modelo ao aprovar
		If cIdPonto == "MODELVLDACTIVE"
			aGetAre := GetArea()
			aSCRAre := SCR->(GetArea())
			aCN9Are := CN9->(GetArea())

			If Alltrim(SCR->CR_TIPO) == "RV"
				cChvCN9 := SCR->CR_FILIAL + Left(SCR->CR_NUM,18)
				dbSelectArea("CN9")
				CN9->(dbSetOrder(01))
				If CN9->(dbSeek(cChvCN9))
					cChvSCR := CN9->CN9_FILIAL + "RV" + CN9->CN9_NUMERO + CN9->CN9_REVISA

					dbSelectArea("SCR")
					SCR->(dbSetOrder(01))
					If SCR->(dbSeek(Alltrim(cChvSCR)))
						Do While !SCR->(Eof()) .And. ;
							Alltrim(SCR->CR_FILIAL + SCR->CR_TIPO + SCR->CR_NUM) == Alltrim(cChvSCR)

							dbSelectArea("SCR")
							If SCR->(Reclock("SCR",.F.))
								SCR->CR_XDTINIC := CN9->CN9_DTINIC
								SCR->CR_XREVISA := CN9->CN9_REVISA
								SCR->CR_XDTFIM  := CN9->CN9_DTFIM
								SCR->CR_XDTREV  := CN9->CN9_DTREV
								SCR->CR_XSALDO  := CN9->CN9_SALDO
								SCR->CR_XVLINI  := CN9->CN9_VLINI
								SCR->CR_XVLATU  := CN9->CN9_VLATU
								SCR->CR_XVLADIT := CN9->CN9_VLADIT
								SCR->CR_XCODOBJ := Msmm(CN9->CN9_CODOBJ)
								SCR->CR_XCODCLA := Msmm(CN9->CN9_CODCLA)
								SCR->CR_XCODJUS	:= Msmm(CN9->CN9_CODJUS)
								SCR->CR_XGLOBA	:= CN9->CN9_XGLOBA
								SCR->(MsUnlock())
							EndIf

							SCR->(dbSkip())
						EndDo
					EndIf
				EndIf
			EndIf

			RestArea(aCN9Are)
			RestArea(aSCRAre)
			RestArea(aGetAre)

			xRet := .T.
			//Antes da alteracao de qualquer campo do formulario
		ElseIf cIdPonto == "FORMPRE"
			xRet := .T.
			//Na validacao total do modelo
		ElseIf cIdPonto == "MODELPOS"
			xRet := .T.
			//Na validacao total do formulario
		ElseIf cIdPonto == "FORMPOS"
			xRet := .T.
			//Antes da alteracao da linha do formulario FWFORMGRID
		ElseIf cIdPonto == "FORMLINEPRE"
			xRet := .T.
			//Na validacao total da linha do formulario FWFORMGRID
		ElseIf cIdPonto == "FORMLINEPOS"
			xRet := .T.
			//Apos a gravacao total do modelo e dentro da transacao
		ElseIf cIdPonto == "MODELCOMMITTTS"
			//Apos a gravacao total do modelo e fora da transacao
		ElseIf cIdPonto == "MODELCOMMITNTTS"
			//Antes da gravacao da tabela do formulario
		ElseIf cIdPonto == "FORMCOMMITTTSPRE"
			//Apos a gravacao da tabela do formulario
			// - Ismael Junior - 13/04/2021
			// - Rotina para geração de pediddo de compras automaticamente apôs a aprovação do ultimo usuário na alçada.
			// - A rotina não acionada apenas quando o campo C1_XPRIORI = 9 ou C. (Regularização)
			// *** Preparação Rotina de Regularização SC ***
		ElseIf cIdPonto == "FORMCOMMITTTSPOS"
			If SC1->C1_XPRIORI $ cMVVALID
			    If SELECT("SCR1")>0
			       SCR1->(dbCloseArea())
			    Endif

				cQry	:= "SELECT * FROM " 						+ CRLF
				cQry 	+= "	" + RetSqlName("SCR") +" " 			+ CRLF
				cQry 	+= "WHERE CR_FILIAL = '" + cSc1Fil + "' " 	+ CRLF
				cQry 	+= "	AND CR_NUM = '" + cSc1Num + "' " 	+ CRLF
				cQry	+= "	AND CR_USER <> '" + cCodUsr + "' " 	+ CRLF
				cQry 	+= "	AND CR_NIVEL <> '" + _cNivel + "' " + CRLF
				cQry 	+= "	AND CR_STATUS NOT IN ('03','05') " 	+ CRLF
				cQry 	+= "	AND CR_TIPO = 'SC' " 				+ CRLF
				cQry 	+= "	AND D_E_L_E_T_ = ' ' " 				+ CRLF

				ChangeQuery(cQry)
			    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"SCR1",.T.,.T.)

				If !Empty(SCR1->CR_NUM)
			    	Alert("Atenção! Ainda há aprovações pendentes.")
				    SCR1->(DbCloseArea())
			    Else
				    SCR1->(DbCloseArea())
			      	u_GPED94()
			    Endif
			Endif
			//No cancelamento do botao
		ElseIf cIdPonto == "MODELCANCEL"
			xRet := .T.
			//Para a inclusao de botoes na ControlBar
		ElseIf cIdPonto == "BUTTONBAR"
			xRet := {}
		EndIf
	EndIf
	RestArea(aArea)
Return xRet


// - Ismael Junior - 13/04/2021
// Função para geração do pedido apôs aprovação do último usuário dad alçada sempre que o campo C1_XPRIORI = 9 ou C.
// ****** Rotina de Regularização da SC ******
User FUnction GPED94()

Local aCabec 	:= {}
Local aItens 	:= {}
Local aLinha 	:= {}
Local aRatCC	:= {}
Local aRatPrj 	:= {}
Local cDoc 		:= ""
Local nOpc 		:= 3

PRIVATE lMsErroAuto := .F.

dbSelectArea("SC7")

cDoc := GETMV("MV_XSC7")
cDoc := alltrim(str(val(cDoc) + 1))
cDoc := PADL(cDoc,6,"0")

PUTMV("MV_XSC7",cDoc)

If SELECT("TBSC1")>0
	TBSC1->(dbCloseArea())
Endif

cQry := "SELECT ISNULL(CONVERT(VARCHAR(2047), CONVERT(VARBINARY(2047), C1_OBS)),'') AS OBSC1,* " + CRLF
cQry += "FROM " + RetSqlName("SC1") + " SC1 " 	+ CRLF
cQry += "WHERE C1_FILIAL = '" + cSc1Fil + "' " 	+ CRLF
cQry += "	AND C1_NUM = '" + cSc1Num + "' " 	+ CRLF
cQry += "	AND C1_XPRIORI IN ('9','C')"		+ CRLF
cQry += "	AND C1_PEDIDO = '' " 				+ CRLF
cQry += "	AND D_E_L_E_T_ = ' ' " 				+ CRLF
ChangeQuery(cQry)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"TBSC1",.T.,.T.)

If !Empty(TBSC1->C1_FORNECE)
	aadd(aCabec,{"C7_NUM" ,cDoc})
	aadd(aCabec,{"C7_EMISSAO" ,dDataBase})
	aadd(aCabec,{"C7_FORNECE" ,TBSC1->C1_FORNECE})
	aadd(aCabec,{"C7_LOJA" ,TBSC1->C1_LOJA})
	aadd(aCabec,{"C7_COND" ,"002"})
	aadd(aCabec,{"C7_CONTATO" ,Posicione("SA2",1,xFilial("SA2")+TBSC1->C1_FORNECE+TBSC1->C1_LOJA,"SA2->A2_CONTATO")})
	aadd(aCabec,{"C7_FILENT" ,cSc1Fil})

	Do While TBSC1->(!Eof())
		aLinha := {}
			aadd(aLinha,{"C7_PRODUTO" ,TBSC1->C1_PRODUTO,Nil})
			aadd(aLinha,{"C7_QUANT" ,TBSC1->C1_QUANT,Nil})
			aadd(aLinha,{"C7_QTDSOL" ,TBSC1->C1_QUANT,Nil})
			aadd(aLinha,{"C7_PRECO" ,TBSC1->C1_VUNIT,Nil})
			aadd(aLinha,{"C7_TOTAL" ,TBSC1->C1_QUANT * C1_VUNIT ,Nil})
			aadd(aLinha,{"C7_CC" ,TBSC1->C1_CC ,Nil})
			aadd(aLinha,{"C7_ITEMCTA" ,TBSC1->C1_ITEMCTA ,Nil})
			aadd(aLinha,{"C7_CLVL" ,TBSC1->C1_CLVL ,Nil})
			aadd(aLinha,{"C7_OBS" ,TBSC1->OBSC1 ,Nil})
			aadd(aLinha,{"C7_NUMSC" ,TBSC1->C1_NUM ,Nil})
			aadd(aLinha,{"C7_ITEMSC" ,TBSC1->C1_ITEM ,Nil})
			aadd(aLinha,{"C7_XTPAPL" ,TBSC1->C1_XPROPRI ,Nil})
			aadd(aItens,aLinha)
		TBSC1->(dbSkip())
	EndDo

	MSExecAuto({|a,b,c,d,e,f,g| MATA120(a,b,c,d,e,f,,g)},1,aCabec,aItens,nOpc,.F.,aRatCC,aRatPrj)

	If !lMsErroAuto
		FwLogMsg("MATA094_PE", /*cTransactionId*/, "MATA094_PE", FunName(), "", "01","Incluido PC: "+cDoc, 0, (nStart - Seconds()), {})

		cSql := " UPDATE " + RetSqlName("SC1")+ " SET C1_QUJE = C1_QUANT, C1_PEDIDO = '" + cDoc + "',C1_RESIDUO = '',C1_OK = 'ok' WHERE C1_NUM = '" + cSc1Num + "' AND C1_FILIAL = '" + cSc1Fil + "' AND C1_XPRIORI IN ('9','C') AND C1_PEDIDO = '' "
		nStatus := TcSQLExec(cSql)
		if (nStatus < 0)
			FwLogMsg("MATA094_PE", /*cTransactionId*/, "MATA094_PE", FunName(), "", "01","TCSQLError() " + TCSQLError(), 0, (nStart - Seconds()), {})
	  	endif

		MsgInfo("Pedido de compra incluido para produto regularizacao! num: " + cDoc,"Pedido de compra")

		cSql := " UPDATE " + RetSqlName("SC7")+ " SET C7_XOBS = C7_OBS, C7_XOBSF = C7_OBS WHERE C7_NUM = '" + cDoc + "' AND C7_FILIAL = '" + cSc1Fil + "' "
		nStatus := TcSQLExec(cSql)
		if (nStatus < 0)
			FwLogMsg("MATA094_PE", /*cTransactionId*/, "MATA094_PE", FunName(), "", "01","TCSQLError() " + TCSQLError(), 0, (nStart - Seconds()), {})
	  	endif
		//- Lucas Costa - 13/04/2021
		//- Carrega as informações do Banco de Conhecimento da Solicitação de Compras para Pedido e Compras
		//- ****** Carrega Banco de Conhecimento ******

		// Alteração da cQuery no dia 07/05/2021 para considerar todos os itens da SC com anexo, agregando a função Like no campo AC9_ENTIDA.
		//cQuery := " SELECT AC9_CODOBJ FROM " + RetSqlName("AC9")+ " AC9 WHERE AC9_ENTIDA = 'SC1' AND AC9_CODENT = '"+xFilial( "SC1" ) + SC1->C1_NUM + "0001"  +"' AND D_E_L_E_T_ != '*' "
		cQuery := " SELECT AC9_CODOBJ FROM " + RetSqlName("AC9")+ " AC9 WHERE AC9_ENTIDA = 'SC1' AND AC9_FILENT = '"+xFilial( "SC1" )+"' AND AC9_CODENT LIKE '"+xFilial( "SC1" ) + SC1->C1_NUM +"%' AND D_E_L_E_T_ = ' ' "

		If SELECT("TRBAC9") > 0
			TRBAC9->(DbCloseArea())
		Endif
	    dbUseArea(.T.,"TOPCONN", TcGenQry(,,cQuery),"TRBAC9",.T.,.T.)
		DbSelectArea("TRBAC9")
		TRBAC9->(dbGoTop())
				Do While TRBAC9->(!Eof())
					RecLock( "AC9", .T. )
					AC9->AC9_FILIAL := xFilial( "AC9" )
					AC9->AC9_FILENT := xFilial( "SC7" )
					AC9->AC9_ENTIDA := "SC7"
					AC9->AC9_CODENT := xFilial( "SC7" ) + SC1->C1_PEDIDO + "0001"
					AC9->AC9_CODOBJ := TRBAC9->AC9_CODOBJ
					AC9->(MsUnLock()) // Confirma e finaliza a operação
				dbSelectArea("TRBAC9")
				TRBAC9->(dbSkip())
				EndDo
		// Fim do carregamento para AC9
	Else
		FwLogMsg("MATA094_PE", /*cTransactionId*/, "MATA094_PE", FunName(), "", "01","Erro na inclusão!", 0, (nStart - Seconds()), {})
		MostraErro()
	EndIf
Endif

Return(cDoc)
