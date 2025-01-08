#INCLUDE "totvs.CH"
#INCLUDE "protheus.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch" 

/*/{Protheus.doc} PCOA02C
Fonte para importação de um arquivo csv
@type Function
@author Caio.Lima
@since 05/09/2021
@history 09/08/2022, Flavio Dias, Adicionado o campo AK2_ITCTB.
@Impact - , Samael Nascimento, ajustado para aderëncia.
/*/
User Function PCOA02C()
	Local _aSays := {}, _aButtons := {}
	Local _lOk := .F.
	Local _lPerg := .F.
	Local _cFilOri := cFilAnt

	Private _cAk1Cod := ""
	Private _cAno    := ""
	Private _cFile   := ""
	Private _nOpc    := 0
	Private _nDupl   := 0

	Aadd(_aSays , "Essa rotina tem o objetivo de efetuar a importaçao de uma planilha csv" )
	Aadd(_aSays , "para gerar um novo cadastro de orçamento do PCO" )
	Aadd(_aSays , "caso o codigo do orçamento informado já exista será gerado uma nova versão" )
	Aadd(_aSays , "caso não exista será gerado um novo cadastro." )
	Aadd(_aSays , "Empresa: " + cEmpAnt )
	Aadd(_aSays , "Filial: " + _cFilOri )

	AADD(_aButtons,{5 , .T. , {|| _lPerg := fparam() } } )
	Aadd(_aButtons,{1 , .T. , {|| _lOk := .T., FechaBatch() } }    )
	Aadd(_aButtons,{2 , .T. , {|| FechaBatch() } }    )

	FormBatch("Importação de orçamento",_aSays,_aButtons,,250,500)

	If _lOk
		If !_lPerg
			_lPerg := fparam()
		EndIf
		If _lPerg
			FWMsgRun( /* Obj_tela */ , {|oSay| fImport(_cFile, oSay) } , "Processando." , "Importando a planilha, aguarde..." )
		EndIf
	EndIf

	lMsErroAuto := .F.
	fChgEmp(_cFilOri)

Return

/*/{Protheus.doc} fImport
Faz a importação do arquivo
@type Function
@author Caio.Lima
@since 05/09/2021
/*/
Static Function fImport(_cCSV, oSay)

	Local _aFile := {}
	Local _aCabec := {}
	Local _aDados := {}

	// limpa o log atual para recomeçar
	MostraErro("z", "z")

	oSay:cCaption := "Lendo arquivo " + AllTrim(_cCSV)
	ProcessMessage()
	_aFile := fLeArq(_cCSV, oSay)

	If Len(_aFile) <= 1
		MsgAlert("Arquivo sem linhas")
		Return
	EndIf

	oSay:cCaption := "Preparando dados"
	ProcessMessage()
	_aFile := fPrepara(_aFile)

	_aCabec := _aFile[1]
	aEval(_aCabec, {|x,y| _aCabec[y] := Upper(_aCabec[y]) })
	_aDados := _aFile[2]

	oSay:cCaption := "Gravando dados"
	ProcessMessage()
	If fGrava(_aCabec, _aDados)
		AutoGrLog("Operação concluida com sucesso!!!")
		MostraErro()
	else
		AutoGrLog("Operação concluida com erro!")
		MostraErro()
	EndIf

Return

