#Include "Protheus.Ch"
#Include "ApWebSrv.Ch"
#Include "TopConn.Ch"
#Include "TbiConn.Ch"
#INCLUDE "totvs.ch"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"
#include "rwmake.ch"
#Include "AP5Mail.ch"

/*/{Protheus.doc} OZ34WS04

    WEB SERVICE DE REEMBOLSO PAGAMENTO ANTECIPADO - ARGO - OZminerals 

@type function
@autor  Fabio Santos - CRM 
@since 09/06/2024
@version P12
@database SQL SERVER 

@Obs 

	Somente ser� gerado o adiantamento Se o status for awaitingIssue

@See u_JobPgtoPAArgo()	

@nested-tags:Frameworks/OZminerals
/*/ 
User Function OZ34WS04()
	Local oRest             := nil as object 
	Local oJson             := nil as object
	Local lExibeToken       := .T. as logcal   
	Local aHeader           := {}  as array
	Local cTkArgo           := ""  as character
	Local cLog              := ""  as character 
	Local cToken            := ""  as character  
	Local bObject           := {||} 

	Private cSintaxeRotina  := ""  as character
	Private cEnderecoApi    := ""  as character
	Private cUserName       := ""  as character
	Private cKeyPassword    := ""  as character
	Private cReseller       := ""  as character
	Private cCorp           := ""  as character
	Private cGranttype      := ""  as character 
	Private cUsrEviroment   := ""  as character 
	Private cKeyEnviroment  := ""  as character 

	Public cAdt             := .F. as logical  

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
	cSintaxeRotina          := ProcName(0)

	//RpcSetEnv( cEmpAnt,cFilAnt, cUsrEviroment, cKeyEnviroment, "FIN", "FINA050",)

	oRest:SetPath("/oauth/access-token/")

	aAdd(aHeader,"Content-Type: application/json")
	aAdd(aHeader,"Authorization: " +cTkArgo)

	oJson["username"]       := AllTrim(cUserName)
	oJson["password"]       := AllTrim(cKeyPassword)
	oJson["reseller"]       := AllTrim(cReseller)
	oJson["corp"]           := AllTrim(cCorp)
	oJson["grant_type"]     := AllTrim(cGranttype)

	oRest:SetPostParams(oJson:ToJson())

    // REALIZA O M�TODO POST E VALIDA O RETORNO
	If ( oRest:Post(aHeader) )
		cToken := oRest:getResult()
		u_YGETLIST(cToken)             // CHAMA O METODO DE LISTA
		If ( lExibeToken )
			cLog := "Informa��es do Token :"+cToken
			ShowLogInConsole(cLog)
		EndIf
	Else
		cLog := "POST: " + oRest:GetLastError()
		ShowLogInConsole(cLog)
	EndIf

Return

/*/{Protheus.doc} YGETLIST

    METODO QUE RETORNA LISTA DOS IDS DE REEMBOLSOS
	//https://api.useargo.com/argo/v2/requests/?products=advancedPayment

@type function
@autor  Fabio Santos - CRM 
@since 18/08/2024
@version P12
@database SQL SERVER 

@nested-tags:Frameworks/OZminerals
/*/ 
User Function YGETLIST(cToken)
	Local oRest1    		:= nil as object 
	Local oJson     		:= nil as object 
	Local aHeader1  		:= {}  as array 
	Local aVetor    		:= {}  as array 
	Local aItens    		:= {}  as array 
	Local lSucess1  		:= .F. as logical
	Local lPermiteExecutar  := .F. as logical
	Local nx        		:= 0   as integer 
	Local nConta    		:= 0   as integer  
	Local cCliID    		:= ""  as character 
	Local cCodigoID 		:= ""  as character 
	Local cRet1     		:= ""  as character
	Local cErr      		:= ""  as character
	Local cDt001    		:= ""  as character
	Local cDt002    		:= ""  as character
	Local cEmpBkp 			:= ""  as character
	Local cFilBkp 			:= ""  as character
	Local cNumEmpBkp		:= ""  as character
	Local cNumEmp			:= ""  as character
	Local dDataPA   		:= ""  as character
	Local cRetData  		:= ""  as character
	Local cStatus           := ""  as character
	Local cIniData          := ""  as character

 	cEmpBkp    				:= cEmpAnt
	cFilBkp    				:= cFilAnt
	cNumEmpBkp 				:= cNumEmp
	cEmpAnt    				:= cEmpAnt
	cFilAnt    				:= cFilAnt
	cNumEmp    				:= cEmpAnt + cFilAnt
	OpenFile(cNumEmp)

	cCodigoID       		:= GetNewPar("OZ_CODID","a52ef450-3d04-41ee-915c-1b5c1603ad72")
	oRest1          		:= FwRest():New(cEnderecoApi)
	cCliID          		:= Alltrim(cCodigoID)
	dDataPA         		:= CtoD("")
	cDt001          		:= CtoD("")
	cDt002          		:= CtoD("")
	cIniData                := CtoD(GetNewPar("?","08/10/2024")) 
    // Cria o objeto JSON e popula ele a partir da string
	oJson           		:= JSonObject():New()
	cErr            		:= oJSon:fromJson(cToken)

	If ( !empty(cErr) )
	    ShowLogInConsole(cErr)
		Return
	EndIf

    // Agora vamos ler as propriedades com GetJSonObject()
	cToken := oJson:GetJSonObject('access_token')

	aAdd(aHeader1,"access_token: "+ cToken)
	aAdd(aHeader1,"client_id: "+ cCliID)

	cDt001  := cIniData
	cDt002  := LastDate(dDataBase)

	nConta++ 
	lSucess1  := .F.
	nx        := 0
	aVetor    := {}
	aItens    := {}
	cRet1     := "" 

	oRest1:SetPath("/argo/v2/requests/?products=advancedPayment")

	If ( lSucess1 := oRest1:Get(aHeader1) ) 

		///Recebe Resposta do metodo Get
		cRet1   := oRest1:GetResult()

		///Formata resposta do metodo Get
		cRet1   := DecodeUTF8(cRet1)
		FWJsonDeserialize(cRet1,@oRest1)

		///Separa os Reembolsos/Presta��es de conta a partir do cRet1
		aVetor  := SubStr(cRet1,3)
		aVetor  := Separa(aVetor,"{",.t.)

		///Verifica item a item
		For nx := 1 To Len(aVetor)

			lPermiteExecutar := .F.
			cID      		 := oRest1[nx]:requestId
			cRetData 		 := oRest1[nx]:CHANGEDATE
			dDataPA  		 := CtoD(SubStr(cRetData,9,2)+"/"+SubStr(cRetData,6,2)+"/"+SubStr(cRetData,1,4))
			cStatus  		 := oRest1[nx]:EXPENSESTATUS

			If AllTrim(cStatus) == AllTrim("awaitingIssue")
				lPermiteExecutar := .T.
			Else 
				lPermiteExecutar := .F.
			EndIf

			If ( lPermiteExecutar )
				If (dDataPA >= cDt001 .And. dDataPA <= cDt002 )
					//Separa os itens do aVetor
					aItens  := Separa(aVetor[nx],",",.t.)

					///Verifica se o vetor tem no minimo 6 campos
					If ( Len(aItens) >= 6 )

						///Formata para receber somente o campo

						If ( oRest1[nx]:ADVANCEPAYMENTSTATUS == "awaitingPayment" )
							cAdt := .T.
						EndIf
					EndIf
					If ( cAdt )
						XGETDADOS1(cID,cToken,cCliID) // CHAMA O METODO QUE FILTRA OS REEMBOLSOS
					EndIf
				EndIf
			Else 
				cRet1:= "O Status "+cStatus+" � diferente de awaitingIssue, somente este status Grava o PA"
				ShowLogInConsole(cRet1)
			EndIf
		Next nx
	Else
		cRet1:= oRest1:GetLastError()
		ShowLogInConsole(cRet1)
	EndIf

	If ( !Empty(AllTrim(cEmpBkp)))
		cEmpAnt := cEmpBkp
		cFilAnt := cFilBkp
		cNumEmp := cEmpAnt + cFilAnt
		OpenFile(cNumEmp)
	EndIf 

