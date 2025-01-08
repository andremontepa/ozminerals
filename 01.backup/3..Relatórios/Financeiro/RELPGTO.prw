//Bibliotecas
#Include "Protheus.ch"
#Include "TopConn.ch"

//Constantes
#Define STR_PULA    Chr(13)+Chr(10)

/*/{Protheus.doc} RelFonrne
Função que cria Relação de Fornecedors
@author Stephen Noel - Equilibrio T.I
@since 06/08/2016
@version 1.0
/*/

User Function RelPgto()
                       
Static oButton1
Static oButton2
Static oComboBo1
Static nComboBo1 := " "
Static oGet1
Static dGet1 := Date()
Static oGet2
Static dGet2 := Date()
Static oSay1
Static oSay2
Static oSay3
Static oDlg

  DEFINE MSDIALOG oDlg TITLE "Parameters" FROM 000, 000  TO 300, 450 COLORS 0, 16777215 PIXEL

    @ 022, 011 SAY oSay1 PROMPT "Company Cod" SIZE 039, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 021, 085 MSCOMBOBOX oComboBo1 VAR nComboBo1 ITEMS {"01","02","03","04","05","06","07"} SIZE 072, 010 OF oDlg COLORS 0, 16777215 PIXEL
    @ 040, 009 SAY oSay2 PROMPT "Initial invoice date" SIZE 064, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 057, 009 SAY oSay3 PROMPT "Final invoice date" SIZE 056, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 039, 085 MSGET oGet1 VAR dGet1 SIZE 072, 010 OF oDlg COLORS 0, 16777215 PIXEL
    @ 056, 084 MSGET oGet2 VAR dGet2 SIZE 075, 010 OF oDlg COLORS 0, 16777215 PIXEL
    @ 093, 037 BUTTON oButton1 PROMPT "Cancel" SIZE 037, 012 OF oDlg Action oDlg:End() PIXEL
    @ 093, 125 BUTTON oButton2 PROMPT "Ok" SIZE 037, 012 OF oDlg Action RelPgto() PIXEL

  ACTIVATE MSDIALOG oDlg CENTERED

Return

Static Function RelPgto()
	If MsgYesNo("Confirma a geração do Relatório?", "Confirma?")
		MsAguarde({||ProcRel()}, "Hold on...", "Processing Records...")
	EndIf
Return

Static Function ProcRel()

	Local aArea         := GetArea()
	Local oExcel
	//Local cArquivo      := GetTempPath()+'RelForne.xlm'
	Local aNomCol       := {}
	Local nX
	Local aColunas      := {}
	Local nAtual        := 0
	Local cCampo        := ""
	Static nTotal        := 0

	//Criando o objeto que irá gerar o conteúdo do Excel
	oExcel := FWMsExcelEx():New()

	lRet := oExcel:IsWorkSheet("Payment")
	oExcel:AddworkSheet("Payment")

	lRet := oExcel:IsWorkSheet("Payment")

	//Criando a Tabela
	oExcel:AddTable("Payment","Payment audit")
	Criatmp1()
	DBSelectArea('QRYPRO2')
	QRYPRO2->(DBGoTop())
	//Criando Colunas
	While !(QRYPRO2->(EoF()))
		oExcel:AddColumn("Payment","Payment audit",AllTrim(QRYPRO2->COLUMN_NAME),1,1) //1 = Modo Texto
		AAdd(aNomCol,QRYPRO2->COLUMN_NAME)
		QRYPRO2->(DbSkip())
	EndDo
	//Criando as Linhas
	QRYPRO2->(DBCloseArea())

	Criatmp2()
	DBSelectArea('QRYPRO')
	QRYPRO->(DBGoTop())
	//Criando as Linhas... Enquanto não for fim da query
	While !(QRYPRO->(EoF()))
		//Incrementa a mensagem na régua
		nAtual++

		MsProcTxt("Loading record " + cValToChar(nAtual) + " of " + cValToChar(nTotal) + "...")
		for nX:= 1 to Len(aNomCol)
			cCampo:= QRYPRO->&(AllTrim(aNomCol[nX]))
			AAdd(aColunas,cCampo)
		Next

		oExcel:AddRow("Payment","Payment audit",aColunas)
		aColunas:={}
		//Pulando Registro
		QRYPRO->(DbSkip())
	EndDo
	QRYPRO->(DbCloseArea())

	//Ativando o arquivo e gerando o xml
	oExcel:Activate()
	oExcel:GetXMLFile('C:/RelPgto.xlm')
	//Abrindo o excel e abrindo o arquivo xml
	oExcel := MsExcel():New()             //Abre uma nova conexão com Excel
	oExcel:WorkBooks:Open('C:/RelPgto.xlm')     //Abre uma planilha
	oExcel:SetVisible(.T.)                 //Visualiza a planilha
	oExcel:Destroy()                       //Encerra o processo do gerenciador de tarefas

	RestArea(aArea)
Return

Static Function Criatmp1()

	Local cQuery2       := ""

	cQuery2 := " SELECT COLUMN_NAME "
	cQuery2 += " FROM INFORMATION_SCHEMA.COLUMNS "
	cQuery2 += " WHERE TABLE_NAME = 'Vw_pagamentos_aus' "
	cQuery2 += " ORDER BY ORDINAL_POSITION "

	TCQuery cQuery2 New Alias "QRYPRO2"

Return

Static Function Criatmp2()

	Local cQuery        := ""

	cQuery := " SELECT * FROM Vw_pagamentos_aus "
	cQuery += " WHERE InvoiceDate >= '"+dtos(dGet1)+"' "
	cQuery += " AND InvoiceDate <= '"+dtos(dGet2)+"' "
	If !empty(nComboBo1)
	cQuery += " AND CompanyCode = '"+nComboBo1+"' "
	EndIf
	TCQuery cQuery New Alias "QRYPRO"

	Count To nTotal

Return
