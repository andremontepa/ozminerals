#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "PRTOPDEF.CH"

/*/{Protheus.doc} OZ02JB01
JOB de Integração Protheus x Klassmatt 
@type function           
@author Ricardo Tavares Ferreira
@since 12/09/2022
@version 12.1.27
@history 12/09/2022, Ricardo Tavares Ferreira, Construção Inicial
/*/
//=============================================================================================================================
    User Function OZ02JB01(xEmp,xFil)
//=============================================================================================================================

    Local nX     := 0
    Default xEmp := "01"
    Default xFil := "01"

    If IsBlind()
        RpcClearEnv()
        RpcSetType(3)
        RpcSetEnv(xEmp,xFil,,,,GetEnvServer(),{"SB1"})
    EndIf 

    APIUtil():ConsoleLog("OZ02JB01","Inicio do Processamento ...",1)

    For nX := 1 To 10
        ProcIntegra()
    Next nX 

    APIUtil():ConsoleLog("OZ02JB01","Fim do Processamento ...",1)
Return Nil

/*/{Protheus.doc} ProcIntegra
Função que processa Busca e Processa a integração.
@type function           
@author Ricardo Tavares Ferreira
@since 12/09/2022
@history 12/09/2022, Ricardo Tavares Ferreira, Construção Inicial
@version 12.1.33
/*/
//=============================================================================================================================
    Static Function ProcIntegra()
