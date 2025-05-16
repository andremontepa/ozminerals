#INCLUDE "TOTVS.CH"
//#INCLUDE 'FWLIBVERSION.CH' 

/*/{Protheus.doc} OZACOTCACA
OZACOTCACA - Rotina de chamada de arquivo .csv e execução de rotina automatica para atualizar cotação 
@type class 
@author Andre Mendes - Crm Services
@since 28/08/2024
@version 12.1.2210
@obs LOCALIZAÇÃO : Function MT150ROT - Chamada da atualização de cotação
EM QUE PONTO : Ao acionar na opção outras ações
UTILIZAÇÃO : Atualizar cotação
@history 28/08/2024, André Mendes - Crm Services, Construção Inicial
/*/ 

User Function OZACOTCACA()
	Local aCotacao      := {}   as array

	U_ImportAltCot(aCotacao) //Chamada da rotina de importação de csv

	IF !Empty(aCotacao) 
		Processa( { || U_AltMata150(aCotacao) }, 'Alterando cotacao...', 'Aguarde...')  ///Chamada da rotina de execauto de alteração de cotação
	EndIF
Return

User Function ImportAltCot(aCotacao)

	IF MSGYESNO( "Deseja importar planilha", "Alterar Cotacao" ) ///Chamada da rotina de importação de excel
		ImporCotaExcel(aCotacao) ///Chamada da rotina de importação de excel	
	EndIF   
Return

Static Function ImporCotaExcel(aCotacao)
	Local aArea     := FWGetArea()
	Local cTipArq   := 'CSV ( Separado por virgula) (*.csv) | Arquivos Excel (*.xlsx) | Arquivos Excel 97-2003 (*.xls)  '   as character
	Local cTitulo   := 'Seleção de Arquivos para Processamento'                     as character
	Local cArqSel   := ''                                                           as character  

	Private cArqCSV := ""                                                           as character

	If ! IsBlind()
		cArqSel := tFileDialog(cTipArq,cTitulo,,,.F.,)

		If ! Empty(cArqSel) .And. File(cArqSel)
			Processa({|| fImportaCota(cArqSel,aCotacao) }, 'Importando...')
		EndIf
	EndIf
	FWRestArea(aArea)

Return(aCotacao)

/*/{Protheus.doc} fImporta
Função que processa o arquivo e realiza a importação para o sistema
@author Andre Mendes
@since 28/07/2024
@version 1.0
@type function
@obs Codigo gerado automaticamente pelo Autumn Code Maker
/*/

Static Function fImportaCota(cArqSel,aCotacao)
	//Local cNomeErro  := ''             as character
	//Local cTextoErro := ''             as character
	Local cLinAtu    := ''               as character
	Local nLinhaAtu  := 0                as numeric
	Local nTotLinhas := 0                as numeric
	Local aLinha     := {}               as array
	Local oArquivo                       as Object

	Private aDados         := {}         as array
	Private lMSHelpAuto    := .T.        as logical
	Private lAutoErrNoFile := .T.        as logical
	Private lMsErroAuto    := .F.        as logical
	Private cAliasImp  := 'SC8'          as character
	Private cSeparador := ';'            as character

	//Abre as tabelas que serão usadas
	DbSelectArea(cAliasImp)
	(cAliasImp)->(DbSetOrder(1))
	(cAliasImp)->(DbGoTop())

	//Definindo o arquivo a ser lido
	oArquivo := FWFileReader():New(cArqSel)

	//Se o arquivo pode ser aberto
	If (oArquivo:Open())

		//Se não for fim do arquivo
		If ! (oArquivo:EoF())

			//Definindo o tamanho da régua
			aLinhas := oArquivo:GetAllLines()
			nTotLinhas := Len(aLinhas)
			ProcRegua(nTotLinhas)

			//Método GoTop não funciona (dependendo da versão da LIB), deve fechar e abrir novamente o arquivo
			oArquivo:Close()
			oArquivo := FWFileReader():New(cArqSel)
			oArquivo:Open()

			//Iniciando controle de transação
			Begin Transaction
				//Enquanto tiver linhas
				While (oArquivo:HasLine())
					//Incrementa na tela a mensagem
					nLinhaAtu++

					IncProc('Analisando linha ' + cValToChar(nLinhaAtu) + ' de ' + cValToChar(nTotLinhas) + '...')

					//Pegando a linha atual e transformando em array
					cLinAtu := oArquivo:GetLine()
					aLinha  := Separa(cLinAtu, cSeparador)

					//Se houver posições no array
					If Len(aLinha) > 0.AND. !aLinha[1] = "C8_NUM"
						aadd(aCotacao,aLinha)
					EndIf

				EndDo
			End Transaction
			//Se tiver log, mostra ele			
		Else
			MsgStop('Arquivo não tem conteúdo!', 'Atenção')
		EndIf
		//Fecha o arquivo
		oArquivo:Close()
	Else
		MsgStop('Arquivo não pode ser aberto!', 'Atenção')
	EndIf

Return (aCotacao)

