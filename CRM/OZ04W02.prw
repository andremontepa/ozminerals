#Include "Totvs.ch"
#Include "RESTFul.ch"
#Include "TopConn.ch"
#Include "tbiconn.ch"

#define NAO_ENVIADO      	500
#define ENVIADO      		200
#define GRAVASCP      		3
#define BLOQUEADO           "B"
#define ENCERRADO           "E"
#define RATEIO              "2"
#define CONSEST             "1"
#define INTEGRADO           "S"
#define PROPRIEDADE         "D"
#define PRIORIDADE          "2"
#define COD_EMPRESA         "01"

/*/{Protheus.doc} WSRESTFUL OZ04W02

    Serviço de Post - RM TOP

@author FABIO SANTOS
@since 11/01/2024
@version 1.0
@type wsrestful
/*/
WSRESTFUL OZ04W02 DESCRIPTION "Serviço de Post - RM TOP"
	WSDATA id         AS STRING

	WSMETHOD GET    ID     DESCRIPTION "Retorna o registro pesquisado" WSSYNTAX "/OZ04W02/get_id?{id}"  PATH "get_id"        PRODUCES APPLICATION_JSON
	WSMETHOD POST   NEW    DESCRIPTION "Inclusão de registro"          WSSYNTAX "/OZ04W02/new"          PATH "new"           PRODUCES APPLICATION_JSON
	WSMETHOD DELETE ERASE  DESCRIPTION "Exclusão de registro"          WSSYNTAX "/OZ04W02/erase"        PATH "erase"         PRODUCES APPLICATION_JSON
END WSRESTFUL

/*/{Protheus.doc} WSMETHOD GET ID

    Busca registro via ID

@author FABIO SANTOS
@since 11/01/2024
@version 1.0
@type method
@param id, Caractere, String que será pesquisada através do MsSeek
/*/
WSMETHOD GET ID WSRECEIVE id WSSERVICE OZ04W02
	Local lRet       := .T.
	Local jResponse  := JsonObject():New()
	Local cAliasWS   := "SCP"

	If ( Empty(::id) )
		Self:setStatus(NAO_ENVIADO)
		jResponse['errorId']  := "ID001"
		jResponse['error']    := "ID vazio"
		jResponse['solution'] := "Informe o ID"
	Else
		DbSelectArea(cAliasWS)
		(cAliasWS)->(DbSetOrder(1))

		If ( ! (cAliasWS)->(MsSeek(FWxFilial(cAliasWS) + ::id)))
			Self:setStatus(NAO_ENVIADO)
			jResponse['errorId']  := "ID002"
			jResponse['error']    := "ID não encontrado"
			jResponse['solution'] := "Código ID não encontrado na tabela " + cAliasWS
		Else
			jResponse['filial']   := (cAliasWS)->CP_FILIAL
			jResponse['num']      := (cAliasWS)->CP_NUM
			jResponse['item']     := (cAliasWS)->CP_ITEM
			jResponse['produto']  := (cAliasWS)->CP_PRODUTO
			jResponse['um']       := (cAliasWS)->CP_UM
			jResponse['quant']    := (cAliasWS)->CP_QUANT
			jResponse['local']    := (cAliasWS)->CP_LOCAL
			jResponse['datprf']   := (cAliasWS)->CP_DATPRF
			jResponse['cc']       := (cAliasWS)->CP_CC
			jResponse['itemcta']  := (cAliasWS)->CP_ITEMCTA
			jResponse['emissao']  := (cAliasWS)->CP_EMISSAO
			jResponse['clvl']     := (cAliasWS)->CP_CLVL
			jResponse['codsoli']  := (cAliasWS)->CP_CODSOLI
			jResponse['rateio']   := (cAliasWS)->CP_RATEIO
			jResponse['projeto']  := (cAliasWS)->CP_XPROJET
			jResponse['tarefa']   := (cAliasWS)->CP_XTAREFA
		EndIf
	EndIf

	Self:SetContentType('application/json')
	Self:SetResponse(jResponse:toJSON())

Return lRet

