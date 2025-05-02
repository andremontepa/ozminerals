#include "protheus.ch"
#include "Totvs.ch"
#include "Tbiconn.ch"
#include "ozminerals.ch"

#define STATUS_NAO_ENVIADO      	"0"
#define STATUS_PROCESSANDO  		"1"
#define STATUS_FINALIZADO      		"2"
#define STATUS_PENDENCIA            "3"

#define RASTRO      				"L"
#define ENDERECO   			        "S"
#define LOCALIZACAO			        "N"
#define ORIGEM_PRODUTO				"0" 
#define CONTROLE_WMS				"2" 
#define IMPOSTO_CSLL  				"2" 
#define CUSTO_MOEDA 				"1"
#define TIPO_CQ    				    "M"

#define TIPO_PR0   					"PR0"
#define TIPO_PR1   					"PR1"

#define TIPO_PA						"PA"
#define TIPO_PI						"PI"

#define INCLUI_EST  				 3 

#define REGISTRO_ATUALIZADO         "Registro Atualizado"
#define REGISTRO_NAO_ATUALIZADO     "Registro Não Atualizado"

#define MOEDA_01    				"01"
#define MOEDA_02    				"02"
#define MOEDA_03   					"03"
#define MOEDA_04    				"04"
#define MOEDA_05    				"05"

#define GRAVA_FLAG  				"1"

#define OP_MANUTENCAO				"OS"
  
#define STATUS_RECORD    		     1
#define STATUS_NO_RECORD 		     2

/*/{Protheus.doc} OZ04M15

	Rotina para incluir saldos iniciais para o custo caixa e depeciação 

@type Function
@author Fabio Santos - CRM Service
@since 03/12/2023
@version P12
@database MSSQL

@Obs 
	Parametro : OZ_DELIMIT contem o delimitar utilizado no layout.
				Como default esta preenchido com ponto e virgula (;) 

	Parametro : OZ_LIBSB9 Habilita o uso da Rotina por segurança Ozminerals 
				Recomenda-se, após o uso deabilitar o uso da Rotina	

	Exemplo de Layout utilizado em Excel: 

	FILIAL;PRODUTO;LOCAL;QUANTIDADE;VLR UNIT. MOEDA 1;VLT TOTAL MOEDA 1;VLR CAIXA MOEDA 1;VLR DEPREIA€ÇO MOEDA 1;VLR UNIT MOEDA 2;VLR TOTAL MOEDA 2;VLR CAIXA MOEDA 2;VLR DEPREIA€ÇO MOEDA 2
	B9_FILIAL;B9_COD;B9_LOCAL;B9_QINI;B9_CM1;B9_VINI1;B9_CP0101;B9_CP0201;B9_CM2;B9_VINI2;B9_CP0102;B9_CP0202
	06;131440;10;100,00;20,0000;2000,00;1000,00;1000,00;10,0000;1000,00;500,00;500,00
	02;131440;10;100,00;20,0000;2000,00;1000,00;1000,00;10,0000;1000,00;500,00;500,00

	Ponto de Atenção :

	O arquivo em Excel, deve ser transformado em formato CSV com o DELIMITADOR (;)
	A Rotina despreza o cabeçalho com 1 linha que pode ser ajustado, caso seja necessario
	Deve executado a rotina REFAZ saldo após executar esta rotina

@see OZGEN18

@nested-tags:Frameworks/OZminerals
/*/
User Function OZ04M15()
	Local aSays        		 := {}  as array
	Local aButtons     		 := {}  as array
	Local nOpca        		 := 0   as numeric
	Local cTitoDlg     		 := ""  as character

	Private cSeparador       := ""  as character
	Private cDataFechamento  := ""  as character
	Private cSintaxeRotina   := ""  as character
	Private cDtUltFechamento := ""  as character
	Private lPodeExecutar    := .F. as Logical

	lPodeExecutar            := GetNewPar("OZ_LIBSB9",.T.)
	cDataFechamento          := GetNewPar("MV_ULMES","20230930")
	cSeparador               := AllTrim(GetNewPar("OZ_DELIMIT",";"))
	cDtUltFechamento         := Substr(Dtos(cDataFechamento),7,2)
	cDtUltFechamento         += "/" + Substr(Dtos(cDataFechamento),5,2)
	cDtUltFechamento         += "/" + Substr(Dtos(cDataFechamento),1,4)
	cSintaxeRotina           := ProcName(0)
	cTitoDlg    	         := "Manutenção Saldo Inicial - OzMinerals"

	aAdd(aSays, "Esta rotina tem por objetivo gerar saldo inicial custo caixa e depreciação")
	aAdd(aSays, "Esta rotina somente importa arquivo em formato  ( .txt ou .csv ) !")
	aAdd(aSays, "O delimitador utlizado é (" + cSeparador + ") com o parametro OZ_LIBSB9 Habilitado!")
	aAdd(aSays, "Deve ser Executado a Rotina Refaz Saldo Após Executar Esta Rotina!")
	aAdd(aSays, "Após o Uso, Deve Ser Desabilitado o uso da Rotina pelo parametro OZ_LIBSB9!")

	aAdd(aButtons,{STATUS_RECORD   , .T., {|o| nOpca := STATUS_RECORD   , FechaBatch()}})
	aAdd(aButtons,{STATUS_NO_RECORD, .T., {|o| nOpca := STATUS_NO_RECORD, FechaBatch()}})

	FormBatch(cTitoDlg, aSays, aButtons)

	If ( nOpca == STATUS_RECORD )
		If lPodeExecutar 
			ManutencaoEstoqueInicial()
		Else 
			FWAlertWarning("Atenção! Rotina Bloqueada para Uso, Solicitar Liberação Para TI, ATraves Do Parametro OZ_LIBSB9!")
		EndIf 
	EndIf