Return

/*
    METODO QUE SELECIONA O CENTRO DE CUSTO DE DESTINO
	https://api.useargo.com/argo/v2/requests/06f13cb8-b478-ee11-a8a0-000d3a7a7880/allocations
*/
Static Function XGETDADOS1(cID,cToken,cCliID)
	Local oRest2      := nil as object 
	Local aHeader2    := {}  as array 
	Local lSucess2    := .F. as logical 
	Local cRet2       := ""  as character
    Local cCostCenter := ""  as character

	oRest2            := FwRest():New(cEnderecoApi)

	aAdd(aHeader2,"client_id: "+ cCliID)
	aAdd(aHeader2,"access_token: "+ cToken)
	aAdd(aHeader2,"Content-Type: application/json")

	oRest2:SetPath("/argo/v2/requests/"+cID+"/allocations")

	If ( lSucess2 := oRest2:Get(aHeader2) )

		cRet2 := oRest2:GetResult()
		cRet2 := DecodeUTF8(cRet2)

		FWJsonDeserialize(cRet2,@oRest2)

		If ( Len(oRest2) > 0 )
			cCostCenter     := PADR(oRest2[1]:COSTCENTERCODE,TamSx3("PAK_CODCC")[1])
			cCostCenter     := Upper(cCostCenter)
		EndIf

		XGETDADOS2(cID,cToken,cCliID,cCostCenter)  // CHAMA O METODO QUE RETORNA DADOS PRO REEMBOLSO

	Else
		cRet2:= oRest2:GetLastError()
		ShowLogInConsole(cRet2)
		Return
	EndIf

Return

/*
    METODO QUE RETORNA O NUMERO DA SOLICITA��O
	https://api.useargo.com/argo/v2/requests/06f13cb8-b478-ee11-a8a0-000d3a7a7880/allocations
*/
Static Function XGETDADOS2(cID,cToken,cCliID,cCostCenter)
	Local oRest3    := nil as object
	Local aHeader3  := {}  as array 
	Local lSucess3  := .F. as logical
	Local lIssue    := .F. as logical
	Local cRet3     := ""  as character
	Local cIssue    := ""  as character
	Local cPayment  := ""  as character
	Local cStatus   := ""  as character 

	Public cNum     := ""  as character
	Public cAprovDT := ""  as character

    cIssue          := GetNewPar("OZ_PAYMEN1","awaitingIssue") 
    cPayment        := GetNewPar("OZ_PAYMEN2","awaitingPayment") 
	oRest3          := FwRest():New(cEnderecoApi)

	aAdd(aHeader3,"client_id: "   + cCliID)
	aAdd(aHeader3,"access_token: "+ cToken)

	oRest3:SetPath("/argo/v2/requests/"+cID)

	If ( lSucess3 := oRest3:Get(aHeader3) )

		cRet3 := oRest3:GetResult()
		cRet3 := DecodeUTF8(cRet3)
		FWJsonDeserialize(cRet3,@oRest3)

		cNum     := AllTrim(Str(oRest3:REQUESTNUMBER))
		cNum     := PadR(StrZero(Val(cNum),9),TamSx3("E2_NUM")[1])
		cStatus  := oRest3:EXPENSESTATUS

		If ( AllTrim(cIssue) == AllTrim(cStatus)  )
			lIssue := .T.
		Else  
			lIssue := .F. 
		EndIf

		If ( lIssue )
			If ( oRest3:APPROVALCOSTDATE <> nil ) 
				cAprovDT := oRest3:APPROVALCOSTDATE
				XGETDADOS3(cID,cToken,cCliID,cCostCenter, lIssue)  // CHAMA O METODO QUE RETORNA DADOS PRO REEMBOLSO
			EndIf
		EndIf

		If ( !lIssue ) 
			cRet3:= "Tipo Pagamento � o status "+cStatus+" do Argo, diferente de awaitingIssue ou awaitingPayment"
			ShowLogInConsole(cRet3)
			Return
		EndIf

	Else
		cRet3:= oRest3:GetLastError()
		ShowLogInConsole(cRet3)
		Return
	EndIf

Return

/*
    METODO QUE RETORNA OS DADOS DO ID PARA REEMBOLSO
	https://api.useargo.com/argo/v2/requests/06f13cb8-b478-ee11-a8a0-000d3a7a7880/requesters
*/
Static Function XGETDADOS3(cID, cToken, cCliID, cCostCenter, lIssue)
	Local oRest4     := nil  as object 
	Local aHeader4   := {}   as array 
	Local lSucess4   := .F.  as logical 
	Local cRet4      := ""   as character
	Local ccpf       := ""   as character
	Local cuserid    := ""   as character 
	Local cEmail     := ""   as character 

	Public cNomeArgo := ""  as character

    oRest4           := FwRest():New(cEnderecoApi)

	aAdd(aHeader4,"access_token: "+ cToken)
	aAdd(aHeader4,"client_id: "+ cCliID)

	oRest4:SetPath("/argo/v2/requests/"+cID+"/requesters")

	If ( lSucess4 := oRest4:Get(aHeader4) )

		cRet4 := oRest4:GetResult()
		cRet4 := DecodeUTF8(cRet4)
		FWJsonDeserialize(cRet4,@oRest4)

		If ( oRest4:cpf <> nil )   
			ccpf        := oRest4:cpf
		EndIF
		cuserid     := oRest4:userid
		cEmail      := oRest4:EMAIL
		cNomeArgo   := Lower(oRest4:FirstName +" "+ oRest4:LastName)

		If ( lIssue )
			u_YGetDados4(cID,cToken,cCliID,ccpf,cuserid,cEmail,cCostCenter) // CHAMA O METODO QUE RETORNA DADOS PRO REEMBOLSO
		EndIf 

		If ( !lIssue )
			cRet4 := "Este Rengistro N�o � Adiantamento Aprovado e Nem Reembolso." + CRLF
			cRet4 += "Ser� necessario consultar no ARGO de tem os seguintes status:" + CRLF
			cRet4 += "status : awaitingIssue ( Foi aprovado e n�o h� pagemnto ainda)" + CRLF
			cRet4 += "status : awaitingPayment ( Foi aprovado o reembolso)" + CRLF
			ShowLogInConsole(cRet4)
			Return
		EndIf	
	Else
		cRet4:= oRest4:GetLastError()
		ShowLogInConsole(cRet4)
		Return
	EndIf

