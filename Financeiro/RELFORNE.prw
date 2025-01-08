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
    @example
    u_zTstExc1()
/*/

User Function RelFonrne()
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

	lRet := oExcel:IsWorkSheet("relationship")
	oExcel:AddworkSheet("relationship")

	lRet := oExcel:IsWorkSheet("relationship")

	//Criando a Tabela
	oExcel:AddTable("relationship","Supplier Data")
	Criatmp1()
	DBSelectArea('QRYPRO2')
	QRYPRO2->(DBGoTop())
	//Criando Colunas
	While !(QRYPRO2->(EoF()))
		oExcel:AddColumn("relationship","Supplier Data",AllTrim(QRYPRO2->COLUMN_NAME),1,1) //1 = Modo Texto
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
			If AllTrim(aNomCol[nX]) == 'Email'
				cCampo:= StrTran(QRYPRO->&(AllTrim(aNomCol[nX])),"<","")
				cCampo:= StrTran(cCampo,">","")
			Else
				cCampo:= QRYPRO->&(AllTrim(aNomCol[nX]))
			EndIf
			AAdd(aColunas,cCampo)
		Next

		oExcel:AddRow("relationship","Supplier Data",aColunas)
		aColunas:={}
		//Pulando Registro
		QRYPRO->(DbSkip())
	EndDo
	QRYPRO->(DbCloseArea())

	//Ativando o arquivo e gerando o xml
	oExcel:Activate()
	oExcel:GetXMLFile('C:/RelFornec.xlm')
	//Abrindo o excel e abrindo o arquivo xml
	oExcel := MsExcel():New()             //Abre uma nova conexão com Excel
	oExcel:WorkBooks:Open('C:/RelFornec.xlm')     //Abre uma planilha
	oExcel:SetVisible(.T.)                 //Visualiza a planilha
	oExcel:Destroy()                       //Encerra o processo do gerenciador de tarefas

	RestArea(aArea)
Return

Static Function Criatmp1()

	Local cQuery2       := ""

	cQuery2 := " SELECT COLUMN_NAME "
	cQuery2 += " FROM INFORMATION_SCHEMA.COLUMNS "
	cQuery2 += " WHERE TABLE_NAME = 'vw_fornecedores_aus' "
	cQuery2 += " ORDER BY ORDINAL_POSITION "

	TCQuery cQuery2 New Alias "QRYPRO2"

Return

Static Function Criatmp2()

	Local cQuery        := ""

	cQuery := " SELECT * FROM vw_fornecedores_aus "

	TCQuery cQuery New Alias "QRYPRO"

	Count To nTotal

Return
