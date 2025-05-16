#include "protheus.ch"
#include "Totvs.ch"
#include "Tbiconn.ch"
//#include "ozminerals.ch"

#define ROTINA_MATA270             	"MATA270"
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

/*/{Protheus.doc} OZ04M99

	Rotina para incluir movimentos no registro de inventario tabela SB7

@type Function
@author Fabio Santos - CRM Service
@since 04/07/2024
@version P12
@database MSSQL

@Obs 
	Parametro : OZ_DELIMIT contem o delimitar utilizado no layout.
				Como default esta preenchido com ponto e virgula (;) 

@see OZGEN18

@nested-tags:Frameworks/OZminerals
/*/
User Function OZ04M99()
	Local aSays        		 := {}  as array
	Local aButtons     		 := {}  as array
	Local nOpca        		 := 0   as numeric
	Local cTitoDlg     		 := ""  as character

	Private cSeparador       := ""  as character
	Private cTipoMovEntrada  := ""  as character
	Private cTipoMovSaida    := ""  as character
	Private cSintaxeRotina   := ""  as character
	Private cCtaDespInvent   := ""  as character

	cSintaxeRotina           := ProcName(0)
	cTitoDlg    	         := "Manutenção Inventario - OzMinerals"
	cSeparador               := AllTrim(GetNewPar("OZ_DELIMIT",";"))
	cCtaDespInvent           := AllTrim(GetNewPar("OZ_CTADESP","610118001"))

	aAdd(aSays, "Esta rotina tem por objetivo incluir as quantidades referente ao inventario")
	aAdd(aSays, "Esta rotina somente importa arquivo em formato  ( .txt ou .csv ) !")
	aAdd(aSays, "O delimitador utlizado é (" + cSeparador + ") ")

	aAdd(aButtons,{STATUS_RECORD   , .T., {|o| nOpca := STATUS_RECORD   , FechaBatch()}})
	aAdd(aButtons,{STATUS_NO_RECORD, .T., {|o| nOpca := STATUS_NO_RECORD, FechaBatch()}})

	FormBatch(cTitoDlg, aSays, aButtons)

	If ( nOpca == STATUS_RECORD )
		ManutencaoInventario()
	EndIf

Return