Return

/*
	METODO PARA PEGAR ADIANTAMENTO 
	https://api.useargo.com/argo/v2/expense/cb717b4d-d97c-ee11-a8a2-000d3a7a7880/advancepayments
*/
User Function YGetDados4(cID,cToken,cCliID,ccpf,cuserid,cEmail,cCostCenter)
	Local oRest5     := nil as object 
	Local aHeader5   := {}  as array 
	Local aRetArgo   := {}  as array  
	Local aCustoArgo := {}  as array 
	Local aRegraCtb  := {}  as array  
	Local aBuscaCC   := {}  as array   
	Local lSucess5   := .F. as logical 
	Local lPassa     := .F. as logical 
	Local cContaCtb  := ""  as character
	Local cRet5      := ""  as character
	Local cArgoEmp   := ""  as character
	Local cEmpTit    := ""  as character
	Local cFilTit    := ""  as character
	Local cLog       := ""  as character
	Local cCentroCst := ""  as character  
 	Local cRetCCusto := ""  as character  
	Local cItemCtb   := ""  as character 
	Local cCredConta := ""  as character 
	Local cDebConta  := ""  as character 
	Local cCCusto    := ""  as character 
	Local cItemCta   := ""  as character 
	Local cClasseVlr := ""  as character 
	Local nI         := 0   as integer
	Local nValTot    := 0   as integer 
	Local nValor     := 0   as integer
	Local nEmpArgo   := 0   as integer 
	Local nCstArgo   := 0   as integer
	Local nRegCtb    := 0   as integer 
	Local nBuscaCC   := 0   as integer 

	Public cParc     := 0   as integer 
	Public cTipo     := ""  as character
	Public cPrefixo  := ""  as character
	Public oRateio   := nil as object 

    oRest5           := FwRest():New(cEnderecoApi)

	aAdd(aHeader5,"access_token: "+ cToken)
	aAdd(aHeader5,"client_id: "+ cCliID)

	oRest5:SetPath("/argo/v2/expense/"+cID+"/advancepayments") //ADIANTAMENTO

	If ( lSucess5 := oRest5:Get(aHeader5) )

		cRet5 := oRest5:GetResult()
		cRet5 := DecodeUTF8(cRet5)
		FWJsonDeserialize(cRet5,@oRest5)

		///Se for Adiantamento
		If ( cAdt )
			If Len(oRest5) > 0
				oRateio    := oRest5
				aRetArgo   := {} 
				nEmpArgo   := 0
				aCustoArgo := {}
				nCstArgo   := 0
				aRegraCtb  := {}
				nRegCtb    := 0  
				cContaCtb  := ""
				lPassa     := .F.
				cLog       := ""
				///Soma os valores
				For nI := 1 To Len(oRest5)
					nValor    := oRest5[nI]:price
					nValTot   := nValTot + nValor
				Next nI

				nValor     := nValTot
				cParc      := Padr("01",TamSx3("E2_PARCELA")[1])
				cHIst      := "Integra��o Argo"
				dEmiss     := cAprovDT
				cTipo      := Padr("PA",TamSx3("E2_TIPO")[1])
				cPrefixo   := PadR("PA",TamSx3("E2_PREFIXO")[1])
				cArgoEmp   := Alltrim(oRest5[1]:INTEGRATIONCODECOMPANY) //Empresa Argo
				cContaCtb  := Alltrim(oRest5[1]:CODELEDGERACCOUNT) //Conta Contabil 
				cCentroCst := cCostCenter //Centro Custo
				aRetArgo   := {}
				nEmpArgo   := 0
				aRetArgo   := CheckEmpresaArgo(cArgoEmp)
				If ( Len(aRetArgo) > 0 )
					For nEmpArgo := 1 To Len(aRetArgo) 
						If ( Alltrim(aRetArgo[nEmpArgo][01]) == AllTrim(cArgoEmp))
							cEmpTit := Alltrim(aRetArgo[nEmpArgo][02])
							cFilTit := Alltrim(aRetArgo[nEmpArgo][03])
							If ( !Empty(cEmpTit) .And. !Empty(cFilTit) )
								lPassa := .T.
								cLog := "Localizado a Empresa No Argo "+cArgoEmp+" Conforme Cadastro Na Rotina - OZ06M01"
								ShowLogInConsole(cLog)
							EndIf
						EndIf
					Next nEmpArgo
				EndIf

				aCustoArgo := {}	
				nCstArgo   := 0
				cContaCtb  := BuscaContaContabil(cEmpTit, cFilTit, cContaCtb)
				aCustoArgo := CentroCustoArgo(cEmpTit, cFilTit, cCentroCst)
				If ( Len(aCustoArgo) > 0 )
					For nCstArgo := 1 To Len(aCustoArgo) 
						cRetCCusto := Alltrim(aCustoArgo[nCstArgo][01])
						cItemCtb   := Alltrim(aCustoArgo[nCstArgo][02])
					Next nCstArgo
				EndIf

				aRegraCtb  := {}
				nRegCtb    := 0
				aRegraCtb  := RegraContabil(cContaCtb, cRetCCusto, cItemCtb)
				If ( Len(aRegraCtb) > 0 )
					For nRegCtb := 1 To Len(aRegraCtb) 
						If ( Alltrim(aRegraCtb[nRegCtb][01]) == "01")
							cCredConta := Alltrim(aRegraCtb[nRegCtb][02])
							cDebConta  := Alltrim(aRegraCtb[nRegCtb][03])
							cCCusto    := Alltrim(aRegraCtb[nRegCtb][04])
							cItemCta   := Alltrim(aRegraCtb[nRegCtb][05])
							cClasseVlr := Alltrim(aRegraCtb[nRegCtb][06]) 
						EndIf
						If ( Alltrim(aRegraCtb[nRegCtb][01]) == "02")
							cCredConta := Alltrim(aRegraCtb[nRegCtb][02])
							cDebConta  := Alltrim(aRegraCtb[nRegCtb][03])
							cCCusto    := Alltrim(aRegraCtb[nRegCtb][04])
							cItemCta   := Alltrim(aRegraCtb[nRegCtb][05])
							cClasseVlr := Alltrim(aRegraCtb[nRegCtb][06]) 
						EndIf
					Next nRegCtb
				Else 
					aBuscaCC  := {}
					nBuscaCC  := 0 
					aBuscaCC  := ArgoBuscaCC(cRetCCusto, cItemCtb)
					If ( Len(aBuscaCC) > 0 )
						For nBuscaCC   := 1 To Len(aBuscaCC) 
							cRetCCusto := Alltrim(aBuscaCC[nBuscaCC][01])
							cItemCtb   := Alltrim(aBuscaCC[nBuscaCC][02])
							cClasseVlr := Alltrim(aBuscaCC[nBuscaCC][03]) 
							cContaCtb  := Alltrim(aBuscaCC[nBuscaCC][04]) 
						Next nBuscaCC
					EndIf
					cDebConta  := cContaCtb
					cCredConta := "210101002"
					cCCusto    := cRetCCusto
					cItemCta   := cItemCtb
					cClasseVlr := cClasseVlr
					cLog       := "Regra N�o Localizada!" + CRLF
					ShowLogInConsole(cLog)
				EndIf

				If ( Alltrim(cEmpTit) == Alltrim(cEmpAnt) )
					If ( lPassa )
						u_YGeraPA(nValor,ccpf,cuserid,cID,dEmiss,cHIst,cEmail,cEmpTit,cFilTit,cCostCenter,cCredConta,cDebConta,cCCusto,cItemCta,cClasseVlr) // CHAMA A FUN��O QUE GERA PA
					Else 
						cLog := "Esta Empresa No Argo "+cArgoEmp+" N�o Existe De/Para no Cadastro, Favor Verificar a Rotina - OZ06M01"
						ShowLogInConsole(cLog)
						Return
					EndIf 
				Else 
					cLog := "Esta Empresa do � "+cEmpTit+" No Argo, e no Protheus � "+cEmpAnt+", Portanto, n�o ser� carregado no Protheus, Favor Verificar se a Empresa Existe!"
					ShowLogInConsole(cLog)
					Return
				EndIf
			EndIf
		EndIf
	Else
		cRet5:= oRest5:GetLastError()
		ShowLogInConsole(cRet5)
		Return
	EndIf

