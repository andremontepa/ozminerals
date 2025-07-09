#INCLUDE "TOTVS.CH"
//#INCLUDE 'FWLIBVERSION.CH'

/*/{Protheus.doc} OZACOTCACA
OZACOTCACA - Rotina de chamada de arquivo .csv e execução de rotina automatica para atualizar cotação
@type class
@author Andre Mendes - Crm Services
@since 28/08/2024
@version 12.1.2210
@obs LOCALIZAÃ‡ÃƒO : Function MT150ROT - Chamada da atualização de cotação
EM QUE PONTO : Ao acionar na opção outras ações
UTILIZAÇÃO : Atualizar cotação
@history 28/08/2024, Andre Mendes - Crm Services, Cosntrução Inicial
@history 25/06/2025, Bill Medeiros - Crm Services, Substituição de Reclock() por Execauto (MATA150)
@see https://tdn.totvs.com/pages/releaseview.action?pageId=545250210
/*/

User Function OZACOTCACA()
	Private aCotacao := {}

	U_ImportAltCot() //Chamada da rotina de importação de csv

	IF !Empty(aCotacao)
		Processa( { || U_AltMata150() }, 'Alterando cotacao...', 'Aguarde...')  ///Chamada da rotina de execauto de alteração de cotação
	EndIF
Return

User Function ImportAltCot()
	IF FWAlertYesNo( "Deseja importar planilha", "Alterar Cotacao" ) ///Chamada da rotina de importação de excel
		ImporCotaExcel() ///Chamada da rotina de importação de excel
	EndIF
Return

Static Function ImporCotaExcel()
	Local aArea     := FWGetArea()
	Local cTipArq   := "CSV ( Separado por virgula) (*.csv) | Arquivos Excel (*.xlsx) | Arquivos Excel 97-2003 (*.xls)"
	Local cTitulo   := "Selecao de Arquivos para Processamento"
	Local cArqSel   := ""

	If !IsBlind()
		cArqSel := tFileDialog(cTipArq,cTitulo,,,.F.,)

		If !Empty(cArqSel) .And. File(cArqSel)
			Processa({|| fImportaCota(cArqSel) }, 'Importando...')
		EndIf
	EndIf

	FWRestArea(aArea)
Return

Static Function fImportaCota(cArqSel)
	Local cLinAtu    := ""
	Local nLinhaAtu  := 0
	Local nTotLinhas := 0
	Local aLinha     := {}
	Local oArquivo

	//Definindo o arquivo a ser lido
	oArquivo := FWFileReader():New(cArqSel)

	If oArquivo:Open()
		If !(oArquivo:EoF())
			aLinhas 	:= oArquivo:GetAllLines()
			nTotLinhas 	:= Len(aLinhas)

			ProcRegua(nTotLinhas)

			//Metodo GoTop não funciona (dependendo da versão da LIB), deve fechar e abrir novamente o arquivo
			oArquivo:Close()

			oArquivo := FWFileReader():New(cArqSel)

			oArquivo:Open()

			//Iniciando controle de transaÃ§Ã£o
			Begin Transaction
				While oArquivo:HasLine()
					nLinhaAtu++

					IncProc('Analisando linha ' + cValToChar(nLinhaAtu) + ' de ' + cValToChar(nTotLinhas) + '...')

					//Pegando a linha atual e transformando em array
					cLinAtu := oArquivo:GetLine()
					aLinha  := Separa(cLinAtu, ";")

					//Se houver posições no array
					If Len(aLinha) > 0 .and. aLinha[1] <> "C8_NUM"
						aadd(aCotacao,aLinha)
					EndIf
				EndDo
			End Transaction
		Else
			MsgStop('Arquivo não tem conteúdo!', 'Atenção')
		EndIf

		oArquivo:Close()
	Else
		MsgStop('Arquivo não pode ser aberto!', 'Atenção')
	EndIf
Return

