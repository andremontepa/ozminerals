#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TOPCONN.CH'
#INCLUDE 'TBICONN.CH'
#INCLUDE 'TOTVS.CH'
#INCLUDE 'FWBROWSE.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'RWMAKE.CH'
#Include 'Ap5mail.ch'

/*/{Protheus.doc} MA110BAR
Ponto de entrada para acrescentar botao na tela de Solicitacao de Compras.
@author 	Ricardo Tavares Ferreira
@since 		31/08/2018
@version 	12.1.17
@return 	Array
@obs 		Ricardo Tavares - Construcao Inicial
/*/
//====================================================================================================
	User Function MA110BAR()
//====================================================================================================

	Local aRot := {}
	Local cAtvWFSC := Alltrim(SuperGetMv("AR_WFSCAT",.F.,Upper("N"),))
	
	If cAtvWFSC == "N"
		Return aRot
	EndIf
	
	IF !Inclui
		aadd(aRot,{"BUDGET",{|| TELA_SC()},"Consulta Aprovação","Consulta Hist. Aprov. SC"})
	ENDIF

Return aRot

/*/{Protheus.doc} TELA_SC
Função que monta a Tela de SC com seu historico
@author 	Ricardo Tavares Ferreira
@since 		04/09/2018
@version 	12.1.17
@return 	Array
@obs 		Ricardo Tavares - Construcao Inicial
/*/
//====================================================================================================
	Static Function TELA_SC()