/*/{Protheus.doc} WSMETHOD POST NEW

    Cria um novo registro na tabela

@author FABIO SANTOS
@since 11/01/2024
@version 1.0
@type method

    Abaixo um exemplo do JSON que deverá vir no body
    * 1: Para campos do tipo Numérico, informe o valor sem usar as aspas
    * 2: Para campos do tipo Data, informe uma string no padrão 'YYYY-MM-DD'

    {
        "filial": "conteudo",
        "num": "conteudo",
        "item": "conteudo",
        "produto": "conteudo",
        "um": "conteudo",
        "quant": "conteudo",
		"vunit": "conteudo",
        "local": "conteudo",
        "cc": "conteudo",
        "itemcta": "conteudo",
        "clvl": "conteudo",
        "projeto": "conteudo",
        "tarefa": "conteudo"
    }

/*/
WSMETHOD POST NEW WSRECEIVE WSSERVICE OZ04W02
	Local lRet              := .T. as logical
	Local lReckLock         := .T. as logical
	Local nLinha            := 0  as integer
	Local jJson             := Nil
	Local cJson             := Self:GetContent()
	Local jResponse         := JsonObject():New()
	Local cAliasWS          := "SCP"
	Local cDirLog           := "\x_logs\" as character
	Local cArqLog           := ""  as character
	Local cError            := ""  as character
	Local cEmpBkp 			:= ""  as character
	Local cFilBkp 			:= ""  as character
	Local cNumEmpBkp        := ""  as character
	Local cNumEmp			:= ""  as character
	Local cDoc              := ""  as character
	Local cErrorLog         := ""  as character
	Local aArea             := {}  as array
	Local aLogAuto          := {}  as array
	Local aCabec            := {}  as array
	Local aItens            := {}  as array

	Private lMsErroAuto     := .F. as logical
	Private lMsHelpAuto     := .T. as logical
	Private lAutoErrNoFile  := .T. as logical

	IF ! ExistDir(cDirLog)
		MakeDir(cDirLog)
	EndIF

	Self:SetContentType('application/json')
	jJson  := JsonObject():New()
	cError := jJson:FromJson(cJson)

	PREPARE ENVIRONMENT EMPRESA COD_EMPRESA FILIAL Alltrim(jJson:GetJsonObject("filial")) MODULO "EST" TABLES "SCP"

	aArea      := GetArea()
	cEmpBkp    := cEmpAnt
	cFilBkp    := cFilAnt
	cNumEmpBkp := cNumEmp
	cEmpAnt    := COD_EMPRESA
	cFilAnt    := Alltrim(jJson:GetJsonObject("filial"))
	cNumEmp    := cEmpAnt + cFilAnt
	OpenFile(cNumEmp)

	IF ( ! Empty(cError) )
		Self:setStatus(NAO_ENVIADO)
		jResponse['errorId']  := 'NEW004'
		jResponse['error']    := 'Parse do JSON'
		jResponse['solution'] := 'Erro ao fazer o Parse do JSON'
	Else

		DbSelectArea(cAliasWS)

		cDoc := GetSXENum("SCP","CP_NUM")

		SCP->(dbSetOrder(1))

		While SCP->(dbSeek(xFilial("SCP")+cDoc))
			ConfirmSX8()
			cDoc := GetSXENum("SCP","CP_NUM")
		EndDo

		aCabec := {}
		aItens := {}

		aAdd( aCabec, {"CP_NUM"      ,cDoc                                 					 , Nil })
		aAdd( aCabec, {"CP_EMISSAO"  ,dDataBase                            					 , Nil })
		aAdd( aCabec, {"CP_SOLICIT"  ,Alltrim(UsrRetName(__CUSERID))         				 , Nil })
		aAdd( aCabec, {"CP_FILIAL"   ,Alltrim(jJson:GetJsonObject("filial")) 				 , Nil })

		aAdd( aItens, {} )
		aAdd( aItens[ Len( aItens ) ],{"CP_ITEM"    , AllTrim(jJson:GetJsonObject("item"))    , Nil } )
		aAdd( aItens[ Len( aItens ) ],{"CP_PRODUTO" , AllTrim(jJson:GetJsonObject("produto")) , Nil } )
		aAdd( aItens[ Len( aItens ) ],{"CP_UM"      , AllTrim(jJson:GetJsonObject("um"))      , Nil } )
		aAdd( aItens[ Len( aItens ) ],{"CP_LOCAL"   , AllTrim(jJson:GetJsonObject("local"))   , Nil } )
		aAdd( aItens[ Len( aItens ) ],{"CP_VUNIT"   , jJson:GetJsonObject("vunit")            , Nil } )
		aAdd( aItens[ Len( aItens ) ],{"CP_QUANT"   , jJson:GetJsonObject("quant")            , Nil } )
		aAdd( aItens[ Len( aItens ) ],{"CP_CC"      , AllTrim(jJson:GetJsonObject("cc"))      , Nil } )
		aAdd( aItens[ Len( aItens ) ],{"CP_ITEMCTA" , AllTrim(jJson:GetJsonObject("itemcta")) , Nil } )
		aAdd( aItens[ Len( aItens ) ],{"CP_CLVL"    , AllTrim(jJson:GetJsonObject("clvl"))    , Nil } )
		aAdd( aItens[ Len( aItens ) ],{"CP_XPROJET" , AllTrim(jJson:GetJsonObject("projeto")) , Nil } )
		aAdd( aItens[ Len( aItens ) ],{"CP_XTAREFA" , AllTrim(jJson:GetJsonObject("tarefa"))  , Nil } )

		If ( Len(aItens) > 0 )

			MsExecAuto({|x,y,z|Mata105(x,y,z)},aCabec,aItens,GRAVASCP)

			If ( lMsErroAuto )
				cErrorLog   := ""
				aLogAuto    := GetAutoGrLog()
				For nLinha := 1 To Len(aLogAuto)
					cErrorLog += aLogAuto[nLinha] + CRLF
				Next nLinha

				cArqLog := 'OZ04W02_New_' + dToS(Date()) + '_' + StrTran(Time(), ':', '-') + '.log'
				MemoWrite(cDirLog + cArqLog, cErrorLog)

				Self:setStatus(NAO_ENVIADO)
				jResponse['errorId']  := "NEW005"
				jResponse['error']    := "Erro na inclusão do registro"
				jResponse['solution'] := "Nao foi possivel incluir o registro, foi gerado um arquivo de log em " + cDirLog + cArqLog + " "
				lRet                  := .F.
			Else
				DbSelectArea("AF8")
				AF8->(dbSetOrder(1))
				If (AF8->(dbSeek(xFilial("AF8")+PAD(jJson:GetJsonObject("projeto"),TAMSX3("AFH_PROJET")[1]))))

					DbSelectArea("AFH")
					AFH->(dbSetOrder(2)) //AFH_FILIAL+AFH_NUMSA+AFH_ITEMSA+AFH_PROJET+AFH_REVISA+AFH_TAREFA
					If (AFH->(dbSeek(xFilial("AFH")+PAD(cDoc,TAMSX3("AFH_NUMSA")[1])+;
							PAD(jJson:GetJsonObject("item"),TAMSX3("AFH_ITEMSA")[1])+;
							PAD(jJson:GetJsonObject("projeto"),TAMSX3("AFH_PROJET")[1])+;
							PAD(AF8->AF8_REVISA,TAMSX3("AFH_REVISA")[1])+;
							PAD(jJson:GetJsonObject("tarefa"),TAMSX3("AFH_TAREFA")[1]))))
						lReckLock := .F.
					Else
						lReckLock := .T.
					EndIf

					Begin Transaction

						AFH->(RecLock("AFH",lReckLock))
							AFH->AFH_FILIAL := Alltrim(jJson:GetJsonObject("filial"))
							AFH->AFH_PROJET := AllTrim(jJson:GetJsonObject("projeto"))
							AFH->AFH_TAREFA := AllTrim(jJson:GetJsonObject("tarefa"))
							AFH->AFH_NUMSA  := AllTrim(cDoc)
							AFH->AFH_ITEMSA := AllTrim(jJson:GetJsonObject("item"))
							AFH->AFH_COD    := AllTrim(jJson:GetJsonObject("produto"))
							AFH->AFH_QUANT  := jJson:GetJsonObject("quant")
							AFH->AFH_REVISA := AF8->AF8_REVISA
							AFH_VIAINT      := INTEGRADO
						AFH->(MsUnLock())

					End Transaction
				EndIf

				Self:setStatus(ENVIADO)
				jResponse['note']     := "Registro incluido com sucesso"
				jResponse['filial']   := Alltrim(jJson:GetJsonObject("filial"))
				jResponse['num']      := cDoc
				lRet                  := .T.
			EndIf
		EndIf
	EndIf

	Self:SetResponse(jResponse:toJSON())

	If ( !Empty(AllTrim(cEmpBkp)))
		cEmpAnt := cEmpBkp
		cFilAnt := cFilBkp
		cNumEmp := cEmpAnt + cFilAnt
		OpenFile(cNumEmp)
	EndIf

	RESET ENVIRONMENT

	RestArea(aArea)

