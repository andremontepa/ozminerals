/*
Função para importação das informações para estoques
Data: 12/2021
Autor: S GEDOLIN TEC

*/
#include 'Protheus.ch'
#include 'TOPConn.ch'
#include 'Rwmake.ch'
#include "TbiConn.ch"
#include "TbiCode.ch"        

User Function OAEST005()
	Local aArea  	:= GetArea()
	Local cTitulo	:= "Importação Cadastro de MRP"
	Local nOpcao 	:= 0
	Local aButtons 	:= {}
	Local aSays    	:= {}
	Local cPerg		:= Padr("FIMPSB1",10) 
	Private cArquivo:= ""
	Private oProcess
	Private lRenomear:= .F.
	Private lMsErroAuto := .F.

	ajustaSx1(cPerg)

	Pergunte(cPerg,.F.)

	AADD(aSays,OemToAnsi("Rotina para Importação de arquivo texto para tabela SZD - MRP"))
	AADD(aSays,"")
	AADD(aSays,OemToAnsi("Clique no botão PARAM para informar os parametros que deverão ser considerados."))
	AADD(aSays,"")
	AADD(aSays,OemToAnsi("Após isso, clique no botão OK."))

	AADD(aButtons, { 1,.T.,{|o| nOpcao:= 1,o:oWnd:End()} } )
	AADD(aButtons, { 2,.T.,{|o| nOpcao:= 2,o:oWnd:End()} } )
	AADD(aButtons, { 5,.T.,{| | pergunte(cPerg,.T.)  } } )

	FormBatch( cTitulo, aSays, aButtons,,200,530 )

	if nOpcao = 1
		cArquivo:= Alltrim(MV_PAR01)

		if Empty(cArquivo)
			MsgStop("Informe o nome do arquivo!!!","Erro")
			return
		Endif

		oProcess := MsNewProcess():New( { || Importa() } , "Importação de registros " , "Aguarde..." , .F. )
		oProcess:Activate()

	EndIf

	RestArea(aArea)

Return

