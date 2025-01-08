#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "fileio.ch"

/*/{Protheus.doc} APIUtil
Fonte contendo todas os metodos e classes genericos.
@type class 
@author Ricardo Tavares Ferreira
@since 27/03/2021
@version 12.1.27
@history 27/03/2021, Ricardo Tavares Ferreira, Construção Inicial
@history 31/03/2021, Ricardo Tavares Ferreira, Inclusão do Metodo de Carregamento de Empresas.
@history 15/04/2021, Ricardo Tavares Ferreira, Inclusão do Metodo responsavel por gravar os dados de Data e Hora.
@history 15/04/2021, Ricardo Tavares Ferreira, Inclusão da Metodo que verifica se o campo é virtual.
@history 29/05/2021, Ricardo Tavares Ferreira, Inclusão do Metodo que salva dos dados do frete no pedido de compras.
/*/
//=============================================================================================================================
    Class APIUtil from LongNameClass
//=============================================================================================================================

	Static Method GetCpoZR1(aPedidos)
	Static Method GrvSC7(nOpcao,cNumPC,nOpcA)
	Static Method ExisteCampo(cAlias,lVirtual)
	Static Method GravaDataHora(cTabela,aDados)
	Static Method CarregaEmpresas()
    Static Method PolyString(cString,lSemSpace,cTipoCpo) 
    Static Method CriaDirArquivo(cPath,cNomeArq,cString)
    Static Method ConsoleLog(cRotina,cMensagem,nTipo)
    Static Method ConsoleLogCustom(cRotina,cMensagem,cTipo)
    Static Method ConsoleLogPadrao(cRotina,cMensagem,cTipo,nModelo)
    Static Method GravaDadosZR4(cTab,aDados)  
    Static Method CarregaParametros(cGrupo,cOrdem,cPergunt,cPerSpa,cPerEng,cVar,cTipo,nTamanho,nDecimal,nPresel,cGSC,cValid,cF3, cGrpSxg,cPyme,cVar01,cDef01,cDefSpa1,cDefEng1,cCnt01,cDef02,cDefSpa2,cDefEng2,cDef03,cDefSpa3,cDefEng3,cDef04,cDefSpa4,cDefEng4,cDef05,cDefSpa5,cDefEng5,aHelpPor,aHelpEng,aHelpSpa,cHelp)
EndClass

/*/{Protheus.doc} GetCpoZR1
Metodo responsável por buscar os campos de Update na ZR1 e montar a instrução de UPDATE no SET.
@type Method
@author Ricardo Tavares Ferreira
@since 30/05/2021
@param aPedidos, array, Array contendo os dados da isntrução SQL.
@param cTabAtu, character, Alias da Tabela a ser retornada o indice
@history 30/05/2021, Ricardo Tavares Ferreira , Construção Inicial.
@return character, Retorna a instrução que será executada via Update
/*/
//===============================================================================================================
    Method GetCpoZR1(aPedidos,cTabAtu,cNumPC) class APIUtil
//===============================================================================================================

	Local cInstr  	:= ""
	Local nX      	:= 0
	Local nY 	  	:= 0
	Local cCpoZR1 	:= ""
	Local cIndex	:= ""
	Local cFiltro	:= ""
	Local aInstr	:= {}
	Local aFiltro	:= {}

    DbSelectArea(cTabAtu)
    cIndex := &(cTabAtu)->(IndexKey(1))

	DbSelectArea("ZR1")
	ZR1->(DbSetOrder(2))

	If ZR1->(DbSeek(FWXFilial("ZR1")+"SC7"+"001"))
		cCpoZR1 := Alltrim(ZR1->ZR1_CPOALT)
		For nX := 1 To Len(aPedidos)
			For nY := 1 To Len(aPedidos[nX])
				If Alltrim(aPedidos[nX][nY][1]) $ cCpoZR1
					If TamSx3(Alltrim(aPedidos[nX][nY][1]))[3] == "N"
						cInstr += aPedidos[nX][nY][1] + " = " + cValToChar(aPedidos[nX][nY][2]) +", " 
					Else 
						cInstr += aPedidos[nX][nY][1] + " = '" + aPedidos[nX][nY][2] + "', "
					EndIf
				EndIf 

				If Alltrim(aPedidos[nX][nY][1]) $ cIndex
					If TamSx3(Alltrim(aPedidos[nX][nY][1]))[3] == "N"
						cFiltro += aPedidos[nX][nY][1] + " = " + cValToChar(aPedidos[nX][nY][2]) +" AND " 
					Else 
						If aPedidos[nX][nY][1] == "C7_NUM"
							If Empty(cNumPC)
								cFiltro += aPedidos[nX][nY][1] + " = 'NUMPED' AND "
							Else 
								cFiltro += aPedidos[nX][nY][1] + " = '" + cNumPC + "' AND "
							EndIf 
						Else
							cFiltro += aPedidos[nX][nY][1] + " = '" + aPedidos[nX][nY][2] + "' AND "
						EndIf 
					EndIf
				EndIf 
			Next nY
			If Right(Alltrim(cInstr),1) == ","
				cInstr := SubStr(Alltrim(cInstr),1,Len(Alltrim(cInstr))-1)
			EndIf

			If Right(Alltrim(cFiltro),3) == "AND"
				cFiltro := SubStr(Alltrim(cFiltro),1,Len(Alltrim(cFiltro))-3)
			EndIf

			aadd(aInstr,cInstr)
			aadd(aFiltro,cFiltro)
			cInstr := ""
			cFiltro := ""
		Next nX
	EndIf
