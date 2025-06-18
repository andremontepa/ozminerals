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

	 // Julio Martins - CRMServices - Junho 2025
    // Melhorias Solicitadas Sr KASSIO em reunião de 09/Jun/2025

@author JULIO MARTINS - CRMSERVICES
@since 10/JUN/2025
@version 1.0
@type wsrestful
/*/
WSRESTFUL OZ02W02 DESCRIPTION "Serviço de Post - RM TOP"
	WSDATA id         AS STRING

	WSMETHOD GET    ID     DESCRIPTION "Retorna o registro pesquisado" WSSYNTAX "/OZ02W02/get_id?{id}"  PATH "get_id"   PRODUCES APPLICATION_JSON
	WSMETHOD POST   NEW    DESCRIPTION "Inclusão de registro"          WSSYNTAX "/OZ02W02/new"          PATH "new"      PRODUCES APPLICATION_JSON
	WSMETHOD DELETE ERASE  DESCRIPTION "Exclusão de registro"          WSSYNTAX "/OZ02W02/erase"        PATH "erase"    PRODUCES APPLICATION_JSON
END WSRESTFUL


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
			jResponse['obsit']    := (cAliasWS)->C1_OBS
			jResponse['dataenv']    := (cAliasWS)->C1_XDTALT
			jResponse['horaenv']    := (cAliasWS)->C1_XHRALT

		EndIf
	EndIf

	Self:SetContentType('application/json')
	Self:SetResponse(jResponse:toJSON())
Return lRet
	

WSMETHOD POST NEW WSRECEIVE WSSERVICE OZ02W02
	Local jJson             := Nil
	Local nLinha            := 0  as integer
	Local lRet              := .T. as logical
	Local jResponse         := JsonObject():New()
	Local cJson             := Self:GetContent()
	Local cDirLog           := "\x_logs\" as character
	Local cArqLog           := ""  as character
	Local cErrorLog         := ""  as character
	Local cError            := ""  as character
	Local cEmpBkp 			:= ""  as character
	Local cFilBkp 			:= ""  as character
	Local cNumEmpBkp        := ""  as character
	Local cDoc              := ""  as character  // NUMERO SC
//	Local cIte              := ""  as character  // ITEM SC
//	Local cPro              := ""  as character  // Projeto
//	Local cRev              := ""  as character  // Revisão
//	Local cTar              := ""  as character  // Tarefa
//	Local cFil              := ""  as character  // Filial
	Local cTime             := Time()
	Local cProjet 			:= ""  as character  // Projeto
	Local cItems            := " " as character
	Local cDestar           := ""
	Local cTarefa           := ""
    Local nX                := 0   as numeric
	Local nY                := 0   as numeric
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

    cTime := substring(cTime,1,2)+substring(cTime,4,2)+substring(cTime,7,2)
	Self:SetContentType('application/json')
	jJson  := JsonObject():New()
	cError := jJson:FromJson(cJson)

	
	aArea      := GetArea()
	cEmpBkp    := cEmpAnt
	cFilBkp    := cFilAnt
	cNumEmpBkp := cNumEmp
	cEmpAnt    := Alltrim(jJson:GetJsonObject("empresa"))   //COD_EMPRESA
	cFilAnt    := Alltrim(jJson:GetJsonObject("filial"))
	cItems     := jJson:GetJsonObject("Items")
	cNumEmp    := cEmpAnt + cFilAnt

	SCfechasx()  
	SCAbreEmp()

If (!Empty (cError))
		Self:setStatus(NAO_ENVIADO)
		jResponse['errorId']  := 'NEW004'
		jResponse['error']    := 'Parse do JSON'
		jResponse['solution'] := 'Erro ao fazer o Parse do JSON'
Else
		DbSelectArea("SC1")
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

 		nY := len(cItems)
       	For nX  := 1 to nY
		aDados := {}
		aAdd(aDados, {"C1_ITEM"   ,   AllTrim(cItems[nX]:GetJsonObject("item"))   ,   Nil})
		aAdd(aDados, {"C1_PRODUTO",   AllTrim(cItems[nX]:GetJsonObject("produto")),   Nil})
		aAdd(aDados, {"C1_UM"     ,   AllTrim(cItems[nX]:GetJsonObject("um"))     ,   Nil})
		aAdd(aDados, {"C1_VUNIT"  ,   cItems[nX]:GetJsonObject("vunit")           ,   Nil})
		aAdd(aDados, {"C1_QUANT"  ,   cItems[nX]:GetJsonObject("quant")           ,   Nil})
		aAdd(aDados, {"C1_LOCAL"  ,   AllTrim(cItems[nX]:GetJsonObject("local"))  ,   Nil})
		aAdd(aDados, {"C1_XPROPRI",   PROPRIEDADE                            ,   Nil})
		aAdd(aDados, {"C1_CC"     ,   AllTrim(cItems[nX]:GetJsonObject("cc"))     ,   Nil})
		aAdd(aDados, {"C1_ITEMCTA",   AllTrim(cItems[nX]:GetJsonObject("itemcta")),   Nil})
		aAdd(aDados, {"C1_CLVL"   ,   AllTrim(cItems[nX]:GetJsonObject("clvl"))   ,   Nil})
		aAdd(aDados, {"C1_XPRIORI",   AllTrim(cItems[nX]:GetJsonObject("priori"))   ,   Nil})
		aAdd(aDados, {"C1_OBS",   AllTrim(cItems[nX]:GetJsonObject("obsit")),   Nil})
        aAdd(aDados, {"C1_FORNECE",   AllTrim(cItems[nX]:GetJsonObject("fornece"))   ,   Nil})
		aAdd(aDados, {"C1_LOJA",   AllTrim(cItems[nX]:GetJsonObject("loja"))   ,   Nil})
		aAdd(aDados, {"C1_XPROJET",   AllTrim(cItems[nX]:GetJsonObject("projeto")),   Nil})
		aAdd(aDados, {"C1_XTAREFA",   AllTrim(cItems[nX]:GetJsonObject("tarefa")) ,   Nil})
		aAdd(aDados, {"C1_ORIGEM",   "TCOPRM" ,   Nil}) // Identifica SC vindo do RM
        aAdd(aDados, {"C1_XDTALT",   DDATABASE ,   Nil})
		aAdd(aDados, {"C1_XHRALT",  cTime ,   Nil})
		aadd(aItensSC,aDados)
	   	Next nX  
		
        cProjet := AllTrim(cItems[1]:GetJsonObject("projeto"))
/* https://tdn.totvs.com/pages/releaseview.action?pageId=318605213 */

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
				jResponse['error']    := "Erro na inclusao do registro"
				jResponse['solution'] := "Nao foi possivel incluir o registro, foi gerado um arquivo de log em " + cDirLog + cArqLog + " "
				lRet                  := .F.

		    Else
			//DbSelectArea("AF8")
			//dbSetOrder(1)
			// If dbSeek(xFilial("AF8")+cProjet) // Se o Projeto existir
			// 	cFil := AF8->AF8_FILIAL
			//	cRev := AF8->AF8_REVISA
			// Endif				   
				   				   
				  // cFil := AF8->AF8_FILIAL
				  //	cRev := AF8->AF8_REVISA
					DbSelectArea("AFG")
					dbSetOrder(7) //AFG_FILIAL+AFG_PROJET+AFG_REVISA+AFG_TAREFA+AFG_NUMSC+AFG_ITEMSC
				  //If !dbSeek(xFilial("AFG")+cDoc)
				  //Begin Transaction
					For nX  := 1 To Len (cItems)
						RecLock("AFG", .T.)
						cProjet := AllTrim(cItems[nX]:GetJsonObject("projeto"))
						cTarefa := AllTrim(cItems[nX]:GetJsonObject("tarefa"))
						cDestar := u_PegaDesSC(cProjet,cTarefa)
						AFG->AFG_FILIAL := Alltrim(jJson:GetJsonObject("filial")) 
						AFG->AFG_PROJET := AllTrim(cItems[nX]:GetJsonObject("projeto"))
						AFG->AFG_TAREFA := AllTrim(cItems[nX]:GetJsonObject("tarefa"))
						AFG->AFG_DESCRU := cDestar
						AFG->AFG_NUMSC  := AllTrim(cDoc)
						AFG->AFG_ITEMSC := AllTrim(cItems[nX]:GetJsonObject("item"))
						AFG->AFG_COD    := AllTrim(cItems[nX]:GetJsonObject("produto"))
						AFG->AFG_QUANT  := cItems[nX]:GetJsonObject("quant")
						//AFG->AFG_REVISA := cRev
						AFG->AFG_CC     := AllTrim(cItems[nX]:GetJsonObject("cc"))  
		 				AFG->AFG_ITEMCT := AllTrim(cItems[nX]:GetJsonObject("itemcta"))
	     				AFG->AFG_CLVL   := AllTrim(cItems[nX]:GetJsonObject("clvl"))  
						AFG->(MsUnlock())
					Next nX
					
				  //End Transaction
				  //  EndIf 
				Self:setStatus(ENVIADO)
				jResponse['note']     := "SOLICITACAO INCLUIDA COM SUCESSO"
				jResponse['empresa']  := Alltrim(jJson:GetJsonObject("empresa"))
				jResponse['filial']   := Alltrim(jJson:GetJsonObject("filial"))
				jResponse['num']      := cDoc
				lRet                  := .T.
		    endif
	Self:SetResponse(jResponse:toJSON())