Return

/*
 	Busca Ultimo Titulo do Argo na tabela SE2 
*/
Static Function CheckEmpresaArgo(cEmpArgo)
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

	cQuery               := QryEmpresaArgo(cEmpArgo)
	cAlias               := MpSysOpenQuery(cQuery)

	If ( !Empty(cAlias) )

		dbSelectArea(cAlias)

		If ( (cAlias)->(!EOF()) )

			While ((cAlias)->(!EOF()))

				aAdd(aRetorno,{(cAlias)->PAP_EMPARG,;
							   (cAlias)->PAP_EMPPRO,;
							   (cAlias)->PAP_FILPRO})

				(cAlias)->(dbSkip())
			EndDo
		EndIf 

		(cAlias)->(dbCloseArea())
	Else
		cLog += " Empresa e Filial: " + cFilAnt + " - N�o Localizada"
	EndIf

	If ( !Empty(cLog) )
		showLogInConsole(StrTran(cLog,CRLF,", ") )
	Endif

	RestArea( aArea )

Return (aRetorno)

/*
	Monta a Query para carregar dados - Busca na SE2
*/
Static Function QryEmpresaArgo(cEmpArgo)
	Local cQuery 	    := ""  as character

	cQuery := " SELECT " + CRLF
	cQuery += "		   PAP_EMPARG AS PAP_EMPARG,      " + CRLF
	cQuery += "		   PAP_EMPPRO AS PAP_EMPPRO,      " + CRLF
	cQuery += "		   PAP_FILPRO AS PAP_FILPRO      " + CRLF
	cQuery += " FROM   " + CRLF
	cQuery += " 	   " + RetSQLTab("PAP") + CRLF
	cQuery += " WHERE " + CRLF
	cQuery += " 				  1 = 1 " + CRLF
	cQuery += "   				  AND PAP_EMPARG  =  " + ValToSql(cEmpArgo)  + "  " + CRLF
	cQuery += "   	              AND " + RetSqlDel("PAP")     + CRLF

	u_ChangeQuery("\sql\WSARGO_ChecaEmpresaArgo.sql", @cQuery)

Return cQuery

/*
 	Busca Conta Contabil que est� vindo do Argo 
*/
Static Function BuscaContaContabil(cCodEmp, cCodFil, cConta)
	Local aArea                 := {}  as array
	Local cRetorno              := ""  as character
	Local cAlias	            := ""  as character
	Local cQuery	            := ""  as character
	Local cLog                  := ""  as character

    aArea                       := GetArea()

	If ( !Empty(cAlias) )
		dbSelectArea(cAlias)
		(cAlias)->(dbCloseArea())
	EndIf

	cQuery               := QryContaContabil(cCodEmp, cCodFil, cConta)
	cAlias               := MpSysOpenQuery(cQuery)

	If ( !Empty(cAlias) )

		dbSelectArea(cAlias)

		If ( (cAlias)->(!EOF()) )

			While ((cAlias)->(!EOF()))

				cRetorno := (cAlias)->PAL_CONTA

				(cAlias)->(dbSkip())
			EndDo
		EndIf 

		(cAlias)->(dbCloseArea())
	Else
		cLog += "Conta Contabil N�o Localizado"
	EndIf

	If ( !Empty(cLog) )
		showLogInConsole(StrTran(cLog,CRLF,", ") )
	Endif

	RestArea( aArea )

Return (cRetorno)

/*
	Monta a Query para Buscar Conta Contabil do Argo
*/
Static Function QryContaContabil(cCodEmp, cCodFil, cConta)
	Local cQuery 	    := ""  as character

	cQuery := " SELECT 							 " + CRLF
	cQuery += "		   PAL_EMP    AS PAL_EMP,    " + CRLF
	cQuery += "		   PAL_FIL    AS PAL_FIL,    " + CRLF
	cQuery += "		   PAL_CODCTA AS PAL_CODCTA, " + CRLF
	cQuery += "		   PAL_CONTA  AS PAL_CONTA   " + CRLF 
	cQuery += " FROM   " + CRLF
	cQuery += " 	   " + RetSQLTab("PAL") + CRLF
	cQuery += " WHERE  " + CRLF
	cQuery += " 	   1 = 1 " + CRLF
	cQuery += "   	   AND PAL_CODCTA =  " + ValToSql(cConta)  + "  " + CRLF
	cQuery += "   	   AND PAL_EMP    =  " + ValToSql(cCodEmp) + "  " + CRLF
	cQuery += "   	   AND " + RetSqlDel("PAL")     + CRLF

	u_ChangeQuery("\sql\WSARGO_QryContaContabil.sql", @cQuery)

Return cQuery

/*
 	Busca Centro de Custo Argo para o Protheus 
*/
Static Function CentroCustoArgo(cCodEmp, cCodFil, cCentroCstArgo)
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

	cQuery               := QryCentroCustoArgo(cCodEmp, cCodFil, cCentroCstArgo)
	cAlias               := MpSysOpenQuery(cQuery)

	If ( !Empty(cAlias) )

		dbSelectArea(cAlias)

		If ( (cAlias)->(!EOF()) )

			While ((cAlias)->(!EOF()))

				aAdd(aRetorno,{ (cAlias)->PAK_CC,;
								(cAlias)->PAK_ITEM})

				(cAlias)->(dbSkip())
			EndDo
		EndIf 

		(cAlias)->(dbCloseArea())
	Else
		cLog += " Centro de Custo e Item Contabil N�o Localizado"
	EndIf

	If ( !Empty(cLog) )
		showLogInConsole(StrTran(cLog,CRLF,", ") )
	Endif

	RestArea( aArea )