Return

/*
    Função que chama a static function de importação para o sistema
*/
Static Function ManutencaoEstoqueInicial()
	Local aArea             := {}  as array
	Local lSalvar           := .F. as logical
	Local cDirInicial       := ""  as character
	Local cTipoArquivo      := ""  as character
	Local cTitulo           := ""  as character
	Local cArqSelecionado   := ""  as character

	aArea                   := FWGetArea()
	cDirInicial             := GetTempPath()
	cTipoArquivo            := "Arquivos com separações (*.csv) | Arquivos texto (*.txt) "
	cTipoArquivo            += "| Todas extensões (*.*)"
	cTitulo                 := "Seleção de Arquivos para Processamento"

	If ( !IsBlind() )

		cArqSelecionado := tFileDialog(;
			cTipoArquivo,;
			cTitulo,;
			,;
			cDirInicial,;
			lSalvar,;
			;
			)

		If ( !Empty(cArqSelecionado) .And. File(cArqSelecionado) )
			Processa({|| ImportaArquivo(cArqSelecionado) }, 'Importando...')
		EndIf
	EndIf

	FWRestArea(aArea)
Return

/*
    Função que processa o arquivo e realiza a importação para o sistema
*/
Static Function ImportaArquivo(cArqSelecionado)
	Local oArquivo          := nil as Object
	Local oExcel            := nil as Object
	Local aLinha            := {}  as array
	Local aLinhas           := {}  as array
	Local nTotalLinhas      := 0   as numeric
	Local nLinhaAtual       := 0   as numeric
	Local nQuantidade       := 0   as integer 
	Local nCustoUnitario    := 0   as integer 
	Local nMA2CstoUnitario  := 0   as integer 
	Local nTotalCusto       := 0   as integer 
	Local nMB2TotalCusto    := 0   as integer  
	Local nCxaVlrCaixa      := 0   as integer  
	Local nMC2VlrCaixa      := 0   as integer 
	Local nDprVlrDeprec     := 0   as integer  
	Local nMD2VlrDeprec     := 0   as integer  
	Local lAbre             := .F. as logical
	Local lGravaTabela      := .T. as logical
	Local cDiretorioTmp     := ""  as character
	Local cArquivoLog       := ""  as character
	Local cLinhaAtual       := ""  as character
	Local cCodigoProduto    := ""  as character
	Local cDescricaoProduto := ""  as character
	Local cTipoProduto      := ""  as character
	Local cUnidadeMedida    := ""  as character
	Local cLog              := ""  as character
	Local cArquivoDestino   := ""  as character
	Local cNomePlanilha     := ""  as character
	Local cTituloPlanilha   := ""  as character
	Local cNomeWork         := ""  as character
	Local cStatus           := ""  as character
	Local cDataEmissao      := ""  as character

	cDiretorioTmp           := GetTempPath()
	cArquivoLog             := "importacao_" + dToS(Date())
	cArquivoLog             += "_" + StrTran(Time(), ":", "-") + ".log"
	cPastaErro              := "\CRM\"
	cArquivoDestino         := "C:\TOTVS\OZ04M15_EMP_" + SM0->M0_CODIGO
	cArquivoDestino         += "_" + Dtos(dDataBase) + StrTran(Time(),":","") + ".XML"
	cNomePlanilha           := "Empresa_" + Rtrim(SM0->M0_NOME)
	cNomeWork               := "Empresa_" + Rtrim(SM0->M0_NOME)
	cTituloPlanilha         := "OzMInerals - Manutenção Saldo Inicial"
	cDataEmissao	        := Substr(Dtos(ddatabase),7,2)
	cDataEmissao	  	    += "/" + Substr(Dtos(ddatabase),5,2)
	cDataEmissao   		    += "/" + Substr(Dtos(ddatabase),1,4)
	oExcel                  := FWMsExcelEX():New()

	oExcel:AddworkSheet(cNomeWork)
	oExcel:AddTable(cNomePlanilha , cTituloPlanilha)
	oExcel:AddColumn(cNomePlanilha, cTituloPlanilha, "Status Atualizacao"           , 1, 1, .F.)
	oExcel:AddColumn(cNomePlanilha, cTituloPlanilha, "Filial"                       , 1, 1, .F.)
	oExcel:AddColumn(cNomePlanilha, cTituloPlanilha, "Data Registro"                , 1, 1, .F.)
	oExcel:AddColumn(cNomePlanilha, cTituloPlanilha, "Codigo Produto"               , 1, 1, .F.)
	oExcel:AddColumn(cNomePlanilha, cTituloPlanilha, "Descrição Produto"            , 1, 1, .F.)
	oExcel:AddColumn(cNomePlanilha, cTituloPlanilha, "Tipo Produto"                 , 1, 1, .F.)
	oExcel:AddColumn(cNomePlanilha, cTituloPlanilha, "Unidade medida"               , 1, 1, .F.)
	oExcel:AddColumn(cNomePlanilha, cTituloPlanilha, "Armazen"                      , 1, 1, .F.)
	oExcel:AddColumn(cNomePlanilha, cTituloPlanilha, "Quantidade"                   , 1, 2, .F.)
	oExcel:AddColumn(cNomePlanilha, cTituloPlanilha, "Custo Unitario"               , 1, 2, .F.)
	oExcel:AddColumn(cNomePlanilha, cTituloPlanilha, "Custo Total"                  , 1, 2, .F.)
	oExcel:AddColumn(cNomePlanilha, cTituloPlanilha, "Custo Caixa"                  , 1, 2, .F.)
	oExcel:AddColumn(cNomePlanilha, cTituloPlanilha, "Custo Depreciação"            , 1, 2, .F.)

	oArquivo := FWFileReader():New(cArqSelecionado)

	If (oArquivo:Open())

		If ( !(oArquivo:EoF()) )

			aLinhas      := oArquivo:GetAllLines()
			nTotalLinhas := Len(aLinhas)
			ProcRegua(nTotalLinhas)

			oArquivo:Close()
			oArquivo := FWFileReader():New(cArqSelecionado)
			oArquivo:Open()

			While (oArquivo:HasLine())

				nLinhaAtual++
				IncProc("Analisando linha " + cValToChar(nLinhaAtual) + " de " + cValToChar(nTotalLinhas) + "...")

				cLinhaAtual := oArquivo:GetLine()
				aLinha      := Separa(cLinhaAtual, cSeparador)

				If ( Len(aLinha) > 0 .And. nLinhaAtual >= 2 )

					lGravaTabela      := .F.
					cFilialProduto    := aLinha[01]
					cCodigoProduto    := aLinha[02]
					cLocalEstoque     := aLinha[03]
					nQuantidade       := Val(StrTran(StrTran(aLinha[04],";",""),",", "."))
					nCustoUnitario    := Val(StrTran(StrTran(aLinha[05],";",""),",", "."))
					nTotalCusto       := Val(StrTran(StrTran(aLinha[06],";",""),",", "."))
					nCxaVlrCaixa      := Val(StrTran(StrTran(aLinha[07],";",""),",", "."))
					nDprVlrDeprec     := Val(StrTran(StrTran(aLinha[08],";",""),",", "."))
					nMA2CstoUnitario  := Val(StrTran(StrTran(aLinha[09],";",""),",", "."))
					nMB2TotalCusto    := Val(StrTran(StrTran(aLinha[10],";",""),",", "."))
					nMC2VlrCaixa      := Val(StrTran(StrTran(aLinha[11],";",""),",", "."))
					nMD2VlrDeprec     := Val(StrTran(StrTran(aLinha[12],";",""),",", "."))

					If ( AllTrim(Posicione("SB1",1,xFilial("SB1")+cCodigoProduto,"B1_COD")) == AllTrim(cCodigoProduto) )
						lGravaTabela   := .T.
					Else
						lGravaTabela   := .F.
						cStatus        := "Codigo de Produto Não Localizado"
					EndIf

					If ( lGravaTabela )
						If ( AllTrim(Posicione("NNR",1,xFilial("NNR")+cLocalEstoque,"NNR_CODIGO")) == AllTrim(cLocalEstoque) )
							lGravaTabela   := .T.
						Else
							lGravaTabela   := .F.
							cStatus        := "Armazen Não Localizado"
						EndIf
					EndIf

					If ( lGravaTabela )

						dbSelectArea("SB1")
						SB1->(dbSetOrder(1))
						If ( SB1->(dbSeek(xFilial("SB1") + PAD(cCodigoProduto,TAMSX3("B1_COD")[1]) )) )

							cDescricaoProduto := AllTrim(B1_DESC)
							cTipoProduto      := AllTrim(B1_TIPO)
							cUnidadeMedida    := AllTrim(B1_UM)
							
							DbSelectArea("SB9")
							SB9->(dbSetOrder(1)) 
							If ( SB9->(dbSeek(PAD(cFilialProduto,TAMSX3("B9_FILIAL")[1]) +; 
							                  PAD(cCodigoProduto,TAMSX3("B9_COD")[1])    +;
											  PAD(cLocalEstoque ,TAMSX3("B9_LOCAL")[1])  +;
											  Dtos(cDataFechamento))) )
								Begin Transaction
									SB9->(RecLock("SB9",.F.))
										SB9->B9_DATA    := cDataFechamento
										SB9->B9_LOCAL   := cLocalEstoque
										SB9->B9_QINI    := nQuantidade
										SB9->B9_CM1     := nCustoUnitario
										SB9->B9_CM2     := nMA2CstoUnitario
										SB9->B9_VINI1   := nTotalCusto 
										SB9->B9_VINI2   := nMB2TotalCusto
										SB9->B9_CP0101  := nCxaVlrCaixa
										SB9->B9_CP0102  := nMC2VlrCaixa
										SB9->B9_CP0201  := nDprVlrDeprec
										SB9->B9_CP0202  := nMD2VlrDeprec 
										SB9->B9_CPM0101 := Round((nCxaVlrCaixa  / nQuantidade ),4)
										SB9->B9_CPM0102 := Round((nMC2VlrCaixa  / nQuantidade ),4)
										SB9->B9_CPM0201 := Round((nDprVlrDeprec / nQuantidade ),4)
										SB9->B9_CPM0202 := Round((nMD2VlrDeprec / nQuantidade ),4)

									SB9->(MsUnlock())
								End Transaction
								cStatus    := REGISTRO_ATUALIZADO
								cLog       += "+ Sucesso no Registro na linha " + cValToChar(nLinhaAtual) + ";" + CRLF
								ShowLogInConsole(cLog)

							Else 
								Begin Transaction
									SB9->(RecLock("SB9",.T.))
										SB9->B9_FILIAL  := cFilialProduto
										SB9->B9_COD     := AllTrim(cCodigoProduto)
										SB9->B9_DATA    := cDataFechamento
										SB9->B9_LOCAL   := cLocalEstoque
										SB9->B9_QINI    := nQuantidade
										SB9->B9_CM1     := nCustoUnitario
										SB9->B9_CM2     := nMA2CstoUnitario
										SB9->B9_VINI1   := nTotalCusto 
										SB9->B9_VINI2   := nMB2TotalCusto
										SB9->B9_CP0101  := nCxaVlrCaixa
										SB9->B9_CP0102  := nMC2VlrCaixa
										SB9->B9_CP0201  := nDprVlrDeprec
										SB9->B9_CP0202  := nMD2VlrDeprec 
										SB9->B9_CPM0101 := Round((nCxaVlrCaixa  / nQuantidade ),4)
										SB9->B9_CPM0102 := Round((nMC2VlrCaixa  / nQuantidade ),4)
										SB9->B9_CPM0201 := Round((nDprVlrDeprec / nQuantidade ),4)
										SB9->B9_CPM0202 := Round((nMD2VlrDeprec / nQuantidade ),4)
										SB9->B9_MCUSTD  := "1"
									SB9->(MsUnlock())
								End Transaction

								cStatus    := REGISTRO_ATUALIZADO
								cLog       += "+ Sucesso no Registro na linha " + cValToChar(nLinhaAtual) + ";" + CRLF
								ShowLogInConsole(cLog)
							EndIf 
						EndIf

						lAbre    := .T.

						oExcel:AddRow(cNomePlanilha, cTituloPlanilha,{Alltrim(cStatus),;
																	  cFilialProduto,;	
																	  cDataEmissao,; 	
																	  Alltrim(cCodigoProduto),;
																	  Alltrim(cDescricaoProduto),;
																	  Alltrim(cTipoProduto),;
																	  Alltrim(cUnidadeMedida),;
																	  Alltrim(cLocalEstoque),;
																	  nQuantidade,;
																	  nCustoUnitario,;
																	  nTotalCusto,;
																	  nCxaVlrCaixa,;
																	  nDprVlrDeprec})

								nQuantidade       := 0
								nCustoUnitario    := 0
								nTotalCusto       := 0
								nCxaVlrCaixa      := 0
								nDprVlrDeprec     := 0
								nMA2CstoUnitario  := 0
								nMB2TotalCusto    := 0
								nMC2VlrCaixa      := 0
								nMD2VlrDeprec     := 0

					EndIf
				EndIf
			EndDo

			MakeDir("C:\TOTVS")

			If (!Empty(cLog))
				MemoWrite(cDiretorioTmp + cArquivoLog, cLog)
				ShellExecute("OPEN", cArquivoLog, " ", cDiretorioTmp, 1)
			EndIf

			If ( lAbre )
				oExcel:Activate()
				oExcel:GetXMLFile(cArquivoDestino)
				OPENXML(cArquivoDestino)
				oExcel:DeActivate()
			Else
				FWAlertError("Não existe dados para serem impressos.", "SEM DADOS")
			EndIf

		Else
			FWAlertError("Arquivo não tem conteúdo!", "Atenção")
		EndIf

		oArquivo:Close()
	Else
		FWAlertError("Arquivo não pode ser aberto!", "Atenção")
	EndIf

Return

/*
    Abre o arquivo em formato excel 
*/
Static Function OPENXML(cArquivoDestino)

	If ( !ApOleClient("MsExcel") )
		Aviso("Atencao", "O Microsoft Excel nao esta instalado.", {"Ok"}, 2)
	Else
		oExcelApp := MsExcel():New()
		oExcelApp:WorkBooks:Open(cArquivoDestino)
		oExcelApp:SetVisible(.T.)
		oExcelApp:Destroy()
	EndIf

Return

/*
	Apresenta a Mensagem no Console do Protheus
*/
Static Function showLogInConsole(cMsg)

	libOzminerals.u_showLogInConsole(cMsg,cSintaxeRotina)

Return