Return lRet

/*/{Protheus.doc} WSMETHOD DELETE ERASE

    Apaga o registro na tabela

@author FABIO SANTOS
@since 11/01/2024
@version 1.0
@type method
@param id, Caractere, String que será pesquisada através do MsSeek

    Abaixo um exemplo do JSON que deverá vir no body
    * 1: Para campos do tipo Numérico, informe o valor sem usar as aspas
    * 2: Para campos do tipo Data, informe uma string no padrão 'YYYY-MM-DD'

    {
        "filial": "conteudo",
        "num": "conteudo",
        "item": "conteudo",
        "produto": "conteudo",
        "um": "conteudo",
        "quant": "conteudo",
		"vunit": "conteudo",
        "local": "conteudo",
        "cc": "conteudo",
        "itemcta": "conteudo",
        "clvl": "conteudo",
        "projeto": "conteudo",
        "tarefa": "conteudo"
    }

/*/
WSMETHOD DELETE ERASE WSRECEIVE id WSSERVICE OZ04W02
	Local jJson             := Nil
	Local lRet              := .T. as logical
	Local lPermiteExcluir   := .F. as logical
	Local jResponse         := JsonObject():New()
	Local cAliasWS          := "SCP"
	Local cJson             := Self:GetContent()
	Local cError            := ""  as character
	Local cEmpBkp 			:= ""  as character
	Local cFilBkp 			:= ""  as character
	Local cNumEmpBkp        := ""  as character
	Local cNumEmp			:= ""  as character
	Local aArea             := {}  as array

	Private lMsErroAuto     := .F. as logical
	Private lMsHelpAuto     := .T. as logical
	Private lAutoErrNoFile  := .T. as logical

	Self:SetContentType('application/json')
	jJson  := JsonObject():New()
	cError := jJson:FromJson(cJson)

	PREPARE ENVIRONMENT EMPRESA COD_EMPRESA FILIAL Alltrim(jJson:GetJsonObject("filial")) MODULO "EST" TABLES "SCP"

	aArea      := GetArea()
	cEmpBkp    := cEmpAnt
	cFilBkp    := cFilAnt
	cNumEmpBkp := cNumEmp
	cEmpAnt    := COD_EMPRESA
	cFilAnt    := Alltrim(jJson:GetJsonObject("filial"))
	cNumEmp    := cEmpAnt + cFilAnt
	OpenFile(cNumEmp)

	If ( Empty(AllTrim(jJson:GetJsonObject("num"))))
		Self:setStatus(NAO_ENVIADO)
		jResponse['errorId']  := "DEL010"
		jResponse['error']    := "Numero da SA vazio"
		jResponse['solution'] := "Informe Numero da SA"
	Else
		If ( ! Empty(cError) )
			Self:setStatus(NAO_ENVIADO)
			jResponse['errorId']  := 'DEL012'
			jResponse['error']    := 'Parse do JSON'
			jResponse['solution'] := 'Erro ao fazer o Parse do JSON'

		Else
			DbSelectArea(cAliasWS)
			(cAliasWS)->(DbSetOrder(2)) //CP_FILIAL+CP_PRODUTO+CP_NUM+CP_ITEM
			If ((cAliasWS)->(MsSeek(FWxFilial(cAliasWS) + PAD(jJson:GetJsonObject("produto"),TAMSX3("CP_PRODUTO")[1]) +;
					PAD(jJson:GetJsonObject("num"),TAMSX3("CP_NUM")[1]) +;
					PAD(jJson:GetJsonObject("item"),TAMSX3("CP_ITEM")[1]))))

				While (cAliasWS)->(!EOF()) .And. SCP->CP_NUM = PAD(jJson:GetJsonObject("num"),TAMSX3("CP_NUM")[1]) .And.;
						SCP->CP_ITEM = PAD(jJson:GetJsonObject("item"),TAMSX3("CP_ITEM")[1])

					If ( SCP->CP_STATUS $ ENCERRADO )
						lPermiteExcluir := .F.
						Exit
					Else
						(cAliasWS)->(RecLock("SCP"))
						dbDelete()
						(cAliasWS)->(MsUnLock())
						lPermiteExcluir := .T.
					EndIf

					(cAliasWS)->(DbSkip())
				EndDo

				If ( lPermiteExcluir )
					Self:setStatus(ENVIADO)
					jResponse['note']     := "Solicitação Armazem Excluido com sucesso"
					jResponse['filial']   := Alltrim(jJson:GetJsonObject("filial"))
					jResponse['num']      := Alltrim(jJson:GetJsonObject('num'))
					lRet                  := .T.
				Else
					Self:setStatus(NAO_ENVIADO)
					jResponse['note']     := "Solicitação Armazem Não Pode Ser Excluido, Encontra-se Encerrada"
					jResponse['filial']   := Alltrim(jJson:GetJsonObject("filial"))
					jResponse['num']      := Alltrim(jJson:GetJsonObject('num'))
					lRet                  := .F.
				EndIf

			Else
				Self:setStatus(NAO_ENVIADO)
				jResponse['errorId']  := "DEL011"
				jResponse['error']    := "Numero de SA não encontrado"
				jResponse['solution'] := "Numero de SA não encontrado na tabela " + cAliasWS
				lRet := .F.
			EndIf
		EndIf
	EndIf

	Self:SetResponse(jResponse:toJSON())

	If ( !Empty(AllTrim(cEmpBkp)))
		cEmpAnt := cEmpBkp
		cFilAnt := cFilBkp
		cNumEmp := cEmpAnt + cFilAnt
		OpenFile(cNumEmp)
	EndIf

	RESET ENVIRONMENT

	RestArea(aArea)

Return lRet
