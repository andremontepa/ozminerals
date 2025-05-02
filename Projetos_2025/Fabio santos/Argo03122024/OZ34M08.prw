#include "protheus.ch"
#include "Totvs.ch"
#include "Tbiconn.ch"
#include "ozminerals.ch"

#define OZ_FILIAL_01    		    "01"
#define OZ_FILIAL_02    		    "02"
#define OZ_FILIAL_03    		    "03"
#define OZ_FILIAL_04    		    "04"
#define OZ_FILIAL_05    		    "05"
#define OZ_FILIAL_06    		    "06"
#define OZ_FILIAL_07    		    "07"
#define OZ_FILIAL_08    		    "08"

#define REGISTRO_ATUALIZADO         "Registro Atualizado"
#define REGISTRO_NAO_ATUALIZADO     "Registro Não Atualizado"

#define GRAVA_FLAG  				"1"

#define STATUS_RECORD    		     1
#define STATUS_NO_RECORD 		     2

/*/{Protheus.doc} OZ34M08

	Rotina atualizar as contas contabeis do de/para ARGO 

@type Function
@author Fabio Santos - CRM Service
@since 13/08/2024
@version P12
@database MSSQL

@Obs 
	Parametro OZ_DELIMIT contem o delimitar utilizado no layout.
	Como default esta preenchido com ponto e virgula (;) 

@see OZGEN18

@nested-tags:Frameworks/OZminerals
/*/
User Function OZ34M08()
	Local aSays        		      := {}  as array
	Local aButtons     		      := {}  as array
	Local nOpca        		      := 0   as numeric
	Local cTitoDlg     		      := ""  as character

	Private cSeparador            := ""  as character

	cSeparador                    := AllTrim(GetNewPar("OZ_DELIMIT",";"))

	cTitoDlg    	              := "Atualizar as contas contabeis de/para ARGO"

	aAdd(aSays, "Esta rotina tem por objetivo no processo de/para ARGO!")
	aAdd(aSays, "Será Gravado Centro de Custo, Item contabil, Classe Valor, Conta a credito e debito!")
	aAdd(aSays, "Esta rotina importa arquivo em formato  ( .txt ou .csv ) !")
	aAdd(aSays, "O delimitador utlizado é ("+cSeparador+") ")

	aAdd(aButtons,{STATUS_RECORD   , .T., {|o| nOpca := STATUS_RECORD   , FechaBatch()}})
	aAdd(aButtons,{STATUS_NO_RECORD, .T., {|o| nOpca := STATUS_NO_RECORD, FechaBatch()}})

	FormBatch(cTitoDlg, aSays, aButtons)

	If ( nOpca == STATUS_RECORD )
		ExecutaImportacaodePara()
	EndIf

Return

