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

User Function OAEST006()
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

	Pergunte(cPerg,.F.)

	AADD(aSays,OemToAnsi("Rotina para Importação de arquivo texto para tabela SNE - Produtos"))
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
	//nPosCod    	:= aScan(aCampos,{ |x| ALLTRIM(x) == "B1_COD" })
	//nPosDesc  	:= aScan(aCampos,{ |x| ALLTRIM(x) == "B1_DESC" })	
	//nPosNCM    	:= aScan(aCampos,{ |x| ALLTRIM(x) == "B1_POSIPI" })
	//nPosEsp		:= aScan(aCampos,{ |x| ALLTRIM(x) == "B1_ESPECIF" })

	oProcess:SetRegua1(len(aDados)) //guardar novamente a quantidade de registros


	//Validando o NCM
/*
	for i:= 1 to len(aDados)

		SYD->(DbSetOrder(1))
		if !SYD->(dbSeek(xFilial("SYD")+aDados[i,nPosNCM]))

			GravaErro(aDados[i,nPosNCM],"NCM Não Cadastrado", aDados[i,nPosNCM]+" "+alltrim(aDados[i,nPosDesc]))
			lFlagImp := .F.
		endif

	Next
*/

	if lFlagImp

		For i:=1 to Len(aDados)

			oProcess:IncRegua1("Importando Produtos..." + aDados[i,nPosCod] )
			aImporta := {}

			dbSelectArea("CNE")
			SB1->(dbSetOrder(1)) // filial + produto

			oProcess:SetRegua2(len(aCampos))
			For j:=1 to Len(aCampos)
				oProcess:IncRegua2('Processando coluna: ' + ALLTRIM(aCampos[j]))
				//Iremos verificar também se o campo existe, para evitar erros durante a importação
				//É importante tambem, validar o tipo que o campo é, pois quando importa um arquivo texto, o conteudo também será texto

				dbSelectArea("SX3")
				SX3->(dbSetOrder(2))
				SX3->(dbGoTop())
				If SX3->(dbSeek(ALLTRIM(aCampos[j])))
//					If !(ALLTRIM(aCampos[j])) $ "B1_FILIAL"
						Do Case
							Case SX3->X3_TIPO == 'N' //Numerico
								AADD(aImporta,{ALLTRIM(aCampos[j]), Val(StrTran(StrTran(Alltrim(aDados[i,j]),".",""),",",".")) , NIL})
							Case SX3->X3_TIPO == 'D' //Data
								AADD(aImporta,{ALLTRIM(aCampos[j]), CTOD(aDados[i,j]), NIL})
							Otherwise //Outros
								AADD(aImporta,{ALLTRIM(aCampos[j]), aDados[i,j], NIL})
						EndCase
//					EndIf
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

	Local cFile := "\SYSTEM\"+FUNNAME()+".LOG"
	Local cLine := ""

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