//=============================================================================================================================

    Local oRestClient       := Nil
    Local cPathKlassmat     := "/rest/ozminerals/v0/getItemsToIntegration"
    Local cGetResult        := ""
    Local aHeader           := {}
    Local aProduto          := {}
    Local oJsRet            := JsonObject():New()
    Local xRet              := Nil 
    Private cUrlKlassmat    := SuperGetMV("OZ_URLKLAS",.F.,"http://api.klassmatt.com.br") 
    Private xParaEmail      := SuperGetMV("OZ_EMAIPRA",.F.,"ricardo@equilibrioti.com.br") 

    //aadd(aHeader,"User-Agent: Mozilla/4.0 (compatible; Protheus "+GetBuild()+")")
    aadd(aHeader,"Content-Type: application/json")

    oRestClient := FWRest():New(cUrlKlassmat)
    oRestClient:setPath(cPathKlassmat+"?SourceId=UniqueID&MaxResults=1")
    oRestClient:nTimeOut := 240

    If oRestClient:Get(aHeader)
        cGetResult := oRestClient:GetResult()
        cGetResult := FwNoAccent(DecodeUTF8(cGetResult, "cp1252"))
        cGetResult := Substr(cGetResult,2,Len(cGetResult))
        cGetResult := Substr(cGetResult,1,Len(cGetResult) - 1)

        xRet := oJsRet:FromJson(cGetResult)
        If ValType(xRet) == "U"
            If ValType(oJsRet:GetJsonObject("ItemCode")) == "C"
                aadd(aProduto,{"B1_COD", AllTrim(oJsRet:GetJsonObject("ItemCode")) , Nil })
            Else 
                aadd(aProduto,{"B1_COD", "" , Nil })
            EndIf 

            If ValType(oJsRet:GetJsonObject("ItemType")) == "C"
                aadd(aProduto,{"B1_TIPO", AllTrim(oJsRet:GetJsonObject("ItemType")) , Nil })
            Else 
                aadd(aProduto,{"B1_TIPO", "" , Nil })
            EndIf 

            If ValType(oJsRet:GetJsonObject("UnitOfMeasure")) == "C"
                aadd(aProduto,{"B1_UM", AllTrim(oJsRet:GetJsonObject("UnitOfMeasure")) , Nil })
            Else 
                aadd(aProduto,{"B1_UM", "" , Nil })
            EndIf 

            If ValType(oJsRet:GetJsonObject("ItemOrigin")) == "C"
                aadd(aProduto,{"B1_ORIGEM", cValToChar(oJsRet:GetJsonObject("ItemOrigin")) , Nil })
            Else 
                aadd(aProduto,{"B1_ORIGEM", "0" , Nil })
            EndIf 

            If ValType(oJsRet:GetJsonObject("Description1")) == "C"
                aadd(aProduto,{"B1_DESCESP", AllTrim(oJsRet:GetJsonObject("Description1")) , Nil })
            Else 
                aadd(aProduto,{"B1_DESCESP", "" , Nil })
            EndIf

            If ValType(oJsRet:GetJsonObject("Description2")) == "C"
                aadd(aProduto,{"B1_ESPECIF", SubStr(AllTrim(oJsRet:GetJsonObject("Description2")),1,TamSX3("B1_ESPECIF")[1]) , Nil })
            Else 
                aadd(aProduto,{"B1_ESPECIF", "" , Nil })
            EndIf 

            If ValType(oJsRet:GetJsonObject("Description3")) == "C"
                aadd(aProduto,{"B1_DESC", SubStr(AllTrim(oJsRet:GetJsonObject("Description3")),1,TamSX3("B1_DESC")[1]) , Nil })
            Else 
                aadd(aProduto,{"B1_DESC", "" , Nil })
            EndIf 

            If ValType(oJsRet:GetJsonObject("TaxClassification")) == "C"
                If AllTrim(oJsRet:GetJsonObject("ItemType")) <> "SV"
                    aadd(aProduto,{"B1_POSIPI", AllTrim(oJsRet:GetJsonObject("TaxClassification")) , Nil })
                Else
                    aadd(aProduto,{"B1_POSIPI", "00000000", Nil })
                EndIf
            Else 
                aadd(aProduto,{"B1_POSIPI", "" , Nil })
            EndIf

            If ValType(oJsRet:GetJsonObject("TaxClassificationStdIPI")) == "N"
                aadd(aProduto,{"B1_IPI", oJsRet:GetJsonObject("TaxClassificationStdIPI") , Nil })
            Else 
                aadd(aProduto,{"B1_IPI", 0 , Nil })
            EndIf 

            If ValType(oJsRet:GetJsonObject("KlassmattId")) == "N"
                aadd(aProduto,{"B1_XIDKLAS", cValToChar(oJsRet:GetJsonObject("KlassmattId")) , Nil })
            Else 
                aadd(aProduto,{"B1_XIDKLAS", "0" , Nil }) 
            EndIf   

            If Valtype(oJsRet:GetJsonObject("FlexFields")) == "J"
                If ValType(oJsRet:GetJsonObject("FlexFields"):GetJsonObject("ARMAZEN_PAD"):GetJsonObject("Code")) == "C"
                    aadd(aProduto,{"B1_LOCPAD", AllTrim(oJsRet:GetJsonObject("FlexFields"):GetJsonObject("ARMAZEN_PAD"):GetJsonObject("Code")) , Nil })
                Else 
                    aadd(aProduto,{"B1_LOCPAD", "01" , Nil }) 
                EndIf 

                If ValType(oJsRet:GetJsonObject("FlexFields"):GetJsonObject("GRUPO"):GetJsonObject("Code")) == "C"
                    aadd(aProduto,{"B1_GRUPO", AllTrim(oJsRet:GetJsonObject("FlexFields"):GetJsonObject("GRUPO"):GetJsonObject("Code")) , Nil })
                Else 
                    aadd(aProduto,{"B1_GRUPO", "" , Nil }) 
                EndIf                 

                If ValType(oJsRet:GetJsonObject("FlexFields"):GetJsonObject("Apropriacao"):GetJsonObject("Code")) == "C"
                    aadd(aProduto,{"B1_XAPROPR", SubStr(Upper(oJsRet:GetJsonObject("FlexFields"):GetJsonObject("Apropriacao"):GetJsonObject("Description")),1,1), Nil })
                Else 
                    aadd(aProduto,{"B1_XAPROPR", "" , Nil }) 
                EndIf 

                If ValType(oJsRet:GetJsonObject("FlexFields"):GetJsonObject("CTA_CONTABIL"):GetJsonObject("Code")) == "C"
                    aadd(aProduto,{"B1_CONTA", SubStr(Upper(oJsRet:GetJsonObject("FlexFields"):GetJsonObject("CTA_CONTABIL"):GetJsonObject("Code")),1,20), Nil })
                Else 
                    aadd(aProduto,{"B1_CONTA", "" , Nil }) 
                EndIf 

                If ValType(oJsRet:GetJsonObject("FlexFields"):GetJsonObject("CONTA_ATIVO"):GetJsonObject("Code")) == "C"
                    aadd(aProduto,{"B1_CTAATIV", SubStr(Upper(oJsRet:GetJsonObject("FlexFields"):GetJsonObject("CONTA_ATIVO"):GetJsonObject("Code")),1,20), Nil })
                Else 
                    aadd(aProduto,{"B1_CTAATIV", "" , Nil }) 
                EndIf 

                If ValType(oJsRet:GetJsonObject("FlexFields"):GetJsonObject("CONTA_CUSTO"):GetJsonObject("Code")) == "C"
                    aadd(aProduto,{"B1_CTACUST", SubStr(Upper(oJsRet:GetJsonObject("FlexFields"):GetJsonObject("CONTA_CUSTO"):GetJsonObject("Code")),1,20), Nil })
                Else 
                    aadd(aProduto,{"B1_CTACUST", "" , Nil }) 
                EndIf 

                If ValType(oJsRet:GetJsonObject("FlexFields"):GetJsonObject("CONTA_DESPESA"):GetJsonObject("Code")) == "C"
                    aadd(aProduto,{"B1_CTADESP", SubStr(Upper(oJsRet:GetJsonObject("FlexFields"):GetJsonObject("CONTA_DESPESA"):GetJsonObject("Code")),1,20), Nil })
                Else 
                    aadd(aProduto,{"B1_CTADESP", "" , Nil }) 
                EndIf 

                If ValType(oJsRet:GetJsonObject("FlexFields"):GetJsonObject("CTA_EXPLORAC"):GetJsonObject("Code")) == "C"
                    aadd(aProduto,{"B1_XCTAEXP", SubStr(Upper(oJsRet:GetJsonObject("FlexFields"):GetJsonObject("CTA_EXPLORAC"):GetJsonObject("Code")),1,20), Nil })
                Else 
                    aadd(aProduto,{"B1_XCTAEXP", "" , Nil }) 
                EndIf 

                If ValType(oJsRet:GetJsonObject("FlexFields"):GetJsonObject("CLASSIFICACAO_FISCAL"):GetJsonObject("Code")) == "C"
                    aadd(aProduto,{"B1_TE", SubStr(Upper(oJsRet:GetJsonObject("FlexFields"):GetJsonObject("CLASSIFICACAO_FISCAL"):GetJsonObject("Code")),1,3), Nil })
                Else 
                    aadd(aProduto,{"B1_TE", "" , Nil }) 
                EndIf

                GravaProduto(aProduto)
            EndIf 
        Else
            APIUtil():ConsoleLog("OZ02JB01|ProcIntegra","Falha ao popular JsonObject. Erro: " + xRet,3)
        Endif
    Else
        APIUtil():ConsoleLog("OZ02JB01|ProcIntegra","Erro ao Buscar os dados na API ---> "+oRestClient:GetLastError(),3)
    Endif
    FWFreeObj(oRestClient)
    FWFreeObj(oJsRet)
