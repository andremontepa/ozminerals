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

/*/{Protheus.doc} OZ04M02

	Rotina para incluir e baixar as movimetações gerenciais 
	Foi utilizado a rotina automática para executar automaticamente a Movimentação Interna MOD2 - MATA241

	tdn https://centraldeatendimento.totvs.com/hc/pt-br/articles/360022031372-MP-SIGAEST-EXECAUTO-Execu%C3%A7%C3%A3o-autom%C3%A1tica-da-rotina-MATA241-Movimentos-M%C3%BAltiplos-

@type Function
@author Fabio Santos - CRM Service
@since 08/10/2023
@version P12
@database MSSQL

@Obs 
	Parametro : OZ_DELIMIT contem o delimitar utilizado no layout.
				Como default esta preenchido com ponto e virgula (;) 

	Parametro : OZ_TMENTRA contem a TM de entrada na tabela SF5

	Parametro : OZ_TMSAIDA contem a TM de saida na tabela SF5

	Layout utilizado em Excel: 

	CODIGO	DESCRICAO	TIPO UM	ARMAZEN	FLAG  QUANTIDADE
	131888  PRODUTO	    PA	 TL	10	    E	  100,00
	131888  PRODUTO	    PA	 TL	10	    S	  100,00

	Flag : 
	E = Entrada 
	S = Saida 

	Ponto de Atenção :

	O arquivo em Excel, deve ser transformado em formato CSV com o DELIMITADOR (;)

@see MATA241
@see OZGEN18

@nested-tags:Frameworks/OZminerals
/*/
User Function OZ04M02()
	Local aSays        		 := {}  as array
	Local aButtons     		 := {}  as array
	Local nOpca        		 := 0   as numeric
	Local cTitoDlg     		 := ""  as character

	Private cSeparador       := ""  as character
	Private cTipoMovEntrada  := ""  as character 
	Private cTipoMovSaida    := ""  as character 
	Private cSintaxeRotina   := ""  as character

	cSintaxeRotina           := ProcName(0)
	cTitoDlg    	         := "Manutenção Estoque Gerencial - OzMinerals"
	cSeparador               := AllTrim(GetNewPar("OZ_DELIMIT",";"))
	cTipoMovEntrada          := AllTrim(GetNewPar("OZ_TMENTRA","003"))
	cTipoMovSaida            := AllTrim(GetNewPar("OZ_TMSAIDA","510"))

	aAdd(aSays, "Esta rotina tem por objetivo gerar as quantidades referente ao estoque gerencial")
	aAdd(aSays, "Esta rotina somente importa arquivo em formato  ( .txt ou .csv ) !")
	aAdd(aSays, "O delimitador utlizado é (" + cSeparador + ") ")
	aAdd(aSays, "Parametro Entrada (" + cTipoMovEntrada + ") e Parametro Saida (" + cTipoMovSaida + ")")

	aAdd(aButtons,{STATUS_RECORD   , .T., {|o| nOpca := STATUS_RECORD   , FechaBatch()}})
	aAdd(aButtons,{STATUS_NO_RECORD, .T., {|o| nOpca := STATUS_NO_RECORD, FechaBatch()}})

	FormBatch(cTitoDlg, aSays, aButtons)

	If ( nOpca == STATUS_RECORD )
		ManutencaoEstoqueGerencial()
	EndIf

Return

