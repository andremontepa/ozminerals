#INCLUDE "PROTHEUS.CH"
User Function MA110BUT()
Local nOpc:= PARAMIXB[1]
Local aBut:= PARAMIXB[2] 

AADD(aBut, {"S4WB0052",{|| U_MAAPROV(SC1->C1_NUM,nOpc,"SC")},"#Aprovadores","#Aprovadores"} )
AADD(aBut, {"S4WB0053",{|| U_ATUCOMP(SC1->C1_NUM,nOpc,"SC")},"#Atualiza Comprador","#Atualiza Comprador"} )
Return aBut      

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A120Posic ³Revisao³Alexandre Inacio Lemes ³Data  ³05/05/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Consulta do status das Aprovacoes Documentos PC/AE/CP/NF   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ Void A120Posic(ExpC1,ExpN1,ExpN2,ExpC2)                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Opcao selecionada                                  ³±±
±±³          ³ ExpC2 = Tipo do Documento                                  ³±±
±±³          ³ ExpC3 = Informa se salva status                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA120 / MATA125 / MATA103 / CNTA130                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function MAAPROV(cNunSc,nOpc,cTpDoc)

Local aArea		:= GetArea()
Local aSavCols   := {}
Local aSavHead   := {}
Local cHelpApv   := "Este documento nao possui controle de aprovacao." // "Este documento nao possui controle de aprovacao."
Local cAliasSCR  := "TMP"
Local cComprador := ""
Local cSituaca   := ""
Local cNumDoc    := ""
Local cStatus    := ""
Local cTitle     := ""
Local cTitDoc    := ""
Local cAddHeader := ""
Local cAprovador := ""
Local nOpcx := nOpc
Local cTipoDoc := cTpDoc
Local lStatus  := .T.
Local lResid   := .F.

Local lBloq     := .F.
Local lQuery    := .F.

Local nSavN		:= 0
Local nX   		:= 0
Local nY        := 0

Local oDlg
Local oGet
Local oBold        
Local lMVAPRSCEC 	:= SuperGetMv("MV_APRSCEC",.F.,.F.)
Local aDadosCR := {}  

#IFDEF TOP
	Local cQuery   := ""
	Local aStruSCR := {}
#ENDIF

If cTipoDoc = "SC"
 lStatus  := .T.
ElseIf cTipoDoc $ "CT|IC"
 lStatus  := .F.
Endif

DEFAULT lResid   := .F.

If lStatus
	aSavCols  := aClone( aCols )
	aSavHead  := aClone( aHeader )
	nSavN     := N
Else
	Private aCols   := {}
	Private aHeader := {}
	Private N       := 1
EndIf

IF cTipoDoc == "SC"
	    cTitle    := "Aprovacao da Solicitação de Compra" // "Aprovacao da Solicitação de Compra"
	    cTitDoc   := "Aprovacao da Solicitação de Compra" // "Aprovacao da Solicitação de Compra" 
	    cHelpApv  := "Esta solicitação nao possui controle de aprovacao." // "Esta solicitação nao possui controle de aprovacao." 
		cNumDoc   := SC1->C1_NUM
		cComprador:= UsrRetName(SC1->C1_USER)
		cStatus   := IIF(SC1->C1_APROV=="L","SOLICITAÇÃO LIBERADA","AGUARDANDO LIB.") //"SOLICITAÇÃO LIBERADA"#"AGUARDANDO LIB."
EndIf 

IF cTipoDoc $ "CT|IC"
	    cTitle    := "Aprovacao da Solicitação de Contrato" // "Aprovacao da Solicitação de Compra"
	    cTitDoc   := "Aprovacao da Solicitação de Contrato" // "Aprovacao da Solicitação de Compra" 
	    cHelpApv  := "Esta solicitação nao possui controle de aprovacao." // "Esta solicitação nao possui controle de aprovacao." 
		cNumDoc   := cNunSc //CN9->CN9_NUMCOT
		cComprador:= "000000" //UsrRetName(SC1->C1_USER)
		cStatus   := IIF(CN9->CN9_APROV=="L","SOLICITAÇÃO LIBERADA","AGUARDANDO LIB.") //"SOLICITAÇÃO LIBERADA"#"AGUARDANDO LIB."
EndIf