Static Function Importa()
	Local cArqProc   := cArquivo+".processado"
	Local cLinha     := ""
	Local lPrim      := .T.
	Local aCampos    := {}
	Local aDados     := {}
	Local nCont		 := 1
	Local nPosCod    := 0
	Local aStrCpo	 := {}
	Local j
    Local i
	Private aErro 	 := {}

	If !File(cArquivo)
		MsgStop("O arquivo " + cArquivo + " não foi encontrado. A importação será abortada!","ATENCAO")
		Return
	EndIf

	FT_FUSE(cArquivo) //Abre o arquivo texto
	oProcess:SetRegua1(FT_FLASTREC()) //Preenche a regua com a quantidade de registros encontrados
	FT_FGOTOP() //coloca o arquivo no topo
	While !FT_FEOF()
		nCont++
		oProcess:IncRegua1('Validando Linha: ' + Alltrim(Str(nCont)))

		cLinha := FT_FREADLN()
		cLinha := ALLTRIM(cLinha)

		If lPrim //considerando que a primeira linha são os campos do cadastros, reservar numa variavel
			aCampos := Separa(cLinha,";",.T.)
			lPrim := .F.
		Else// gravar em outra variavel os registros
			AADD(aDados,Separa(cLinha,";",.T.))
		EndIf

		FT_FSKIP()
	EndDo

	FT_FUSE()

	//utilizaremos a aScan para localizar a posição dos campos na variavel que armazenará o nome dos campos
	nPosFil     := aScan(aCampos,{ |x| ALLTRIM(x) == "ZD_FILIAL" })
	nPosCod    	:= aScan(aCampos,{ |x| ALLTRIM(x) == "ZD_COD" })
	nPosLocal   := aScan(aCampos,{ |x| ALLTRIM(x) == "ZD_LOCAL" })
	cErro  := ''
	oProcess:SetRegua1(len(aDados)) //guardar novamente a quantidade de registros
	
	Begin Transaction
	
	For i:=1 to Len(aDados)

		oProcess:IncRegua1("Importando Produtos MRP..." + aDados[i,nPosFil] +" "+ aDados[i,nPosCod])

		aImporta := {}

		dbSelectArea("SB1")
		SB1->(dbSetOrder(1))
		If SB1->(dbSeek(xFilial("SB1") + aDados[i,nPosCod]) )
		
			dbSelectArea("SZD")
			SZD->(dbSetOrder(1))
			If SZD->(dbSeek( PadR(alltrim(aDados[i,nPosFil]),TamSx3("ZD_FILIAL")[1]) +;
							 PadR(alltrim(aDados[i,nPosCod]),TamSx3("ZD_COD")[1]) +;
							 PadR(alltrim(aDados[i,nPosLocal]),TamSx3("ZD_LOCAL")[1]) ) )
				Reclock("SZD",.F.)
			Else
				Reclock("SZD",.T.)
			EndIf
			
			oProcess:SetRegua2(len(aCampos))
			For j:=1 to Len(aCampos)
					
				oProcess:IncRegua2('Processando coluna: ' + ALLTRIM(aCampos[j]))
				//Iremos verificar também se o campo existe, para evitar erros durante a importação
				//É importante tambem, validar o tipo que o campo é, pois quando importa um arquivo texto, o conteudo também será texto
						
				cCampo  := "SZD->" + aCampos[j]
				aStrCpo := FWSX3Util():GetFieldStruct(Alltrim(aCampos[j]))
				If Len(aStrCpo) > 0
					Do Case
						Case aStrCpo[2] == 'N' //Numerico
							&cCampo := Val(StrTran(StrTran(Alltrim(aDados[i,j]),".",""),",","."))
						Case aStrCpo[2] == 'D' //Data
							&cCampo := CTOD(aDados[i,j]) 
						Otherwise //Outros
							&cCampo := Alltrim(aDados[i,j])
					EndCase
				EndIf 
			Next j
	
			SZD->(MsUnlock())
				
		Else //Caso o registro exista, gravar o log
			GravaErro(aDados[i,nPosCod],aDados[i,nPosFil],"O Produto Nâo Existe!!")
		EndIf
		
	Next i
	
	End Transaction
	
	IF(MV_PAR02==1)
		If File(cArqProc)
			fErase(cArqProc)
		Endif
		fRename(Upper(cArquivo), cArqProc)
	Endif	

	If Len(aErro) > 0
		MostraLog()
	Else
		ApMsgInfo("Importação de MRP efetuada com sucesso!","SUCESSO")
	EndIf

Return()

Static Function GravaErro(cCod,xcFilial,cMsg)

	Local cFile := "\SYSTEM\"+FUNNAME()+".LOG"
	Local cLine := ""

    cMsg := 'Erro ExecAuto Produto '+cCod
	AADD(aErro,{cCod,xcFilial,cMsg})

Return()

