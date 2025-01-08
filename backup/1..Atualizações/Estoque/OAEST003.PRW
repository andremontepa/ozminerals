/*
Função para importação do cadastro de produtos
Data: 12/2021
Autor: S GEDOLIN TEC

*/

#include 'Protheus.ch'
#include 'TOPConn.ch'
#include 'Rwmake.ch'
#include "TbiConn.ch"
#include "TbiCode.ch"        

User Function OAEST003()
	Local aArea  	:= GetArea()
	Local cTitulo	:= "Importação Cadastro de Produtos"
	Local nOpcao 	:= 0
	Local aButtons 	:= {}
	Local aSays    	:= {}
	Local cPerg		:= Padr("FIMPSB1",10) 
	Private cArquivo:= ""
	Private oProcess
	Private lRenomear:= .F.
	Private lMsErroAuto := .F.

	ajustaSx1(cPerg)

	//Pergunte(cPerg,.F.)

	AADD(aSays,OemToAnsi("Rotina para Importação de arquivo texto para tabela SB1 - Produtos"))
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
	Local cArqProc  := cArquivo+".processado"
	Local cLinha    := ""
	Local lPrim     := .T.
	Local aCampos   := {}
	Local aDados    := {}
	Local nCont		:= 1
	Local nPosCod   := 0
	Local j
    Local i
	Local nTpMov	:= 3
	Local lFlagImp	:= .T.
	Local aStrCpo	:= {}
	
	Private aErro 	 := {}
	private lMsErroAuto := .F.
	
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
	//nPosFil     := aScan(aCampos,{ |x| ALLTRIM(x) == "B1_FILIAL" })
	nPosCod    	:= aScan(aCampos,{ |x| ALLTRIM(x) == "B1_COD" })
	nPosDesc  	:= aScan(aCampos,{ |x| ALLTRIM(x) == "B1_DESC" })	
	nPosNCM    	:= aScan(aCampos,{ |x| ALLTRIM(x) == "B1_POSIPI" })
	nPosEsp		:= aScan(aCampos,{ |x| ALLTRIM(x) == "B1_ESPECIF" })

	oProcess:SetRegua1(len(aDados)) //guardar novamente a quantidade de registros

	//Validando o NCM
	for i:= 1 to len(aDados)

		if empty(aDados[i,nPosCod])
			SYD->(DbSetOrder(1))
			if !SYD->(dbSeek(xFilial("SYD")+aDados[i,nPosNCM]))

				GravaErro(aDados[i,nPosNCM],"NCM Não Cadastrado", aDados[i,nPosNCM]+" "+alltrim(aDados[i,nPosDesc]))
				lFlagImp := .F.
			endif
		endif

	Next

	if lFlagImp

		For i:=1 to Len(aDados)

			if empty(aDados[i,nPosCod])
				oProcess:IncRegua1("Importando Produtos..." + aDados[i,nPosDesc] )
			else
				oProcess:IncRegua1("Importando Produtos..." + aDados[i,nPosCod] )
			endif

			aImporta := {}

			dbSelectArea("SB1")
			SB1->(dbSetOrder(1)) // filial + produto
			If SB1->(dbSeek( xFilial("SB1") +;
							PadR(alltrim(aDados[i,nPosCod]),TamSx3("B1_COD")[1])))
				nTpMov := 4
			else
				
				aDados[i,nPosCod] := U_FUN_PROD()

			endif
			if nPosEsp > 0 
				aDados[i,nPosEsp] := substr(aDados[i,nPosEsp],1,80)
			endif

			if nPosDesc > 0 
				aDados[i,nPosDesc] := substr(aDados[i,nPosDesc],1,55)
			endif

			oProcess:SetRegua2(len(aCampos))
			For j:=1 to Len(aCampos)
				oProcess:IncRegua2('Processando coluna: ' + ALLTRIM(aCampos[j]))
				//Iremos verificar também se o campo existe, para evitar erros durante a importação
				//É importante tambem, validar o tipo que o campo é, pois quando importa um arquivo texto, o conteudo também será texto

				aStrCpo := FWSX3Util():GetFieldStruct(Alltrim(aCampos[j]))
				If Len(aStrCpo) > 0
					If aStrCpo[1] <> "B1_FILIAL"
						Do Case
							Case aStrCpo[2] == 'N' //Numerico
								AADD(aImporta,{ALLTRIM(aCampos[j]), Val(StrTran(StrTran(Alltrim(aDados[i,j]),".",""),",",".")) , NIL})
							Case aStrCpo[2] == 'D' //Data
								AADD(aImporta,{ALLTRIM(aCampos[j]), CTOD(aDados[i,j]), NIL})
							Otherwise //Outros
								AADD(aImporta,{ALLTRIM(aCampos[j]), aDados[i,j], NIL})
						EndCase
					EndIf 
				EndIf 
			Next j

			//Utilizar o MsExecAuto para incluir registros na tabela de clientes, utilizando a opção 3
			MSExecAuto({|x,y| Mata010(x,y)}, aImporta, nTpMov)
				
			//Caso encontre erro exibir na tela
			If lMsErroAuto
				//aLogAuto := GetAutoGRLog()
				//aErro := MostraErro("\SYSTEM\",FUNNAME() + ".LOG")
				MostraErro()
					
				GravaErro(aDados[i,nPosCod],'Erro ExecAuto Produto ',"")
				DisarmTransaction()
			EndIf

		Next i

		IF(MV_PAR02==1)
			If File(cArqProc)
				fErase(cArqProc)
			Endif
			fRename(Upper(cArquivo), cArqProc)
		Endif	

		If Len(aErro) > 0
			MostraLog()
		Else
			ApMsgInfo("Importação de Produtos efetuada com sucesso!","SUCESSO")
		EndIf
	else
		MostraLog()
	endif
	