/*
    Função que chama a static function de importação para o sistema
*/
Static Function ManutencaoEstoqueGerencial()
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
	Local aLogErro          := {}  as array
	Local aCabecalho        := {}  as array
	Local aItens            := {}  as array
	Local aItem    			:= {}  as array
	Local nTotalLinhas      := 0   as numeric
	Local nLinhaAtual       := 0   as numeric
	Local nLinhaErro        := 0   as numeric
	Local nQuantidade       := 0   as integer 
	Local lAbre             := .F. as logical
	Local lGravaTabela      := .T. as logical
	Local cDiretorioTmp     := ""  as character
	Local cArquivoLog       := ""  as character
	Local cLinhaAtual       := ""  as character
	Local cCodigoProduto    := ""  as character
	Local cDescricaoProduto := ""  as character
	Local cTipoProduto      := ""  as character
	Local cUnidadeMedida    := ""  as character
	Local cNomeErro         := ""  as character
	Local cTextoErro        := ""  as character
	Local cLog              := ""  as character
	Local cArquivoDestino   := ""  as character
	Local cNomePlanilha     := ""  as character
	Local cTituloPlanilha   := ""  as character
	Local cNomeWork         := ""  as character
	Local cStatus           := ""  as character
	Local cFlagMovimento    := ""  as character 
	Local cMovimentoEstoque := ""  as character 
	Local cDataEmissao      := ""  as character
	Local cDocumento        := ""  as character
 
	Private lMSHelpAuto     := .T. as logical
	Private lAutoErrNoFile  := .T. as logical
	Private lMsErroAuto     := .F. as logical

	cDiretorioTmp           := GetTempPath()
	cArquivoLog             := "importacao_" + dToS(Date())
	cArquivoLog             += "_" + StrTran(Time(), ":", "-") + ".log"
	cPastaErro              := "\CRM\"
	cArquivoDestino         := "C:\TOTVS\OZESTGER_EMP_" + SM0->M0_CODIGO
	cArquivoDestino         += "_" + Dtos(dDataBase) + StrTran(Time(),":","") + ".XML"
	cNomePlanilha           := "Empresa_" + Rtrim(SM0->M0_NOME)
	cNomeWork               := "Empresa_" + Rtrim(SM0->M0_NOME)
	cTituloPlanilha         := "OzMInerals - Manutenção Estoque Gerencial Layout"
	cDataEmissao	        := Substr(Dtos(ddatabase),7,2)
	cDataEmissao	  	    += "/" + Substr(Dtos(ddatabase),5,2)
	cDataEmissao   		    += "/" + Substr(Dtos(ddatabase),1,4)
	oExcel                  := FWMsExcelEX():New()

	oExcel:AddworkSheet(cNomeWork)
	oExcel:AddTable(cNomePlanilha , cTituloPlanilha)
	oExcel:AddColumn(cNomePlanilha, cTituloPlanilha, "Status Atualizacao"           , 1, 1, .F.)
	oExcel:AddColumn(cNomePlanilha, cTituloPlanilha, "Documento"                    , 1, 1, .F.)
	oExcel:AddColumn(cNomePlanilha, cTituloPlanilha, "Data Movimentação"            , 1, 1, .F.)
	oExcel:AddColumn(cNomePlanilha, cTituloPlanilha, "Tipo Movimento"               , 1, 1, .F.)
	oExcel:AddColumn(cNomePlanilha, cTituloPlanilha, "Codigo Produto"               , 1, 1, .F.)
	oExcel:AddColumn(cNomePlanilha, cTituloPlanilha, "Descrição Produto"            , 1, 1, .F.)
	oExcel:AddColumn(cNomePlanilha, cTituloPlanilha, "Tipo Produto"                 , 1, 1, .F.)
	oExcel:AddColumn(cNomePlanilha, cTituloPlanilha, "Unidade medida"               , 1, 1, .F.)
	oExcel:AddColumn(cNomePlanilha, cTituloPlanilha, "Armazen"                      , 1, 1, .F.)
	oExcel:AddColumn(cNomePlanilha, cTituloPlanilha, "Quantidade"                   , 1, 2, .F.)

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
					aCabecalho        := {}
					aItem  			  := {}
					aItens            := {}
					cCodigoProduto    := aLinha[01]
					cDescricaoProduto := aLinha[02]
					cTipoProduto      := aLinha[03]
					cUnidadeMedida    := aLinha[04]
					cLocalEstoque     := aLinha[05]
					cFlagMovimento    := aLinha[06] 
					nQuantidade       := Val(StrTran(StrTran(aLinha[07],";",""),",", "."))

					If ( AllTrim(Posicione("SB1",1,xFilial("SB1")+cCodigoProduto,"B1_COD")) == AllTrim(cCodigoProduto) )
						lGravaTabela   := .T.
					Else
						lGravaTabela   := .F.
						cStatus        := "Codigo de Produto Não Localizado"
					EndIf

					If ( lGravaTabela )
						If ( AllTrim(Posicione("SB1",1,xFilial("SB1")+cCodigoProduto,"B1_RASTRO")) $ AllTrim(RASTRO) )
							lGravaTabela   := .F.
							cStatus        := "Este Produto controla Lote, Não será Incluido"
						Else
							lGravaTabela   := .T.
						EndIf
					EndIf

					If ( lGravaTabela )
						If ( AllTrim(Posicione("SB1",1,xFilial("SB1")+cCodigoProduto,"B1_LOCALIZ")) $ AllTrim(ENDERECO) )
							lGravaTabela   := .F.
							cStatus        := "Este Produto controla Endereço, Não será Incluido"
						Else
							lGravaTabela   := .T.
						EndIf
					EndIf

					If ( lGravaTabela )
						If AllTrim(posicione("SX5",1,xFilial("SX5")+"02"+cTipoProduto,"X5_CHAVE")) == AllTrim(cTipoProduto)
							lGravaTabela   := .T.
						Else
							lGravaTabela   := .F.
							cStatus        := "Tipo de Produto Não Localizado"
						EndIf
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
						If ( AllTrim(Posicione("SAH",1,xFilial("SAH")+cUnidadeMedida,"AH_UNIMED")) == AllTrim(cUnidadeMedida) )
							lGravaTabela   := .T.
						Else
							lGravaTabela   := .F.
							cStatus        := "Unidade de Medida Não Localizado"
						EndIf
					EndIf

					If ( lGravaTabela )

						lMsErroAuto := .F.

						dbSelectArea("SB1")
						SB1->(dbSetOrder(1))
						If ( SB1->(dbSeek(xFilial("SB1") + cCodigoProduto )) )

							DbSelectArea("SD3")

							If ( AllTrim(cFlagMovimento) $ Alltrim(TIPO_ENTRADA) )
								cMovimentoEstoque := AllTrim(cTipoMovEntrada)
							ElseIf ( AllTrim(cFlagMovimento) $ AllTrim(TIPO_SAIDA) )
								cMovimentoEstoque := AllTrim(cTipoMovSaida)
							EndIf

							aCabecalho := { {"D3_DOC"     ,NextNumero("SD3",2,"D3_DOC",.T.), NIL} ,;
											{"D3_TM"      ,cMovimentoEstoque               , NIL} ,;
											{"D3_CC"      ,"        "                      , NIL} ,;
											{"D3_EMISSAO" ,ddatabase                       , NIL}}

							ProcRegua(0)
							IncProc("Adicionando produto " + Alltrim(SB1->B1_COD) + "...")
							
							aAdd(aItem, {"D3_COD"   ,cCodigoProduto   ,  Nil})
							aAdd(aItem, {"D3_UM"    ,cUnidadeMedida   ,  Nil})
							aAdd(aItem, {"D3_QUANT" ,nQuantidade      ,  Nil})
							aAdd(aItem, {"D3_LOCAL" ,cLocalEstoque    ,  Nil})

							aAdd(aItens, aClone(aItem))

							MsExecAuto({|x, y, z| MATA241(x, y, z)}, aCabecalho, aItens, INCLUI_EST)

							If lMsErroAuto

								cPastaErro := "\crm\"
								cNomeErro  := "erro_" + cArqSelecionado + "_lin_" + cValToChar(nLinhaAtual)
								cNomeErro  += "_" + dToS(Date()) + "_" + StrTran(Time(), ":", "-") + ".txt"

								If ( !ExistDir(cPastaErro))
									MakeDir(cPastaErro)
								EndIf

								cTextoErro := ""
								aLogErro   := GetAutoGRLog()

								For nLinhaErro := 1 To Len(aLogErro)
									cTextoErro += aLogErro[nLinhaErro] + CRLF
								Next

								MemoWrite(cPastaErro + cNomeErro, cTextoErro)
								cLog       += "- Falha ao incluir registro, "
								cLog       += "linha [" + cValToChar(nLinhaAtual) + "],"
								cLog       += "arquivo de log em " + cPastaErro + cNomeErro + CRLF
								ShowLogInConsole(cLog)
							Else
								cDocumento := Alltrim(SD3->D3_DOC)
								cStatus    := REGISTRO_ATUALIZADO
								cLog       += "+ Sucesso no Execauto na linha " + cValToChar(nLinhaAtual) + ";" + CRLF
								ShowLogInConsole(cLog)
							EndIf
						EndIf

						lAbre    := .T.

						oExcel:AddRow(cNomePlanilha, cTituloPlanilha,{Alltrim(cStatus),;
																	  Alltrim(cDocumento),; 		
																	  Alltrim(cDataEmissao),;	
																	  Alltrim(cMovimentoEstoque),;
																	  Alltrim(cCodigoProduto),;
																	  Alltrim(cDescricaoProduto),;
																	  Alltrim(cTipoProduto),;
																	  Alltrim(cUnidadeMedida),;
																	  Alltrim(cLocalEstoque),;
																	  nQuantidade})

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