Return (aRetorno)

/*
	Monta a Query para Buscar Centro de Custo do Argo
*/
Static Function QryCentroCustoArgo(cCodEmp, cCodFil, cCentroCstArgo)
	Local cQuery 	    := ""  as character

	cQuery := " SELECT " + CRLF
	cQuery += "		   PAK_EMP   AS PAK_EMP,   " + CRLF
	cQuery += "		   PAK_FIL   AS PAK_FIL,   " + CRLF
	cQuery += "		   PAK_CODCC AS PAK_CODCC, " + CRLF
	cQuery += "		   PAK_CC    AS PAK_CC,    " + CRLF
	cQuery += "		   PAK_ITEM  AS PAK_ITEM   " + CRLF
	cQuery += " FROM   " + CRLF
	cQuery += " 	   " + RetSQLTab("PAK") + CRLF
	cQuery += " WHERE  " + CRLF
	cQuery += " 	   1 = 1 " + CRLF
	cQuery += "   	   AND PAK_CODCC  =  " + ValToSql(cCentroCstArgo)  + "  " + CRLF
	cQuery += "   	   AND PAK_EMP    =  " + ValToSql(cCodEmp)         + "  " + CRLF
	cQuery += "   	   AND PAK_FIL    =  " + ValToSql(cCodFil)         + "  " + CRLF
	cQuery += "   	   AND " + RetSqlDel("PAK")                        + CRLF

	u_ChangeQuery("\sql\WSARGO_QryCentroCustoArgo.sql", @cQuery)

Return cQuery

/*
 	Busca Regra Contabil para Gravar nos campos do Titulo 
*/
Static Function RegraContabil(cContaCtb, cCentroCusto, cItemContabil)
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

	cQuery               := QryRegraContabil(cContaCtb, cCentroCusto, cItemContabil)
	cAlias               := MpSysOpenQuery(cQuery)

	If ( !Empty(cAlias) )

		dbSelectArea(cAlias)

		If ( (cAlias)->(!EOF()) )

			While ((cAlias)->(!EOF()))

				aAdd(aRetorno,{ (cAlias)->TIPO,;
								(cAlias)->PAJ_CTAC,;
								(cAlias)->PAJ_CTAD,;
								(cAlias)->PAJ_CC,;
								(cAlias)->PAJ_ITEM,;
								(cAlias)->PAJ_CLVL})

				(cAlias)->(dbSkip())
			EndDo
		EndIf 

		(cAlias)->(dbCloseArea())
	Else
		cLog += "Regra Contabil N�o Localizada"
	EndIf

	If ( !Empty(cLog) )
		showLogInConsole(StrTran(cLog,CRLF,", ") )
	Endif

	RestArea( aArea )

Return (aRetorno)

/*
 	Busca Regra para Gravar nos campos do Titulo 
*/
Static Function ArgoBuscaCC(cRetCCusto, cItemCtb)
	Local aArea                 := {}  as array
	Local aRetorno              := {}  as array
	Local lPassa                := .F. as logical   
	Local cAlias	            := ""  as character
	Local cQuery	            := ""  as character
	Local cLog                  := ""  as character

    aArea                       := GetArea()

	If ( !Empty(cAlias) )
		dbSelectArea(cAlias)
		(cAlias)->(dbCloseArea())
	EndIf

	cQuery               := QryBuscaClvl(cRetCCusto, cItemCtb)
	cAlias               := MpSysOpenQuery(cQuery)

	If ( !Empty(cAlias) )

		dbSelectArea(cAlias)

		If ( (cAlias)->(!EOF()) )

			While ((cAlias)->(!EOF()))

				lPassa  := .F.

				If (Alltrim((cAlias)->PAJ_CTAD) == Alltrim("110302004"))
					lPassa := .F.
				Else 
					lPassa := .T.
				EndIf	            
				If ( lPassa )
					aAdd(aRetorno,{ (cAlias)->PAJ_CC,;
									(cAlias)->PAJ_ITEM,;
									(cAlias)->PAJ_CLVL,;
									(cAlias)->PAJ_CTAD})
					If Len(aRetorno) > 0
						Exit
					EndIf
				EndIf
				
				(cAlias)->(dbSkip())
			EndDo
		EndIf 

		(cAlias)->(dbCloseArea())
	Else
		cLog += "Regra Contabil N�o Localizada"
	EndIf

	If ( !Empty(cLog) )
		showLogInConsole(StrTran(cLog,CRLF,", ") )
	Endif

	RestArea( aArea )

Return (aRetorno)

/*
	Monta a Query para Buscar Conta, Centro de Custo, Item Contabil e Classe de Valor 
*/
Static Function QryRegraContabil(cContaCtb, cCentroCusto, cItemContabil)
	Local cQuery 	    := ""  as character

	cQuery := " SELECT " + CRLF
	cQuery += "		   '01'     AS TIPO,        " + CRLF
	cQuery += "		   PAJ_CTAD AS PAJ_CTAD,    " + CRLF
	cQuery += "		   PAJ_CTAC AS PAJ_CTAC,    " + CRLF
	cQuery += "		   PAJ_CC   AS PAJ_CC,      " + CRLF
	cQuery += "		   PAJ_ITEM AS PAJ_ITEM,    " + CRLF 
	cQuery += "		   PAJ_CLVL AS PAJ_CLVL     " + CRLF 
	cQuery += " FROM   " + CRLF
	cQuery += " 	   " + RetSQLTab("PAJ") + CRLF
	cQuery += " WHERE  " + CRLF
	cQuery += " 	   1 = 1 " + CRLF
	cQuery += "   	   AND PAJ_CTAC   =  " + ValToSql(cContaCtb)       + "  " + CRLF
	cQuery += "   	   AND PAJ_CC     =  " + ValToSql(cCentroCusto)    + "  " + CRLF
	cQuery += "   	   AND PAJ_ITEM   =  " + ValToSql(cItemContabil)   + "  " + CRLF
	cQuery += "   	   AND " + RetSqlDel("PAJ")                               + CRLF

	cQuery += "UNION ALL " + CRLF

	cQuery += " SELECT " + CRLF
	cQuery += "		   '02'     AS TIPO,        " + CRLF
	cQuery += "		   PAJ_CTAD AS PAJ_CTAD,    " + CRLF
	cQuery += "		   PAJ_CTAC AS PAJ_CTAC,    " + CRLF
	cQuery += "		   PAJ_CC   AS PAJ_CC,      " + CRLF
	cQuery += "		   PAJ_ITEM AS PAJ_ITEM,    " + CRLF 
	cQuery += "		   PAJ_CLVL AS PAJ_CLVL     " + CRLF 
	cQuery += " FROM   " + CRLF
	cQuery += " 	   " + RetSQLTab("PAJ") + CRLF
	cQuery += " WHERE  " + CRLF
	cQuery += " 	   1 = 1 " + CRLF
	cQuery += "   	   AND PAJ_CTAD   =  " + ValToSql(cContaCtb)       + "  " + CRLF
	cQuery += "   	   AND PAJ_CC     =  " + ValToSql(cCentroCusto)    + "  " + CRLF
	cQuery += "   	   AND PAJ_ITEM   =  " + ValToSql(cItemContabil)   + "  " + CRLF
	cQuery += "   	   AND " + RetSqlDel("PAJ")                               + CRLF

	u_ChangeQuery("\sql\WSARGO_QryRegraContabil.sql", @cQuery)