User Function AltMata150()
	Local aCabec        	:= {}
	Local aItens        	:= {}
	Local aLogAuto      	:= {}
	Local cNumCotacao   	:= ""
	Local cNumProposta  	:= ""
	Local cNumFornece   	:= ""
	Local cLojaFornece  	:= ""
	Local cItem         	:= ""
	Local cProduto      	:= ""
	Local cCondPag      	:= ""
	Local cTipoFret     	:= ""
	Local cUnidadeM			:= ""
	Local nNumSC			:= ""
	Local cIdent			:= ""
	Local cLog          	:= ""
	Local cFilImp			:= ""
	Local cLogTxt       	:= ""
	Local nPreco        	:= 0
	Local nAliqIPI      	:= 0
	Local nValFrete     	:= 0
	Local nValDespesa   	:= 0
	Local nValDescont   	:= 0
	Local nValTotal     	:= 0
	Local nQuant			:= 0
	Local nX            	:= 0
	Local nAux          	:= 0

	Private lMSHelpAuto    	:= .T.
	Private lAutoErrNoFile 	:= .T.
	Private lMsErroAuto    	:= .F.

	dbSelectArea("SB1")
	SB1->(dbSetOrder(1))

	dbSelectArea("SC8")
	SC8->(dbSetOrder(1))  //Filial + Orcamento + Fornecedor + Loja + Item

	For nX := 1 to Len(aCotacao)
		cNumCotacao	  := StrZero(val(aCotacao[nx][1]),6)
		cNumFornece   := StrZero(val(aCotacao[nx][2]),6)
		cLojaFornece  := StrZero(val(aCotacao[nx][3]),2)
		cItem         := StrZero(val(aCotacao[nx][4]),4)
		cNumProposta  := StrZero(val(aCotacao[nx][5]),2)
		cProduto      := StrZero(val(aCotacao[nx][6]),6)
		nPreco        := Val(StrTran(aCotacao[nx][7],",","."))
		cCondPag      := StrZero(val(aCotacao[nx][8]),3)
		nAliqIPI      := Val(StrTran(aCotacao[nx][9],",","."))
		nValFrete     := Val(StrTran(aCotacao[nx][10],",","."))
		cTipoFret     := aCotacao[nx][11]
		nValDespesa   := Val(StrTran(aCotacao[nx][12],",","."))
		nValDescont   := Val(StrTran(aCotacao[nx][13],",","."))
		cFilImp 	  := StrZero(val(aCotacao[nx][14]),2)
		aCabec		  := {}
		aItens		  := {}

		SB1->(DbGoTop())

		If SB1->(dbSeek(FWxFilial("SB1") + cProduto,.F.))
			cUnidadeM := SB1->B1_UM //Busca Unidade de Medida do Produto

			SC8->(DbGoTop())

			IF SC8->(dbSeek(cFilImp + cNumCotacao + cNumFornece + cLojaFornece + cItem,.F.))
				nValTotal	:= SC8->C8_QUANT * nPreco
				nQuant		:= SC8->C8_QUANT
				nNumSC		:= SC8->C8_NUMSC
				cIdent		:= SC8->C8_IDENT

				IF SC8->C8_NUM == cNumCotacao .and. SC8->C8_NUMPRO == cNumProposta .and. SC8->C8_ITEM == cItem .and. Alltrim(SC8->C8_PRODUTO) == cProduto
					aCabec := {}
					aItens := {}

					aadd(aCabec,{"C8_FORNECE" 	,cNumFornece})
					aadd(aCabec,{"C8_LOJA" 		,cLojaFornece})
					aadd(aCabec,{"C8_COND" 		,cCondPag})
					aadd(aCabec,{"C8_CONTATO" 	,SC8->C8_CONTATO})
					aadd(aCabec,{"C8_FILENT" 	,SC8->C8_FILENT})
					aadd(aCabec,{"C8_MOEDA" 	,SC8->C8_MOEDA})
					aadd(aCabec,{"C8_EMISSAO" 	,SC8->C8_EMISSAO})
					aadd(aCabec,{"C8_TOTFRE" 	,0})
					aadd(aCabec,{"C8_VALDESC" 	,0})
					aadd(aCabec,{"C8_DESPESA" 	,0})
					aadd(aCabec,{"C8_SEGURO" 	,0})
					aadd(aCabec,{"C8_DESC1" 	,0})
					aadd(aCabec,{"C8_DESC2" 	,0})
					aadd(aCabec,{"C8_DESC3" 	,0})

					aadd(aItens,{;
						{"C8_NUMPRO" 	,cNumProposta 	,NIL},;
						{"C8_PRODUTO" 	,cProduto 		,NIL},;
						{"C8_ITEM" 		,cItem			,NIL},;
						{"C8_NUMSC" 	,nNumSC			,NIL},;
						{"C8_IDENT" 	,cIdent			,NIL},;
						{"C8_UM" 		,cUnidadeM		,NIL},;
						{"C8_QUANT" 	,nQuant			,NIL},;
						{"C8_PRECO" 	,nPreco 		,NIL},;
						{"C8_TOTAL" 	,nValTotal		,NIL},;
						{"C8_DESC" 		,nValDescont	,NIL},;
						{"C8_VALFRE" 	,nValFrete		,NIL},;
						{"C8_ALIIPI" 	,nAliqIPI		,NIL}})

					Begin Transaction
						lMsErroAuto := .F.

						MSExecAuto({|v,x,y| MATA150(v,x,y)},FWVetByDic(aCabec,"SC8",.F.),FWVetByDic(aItens,"SC8",.T.),3)

						If lMsErroAuto
							aLogAuto := GetAutoGRLog()
							cLogTxt  := ""

							For nAux := 1 To Len(aLogAuto)
								cLogTxt += aLogAuto[nAux] + CRLF
							Next nAux

							cLog += "Cotacao: " + cNumCotacao + "- NumeroItem: " + cItem + " Erro na atualizacao: " +  cLogTxt + CRLF
						Else
							cLog += "Cotacao: " + cNumCotacao + "- NumeroItem: " + cItem + " atualizada com sucesso"  + CRLF
						EndIf
					End Transaction
				EndIf
			Else
				cLog += "Cotacao: " + cNumCotacao + "- NumeroItem: " + cItem + " nao localizado"  + CRLF
			EndIf
		EndIf
	Next

	ShowLog(cLog)
Return