Endif


RestArea(aArea)

Return lRet


WSMETHOD DELETE ERASE WSRECEIVE id WSSERVICE OZ02W02
	Local jJson             := Nil
	Local lRet              := .T. as logical
	Local lPermiteExcluir   := .F. as logical
	Local jResponse         := JsonObject():New()
//	Local cAliasWS          := "SC1"
	Local cJson             := Self:GetContent()
	Local cError            := ""  as character
	Local cEmpBkp 			:= ""  as character
	Local cFilBkp 			:= ""  as character
	Local cNumEmpBkp        := ""  as character
	Local cNumEmp			:= ""  as character
	Local cIte              := ""  as character  
	Local cNum              := ""  as character
 	Local cItems            := " " as character
    Local cAprova           := "B" as character
//	Local cDestar           :=""
	Local nX                := 0   as Numeric
	Local aArea             := {}  as array
	Private lMsErroAuto     := .F. as logical
	Private lMsHelpAuto     := .T. as logical
	Private lAutoErrNoFile  := .T. as logical

	Self:SetContentType('application/json')
	jJson  := JsonObject():New()
	cError := jJson:FromJson(cJson)

	aArea      := GetArea()
	cEmpBkp    := cEmpAnt
	cFilBkp    := cFilAnt
	cNumEmpBkp := cNumEmp
	cEmpAnt    := Alltrim(jJson:GetJsonObject("empresa"))
	cFilAnt    := Alltrim(jJson:GetJsonObject("filial"))
	cNumEmp    := cEmpAnt + cFilAnt
	cItems     := jJson:GetJsonObject("Items")

	SCfechasx()  
	SCAbreEmp()
	
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

		cNum := jJson:GetJsonObject("num")
			DbSelectArea("SC1")
			DbSetOrder(1)
          		  For nX  := 1 To Len (cItems)	
					cIte := AllTrim(cItems[nX]:GetJsonObject("item"))
						If dbSeek(xFilial("SC1")+cNum+cIte+space(3))
                           	cAprova := SC1->C1_APROV
								If cAprova == "B"  // ( SC1->C1_APROV $ BLOQUEADO )
									RecLock("SC1")
									dbDelete()
									MsUnLock()
									lPermiteExcluir := .T.
										Self:setStatus(ENVIADO)
										jResponse['note']     := "ITENS SOLICITACAO "+cNum+" EXCLUIDOS!"
										jResponse['filial']   := Alltrim(jJson:GetJsonObject("filial"))
										jResponse['num']      := Alltrim(jJson:GetJsonObject('num'))
										Self:SetResponse(jResponse:toJSON())
										lRet                  := .T.

								Else
										Self:setStatus(NAO_ENVIADO)
										jResponse['note']     := "Solicitacao "+cNum+" Item "+cIte+" Aprovado nao pode ser excluido!"
										jResponse['filial']   := Alltrim(jJson:GetJsonObject("filial"))
										jResponse['num']      := Alltrim(jJson:GetJsonObject('num'))
										Self:SetResponse(jResponse:toJSON())
								endif
						Else		
										Self:setStatus(NAO_ENVIADO)
										jResponse['note']     := "Solicitacao "+cNum+" Item "+cIte+" nao encontrada!"
										jResponse['filial']   := Alltrim(jJson:GetJsonObject("filial"))
										jResponse['num']      := Alltrim(jJson:GetJsonObject('num'))
										Self:SetResponse(jResponse:toJSON())										

						Endif
				  next nX

	
		EndIf
	EndIf