Return {aInstr,aFiltro}

/*/{Protheus.doc} GrvSC7
Metodo responsável por gravar os dados de campos na configuração da API no pedido de compras.
@type Method
@author Ricardo Tavares Ferreira
@since 29/05/2021
@param nOpcao, character, Tipo de operação executada.
@param cNumPC, character, numero do pedido de compras
@param nOpcA, numeric, verifica se o usuario confirmou ou cancelou a operação
@obs Metodo executado no ponto de entrada MT120FIM.
@history 29/05/2021, Ricardo Tavares Ferreira , Construção Inicial.
/*/
//===============================================================================================================
    Method GrvSC7(nOpcao,cNumPC,nOpcA) class APIUtil
//===============================================================================================================

	Local oQuery    := Nil
    Local cCodQry 	:= "003"
	Local aArea		:= GetArea()
	Local lAprSist	:= SuperGetMV("AP_APRSIS",.F.,.F.) 
	Local cInst		:= ""
	Local nX 		:= 0

	If nOpcao == 3 .or. nOpcao == 4
		If nOpcA == 1
			If Len(__aExcSet__) > 0
				For nX := 1 To Len(__aExcSet__)
					cInst := __aExcSet__[nX] + Iif(lAprSist,", C7_CONAPRO = 'B'","")
					cFilt := StrTran(__aExcFil__[nX],"NUMPED",cNumPC)
					
					oQuery := APIExQry():New()
					oQuery:SetFormula(cCodQry)
					oQuery:AddFilter("TAB1", RetSqlName("SC7"))
					oQuery:AddFilter("EXEC1", cInst)
					oQuery:AddFilter("FILTRO", cFilt)

					If .not. oQuery:ExecTCSQL()
						APIUtil():ConsoleLog("APIUtil|GrvSC7","Falha ao Executar o UPDATE na tabela SC7.",3)
					Else 
						APIUtil():ConsoleLog("APIUtil|GrvSC7","Dados da tabela SC7 alterados com sucesso para o pedido "+cNumPC+" Item: "+Strzero(nX,TamSx3("C7_ITEM")[1])+".",1)
					EndIf

					FWFreeObj(oQuery)
				Next nX
			Else 
				If lAprSist
					oQuery := APIExQry():New()
					oQuery:SetFormula(cCodQry)
					oQuery:AddFilter("TAB1", RetSqlName("SC7"))
					oQuery:AddFilter("EXEC1", "C7_CONAPRO = 'B'")
					oQuery:AddFilter("FILTRO", "C7_FILIAL = '"+FWXFilial("SC7")+"' AND C7_NUM = '"+cNumPC+"'")

					If .not. oQuery:ExecTCSQL()
						APIUtil():ConsoleLog("APIUtil|GrvSC7","Falha ao Executar o UPDATE na tabela SC7.",3)
					Else 
						APIUtil():ConsoleLog("APIUtil|GrvSC7","Dados da tabela SC7 alterados com sucesso para o pedido "+cNumPC,1)
					EndIf

					FWFreeObj(oQuery)
				EndIf
			EndIf 
		EndIf 
	EndIf	 
	RestArea(aArea)
Return 

/*/{Protheus.doc} GravaDataHora
Metodo responsável por gravar a data e hora de registros alterados ou incluidos.
@type Method
@author Ricardo Tavares Ferreira
@since 15/04/2021
@param cTab, character, Alias da Tabela que será utilizado para gravar os Dados de Data e Hora.
@param aDados, array, Dados que serão usados na Gravação.
@param aCampos, array, Array contendo os 2 campos que seram usados na gravação da data e hora.
@obs O Array enviado tem que ser somente de uma posição Ex... aDados[1], aDados[2]....
@history 15/04/2021, Ricardo Tavares Ferreira , Construção Inicial.
/*/
//===============================================================================================================
    Method GravaDataHora(cTab,aDados,aCampos) class APIUtil