//====================================================================================================

	Local aArea		:= GetArea()
	Local aSavCols  := {}
	Local aSavHead  := {}
	Local cHelpApv  := OemToAnsi("Este documento nao possui controle de aprovacao.")
	Local cAliasSCR := "TMP"
	Local cSolicit := ""
	Local cSituaca  := ""
	Local cNumDoc   := ""
	Local cNumFil   := "" 
	Local cStatus   := ""
	Local cTitle    := ""
	Local cTitDoc   := ""
	Local lBloq     := .F.
	Local nSavN		:= 0
	Local nX   		:= 0
	Local nY        := 0
	Local oDlg
	Local oGet
	Local oBold        

	aSavCols  := aClone(aCols)
	aSavHead  := aClone(aHeader)
	nSavN     := N

	If !Empty(SC1->C1_XGRPAPR)
		cTitle    := "Historico das Aprovações da Solicitação de Compra"
		cTitDoc   := "Num. SC"
		cHelpApv  := "Esta solicitação não possui controle de aprovação."                                                                          
		cNumDoc   := SC1->C1_NUM  
		cNumFil   := SC1->C1_FILIAL
		cSolicit  := UsrFullName(SC1->C1_USER)
		cStatus   := IIF(Posicione("SC1",1,cNumFil+cNumDoc,"C1_APROV")=="L",OemToAnsi("LIBERADO"),OemToAnsi("AGUARDANDO LIB.")) 
	EndIf

	aHeader:= {}
	aCols  := {}

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Faz a montagem do aHeader com os campos fixos.               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SX3")
	dbSetOrder(1)
	MsSeek("SCR")
	While !Eof() .And. (SX3->X3_ARQUIVO == "SCR")
		IF AllTrim(X3_CAMPO)$"CR_NIVEL/CR_OBS/CR_DATALIB/CR_USERORI/CR_APRORI" 
			AADD(aHeader,{	TRIM(X3Titulo()),;
			SX3->X3_CAMPO,;
			SX3->X3_PICTURE,;
			SX3->X3_TAMANHO,;
			SX3->X3_DECIMAL,;
			SX3->X3_VALID,;
			SX3->X3_USADO,;
			SX3->X3_TIPO,;
			SX3->X3_ARQUIVO,;
			SX3->X3_CONTEXT } )
			
			If AllTrim(x3_campo) == "CR_NIVEL"
				AADD(aHeader,{ OemToAnsi("Situacao")			,"bCR_SITUACA"		,"",20,0,"","","C","",""} )
				AADD(aHeader,{ OemToAnsi("Usuario")				,"bCR_NOME"			,"",15,0,"","","C","",""} )
				AADD(aHeader,{ OemToAnsi("Aprovado por")		,"bCR_NOMELIB"  	,"",15,0,"","","C","",""} )
			ElseIf AllTrim(x3_campo) == "CR_APRORI"
				AADD(aHeader,{ OemToAnsi("Aprovador Principal"),"bCR_APROVPRI"	 	,"",15,0,"","","C","",""} )
			EndIf
			
		Endif
		
		dbSelectArea("SX3")
		dbSkip()
	EndDo

	ADHeadRec("SCR",aHeader)

	aStruSCR := SCR->(dbStruct())
	cAliasSCR := GetNextAlias()

	BeginSQL Alias cAliasSCR
		select SCR.*, SCR.R_E_C_N_O_ SCRRECNO
		from  %Table:SCR% SCR
		where SCR.CR_FILIAL = %Exp:cNumFil%
		and SCR.CR_NUM    = %Exp:Padr(cNumDoc,Len(SCR->CR_NUM))%
		and SCR.CR_TIPO   = 'SC'
		and SCR.%NotDel%
		order by SCR.CR_FILIAL, SCR.CR_TIPO, SCR.CR_NUM, SCR.CR_NIVEL, SCR.CR_APROV
	EndSQL

	For nX := 1 To Len(aStruSCR)
		If aStruSCR[nX][2]<>"C"
			TcSetField(cAliasSCR,aStruSCR[nX][1],aStruSCR[nX][2],aStruSCR[nX][3],aStruSCR[nX][4])
		EndIf
	Next nX

	dbSelectArea(cAliasSCR)

	While !Eof() .And.(cAliasSCR)->CR_FILIAL+(cAliasSCR)->CR_TIPO+Substr((cAliasSCR)->CR_NUM,1,Len(SC1->C1_NUM)) == cNumFil + "SC" + cNumDoc
		aadd(aCols,Array(Len(aHeader)+1))
		nY++
		For nX := 1 to Len(aHeader)
			If IsHeadRec(aHeader[nX][2])
				aCols[nY][nX] := (cAliasSCR)->SCRRECNO
			ElseIf IsHeadAlias(aHeader[nX][2])
				aCols[nY][nX] := "SCR"
			ElseIf Alltrim(aHeader[nX][02]) == "bCR_NOME"
				aCols[nY][nX] := UsrRetName((cAliasSCR)->CR_USER)
			ElseIf Alltrim(aHeader[nX][02]) == "bCR_SITUACA"
				Do Case
					Case (cAliasSCR)->CR_STATUS == "01"
						cSituaca := OemToAnsi("Aguardando")
					Case (cAliasSCR)->CR_STATUS == "02"
						cSituaca := OemToAnsi("Em Aprovação")
					Case (cAliasSCR)->CR_STATUS == "03"
						cSituaca := "Solicitação Aprovada"
					Case (cAliasSCR)->CR_STATUS == "04"
						cSituaca := "Solicitação Bloqueada"
						lBloq := .T.
					Case (cAliasSCR)->CR_STATUS == "05"
						cSituaca := OemToAnsi("Nível Liberado ")
				EndCase
				aCols[nY][nX] := cSituaca
			ElseIf Alltrim(aHeader[nX][02]) == "bCR_NOMELIB"
				If (cAliasSCR)->CR_STATUS $ "01|02"
					aCols[nY][nX] := ""
				Else
					aCols[nY][nX] := UsrFullName((cAliasSCR)->CR_USERLIB)				
				EndIf
			ElseIf Alltrim(aHeader[nX][02]) == "bCR_APROVPRI"
				aCols[nY][nX] := UsrFullName((cAliasSCR)->CR_USERORI)
			ElseIf Alltrim(aHeader[nX][02]) == "CR_USER"
				aCols[nY][nX] := (cAliasSCR)->CR_USER
			ElseIf Alltrim(aHeader[nX][02]) == "CR_NIVEL"
				aCols[nY][nX] := (cAliasSCR)->CR_NIVEL
			ElseIf Alltrim(aHeader[nX][02]) == "CR_DATALIB"
				aCols[nY][nX] := Dtoc((cAliasSCR)->CR_DATALIB)
			ElseIf Alltrim(aHeader[nX][02]) == "CR_USERORI"
				aCols[nY][nX] := (cAliasSCR)->CR_USERORI
			ElseIf Alltrim(aHeader[nX][02]) == "CR_APRORI"
				aCols[nY][nX] := (cAliasSCR)->CR_APRORI
			EndIf
		Next nX
		aCols[nY][Len(aHeader)+1] := .F.
		dbSkip()
	EndDo

	If Empty(aCols)
		MsgInfo("Esta Solicitação de Compra não possui controle de aprovação.","Consulta Aprovação")
	Else
		If lBloq
			cStatus := "SOLICITAÇÃO BLOQUEADA"
		EndIf      

		n:=	 IIF(n > Len(aCols), Len(aCols), n)  // Feito isto p/evitar erro fatal(Array out of Bounds). Gilson-Localizações
		
		DEFINE FONT oBold NAME "Arial" SIZE 0, -12 BOLD
		DEFINE MSDIALOG oDlg TITLE cTitle From 109,095 To 400,870 OF oMainWnd PIXEL
		@ 005,003 TO 032,387 LABEL "Dados da Solicitação" OF oDlg PIXEL
		@ 015,007 SAY "Filial" OF oDlg FONT oBold PIXEL SIZE 046,009 
		@ 014,027 MSGET SC1->C1_FILIAL PICTURE "" WHEN .F. READONLY PIXEL SIZE 050,009 OF oDlg FONT oBold
		@ 015,092 SAY cTitDoc OF oDlg FONT oBold PIXEL SIZE 046,009 
		@ 014,132 MSGET SC1->C1_NUM PICTURE "" WHEN .F. READONLY PIXEL SIZE 050,009 OF oDlg FONT oBold
		@ 015,195 SAY OemToAnsi("Solicitante") OF oDlg PIXEL SIZE 033,009 FONT oBold
		@ 014,230 MSGET cSolicit PICTURE "" WHEN .F. of oDlg READONLY PIXEL SIZE 153,009 FONT oBold	
		@ 036,003 TO 125,387 LABEL "Dados dos Aprovadores" OF oDlg PIXEL
		@ 133,008 SAY "Situacao :" OF oDlg PIXEL SIZE 052,009 
		@ 133,038 SAY cStatus OF oDlg PIXEL SIZE 200,009 FONT oBold 
		@ 132,352 BUTTON "Fechar" SIZE 035 ,010  FONT oDlg:oFont ACTION (oDlg:End()) OF oDlg PIXEL  
		oGet:= MSGetDados():New(045,007,120,384,2,,,"")
		oGet:Refresh()
		@ 129,003 TO 130,387 LABEL "" OF oDlg PIXEL
		ACTIVATE MSDIALOG oDlg CENTERED
	EndIf

	(cAliasSCR)->(dbCloseArea())

	aHeader := aClone(aSavHead)
	aCols   := aClone(aSavCols)
	N		:= nSavN

	dbSelectArea("SC1")
	RestArea(aArea)

Return()
	