Return()

Static Function GravaErro(cCod,cMsg,cDetalhe)

	//Local cFile := "\SYSTEM\"+FUNNAME()+".LOG"
	//Local cLine := ""

	AADD(aErro,{cCod,cMsg,cDetalhe})

Return()

Static Function MostraLog()

	Local oDlg
	Local oFont
	Local cMemo := ""

	if len(aErro) == 0
		aAdd(aErro,{"  ", "  ","  "})
	endif

	DEFINE FONT oFont NAME "Courier New" SIZE 5,0

	DEFINE MSDIALOG oDlg TITLE "Importação Cadastros" From 3,0 to 400,417 PIXEL

	aCabec := {"Código","Mensagem"}
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

	oReport := TReport():New(FUNNAME(),"Importação Cadastro de Produtos",,{|oReport| PrintReport(oReport)},"Este relatorio ira imprimir a relacao de erros encontrados durante o processo de importação dos dados.")
	oReport:SetLandscape()

	oSection := TRSection():New(oReport,,{})

	TRCell():New(oSection,"CODIGO"  ,,"Código")
	TRCell():New(oSection,"DESCRI"  ,,"Descrição do Erro")
	TRCell():New(oSection,"DETALHE"  ,,"Detalhado")

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
		oSection:Cell("DESCRI"):SetValue(aErro[i,2])
		oSection:Cell("DESCRI"):SetSize(200)
		oSection:Cell("DETALHE"):SetValue(aErro[i,3])
		oSection:Cell("DETALHE"):SetSize(20)

		nTamLin := 200
		nTab := 3
		lWrap := .T.

		lPrim := .T.

		cObsMemo := aErro[i,2]
		nLines   := MLCOUNT(cObsMemo, nTamLin, nTab, lWrap)

		For nCurrentLine := 1 to nLines
			If lPrim
				oSection:Cell("DESCRI"):SetValue(MEMOLINE(cObsMemo, nTamLin, nCurrentLine, nTab, lWrap))
				oSection:Cell("DESCRI"):SetSize(300)
				oSection:PrintLine()
				lPrim := .F.
			Else
				oSection:Cell("CODIGO"):SetValue("")
				oSection:Cell("DETALHE"):SetValue("")
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

	If .not. ParamBox(aPergs,"Arquivo",aRet,/*bValid*/,/*aButtons*/,.T.,/*nPosX*/,/*nPosY*/,/*oDialog*/,"OAEST003",.T.,.T.)
		lRet := .F.
	EndIf 
Return lRet