//===============================================================================================================

	Local lIntegraBaseB	:= SuperGetMV("AP_INTBSB",.F.,.F.)
	Local nX 			:= 0
	Local xDate			:= Date()
	Local xHora			:= StrTran(Time(),":","")

	Default cTab 	:= ""
	Default aDados 	:= {}

	If lIntegraBaseB
		If .not. Empty(cTab) .and. Len(aDados) > 0 .and. Len(aCampos) > 0
			If APIUtil():ExisteCampo(cTab,aCampos[1],.F.)
				If APIUtil():ExisteCampo(cTab,aCampos[2],.F.)
					DbSelectArea(cTab)
					For nX := 1 To Len(aDados)
						&(cTab)->(DbGoto(aDados[nX]))
						RecLock(cTab,.F.)
							&(cTab+"->"+Alltrim(aCampos[1])) := xDate
							&(cTab+"->"+Alltrim(aCampos[2])) := xHora
						&(cTab)->(MsUnlock())
						APIUtil():ConsoleLog("APIUtil|GravaDataHora","ID "+cValToChar(aDados[nX])+" da tabela "+Alltrim(cTab)+", Gravado com Sucesso...",1)
					Next nX 
				Else
					APIUtil():ConsoleLog("APIUtil|GravaDataHora","O Campo "+Alltrim(aCampos[2])+" não existe cadastrado na base de dados, como a integração com o sistema Base-B  está ativo é necessário criar o campo mencionado, não é possivel prosseguir com a gravação dos dados.",4)
				EndIf 
			Else 
				APIUtil():ConsoleLog("APIUtil|GravaDataHora","O Campo "+Alltrim(aCampos[1])+" não existe cadastrado na base de dados, como a integração com o sistema Base-B  está ativo é necessário criar o campo mencionado, não é possivel prosseguir com a gravação dos dados.",4)
			EndIf 
		Else 
			APIUtil():ConsoleLog("APIUtil|GravaDataHora","Código da Tabela, Array de dados ou Array de campos vazio, não é possivel prosseguir com a gravação dos dados.",4)
		EndIf
	Else 
		APIUtil():ConsoleLog("APIUtil|GravaDataHora","Integração com o Sistema Base-B não Ativa, para usar a integração ative o Parametro AP_INTBSB.",2)
	EndIf
Return 

/*/{Protheus.doc} ExisteCampo
Metodo responsável por verificar se o campo existe e se é virtual na base de dados
@type Method
@author Ricardo Tavares Ferreira
@since 15/04/2021
@return logical, Valida se o campo existe na Base de Dados.
@param cAlias, character, Alias da Tabela a ser Pesquisada.
@param cCampo, character, Campo a ser pesquisado.
@param lVirtual, logical, Define se o Campo é Virtual.
@history 15/04/2021, Ricardo Tavares Ferreira , Construção Inicial.
/*/
//===============================================================================================================
    Method ExisteCampo(cAlias,cCampo,lVirtual) class APIUtil
//===============================================================================================================

	Local aCampos 	:= {}
	Local nX 		:= 0
	Local lExiste 	:= .F.

	aCampos := FWSX3Util():GetAllFields(cAlias,lVirtual) 

	For nX := 1 To Len(aCampos)
		If Alltrim(Upper(cCampo)) == Alltrim(Upper(aCampos[nX]))
			lExiste := .T.
			Exit
		EndIf
	Next nX 
Return lExiste

/*/{Protheus.doc} CarregaEmpresas
Metodo responsável carregar e retornar um array contendo as empresas ativas no sistema.
@type Method
@author Ricardo Tavares Ferreira
@since 31/03/2021
@return array, Array contendo todas as empresas ativas do sistema.
@history 31/03/2021, Ricardo Tavares Ferreira , Construção Inicial.
/*/
//===============================================================================================================
    Method CarregaEmpresas() class APIUtil
//===============================================================================================================

	Local aArea			:= SM0->(GetArea())
	Local aAux			:= {}
	Local aRetSM0		:= {}
	Local lFWLoadSM0	:= FindFunction("FWLoadSM0")
	Local lFWCodFilSM0 	:= FindFunction("FWCodFil")
	Local nX			:= 0
	
	If lFWLoadSM0
		aRetSM0	:= FWLoadSM0()
		For nX := 1 To Len(aRetSM0) 
			aAdd(aAux,aRetSM0[nX])
		Next nX
		aRetSM0 := aClone(aAux)
	Else
		DbSelectArea("SM0")
		SM0->(DbGoTop())
		While SM0->(!Eof())
			aAux := {SM0->M0_CODIGO,;
					 IIf(lFWCodFilSM0,FWGETCODFILIAL,SM0->M0_CODFIL),;
					 "",;
					 "",;
					 "",;
					 SM0->M0_NOME,;
					 SM0->M0_FILIAL}
			aAdd(aRetSM0,aClone(aAux))
			SM0->(DbSkip())
		End
	EndIf
	RestArea(aArea)