Return 

/*/{Protheus.doc} GravaProduto
Função que grava o produto no protheus.
@type function           
@author Ricardo Tavares Ferreira
@since 14/09/2022
@history 14/09/2022, Ricardo Tavares Ferreira, Construção Inicial
@version 12.1.33
/*/
//=============================================================================================================================
    Static Function GravaProduto(aProduto)
//=============================================================================================================================

    Local nPosProd          := aScan(aProduto,{|x| AllTrim(x[1])=="B1_COD"})
    Local cCodProd          := Alltrim(aProduto[nPosProd][2])
    Local nPosIDKl          := aScan(aProduto,{|x| AllTrim(x[1])=="B1_XIDKLAS"})
    Local cIDKlass          := Alltrim(aProduto[nPosIDKl][2])
    Local nOpc              := 3
	Local cMsgRet			:= ""
    Local cMsgInt           := ""
    Local lStatus           := .T.
    Local aRetKlass         := {}
    Local cAssunto          := "[Protheus] Retorno API Klassmatt"
    Local cFilePath         := ""
    Local cMsgEmail         := ""

	Private lMsErroAuto   	:= .F.
	Private lMsHelpAuto   	:= .F.
	Private lAutoErrNoFile	:= .T.
     
    If .not. Empty(cCodProd)  
        nOpc := 4 
        If .not. GetProdKlassmat(cIDKlass,cCodProd)
            aProduto[nPosIDKl][2] := cIDKlass
        EndIf 
    Else
        aProduto[nPosProd][2] := GetNextCodPrd()
    EndIf 

    aadd(aProduto,{"B1_FILIAL", FWXFilial("SB1") , Nil }) 

    aProduto := FWVetByDic(aProduto,"SB1")
    MSExecAuto({|x,y| MATA010(x,y)},aProduto,nOpc) 

	If lMsErroAuto	
		cMsgRet := "Erro ao Incluir/Alterar o Produto ---> " + CRLF
		aEval(GetAutoGrLog(), {|x| cMsgRet += x + CRLF })
        cMsgInt   := "Erro na Gravacao do Produto no Protheus. Verifique o Email enviado para mais detalhes do erro encontrado."
        cMsgEmail :=  cMsgRet
        APIUtil():ConsoleLog("OZ02JB01|GravaProduto",cMsgRet,3)

        aRetKlass := PostKlassmatt("",Val(cIDKlass),!lStatus,cMsgInt)
        
        If .not. aRetKlass[1]
            APIUtil():EnviarEmail(xParaEmail,cAssunto,cMsgEmail,cFilePath)
        EndIf 
    Else 
        cMsgRet   := "Item Integrado com Sucesso ["+Alltrim(SB1->B1_COD)+"]"
        aRetKlass := PostKlassmatt(Alltrim(SB1->B1_COD),Val(cIDKlass),lStatus,cMsgRet)

        If .not. aRetKlass[1]
            cMsgEmail := aRetKlass[2]
            APIUtil():EnviarEmail(xParaEmail,cAssunto,cMsgEmail,cFilePath)
        EndIf 
	EndIf