Static Function ajustaSx1(cPerg)
	//	putSx1(cPerg, "01", "Arquivo"  , "", "", "mv_ch1", "C", 99, 0, 0, "G", "", "DIR", "", "","mv_par01", "", "", "", "", "", "", "","", "", "", "", "", "", "", "", "", {"Informe o arquivo TXT que será","importado (Extensão CSV)",""}, {"","",""}, {"","",""})
	//	PutSx1(cPerg, "02", "Renomear?", "", "", "mv_ch2", "N",  1, 0, 2, "C", "",    "", "", "","mv_par02","Sim","Si","Yes","","Nao","No","No")
	 
	Local _i:=1	
	Private _agrpsx1:={}	

	aadd(_agrpsx1,{cPerg,"01","Arquivo?        ","mv_ch1"  ,"C",99,0,0,"G",space(60),"mv_par01"       ,space(15)        ,"",space(15),space(15)  ,space(30),space(15),space(15)  ,space(30),space(15),space(15) ,space(30),space(15),space(15)        ,space(30),"DIR"})
	aadd(_agrpsx1,{cPerg,"02","Renomear?       ","mv_ch2"  ,"N",1 ,2,0,"C",space(60),"mv_par02"       ,"SIM"       	    ,'NAO',space(15),"NAO"     ,space(30),space(15),space(15)  ,space(30),space(15),space(15) ,space(30),space(15),space(15)        ,space(30),    })

	For _i:=1 to len(_agrpsx1)
	if !sx1->(dbseek(_agrpsx1[_i,1]+_agrpsx1[_i,2]))
	sx1->(reclock("SX1",.t.))
	sx1->x1_grupo  :=_agrpsx1[_i,01]
	sx1->x1_ordem  :=_agrpsx1[_i,02]
	sx1->x1_pergunt:=_agrpsx1[_i,03]
	sx1->x1_variavl:=_agrpsx1[_i,04]
	sx1->x1_tipo   :=_agrpsx1[_i,05]
	sx1->x1_tamanho:=_agrpsx1[_i,06]
	sx1->x1_decimal:=_agrpsx1[_i,07]
	sx1->x1_presel :=_agrpsx1[_i,08]
	sx1->x1_gsc    :=_agrpsx1[_i,09]
	sx1->x1_valid  :=_agrpsx1[_i,10]
	sx1->x1_var01  :=_agrpsx1[_i,11]
	sx1->x1_def01  :=_agrpsx1[_i,12]
	sx1->x1_cnt01  :=_agrpsx1[_i,13]
	sx1->x1_var02  :=_agrpsx1[_i,14]
	sx1->x1_def02  :=_agrpsx1[_i,15]
	sx1->x1_cnt02  :=_agrpsx1[_i,16]
	sx1->x1_var03  :=_agrpsx1[_i,17]
	sx1->x1_def03  :=_agrpsx1[_i,18]
	sx1->x1_cnt03  :=_agrpsx1[_i,19]
	sx1->x1_var04  :=_agrpsx1[_i,20]
	sx1->x1_def04  :=_agrpsx1[_i,21]
	sx1->x1_cnt04  :=_agrpsx1[_i,22]
	sx1->x1_var05  :=_agrpsx1[_i,23]
	sx1->x1_def05  :=_agrpsx1[_i,24]
	sx1->x1_cnt05  :=_agrpsx1[_i,25]
	sx1->x1_f3     :=_agrpsx1[_i,26]
	sx1->(msunlock())
	EndIf
	Next
	 

	//	putSx1(cPerg, "01", "Arquivo"  , "", "", "mv_ch1", "C", 99, 0, 0, "G", "", "DIR", "", "","mv_par01", "", "", "", "", "", "", "","", "", "", "", "", "", "", "", "", {"Informe o arquivo TXT que será","importado (Extensão CSV)",""}, {"","",""}, {"","",""})
	//	PutSx1(cPerg, "02", "Renomear?", "", "", "mv_ch2", "N",  1, 0, 2, "C", "",    "", "", "","mv_par02","Sim","Si","Yes","","Nao","No","No")
 
Return NIL


