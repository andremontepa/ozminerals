#Include "Totvs.ch"
#Include "RESTFul.ch"
#Include "TopConn.ch"
#Include "tbiconn.ch"

#define NAO_ENVIADO      	500
#define ENVIADO      		200
#define BLOQUEADO           "B"
#define ENCERRADO           "E"
#define RATEIO              "2"
#define INTEGRADO           "S"
#define PROPRIEDADE         "D"
#define PRIORIDADE          "2"
#define COD_EMPRESA         "01" 

/*/{Protheus.doc} WSRESTFUL OZ02W02

	Serviço de Post - RM TOP

@author FABIO SANTOS
@since 03/01/2024
@version 1.0
@type wsrestful
/*/
WSRESTFUL OZ02W02 DESCRIPTION "Serviço de Post - RM TOP"
	WSDATA id         AS STRING

	WSMETHOD GET    ID     DESCRIPTION "Retorna o registro pesquisado" WSSYNTAX "/OZ02W02/get_id?{id}"  PATH "get_id"   PRODUCES APPLICATION_JSON
	WSMETHOD POST   NEW    DESCRIPTION "Inclusão de registro"          WSSYNTAX "/OZ02W02/new"          PATH "new"      PRODUCES APPLICATION_JSON
	WSMETHOD DELETE ERASE  DESCRIPTION "Exclusão de registro"          WSSYNTAX "/OZ02W02/erase"        PATH "erase"    PRODUCES APPLICATION_JSON
END WSRESTFUL

/*/{Protheus.doc} WSMETHOD GET ID

	Busca registro via ID

@author FABIO SANTOS
@since 03/01/2024
@version 1.0
@type method
@param id, Caractere, String que será pesquisada através do MsSeek
/*/
WSMETHOD GET ID WSRECEIVE id WSSERVICE OZ02W02
	Local lRet       := .T.
	Local jResponse  := JsonObject():New()
	Local cAliasWS   := "SC1"

	If ( Empty(::id) )
		Self:setStatus(NAO_ENVIADO)
		jResponse['errorId']     := 'ID001'
		jResponse['error']       := 'ID vazio'
		jResponse['solution']    := 'Informe o ID'
	Else
		DbSelectArea(cAliasWS)
		(cAliasWS)->(DbSetOrder(1))

		If ( ! (cAliasWS)->(MsSeek(FWxFilial(cAliasWS) + ::id)))
			Self:setStatus(NAO_ENVIADO)
			jResponse['errorId']  := 'ID002'
			jResponse['error']    := 'ID não encontrado'
			jResponse['solution'] := 'Código ID não encontrado na tabela ' + cAliasWS
		Else
			jResponse['filial']   := (cAliasWS)->C1_FILIAL
			jResponse['num']      := (cAliasWS)->C1_NUM
			jResponse['item']     := (cAliasWS)->C1_ITEM
			jResponse['produto']  := (cAliasWS)->C1_PRODUTO
			jResponse['descri ']  := (cAliasWS)->C1_DESCRI
			jResponse['um']       := (cAliasWS)->C1_UM
			jResponse['local']    := (cAliasWS)->C1_LOCAL
			jResponse['quant']    := (cAliasWS)->C1_QUANT
			jResponse['vunit']    := (cAliasWS)->C1_VUNIT
			jResponse['xpropri']  := (cAliasWS)->C1_XPROPRI
			jResponse['cc']       := (cAliasWS)->C1_CC
			jResponse['itemcta']  := (cAliasWS)->C1_ITEMCTA
			jResponse['clvl']     := (cAliasWS)->C1_CLVL
			jResponse['xpriori']  := (cAliasWS)->C1_XPRIORI
			jResponse['emissao']  := (cAliasWS)->C1_EMISSAO
			jResponse['projeto']  := (cAliasWS)->C1_XPROJET
			jResponse['tarefa']   := (cAliasWS)->C1_XTAREFA
		EndIf
	EndIf

	Self:SetContentType('application/json')
	Self:SetResponse(jResponse:toJSON())
Return lRet

