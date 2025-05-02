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

/*/{Protheus.doc} OZ34M10

	Rotina atualizar Cadastro CONTA CONTABIL Argo 

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
User Function OZ34M10()
	Local aSays        		      := {}  as array
	Local aButtons     		      := {}  as array
	Local nOpca        		      := 0   as numeric
	Local cTitoDlg     		      := ""  as character

	Private cSeparador            := ""  as character

	cSeparador                    := AllTrim(GetNewPar("OZ_DELIMIT",";"))

	cTitoDlg    	              := "OZMinerals - Cadastro Conta Contabil Argo"

	aAdd(aSays, "Esta rotina tem por objetivo dar carga no Cadastro do Argo Conta Contabil!")
	aAdd(aSays, "Será Gravado Conta Contabil que estra cadstrada no ARGO!")
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
	Local cNomeErro          := ""  as character
	Local cTextoErro         := ""  as character
	Local cLog               := ""  as character
	Local cArquivoDestino    := ""  as character
	Local cNomePlanilha      := ""  as character
	Local cTituloPlanilha    := ""  as character
	Local cNomeWork          := ""  as character
	Local cStatus            := ""  as character
	Local cCodID             := ""  as character
	Local cCodContaArgo      := ""  as character 
	Local cDescContaArgo     := ""  as character 
	Local cDescEmpArgo       := ""  as character 
	Local c01Argo            := ""  as character
	Local c02Argo            := ""  as character
	Local c03Argo            := ""  as character
	Local c04Argo            := ""  as character
	Local c05Argo            := ""  as character
	Local c06Argo            := ""  as character
	Local c07Argo            := ""  as character
	Local c08Argo            := ""  as character

	cDiretorioTmp            := GetTempPath()
	cArquivoLog              := "importacao_" + dToS(Date())
	cArquivoLog              += "_" + StrTran(Time(), ":", "-") + ".log"
	cPastaErro               := "\CRM\"
	cArquivoDestino          := "C:\TOTVS\OZIMP02ARGO_EMP_" + SM0->M0_CODIGO
	cArquivoDestino          += "_" + Dtos(dDataBase) + StrTran(Time(),":","") + ".XML"
	cNomePlanilha            := "Empresa_" + Rtrim(SM0->M0_NOME)
	cNomeWork                := "Empresa_" + Rtrim(SM0->M0_NOME)
	cTituloPlanilha          := "OzMInerals - Cadastro Centro Custo Argo  - Ajustados conforme Layout"
	oExcel                   := FWMsExcelEX():New()

	oExcel:AddworkSheet(cNomeWork)
	oExcel:AddTable(cNomePlanilha , cTituloPlanilha)
	oExcel:AddColumn(cNomePlanilha, cTituloPlanilha, "Status Atualizacao"     , 1, 1, .F.)
	oExcel:AddColumn(cNomePlanilha, cTituloPlanilha, "Filial Protheus"        , 1, 1, .F.)
	oExcel:AddColumn(cNomePlanilha, cTituloPlanilha, "Codigo ID"              , 1, 1, .F.)
	oExcel:AddColumn(cNomePlanilha, cTituloPlanilha, "Cod. Empresa Protheus"  , 1, 1, .F.)
	oExcel:AddColumn(cNomePlanilha, cTituloPlanilha, "Cod. Filial  Protheus"  , 1, 1, .F.)
	oExcel:AddColumn(cNomePlanilha, cTituloPlanilha, "Conta Contabil"         , 1, 1, .F.)
	oExcel:AddColumn(cNomePlanilha, cTituloPlanilha, "Desc. Conta Contabil"   ,1 , 1, .F.)

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
					cCodID             := aLinha[01]
					cCodContaArgo      := aLinha[02]
					cContaContabil     := aLinha[03]
					cDescContaArgo     := aLinha[04]
					cEmpresa           := aLinha[05]
					cCodigoFilial      := aLinha[06]
					cDescEmpArgo       := aLinha[07]

					If (!Empty(cContaContabil))
						If ( AllTrim(Posicione("CT1",1,xFilial("CT1")+cContaContabil,"CT1_CONTA")) == AllTrim(cContaContabil) )
							lGravaTabela   := .T.
						Else
							lGravaTabela   := .F.
							cStatus        := "Conta Contabil Não Localizado"
							lAbre          := .T.
						EndIf
					EndIf

					If ( lGravaTabela )

						cStatus   := REGISTRO_ATUALIZADO
						c01Argo   := AllTrim(cCodID)
						c02Argo   := AllTrim(cCodContaArgo) 
						c03Argo   := AllTrim(cContaContabil) 
						c04Argo   := AllTrim(cDescContaArgo)
						c05Argo   := AllTrim(cEmpresa)
						c06Argo   := AllTrim(cCodigoFilial)
						c07Argo   := AllTrim(cDescEmpArgo)
						c08Argo   := AllTrim(Posicione("CT1",1,xFilial("CT1")+cContaContabil,"CT1_DESC01")) 

						dbSelectArea("PAL")
						PAL->(dbSetOrder(1))
						If ( PAL->(dbSeek(PAD(xFilial("PAL") ,TAMSX3("PAL_FILIAL") [1]) +; 
										  PAD(c01Argo        ,TAMSX3("PAL_ID")     [1]) )))
							lReckLock := .F.
						Else 
							lReckLock := .T.
						EndIf
			
						If ( lReckLock )
							Begin Transaction
								PAK->(RecLock("PAL",lReckLock))
									PAL->PAL_FILIAL := xFilial("PAL")
									PAL->PAL_ID     := c01Argo
									PAL->PAL_EMP    := c05Argo
									PAL->PAL_FIL    := c06Argo
									PAL->PAL_CODCTA := c02Argo
									PAL->PAL_DSCARG := c04Argo
									PAL->PAL_CONTA  := c03Argo
									PAL->PAL_DSCCTA := c08Argo
									PAL->PAL_MSBLQL := "2"
								PAL->(MsUnlock())
							End Transaction
						EndIf
						lPermiteExecutar := .F.
						lAbre := .T.
					EndIf
				Else 
					cStatus        := "Registro Não Localizado" 
					lAbre := .T.
				EndIf

				If ( lAbre )

					oExcel:AddRow(cNomePlanilha, cTituloPlanilha,{  Alltrim(cStatus),;
																	xFilial("PAL"),;
																	c01Argo,;
																	c05Argo,;
																	c06Argo,;
																	c03Argo,;
																	c08Argo})
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