Return cQuery

/*
	Monta a Query para Buscar Centro de Custo, Item Contabil e Classe de Valor 
*/
Static Function QryBuscaClvl(cCentroCusto, cItemContabil)
	Local cQuery 	    := ""  as character

	cQuery := " SELECT " + CRLF
	cQuery += "		   PAJ_CC   AS PAJ_CC,      " + CRLF
	cQuery += "		   PAJ_ITEM AS PAJ_ITEM,    " + CRLF 
	cQuery += "		   PAJ_CLVL AS PAJ_CLVL,    " + CRLF 
	cQuery += "		   PAJ_CTAD AS PAJ_CTAD     " + CRLF
	cQuery += " FROM   " + CRLF
	cQuery += " 	   " + RetSQLTab("PAJ") + CRLF
	cQuery += " WHERE  " + CRLF
	cQuery += " 	   1 = 1 " + CRLF
	cQuery += "   	   AND PAJ_CC     =  " + ValToSql(cCentroCusto)    + "  " + CRLF
	cQuery += "   	   AND PAJ_ITEM   =  " + ValToSql(cItemContabil)   + "  " + CRLF
	cQuery += "   	   AND " + RetSqlDel("PAJ")                               + CRLF

	u_ChangeQuery("\sql\WSARGO_QryBuscaClvl.sql", @cQuery)

Return cQuery

