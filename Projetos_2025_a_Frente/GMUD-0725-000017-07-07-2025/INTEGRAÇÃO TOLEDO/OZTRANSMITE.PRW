#Include "Protheus.ch"
#Include "ApWizard.ch"
#Include "Fileio.ch"
#Include "RptDef.ch"
#Include "FwPrintSetup.ch"
#Include "Totvs.ch"
#Include "ParmType.ch"

Static _nOpcErro := 0

Static _cMsgErro := ""

/*/{Protheus.doc} OZTRANSMITE
Função para transmitir Nfe gerada após integração API Balança Toledo ao Protheus
Projeto Integração TOLEDO

@author Julio Martins - Crmservices
@since Maio/2025
/*/

// c_Alias    = SF2
// c_SerDoc   = SF2->F2_SERIE
// c_NfsIni   = SF2->F2_DOC
// c_NfsFim   = SF2->F2_DOC
// l_End      = Status da transmissão

User Function OZTRANSMITE(c_Alias,c_SerDoc,c_NfsIni,c_NfsFim,l_End)

	Local _aArea := GetArea()
	Local lRet   := .F.
	
	Default c_Alias := ""
	Default c_SerDoc := ""
	Default c_NfsIni := ""
	Default c_NfsFim := ""
	
	Default l_End := .F.
	
	// Inicializa as variaveis static's.
	_nOpcErro := 0
	_cMsgErro := ""
	
	If !Empty(c_Alias)
		// Função para transmitir 
		lRet := _fTransmit(c_Alias,c_SerDoc,c_NfsIni,c_NfsFim)
	EndIf
	
	RestArea(_aArea)
	
Return lRet

Static Function _fTransmit(c_Alias,c_SerDoc,c_NfsIni,c_NfsFim,l_End)
Local _oWebServ := Nil	
Local _cIdEnt := ""
Local _cAmbiente := ""
Local _cURL := ""
Local _cUsaColab := ""
Local _cUserNeog := ""
Local _cPassword := ""
Local _cConFall := ""
Local _cDocColab := ""
Local _cConteudo := ""
Local _cModel := "55"
Local _cModalida := ""
Local _cVersao := ""
Local _cRetorno := ""

Local _lOk := .F.
Local _lNfeCancE := .F.

Local _nRetCol := 0
Local _nAmbNFeC := 0
Local _nAmbCTeC := 0

Local lRet      := .F.		

Private _lUsaColab := UsaColaboracao("1")

Private bFiltraBrw := {|| }

Default c_Alias := ""
Default c_SerDoc := ""
Default c_NfsIni := ""
Default c_NfsFim := ""