Static Function CriaPerg( cPerg, aPerg, aHelp )
	Local aArea := GetArea()
	Local aCpoPerg := {}
	Local nX := 0
	Local nY := 0
	// DEFINE ESTRUTUA DO ARRAY DAS PERGUNTAS COM AS PRINCIPAIS INFORMACOES
	AADD( aCpoPerg, 'X1_ORDEM' )
	AADD( aCpoPerg, 'X1_PERGUNT' )
	AADD( aCpoPerg, 'X1_PERSPA' )
	AADD( aCpoPerg, 'X1_PERENG' ) 
	AADD( aCpoPerg, 'X1_VARIAVL' )
	AADD( aCpoPerg, 'X1_TIPO' )
	AADD( aCpoPerg, 'X1_TAMANHO' )
	AADD( aCpoPerg, 'X1_DECIMAL' )
	AADD( aCpoPerg, 'X1_PRESEL' )
	AADD( aCpoPerg, 'X1_GSC' )
	AADD( aCpoPerg, 'X1_VALID' )
	AADD( aCpoPerg, 'X1_VAR01' )
	AADD( aCpoPerg, 'X1_DEF01' )
	AADD( aCpoPerg, 'X1_DEFSPA1' )
	AADD( aCpoPerg, 'X1_DEFENG1' )
	AADD( aCpoPerg, 'X1_CNT01' )
	AADD( aCpoPerg, 'X1_VAR02' )
	AADD( aCpoPerg, 'X1_DEF02' )
	AADD( aCpoPerg, 'X1_DEFSPA2' )
	AADD( aCpoPerg, 'X1_DEFENG2' )
	AADD( aCpoPerg, 'X1_CNT02' )
	AADD( aCpoPerg, 'X1_VAR03' )
	AADD( aCpoPerg, 'X1_DEF03' )
	AADD( aCpoPerg, 'X1_DEFSPA3' )
	AADD( aCpoPerg, 'X1_DEFENG3' )
	AADD( aCpoPerg, 'X1_CNT03' )
	AADD( aCpoPerg, 'X1_VAR04' )
	AADD( aCpoPerg, 'X1_DEF04' )
	AADD( aCpoPerg, 'X1_DEFSPA4' )
	AADD( aCpoPerg, 'X1_DEFENG4' )
	AADD( aCpoPerg, 'X1_CNT04' )
	AADD( aCpoPerg, 'X1_VAR05' )
	AADD( aCpoPerg, 'X1_DEF05' )
	AADD( aCpoPerg, 'X1_DEFSPA5' )
	AADD( aCpoPerg, 'X1_DEFENG5' )
	AADD( aCpoPerg, 'X1_CNT05' )
	AADD( aCpoPerg, 'X1_F3' )
	AADD( aCpoPerg, 'X1_PYME' )
	AADD( aCpoPerg, 'X1_GRPSXG' )
	AADD( aCpoPerg, 'X1_HELP' )
	AADD( aCpoPerg, 'X1_PICTURE' )
	AADD( aCpoPerg, 'X1_IDFIL' )

	DBSelectArea( "SX1" )
	DBSetOrder( 1 )
	For nX := 1 To Len( aPerg )
		IF !DBSeek( PADR(cPerg,10) + aPerg[nX][1] )
			RecLock( "SX1", .T. ) // Inclui
		Else
			RecLock( "SX1", .F. ) // Altera
		Endif
		// Grava informacoes dos campos da SX1
		For nY := 1 To Len( aPerg[nX] )
			If aPerg[nX][nY] <> NIL
				SX1->( &( aCpoPerg[nY] ) ) := aPerg[nX][nY]
			EndIf
		Next
		SX1->X1_GRUPO := PADR(cPerg,10)
		MsUnlock() // Libera Registro
		// Verifica se campo possui Help
		_nPosHelp := aScan(aHelp,{|x| x[1] == aPerg[nX][1]}) 
		IF (_nPosHelp > 0)
			cNome := "P."+TRIM(cPerg)+ aHelp[_nPosHelp][1]+"."
			PutSX1Help(cNome,aHelp[_nPosHelp][2],{},{},.T.)
		Else
			// Apaga help ja existente.
			cNome := "P."+TRIM(cPerg)+ aPerg[nX][1]+"."
			PutSX1Help(cNome,{" "},{},{},.T.)
		Endif
	Next
    
	// Apaga perguntas nao definidas no array
	DBSEEK(cPerg,.T.)
	DO WHILE SX1->(!Eof()) .And. SX1->X1_GRUPO == cPerg
		IF ASCAN(aPerg,{|Y| Y[1] == SX1->X1_ORDEM}) == 0
			Reclock("SX1", .F.)
			SX1->(DBDELETE())
			Msunlock()
		ENDIF
		SX1->(DBSKIP())
	ENDDO
	RestArea( aArea )
Return