/*/{Protheus.doc} YGeraPA

    FUN��O QUE GERA TITULO DE PAGAMENTO ANTECPADO NO FINANCEIRO

@type function
@autor  Fabio Santos - CRM
@since 18/08/2024
@version P12
@database SQL SERVER 

@nested-tags:Frameworks/OZminerals
/*/ 
User Function YGeraPA(nValor,ccpf,cuserid,cID,dEmiss,cHIst,cEmail,cEmpTit,cFilTit,cCostCenter,cCredConta,cDebConta,cCCusto,cItemCta,cClasseVlr)
	Local lReckLock     := .T. as logical 
	Local cFor          := ""  as character
	Local cLoja         := ""  as character
	Local cData         := ""  as character
	Local cLog          := ""  as character
	Local cEmpBkp 		:= ""  as character
	Local cFilBkp 		:= ""  as character
	Local cNumEmpBkp    := ""  as character
	Local cNumEmp		:= ""  as character
	Local aExecAuto     := {}  as array 
	Local aArea         := {}  as array

	Private lMsErroAuto := .F. as logical

	aArea               := GetArea()
 	cEmpBkp    			:= cEmpAnt
	cFilBkp    			:= cFilAnt
	cNumEmpBkp 			:= cNumEmp
	cEmpAnt    			:= cEmpTit
	cFilAnt    			:= cFilTit
	cNumEmp    			:= cEmpAnt + cFilAnt
	OpenFile(cNumEmp)

    cData               := IIF(LEN(AllTrim(str(Day(dDataBase))))<2,"0"+AllTrim(str(Day(dDataBase))),;
                                   AllTrim(str(Day(dDataBase))))+"/"+IIF(LEN(AllTrim(str(Month(dDataBase))))<2,;
                                   "0"+AllTrim(str(Month(dDataBase))),AllTrim(str(Month(dDataBase))))+"/"+;
                                   AllTrim(str(Year(dDataBase)))
	cFor	            := Posicione("SA2",3,xFilial("SA2")+ccpf,"A2_COD"    )
	cLoja	            := Posicione("SA2",3,xFilial("SA2")+ccpf,"A2_LOJA"   )
	cNome	            := Posicione("SA2",3,xFilial("SA2")+ccpf,"A2_NOME"   )

	U_DadosBanc()

    DbSelectArea("ZZ1")
    ZZ1->(DbSetOrder(1))

    DbSelectArea("SE2")
    SE2->(DbSetOrder(1))

	If ( !Empty(AllTrim(cFor)) .AND. !Empty(AllTrim(cLoja)) ) 

		If ( !Empty(AllTrim(cBanco)) .AND. !Empty(AllTrim(cAgencia)) .AND. !Empty(AllTrim(cConta)) ) 

			If ( !SE2->(DbSeek(xFilial("SE2") + cPrefixo + cNum + cParc + cTipo + cFor + cLoja )) )

				If ( ZZ1->(dbSeek(  PAD(xFilial("ZZ1")  ,TAMSX3("ZZ1_FILIAL") [1]) +; 
									PAD(cID             ,TAMSX3("ZZ1_IDREQ")  [1]) +;
									PAD(cParc           ,TAMSX3("ZZ1_PARCE")  [1]) +;
									PAD("Integrado"     ,TAMSX3("ZZ1_STATUS") [1]) )))
                    lReckLock := .F.
                Else 
                    lReckLock := .T.
				EndIf

				//Prepara o array para o execauto
				aExecAuto := {}
				dEmiss := StrTran(substr(dEmiss,1,10), "-", "")
				dEmiss := stod(dEmiss)

				aAdd(aExecAuto, {"E2_NUM"    , cNum       , Nil})
				aAdd(aExecAuto, {"E2_PREFIXO", cPrefixo   , Nil})
				aAdd(aExecAuto, {"E2_PARCELA", cParc      , Nil})
				aAdd(aExecAuto, {"E2_TIPO"   , cTipo      , Nil})
				aAdd(aExecAuto, {"E2_NATUREZ", "209011"   , Nil})
				aAdd(aExecAuto, {"E2_FORNECE", cFor       , Nil})
				aAdd(aExecAuto, {"E2_LOJA"   , cLoja      , Nil})
				aAdd(aExecAuto, {"E2_NOMFOR" , cNome      , Nil})
				aAdd(aExecAuto, {"E2_EMISSAO", dEmiss     , Nil}) 
				aAdd(aExecAuto, {"E2_VENCTO" , dDataBase+5  , Nil})
				aAdd(aExecAuto, {"E2_VENCREA", dDataBase+5  , Nil})
				aAdd(aExecAuto, {"E2_VALOR"  , nValor     , Nil})
				aAdd(aExecAuto, {"E2_HIST"   , cHIst      , Nil})
				aAdd(aExecAuto, {"E2_MOEDA"  , 1          , Nil})
				aAdd(aExecAuto, {"E2_XID"    , cID        , Nil})  
				aAdd(aExecAuto, {"E2_XCTAC"  , cCredConta , Nil})
				aAdd(aExecAuto, {"E2_XCTAD"  , cDebConta  , Nil})
				aAdd(aExecAuto, {"E2_XCC"    , cCCusto    , Nil})
				aAdd(aExecAuto, {"E2_XITEMCT", cItemCta   , Nil})
				aAdd(aExecAuto, {"E2_XCLVL"  , cClasseVlr , Nil})
				aAdd(aExecAuto, {"AUTBANCO"  , cBanco     ,,Nil})
				aAdd(aExecAuto, {"AUTAGENCIA", cAgencia   ,,Nil})
				aAdd(aExecAuto, {"AUTCONTA"  , cConta     ,,Nil})

				Begin Transaction

					lMsErroAuto := .F.
					MSExecAuto({|y,z| FINA050(y,z)},aExecAuto,3)   // SE2 Contas a Pagar em aberto MESTRE

					If ( lMsErroAuto )
						DisarmTransaction()
						RollBackSX8()

						If ( lReckLock )
							If ( RecLock("ZZ1",lReckLock) )
								ZZ1->ZZ1_IDREQ   := cID
								ZZ1->ZZ1_FILCAD  := cFilAnt
								ZZ1->ZZ1_NUMREQ  := cNum
								ZZ1->ZZ1_IDFORN  := cFor
								ZZ1->ZZ1_NOME    := cNome
								ZZ1->ZZ1_VALOR   := nValor
								ZZ1->ZZ1_PARCE   := cParc
								ZZ1->ZZ1_EMISSD  := SubStr(cAprovDT,1,10)
								ZZ1->ZZ1_EMISSH  := SubStr(cAprovDT,12,8)
								ZZ1->ZZ1_PREFIX  := cPrefixo
								ZZ1->ZZ1_DTINTE  := cData
								ZZ1->ZZ1_HRINTE  := Time()
								ZZ1->ZZ1_STATUS  := "N�o Integrado"
								ZZ1->ZZ1_STS     := "1"
								ZZ1->ZZ1_HIST    := cHist
								ZZ1->ZZ1_OBS     := MostraErro()
								ZZ1->(MsUnlock())
							EndIf
						EndIf
						ShowLogInConsole(MostraErro())
					Else
						ConfirmSX8()
						If ( lReckLock )
							If ( RecLock("ZZ1",lReckLock) )
								ZZ1->ZZ1_IDREQ   := cID
								ZZ1->ZZ1_FILCAD  := cFilAnt
								ZZ1->ZZ1_NUMREQ  := cNum
								ZZ1->ZZ1_IDFORN  := cFor
								ZZ1->ZZ1_NOME    := cNome
								ZZ1->ZZ1_VALOR   := nValor
								ZZ1->ZZ1_PARCE   := cParc
								ZZ1->ZZ1_EMISSD  := SubStr(cAprovDT,1,10)
								ZZ1->ZZ1_EMISSH  := SubStr(cAprovDT,12,8)
								ZZ1->ZZ1_PREFIX  := cPrefixo
								ZZ1->ZZ1_DTINTE  := cData
								ZZ1->ZZ1_HRINTE  := Time()
								ZZ1->ZZ1_STATUS  := "Integrado"
								ZZ1->ZZ1_STS     := "1"
								ZZ1->ZZ1_HIST    := cHist
								ZZ1->ZZ1_OBS     := ""
								ZZ1->(MsUnlock())
							EndIf
						EndIf
						cLog := "Integrado com Sucesso"
						ShowLogInConsole(cLog)
					Endif
				End Transaction
			Else
				If ( ZZ1->(dbSeek(  PAD(xFilial("ZZ1")  ,TAMSX3("ZZ1_FILIAL") [1]) +; 
									PAD(cID             ,TAMSX3("ZZ1_IDREQ")  [1]) +;
									PAD(cParc           ,TAMSX3("ZZ1_PARCE")  [1]) +;
									PAD("Integrado"     ,TAMSX3("ZZ1_STATUS") [1]) )))
                    lReckLock := .F.
                Else 
                    lReckLock := .T.
				EndIf

				If ( lReckLock )
					Begin Transaction
						If ( RecLock("ZZ1",lReckLock) )
							ZZ1->ZZ1_IDREQ   := cID
							ZZ1->ZZ1_FILCAD  := cFilAnt
							ZZ1->ZZ1_NUMREQ  := cNum
							ZZ1->ZZ1_IDFORN  := cFor
							ZZ1->ZZ1_NOME    := cNome
							ZZ1->ZZ1_VALOR   := nValor
							ZZ1->ZZ1_PARCE   := cParc
							ZZ1->ZZ1_EMISSD  := SubStr(cAprovDT,1,10)
							ZZ1->ZZ1_EMISSH  := SubStr(cAprovDT,12,8)
							ZZ1->ZZ1_PREFIX  := cPrefixo
							ZZ1->ZZ1_DTINTE  := cData
							ZZ1->ZZ1_HRINTE  := Time()
							ZZ1->ZZ1_STATUS  := "N�o Integrado"
							ZZ1->ZZ1_STS     := "2"
							ZZ1->ZZ1_HIST    := cHist
							ZZ1->ZZ1_OBS     := "Foi encontrado um registro no banco de dados com o mesmo: " + CRLF;
								+ " � Filial " + CRLF + " � Prefixo " + CRLF + " � Numero " + CRLF + " � Parcela " + CRLF;
								+ " � Tipo " + CRLF + " � Fornecedor " + CRLF + " � Loja " + CRLF
							ZZ1->(MsUnlock())
						Endif
					End Transaction
				EndIf
				cLog := "Dados encontrados no banco! Titulo n�o foi gerado!"
				ShowLogInConsole(cLog)
			Endif
		Else
			If ( ZZ1->(dbSeek(  PAD(xFilial("ZZ1")  ,TAMSX3("ZZ1_FILIAL") [1]) +; 
								PAD(cID             ,TAMSX3("ZZ1_IDREQ")  [1]) +;
								PAD(cParc           ,TAMSX3("ZZ1_PARCE")  [1]) +;
								PAD("Integrado"     ,TAMSX3("ZZ1_STATUS") [1]) )))
                lReckLock := .F.
            Else 
                lReckLock := .T.
			EndIf

			If ( lReckLock )
				Begin Transaction
					If ( RecLock("ZZ1",lReckLock) )
						ZZ1->ZZ1_IDREQ   := cID
						ZZ1->ZZ1_FILCAD  := cFilAnt
						ZZ1->ZZ1_NUMREQ  := cNum
						ZZ1->ZZ1_IDFORN  := cFor
						ZZ1->ZZ1_NOME    := cNome
						ZZ1->ZZ1_VALOR   := nValor
						ZZ1->ZZ1_PARCE   := cParc
						ZZ1->ZZ1_EMISSD  := SubStr(cAprovDT,1,10)
						ZZ1->ZZ1_EMISSH  := SubStr(cAprovDT,12,8)
						ZZ1->ZZ1_PREFIX  := cPrefixo
						ZZ1->ZZ1_DTINTE  := cData
						ZZ1->ZZ1_HRINTE  := Time()
						ZZ1->ZZ1_STATUS  := "N�o Integrado"
						ZZ1->ZZ1_STS     := "2"
						ZZ1->ZZ1_HIST    := cHist
						ZZ1->ZZ1_OBS     := "Dados Bancarios n�o encontrados! Titulo n�o foi gerado!"
						ZZ1->(MsUnlock())
					EndIf
				End Transaction
			EndIf
			cLog := "Dados Bancarios n�o encontrados! Titulo n�o foi gerado!"
			ShowLogInConsole(cLog)
		Endif
	Else
		If ( ZZ1->(dbSeek(  PAD(xFilial("ZZ1")  ,TAMSX3("ZZ1_FILIAL") [1]) +; 
							PAD(cID             ,TAMSX3("ZZ1_IDREQ")  [1]) +;
							PAD(cParc           ,TAMSX3("ZZ1_PARCE")  [1]) +;
							PAD("Integrado"     ,TAMSX3("ZZ1_STATUS") [1]) )))
            lReckLock := .F.
        Else 
        	lReckLock := .T.
		EndIf

		If ( lReckLock )
			Begin Transaction
				///Informa Erro
				If ( RecLock("ZZ1",lReckLock) )
					ZZ1->ZZ1_IDREQ   := cID
					ZZ1->ZZ1_FILCAD  := cFilAnt
					ZZ1->ZZ1_NUMREQ  := cNum
					ZZ1->ZZ1_IDFORN  := cFor
					ZZ1->ZZ1_NOME    := cNome
					ZZ1->ZZ1_VALOR   := nValor
					ZZ1->ZZ1_PARCE   := cParc
					ZZ1->ZZ1_EMISSD  := SubStr(cAprovDT,1,10)
					ZZ1->ZZ1_EMISSH  := SubStr(cAprovDT,12,8)
					ZZ1->ZZ1_PREFIX  := cPrefixo
					ZZ1->ZZ1_DTINTE  := cData
					ZZ1->ZZ1_HRINTE  := Time()
					ZZ1->ZZ1_STATUS  := "N�o Integrado"
					ZZ1->ZZ1_STS     := "2"
					ZZ1->ZZ1_HIST    := cHist
					ZZ1->ZZ1_OBS     := "Fornecedor n�o encontrado! Titulo n�o foi gerado!"
					ZZ1->(MsUnlock())
				EndIf
			End Transaction
		EndIf

		EnvMail(cNomeArgo,"Adiantamento",cEmail,cNum)
		cLog := "Fornecedor n�o encontrado! Titulo n�o foi gerado!"
		ShowLogInConsole(cLog)
	EndIf

	If ( !Empty(AllTrim(cEmpBkp)))
		cEmpAnt := cEmpBkp
		cFilAnt := cFilBkp
		cNumEmp := cEmpAnt + cFilAnt
		OpenFile(cNumEmp)
	EndIf 

	RestArea( aArea )

