#include "protheus.ch"
#include "Totvs.ch"
#include "Tbiconn.ch"
#include "ozminerals.ch"

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

/*/{Protheus.doc} OZ04M98

	Rotina para ajustar movimentos das entidades contabeis na tabela SD3

@type Function
@author Fabio Santos - CRM Service
@since 18/07/2024
@version P12
@database MSSQL

@Obs 
	Parametro : OZ_DELIMIT contem o delimitar utilizado no layout.
				Como default esta preenchido com ponto e virgula (;) 

@see OZGEN18

@nested-tags:Frameworks/OZminerals
/*/
User Function OZ04M98()
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
	cTitoDlg    	         := "Ajuste entidades contabeis do inventario - OzMinerals"
	cSeparador               := AllTrim(GetNewPar("OZ_DELIMIT",";"))
	cCtaDespInvent           := AllTrim(GetNewPar("OZ_CTADESP","610118001"))

	aAdd(aSays, "Esta rotina tem por objetivo ajustar entidades contabeis referente ao inventario")
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
	Local lAbre             := .F. as logical
	Local lGravaTabela      := .T. as logical
	Local cCodFilial        := ""  as Character
	Local cArmazem          := ""  as Character
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
	Local cDescProduto      := ""  as character
	Local cControlaEnd      := ""  as character
	Local cCtaContabil      := ""  as character
	Local cNumSerie         := ""  as character 
	Local cLoteCtl          := ""  as character 
	Local cNumLote          := ""  as character
	Local cCf               := ""  as character
	Local cTm               := ""  as character
	Local cCheckCtaCtb      := ""  as character

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
	oExcel:AddColumn(cNomePlanilha, cTituloPlanilha, "Filial"                       , 1, 1, .F.)
	oExcel:AddColumn(cNomePlanilha, cTituloPlanilha, "Codigo Produto"               , 1, 1, .F.)
	oExcel:AddColumn(cNomePlanilha, cTituloPlanilha, "Descrição Produto"            , 1, 1, .F.)
	oExcel:AddColumn(cNomePlanilha, cTituloPlanilha, "Data Movimentação"            , 1, 1, .F.)
	oExcel:AddColumn(cNomePlanilha, cTituloPlanilha, "Tipo Produto"                 , 1, 1, .F.)
	oExcel:AddColumn(cNomePlanilha, cTituloPlanilha, "Unidade medida"               , 1, 1, .F.)
	oExcel:AddColumn(cNomePlanilha, cTituloPlanilha, "Armazen"                      , 1, 1, .F.)
	oExcel:AddColumn(cNomePlanilha, cTituloPlanilha, "Conta Contabil Produto"       , 1, 1, .F.)
	oExcel:AddColumn(cNomePlanilha, cTituloPlanilha, "Conta Contabil Inventario"    , 1, 1, .F.)
	oExcel:AddColumn(cNomePlanilha, cTituloPlanilha, "Centro Custo Despesa"         , 1, 1, .F.)
	oExcel:AddColumn(cNomePlanilha, cTituloPlanilha, "Item Contabil Despesa"        , 1, 1, .F.)
	oExcel:AddColumn(cNomePlanilha, cTituloPlanilha, "Classe Valor Despesa"         , 1, 1, .F.)

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

			While (oArquivo:HasLine())

				nLinhaAtual++
				IncProc("Analisando linha " + cValToChar(nLinhaAtual) + " de " + cValToChar(nTotalLinhas) + "...")

				cLinhaAtual := oArquivo:GetLine()
				aLinha      := Separa(cLinhaAtual, cSeparador)

				If ( Len(aLinha) > 0 .And. nLinhaAtual >= 2 )

					lGravaTabela      := .F.
					cStatus           := ""
					cUnidadeMedida	  := ""
					cDescProduto      := ""
					cTipoProduto      := ""
					cCtaContabil      := ""
					cCheckCtaCtb      := "" 
					cNumSeq           := ""
					cCodFilial        := aLinha[01]
					cCodigoProduto    := aLinha[02]
					cArmazem          := aLinha[03]
					cTm               := aLinha[04]   
					cCf               := aLinha[05]   
					cCtaContabil      := aLinha[06]
					cCentroCusto      := aLinha[07]
					cItemContabil     := aLinha[08]
					cClasseValor      := aLinha[09]
					cDocumento        := aLinha[10]
					dDataInventario   := StoD(aLinha[11])

					If ( AllTrim(Posicione("SB1",1,xFilial("SB1")+cCodigoProduto,"B1_COD")) == AllTrim(cCodigoProduto) )
						lGravaTabela   := .T.
						cUnidadeMedida := AllTrim(Posicione("SB1",1,xFilial("SB1")+cCodigoProduto,"B1_UM"))
						cDescProduto   := AllTrim(Posicione("SB1",1,xFilial("SB1")+cCodigoProduto,"B1_DESC"))
						cControlaEnd   := AllTrim(Posicione("SB1",1,xFilial("SB1")+cCodigoProduto,"B1_LOCALIZ"))
						cTipoProduto   := AllTrim(Posicione("SB1",1,xFilial("SB1")+cCodigoProduto,"B1_TIPO"))
						cCheckCtaCtb   := AllTrim(Posicione("SB1",1,xFilial("SB1")+cCodigoProduto,"B1_CONTA"))
						If (Alltrim(cCheckCtaCtb) == Alltrim(cCtaContabil))
							cCheckCtaCtb := Alltrim(cCtaContabil)
						Else 
							cCheckCtaCtb := Alltrim(cCheckCtaCtb)
						EndIf
					Else
						lGravaTabela   := .F.
						cStatus        := "Codigo de Produto Não Localizado"
					EndIf

					If ( lGravaTabela )
						If ( AllTrim(Posicione("NNR",1,xFilial("NNR")+cArmazem,"NNR_CODIGO")) == AllTrim(cArmazem) )
							lGravaTabela   := .T.
						Else
							lGravaTabela   := .F.
							cStatus        := "Armazen Não Localizado"
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

						If ( SB1->(dbSeek(xFilial("SB1") + cCodigoProduto )) )

							ProcRegua(0)
							IncProc("Adicionando produto " + Alltrim(SB1->B1_COD) + "...")

							BuscaIndiceMovimentacao(cCodFilial,; 
												    cCodigoProduto,;
												    cCf,; 
												    cTm,;
												    cArmazem,;
												    dDataInventario,;
												    cCheckCtaCtb,;
												    cCentroCusto,;
												    cItemContabil,;
												    cClasseValor,;
												    cCtaDespInvent)

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
																	Alltrim(cCodFilial),;
																	Alltrim(cCodigoProduto),;
																	Alltrim(cDescProduto),;
																	Alltrim(Dtos(dDataInventario)),;
																	Alltrim(cTipoProduto),;
																	Alltrim(cUnidadeMedida),;
																	Alltrim(cArmazem),;
																	Alltrim(cCheckCtaCtb),;
																	Alltrim(cCtaDespInvent),;
																	Alltrim(cCentroCusto),;
																	Alltrim(cItemContabil),;
																	Alltrim(cClasseValor)})
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
 	Retorna o indice tabela SD3
