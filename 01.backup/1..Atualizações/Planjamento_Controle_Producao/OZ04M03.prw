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

#define OZ_FILIAL_01    		    "01"
#define OZ_FILIAL_02    		    "02"
#define OZ_FILIAL_03    		    "03"
#define OZ_FILIAL_04    		    "04"
#define OZ_FILIAL_05    		    "05"
#define OZ_FILIAL_06    		    "06"
#define OZ_FILIAL_07    		    "07"
#define OZ_FILIAL_08    		    "08"

#define ARMAZEN_FILIAL_01		    "10"
#define ARMAZEN_FILIAL_02		    "ZA"
#define ARMAZEN_FILIAL_03		    "10"
#define ARMAZEN_FILIAL_04		    "10"
#define ARMAZEN_FILIAL_05		    "10"
#define ARMAZEN_FILIAL_06		    "ZP"
#define ARMAZEN_FILIAL_07		    "10"
#define ARMAZEN_FILIAL_08		    "10"
#define ARMAZEN_PADRAO			    "10"

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

/*/{Protheus.doc} OZ04M03

	Rotina atualizar as contas contabeis do cadastro de produto e indicadores 

@type Function
@author Fabio Santos - CRM Service
@since 08/10/2023
@version P12
@database MSSQL

@Obs 
	Parametro OZ_DELIMIT contem o delimitar utilizado no layout.
	Como default esta preenchido com ponto e virgula (;) 

	Layout utilizado em Formato CSV: 

	FILIAL;PRODUTO;COMPONENTE;DESCRICAO;TIPO PRODUTO;UN MEDIDA;SEG UN MEDIDA;CONTA CONTABIL;CENTRO DE CUSTO;CENTRO CUSTO MAO OBRA;ITEM CONTABIL;CLASSE DE VALOR;CONTA CONTABIL CAIXA;CONTA CONTABIL DEPRECIACAO;
	02;131435;131498;CAIXA-AVBCANMO-001;CX;TL;;610101001;AVBCANMO;AVBCANMO;001;CPIND;610201003;;
	02;131435;131499;CAIXA-AVBCANMO-002;CX;TL;;610101001;AVBCANMO;AVBCANMO;002;CPIND;610201003;;
	02;131435;131500;CAIXA-AVBCANMO-003;CX;TL;;610101001;AVBCANMO;AVBCANMO;003;CPIND;610201003;;
	06;131440;231419;CPD001025-DEPRE-AVBCPBMAN-1025;DP;TL;;610101001;AVBCPBMAN;CPD001025;1025;CPIND;;710380004;
	06;131440;231420;CPD001026-DEPRE-AVBCPBMAN-1026;DP;TL;;610101001;AVBCPBMAN;CPD001026;1026;CPIND;;710380004;
	06;131440;231421;CPD001029-DEPRE-AVBCPBMAN-1029;DP;TL;;610101001;AVBCPBMAN;CPD001029;1029;CPIND;;710380004;
	02;131440;131440;MLPB10 MINERIO LAVRADO PB;PI;TL;;; ;; ;;110407005;110408005
	02;131546;131546;MLPB10A-MINERIO LAVRADO PB - C;PI;TL;;;;;;;110407006;110408006
	06;131435;131435;MLAN10 MINERIO LAVRADO ANTAS;PI;TL;;;;;;;110407001;110408001
	06;131436;131436;MBPB50 MINERIO BRITADO PEDRA B;PI;TL;;;;;;;110403001;110405001

@see OZGEN18

@nested-tags:Frameworks/OZminerals
/*/
User Function OZ04M03()
	Local aSays        		      := {}  as array
	Local aButtons     		      := {}  as array
	Local nOpca        		      := 0   as numeric
	Local cTitoDlg     		      := ""  as character

	Private cCtaIndiretoTransit   := ""  as character
	Private cCtaDiretoTransit     := ""  as character
	Private cSeparador            := ""  as character
	Private cArmazenPorFilial     := ""  as character
	Private cParamTipoProduto     := ""  as character

	cCtaDiretoTransit             := AllTrim(GetNewPar("OZ_CTADIR","610201999"))
	cCtaIndiretoTransit           := AllTrim(GetNewPar("OZ_CTAIND","710389999"))
	cSeparador                    := AllTrim(GetNewPar("OZ_DELIMIT",";"))
	cArmazenPorFilial     		  := AllTrim(GetNewPar("OZ_ARMAZEN","10"))
	cParamTipoProduto     		  := AllTrim(GetNewPar("OZ_TPPROD" ,"CX/DP"))

	cTitoDlg    	              := "Ajusta dados contabeis no cadastro de produto e Indicadores"

	aAdd(aSays, "Esta rotina tem por objetivo gerar ajustar conta contabil patrimonio, centro de custo,")
	aAdd(aSays, "Item contabil, Conta contabil caixa, conta contabil depreciação no cadastro de produto ")
	aAdd(aSays, "e cadastro de Indicadores - Esta rotina importa arquivo em formato  ( .txt ou .csv ) !")
	aAdd(aSays, "O delimitador utlizado é ("+cSeparador+") ")

	aAdd(aButtons,{STATUS_RECORD   , .T., {|o| nOpca := STATUS_RECORD   , FechaBatch()}})
	aAdd(aButtons,{STATUS_NO_RECORD, .T., {|o| nOpca := STATUS_NO_RECORD, FechaBatch()}})

	FormBatch(cTitoDlg, aSays, aButtons)

	If ( nOpca == STATUS_RECORD )
		ExecutaImportacaoProduto()
	EndIf