Static Function MostraLog()

	Local oDlg
	Local oFont
	Local cMemo := ""

	DEFINE FONT oFont NAME "Courier New" SIZE 5,0

	DEFINE MSDIALOG oDlg TITLE "Importação Cadastros" From 3,0 to 400,417 PIXEL

	aCabec := {"Código","Filial"}
	cCabec := "{aErro[oBrw:nAT][1],aErro[oBrw:nAT][2]}"
	bCabec :=  &( "{ || " + cCabec + " }" )

	oBrw := TWBrowse():New( 005,005,200,090,,aCabec,,oDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
	oBrw:SetArray(aErro)
	oBrw:bChange    := { || cMemo := aErro[oBrw:nAT][3], oMemo:Refresh()}
	oBrw:bLDblClick := { || cMemo := aErro[oBrw:nAT][3], oMemo:Refresh()}
	oBrw:bLine := bCabec

	@ 100,005 GET oMemo VAR cMemo MEMO SIZE 200,080 OF oDlg PIXEL

	oMemo:bRClicked := {||AllwaysTrue()}
	oMemo:lReadOnly := .T.
	oMemo:oFont := oFont

	oImprimir :=tButton():New(185,120,'Imprimir' ,oDlg,{|| fImprimeLog() },40,12,,,,.T.)
	oSair     :=tButton():New(185,165,'Sair'     ,oDlg,{|| ::End() },40,12,,,,.T.)

	ACTIVATE MSDIALOG oDlg CENTERED

Return()

Static Function fImprimeLog()

	Local oReport

	If TRepInUse()	//verifica se relatorios personalizaveis esta disponivel
		oReport := ReportDef()
		oReport:PrintDialog()
	EndIf

Return()

Static Function ReportDef()

	Local oReport
	Local oSection

	oReport := TReport():New(FUNNAME(),"Importação Cadastro de Produtos MRP",,{|oReport| PrintReport(oReport)},"Este relatorio ira imprimir a relacao de erros encontrados durante o processo de importação dos dados.")
	oReport:SetLandscape()

	oSection := TRSection():New(oReport,,{})

	TRCell():New(oSection,"CODIGO"  ,,"Código")
	TRCell():New(oSection,"Filial"  ,,"Filial")
	TRCell():New(oSection,"DESCRI"  ,,"Descrição do Erro")

Return oReport

Static Function PrintReport(oReport)

	Local oSection := oReport:Section(1)
	Local nCurrentLine, i

	oReport:SetMeter(Len(aErro))

	oSection:Init()

	For i:=1 to Len(aErro)

		If oReport:Cancel()
			Exit
		EndIf

		oReport:IncMeter()

		oSection:Cell("CODIGO"):SetValue(aErro[i,1])
		oSection:Cell("CODIGO"):SetSize(20)
		oSection:Cell("FILIAL"):SetValue(aErro[i,2])
		oSection:Cell("FILIAL"):SetSize(20)
		oSection:Cell("DESCRI"):SetValue(aErro[i,3])
		oSection:Cell("DESCRI"):SetSize(200)

		nTamLin := 200
		nTab := 3
		lWrap := .T.

		lPrim := .T.

		cObsMemo := aErro[i,3]
		nLines   := MLCOUNT(cObsMemo, nTamLin, nTab, lWrap)

		For nCurrentLine := 1 to nLines
			If lPrim
				oSection:Cell("DESCRI"):SetValue(MEMOLINE(cObsMemo, nTamLin, nCurrentLine, nTab, lWrap))
				oSection:Cell("DESCRI"):SetSize(300)
				oSection:PrintLine()
				lPrim := .F.
			Else
				oSection:Cell("CODIGO"):SetValue("")
				oSection:Cell("FILIAL"):SetValue("")
				oSection:Cell("DESCRI"):SetValue(MEMOLINE(cObsMemo, nTamLin, nCurrentLine, nTab, lWrap))
				oSection:Cell("DESCRI"):SetSize(300)
				oSection:PrintLine()
			EndIf
		Next i

		oReport:SkipLine()
	Next i

	oSection:Finish()

Return()

/*/{Protheus.doc} ajustaSx1
Criacao das Perguntas da Rotina tipo Parambox. 
@type function
@author Ricardo Tavares Ferreira
@since 08/06/2023
@version 12.1.2210
@return logical, Retorna logico se confirmou os paramtros.
@history 08/06/2023, Ricardo Tavares Ferreira, Construção Inicial.
/*/
//====================================================================================================
	Static Function ajustaSx1(cPerg)
//====================================================================================================

    Local aPergs	    := {}
    Local aRet		    := {}
    Local lRet		    := .T.
	Local aRenomear     := {"Sim","Não"}

    Private cCadastro   := "Perguntas"

    aadd(aPergs,{6 , "Local do Arquivo" , Padr("",300),"",".T.","",80,.T.,""/*"Arquivos CSV |*.csv"*/,"",GETF_LOCALHARD+GETF_NETWORKDRIVE}) // MV_PAR01
    aadd(aPergs,{3 , "Renomear"         ,1,aRenomear                                  ,150,"",.T.}) // MV_PAR02

	If .not. ParamBox(aPergs,"Arquivo",aRet,/*bValid*/,/*aButtons*/,.T.,/*nPosX*/,/*nPosY*/,/*oDialog*/,"OAEST005",.T.,.T.)
		lRet := .F.
	EndIf 
Return lRet