*/
Static Function BuscaIndiceMovimentacao(cCodFilial, cProduto, cCf, cTm, cLocal, dEmissao, cCheckCtaCtb,;
										cCentroCusto, cItemContabil, cClasseValor, cCtaDespInvent)

	Local aArea             := {}  as array
	Local aNumSeq           := {}  as array
	Local cAlias	        := ""  as character
	Local cQuery	        := ""  as character
	Local cQry  	        := ""  as character

	aArea      	            := GetArea()

	If ( !Empty(cAlias) )
		dbSelectArea(cAlias)
		(cAlias)->(dbCloseArea())
	EndIf

	cQuery               := QryMovimentoProduto(cCodFilial, cProduto, cCf, cTm, cLocal ,dEmissao)
	cAlias               := MpSysOpenQuery(cQuery)

	If ( !Empty(cAlias) )

		DbSelectArea(cAlias)

		DbSelectArea("SD3")
		SD3->(DbSetOrder(5)) 

		If ( (cAlias)->(!EOF()) )

			While (cAlias)->(!EOF())
				Begin Transaction

					cQry := ""
					cQry := " UPDATE " + RetSqlName("SD3") + CRLF
					cQry += "        SET D3_CONTA   = '" + cCheckCtaCtb   +"',  " + CRLF   
					cQry += "            D3_CC      = '" + cCentroCusto   +"',  " + CRLF   
					cQry += "            D3_ITEMCTA = '" + cItemContabil  +"',  " + CRLF
					cQry += "            D3_CLVL    = '" + cClasseValor   +"',  " + CRLF
					cQry += "            D3_XCTADES = '" + cCtaDespInvent +"'   " + CRLF
					cQry += " FROM                                         " + CRLF
					cQry += " 	   " + RetSqlTab("SD3")                      + CRLF
					cQry += "WHERE   1=1  " + CRLF
					cQry += "        AND D3_FILIAL  = " + ValToSql(cCodFilial) + " " + CRLF
					cQry += "        AND D3_COD     = " + ValToSql(cProduto)   + " " + CRLF
					cQry += "        AND D3_LOCAL   = " + ValToSql(cLocal)     + " " + CRLF
					cQry += "        AND D3_EMISSAO = " + ValToSql(Dtos(dEmissao))   + " " + CRLF
					cQry += "        AND D3_ESTORNO =  ' ' " + CRLF
					cQry += "        AND " + RetSqlDel("SD3") + CRLF

					If ( TcSQLExec(cQry) < 0 )
						ConOut(TcSQLError())
					Else
						TcSqlExec(cQry)
						lRet  := .T.
					EndIf

				End Transaction	

				(cAlias)->(dbSkip())
			Enddo

			(cAlias)->(DbCloseArea())
		EndIf
	EndIf

	RestArea(aArea)