/*/{Protheus.doc} fPrepara
Prepara o array para o processamento e gravação dos dados
retorna um array de duas posições, linha 1 cabecalho, linha 2 dados
@author Caio.Lima
@since 05/09/2021
@type Function
/*/
Static Function fPrepara(_aArray)
	Local _aRet := Array(2)
	Local _aDePara := {}
	Local _nx := 0
	Local _aCabec := {}
	Local _aDados := {}

	/* Aadd(_aDePara, {"B1_DESC"   ,  "Descrição 60"} )
	Aadd(_aDePara, {"B1_COD"    ,  "Cód. ERP - Item"} )
	Aadd(_aDePara, {"B1_POSIPI" ,  "PDA-NCM - NCM"} )
	Aadd(_aDePara, {"B1_UM"     ,  "PDA-UNIDAD - UNIDADE"} )
	Aadd(_aDePara, {"B1_CODCAT" ,  "Código - Categoria"} )
	Aadd(_aDePara, {"B1_CODSCAT",  "Código - Subcategoria"} )
	Aadd(_aDePara, {"B1_CODPD"  ,  "Código - PD"} )
	Aadd(_aDePara, {"B1_ASTRCOD",  "ID - Item"} )
	Aadd(_aDePara, {"B1_ESPLONG",  "Especificação - Item"} )
	Aadd(_aDePara, {"ZK_TIPOPD" ,  "Tipo PD - PD"} )
	Aadd(_aDePara, {"ZK_DESC"   ,  "Título - PD"} )
	Aadd(_aDePara, {"ZL_DESC"   ,  "Subcategoria - Descrição"} )
	Aadd(_aDePara, {"ZI_DESC"   ,  "Categoria - Descrição"} ) */

	If Len(_aArray) > 1
		_aCabec := _aArray[1]
		_aDados := aClone(_aArray)
		aDel(_aDados, 1)
		ASize(_aDados, Len(_aDados) - 1)

		For _nx := 1 to Len(_aDePara)
			_nP := AScan(_aCabec, _aDePara[_nx,2])
			If _nP > 0
				_aCabec[_nP] := _aDePara[_nx,1]
			EndIf
		Next
		_aRet[1] := _aCabec
		_aRet[2] := _aDados
	EndIf
Return(_aRet)