Default l_End := .F.

	// Função para ajustar a numeração da nota
	_fAjustVar(c_Alias,@c_NfsIni,@c_NfsFim,@c_SerDoc)
	
	// Pega os parametros para utilização do webservice
	_cURL := PadR(GetMv("MV_SPEDURL",,"http://"),250)
	_cUsaColab := GetMv("MV_SPEDCOL",,"N")
	_cUserNeog := GetMv("MV_USERCOL",,"")
	_cPassword := GetMv("MV_PASSCOL",,"")
	_cConFall := GetMv("MV_CONFALL",,"N")
	_cDocColab := GetMv("MV_DOCSCOL",,"0")
	
	_nRetCol := GetMv("MV_NRETCOL",,10)
	_nAmbNFeC := GetMv("MV_AMBCTEC",,2)
	_nAmbCTeC := GetMv("MV_AMBICOL",,2)

	_lNfeCancE := GetMv("MV_NFECAEV",,.F.)	// Cancelamento de NF-e por Evento
	
	// Busca o ID com a função static function do SPEDNFE
	_cIdEnt := GetIdEnt()
	
	If !Empty(_cIdEnt)
		If _lUsaColab
			_lOk := ColParValid(Iif(lCte,"CTE","NFE"),@_cRetorno)
						
			If _lOk				
				_lNfeCancE := .T.
				_cAmbiente := ColGetPar("MV_AMBIENT","")+" - " +ColDescOpcao("MV_AMBIENT", ColGetPar("MV_AMBIENT","") )			
				_cVersao := ColGetPar("MV_VERSAO","")
				_cModalida := ColGetPar("MV_MODALID","")+" - " +ColDescOpcao("MV_MODALID", ColGetPar("MV_MODALID","") )				
			EndIf
		Else
			// Estancia o objeto do webservice
			_oWebServ := WsSpedCfgNFe():New()
			
			// Obtem o ambiente de execucao do Totvs Services SPED                     ³
			_oWebServ:cUSERTOKEN := "TOTVS"
			_oWebServ:cID_ENT    := _cIdEnt
			_oWebServ:nAmbiente  := 0	
			_oWebServ:_URL := AllTrim(_cURL) + "/SPEDCFGNFe.apw"
			
			_lOk := _oWebServ:CFGAMBIENTE()
			_cAmbiente := _oWebServ:cCfgAmbienteResult
			
			If _lOk
				_lOk := _oWebServ:CfgTSSVersao()
			EndIf
			
			// Obtem a modalidade de comunicacao com a SEFAZ TSS ou TOTVS Colaboracao
			If _lOk .And. _oWebServ:cCfgTssVersaoResult >= "1.35"
				_oWebServ:cUSERTOKEN := "TOTVS"
				_oWebServ:cID_ENT := _cIdEnt			
				_oWebServ:cUSACOLAB := _cUsaColab
				_oWebServ:nNUMRETNF := _nRetCol
				_oWebServ:nAMBIENTE := 0
				_oWebServ:nMODALIDADE := 0
				_oWebServ:cVERSAONFE := ""
				_oWebServ:cVERSAONSE := ""
				_oWebServ:cVERSAODPEC := ""
				_oWebServ:cVERSAOCTE := ""
				_oWebServ:cUSERNEOG := _cUserNeog
				_oWebServ:cPASSWORD := _cPassword
				_oWebServ:cCONFALL := _cConFall
				                      
				If _oWebServ:cCfgTssVersaoResult >= "1.43"
					If "1" $ Upper(_cDocColab)
		    			_cConteudo += "1"
		    		EndIf
		    		
		    		If "2" $ Upper(_cDocColab)
						_cConteudo += "2"
		    		EndIf
		    		
		    		If "3" $ Upper(_cDocColab)
						_cConteudo += "3"
		    		EndIf
		    		                    
		    		If "4" $ Upper(_cDocColab)
						_cConteudo := "4"
		    		EndIf
		    		
		    		If "0" $ Upper(_cDocColab)
						_cConteudo := "0"
		    		EndIf
		    		
					//-- Cancelamento por Evento
					If _oWebServ:cCfgTssVersaoResult >= "2.15"
						_oWebServ:lNFeCancEvento := _lNfeCancE
					EndIf
					
					_oWebServ:cDOCSCOL	:= _cConteudo
					_oWebServ:nAMBNFECOLAB:= IIF(_nAmbNFeC >= 1 .And. _nAmbNFeC <=2,_nAmbNFeC,2)
					_oWebServ:nAMBCTECOLAB:= IIF(_nAmbCTeC >= 1 .And. _nAmbCTeC <=2,_nAmbCTeC,2)
				EndIf
				
				//Habilita o uso do evento EPEC para NFe 3.10
				If _oWebServ:cCfgTssVersaoResult >= "2.38"
					_oWebServ:cNFEENVEPEC := "1"
				EndIf
				
				_oWebServ:_URL := AllTrim(_cURL) + "/SPEDCFGNFe.apw"
				_oWebServ:CFGPARAMSPED()		
			EndIf
		
			// Obtem a modalidade de execucao do Totvs Services SPED
			If _lOk
				_oWebServ:cUSERTOKEN := "TOTVS"
				_oWebServ:cID_ENT := _cIdEnt
				_oWebServ:nModalidade := 0
				_oWebServ:_URL := AllTrim(_cURL) + "/SPEDCFGNFe.apw"
				_oWebServ:cModelo := _cModel
				_lOk := _oWebServ:CFGModalidade()
				_cModalida := _oWebServ:cCfgModalidadeResult
			EndIf
		
			// Obtem a versao de trabalho da NFe do Totvs Services SPED
			If _lOk
				_oWebServ:cUSERTOKEN := "TOTVS"
				_oWebServ:cID_ENT := _cIdEnt
				_oWebServ:cVersao := "0.00"
				_oWebServ:_URL := AllTrim(_cURL) + "/SPEDCFGNFe.apw"
				_lOk := _oWebServ:CFGVersao()
				_cVersao := _oWebServ:cCfgVersaoResult
			EndIf
			
			If _lOk
				_oWebServ:cUSERTOKEN := "TOTVS"
				_oWebServ:cID_ENT := _cIdEnt
				_oWebServ:cVersao := "0.00"
				_oWebServ:_URL := AllTrim(_cURL) + "/SPEDCFGNFe.apw"
				_lOk := _oWebServ:CFGVersaoCTe()
			EndIf
				
			If _lOk
				_oWebServ:cUSERTOKEN := "TOTVS"
				_oWebServ:cID_ENT := _cIdEnt
				_oWebServ:cVersao := "0.00"
				_oWebServ:_URL := AllTrim(_cURL) + "/SPEDCFGNFe.apw"
				_lOk := _oWebServ:CFGVersaoDpec()
			EndIf
			
			// Verifica o status na SEFAZ
			If _lOk .And. !_lUsaColab
				_oWebServ:= WSNFeSBRA():New()
				_oWebServ:cUSERTOKEN := "TOTVS"
				_oWebServ:cID_ENT := _cIdEnt
				_oWebServ:_URL := AllTrim(_cURL) + "/NFeSBRA.apw"
				
				_lOk := _oWebServ:MONITORSEFAZMODELO()
				
				If _lOk
					// _oWebServ:oWsMonitorSefazModeloResult:OWSMONITORSTATUSSEFAZMODELO
				EndIf
			EndIf
			
			_cRetorno := SpedNFeTrf(c_Alias,AllTrim(c_SerDoc),c_NfsIni,c_NfsFim,_cIdEnt,_cAmbiente,_cModalida,_cVersao,@l_End)
			
			lRet := _fVldTrans(c_Alias,AllTrim(c_SerDoc),c_NfsIni,c_NfsFim)
		EndIf
	EndIf
	