/*/{Protheus.doc} WSMETHOD POST NEW

	Cria um novo registro na tabela

@author FABIO SANTOS
@since 03/01/2024
@version 1.0
@type method
@obs Abaixo um exemplo do JSON que deverá vir no body

    * 1: Para campos do tipo Numérico, informe o valor sem usar as aspas
    * 2: Para campos do tipo Data, informe uma string no padrão 'YYYY-MM-DD'

    {
        "filial": "conteudo",
        "num": "conteudo",
        "item": "conteudo",
        "produto": "conteudo",
        "descri ": "conteudo",
        "um": "conteudo",
        "quant": "conteudo",
        "vunit": "conteudo",
        "xpropri": "conteudo",
        "segum": "conteudo",
        "cc": "conteudo",
        "itemcta": "conteudo",
        "clvl": "conteudo",
        "xpriori": "conteudo",
        "xnomecp": "conteudo",
        "local": "conteudo",
        "emissao": "conteudo",
        "conta": "conteudo",
        "projeto": "conteudo",
        "tarefa": "conteudo"

    }
/*/
WSMETHOD POST NEW WSRECEIVE WSSERVICE OZ02W02
	Local jJson             := Nil
	Local nLinha            := 0  as integer
	Local lRet              := .T. as logical
	Local lReckLock         := .T. as logical
	Local jResponse         := JsonObject():New()
	Local cAliasWS          := "SC1"
	Local cJson             := Self:GetContent()
	Local cDirLog           := "\x_logs\" as character
	Local cArqLog           := ""  as character
	Local cErrorLog         := ""  as character
	Local cError            := ""  as character
	Local cEmpBkp 			:= ""  as character
	Local cFilBkp 			:= ""  as character
	Local cNumEmpBkp        := ""  as character
	Local cNumEmp			:= ""  as character
	Local cDoc              := ""  as character
	Local aLogAuto          := {}  as array
	Local aArea             := {}  as array
	Local aCabec            := {}  as array
	Local aDados            := {}  as array
	Local aItensSC          := {}  as array

	Private lMsErroAuto     := .F. as logical
	Private lMsHelpAuto     := .T. as logical
	Private lAutoErrNoFile  := .T. as logical

	IF ! ExistDir(cDirLog)
		MakeDir(cDirLog)
	EndIF

	Self:SetContentType('application/json')
	jJson  := JsonObject():New()
	cError := jJson:FromJson(cJson)

	PREPARE ENVIRONMENT EMPRESA COD_EMPRESA FILIAL Alltrim(jJson:GetJsonObject("filial")) MODULO "COM" TABLES "SC1"

	aArea      := GetArea()
	cEmpBkp    := cEmpAnt
	cFilBkp    := cFilAnt
	cNumEmpBkp := cNumEmp
	cEmpAnt    := COD_EMPRESA
	cFilAnt    := Alltrim(jJson:GetJsonObject("filial"))
	cNumEmp    := cEmpAnt + cFilAnt
	OpenFile(cNumEmp)

	If ( ! Empty(cError) )
		Self:setStatus(NAO_ENVIADO)
		jResponse['errorId']  := 'NEW004'
		jResponse['error']    := 'Parse do JSON'
		jResponse['solution'] := 'Erro ao fazer o Parse do JSON'

	Else

		DbSelectArea(cAliasWS)

		cDoc := GetSXENum("SC1","C1_NUM")

		SC1->(dbSetOrder(1))

		While SC1->(dbSeek(xFilial("SC1")+cDoc))
			ConfirmSX8()
			cDoc := GetSXENum("SC1","C1_NUM")
		EndDo

		aCabec := {}
		aDados := {}

		aCabec := {{"C1_NUM",cDoc                                            , NIL},;
			       {"C1_SOLICIT",Alltrim(UsrRetName(__CUSERID))              , NIL},;
			       {"C1_EMISSAO",dDataBase                                   , NIL},;
			       {"C1_FILIAL" ,Alltrim(jJson:GetJsonObject("filial"))      , NIL}}

		aAdd(aDados, {"C1_ITEM"   ,   AllTrim(jJson:GetJsonObject("item"))   ,   Nil})
		aAdd(aDados, {"C1_PRODUTO",   AllTrim(jJson:GetJsonObject("produto")),   Nil})
		aAdd(aDados, {"C1_UM"     ,   AllTrim(jJson:GetJsonObject("um"))     ,   Nil})
		aAdd(aDados, {"C1_VUNIT"  ,   jJson:GetJsonObject("vunit")           ,   Nil})
		aAdd(aDados, {"C1_QUANT"  ,   jJson:GetJsonObject("quant")           ,   Nil})
		aAdd(aDados, {"C1_LOCAL"  ,   AllTrim(jJson:GetJsonObject("local"))  ,   Nil})
		aAdd(aDados, {"C1_XPROPRI",   PROPRIEDADE                            ,   Nil})
		aAdd(aDados, {"C1_CC"     ,   AllTrim(jJson:GetJsonObject("cc"))     ,   Nil})
		aAdd(aDados, {"C1_ITEMCTA",   AllTrim(jJson:GetJsonObject("itemcta")),   Nil})
		aAdd(aDados, {"C1_CLVL"   ,   AllTrim(jJson:GetJsonObject("clvl"))   ,   Nil})
		aAdd(aDados, {"C1_XPRIORI",   PRIORIDADE                             ,   Nil})
		aAdd(aDados, {"C1_XPROJET",   AllTrim(jJson:GetJsonObject("projeto")),   Nil})
		aAdd(aDados, {"C1_XTAREFA",   AllTrim(jJson:GetJsonObject("tarefa")) ,   Nil})

		aadd(aItensSC,aDados)

		If ( Len(aItensSC) > 0 )

			MSExecAuto({|x,y| mata110(x,y)},aCabec,aItensSC)

			If ( lMsErroAuto )
				cErrorLog   := ""
				aLogAuto    := GetAutoGrLog()
				For nLinha := 1 To Len(aLogAuto)
					cErrorLog += aLogAuto[nLinha] + CRLF
				Next nLinha

				cArqLog := 'OZ02W02_New_' + dToS(Date()) + '_' + StrTran(Time(), ':', '-') + '.log'
				MemoWrite(cDirLog + cArqLog, cErrorLog)

				Self:setStatus(NAO_ENVIADO)
				jResponse['errorId']  := "NEW005"
				jResponse['error']    := "Erro na inclusão do registro"
				jResponse['solution'] := "Nao foi possivel incluir o registro, foi gerado um arquivo de log em " + cDirLog + cArqLog + " "
				lRet                  := .F.

			Else
				DbSelectArea("AF8")
				AF8->(dbSetOrder(1))
				If (AF8->(dbSeek(xFilial("AF8")+PAD(jJson:GetJsonObject("projeto"),TAMSX3("AFG_PROJET")[1]))))

					DbSelectArea("AFG")
					AFG->(dbSetOrder(2)) //AFG_FILIAL+AFG_NUMSC+AFG_ITEMSC+AFG_PROJET+AFG_REVISA+AFG_TAREFA
					If (AFG->(dbSeek(xFilial("AFG")+PAD(cDoc,TAMSX3("AFG_NUMSC")[1])+;
							PAD(jJson:GetJsonObject("item"),TAMSX3("AFG_ITEMSC")[1])+;
							PAD(jJson:GetJsonObject("projeto"),TAMSX3("AFG_PROJET")[1])+;
							PAD(AF8->AF8_REVISA,TAMSX3("AFG_REVISA")[1])+;
							PAD(jJson:GetJsonObject("tarefa"),TAMSX3("AFG_TAREFA")[1]))))
						lReckLock := .F.
					Else
						lReckLock := .T.
					EndIf

					Begin Transaction

						AFG->(RecLock("AFG",lReckLock))
							AFG->AFG_FILIAL := Alltrim(jJson:GetJsonObject("filial"))
							AFG->AFG_PROJET := AllTrim(jJson:GetJsonObject("projeto"))
							AFG->AFG_TAREFA := AllTrim(jJson:GetJsonObject("tarefa"))
							AFG->AFG_NUMSC  := AllTrim(cDoc)
							AFG->AFG_ITEMSC := AllTrim(jJson:GetJsonObject("item"))
							AFG->AFG_COD    := AllTrim(jJson:GetJsonObject("produto"))
							AFG->AFG_QUANT  := jJson:GetJsonObject("quant")
							AFG->AFG_REVISA := AF8->AF8_REVISA
						AFG->(MsUnLock())

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
@since 03/01/2024
@version 1.0
@type method
@param id, Caractere, String que será pesquisada através do MsSeek