User Function AltMata150(aCotacao)

	Local aCabec        := {}              as Array
	Local aItens        := {}              as Array
	Local lret			:=.F.			   as logical
	Local cNumCotacao   := ""              as Character  // C8_NUM
	Local cNumProposta  := ""              as Character  // C8_NUMPRO	
	Local cNumFornece   := ""              as Character  // C8_FORNECE	
	Local cLojaFornece  := ""              as Character  // C8_LOJA	
	Local cItem         := ""              as Character  // C8_ITEM	
	Local cProduto      := ""              as Character  // C8_PRODUTO
	Local cCondPag      := ""              as Character  // C8_COND	
	Local cTipoFret     := ""              as Character  // C8_TPFRETE
	Local cUnidadeM		:= ""		       as Character  // C8_UM
	Local nNumSC		:= ""			   as Character  // C8_NUMSC
	Local cIdent		:= ""			   as Character	 // C8_IDENT
	Local nPreco        := 0               as Numeric    // C8_PRECO
	Local nAliqIPI      := 0               as Numeric    // C8_ALIQIPI	
	Local nValFrete     := 0               as Numeric    // C8_VALFRE
	Local nValDespesa   := 0               as Numeric    // C8_DESPESA	
	Local nValDescont   := 0               as Numeric    // C8_DESC
	Local nValTotal     := 0               as Numeric    // C8_TOTAL
	Local nQuant		:= 0			   as Numeric    // C8_QUANT
	Local cFilImp		:= ""			   as Character  // C8_FILIAL - Lucas Raminelli 31/03/2025 - add Filial
	Local nX            := 0               as Numeric    
	Local cLog          := ""			   as Character  //Lucas Raminelli - 31/03/2025 - Log de termino 
	Local cError        := ""			   as Character  //Lucas Raminelli - 31/03/2025 - Log de termino 

	Private lMsErroAuto := .F.  

	For nX:=1 to Len(aCotacao)

		cNumCotacao	  := StrZero(val(aCotacao[nx][1]),6)
		cNumProposta  := StrZero(val(aCotacao[nx][5]),2)	
		cNumFornece   := StrZero(val(aCotacao[nx][2]),6)	
		cLojaFornece  := StrZero(val(aCotacao[nx][3]),2)	
		cItem         := StrZero(val(aCotacao[nx][4]),4)	
		cProduto      := StrZero(val(aCotacao[nx][6]),6)
		cCondPag      := StrZero(val(aCotacao[nx][8]),3)	
		cFilImp 	  := StrZero(val(aCotacao[nx][14]),2)
		cTipoFret     := aCotacao[nx][11]	

		nPreco        := Val(StrTran(aCotacao[nx][7],",","."))
		nAliqIPI      := Val(StrTran(aCotacao[nx][9],",","."))
		nValFrete     := Val(StrTran(aCotacao[nx][10],",","."))
		nValDespesa   := Val(StrTran(aCotacao[nx][12],",","."))
		nValDescont   := Val(StrTran(aCotacao[nx][13],",","."))
		aCabec:={}
		aItens:={}

		dbSelectArea("SB1")   
		dbSetOrder(1)
		dbSeek(xFilial("SB1")+ cProduto) 
		
		cUnidadeM:= SB1->B1_UM //Busca Unidade de Medida do Produto

		dbSelectArea("SC8")   
		dbSetOrder(1) 
		IF dbSeek(cFilImp + cNumCotacao + cNumFornece + cLojaFornece + cItem)  //Filial+Orçamento+Fornecedor+Loja+Item

			nValTotal	:= SC8->C8_QUANT*nPreco
			nQuant		:= SC8->C8_QUANT
			nNumSC		:= SC8->C8_NUMSC
			cIdent		:= SC8->C8_IDENT

			IF cNumCotacao == SC8->C8_NUM .AND. SC8->C8_NUMPRO == cNumProposta .AND. SC8->C8_ITEM == cItem .AND. ALLTRIM(SC8->C8_PRODUTO) == cProduto

				//Lucas Raminelli - 02/04/2025 - retirado ExecAuto pois o mesmo não atualiza
				IF Reclock("SC8",.F.)
				   SC8->C8_FORNECE 	:= cNumFornece
				   SC8->C8_LOJA 	:= cLojaFornece
				   SC8->C8_COND		:= cCondPag
				   SC8->C8_TPFRETE  := cTipoFret
				   SC8->C8_DESPESA	:= nValDespesa
				   SC8->C8_NUMPRO	:= cNumProposta
				   SC8->C8_PRODUTO	:= cProduto
				   SC8->C8_ITEM		:= cItem
				   SC8->C8_NUMSC	:= nNumSC
				   SC8->C8_IDENT	:= cIdent
				   SC8->C8_UM		:= cUnidadeM
				   SC8->C8_QUANT	:= nQuant
				   SC8->C8_PRECO	:= nPreco
				   SC8->C8_TOTAL	:= nValTotal
				   SC8->C8_DESC		:= nValDescont
				   SC8->C8_VALFRE	:= nValFrete
				   SC8->C8_ALIIPI	:= nAliqIPI
				   SC8->(MsUnlock())				
				
				   cLog += "Cotação: " + cNumCotacao + "- NumeroItem: " + cItem + " atualizada com sucesso"  + CRLF
				   ConOut("Cotação: " + cNumCotacao + "- NumeroItem: " + cItem + " atualizada com sucesso")
				Else
				   cLog += "Cotação: " + cNumCotacao + "- NumeroItem: " + cItem + " Erro na atualização"  + CRLF
				   ConOut("Erro na Atualização: " + cError)
				EndIf
				
			EndIf			
		Else	
			cLog += "Cotação: " + cNumCotacao + "- NumeroItem: " + cItem + " não localizado"  + CRLF
			Conout(" Registro não localizado : "+ cFilImp + cNumCotacao + cNumFornece + cLojaFornece + cItem)
		EndIf
	Next

	ShowLog(cLog)
	ConOut("Fim: " + Time())
	lRet:= .T.

Return Nil