Return(aNumSeq)

/*
    Query para retornar a movimentação
*/
Static Function QryMovimentoProduto(cCodFilial, cProduto, cCf, cTm, cLocal, dEmissao)
	Local cQuery         := ""  as character

	cQuery := "SELECT DISTINCT " + CRLF
	cQuery += "      D3_FILIAL  AS D3_FILIAL,  " + CRLF
	cQuery += "      D3_COD     AS D3_COD,     " + CRLF
	cQuery += "      D3_CF      AS D3_CF,      " + CRLF
	cQuery += "      D3_TM      AS D3_TM,      " + CRLF
	cQuery += "      D3_LOCAL   AS D3_LOCAL,   " + CRLF
	cQuery += "      D3_NUMSEQ  AS D3_NUMSEQ,  " + CRLF
	cQuery += "      D3_DOC     AS D3_DOC,     " + CRLF
	cQuery += "      D3_EMISSAO AS D3_EMISSAO  " + CRLF
	cQuery += "FROM  " + RetSqlTab("SD3") + " (NOLOCK)  " + CRLF
	cQuery += " 	   INNER JOIN " + CRLF
	cQuery += " 	              "+ RetSQLTab("SB1") +  CRLF
	cQuery += " 	              ON 1=1 " + CRLF
	cQuery += "      			  AND D3_COD = B1_COD " + CRLF
	cQuery += "      			  AND " + RetSqlDel("SB1") + CRLF
	cQuery += "WHERE   1=1  " + CRLF
	cQuery += "        AND D3_FILIAL  = " + ValToSql(cCodFilial) + " " + CRLF
	cQuery += "        AND D3_COD     = " + ValToSql(cProduto)   + " " + CRLF
	cQuery += "        AND D3_LOCAL   = " + ValToSql(cLocal)     + " " + CRLF
	cQuery += "        AND D3_EMISSAO = " + ValToSql(Dtos(dEmissao))   + " " + CRLF
	cQuery += "        AND D3_ESTORNO =  ' ' " + CRLF
	cQuery += "        AND " + RetSqlDel("SD3") + CRLF

	u_ChangeQuery("\sql\OZ04N98_QryMovimentoProduto.sql",@cQuery)

Return cQuery

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