Return 

/*/{Protheus.doc} PostKlassmatt
Busca o Produto com ID Klassmatt cadastrado no protheus.
@type function           
@author Ricardo Tavares Ferreira
@since 14/09/2022
@history 14/09/2022, Ricardo Tavares Ferreira, Construção Inicial
@version 12.1.33
/*/
//=============================================================================================================================
    Static Function PostKlassmatt(cCodProd,nIDKlassmatt,lStatus,cMsg)
//=============================================================================================================================

    Local oRestClient   := Nil
    Local cPathKlassmat := "/rest/ozminerals/v0/updateItemIntegrationStatus"
    Local cJsonEnv      := ""
    Local aHeader       := {}
    Local oJson         := JsonObject():new()
    Local cTextoRet     := ""

    oJson["KlassmattId"]    := nIDKlassmatt
    oJson["ItemCode"] 		:= cCodProd
    oJson["Success"] 		:= lStatus
    oJson["ErrorMessage"] 	:= cMsg

    cJsonEnv := oJson:ToJson()
    FWFreeObj(oJson)

    aAdd(aHeader, "Content-Type: application/json")

    oRestClient := FWRest():New(cUrlKlassmat)
    oRestClient:setPath(cPathKlassmat)
    oRestClient:nTimeOut := 360
    oRestClient:SetPostParams(cJsonEnv)

    If .not. oRestClient:Post(aHeader)
        APIUtil():ConsoleLog("OZ02JB01|PostKlassmatt","Erro ao Atualizar o Servidor da Klassmatt ---> "+ CRLF + "Contate o Administrador!" + CRLF + "Erro: " + oRestClient:GetLastError(),3)
        cTextoRet := "Erro ao Atualizar o Servidor da Klassmatt ---> "+ CRLF + "Contate o Administrador!" + CRLF + "Erro: " + oRestClient:GetLastError()
        Return{.F., cTextoRet}
    Else 
        APIUtil():ConsoleLog("OZ02JB01|PostKlassmatt","Registro Integrado com Sucesso ID Klassmatt: "+cValToChar(nIDKlassmatt)+" | Codigo do Produto: "+cCodProd,1)
    EndIf 
    FWFreeObj(oRestClient)