/*
    Função que chama a static function de importação para o sistema
*/
Static Function ManutencaoInventario()
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
	Local nQtd2Unidade      := 0   as integer
	Local nVlrUnitario      := 0   as integer
	Local nCont             := 0   as integer
	Local nSeqInvent        := 0   as integer
	Local lAbre             := .F. as logical
	Local lGravaTabela      := .T. as logical
	Local lReckLock         := .F. as logical
	Local cCodFilial        := ""  as Character
	Local cArmazem          := ""  as Character
	Local cEndereco         := ""  as Character
	Local dDataInventario   := ""  as Character
	Local cCentroCusto      := ""  as Character
	Local cItemContabil     := ""  as Character
	Local cClasseValor      := ""  as Character
	Local cDiretorioTmp     := ""  as character
	Local cArquivoLog       := ""  as character
	Local cLinhaAtual       := ""  as character
	Local cCodigoProduto    := ""  as character
	Local cTipoProduto      := ""  as character
	Local cUnidadeMedida    := ""  as character
	Local cLog              := ""  as character
	Local cArquivoDestino   := ""  as character
	Local cNomePlanilha     := ""  as character
	Local cTituloPlanilha   := ""  as character
	Local cNomeWork         := ""  as character
	Local cStatus           := ""  as character
	Local cDataEmissao      := ""  as character
	Local cDocumento        := ""  as character
	Local cContagem         := ""  as character
	Local cDescProduto      := ""  as character
	Local cControlaEnd      := ""  as character
	Local cCtaContabil      := ""  as character
	Local cNumSerie         := ""  as character 
	Local cLoteCtl          := ""  as character 
	Local cNumLote          := ""  as character

	Private lMSHelpAuto     := .T. as logical
	Private lAutoErrNoFile  := .T. as logical
	Private lMsErroAuto     := .F. as logical

	cDiretorioTmp           := GetTempPath()
	cArquivoLog             := "importacao_" + dToS(Date())
	cArquivoLog             += "_" + StrTran(Time(), ":", "-") + ".log"
	cPastaErro              := "\CRM\"
	cArquivoDestino         := "C:\TOTVS\OZINVEST_EMP_" + SM0->M0_CODIGO
	cArquivoDestino         += "_" + Dtos(dDataBase) + StrTran(Time(),":","") + ".XML"
	cNomePlanilha           := "Empresa_" + Rtrim(SM0->M0_NOME)
	cNomeWork               := "Empresa_" + Rtrim(SM0->M0_NOME)
	cTituloPlanilha         := "OzMInerals - Manutenção Inventario Layout"
	cDataEmissao	        := Substr(Dtos(ddatabase),7,2)
	cDataEmissao	  	    += "/" + Substr(Dtos(ddatabase),5,2)
	cDataEmissao   		    += "/" + Substr(Dtos(ddatabase),1,4)
	dDataInventario         := CtoD("")
	dDataInventario         := dDatabase
	cNumSerie               := padr(Alltrim(cNumSerie),tamSx3("B7_NUMSERI")[1])
	cLoteCtl                := padr(Alltrim(cLoteCtl) ,tamSx3("B7_LOTECTL")[1])
	cNumLote                := padr(Alltrim(cNumLote) ,tamSx3("B7_NUMLOTE")[1])
	oExcel                  := FWMsExcelEX():New()

	oExcel:AddworkSheet(cNomeWork)
	oExcel:AddTable(cNomePlanilha , cTituloPlanilha)
	oExcel:AddColumn(cNomePlanilha, cTituloPlanilha, "Status Atualizacao"           , 1, 1, .F.)
	oExcel:AddColumn(cNomePlanilha, cTituloPlanilha, "Codigo Produto"               , 1, 1, .F.)
	oExcel:AddColumn(cNomePlanilha, cTituloPlanilha, "Descrição Produto"            , 1, 1, .F.)
	oExcel:AddColumn(cNomePlanilha, cTituloPlanilha, "Documento"                    , 1, 1, .F.)
	oExcel:AddColumn(cNomePlanilha, cTituloPlanilha, "Data Movimentação"            , 1, 1, .F.)
	oExcel:AddColumn(cNomePlanilha, cTituloPlanilha, "Prod. Controla Endereço"      , 1, 1, .F.)
	oExcel:AddColumn(cNomePlanilha, cTituloPlanilha, "Tipo Produto"                 , 1, 1, .F.)
	oExcel:AddColumn(cNomePlanilha, cTituloPlanilha, "Unidade medida"               , 1, 1, .F.)
	oExcel:AddColumn(cNomePlanilha, cTituloPlanilha, "Armazen"                      , 1, 1, .F.)
	oExcel:AddColumn(cNomePlanilha, cTituloPlanilha, "Endereço"                     , 1, 1, .F.)
	oExcel:AddColumn(cNomePlanilha, cTituloPlanilha, "Quantidade"                   , 1, 2, .F.)
	oExcel:AddColumn(cNomePlanilha, cTituloPlanilha, "Conta Contabil Produto"       , 1, 1, .F.)
	oExcel:AddColumn(cNomePlanilha, cTituloPlanilha, "Conta Contabil Inventario"    , 1, 1, .F.)
	oExcel:AddColumn(cNomePlanilha, cTituloPlanilha, "Centro Custo Despesa"         , 1, 1, .F.)
	oExcel:AddColumn(cNomePlanilha, cTituloPlanilha, "Item Contabil Despesa"        , 1, 1, .F.)
	oExcel:AddColumn(cNomePlanilha, cTituloPlanilha, "Classe Valor Despesa"         , 1, 1, .F.)
	oExcel:AddColumn(cNomePlanilha, cTituloPlanilha, "Valor Unitario"               , 1, 2, .F.)
	oExcel:AddColumn(cNomePlanilha, cTituloPlanilha, "Numero Contagem"              , 1, 1, .F.)

	oArquivo := FWFileReader():New(cArqSelecionado)

	If (oArquivo:Open())

		If ( !(oArquivo:EoF()) )

			aLinhas      := oArquivo:GetAllLines()
			nTotalLinhas := Len(aLinhas)
			ProcRegua(nTotalLinhas)

			oArquivo:Close()
			oArquivo := FWFileReader():New(cArqSelecionado)
			oArquivo:Open()

			dbSelectArea("SB1")
			SB1->(dbSetOrder(1))

			DbSelectArea("SB7")
			SB7->(DbSetOrder(1)) 

			While (oArquivo:HasLine())

				nLinhaAtual++
				IncProc("Analisando linha " + cValToChar(nLinhaAtual) + " de " + cValToChar(nTotalLinhas) + "...")

				cLinhaAtual := oArquivo:GetLine()
				aLinha      := Separa(cLinhaAtual, cSeparador)

				If ( Len(aLinha) > 0 .And. nLinhaAtual >= 2 )

					lGravaTabela      := .F.
					lReckLock         := .F.
					cStatus           := ""
					cUnidadeMedida	  := ""
					cDescProduto      := ""
					cControlaEnd      := ""
					cTipoProduto      := ""
					cCtaContabil      := ""
					cCodFilial        := aLinha[01]
					cCodigoProduto    := aLinha[02]
					cDocumento        := aLinha[03]
					nQuantidade       := Val(StrTran(StrTran(aLinha[04],";",""),",", "."))
					nQtd2Unidade      := Val(StrTran(StrTran(aLinha[05],";",""),",", "."))
					cArmazem          := aLinha[06]
					cEndereco         := aLinha[07]
					dDataInventario   := StoD(aLinha[08])
					nVlrUnitario      := Val(StrTran(StrTran(aLinha[09],";",""),",", "."))
					cCentroCusto      := aLinha[10]
					cItemContabil     := aLinha[11]
					cClasseValor      := aLinha[12]

					If ( AllTrim(Posicione("SB1",1,xFilial("SB1")+cCodigoProduto,"B1_COD")) == AllTrim(cCodigoProduto) )
						lGravaTabela   := .T.
						cUnidadeMedida := AllTrim(Posicione("SB1",1,xFilial("SB1")+cCodigoProduto,"B1_UM"))
						cDescProduto   := AllTrim(Posicione("SB1",1,xFilial("SB1")+cCodigoProduto,"B1_DESC"))
						cControlaEnd   := AllTrim(Posicione("SB1",1,xFilial("SB1")+cCodigoProduto,"B1_LOCALIZ"))
						cTipoProduto   := AllTrim(Posicione("SB1",1,xFilial("SB1")+cCodigoProduto,"B1_TIPO"))
						cCtaContabil   := AllTrim(Posicione("SB1",1,xFilial("SB1")+cCodigoProduto,"B1_CONTA"))
					Else
						lGravaTabela   := .F.
						cStatus        := "Codigo de Produto Não Localizado"
					EndIf

					If ( lGravaTabela )
						If ( AllTrim(Posicione("SB1",1,xFilial("SB1")+cCodigoProduto,"B1_RASTRO")) == AllTrim(RASTRO) )
							lGravaTabela   := .F.
							cStatus        := "Este Produto controla Lote, Não será Incluido"
						Else
							lGravaTabela   := .T.
						EndIf
					EndIf

					If ( lGravaTabela )
						If ( AllTrim(Posicione("SB1",1,xFilial("SB1")+cCodigoProduto,"B1_LOCALIZ")) == AllTrim(ENDERECO) )
							lGravaTabela   := .T.
						Else
							cEndereco      := ""
						EndIf
					EndIf

					If ( lGravaTabela )
						If ( AllTrim(Posicione("SB1",1,xFilial("SB1")+cCodigoProduto,"B1_LOCALIZ")) == AllTrim(ENDERECO) )
							If ( AllTrim(Posicione("SBE",9,xFilial("SBE")+cEndereco,"BE_LOCALIZ")) == AllTrim(cEndereco) )
								lGravaTabela   := .T.
							Else
								lGravaTabela   := .F.
								cStatus        := "Endereco nao localizado"
							EndIf
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
						If ( AllTrim(Posicione("NNR",1,xFilial("NNR")+cArmazem,"NNR_CODIGO")) == AllTrim(cArmazem) )
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

					If ( lGravaTabela .And. !Empty(AllTrim(cCentroCusto)) )
						If ( AllTrim(Posicione("CTT",1,xFilial("CTT")+cCentroCusto,"CTT_CUSTO")) == AllTrim(cCentroCusto) )
							lGravaTabela   := .T.
						Else
							lGravaTabela   := .F.
							cStatus        := "Centro de Custo Não Localizado"
						EndIf
					EndIf

					If ( lGravaTabela .And. !Empty(AllTrim(cItemContabil)) )
						If ( AllTrim(Posicione("CTD",1,xFilial("CTD")+cItemContabil,"CTD_ITEM")) == AllTrim(cItemContabil) )
							lGravaTabela   := .T.
						Else
							lGravaTabela   := .F.
							cStatus        := "Item Contabil Não Localizado"
						EndIf
					EndIf

					If ( lGravaTabela .And. !Empty(AllTrim(cClasseValor)) )
						If ( AllTrim(Posicione("CTH",1,xFilial("CTH")+cClasseValor,"CTH_CLVL")) == AllTrim(cClasseValor) )
							lGravaTabela   := .T.
						Else
							lGravaTabela   := .F.
							cStatus        := "Classe de Valor Não Localizado"
						EndIf
					EndIf

					If ( lGravaTabela )

						nSeqInvent := 0
						cContagem  := "001"
						nSeqInvent := nCont++
						If ( SB1->(dbSeek(xFilial("SB1") + cCodigoProduto )) )

							ProcRegua(0)
							IncProc("Adicionando produto " + Alltrim(SB1->B1_COD) + "...")

							If (SB7->(DbSeek(xFilial("SB7") + DtoS(dDataInventario) + cCodigoProduto + cArmazem +; 
															  cEndereco + cNumSerie + cLoteCtl + cNumLote + cContagem )))
								lReckLock := .F.
							Else 
								lReckLock := .T.
							EndIf

							Begin Transaction
								SB7->(RecLock("SB7",lReckLock))
									SB7->B7_FILIAL  := cCodFilial
									SB7->B7_DOC     := cDocumento
									SB7->B7_COD     := cCodigoProduto
									SB7->B7_TIPO    := cTipoProduto
									SB7->B7_QUANT   := nQuantidade
									SB7->B7_QTSEGUM := nQtd2Unidade
									SB7->B7_LOCAL   := cArmazem
									SB7->B7_LOCALIZ := cEndereco
									SB7->B7_CONTAGE := cContagem
									SB7->B7_XCONTA  := cCtaContabil
									SB7->B7_XCTADES := cCtaDespInvent
									SB7->B7_XCC     := cCentroCusto
									SB7->B7_XITEMCT := cItemContabil
									SB7->B7_XCLVL   := cClasseValor
									SB7->B7_XVALOR  := nVlrUnitario
									SB7->B7_DTVALID := dDataInventario
									SB7->B7_DATA    := dDataInventario
									SB7->B7_ORIGEM  := ROTINA_MATA270 
									SB7->B7_STATUS  := STATUS_PROCESSANDO
									SB7->B7_XSEQINV := nSeqInvent
								SB7->(MsUnlock())
							End Transaction
							cDocumento := Alltrim(cDocumento)
							cStatus    := REGISTRO_ATUALIZADO
							cLog       += "+ Sucesso no Execauto na linha " + cValToChar(nLinhaAtual) + ";" + CRLF

							ShowLogInConsole(cLog)
						EndIf
					Else 
						If ( !Empty(AllTrim(cStatus)) )
							cStatus := cStatus
						Else 

							cStatus := REGISTRO_NAO_ATUALIZADO
						EndIf
					EndIf

					lAbre    := .T.

					oExcel:AddRow(cNomePlanilha, cTituloPlanilha,{	Alltrim(cStatus),;
																	Alltrim(cCodigoProduto),;
																	Alltrim(cDescProduto),;
																	Alltrim(cDocumento),;
																	Alltrim(cDataEmissao),;
																	Alltrim(cControlaEnd),;
																	Alltrim(cTipoProduto),;
																	Alltrim(cUnidadeMedida),;
																	Alltrim(cArmazem),;
																	Alltrim(cEndereco),;
																	nQuantidade,;
																	Alltrim(cCtaContabil),;
																	Alltrim(cCtaDespInvent),;
																	Alltrim(cCentroCusto),;
																	Alltrim(cItemContabil),;
																	Alltrim(cClasseValor),;
																	nVlrUnitario,;
																	Alltrim(cContagem)})
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