Return

/*
   Fun��o que envia Email para o solicitante do Registro
*/
Static Function EnvMail(cNome,cTipo,cEmail,cNum)
	Local   cHora 		:= ""  as character
	Local   cSaudacao   := ""  as character

	Private cAssunto	:= ""  as character
	Private cEmailCC    := ""  as character
	Private cTexto		:= ""  as character 
	Private cPara		:= ""  as character
	Private cCC			:= ""  as character

	cHora 		        := SUBSTR(TIME(), 1, 2)                     
    cAssunto	        := "Registro N�: "+cNum+ " n�o concluido."
	cNome               := AjustaNome(cNome)
	cEmailCC            := GetNewPar("OZ_GRPMAIL","fcarneirosantos@gmail.com;milene.s.santos@ozminerals.com")
    cPara		        := If (Empty(Alltrim(cEmail)),cEmail,cEmailCC)
    cCC			        := cEmailCC

	If ( Val(cHora) >= 18 )
		cSaudacao := "Boa Noite, " + cNome + "!"
	ElseIf ( Val(cHora) >= 12 )
		cSaudacao := "Boa Tarde, " + cNome + "!"
	ElseIf ( Val(cHora) >= 6 )
		cSaudacao := "Bom Dia, " + cNome + "!"
	Else
		cSaudacao := "Boa Madrugada, " + cNome + "!"
	EndIf

	cTexto   :="<html>"
	cTexto   +="<head>"
	cTexto   +="<title>OzMineral�s - Aviso de Cadastramento do Fornecedor</title>"
	cTexto   +="</head>"
	cTexto   +="<body>"
	cTexto   +="<div style='text-align: left;'>"
	cTexto   +="<div>"
	cTexto   +=		"<p>"
	cTexto   +=		" "+AllTrim(cSaudacao)+" "
	cTexto   +=		"</p>"
	cTexto   +=		"<p>"
	cTexto   +=		"Seu "+ cTipo + " de numero: "+cNum+" n�o foi integrado com Protheus. "
	cTexto   +=		"</p>"
	cTexto   +=		"<p>"
	cTexto   +=		"Favor entrar em contado com o setor responsavel."
	cTexto   +=		"</p>"
	cTexto   +=		"<p>"
	cTexto   +=		"Att."
	cTexto   +=		"</p>"
	cTexto   +=		"<p>"
	cTexto   +=		"OZmineral�s - Departamento Financeiro"
	cTexto   +=		"</p>"
	cTexto   +=		"<p>[ESTA MENSAGEM FOI GERADA AUTOMATICAMENTE PELO SISTEMA, FAVOR N&Atilde;O RESPONDER]</p>"
	cTexto   +=	"</div>"
	cTexto   +=	"</div>"
	cTexto   +=		"</body>"
	cTexto   +="</html>"

	If ( !Empty(cPara) .And. Len(cTexto) > 30 )
		U_OZ06A01D(cPara,cCC,cAssunto,cTexto,"",.T.)
	EndIf

Return

/*
  Fun��o que ajusta o nome para a sauda��o
*/
Static Function AjustaNome(cNome)
	Local nI         := 0   as integer 
	Local nSobrenome := 0   as integer
	Local cNomeSobr  := ""  as character
	Local lUpper     := .F. as logical

	///Separa Primeiro e segundo nome
	For nI := 1 To Len(cNome)

		If ( SubStr(cNome,nI,1) == " " )

			cNomeSobr += " "
			lUpper    := .T.
			nSobrenome++

			If ( nSobrenome >= 2 )
				Exit
			Endif
		Else
			If ( nI == 1 .Or. lUpper )
				cNomeSobr += Upper(SubStr(cNome,nI,1))
				lUpper    := .F.
			Else
				cNomeSobr += SubStr(cNome,nI,1)
			EndIf
		Endif
	Next nI

	cNome := SubStr(cNomeSobr,1,Len(cNomeSobr))

Return cNome

/*
	Apresenta a Mensagem no Console do Protheus
*/
Static Function showLogInConsole(cMsg)

	libOzminerals.u_showLogInConsole(cMsg,cSintaxeRotina)

Return
