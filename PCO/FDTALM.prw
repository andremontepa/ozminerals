//Bibliotecas
#Include "Totvs.ch"
#INCLUDE "protheus.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch" 

/*/{Protheus.doc} FDTALM
Importar a Tabela ALM
@author Flavio Oliveira Dias
@since 21/12/2022
@version 1.0
@type function
/*/

User Function FDTALM()
	Local aArea := FWGetArea()
	Local cDirIni := GetTempPath()
	Local cTipArq := 'Arquivos com separações (*.csv) | Arquivos texto (*.txt) | Todas extensões (*.*)'
	Local cTitulo := 'Seleção de Arquivos para Processamento'
	Local lSalvar := .F.
	Local cArqSel := ''
 
	//Se não estiver sendo executado via job
	If ! IsBlind()
 
	    //Chama a função para buscar arquivos
	    cArqSel := tFileDialog(;
	        cTipArq,;  // Filtragem de tipos de arquivos que serão selecionados
	        cTitulo,;  // Título da Janela para seleção dos arquivos
	        ,;         // Compatibilidade
	        cDirIni,;  // Diretório inicial da busca de arquivos
	        lSalvar,;  // Se for .T., será uma Save Dialog, senão será Open Dialog
	        ;          // Se não passar parâmetro, irá pegar apenas 1 arquivo; Se for informado GETF_MULTISELECT será possível pegar mais de 1 arquivo; Se for informado GETF_RETDIRECTORY será possível selecionar o diretório
	    )

	    //Se tiver o arquivo selecionado e ele existir
	    If ! Empty(cArqSel) .And. File(cArqSel)
	        Processa({|| fImporta(cArqSel) }, 'Importando...')
	    EndIf
	EndIf
	
	FWRestArea(aArea)
Return
	
/*/{Protheus.doc} fImporta
Função que processa o arquivo e realiza a importação para o sistema
@author Flavio Oliveira Dias
@since 21/12/2022
@version 1.0
@type function
/*/

Static Function fImporta(cArqSel)
	Local cDirTmp    := GetTempPath()
	Local cArqLog    := 'importacao_' + dToS(Date()) + '_' + StrTran(Time(), ':', '-') + '.log'
	Local nTotLinhas := 0
	Local cLinAtu    := ''
	Local nLinhaAtu  := 0
	Local aLinha     := {}
	Local oArquivo
	Local cPastaErro := '\x_logs\'
	Local cNomeErro  := ''
	Local cTextoErro := ''
	Local aLogErro   := {}
	Local nLinhaErro := 0
	Local cLog       := ''
	Local lIgnor01   := FWAlertYesNo('Deseja ignorar a linha 1 do arquivo?', 'Ignorar?')
	//Variáveis do ExecAuto
	Private aDados         := {}
	Private lMSHelpAuto    := .T.
	Private lAutoErrNoFile := .T.
	Private lMsErroAuto    := .F.
	//Variáveis da Importação
	Private cAliasImp  := 'ALM'
	Private cSeparador := ';'

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

					//Se estiver configurado para pular a linha 1, e for a linha 1
					If lIgnor01 .And. nLinhaAtu == 1
						Loop

					//Se houver posições no array
					ElseIf Len(aLinha) > 0
						cLog += '+ Processando a linha ' + cValToChar(nLinhaAtu) + ';' + CRLF
						RecLock(cAliasImp, .T.)
							ALM_FILIAL := aLinha[1]
							ALM_COD := aLinha[2]
							ALM_DESC := aLinha[3]
							ALM_ITEM := aLinha[4]
							ALM_USER := aLinha[5]
							ALM_NOME := aLinha[6]
							ALM_NIVEL := aLinha[7]
							ALM_TPLIB := aLinha[8]
						(cAliasImp)->(MsUnlock())

					EndIf

				EndDo
			End Transaction

			//Se tiver log, mostra ele
			If ! Empty(cLog)
				MemoWrite(cDirTmp + cArqLog, cLog)
				ShellExecute('OPEN', cArqLog, '', cDirTmp, 1)
			EndIf

		Else
			MsgStop('Arquivo não tem conteúdo!', 'Atenção')
		EndIf

		//Fecha o arquivo
		oArquivo:Close()
	Else
		MsgStop('Arquivo não pode ser aberto!', 'Atenção')
	EndIf

Return