If !Empty(cNumDoc) 

	aHeader:= {}
	aCols  := {}

	If lMVAPRSCEC
		AADD(aHeader,{ "Item ","bCR_ITEM","",15,0,"","","C","",""} )
	Endif

	aDadosCR := FWSX3Util():GetListFieldsStruct("SCR",.F.) 
	For nX := 1 To Len(aDadosCR)
		IF AllTrim(aDadosCR[nX][1]) $ "CR_NIVEL/CR_OBS/CR_DATALIB/" + cAddHeader
			AADD(aHeader,{GetSX3Cache(aDadosCR[nX][1],"X3_TITULO"),;
			aDadosCR[nX][1],;
			X3Picture(aDadosCR[nX][1]),;
			aDadosCR[nX][3],;
			aDadosCR[nX][4],;
			GetSX3Cache(aDadosCR[nX][1],"X3_VALID"),;
			GetSX3Cache(aDadosCR[nX][1],"X3_USADO"),;
			aDadosCR[nX][2],;
			"SCR",;
			GetSX3Cache(aDadosCR[nX][1],"X3_CONTEXT")})
			If AllTrim(aDadosCR[nX][1]) == "CR_NIVEL"
				AADD(aHeader,{ "Usuario","bCR_NOME",   "",15,0,"","","C","",""} ) // Usuario
				AADD(aHeader,{ "Situacao","bCR_SITUACA","",20,0,"","","C","",""} ) //"Situacao"
				AADD(aHeader,{ "Usuario Lib.","bCR_NOMELIB","",15,0,"","","C","",""} ) //"Usuario Lib."
			EndIf
		Endif
	Next nX
	ADHeadRec("SCR",aHeader)

		lQuery     := .T.
		
		If cTipoDoc == "SC"
			aStruSCR := SCR->(dbStruct())
			cAliasSCR := GetNextAlias()
		
			cQuery    := "SELECT SCR.*,'0001' AS DBM_ITEM,'' AS DBM_ITEMRA, SCR.R_E_C_N_O_ SCRRECNO "
			cQuery    += "FROM "+RetSqlName("SCR")+" SCR "
			cQuery    += "WHERE CR_NUM = '"+Padr(SC1->C1_NUM,Len(SCR->CR_NUM))+"' "		
			cQuery    += "AND CR_FILIAL = '"+xFilial("SCR")+"' AND CR_TIPO = 'SC' "  
			cQuery    += "AND D_E_L_E_T_ != '*' "
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSCR)
        Endif 
		If cTipoDoc $ "CT|IC"
			aStruSCR := SCR->(dbStruct())
			cAliasSCR := GetNextAlias()
		
			cQuery    := "SELECT SCR.*,'0001' AS DBM_ITEM,'' AS DBM_ITEMRA, SCR.R_E_C_N_O_ SCRRECNO "
			cQuery    += "FROM "+RetSqlName("SCR")+" SCR "
			cQuery    += "WHERE CR_NUM = '"+Padr(cNunSc,Len(CN9->CN9_NUMERO))+"' "		
			cQuery    += "AND CR_FILIAL = '"+xFilial("SCR")+"' AND CR_TIPO = '"+cTipoDoc+"' "  
			cQuery    += "AND D_E_L_E_T_ != '*' "
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSCR)
        Endif        
		For nX := 1 To Len(aStruSCR)
			If aStruSCR[nX][2]<>"C"
				TcSetField(cAliasSCR,aStruSCR[nX][1],aStruSCR[nX][2],aStruSCR[nX][3],aStruSCR[nX][4])
			EndIf
		Next nX

	dbSelectArea(cAliasSCR)
	cCodUser := ""		
	While !Eof() 
	 If (cAliasSCR)->CR_USER <> cCodUser
		aAdd(aCols,Array(Len(aHeader)+1))
		nY++
		For nX := 1 to Len(aHeader)
            If IsHeadRec(aHeader[nX][2])
			    aCols[nY][nX] := (cAliasSCR)->SCRRECNO
            ElseIf IsHeadAlias(aHeader[nX][2])
			    aCols[nY][nX] := "SCR"
			ElseIf aHeader[nX][02] == "bCR_NOME"
				aCols[nY][nX] := UsrRetName((cAliasSCR)->CR_USER)
			ElseIf aHeader[nX][02] == "bCR_ITEM"
				If lMVAPRSCEC
					If (cAliasSCR)->CR_TIPO $ "SC|SA|IP|CT|IC" 
						aCols[nY][nX] :=(cAliasSCR)->DBM_ITEM + IIF(!Empty((cAliasSCR)->DBM_ITEMRA),"-"+(cAliasSCR)->DBM_ITEMRA,"")
					Else
						aCols[nY][nX] := Replicate("-",8)
					Endif
				Endif	
			ElseIf aHeader[nX][02] == "bCR_SITUACA"
				Do Case
				Case (cAliasSCR)->CR_STATUS == "01"
						cSituaca := "Nivel Bloqueado" //"Nivel Bloqueado"
				Case (cAliasSCR)->CR_STATUS == "02"
						cSituaca := "Aguardando Liberacao" //"Aguardando Liberacao"
				Case (cAliasSCR)->CR_STATUS == "03"
						If (cAliasSCR)->CR_TIPO $ "SC|SA"
							cSituaca := "Solicitação Aprovada" //"Solicitação Aprovada"
						EndIf
				Case (cAliasSCR)->CR_STATUS == "04"
						If (cAliasSCR)->CR_TIPO == "SC"
							cSituaca :="Solicitação Bloqueada" //"Solicitação Bloqueada"
						EndIf
					lBloq := .T.
				Case (cAliasSCR)->CR_STATUS == "05"
					cSituaca := "Nivel Liberado " // "Nivel Liberado "
				EndCase
				aCols[nY][nX] := cSituaca
			ElseIf aHeader[nX][02] == "bCR_NOMELIB"
				aCols[nY][nX] := UsrRetName((cAliasSCR)->CR_USERLIB)
			ElseIf ( aHeader[nX][10] != "V")
				aCols[nY][nX] := FieldGet(FieldPos(aHeader[nX][2]))
			EndIf	
		Next nX
		aCols[nY][Len(aHeader)+1] := .F.
	 cCodUser := (cAliasSCR)->CR_USER
	 Endif		
  dbSkip()
  EndDo

	If !Empty(aCols)
		If lBloq
			cStatus := "BLOQUEADO"
		EndIf	
		n:=	 IIF(n > Len(aCols), Len(aCols), n)  // Feito isto p/evitar erro fatal(Array out of Bounds). Gilson-Localizações
		DEFINE FONT oBold NAME "Arial" SIZE 0, -12 BOLD
		DEFINE MSDIALOG oDlg TITLE cTitle From 109,095 To 400,600 OF oMainWnd PIXEL	 //"Aprovacao do Pedido de Compra // Contrato"
		@ 005,003 TO 032,250 LABEL "" OF oDlg PIXEL
		If cTipoDoc <> "MD"
			@ 015,007 SAY cTitDoc OF oDlg FONT oBold PIXEL SIZE 046,009 // "Pedido" / "Contrato" / "Nota Fiscal" 
			@ 014,041 MSGET cNumDoc PICTURE "" WHEN .F. PIXEL SIZE 150,009 OF oDlg FONT oBold
	        If cTipoDoc <> "NF"
				@ 015,095 SAY OemToAnsi("Comprador") OF oDlg PIXEL SIZE 045,009 FONT oBold //"Comprador"
				@ 014,138 MSGET cComprador PICTURE "" WHEN .F. of oDlg PIXEL SIZE 103,009 FONT oBold
	        EndIF   
	   	Else
			@ 015,007 SAY cTitDoc OF oDlg FONT oBold PIXEL SIZE 046,009 // "Medicao" 
			@ 014,035 MSGET cNumDoc PICTURE "" WHEN .F. PIXEL SIZE 50,009 OF oDlg FONT oBold

			@ 015,095 SAY cAprovador OF oDlg PIXEL SIZE 045,009 FONT oBold //"Aprovador"
			@ 014,138 MSGET cComprador PICTURE "" WHEN .F. of oDlg PIXEL SIZE 103,009 FONT oBold  	
	   	EndIf          
	   	
		@ 132,008 SAY 'Situacao :' OF oDlg PIXEL SIZE 052,009 //'Situacao :'
		@ 132,038 SAY cStatus OF oDlg PIXEL SIZE 120,009 FONT oBold
		@ 132,205 BUTTON 'Fechar' SIZE 035 ,010  FONT oDlg:oFont ACTION (oDlg:End()) OF oDlg PIXEL  //'Fechar'
		oGet:= MSGetDados():New(038,003,120,250,nOpcx,,,"")
		oGet:Refresh()
		@ 126,002 TO 127,250 LABEL "" OF oDlg PIXEL	
		ACTIVATE MSDIALOG oDlg CENTERED
	Else
		Aviso("Atencao","Este pedido nao possui controle de aprovacao.",{"Voltar"}) //"Atencao"###"Este pedido nao possui controle de aprovacao."###"Voltar"
	EndIf

	dbSelectArea(cAliasSCR)
	dbCloseArea()

	If lStatus
		aHeader := aClone(aSavHead)
		aCols   := aClone(aSavCols)
		N		:= nSavN
	EndIf
Else
	Aviso("Atencao","Este Documento nao possui controle de aprovacao.",{"Voltar"}) //"Atencao"###"Este Documento nao possui controle de aprovacao."###"Voltar"
EndIf

RestArea(aArea)

Return NIL