Return

/*
    Função que chama a importação para o sistema
*/
Static Function ExecutaImportacaoProduto()
	Local aArea           := {}  as array
	Local lSalvar         := .F. as logical
	Local cDirInicial     := ""  as character
	Local cTipoArquivo    := ""  as character
	Local cTitulo         := ""  as character
	Local cArqSelecionado := ""  as character

	aArea                 := FWGetArea()
	cDirInicial           := GetTempPath()
	cTipoArquivo          := "Arquivos com separações (*.csv) | Arquivos texto (*.txt) "
	cTipoArquivo          += "| Todas extensões (*.*)"
	cTitulo               := "Seleção de Arquivos para Processamento"

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
	Local oArquivo           := nil as Object
	Local oExcel             := nil as Object
	Local aLinha             := {}  as array
	Local aLinhas            := {}  as array
	Local aLogErro           := {}  as array
	Local nTotalLinhas       := 0   as numeric
	Local nLinhaAtual        := 0   as numeric
	Local nLinhaErro         := 0   as numeric
	Local lPermiteExecutar   := .F. as logical
	Local lAbre              := .F. as logical
	Local lGravaTabela       := .T. as logical
	lOCAL lReckLock          := .T. as logical
	Local cDiretorioTmp      := ""  as character
	Local cArquivoLog        := ""  as character
	Local cLinhaAtual        := ""  as character
	Local cCodigoFilial      := ""  as character
	Local cCodigoPrincipal   := ""  as character
	Local cCodigoProduto     := ""  as character
	Local cDescricaoProduto  := ""  as character
	Local cTipoProduto       := ""  as character
	Local cUnidadeMedida     := ""  as character
	Local cSegUnidMedida     := ""  as character
	Local cContaContabil     := ""  as character
	Local cAntCentroCusto    := ""  as character
	Local cCentroCusteio     := ""  as character
	Local cItemContabil      := ""  as character
	Local cClasseValor       := ""  as character
	Local cContaCaixa        := ""  as character
	Local cContaDepreciacao  := ""  as character
	Local cNomeErro          := ""  as character
	Local cTextoErro         := ""  as character
	Local cLog               := ""  as character
	Local cArquivoDestino    := ""  as character
	Local cNomePlanilha      := ""  as character
	Local cTituloPlanilha    := ""  as character
	Local cNomeWork          := ""  as character
	Local cStatus            := ""  as character
	Local cLocalProduto      := ""  as character
	Local cCtaCxaTransit     := ""  as character
	Local cCtaDprTransit     := ""  as character

	cDiretorioTmp            := GetTempPath()
	cArquivoLog              := "importacao_" + dToS(Date())
	cArquivoLog              += "_" + StrTran(Time(), ":", "-") + ".log"
	cPastaErro               := "\CRM\"
	cArquivoDestino          := "C:\TOTVS\OZIMPSB1_EMP_" + SM0->M0_CODIGO
	cArquivoDestino          += "_" + Dtos(dDataBase) + StrTran(Time(),":","") + ".XML"
	cNomePlanilha            := "Empresa_" + Rtrim(SM0->M0_NOME)
	cNomeWork                := "Empresa_" + Rtrim(SM0->M0_NOME)
	cTituloPlanilha          := "OzMInerals - Produtos Ajustados conforme Layout"
	oExcel                   := FWMsExcelEX():New()

	oExcel:AddworkSheet(cNomeWork)
	oExcel:AddTable(cNomePlanilha , cTituloPlanilha)
	oExcel:AddColumn(cNomePlanilha, cTituloPlanilha, "Status Atualizacao"     , 1, 1, .F.)
	oExcel:AddColumn(cNomePlanilha, cTituloPlanilha, "Codigo Filial"          , 1, 1, .F.)
	oExcel:AddColumn(cNomePlanilha, cTituloPlanilha, "Codigo Produto"         , 1, 1, .F.)
	oExcel:AddColumn(cNomePlanilha, cTituloPlanilha, "Descrição Produto"      , 1, 1, .F.)
	oExcel:AddColumn(cNomePlanilha, cTituloPlanilha, "Tipo Produto"           , 1, 1, .F.)
	oExcel:AddColumn(cNomePlanilha, cTituloPlanilha, "Unidade medida"         , 1, 1, .F.)
	oExcel:AddColumn(cNomePlanilha, cTituloPlanilha, "Conta Contabil"         , 1, 1, .F.)
	oExcel:AddColumn(cNomePlanilha, cTituloPlanilha, "Centro de Custo"        , 1, 1, .F.)
	oExcel:AddColumn(cNomePlanilha, cTituloPlanilha, "Item Contabil"          , 1, 1, .F.)
	oExcel:AddColumn(cNomePlanilha, cTituloPlanilha, "Conta Ctb Caixa"        , 1, 1, .F.)
	oExcel:AddColumn(cNomePlanilha, cTituloPlanilha, "Conta Ctb Depreciação"  , 1, 1, .F.)
	oExcel:AddColumn(cNomePlanilha, cTituloPlanilha, "C.Custo Custeio"        , 1, 1, .F.)
	oExcel:AddColumn(cNomePlanilha, cTituloPlanilha, "Classe de Valor"        , 1, 1, .F.)

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

					lGravaTabela       := .F.
					lAbre              := .F.
					lReckLock          := .F.
					cCodigoFilial      := aLinha[01]
					cCodigoPrincipal   := aLinha[02]
					cCodigoProduto     := aLinha[03]
					cDescricaoProduto  := aLinha[04]
					cTipoProduto       := aLinha[05]
					cUnidadeMedida     := aLinha[06]
					cSegUnidMedida     := aLinha[07] 
					cContaContabil     := aLinha[08]
					cAntCentroCusto    := aLinha[09]
					cCentroCusteio     := aLinha[10]
					cItemContabil      := aLinha[11]
					cClasseValor       := aLinha[12]
					cContaCaixa        := aLinha[13]
					cContaDepreciacao  := aLinha[14]

					If ( AllTrim(Posicione("SB1",1,xFilial("SB1")+cCodigoProduto,"B1_COD")) == AllTrim(cCodigoProduto) )
						lGravaTabela   := .T.
					Else
						lGravaTabela   := .F.
						cStatus        := "Codigo de Produto Não Localizado"
						lAbre          := .T.
					EndIf

					If ( lGravaTabela )
						If AllTrim(posicione("SX5",1,xFilial("SX5")+"02"+cTipoProduto,"X5_CHAVE")) == AllTrim(cTipoProduto)
							lGravaTabela   := .T.
						Else
							lGravaTabela   := .F.
							cStatus        := "Tipo de Produto Não Localizado"
							lAbre          := .T.
						EndIf
					EndIf

					If ( lGravaTabela )
						If ( AllTrim(Posicione("SAH",1,xFilial("SAH")+cUnidadeMedida,"AH_UNIMED")) == AllTrim(cUnidadeMedida) )
							lGravaTabela   := .T.
						Else
							lGravaTabela   := .F.
							cStatus        := "Armazen Não Localizado"
							lAbre          := .T.
						EndIf
					EndIf

					If (!Empty(cContaContabil))
						If ( lGravaTabela )
							If ( AllTrim(Posicione("CT1",1,xFilial("CT1")+cContaContabil,"CT1_CONTA")) == AllTrim(cContaContabil) )
								lGravaTabela   := .T.
							Else
								lGravaTabela   := .F.
								cStatus        := "Conta Contabil Não Localizado"
								lAbre          := .T.
							EndIf
						EndIf
					EndIf

					If (!Empty(cContaCaixa))
						If ( lGravaTabela )
							If ( AllTrim(Posicione("CT1",1,xFilial("CT1")+cContaCaixa,"CT1_CONTA")) == AllTrim(cContaCaixa))
								lGravaTabela   := .T.
							Else
								lGravaTabela   := .F.
								cStatus        := "Conta Caixa Não Localizado"
								lAbre          := .T.
							EndIf
						EndIf
					EndIf

					If (!Empty(cContaDepreciacao))
						If ( lGravaTabela )
							If ( AllTrim(Posicione("CT1",1,xFilial("CT1")+cContaDepreciacao,"CT1_CONTA")) == AllTrim(cContaDepreciacao))
								lGravaTabela   := .T.
							Else
								lGravaTabela   := .F.
								cStatus        := "Conta Depreciação Não Localizado"
								lAbre          := .T.
							EndIf
						EndIf
					EndIf

					If (!Empty(cAntCentroCusto))
						If ( lGravaTabela )
							If ( AllTrim(Posicione("CTT",1,xFilial("CTT")+cAntCentroCusto,"CTT_CUSTO")) == AllTrim(cAntCentroCusto) )
								lGravaTabela   := .T.
							Else
								lGravaTabela   := .F.
								cStatus        := "Centro de Custo Não Localizado"
								lAbre          := .T.
							EndIf
						EndIf
					EndIf

					If (!Empty(cCentroCusteio))
						If ( lGravaTabela )
							If ( AllTrim(Posicione("CTT",1,xFilial("CTT")+cCentroCusteio ,"CTT_CUSTO")) == AllTrim(cCentroCusteio ))
								lGravaTabela   := .T.
							Else
								lGravaTabela   := .F.
								cStatus        := "C.Custo Custeio Não Localizado"
								lAbre          := .T.
							EndIf
						EndIf
					EndIf

					If (!Empty(cItemContabil))
						If ( lGravaTabela )
							If ( AllTrim(Posicione("CTD",1,xFilial("CTD")+cItemContabil,"CTD_ITEM")) == AllTrim(cItemContabil))
								lGravaTabela   := .T.
							Else
								lGravaTabela   := .F.
								cStatus        := "Item Contabil Não Localizado"
								lAbre          := .T.
							EndIf
						EndIf
					EndIf

					If (!Empty(cClasseValor))
						If ( lGravaTabela )
							If ( AllTrim(Posicione("CTH",1,xFilial("CTH")+cClasseValor,"CTH_CLVL")) == AllTrim(cClasseValor))
								lGravaTabela   := .T.
							Else
								lGravaTabela   := .F.
								cStatus        := "Classe de Valor Não Localizado"
								lAbre          := .T.
							EndIf
						EndIf
					EndIf

					If ( lGravaTabela )

						cStatus        := REGISTRO_ATUALIZADO
						
						If ( cTipoProduto $ cParamTipoProduto )
							If ( AllTrim(cCodigoFilial) $ OZ_FILIAL_02 ) 
								cLocalProduto := ARMAZEN_FILIAL_02
							ElseIf ( AllTrim(cCodigoFilial) $ OZ_FILIAL_06 ) 
								cLocalProduto := ARMAZEN_FILIAL_06
							else
								cLocalProduto := cArmazenPorFilial
							EndIf 
						Else 
								cLocalProduto := cArmazenPorFilial
						EndIf

						cCtaCxaTransit := Alltrim(cCtaDiretoTransit)	
						cCtaDprTransit := Alltrim(cCtaIndiretoTransit)

						dbSelectArea("SB1")
						SB1->(dbSetOrder(1))
						If ( SB1->(dbSeek(xFilial("SB1") + cCodigoProduto )) )
							Begin Transaction
								SB1->(RecLock("SB1",.F.))
									SB1->B1_TIPO     := Alltrim(cTipoProduto)
									SB1->B1_LOCPAD   := AllTrim(cLocalProduto)
									SB1->B1_UM       := Alltrim(cUnidadeMedida)
									SB1->B1_CONTA    := IF(!Empty(Alltrim(cContaCaixa)),Alltrim(cCtaCxaTransit),Alltrim(cCtaDprTransit))
									SB1->B1_CC       := Alltrim(cAntCentroCusto)
									SB1->B1_ITEMCC   := Alltrim(cItemContabil)
									SB1->B1_CCCUSTO  := Alltrim(cCentroCusteio)
									SB1->B1_CLVL     := Alltrim(cClasseValor)
								SB1->(MsUnlock())
							End Transaction

							DbSelectArea("SBZ")
							SBZ->(DbSetOrder(1))
							If ( SBZ->(DbSeek(cCodigoFilial + cCodigoProduto)))
								cStatus   := "Resgistro Já Existe na base"
								lReckLock := .F.
							Else
								lReckLock := .T.
							EndIf

							Begin Transaction
								SBZ->(Reclock("SBZ",lReckLock))
									SBZ->BZ_FILIAL   := AllTrim(cCodigoFilial)
									SBZ->BZ_COD      := AllTrim(cCodigoProduto)
									SBZ->BZ_XDESC    := AllTrim(cDescricaoProduto)
									SBZ->BZ_LOCPAD   := AllTrim(cLocalProduto) 
									If  ( AllTrim(Posicione("SB1",1,xFilial("SB1")+cCodigoProduto,"B1_TIPO")) $ (TIPO_PA+"/"+TIPO_PI))
										SBZ->BZ_XCTACXA  := Alltrim(cContaCaixa)
										SBZ->BZ_XCTADPR  := AllTrim(cContaDepreciacao)
									Else 
										SBZ->BZ_XCTACXA  := IF(!Empty(Alltrim(cContaCaixa)),Alltrim(cContaCaixa),"")
										SBZ->BZ_XCTADPR  := IF(!Empty(AllTrim(cContaDepreciacao)),AllTrim(cContaDepreciacao),"")
									EndIf 
									If  ( AllTrim(Posicione("SB1",1,xFilial("SB1")+cCodigoProduto,"B1_TIPO")) $ (TIPO_PA+"/"+TIPO_PI))
										SBZ->BZ_XCTADIR  := AllTrim(cCtaCxaTransit)
										SBZ->BZ_XCTAIND  := AllTrim(cCtaDprTransit)
									Else 
										SBZ->BZ_XCTADIR  := IF(!Empty(Alltrim(cContaCaixa)),AllTrim(cCtaCxaTransit),"")
										SBZ->BZ_XCTAIND  := IF(!Empty(AllTrim(cContaDepreciacao)),AllTrim(cCtaDprTransit),"")
									EndIf 
									SBZ->BZ_ORIGEM   := ORIGEM_PRODUTO
									SBZ->BZ_LOCALIZ  := LOCALIZACAO
									SBZ->BZ_DTINCLU  := DDATABASE
									SBZ->BZ_CTRWMS   := CONTROLE_WMS
									SBZ->BZ_CSLL     := IMPOSTO_CSLL
									SBZ->BZ_MCUSTD   := CUSTO_MOEDA
									SBZ->BZ_TIPOCQ   := TIPO_CQ
								SBZ->( Msunlock() )
							End Transaction

							lPermiteExecutar := .F.
							lAbre := .T.
						Else

							lPermiteExecutar := .T.
						EndIf
					EndIf

					If ( lAbre )

						oExcel:AddRow(cNomePlanilha, cTituloPlanilha,{  Alltrim(cStatus),;
																		Alltrim(cCodigoFilial),;
																		Alltrim(cCodigoProduto),;
																		Alltrim(cDescricaoProduto),;
																		Alltrim(cTipoProduto),;
																		Alltrim(cUnidadeMedida),;
																		Alltrim(cContaContabil),;
																		Alltrim(cAntCentroCusto),;
																		Alltrim(cItemContabil),;
																		Alltrim(cContaCaixa),;
																		Alltrim(cContaDepreciacao),;
																		Alltrim(cCentroCusteio),;
																		Alltrim(cClasseValor)})
					EndIf

					If ( lPermiteExecutar )

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
						cLog += "- Falha ao incluir registro, "
						cLog += "linha [" + cValToChar(nLinhaAtual) + "],"
						cLog += "arquivo de log em " + cPastaErro + cNomeErro + CRLF

					Else
						cLog += "+ Sucesso no Execauto na linha " + cValToChar(nLinhaAtual) + ";" + CRLF
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
    Função abre o arquivo em formato excel 
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