Return lRet

/*/{Protheus.doc} _fAjustVar
Função para ajustar as variaveis de numero da nota
/*/

Static Function _fAjustVar(c_Alias,c_NfsIni,c_NfsFim,c_SerDoc)

	Local _cAuxilia1 := ""
	Local _cAuxilia2 := ""
	
	Default c_NfsIni := ""
	Default c_NfsFim := ""
	Default c_SerDoc := ""
	
	If Empty(c_NfsFim)
		c_NfsFim := c_NfsIni
	EndIf	
	
	If AllTrim(Upper(c_Alias)) == "SF1"
		_cAuxilia1 := "F1_DOC"
		_cAuxilia2 := "F1_SERIE"
	ElseIf AllTrim(Upper(c_Alias)) == "SF2"
		_cAuxilia1 := "F2_DOC"
		_cAuxilia2 := "F2_SERIE"
	EndIf
	
	c_NfsIni := PadR(c_NfsIni,TamSx3(_cAuxilia1)[1])
	c_NfsFim := PadR(c_NfsFim,TamSx3(_cAuxilia1)[1])
	c_SerDoc := PadR(c_SerDoc,TamSx3(_cAuxilia2)[1])
	
Return

/*/{Protheus.doc} _fVldTrans
Função para validar a transmissão
/*/

Static Function _fVldTrans(c_Alias,c_SerDoc,c_NfsIni,c_NfsFim)

	Local _aArea := GetArea()
	Local _aAreaAls := (c_Alias)->(GetArea())
	
	Local _cAuxilia1 := ""
	Local _cAuxilia2 := ""
	Local _cAuxilia3 := ""
	
	Local _lContinua := .T.
	
	Default c_SerDoc := ""
	Default c_NfsIni := ""
	Default c_NfsFim := ""
	
	DbSelectArea(c_Alias)		// SF2 = Cabecalho das NF de Saida | SF1 = Cabecalho das NF de Entrada
	(c_Alias)->(DbSetOrder(1))	// SF2 = F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO | SF1 = F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO
	
	If AllTrim(Upper(c_Alias)) == "SF1"
		_cAuxilia1 := "F1_DOC"
		_cAuxilia2 := "F1_SERIE"
		_cAuxilia3 := "F1_FIMP"
	ElseIf AllTrim(Upper(c_Alias)) == "SF2"
		_cAuxilia1 := "F2_DOC"
		_cAuxilia2 := "F2_SERIE"
		_cAuxilia3 := "F2_FIMP"
	EndIf
	
	If !Empty(c_NfsFim)
		(c_Alias)->(DbGoTop())
		If (c_Alias)->(DbSeek(xFilial(c_Alias)+c_NfsIni+c_SerDoc))
			While (c_Alias)->(!Eof()) .And. AllTrim((c_Alias)->&(_cAuxilia2)) == c_SerDoc .And. (c_Alias)->&(_cAuxilia1) >= c_NfsIni .And. (c_Alias)->&(_cAuxilia1) <= c_NfsFim
				// Se for diferente de transmitido
				If (c_Alias)->&(_cAuxilia3) <> "T"
					_lContinua := .F.
					_nOpcErro := 1
					_cMsgErro += (c_Alias)->&(_cAuxilia1) + " - Não transmitida" + CRLF
				Else
					_cMsgErro += (c_Alias)->&(_cAuxilia1) + " - Transmitida" + CRLF
				EndIf
				(c_Alias)->(DbSkip())
			EndDo
		EndIf		
	EndIf
		
	RestArea(_aAreaAls)
	RestArea(_aArea)
	
Return _lContinua

/*/{Protheus.doc} FT024AOP
Função para retornar a opção do erro. Se for zero, é porque gerou normalmente.
@return numerico, opção de erro. Se for zero, é porque está ok.
/*/

User Function FT024AOP()

Return _nOpcErro

/*/{Protheus.doc} FT024AER
Função para retornar o a mensagens.
/*/

User Function FT024AER()

Return _cMsgErro


Static Function GetIdEnt(lUsaColab)

local cIdEnt := ""
local cError := ""

Default lUsaColab := .F.

If !lUsaColab

	cIdEnt := getCfgEntidade(@cError)

	if(empty(cIdEnt))
		Aviso("SPED", cError, {"SPED"}, 3) // STR0647 = "SPED"

	endif

else
	if !( ColCheckUpd() )
		Aviso("SPED", "UPDATE do TOTVS Colaboração 2.0 não aplicado. Desativado o uso do TOTVS Colaboração 2.0",{"SPED"},3) //STR0647 = "SPED", // STR0810 =  "UPDATE do TOTVS Colaboração 2.0 não aplicado. Desativado o uso do TOTVS Colaboração 2.0"
	else
		cIdEnt := "000000"
	endif
endIf

Return(cIdEnt)