/*
    Função que chama a importação para o sistema
*/
Static Function ExecutaImportacaodePara()
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
	lOCAL lReckLock          := .F. as logical
	Local cDiretorioTmp      := ""  as character
	Local cArquivoLog        := ""  as character
	Local cLinhaAtual        := ""  as character
	Local cCodigoFilial      := ""  as character
	Local cItemContabil      := ""  as character
	Local cClasseValor       := ""  as character
	Local cNomeErro          := ""  as character
	Local cTextoErro         := ""  as character
	Local cLog               := ""  as character
	Local cArquivoDestino    := ""  as character
	Local cNomePlanilha      := ""  as character
	Local cTituloPlanilha    := ""  as character
	Local cNomeWork          := ""  as character
	Local cStatus            := ""  as character
	Local cCentroCusto       := ""  as character
	Local cDebContaContabil  := ""  as character
	Local cCredContaContabil := ""  as character
	Local c01Custo  		 := ""  as character
	Local c02Desc   		 := ""  as character
	Local c03Item   		 := ""  as character
	Local c04Desc   		 := ""  as character
	Local c05Clvl   		 := ""  as character
	Local c06Desc   		 := ""  as character
	Local c07CtaDeb 		 := ""  as character
	Local c08Desc   		 := ""  as character
	Local c09CtaCrd 		 := ""  as character
	Local c10Desc   		 := ""  as character

	cDiretorioTmp            := GetTempPath()
	cArquivoLog              := "importacao_" + dToS(Date())
	cArquivoLog              += "_" + StrTran(Time(), ":", "-") + ".log"
	cPastaErro               := "\CRM\"
	cArquivoDestino          := "C:\TOTVS\OZIMP01ARGO_EMP_" + SM0->M0_CODIGO
	cArquivoDestino          += "_" + Dtos(dDataBase) + StrTran(Time(),":","") + ".XML"
	cNomePlanilha            := "Empresa_" + Rtrim(SM0->M0_NOME)
	cNomeWork                := "Empresa_" + Rtrim(SM0->M0_NOME)
	cTituloPlanilha          := "OzMInerals - De Para Processo Argo - Ajustados conforme Layout"
	oExcel                   := FWMsExcelEX():New()

	oExcel:AddworkSheet(cNomeWork)
	oExcel:AddTable(cNomePlanilha , cTituloPlanilha)
	oExcel:AddColumn(cNomePlanilha, cTituloPlanilha, "Status Atualizacao"     , 1, 1, .F.)
	oExcel:AddColumn(cNomePlanilha, cTituloPlanilha, "Codigo Filial"          , 1, 1, .F.)
	oExcel:AddColumn(cNomePlanilha, cTituloPlanilha, "Centro de Custo"        , 1, 1, .F.)
	oExcel:AddColumn(cNomePlanilha, cTituloPlanilha, "Desc. Centro de Custo"  , 1, 1, .F.)
	oExcel:AddColumn(cNomePlanilha, cTituloPlanilha, "Item Contabil"          , 1, 1, .F.)
	oExcel:AddColumn(cNomePlanilha, cTituloPlanilha, "Desc. Item Contabil"    , 1, 1, .F.)
	oExcel:AddColumn(cNomePlanilha, cTituloPlanilha, "Classe de Valor"        , 1, 1, .F.)
	oExcel:AddColumn(cNomePlanilha, cTituloPlanilha, "Desc. Classe de Valor"  , 1, 1, .F.)
	oExcel:AddColumn(cNomePlanilha, cTituloPlanilha, "Conta Contabil Debito"  , 1, 1, .F.)
	oExcel:AddColumn(cNomePlanilha, cTituloPlanilha, "Desc. C.Contabil Deb."  , 1, 1, .F.)
	oExcel:AddColumn(cNomePlanilha, cTituloPlanilha, "Conta Contabil Credito" , 1, 1, .F.)
	oExcel:AddColumn(cNomePlanilha, cTituloPlanilha, "Desc. C.Contabil Cred." , 1, 1, .F.)

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
					lAchouEmpresa      := .F.
					cEmpresa           := aLinha[01]
					cCodigoFilial      := aLinha[02]
					cCentroCusto       := aLinha[03]
					cItemContabil      := aLinha[04]
					cClasseValor       := aLinha[05]
					cDebContaContabil  := aLinha[06]
					cCredContaContabil := aLinha[07]

					If (!Empty(cDebContaContabil))
						If ( AllTrim(Posicione("CT1",1,xFilial("CT1")+cDebContaContabil,"CT1_CONTA")) == AllTrim(cDebContaContabil) )
							lGravaTabela   := .T.
						Else
							lGravaTabela   := .F.
							cStatus        := "Conta Contabil Debito Não Localizado"
							lAbre          := .T.
						EndIf
					EndIf

					If (!Empty(cCredContaContabil))
						If ( lGravaTabela )
							If ( AllTrim(Posicione("CT1",1,xFilial("CT1")+cCredContaContabil,"CT1_CONTA")) == AllTrim(cCredContaContabil) )
								lGravaTabela   := .T.
							Else
								lGravaTabela   := .F.
								cStatus        := "Conta Contabil Credito Não Localizado"
								lAbre          := .T.
							EndIf
						EndIf
					EndIf

					If (!Empty(cCentroCusto))
						If ( lGravaTabela )
							If ( AllTrim(Posicione("CTT",1,xFilial("CTT")+cCentroCusto,"CTT_CUSTO")) == AllTrim(cCentroCusto) )
								lGravaTabela   := .T.
							Else
								lGravaTabela   := .F.
								cStatus        := "Centro de Custo Não Localizado"
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

						cStatus   := REGISTRO_ATUALIZADO
						c01Custo  := AllTrim(cCentroCusto)
						c02Desc   := AllTrim(Posicione("CTT",1,xFilial("CTT")+cCentroCusto ,"CTT_DESC01"))
						c03Item   := AllTrim(cItemContabil)
						c04Desc   := AllTrim(Posicione("CTD",1,xFilial("CTD")+cItemContabil,"CTD_DESC01"))
						c05Clvl   := AllTrim(cClasseValor)
						c06Desc   := AllTrim(Posicione("CTH",1,xFilial("CTH")+cClasseValor ,"CTH_DESC01"))
						c07CtaDeb := AllTrim(cDebContaContabil)
						c08Desc   := AllTrim(Posicione("CT1",1,xFilial("CT1")+cDebContaContabil ,"CT1_DESC01"))
						c09CtaCrd := AllTrim(cCredContaContabil)
						c10Desc   := AllTrim(Posicione("CT1",1,xFilial("CT1")+cCredContaContabil,"CT1_DESC01"))

						dbSelectArea("PAJ")
						PAJ->(dbSetOrder(1))
						If ( PAJ->(dbSeek(  PAD(xFilial("PAJ") ,TAMSX3("PAJ_FILIAL") [1]) +;
											PAD(c01Custo       ,TAMSX3("PAJ_CC")     [1]) +;
											PAD(c03Item        ,TAMSX3("PAJ_ITEM")   [1]) +;
											PAD(c05Clvl        ,TAMSX3("PAJ_CLVL")   [1]) +;
											PAD(c07CtaDeb      ,TAMSX3("PAJ_CTAD")   [1]) +;
											PAD(c09CtaCrd      ,TAMSX3("PAJ_CTAC")   [1]) )))
							lReckLock := .F.
						Else
							lReckLock := .T.
						EndIf

						If ( lReckLock )
							Begin Transaction
								PAJ->(RecLock("PAJ",lReckLock))
									PAJ->PAJ_FILIAL := xFilial("PAJ")
									PAJ->PAJ_CC     := c01Custo
									PAJ->PAJ_CCDSC  := c02Desc
									PAJ->PAJ_ITEM   := c03Item
									PAJ->PAJ_ITDSC  := c04Desc
									PAJ->PAJ_CLVL   := c05Clvl
									PAJ->PAJ_CLDSC  := c06Desc
									PAJ->PAJ_CTAD   := c07CtaDeb
									PAJ->PAJ_CTDSCD := c08Desc
									PAJ->PAJ_CTAC   := c09CtaCrd
									PAJ->PAJ_CTDSCC := c10Desc
									PAJ->PAJ_MSBLQL := "2"
								PAJ->(MsUnlock())
							End Transaction
						EndIf
						lPermiteExecutar := .F.
						lAbre := .T.
					EndIf

					If ( lAbre )

						oExcel:AddRow(cNomePlanilha, cTituloPlanilha,{  Alltrim(cStatus),;
																		xFilial("PAJ"),;
																		c01Custo,;
																		c02Desc,;
																		c03Item,;
																		c04Desc,;
																		c05Clvl,;
																		c06Desc,;
																		c07CtaDeb,;
																		c08Desc,;
																		c09CtaCrd,;
																		c10Desc})
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