Return{.T., cTextoRet}

/*/{Protheus.doc} GetProdKlassmat
Busca o Produto com ID Klassmatt cadastrado no protheus.
@type function           
@author Ricardo Tavares Ferreira
@since 14/09/2022
@history 14/09/2022, Ricardo Tavares Ferreira, Construção Inicial
@version 12.1.33
/*/
//=============================================================================================================================
    Static Function GetProdKlassmat(cIDKlass,cCodProd)
//=============================================================================================================================

	Local cAliasXY  := GetNextAlias()
   	Local cQuery	:= ""
	Local QbLinha	:= CRLF
    Local nQtdReg   := 0
	Local lRet 		:= .F.

	cQuery := " SELECT SB1.R_E_C_N_O_ IDSB1 "+QbLinha
	cQuery += " FROM "
	cQuery +=   RetSqlName("SB1") + " SB1 "+QbLinha
	cQuery += " WHERE "+QbLinha 
	cQuery += " SB1.D_E_L_E_T_ = ' ' "+QbLinha 
	cQuery += " AND B1_FILIAL = '"+FWXFilial("SB1")+"' "+QbLinha
	cQuery += " AND B1_XIDKLAS = '"+cIDKlass+"' "+QbLinha
    cQuery += " AND B1_COD = '"+cCodProd+"' "+QbLinha

	APIUtil():ConsoleLog("OZ02JB01|GetProdKlassmat","Query Executada "+Alltrim(cQuery),1)	
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasXY,.F.,.T.)
		
	DbSelectArea(cAliasXY)
	(cAliasXY)->(DbGoTop())
	Count To nQtdReg
	(cAliasXY)->(DbGoTop())
		
	If nQtdReg <= 0
		(cAliasXY)->(DbCloseArea())
    Else
		lRet := .T.
        DbSelectArea("SB1")
        SB1->(DbSetOrder(1))
        SB1->(DbGoTo((cAliasXY)->IDSB1))
        (cAliasXY)->(DbCloseArea())
    EndIf
Return lRet

/*/{Protheus.doc} GetNextCodPrd
Busca o proximo codigo do produto no protheus
@type function           
@author Ricardo Tavares Ferreira
@since 14/09/2022
@history 14/09/2022, Ricardo Tavares Ferreira, Construção Inicial
@version 12.1.33
/*/
//=============================================================================================================================
    Static Function GetNextCodPrd()
//=============================================================================================================================

	Local cAliasXY  := GetNextAlias()
   	Local cQuery	:= ""
	Local QbLinha	:= CRLF
    Local nQtdReg   := 0
	Local cCodPrd   := ""

    cQuery := " SELECT "+QbLinha
    cQuery += " MAX(B1_COD) B1_COD "+QbLinha
	cQuery += " FROM "
	cQuery +=   RetSqlName("SB1") + " SB1 "+QbLinha
    cQuery += " WHERE SB1.D_E_L_E_T_ = ' ' "+QbLinha 
    cQuery += " AND ISNUMERIC(B1_COD) = 1 "+QbLinha 
    cQuery += " AND LEN(B1_COD) = 6 "+QbLinha
    cQuery += " AND B1_FILIAL = '"+FWXFilial("SB1")+"' "+QbLinha

	APIUtil():ConsoleLog("OZ02JB01|GetNextCodPrd","Query Executada "+Alltrim(cQuery),1)	
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasXY,.F.,.T.)
		
	DbSelectArea(cAliasXY)
	(cAliasXY)->(DbGoTop())
	Count To nQtdReg
	(cAliasXY)->(DbGoTop())
		
	If nQtdReg <= 0
        cCodPrd := "000001"
		(cAliasXY)->(DbCloseArea())
    Else
		cCodPrd := StrZero(Val((cAliasXY)->B1_COD) + 1,6)
        (cAliasXY)->(DbCloseArea())
    EndIf
Return cCodPrd