@obs Abaixo um exemplo do JSON que deverá vir no body

    * 1: Para campos do tipo Numérico, informe o valor sem usar as aspas
    * 2: Para campos do tipo Data, informe uma string no padrão 'YYYY-MM-DD'

    {
        "filial": "conteudo",
        "num": "conteudo",
        "item": "conteudo",
        "produto": "conteudo",
        "descri ": "conteudo",
        "um": "conteudo",
        "quant": "conteudo",
        "vunit": "conteudo",
        "xpropri": "conteudo",
        "cc": "conteudo",
        "itemcta": "conteudo",
        "clvl": "conteudo",
        "xpriori": "conteudo",
        "xnomecp": "conteudo",
        "local": "conteudo",
        "emissao": "conteudo",
        "conta": "conteudo",
        "projeto": "conteudo",
        "tarefa": "conteudo"
    }
/*/
WSMETHOD DELETE ERASE WSRECEIVE id WSSERVICE OZ02W02
	Local jJson             := Nil
	Local lRet              := .T. as logical
	Local lPermiteExcluir   := .F. as logical
	Local jResponse         := JsonObject():New()
	Local cAliasWS          := "SC1"
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

	PREPARE ENVIRONMENT EMPRESA COD_EMPRESA FILIAL Alltrim(jJson:GetJsonObject("filial")) MODULO "COM" TABLES "SC1"

	aArea      := GetArea()
	cEmpBkp    := cEmpAnt
	cFilBkp    := cFilAnt
	cNumEmpBkp := cNumEmp
	cEmpAnt    := COD_EMPRESA
	cFilAnt    := Alltrim(jJson:GetJsonObject("filial"))
	cNumEmp    := cEmpAnt + cFilAnt
	OpenFile(cNumEmp)

	If ( Empty(AllTrim(jJson:GetJsonObject("num"))) )
		Self:setStatus(NAO_ENVIADO)
		jResponse['errorId']  := "DEL010"
		jResponse['error']    := "Numero da SC vazio"
		jResponse['solution'] := "Informe Numero da SC"
	Else
		If ( ! Empty(cError) )
			Self:setStatus(NAO_ENVIADO)
			jResponse['errorId']  := 'DEL012'
			jResponse['error']    := 'Parse do JSON'
			jResponse['solution'] := 'Erro ao fazer o Parse do JSON'

		Else
			DbSelectArea(cAliasWS)
			(cAliasWS)->(DbSetOrder(1))
			If ((cAliasWS)->(MsSeek(FWxFilial(cAliasWS) + PAD(jJson:GetJsonObject("num"),TAMSX3("C1_NUM")[1])  +;
					PAD(jJson:GetJsonObject("item"),TAMSX3("C1_ITEM")[1]) +;
					PAD(SPACE(03),TAMSX3("C1_ITEMGRD")[1]))))

				While (cAliasWS)->(!EOF()) .And. SC1->C1_NUM = PAD(jJson:GetJsonObject("num"),TAMSX3("C1_NUM")[1]) .And.;
						SC1->C1_ITEM = PAD(jJson:GetJsonObject("item"),TAMSX3("C1_ITEM")[1])

					If ( SC1->C1_APROV $ BLOQUEADO )
						(cAliasWS)->(RecLock("SC1"))
						dbDelete()
						(cAliasWS)->(MsUnLock())
						lPermiteExcluir := .T.
					Else 
						lPermiteExcluir := .F.
						Exit
					EndIf

					(cAliasWS)->(DbSkip())
				EndDo

				If ( lPermiteExcluir )
					Self:setStatus(ENVIADO)
					jResponse['note']     := "Registro Excluido com sucesso"
					jResponse['filial']   := Alltrim(jJson:GetJsonObject("filial"))
					jResponse['num']      := Alltrim(jJson:GetJsonObject('num'))
					lRet                  := .T.
				Else 
					Self:setStatus(NAO_ENVIADO)
					jResponse['note']     := "SC Não pode ser Excluido, Encontra-se Aprovado no Protheus"
					jResponse['filial']   := Alltrim(jJson:GetJsonObject("filial"))
					jResponse['num']      := Alltrim(jJson:GetJsonObject('num'))
					lRet                  := .F.
				EndIf

			Else
				Self:setStatus(NAO_ENVIADO)
				jResponse['errorId']  := "DEL011"
				jResponse['error']    := "Numero de SC não encontrado"
				jResponse['solution'] := "Numero de SC não encontrado na tabela " + cAliasWS
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
