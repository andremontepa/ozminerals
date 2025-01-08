#Include "Protheus.ch"
#Include "TopConn.ch"
#Include "totvs.ch"

#Define CLRF        Chr(13)+ Chr(10)

/*/{Protheus.doc} RT99M002
Rotina de consulta especifica que busca os dados dos Itens Contabeis Amarrados ao Centro de Custo.
@author 	Ricardo Tavares Ferreira
@since 		16/02/2018
@version 	12.1.17
@return 	Logico
@Obs 		Ricardo Tavares - Construcao Inicial
/*/
//==========================================================================================================
	User Function RT99M002()
//==========================================================================================================  

	Local lRet		:= .F.   
	Local aArea		:= GetArea()
	Local cInstSql	:= ""
	Local cRetCon	:= "Z6_CODITEM"
	Local cAgrup	:= ""  
	Local cOrdem	:= ""   
//	Local cCampo	:= ""   
	Local aCampos	:= {} 
	Local aCont		:= {}
	Local cContCTT	:= "" 
	Local cContSZ6	:= ""
	Local cContSZ7	:= ""
	Local cF3Atu	:= ""
	Local cCampoCTT	:= "" 
	Local cCampoSZ6	:= ""   
	Local cCampoSZ7	:= ""
	Local cConteudo	:= ""
	Local lOk		:= .F.   
	Local nX		:= 0   
	Local cTabAlias	:= AliasCpo(Substr(__READVAR,AT(">",__READVAR)+1,10))  
	Local aDadosAMR := {}
	
	aDadosAMR := FWSX3Util():GetListFieldsStruct(cTabAlias,.F.) 
	For nX := 1 To Len(aDadosAMR)
		If Alltrim(GetSX3Cache(aDadosAMR[nX][1],"X3_F3")) $ "SZ6|SZ7|CTT"
			AADD(aCampos,{aDadosAMR[nX][1],Alltrim(GetSX3Cache(aDadosAMR[nX][1],"X3_F3"))})
		EndIf
	Next nX   
	
	For nX := 1 To Len(aCampos)     
	    cCont := "M->" + Alltrim(aCampos[nX][1])
		AADD(aCont,{Alltrim(aCampos[nX][1]),Alltrim(aCampos[nX][2]),&cCont})
	Next nX
	
	For nX := 1 To Len(aCont)
    //--
    //-- Documentado por Toni Aguiar - TOTVS STARSOFT em 17/03/2021
    //--	
	//-- If ! Empty(aCont[nX][3])
			If aCont[nX][2] == "CTT"
				cCampoCTT := Alltrim(aCont[nX][1])
				cContCTT  := Alltrim(aCont[nX][3])
			ElseIf aCont[nX][2] == "SZ6"
				cCampoSZ6 := Alltrim(aCont[nX][1])
				cContSZ6  := Alltrim(aCont[nX][3])
			ElseIf aCont[nX][2] == "SZ7"
				cCampoSZ7 := Alltrim(aCont[nX][1])
				cContSZ7  := Alltrim(aCont[nX][3])
			EndIf
			
			If Alltrim(aCont[nX][1]) == Alltrim(Substr(__READVAR,AT(">",__READVAR)+1,10))
				cF3Atu := Alltrim(aCont[nX][2])
			EndIf
		//-- EndIf
	Next nX
	
	                    
	If Type("Acols") <> "A" 
	
		If ! Empty(cContCTT) 
	   		cInstSql := "SELECT Z6_CODITEM,Z6_DESCITE,Z6_COD,Z6_CCUSTO FROM "+ RetSqlName("SZ6") +" SZ6 WHERE SZ6.D_E_L_E_T_ = ' ' AND Z6_CCUSTO = '"+cContCTT+"' AND Z6_STATUS = '1'"
	   		U_RT99M001(cInstSql, cRetCon, cAgrup, cOrdem)    
	   		lOk := .T.
   		Else
	   		lOk := .F.
		EndIf  
		
	Else
		cConteudo := Acols[n][GdFieldPos(cCampoCTT)] 
		
		If !Empty(cConteudo) 
	   		cInstSql := "SELECT Z6_CODITEM,Z6_DESCITE,Z6_CCUSTO FROM "+ RetSqlName("SZ6") +" SZ6 WHERE SZ6.D_E_L_E_T_ = ' ' AND Z6_CCUSTO = '"+cConteudo+"' AND Z6_STATUS = '1'"
	   		U_RT99M001(cInstSql, cRetCon, cAgrup, cOrdem)    
	   		lOk := .T.
   		Else
	   		lOk := .F.
		EndIf 
		
	EndIf
	
	If lOk
		lRet := .T.
	Else
		ShowHelpDlg('RT99M002',{'O Campo Centro de Custo nùo foi preenchido.'},,{'Preencha o campo centro de custo primeiro para depois prosseguir com a inclusùo do cadastro.'},)
	EndIf
	
	RestArea(aArea)

Return lRet 
