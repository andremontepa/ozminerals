#Include "Protheus.Ch"
#Include "ApWebSrv.Ch"
#Include "TopConn.Ch"
#Include "TbiConn.Ch"
#INCLUDE "totvs.ch"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"
#include "rwmake.ch"
#Include "AP5Mail.ch"

#define VAZIO           Space(01)
#define PGTOANTECIPADO  "PA"

/*/{Protheus.doc} OZ06M09

	Rotina para enviar o pagamento antecipado para o argo 

@type Function
@author Fabio Santos - CRM Service
@since 22/09/2024
@version P12
@database MSSQL

@see OZGENSQL
@see OZGEN18

@nested-tags:Frameworks/OZminerals
/*/
User Function OZ06M09()
	Local aSays      		:= {} as array 
	Local aButtons   		:= {} as array 
	Local nOpca      		:= 0  as integer
	Local cTitoDlg   		:= "" as character
	
	Private _cPerg          := "OZ06M09"
	Private cSintaxeRotina  := ""  as character

    aArea            		:= GetArea()
	cTitoDlg         		:= "Envia Confirmação de Pgto Para Argo"
	cPerg            		:= "OZ06M09"
	cSintaxeRotina          := ProcName(0)

	aAdd(aSays, "Rotina para gerar a confirmação do pagamento antecipado para ARGO!")
	aAdd(aSays, "Esta rotina ira enviar o pagamento de acordo com os paramentros informados,")
	aAdd(aSays, "sendo por data de pagamento, tipo de titulo, numero, prefixo, fornecedor e loja.")
	aAdd(aSays, "Atenção!!!")
	aAdd(aSays, "Esta Rotina Deve Ser Executada Para Cada Empresa.")
	aAdd(aSays, "Para que este processo se torne automatico, é necessario intervir no retorno do CNAB.")
	aAdd(aSays, "Portanto, até a intervenção no retrorno do CNAB, deve ser excutado esta rotina!")

	aAdd(aButtons,{1, .T., {|o| nOpca := 1, FechaBatch()}})
	aAdd(aButtons,{2, .T., {|o| nOpca := 2, FechaBatch()}})

	FormBatch(cTitoDlg, aSays, aButtons)

	If ( nOpca == 1 )
		
		oAjustaSx1()

		If ( !Pergunte(_cPerg,.T.))
			Return
		Else 
			MontaDir("C:\TOTVS\")
			FWMsgRun(,{|| u_OZ06WS01() } ,"Processando Confirnação Pagamento Antecipado Argo...","Aguarde")
		EndIf
	EndIf

	RestArea( aArea )

Return

/*
    Executa o envio de pagamento para o ARGO
*/
User Function OZ06WS01()
	Local oRest     		:= nil as object
	Local oJson     		:= nil as object
	Local lRet      		:= .T. as logical 
	Local lPassa     		:= .T. as logical 
	Local aArea             := {}  as array
	Local aHeader   		:= {}  as array
	Local aRetorna          := {}  as array 
	Local nRet              := 0   as integer
	Local cTkArgo   		:= ""  as character
	Local cLog      		:= ""  as character
	Local cToken            := ""  as character
	Local bObject   		:= {||}

	Private cEnderecoApi    := ""  as character
	Private cUserName       := ""  as character
	Private cKeyPassword    := ""  as character
	Private cReseller       := ""  as character
	Private cCorp           := ""  as character
	Private cGranttype      := ""  as character 
	Private cUsrEviroment   := ""  as character 
	Private cKeyEnviroment  := ""  as character 

    aArea                   := GetArea()
	cUsrEviroment   		:= GetNewPar("OZ_USRPROT","LEONARDO.MEDEIROS")  
	cKeyEnviroment  		:= GetNewPar("OZ_KEYPROT","Totvs@2024")    
	cEnderecoApi            := Alltrim(GetNewPar("OZ_APIARGO" ,"https://api.useargo.com"))
	cUserName       		:= GetNewPar("OZ_USRNAME" ,"integracao.api")
	cKeyPassword       		:= GetNewPar("OZ_KEYPWD"  ,"Oz@2023")
	cReseller       		:= GetNewPar("OZ_RESELLE" ,"ozminerals")
	cCorp           		:= GetNewPar("OZ_CORP"    ,"")
	cGranttype       		:= GetNewPar("OZ_GRANTTY" ,"password")
	cTkArgo                 := GetNewPar("OZ_TOKENFX","Basic YTUyZWY0NTAtM2QwNC00MWVlLTkxNWMtMWI1YzE2MDNhZDcyOjMzZTZmODRiLWM3ZmUtNDE1Mi05NmNmLWMwYWIyNjM5ZjhkZQ==")
	lExibeToken             := GetNewPar("OZ_VETOKEN",.T.) 
	bObject                 := {|| JsonObject():New()}
	oRest                   := FwRest():New(cEnderecoApi)
	oJson                   := Eval(bObject)

	oRest:SetPath("/oauth/access-token/")

	aAdd(aHeader,"Content-Type: application/json")
	aAdd(aHeader,"Authorization: " +cTkArgo)

	oJson["username"]       := AllTrim(cUserName)
	oJson["password"]       := AllTrim(cKeyPassword)
	oJson["reseller"]       := AllTrim(cReseller)
	oJson["corp"]           := AllTrim(cCorp)
	oJson["grant_type"]     := AllTrim(cGranttype)

	oRest:SetPostParams(oJson:ToJson())

    DbSelectArea("ZZ1")
    ZZ1->(DbSetOrder(1))

	// REALIZA O MÉTODO POST E VALIDA O RETORNO
	If (oRest:Post(aHeader))
		cToken    := oRest:getResult()
		aRetorna  := ArgoBuscaPgtoPa()
		If ( Len(aRetorna) > 0 )
			For nRet   := 1 To Len(aRetorna) 
				lPassa := .F.
				If ( ZZ1->(dbSeek(  PAD(aRetorna[nRet][01] ,TAMSX3("ZZ1_FILIAL") [1]) +; 
									PAD(aRetorna[nRet][03] ,TAMSX3("ZZ1_IDREQ")  [1]) +;
									PAD(aRetorna[nRet][02] ,TAMSX3("ZZ1_PARCE")  [1]) +;
									PAD("Pago"             ,TAMSX3("ZZ1_STATUS") [1]) )))
					lPassa := .F.
				Else 
					lPassa := .T.
				EndIf

				If ( lPassa )
					lRet   := XBXATIT(	cToken             /*Token*/ ,; 
										aRetorna[nRet][01] /*Filial*/,; 
										aRetorna[nRet][03] /*cID*/   ,; 
										aRetorna[nRet][02] /*cParcela*/) 
				EndIf

			Next nRet
		EndIf
	Else
		cLog := "POST: " + oRest:GetLastError()
		ShowLogInConsole(cLog)
	EndIf

	RestArea( aArea )

Return( lRet )

/*
    Executa a baixa do Titulo processo ARGO
*/
Static Function XBXATIT(cToken, cCodFilial, cID, cParcela)
	Local oRest     		:= nil as object 
	Local aHeader   		:= {}  as array 
	Local aArea             := {}  as array
	Local lRet      		:= .T. as logical 
	Local nStatus   		:= 0   as integer 
	Local nRetStatus        := 0   as integer  
	Local cError    		:= ""  as character
	Local c_ID      		:= ""  as character
	Local cParc     		:= ""  as character
	Local cCliID    		:= ""  as character
	Local cCodigoID         := ""  as character 
	Local cData     		:= ""  as character
   	Local cLog      		:= ""  as character

    aArea                   := GetArea()
	oRest                   := FwRest():New(cEnderecoApi)
	c_ID            		:= AllTrim(cID)      
	cParc           		:= AllTrim(cParcela) 
	cCodigoID       		:= GetNewPar("OZ_CODID","a52ef450-3d04-41ee-915c-1b5c1603ad72")
	cCliID          		:= Alltrim(cCodigoID)
	cData           		:= IIF(LEN(AllTrim(str(Day(dDataBase))))<2,"0"+AllTrim(str(Day(dDataBase))),AllTrim(str(Day(dDataBase))))+"/"+IIF(LEN(AllTrim(str(Month(dDataBase))))<2,"0"+AllTrim(str(Month(dDataBase))),AllTrim(str(Month(dDataBase))))+"/"+AllTrim(str(Year(dDataBase)))

	oRest:SetPath("/argo/v2/requests/concluderefund/"+c_ID)

	cToken := SubStr(cToken,At(':"',cToken)+2,36)

	aAdd(aHeader,"client_id: "+cCliID)
	aAdd(aHeader,"access_token: "+cToken)

    DbSelectArea("ZZ1")
    ZZ1->(DbSetOrder(1))

	If ( oRest:Post(aHeader) .And. !Empty(AllTrim(c_ID)) )
		cError     := ""
		nStatus    := HTTPGetStatus(@cError)
		nRetStatus := nStatus

		If ( nStatus >= 200 .And. nStatus <= 299 )

			If Empty(oRest:getResult())
                cLog := "WS REEMBOLSO ARGO - ERRO: " + cValToChar(nRetStatus)
                ShowLogInConsole(cLog)
			Else
				cRet := oRest:getResult()

				If ( ZZ1->(dbSeek(  PAD(xFilial("ZZ1")  ,TAMSX3("ZZ1_FILIAL") [1]) +; 
									PAD(c_ID            ,TAMSX3("ZZ1_IDREQ")  [1]) +;
									PAD(cParc           ,TAMSX3("ZZ1_PARCE")  [1]) +;
									PAD("Integrado"     ,TAMSX3("ZZ1_STATUS") [1]) )))

				
					If ( ZZ1->(RecLock("ZZ1",.F.)))
						 ZZ1->ZZ1_DTBX    := cData
						 ZZ1->ZZ1_HRBX    := Time()
						 ZZ1->ZZ1_STATUS  := "Pago"
						 ZZ1->ZZ1_STS     := "3"
						 ZZ1->(MsUnlock())
					Endif
				Endif

               ShowLogInConsole(cRet)
			Endif
		Else
            ShowLogInConsole(cError)
		Endif
	Else
        cLog := oRest:getLastError() + CRLF + oRest:getResult()
        ShowLogInConsole(cLog)
	EndIf

	RestArea( aArea )

Return( lRet )

/*
 	Busca Regra para Gravar nos campos do Titulo 
*/
Static Function ArgoBuscaPgtoPa()
	Local aArea                 := {}  as array
	Local aRetorno              := {}  as array
	Local cAlias	            := ""  as character
	Local cQuery	            := ""  as character
	Local cLog                  := ""  as character

    aArea                       := GetArea()

	If ( !Empty(cAlias) )
		dbSelectArea(cAlias)
		(cAlias)->(dbCloseArea())
	EndIf

	cQuery               := QryBuscaPgtoAntecipado()
	cAlias               := MpSysOpenQuery(cQuery)

	If ( !Empty(cAlias) )

		dbSelectArea(cAlias)

		If ( (cAlias)->(!EOF()) )

			While ((cAlias)->(!EOF()))

				aAdd(aRetorno,{ (cAlias)->E5_FILIAL,;
								(cAlias)->E5_PARCELA,;
								(cAlias)->E2_XID})
				(cAlias)->(dbSkip())
			EndDo
		EndIf 

		(cAlias)->(dbCloseArea())
	Else
		cLog += "Registro Não Localizado!"
	EndIf

	If ( !Empty(cLog) )
		showLogInConsole(StrTran(cLog,CRLF,", ") )
	Endif

	RestArea( aArea )

Return (aRetorno)

/*
	Monta a Query para Buscar Conta, Centro de Custo, Item Contabil e Classe de Valor 
*/
Static Function QryBuscaPgtoAntecipado()
	Local cQuery 	    := ""  as character

	cQuery := " SELECT " + CRLF
	cQuery += "		   E5_FILIAL  AS E5_FILIAL,  " + CRLF
	cQuery += "		   E5_DATA    AS E5_DATA,    " + CRLF
	cQuery += "		   E5_PREFIXO AS E5_PREFIXO, " + CRLF
	cQuery += "		   E5_NUMERO  AS E5_NUMERO,  " + CRLF 
	cQuery += "		   E5_PARCELA AS E5_PARCELA, " + CRLF 
	cQuery += "		   E5_TIPO    AS E5_TIPO,    " + CRLF 
	cQuery += "		   E5_CLIFOR  AS E5_CLIFOR,  " + CRLF 
	cQuery += "		   E5_LOJA    AS E5_LOJA,    " + CRLF 
	cQuery += "		   E5_TIPODOC AS E5_TIPODOC, " + CRLF 
	cQuery += "		   E2_XID     AS E2_XID     " + CRLF 
	cQuery += " FROM   " + CRLF
	cQuery += " 	   " + RetSQLTab("SE5") + CRLF
	cQuery += " 	   INNER JOIN " + CRLF
	cQuery += " 	              " + RetSQLTab("SE2") +  CRLF
	cQuery += " 	              ON 1=1 " + CRLF
	cQuery += " 				  AND E5_FILIAL  = E2_FILIAL  " + CRLF
	cQuery += " 				  AND E5_PREFIXO = E2_PREFIXO " + CRLF
	cQuery += " 				  AND E5_NUMERO  = E2_NUM     " + CRLF
	cQuery += " 				  AND E5_PARCELA = E2_PARCELA " + CRLF
	cQuery += " 				  AND E5_TIPO    = E2_TIPO    " + CRLF
	cQuery += " 				  AND E5_CLIFOR  = E2_FORNECE " + CRLF
	cQuery += " 				  AND E5_LOJA    = E2_LOJA    " + CRLF
	cQuery += "     			  AND " + RetSqlDel("SE2")   + CRLF
	cQuery += " WHERE  " + CRLF
	cQuery += " 	   1 = 1 " + CRLF
	cQuery += "   	   AND E5_FILIAL  BETWEEN " + ValToSql(MV_PAR01) + " AND " + ValToSql(MV_PAR02) + " " + CRLF
	cQuery += "   	   AND E5_PREFIXO BETWEEN " + ValToSql(MV_PAR03) + " AND " + ValToSql(MV_PAR04) + " " + CRLF
	cQuery += "   	   AND E5_NUMERO  BETWEEN " + ValToSql(MV_PAR05) + " AND " + ValToSql(MV_PAR06) + " " + CRLF
	cQuery += "   	   AND E5_PARCELA BETWEEN " + ValToSql(MV_PAR07) + " AND " + ValToSql(MV_PAR08) + " " + CRLF
	cQuery += "   	   AND E5_TIPO    BETWEEN " + ValToSql(MV_PAR09) + " AND " + ValToSql(MV_PAR10) + " " + CRLF
	cQuery += "   	   AND E5_CLIFOR  BETWEEN " + ValToSql(MV_PAR11) + " AND " + ValToSql(MV_PAR12) + " " + CRLF
	cQuery += "   	   AND E5_LOJA    BETWEEN " + ValToSql(MV_PAR13) + " AND " + ValToSql(MV_PAR14) + " " + CRLF
	cQuery += "   	   AND E5_DATA    BETWEEN " + ValToSql(DtoS(MV_PAR15)) + " AND " + ValToSql(DtoS(MV_PAR16)) + " " + CRLF
	cQuery += "   	   AND E2_XID     <>  " + ValToSql(VAZIO)    + "  " + CRLF
	cQuery += "   	   AND E2_TIPO    =   " + ValToSql(PGTOANTECIPADO)   + "  " + CRLF
	cQuery += "   	   AND " + RetSqlDel("SE5")                               + CRLF
	cQuery += " GROUP BY   " + CRLF
	cQuery += "		   E5_FILIAL,  " + CRLF
	cQuery += "		   E5_DATA,    " + CRLF
	cQuery += "		   E5_PREFIXO, " + CRLF
	cQuery += "		   E5_NUMERO,  " + CRLF 
	cQuery += "		   E5_PARCELA, " + CRLF 
	cQuery += "		   E5_TIPO,    " + CRLF 
	cQuery += "		   E5_CLIFOR,  " + CRLF 
	cQuery += "		   E5_LOJA,    " + CRLF 
	cQuery += "		   E5_TIPODOC, " + CRLF 
	cQuery += "		   E2_XID      " + CRLF 

	u_ChangeQuery("\sql\EnviaTituloPagoArgo_QryBuscaPgtoAntecipado.sql", @cQuery)

Return cQuery

/*
	Grupo de Perguntas para executar a rotina 
*/
Static Function oAjustaSx1()
	Local _aPerg  := {} as array
	Local _ni     := 0  as integer 

	Aadd(_aPerg,{"Filial De  .......?","mv_ch1","C",02,"G","mv_par01","","","","","","SM0","","",0})
	Aadd(_aPerg,{"Filial Até .......?","mv_ch2","C",02,"G","mv_par02","","","","","","SM0","","",0})

	Aadd(_aPerg,{"Prefixo De  ......?","mv_ch3","C",03,"G","mv_par03","","","","","","SE2","","",0})
	Aadd(_aPerg,{"Prefixo Até ......?","mv_ch4","C",03,"G","mv_par04","","","","","","SE2","","",0})

	Aadd(_aPerg,{"Numero Tit. De ...?","mv_ch5","C",09,"G","mv_par05","","","","","","SE2","","",0})
	Aadd(_aPerg,{"Numero Tit. Até ..?","mv_ch6","C",09,"G","mv_par06","","","","","","SE2","","",0})

	Aadd(_aPerg,{"Parcela Tit. De  .?","mv_ch7","C",03,"G","mv_par07","","","","","","SE2","","",0})
	Aadd(_aPerg,{"Parcela Tit. Até .?","mv_ch8","C",03,"G","mv_par08","","","","","","SE2","","",0})

	Aadd(_aPerg,{"Tipo Tit. De .....?","mv_ch9","C",03,"G","mv_par09","","","","","","05","","",0})
	Aadd(_aPerg,{"Tipo Tit. Até ....?","mv_cha","C",03,"G","mv_par10","","","","","","05","","",0})

	Aadd(_aPerg,{"Fornecedor De  ...?","mv_chb","C",06,"G","mv_par11","","","","","","SA2","","",0})
	Aadd(_aPerg,{"Fornecedor Até ...?","mv_chc","C",06,"G","mv_par12","","","","","","SA2","","",0})

	Aadd(_aPerg,{"Loja Forn. De ....?","mv_chd","C",02,"G","mv_par13","","","","","","SA2","","",0})
	Aadd(_aPerg,{"Loja Forn. Até ...?","mv_che","C",02,"G","mv_par14","","","","","","SA2","","",0})

	Aadd(_aPerg,{"Data Pgto  De ....?","mv_chf","D",08,"G","mv_par15","","","","","","","","",0})
	Aadd(_aPerg,{"Data Pgto  Até ...?","mv_chg","D",08,"G","mv_par16","","","","","","","","",0})

	dbSelectArea("SX1")
	For _ni := 1 To Len(_aPerg)
		If ( !dbSeek(_cPerg+ SPACE( LEN(SX1->X1_GRUPO) - LEN(_cPerg))+StrZero(_ni,2)))
			RecLock("SX1",.T.)
				SX1->X1_GRUPO    := _cPerg
				SX1->X1_ORDEM    := StrZero(_ni,2)
				SX1->X1_PERGUNT  := _aPerg[_ni][1]
				SX1->X1_VARIAVL  := _aPerg[_ni][2]
				SX1->X1_TIPO     := _aPerg[_ni][3]
				SX1->X1_TAMANHO  := _aPerg[_ni][4]
				SX1->X1_GSC      := _aPerg[_ni][5]
				SX1->X1_VAR01    := _aPerg[_ni][6]
				SX1->X1_DEF01    := _aPerg[_ni][7]
				SX1->X1_DEF02    := _aPerg[_ni][8]
				SX1->X1_DEF03    := _aPerg[_ni][9]
				SX1->X1_DEF04    := _aPerg[_ni][10]
				SX1->X1_DEF05    := _aPerg[_ni][11]
				SX1->X1_F3       := _aPerg[_ni][12]
				SX1->X1_CNT01    := _aPerg[_ni][13]
				SX1->X1_VALID    := _aPerg[_ni][14]
				SX1->X1_DECIMAL  := _aPerg[_ni][15]
			MsUnLock()
		EndIf
	Next _ni

Return

/*
	Apresenta a Mensagem no Console do Protheus
*/
Static Function showLogInConsole(cMsg)

	libOzminerals.u_showLogInConsole(cMsg,cSintaxeRotina)

Return