Return aRetSM0

/*/{Protheus.doc} PolyString
Metodo responsável por retirar do conteudo passado como parametro os caracteres especiais.
@type Method
@author Ricardo Tavares Ferreira
@since 28/03/2021
@param cTipoCpo, character, Tipo do campo.
@param lSemSpace, logical, controla o retorno do conteudo sem espaço.
@param cString, character, String que sera salvo no arquivo.
@history 28/03/2021, Ricardo Tavares Ferreira , Construção Inicial.
/*/
//===============================================================================================================
    Method PolyString(cString,lSemSpace,cTipoCpo) class APIUtil
//===============================================================================================================

    Local lRetCharEsp   := SuperGetMV("AP_CHARESP",.F.,.F.)

    Default lSemSpace   := .F.
    Default cTipoCpo    := "C"

    If lSemSpace
        cString := StrTran(cString ," ","")
    EndIF

	If cTipoCpo == "N"
		cString := StrTran(cString ,",",".")
		Return cString
	EndIf

    If lRetCharEsp
        cString := StrTran(cString,"Ç","C")
        cString := StrTran(cString,"ç","ç")	
        cString := StrTran(cString,"@","")
        cString := StrTran(cString,"\","")
        cString := StrTran(cString,'/','')
        cString := StrTran(cString,'-','')
        cString := StrTran(cString,"°","")
        cString := StrTran(cString,">","")
        cString := StrTran(cString,"<","")
        cString := StrTran(cString,"#","")
        cString := StrTran(cString,"%","")
        cString := StrTran(cString,"$","")
        cString := StrTran(cString,"(","")
        cString := StrTran(cString,")","")
        cString := StrTran(cString,"!","")
        cString := StrTran(cString,"=","")
        cString := StrTran(cString,"+","")
        cString := StrTran(cString,"{","")
        cString := StrTran(cString,"}","")
        cString := StrTran(cString,"[","")
        cString := StrTran(cString,"]","")
        cString := StrTran(cString,"?","")
        cString := StrTran(cString,"|","")
		cString := FwNoAccent(AllTrim(cString))
    EndIf

    cString := StrTran(cString,"ï","")
	cString := StrTran(cString,"»","")
	cString := StrTran(cString,"¿","")
	cString := StrTran(cString,"'","")
	cString := StrTran(cString,"*","")
	cString := StrTran(cString,"&","E")
	cString := StrTran(cString,'"',"")
	cString := StrTran(cString,"ª","")
	cString := StrTran(cString,"Ã","")
	cString := StrTran(cString,"£","") 
	cString := StrTran(cString,""," ")
Return cString

/*/{Protheus.doc} CriaDirArquivo
Metodo Responsavel por criar um diretorio e gravar uma string passada como paramtro em um arquivo no diretorio criado.
@type Method
@author Ricardo Tavares Ferreira
@since 28/03/2021
@return logical, Informa se a contabilização do reembolso foi executada corretamente.
@param cPath, character, Caminho do arquivo.
@param cNomeArq, character, Nome do Arquivo e extensão que será salvo.
@param cString, character, String que sera salvo no arquivo.
@history 28/03/2021, Ricardo Tavares Ferreira , Construção Inicial.
@history 07/04/2021, Ricardo Tavares Ferreira, Solução para gravar arquivos, como o processo é feito via JOB o arquivo é gravado somente no servidor "Protheus_Data".
/*/
//=============================================================================================================================
	Method CriaDirArquivo(cPath,cNomeArq,cString) class APIUtil
//=============================================================================================================================

    Local IsDir 		:= .F.
    Local nDir      	:= 0
	Local lSucesso		:= .T.

	Default cPath 		:= "\sql_api"
	Default cNomeArq 	:= "Sql_Generico.txt"
	Default cString		:= ""

	IsDir := ExistDir(cPath,Nil,.T.)

    If IsDir
        MemoWrite(cPath+"\"+cNomeArq,cString)
    Else 
        nDir := MakeDir(cPath,Nil,.F.)

        If nDir # 0
            cMensagem := "Falha ao Criar a pasta onde será salvo as consultas executadas pelo sistema."+cValToChar(FError())
			APIUtil():ConsoleLog("APIUtil|CriaDirArquivo",cMensagem,3)
            lSucesso := .F.
		Else 
            IsDir := ExistDir(cPath,Nil,.F.)

            If IsDir
                MemoWrite(cPath+"\"+cNomeArq,cString)
            Else 
				lSucesso := .F.
			EndIf
        EndIf
    EndIf
Return lSucesso

/*/{Protheus.doc} ConsoleLog
Metodo centralizador que irá gravar o log do sistema sendo via console.log padrao ou console salvo em maquina local.
@type Method 
@author Ricardo Tavares Ferreira
@since 27/03/2021
@version 12.1.27
@param cRotina, character, Nome da função que esta utilizando o console.
@param cMensagem, character, Mensagem que será exibida no console.log
@param nTipo, numeric, ID do Tipo do log a ser exibido.
@obs Para o parametro nTipo os valores são:
1 = INFO
2 = WARN
3 = ERROR
4 = FATAL
5 = DEBUG
@history 27/03/2021, Ricardo Tavares Ferreira, Construção Inicial
/*/
//=============================================================================================================================
    Method ConsoleLog(cRotina,cMensagem,nTipo) Class APIUtil
//=============================================================================================================================

    Local nModLog       := SuperGetMV("AP_GRVLOG",.F.,1)
    Local cTipo         := ""

    Default cRotina     := "XXXXXX"
    Default cMensagem   := "Mensagem nao passada como parametro."
    Default nTipo       := 5

    If nTipo == 1
        cTipo := "INFO"
    ElseIf nTipo == 2
        cTipo := "WARN"
    ElseIf nTipo == 3
        cTipo := "ERROR"
    ElseIf nTipo == 4
        cTipo := "FATAL"
    ElseIf nTipo == 5
        cTipo := "DEBUG"
    EndIf

    If nModLog == 1
        APIUtil():ConsoleLogPadrao(cRotina,FwNoAccent(cMensagem),cTipo)
    ElseIf nModLog == 2
        APIUtil():ConsoleLogCustom(cRotina,cMensagem,cTipo)
    EndIf
Return

/*/{Protheus.doc} ConsoleLogCustom
Metodo responsavel por gravar o log no arquivo console.log customizado em uma pasta definido em parametro.
@type Method 
@author Ricardo Tavares Ferreira
@since 27/03/2021
@version 12.1.27
@param cRotina, character, Nome da função que esta utilizando o console.
@param cMensagem, character, Mensagem que será exibida no console.log
@param cTipo, character, Tipo do log a ser exibido.
@history 27/03/2021, Ricardo Tavares Ferreira, Construção Inicial.
@history 10/04/2021, Ricardo Tavares Ferreira, Implementação da gravação de log customizado.
/*/
//=============================================================================================================================
    Method ConsoleLogCustom(cRotina,cMensagem,cTipo) Class APIUtil
//=============================================================================================================================

	Local cPath 	:= SuperGetMV("AP_DIRGLOG",.F.,"\log_api\")
	Local cNomeArq	:= "api_protheus.log"
	Local cMsgFim	:= ""
	Local IsDir		:= .F.
	Local nDir     	:= 0
	Local cComplMsg	:= ""
	Local QbLinha	:= chr(13)+chr(10)
	Local nHdl		:= 0

	Private nStart      := 0

	If Right(cPath,1) == "\"
        cPath := Substr(cPath,1,Len(cPath)-1)
    EndIf

	IsDir := ExistDir(cPath,Nil,.T.)

    If .not. IsDir
		nDir := MakeDir(cPath,Nil,.F.)

        If nDir # 0
            cMensagem := "Falha ao Criar a pasta onde será salvo as consultas executadas pelo sistema."+cValToChar(FError())
			cComplMsg := " [" + Dtoc(Date()) +" "+ Time()+ "] ...: "+cMensagem
			FwLogMsg("APIUtil", /*cTransactionId*/, "APIUtil", FunName(), "","["+cTipo+"] ["+cRotina+"]" +cComplMsg, 0, (nStart - Seconds()), {})
			Return
		Else 
            IsDir := ExistDir(cPath,Nil,.F.)
            If .not. IsDir
				cMensagem := "Falha ao Criar o diretorio, o arquivo nao será salvo."
				cComplMsg := " [" + Dtoc(Date()) +" "+ Time()+ "] ...: "+cMensagem
				FwLogMsg("APIUtil", /*cTransactionId*/, "APIUtil", FunName(), "","["+cTipo+"] ["+cRotina+"]" +cComplMsg, 0, (nStart - Seconds()), {})
				Return
			EndIf
        EndIf
    EndIf 

	nHdl := FOpen(cPath+"\"+cNomeArq,FO_READWRITE)

	If nHdl > 0 
		cComplMsg := " [" + Dtoc(Date()) +" "+ Time()+ "] ...: Arquivo aberto."
		FwLogMsg("APIUtil", /*cTransactionId*/, "APIUtil", FunName(), "","["+cTipo+"] ["+cRotina+"]" +cComplMsg, 0, (nStart - Seconds()), {})
	Else 
		nHdl := FCreate(cPath+"\"+cNomeArq,0)
	EndIf
	
	If nHdl > 0 
    	FSeek(nHdl,0,2)
		cComplMsg := " [" + Dtoc(Date()) +" "+ Time()+ "] ...: "+Alltrim(cMensagem)
		cMsgFim   := "["+cTipo+"] ["+cRotina+"]" +cComplMsg + QbLinha
		Fwrite(nHdl,cMsgFim,Len(cMsgFim))
		FClose(nHdl)
	EndIf
Return

/*/{Protheus.doc} ConsoleLogPadrao
Metodo responsavel por gravar o log no arquivo console.log padrão do sistema.
@type Method 
@author Ricardo Tavares Ferreira
@since 27/03/2021
@version 12.1.27
@param cRotina, character, Nome da função que esta utilizando o console.
@param cMensagem, character, Mensagem que será exibida no console.log
@param cTipo, character, Tipo do log a ser exibido.
@history 27/03/2021, Ricardo Tavares Ferreira, Construção Inicial
/*/
//=============================================================================================================================
    Method ConsoleLogPadrao(cRotina,cMensagem,cTipo) Class APIUtil
//=============================================================================================================================

    //Local nModelo       := SuperGetMV("AP_MODLOGP",.F.,1)
    Local cComplMsg     := ""

    cComplMsg := " [" + Dtoc(Date()) +" "+ Time()+ "] ...: "+Alltrim(cMensagem)

    //If nModelo == 1
    //    Conout("["+cTipo+"] ["+cRotina+"]" +cComplMsg)
    //Else 
	    FWLogMsg(cTipo,/*cTransactionId*/,cRotina,/*cCategory*/,/*cStep*/,/*cMsgId*/,cComplMsg,/*nMensure*/,/*nElapseTime*/,/*aMessage*/)
    //EndIf 
Return

/*/{Protheus.doc} GravaDadosZR4
Fonte contendo todas os metodos e classes genericos.
@type Method 
@author Ricardo Tavares Ferreira
@since 27/03/2021
@version 12.1.27
@param cTab, character, Código da tabela que esta sendo excluido o registro e que está sendo salvo na tabela ZR4.
@param aDados, array, Array Contendo os Dados que irão ser salvos na tabela ZR4.
@history 27/03/2021, Ricardo Tavares Ferreira, Construção Inicial.
@history 15/04/2021, Ricardo Tavares Ferreira, Inclusão do Parametro que valida se a Integração com o Base-B está Ativa.
/*/
//=============================================================================================================================
   Method GravaDadosZR4(cTab,aDados,lRegDel) Class APIUtil
//=============================================================================================================================

    Local cMensagem 	:= ""
    Local oGravaZR4 	:= Nil
	Local lIntegraBaseB	:= SuperGetMV("AP_INTBSB",.F.,.F.)

	If lIntegraBaseB
		If Empty(cTab) .or. Len(aDados) <= 0
			cMensagem := "Dados da exclusao nao gravados pois informacoes necessarias nao foram enviados como parametro."
			APIUtil():ConsoleLog("APIUtil|GravaDadosZR4",cMensagem,3)
		Else
			cMensagem := "Inicio do Processo de Gravacao"
			APIUtil():ConsoleLog("APIUtil|GravaDadosZR4",cMensagem,1)

			oGravaZR4 := APIGrvZR4():New(cTab,lRegDel)
			If oGravaZR4:ExcutaGravacao(aDados)
				cMensagem := "Registros gravados com sucesso."
				APIUtil():ConsoleLog("APIUtil|GravaDadosZR4",cMensagem,1)
			Else
				cMensagem := "Falha ao gravar os dados na tabela ZR4."
				APIUtil():ConsoleLog("APIUtil|GravaDadosZR4",cMensagem,3)
			EndIf

			cMensagem := "Fim do Processo de Gravacao"
			APIUtil():ConsoleLog("APIUtil|GravaDadosZR4",cMensagem,1)
		EndIf
	Else 
		APIUtil():ConsoleLog("APIUtil|GravaDadosZR4","Integração com o Sistema Base-B não Ativa, para usar a integração ative o Parametro AP_INTBSB.",2)
	EndIf
    FWFreeObj(oGravaZR4)
Return Nil

/*/{Protheus.doc} CarregaParametros
Cria os Parametros na tabela SX1.
@type function 
@author Ricardo Tavares Ferreira
@since 28/03/2021
@history 28/03/2021, Ricardo Tavares Ferreira, Construção Inicial.
@version 12.1.27
/*/
//=============================================================================================================================
//    Method CarregaParametros(cGrupo,cOrdem,cPergunt,cPerSpa,cPerEng,cVar,cTipo,nTamanho,nDecimal,nPresel,cGSC,cValid,cF3, cGrpSxg,cPyme,cVar01,cDef01,cDefSpa1,cDefEng1,cCnt01,cDef02,cDefSpa2,cDefEng2,cDef03,cDefSpa3,cDefEng3,cDef04,cDefSpa4,cDefEng4,cDef05,cDefSpa5,cDefEng5,aHelpPor,aHelpEng,aHelpSpa,cHelp) Class APIUtil
//=============================================================================================================================
/*
    Local aArea := GetArea() 
	Local cKey 
	Local lPort := .f. 
	Local lSpa := .f. 
	Local lIngl := .f. 

	cKey := "P." + AllTrim( cGrupo ) + AllTrim( cOrdem ) + "." 

	cPyme       := Iif( cPyme   == Nil , "" , cPyme   ) 
	cF3         := Iif( cF3     == NIl , "" , cF3     ) 
	cGrpSxg     := Iif( cGrpSxg == Nil , "" , cGrpSxg ) 
	cCnt01      := Iif( cCnt01  == Nil , "" , cCnt01  ) 
	cHelp       := Iif( cHelp   == Nil , "" , cHelp   ) 

	dbSelectArea( "SX1" ) 
	dbSetOrder( 1 ) 

	cGrupo := PadR( cGrupo , Len( SX1->X1_GRUPO ) , " " ) 

	If !( DbSeek( cGrupo + cOrdem )) 

		cPergunt   := If(! "?" $ cPergunt .And. ! Empty(cPergunt),Alltrim(cPergunt)+" ?",cPergunt) 
		cPerSpa    := If(! "?" $ cPerSpa .And. ! Empty(cPerSpa) ,Alltrim(cPerSpa) +" ?",cPerSpa) 
		cPerEng    := If(! "?" $ cPerEng .And. ! Empty(cPerEng) ,Alltrim(cPerEng) +" ?",cPerEng) 

		Reclock( "SX1" , .T. ) 

		Replace X1_GRUPO   With cGrupo 
		Replace X1_ORDEM   With cOrdem 
		Replace X1_PERGUNT With cPergunt 
		Replace X1_PERSPA With cPerSpa 
		Replace X1_PERENG With cPerEng 
		Replace X1_VARIAVL With cVar 
		Replace X1_TIPO    With cTipo 
		Replace X1_TAMANHO With nTamanho 
		Replace X1_DECIMAL With nDecimal 
		Replace X1_PRESEL With nPresel 
		Replace X1_GSC     With cGSC 
		Replace X1_VALID   With cValid 

		Replace X1_VAR01   With cVar01 

		Replace X1_F3      With cF3 
		Replace X1_GRPSXG With cGrpSxg 

		If Fieldpos("X1_PYME") > 0 
			If cPyme != Nil 
				Replace X1_PYME With cPyme 
			Endif 
		Endif 

		Replace X1_CNT01   With cCnt01 
		If cGSC == "C"               // Mult Escolha 
			Replace X1_DEF01   With cDef01 
			Replace X1_DEFSPA1 With cDefSpa1 
			Replace X1_DEFENG1 With cDefEng1 

			Replace X1_DEF02   With cDef02 
			Replace X1_DEFSPA2 With cDefSpa2 
			Replace X1_DEFENG2 With cDefEng2 

			Replace X1_DEF03   With cDef03 
			Replace X1_DEFSPA3 With cDefSpa3 
			Replace X1_DEFENG3 With cDefEng3 

			Replace X1_DEF04   With cDef04 
			Replace X1_DEFSPA4 With cDefSpa4 
			Replace X1_DEFENG4 With cDefEng4 

			Replace X1_DEF05   With cDef05 
			Replace X1_DEFSPA5 With cDefSpa5 
			Replace X1_DEFENG5 With cDefEng5 
		Endif 

		Replace X1_HELP With cHelp 

		xSX1Help(cKey,aHelpPor,aHelpEng,aHelpSpa, .T. , "") 

		MsUnlock() 
	Else 

		lPort := ! "?" $ X1_PERGUNT .And. ! Empty(SX1->X1_PERGUNT) 
		lSpa := ! "?" $ X1_PERSPA .And. ! Empty(SX1->X1_PERSPA) 
		lIngl := ! "?" $ X1_PERENG .And. ! Empty(SX1->X1_PERENG) 

		If lPort .Or. lSpa .Or. lIngl 
			RecLock("SX1",.F.) 
			If lPort 
				SX1->X1_PERGUNT:= Alltrim(SX1->X1_PERGUNT)+" ?" 
			EndIf 
			If lSpa 
				SX1->X1_PERSPA := Alltrim(SX1->X1_PERSPA) +" ?" 
			EndIf 
			If lIngl 
				SX1->X1_PERENG := Alltrim(SX1->X1_PERENG) +" ?" 
			EndIf 
			SX1->(MsUnLock()) 
		EndIf 
	Endif 
	RestArea( aArea ) 
Return	*/

/*/{Protheus.doc} xSX1Help
Gravação de help de campos.
@type function 
@author Ricardo Tavares Ferreira
@since 28/03/2021
@param cKey, character, Codigo da chave SX1.
@param aHelpPor, array, Array Contendo o Help em Portugues.
@param aHelpEng, array, Array Contendo o Help em Ingles.
@param aHelpSpa, array, Array Contendo o Help em Espanhol.
@param lUpdate, logical, Verifica se o processo do help será de inclusão ou Alteração.
@param cStatus, character, Status do Grupo de Help Cadastrado.
@history 28/03/2021, Ricardo Tavares Ferreira, Construção Inicial.
@version 12.1.27
/*/
//=============================================================================================================================
//    Static Function xSX1Help(cKey,aHelpPor,aHelpEng,aHelpSpa,lUpdate,cStatus)
//=============================================================================================================================
/*
	Local cFilePor := "SIGAHLP.HLP"
	Local cFileEng := "SIGAHLE.HLE"
	Local cFileSpa := "SIGAHLS.HLS"
	Local nRet
	Local nT
	Local nI
	Local cLast
	Local cNewMemo
	Local cAlterPath := ''
	Local nPos	

	If ( ExistBlock('HLPALTERPATH') )
		cAlterPath := Upper(AllTrim(ExecBlock('HLPALTERPATH', .F., .F.)))
		If ( ValType(cAlterPath) != 'C' )
			cAlterPath := ''
		ElseIf ( (nPos:=Rat('\', cAlterPath)) == 1 )
			cAlterPath += '\'
		ElseIf ( nPos == 0	)
			cAlterPath := '\' + cAlterPath + '\'
		EndIf

		cFilePor := cAlterPath + cFilePor
		cFileEng := cAlterPath + cFileEng
		cFileSpa := cAlterPath + cFileSpa

	EndIf

	Default aHelpPor := {}
	Default aHelpEng := {}
	Default aHelpSpa := {}
	Default lUpdate  := .T.
	Default cStatus  := ""

	If Empty(cKey)
		Return
	EndIf

	If !(cStatus $ "USER|MODIFIED|TEMPLATE")
		cStatus := NIL
	EndIf

	cLast 	 := ""
	cNewMemo := ""

	nT := Len(aHelpPor)

	For nI:= 1 to nT
		cLast := Padr(aHelpPor[nI],40)
		If nI == nT
			cLast := RTrim(cLast)
		EndIf
		cNewMemo+= cLast
	Next

	If !Empty(cNewMemo)
		nRet := SPF_SEEK( cFilePor, cKey, 1 )
		If nRet < 0
			SPF_INSERT( cFilePor, cKey, cStatus,, cNewMemo )
		Else
			If lUpdate
				SPF_UPDATE( cFilePor, nRet, cKey, cStatus,, cNewMemo )
			EndIf
		EndIf
	EndIf

	cLast 	 := ""
	cNewMemo := ""

	nT := Len(aHelpEng)

	For nI:= 1 to nT
		cLast := Padr(aHelpEng[nI],40)
		If nI == nT
			cLast := RTrim(cLast)
		EndIf
		cNewMemo+= cLast
	Next

	If !Empty(cNewMemo)
		nRet := SPF_SEEK( cFileEng, cKey, 1 )
		If nRet < 0
			SPF_INSERT( cFileEng, cKey, cStatus,, cNewMemo )
		Else
			If lUpdate
				SPF_UPDATE( cFileEng, nRet, cKey, cStatus,, cNewMemo )
			EndIf
		EndIf
	EndIf

	cLast 	 := ""
	cNewMemo := ""

	nT := Len(aHelpSpa)

	For nI:= 1 to nT
		cLast := Padr(aHelpSpa[nI],40)
		If nI == nT
			cLast := RTrim(cLast)
		EndIf
		cNewMemo+= cLast
	Next

	If !Empty(cNewMemo)
		nRet := SPF_SEEK( cFileSpa, cKey, 1 )
		If nRet < 0
			SPF_INSERT( cFileSpa, cKey, cStatus,, cNewMemo )
		Else
			If lUpdate
				SPF_UPDATE( cFileSpa, nRet, cKey, cStatus,, cNewMemo )
			EndIf
		EndIf
	EndIf
Return*/