/*/{Protheus.doc} fLeArq
Faz a leitura do arquivo
@author Caio.Lima
@since 05/09/2021
@type Function
/*/
Static Function fLeArq(_cArq, oSay, _aDPData )
	Local _aRet := {}
	Local _nx := 0
	Local _ny := 0
	Local _cChar := ""
	Local _cFileSrv := ""

	Default _aDPData := {}

	if !Left(_cArq, 1) $ "\/"
		_cFileSrv := "\SYSTEM\"
		//Alert(_cFileSrv)
		// copia o arquivo para o servidor antes de iniciar
		MsgRun("de: "+ _cArq + CRLF + "para: " + _cFileSrv, "Copiar arquivo",{|| CpyT2S(_cArq, _cFileSrv) })
		_cFileSrv += SubStr(_cArq, RAt("\", _cArq) + 1 )
		_cArq := _cFileSrv
	EndIf

	_nFile := FOpen(_cArq)
	If _nFile = -1
		Alert("Falha ao abrir arquivo: " + CRLF + _cArq)
	Else // se conseguiu abrir arquivo
		FSeek(_nFile,0) // posiciona na primeira linha do arquivo
		nBtLidos := FRead(_nFile,@_cChar,1)
		_cLinha := ""
		_lOpen := .F.
		// lê byte a byte
		While nBtLidos >= 1
			If (_cChar = Chr(13) .OR. _cChar = Chr(10)) .AND. !_lOpen
				If !Empty(_cLinha)
					// substituição das palavras invalidas
					AEval(_aDPData, {|x,y| _cLinha := StrTran(_cLinha, x[1], x[2]) })
					Aadd(_aRet, _cLinha )
					oSay:cCaption := "Lendo o arquivo. linha: " + cValToChar(Len(_aRet))
				EndIf
				_cLinha := ""
			ElseIf _cChar == '"'
				_lOpen := !_lOpen
				If _lOpen
					_cOpen := ""
				ElseIf Empty(_cOpen)
					_cLinha += '||'
				Else
					_cLinha += '"' // fechamento
				EndIf
			Else
				If _lOpen .AND. Empty(_cOpen)
					_cOpen := "1"
					_cLinha += '"' // abertura
				EndIf
				_cLinha += _cChar
			EndIf
			nBtLidos := FRead(_nFile,@_cChar,1)
		End
		Fclose(_nFile) // fecha arquivo
	EndIf

	For _nx:= 1 to Len(_aRet)
		_cLin := _aRet[_nx] + " "
		_cCampo := ""
		_aLin := {}

		oSay:cCaption := "Processando o arquivo. linha: " + cValToChar(_nx)

		_ny := 1
		While _ny <= Len(_cLin)
			_cRest := SubStr(_cLin,_ny)
			_cChar := SubStr(_cLin,_ny,1)
			_cNext := SubStr(_cLin,_ny+1,1)
			_nPIni := _ny
			_cAt := ';'
			If _cChar == '"' .AND. !_cNext $ '" '
				_cAt := '";'
				_nPIni++
			EndIf

			_nPFim := At(_cAt, _cLin, _nPIni )
			If _nPFim <= 0
				_nPFim := Len(_cLin) + 1
			EndIf
			_cCampo := SubStr(_cLin,_nPIni, _nPFim - _nPIni)
			_ny := _nPFim + Len(_cAt)
			Aadd(_aLin, AllTrim(StrTran(_cCampo, "||", "") ))
		End
		_aRet[_nx] := _aLin
	Next

	If !Empty(_cFileSrv)
		FErase(_cFileSrv)
	EndIf

Return(_aRet)

/*/{Protheus.doc} fGrava
Grava os dados do arquivo nas tabelas necessárias
@author Caio.Lima
@since 05/09/2021
@type Function
@history 09/08/2022, Flavio Dias, adicionado o coluna AK2_ITCTB para gravar no Orçmaneto.
/*/
Static Function fGrava(_aCabec, _aDados)
	Local _lRet := .T.
	Local _nLin := 0
	Local _lNew := .T.
	Local _cMsg := ""
	Local _nx := 0
    Local _cCTTDesc := ""
	Local _lNVersao := _nOpc == 2

	Private _cVersao := "0001"

	dbSelectArea("AK1")
	AK1->(dbSetOrder(1)) // AK1_FILIAL+AK1_CODIGO+AK1_VERSAO
	_lNew := !AK1->(dbSeek(xFilial("AK1") + _cAk1Cod))

	If _lNew
		_cMsg := "O orçamento " + _cAk1Cod + " não foi localizado, será gerado um **NOVO** cadastro." + CRLF
	Else
		If _lNVersao
			_cMsg := "O orçamento " + _cAk1Cod + " já existe, será gerado uma nova **VERSÃO** para esse orçamento." + CRLF
		Else
			_cMsg := "O orçamento " + _cAk1Cod + " já existe, e o prametro de operação está para gerar um complemento." + CRLF
			_cMsg += "O orçamento atual será alterado de acordo com a planilha" + CRLF
		EndIf
	EndIf
	
	_cMsg += CRLF

	If _nDupl == 1 // somar
		_cMsg += "Caso a linha que está sendo importada já exista o valor será SOMADO" + CRLF
	ElseIf _nDupl == 2 // sobrescrever
		_cMsg += "Caso a linha que está sendo importada já exista o valor será SOBRESCRITO" + CRLF
	Else // ignorar segunda ocorrencia
		_cMsg += "Caso a linha que está sendo importada já exista o valor será IGNORADO" + CRLF
	EndIf
	
	_cMsg += CRLF + "Continuar?"

	If Aviso( 'ATENÇÃO', _cMsg ,{'OK' , "Cancelar"} ,4,,,, .T.) == 2
		MsgAlert("Operação cancelada!")
		return(.F.)
	EndIf

	Begin Transaction

		If _lNew
			If !fGerNewOrc(_aCabec, _aDados)
				Return(.F.)
			EndIf
		Else
			If _lNVersao
				_cVersao := Soma1(AK1->AK1_VERSAO)

				dbSelectArea("AK3")
				AK3->(dbSetOrder(1)) // AK3_FILIAL+AK3_ORCAME+AK3_VERSAO+AK3_CO
				If AK3->(dbSeek(xFilial("AK3") + _cAk1Cod + AK1->AK1_VERSAO + _cAk1Cod ))
					RegToMemory("AK3", .F., .F., .F.)
					M->AK3_VERSAO := _cVersao
					AxIncluiAuto("AK3" ,,, 3)
				EndIf

				RecLock("AK1" ,  .F. )
				AK1->AK1_VERSAO := _cVersao
				AK1->AK1_STATUS := "1"
				//AK1->AK1_VERREV := AK1->AK1_VERSAO
				AK1->(MsUnlock())
			else
				_cVersao := AK1->AK1_VERSAO
			EndIf
		EndIf

		dbSelectArea("AK3")
		AK3->(dbSetOrder(1)) // AK3_FILIAL+AK3_ORCAME+AK3_VERSAO+AK3_CO

		dbSelectArea("AK5")
		AK5->(dbSetOrder(1)) // AK5_FILIAL, AK5_CODIGO, R_E_C_D_E_L_

		dbSelectArea("AK2")
		AK2->(dbSetOrder(1)) // AK2_FILIAL+AK2_ORCAME+AK2_VERSAO+AK2_CO+AK2_ID+DTOS(AK2_PERIOD)

		_nCO   := AScan(_aCabec, "CC" )
		_nCC   := AScan(_aCabec, "CENTRO DE CUSTO" )
		_nClvl := AScan(_aCabec, "CLASSE DE VALOR" )
		_nCL   := AScan(_aCabec, "CLASSE ORCAMENTO" )
		_nOP   := AScan(_aCabec, "OPERACAO" )
		_nIC   := AScan(_aCabec, "ITEM CONTABIL" )
		_aMeses := {"JAN", "FEV","MAR", "ABR", "MAI", "JUN", "JUL", "AGO", "SET", "OUT", "NOV", "DEZ"}

		dbSelectArea("AKE")
		AKE->(dbSetOrder(1)) // AKE_FILIAL+AKE_ORCAME+AKE_REVISA
		If !AKE->(dbSeek(xFilial("AKE") + _cAk1Cod + _cVersao) )
			RecLock("AKE" ,  .T. )
			AKE->AKE_FILIAL := xFilial("AKE")
			AKE->AKE_ORCAME := _cAk1Cod
			AKE->AKE_REVISA := _cVersao
			AKE->AKE_DATAI  := dDataBase
			AKE->AKE_HORAI  := Time()
			AKE->AKE_DATAF  := dDataBase
			AKE->AKE_USERI  := __cUserId
			AKE->AKE_HORAF  := Time()
			AKE->AKE_USERF  := __cUserId
			AKE->(MsUnlock())
		EndIf

		For _nLin := 1 to Len(_aDados)
            _aDados[_nLin, _nCO] := PadR(_aDados[_nLin, _nCO], TamSX3("AK2_CO")[1])
            _aDados[_nLin, _nCC] := PadR(_aDados[_nLin, _nCC], TamSX3("AK2_CC")[1])
            _aDados[_nLin, _nCL] := PadR(_aDados[_nLin, _nCL], TamSX3("AK2_CLASSE")[1])
            _aDados[_nLin, _nOP] := PadR(_aDados[_nLin, _nOP], TamSX3("AK2_OPER")[1])
			If _nClvl > 0
            	_aDados[_nLin, _nClvl] := PadR(_aDados[_nLin, _nClvl], TamSX3("AK2_CLVLR")[1])
			EndIf
           If _nIC > 0
            	_aDados[_nLin, _nIC] := PadR(_aDados[_nLin, _nIC], TamSX3("AK2_ITCTB")[1])
			EndIf 

            // AK3_FILIAL+AK3_ORCAME+AK3_VERSAO+AK3_CO
			If !AK3->( dbSeek(xFilial("AK3") + _cAk1Cod + _cVersao + _aDados[_nLin, _nCO] ) )
				If !AK5->(dbSeek(xFilial("AK5") + _aDados[_nLin, _nCO] ))
					AutoGrLog(ProcName() + " - " + cValToChar(ProcLine()) + " CO não encontrada - "  + _aDados[_nLin, _nCO] )
					DisarmTransaction()
					Exit
				EndIf
				RecLock("AK3" ,  .T. )
				AK3->AK3_FILIAL := xFilial("AK3")
				AK3->AK3_ORCAME := _cAk1Cod
				AK3->AK3_VERSAO := _cVersao
				AK3->AK3_CO     := _aDados[_nLin, _nCO]
				AK3->AK3_PAI    := _cAk1Cod
				AK3->AK3_TIPO   := AK5->AK5_TIPO
				AK3->AK3_NIVEL  := Iif(Empty(AK5->AK5_COSUP), "002" , "003" )
				AK3->AK3_DESCRI := AK5->AK5_DESCRI
				AK3->(MsUnlock())
			EndIf

            If AK2->(FieldPos("AK2_DESCRI")) > 0
                _cCTTDesc := Posicione("CTT", 1, xFilial("CTT")+_aDados[_nLin, _nCC], "CTT_DESC01")
            EndIf

			For _nx := 1 to Len(_aMeses)
				_cId := "0001"
				_nValor := Val(StrTran(_aDados[_nLin, aScan(_aCabec, _aMeses[_nx] ) ], ",", "."))
				dDataIni := CtoD("01/"+StrZero(_nx,2)+"/"+Alltrim(_cAno))

                _lAK2New := .T.
                _cSql := " SELECT MAX(AK2_ID) FROM "+RetSQLName('AK2')+" AK2  "+CRLF
                _cSql += " WHERE AK2.D_E_L_E_T_<>'*' AND AK2_FILIAL='"+xFilial("AK2")+"' "+CRLF
                _cSql += " AND AK2_ORCAME='"+_cAk1Cod+"' "+CRLF
                _cSql += " AND AK2_VERSAO='"+_cVersao+"' "+CRLF
                _cSql += " AND AK2_CO    ='"+_aDados[_nLin, _nCO]+"' "+CRLF
                _cSql += " AND AK2_PERIOD='"+DTOS(dDataIni)+"' "+CRLF
                _cVerMax := Fm_SQL(_cSql)
                
                _cSql += " AND AK2_CC    ='"+_aDados[_nLin, _nCC]+"' "+CRLF
                _cSql += " AND AK2_CLASSE='"+_aDados[_nLin, _nCL]+"' "+CRLF
                _cSql += " AND AK2_OPER  ='"+_aDados[_nLin, _nOP]+"' "+CRLF
				If _nClvl > 0
                	_cSql += " AND AK2_CLVLR  ='"+_aDados[_nLin, _nClvl]+"' "+CRLF
				EndIf
                _cVerAtu := Fm_SQL(_cSql)

                If !Empty(_cVerMax)
                    _cId := Soma1(_cVerMax)
                    _lAK2New := .T.
                EndIf

                If !Empty(_cVerAtu)
					
					// ignorar segunda ocorrência
					If _nDupl == 3
						Loop
					EndIf
                    _cId := _cVerAtu
                    _lAK2New := .F.
                EndIf

                //Alert(xFilial("AK2") + _cAk1Cod  +_cVersao + _aDados[_nLin, _nCO] + DTOS(dDataIni) + _cId)
                
                If !_lAK2New
				    // AK2_FILIAL+AK2_ORCAME+AK2_VERSAO+AK2_CO+DTOS(AK2_PERIOD)+AK2_ID
					AK2->(dbGoTop())
                    AK2->( dbSeek( xFilial("AK2") + _cAk1Cod  +_cVersao + _aDados[_nLin, _nCO] + DTOS(dDataIni) + _cId ) )
                EndIf

				RecLock("AK2",  _lAK2New )
				AK2->AK2_FILIAL := xFilial("AK2")
				AK2->AK2_ID     := _cId
				AK2->AK2_ORCAME := _cAk1Cod
				AK2->AK2_VERSAO := _cVersao
				AK2->AK2_CO     := _aDados[_nLin, _nCO]
				AK2->AK2_CC     := _aDados[_nLin, _nCC]
				AK2->AK2_CLASSE := _aDados[_nLin, _nCL]
				AK2->AK2_OPER   := _aDados[_nLin, _nOP]
				if _nClvl > 0
					AK2->AK2_CLVLR   := _aDados[_nLin, _nClvl]
				endif
				if _nIC > 0
					AK2->AK2_ITCTB   := _aDados[_nLin, _nIC]
				endif
                If AK2->(FieldPos("AK2_DESCRI")) > 0
                    AK2->AK2_DESCRI := _cCTTDesc
                EndIf
				AK2->AK2_PERIOD := dDataIni
				AK2->AK2_MOEDA  := 1
				AK2->AK2_DATAF  := LastDate(dDataIni)
				AK2->AK2_DATAI  := dDataIni

				If _nDupl == 1 // somar
					AK2->AK2_VALOR  += _nValor
				else // sobrescrever
					AK2->AK2_VALOR  := _nValor
				EndIf
				if !_lAK2New .AND. AK2->(FieldPos("AK2_USERGA")) > 0
					AK2->AK2_USERGA  := ""
				EndIf
				AK2->(MsUnlock())
			Next
		Next

	End Transaction

Return(_lRet)

/*/{Protheus.doc} fGerNewOrc
gera um novo orçamento
@author Caio.Lima
@since 05/09/2021
@type Function
/*/
Static Function fGerNewOrc(_aCabec, _aDados)
	Local _lRet := .T.

	aAutoCab := {{"AK1_CODIGO" , Alltrim(_cAk1Cod)            , NIL},;
		{"AK1_VERSAO" , _cVersao                     , NIL},;
		{"AK1_DESCRI" , "JAN A DEZ " + Alltrim(_cAno)      , NIL},;
		{"AK1_TPPERI" , "3"                          , NIL},;
		{"AK1_INIPER" , CTOD("01/01/" + Alltrim(_cAno))    , NIL},;
		{"AK1_FIMPER" , CTOD("31/12/" + Alltrim(_cAno))    , NIL},;
		{"AK1_CTRUSR" , "2"                          , NIL},;
		{"AK1_STATUS" , "1"                          , NIL}}

	lMsErroAuto := .F.
	MSExecAuto( {|x,y,z,a,b,c| PCOA100(x,y,z, a, b, c)}, 3/*nCallOpcx*/,/*cRevisa*/, /*lRev*/, /*lSim*/,aAutoCab, /*xAutoItens*/) //inclusão AK1

	If lMsErroAuto
		AutoGrLog(ProcName() + " - " + cValToChar(ProcLine()))
		MostraErro()
		_lRet := .F.
	Else

	EndIf

Return(_lRet)

/*/{Protheus.doc} fparam
Função para definir os parametros
@author  Caio Lima
@since   13/07/2021
@type Function
/*/
Static Function fparam()
	Local _aBox := {}
	Local _aRet := {}
	Local _lRet := .F.
	Local _nTAK1 := TamSX3("AK1_CODIGO")[1]

	_cAno := cValToChar(Year(dDataBase))

	aAdd( _aBox , {1,"Codigo do orçamento", PadR(_cAk1Cod, _nTAK1) , ,'.T.',"",'.T.', 60 ,.T. } )
	aAdd( _aBox , {1,"Ano" , PadR(_cAno, 4) , ,'.T.',,'.T.', 30 ,.T. } )
	aAdd( _aBox , {6,"Arquivo CSV (dados)", PadR(_cFile,100), "", "", "", 90, .T., "Arquivos .CSV |*.CSV", "",} )
	aAdd( _aBox , {2,"Operação", 1 , {"1=Complemento mesma versão","2=Nova versão"} , 100, , .T. } )
	aAdd( _aBox , {2,"Duplicidade", 1 , {"1=Somar com a existente","2=Sobrescrever","3=Ignorar segunda ocorrência"} , 100, , .T. } )

	_lRet := ParamBox(_aBox,"Parametros importação de orçamento", _aRet,,,,,,,"Z"+FunName(),.T.,.T.)
	If _lRet
		_cAk1Cod  := _aRet[1]
		_cAno     := _aRet[2]
		_cFile    := _aRet[3]

		_nOpc     := _aRet[4]
		If ValType(_nOpc) == "C"
			_nOpc := Val(Left(_nOpc,1))
		EndIf

		_nDupl     := _aRet[5]
		If ValType(_nDupl) == "C"
			_nDupl := Val(Left(_nDupl,1))
		EndIf
	EndIf

Return(_lRet)

/*/{Protheus.doc} fChgEmp
Funcao que altera filial logado em tempo de execução
@author caiocrol
@since 21/05/2015
@version 1.0
@type Function
/*/
Static Function fChgEmp(_cFil)

	Local _aArea := GetArea()

	dbSelectArea("SM0")
	SM0->(dbSetOrder(1))
	If SM0->(dbSeek( cEmpAnt + _cFil ))
		//cFilial := _cFil
		cFilAnt := _cFil
		cEmpresa := cEmpAnt + _cFil
		MsTcSetParam("FILIAL" , _cFil )
	EndIf

	RestArea(_aArea)

Return
