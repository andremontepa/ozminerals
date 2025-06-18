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

/*/{Protheus.doc} OZ04C99

	Rotina para incluir custo tabela SDQ

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
User Function OZ04C99()
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
	cTitoDlg    	         := "Manutenção Valores - OzMinerals"
	cSeparador               := AllTrim(GetNewPar("OZ_DELIMIT",";"))

	aAdd(aSays, "Esta rotina tem por objetivo incluir as valores referente ao inventario")
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
	local aItem             := {}  as array
	Local nTotalLinhas      := 0   as numeric
	Local nLinhaAtual       := 0   as numeric
	Local nVlrCm1	        := 0   as integer
	Local nVlrCm2	        := 0   as integer
	Local nSeqInvent        := 0   as integer
	Local cNumSeq           := 0   as integer
	Local lAbre             := .F. as logical
	Local lGravaTabela      := .T. as logical
	Local lReckLock         := .F. as logical
	Local cCodFilial        := ""  as Character
	Local cArmazem          := ""  as Character
	Local dDataInventario   := ""  as Character
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
	Local cDescProduto      := ""  as character
	Local cControlaEnd      := ""  as character

	Private lMsErroAuto     := .F. as logical

	cDiretorioTmp           := GetTempPath()
	cArquivoLog             := "importacao_" + dToS(Date())
	cArquivoLog             += "_" + StrTran(Time(), ":", "-") + ".log"
	cPastaErro              := "\CRM\"
	cArquivoDestino         := "C:\TOTVS\OZINVESTVLR_EMP_" + SM0->M0_CODIGO
	cArquivoDestino         += "_" + Dtos(dDataBase) + StrTran(Time(),":","") + ".XML"
	cNomePlanilha           := "Empresa_" + Rtrim(SM0->M0_NOME)
	cNomeWork               := "Empresa_" + Rtrim(SM0->M0_NOME)
	cTituloPlanilha         := "OzMInerals - Manutenção Valor Inventario Layout"
	cDataEmissao	        := Substr(Dtos(ddatabase),7,2)
	cDataEmissao	  	    += "/" + Substr(Dtos(ddatabase),5,2)
	cDataEmissao   		    += "/" + Substr(Dtos(ddatabase),1,4)
	dDataInventario         := CtoD("")
	dDataInventario         := dDatabase
	oExcel                  := FWMsExcelEX():New()

	oExcel:AddworkSheet(cNomeWork)
	oExcel:AddTable(cNomePlanilha , cTituloPlanilha)
	oExcel:AddColumn(cNomePlanilha, cTituloPlanilha, "Status Atualizacao"           , 1, 1, .F.)
	oExcel:AddColumn(cNomePlanilha, cTituloPlanilha, "Codigo Produto"               , 1, 1, .F.)
	oExcel:AddColumn(cNomePlanilha, cTituloPlanilha, "Descrição Produto"            , 1, 1, .F.)
	oExcel:AddColumn(cNomePlanilha, cTituloPlanilha, "Data Movimentação"            , 1, 1, .F.)
	oExcel:AddColumn(cNomePlanilha, cTituloPlanilha, "Tipo Produto"                 , 1, 1, .F.)
	oExcel:AddColumn(cNomePlanilha, cTituloPlanilha, "Unidade medida"               , 1, 1, .F.)
	oExcel:AddColumn(cNomePlanilha, cTituloPlanilha, "Armazen"                      , 1, 1, .F.)
	oExcel:AddColumn(cNomePlanilha, cTituloPlanilha, "Valor M1"  		            , 1, 2, .F.)
	oExcel:AddColumn(cNomePlanilha, cTituloPlanilha, "Valor M2"                     , 1, 2, .F.)

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

			DbSelectArea("SDQ")
			SDQ->(DbSetOrder(1))

			cNumSeq := ProxNum()

			While (oArquivo:HasLine())

				nLinhaAtual++
				IncProc("Analisando linha " + cValToChar(nLinhaAtual) + " de " + cValToChar(nTotalLinhas) + "...")

				cLinhaAtual := oArquivo:GetLine()
				aLinha      := Separa(cLinhaAtual, cSeparador)

				If ( Len(aLinha) > 0 .And. nLinhaAtual >= 2 )

					lGravaTabela      := .F.
					lReckLock         := .F.
					lMsErroAuto       := .F.
					cStatus           := ""
					cUnidadeMedida	  := ""
					cDescProduto      := ""
					cControlaEnd      := ""
					cTipoProduto      := ""
					aItem             := {}
					cCodFilial        := aLinha[01]
					cCodigoProduto    := aLinha[02]
					cArmazem          := aLinha[03]
					dDataInventario   := StoD(aLinha[04])
					nVlrCm1      	  := Val(StrTran(StrTran(aLinha[05],";",""),",", "."))
					nVlrCm2           := (nVlrCm1*5.43)

					If ( AllTrim(Posicione("SB1",1,xFilial("SB1")+cCodigoProduto,"B1_COD")) == AllTrim(cCodigoProduto) )
						lGravaTabela   := .T.
						cUnidadeMedida := AllTrim(Posicione("SB1",1,xFilial("SB1")+cCodigoProduto,"B1_UM"))
						cDescProduto   := AllTrim(Posicione("SB1",1,xFilial("SB1")+cCodigoProduto,"B1_DESC"))
						cTipoProduto   := AllTrim(Posicione("SB1",1,xFilial("SB1")+cCodigoProduto,"B1_TIPO"))
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

					If ( lGravaTabela )
						If ( AllTrim(Posicione("SAH",1,xFilial("SAH")+cUnidadeMedida,"AH_UNIMED")) == AllTrim(cUnidadeMedida) )
							lGravaTabela   := .T.
						Else
							lGravaTabela   := .F.
							cStatus        := "Unidade de Medida Não Localizado"
						EndIf
					EndIf

					If ( lGravaTabela )

						nSeqInvent := 0
						If ( SB1->(dbSeek(xFilial("SB1") + cCodigoProduto )) )

							ProcRegua(0)
							IncProc("Adicionando produto " + Alltrim(SB1->B1_COD) + "...")
							If (SDQ->(DbSeek(xFilial("SDQ") + cCodigoProduto + cArmazem + DtoS(dDataInventario) )))
								lReckLock := .F.
							Else
								lReckLock := .T.
							EndIf

							If (lReckLock) 
								Begin Transaction
									AAdd(aItem,{"DQ_COD"  ,cCodigoProduto  ,Nil})
									AAdd(aItem,{"DQ_LOCAL",cArmazem        ,Nil})
									AAdd(aItem,{"DQ_DATA" ,dDataInventario ,Nil})
									AAdd(aItem,{"DQ_CM1"  ,nVlrCm1         ,Nil})
									AAdd(aItem,{"DQ_CM2"  ,nVlrCm2         ,Nil})
									AAdd(aItem,{"DQ_CM3"  ,0               ,Nil})
									AAdd(aItem,{"DQ_CM4"  ,0               ,Nil})

									MSExecAuto({|x,y,z| MATA338(x,y)},aItem,3)
									If ( !lMsErroAuto )
										cStatus    := REGISTRO_ATUALIZADO
										cLog       += "+ Sucesso no Execauto na linha " + cValToChar(nLinhaAtual) + ";" + CRLF

										ShowLogInConsole(cLog)
									Else
										cStatus    := REGISTRO_NAO_ATUALIZADO
										cLog       += "+ Sucesso no Execauto na linha " + cValToChar(nLinhaAtual) + ";" + CRLF

										ShowLogInConsole(cLog)
									EndIf
								End Transaction
							Else 
								cStatus    := "Registro Já Atualizado"
								cLog       += "+ Sucesso no Execauto na linha " + cValToChar(nLinhaAtual) + ";" + CRLF

								ShowLogInConsole(cLog)
							EndIf
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
																	Alltrim(cDataEmissao),;
																	Alltrim(cTipoProduto),;
																	Alltrim(cUnidadeMedida),;
																	Alltrim(cArmazem),;
																	nVlrCm1,;
																	nVlrCm2})
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