RestArea(aArea)

Return lRet


***********************
Static function SCFechaSX()
***********************
Local nX

     if Select("XXS") > 0 ; XXS->(dbCloseArea()) ; endif
     if Select("XB3") > 0 ; XB3->(dbCloseArea()) ; endif
     if Select("SIX") > 0 ; SIX->(dbCloseArea()) ; endif
     if Select("XAB") > 0 ; XAB->(dbCloseArea()) ; endif
     if Select("XAL") > 0 ; XAL->(dbCloseArea()) ; endif
     if Select("XAM") > 0 ; XAM->(dbCloseArea()) ; endif
     if Select("XAN") > 0 ; XAN->(dbCloseArea()) ; endif
     if Select("XAO") > 0 ; XAO->(dbCloseArea()) ; endif
     if Select("XAP") > 0 ; XAP->(dbCloseArea()) ; endif
     if Select("XAS") > 0 ; XAS->(dbCloseArea()) ; endif

     cAlias := "SX0"              // fecha todos os SXs
     for nX := 1 to 40
        if (Select(cAlias)>0)
           (cAlias)->(dbCloseArea())
        endif     
        cAlias := soma1(cAlias)
     next

     cAlias := "XX1"             // fecha todos os XXs
     for nX := 1 to 40
        if (Select(cAlias)>0)
           (cAlias)->(dbCloseArea())
        endif     
        cAlias := soma1(cAlias)
     next

return NIL



***********************
Static function SCAbreEmp()
***********************

cNumEmp := cEmpAnt+cFilAnt
     
Opensm0(cNumEmp)
Openfile(cNumEmp)

return NIL

User Function PegaDesSC(cProjet,cTarefa)
DbSelectArea("ZF9")
dbSetOrder(1) 
If dbSeek(xFilial("ZF9")+ cProjet+cTarefa)  
cDestar := substring(ZF9_DESCR,1,30)
else
cDestar :="@@Projeto/Tarefa não encontrado@@ " 
endif
Return(cDestar)
