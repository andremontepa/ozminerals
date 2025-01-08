#Include "Protheus.ch"
#Include "TopConn.ch"

#Define CLRF        Chr(13)+ Chr(10)

/*/{Protheus.doc} RT99M003
Rotina de consulta especifica que busca os dados das Classes Valor Amarrado ao Item contabil 
@author 	Ricardo Tavares Ferreira
@since 		16/02/2018
@version 	12.1.17
@return 	Logico
@Obs 		Ricardo Tavares - Construcao Inicial
/*/
//==========================================================================================================
	User Function RT99M003()
//==========================================================================================================  

	Local lRet		:= .F.   
	Local aArea		:= GetArea()
	Local cInstSql	:= ""
	Local cRetCon	:= "Z7_CODCVL"
	Local cAgrup	:= ""  
	Local cOrdem	:= ""   
	Local cCampoCTT	:= "" 
	Local cCampoSZ6	:= ""   
	Local cCampoSZ7	:= ""
	Local aCampos	:= {} 
	Local aCont		:= {}
	Local cContCTT	:= "" 
	Local cContSZ6	:= ""
	Local cContSZ7	:= ""
	Local cF3Atu	:= ""
	Local lOk		:= .F.   
	Local nX		:= 0   
	Local cTabAlias	:= AliasCpo(Substr(__READVAR,AT(">",__READVAR)+1,10))  
	Local cFiltro	:= "X3_ARQUIVO = '"+cTabAlias+"'"
	
	DbSelectArea("SX3")
	SX3->(DbSetOrder(1))
	 
	SET FILTER TO &(cFiltro)
	   
	SX3->(DbGoTOp())                 
	
	While !SX3->(EoF()) 
		If ! Empty(SX3->X3_F3)
			If Alltrim(SX3->X3_F3) $ "SZ6|SZ7|CTT"
				AADD(aCampos,{SX3->X3_CAMPO,SX3->X3_F3})
			EndIf
		EndIf
		SX3->(DbSkip())
	End
	
	DBCLEARFILTER()    
	
	For nX := 1 To Len(aCampos)   
	    cCont := "M->" + Alltrim(aCampos[nX][1])
		AADD(aCont,{Alltrim(aCampos[nX][1]),Alltrim(aCampos[nX][2]),&cCont})
	Next nX
	
	For nX := 1 To Len(aCont)
	    //--
	    //-- Documentado por Toni Aguiar - TOTVS STARSOFT em 17/03/2021
	    //--
		//If ! Empty(aCont[nX][3])
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
		//EndIf
	Next nX
	
	If Type("Acols") <> "A" 
		
		If ! Empty(cContCTT) .and. ! Empty(cContSZ6) 
			cInstSql := "SELECT Z7_CODCVL, Z7_DESCCVL,Z7_COD,Z7_CCUSTO,Z7_CODITEM FROM "+ RetSqlName("SZ7") +" SZ7 WHERE SZ7.D_E_L_E_T_ = ' ' AND Z7_CCUSTO = '"+cContCTT+"' AND Z7_CODITEM = '"+cContSZ6+"' AND Z7_STATUS = '1'"
			U_RT99M001(cInstSql, cRetCon, cAgrup, cOrdem)    
			lOk := .T.
		Else
			lOk := .F.
		EndIf     
		
		If lOk
			lRet := .T.
		Else 
			If Empty(cContCTT)
				ShowHelpDlg('RT99M003',{'O Campo Centro de Custo não foi preenchido.'},,{'Preencha o campo Centro de Custo primeiro para depois prosseguir com a inclusão do cadastro.'},)
			ElseIf Empty(cContSZ6) 
			 	ShowHelpDlg('RT99M003',{'O Campo Item Contábil não foi preenchido.'},,{'Preencha o campo Item Contábil primeiro para depois prosseguir com a inclusão do cadastro.'},)
			EndIf
		EndIf
	
	Else  
	    //--
	    //-- Alterado por Toni Aguiar - TOTVS STARSOFT em 17/03/2021
	    //--
		//-- cContCTT	:= Acols[n][GdFieldPos(cCampoCTT)]
		//-- cContSZ6	:= Acols[n][GdFieldPos(cCampoSZ6)]
		cContCTT	:= If(Alltrim(cContCTT)="", Acols[n][GdFieldPos(cCampoCTT)], cContCTT)
		cContSZ6	:= If(Alltrim(cContSZ6)="", Acols[n][GdFieldPos(cCampoSZ6)], cContSZ6)
		
		If !Empty(cContCTT) .and. !Empty(cContSZ6) 
			cInstSql := "SELECT Z7_CODCVL, Z7_DESCCVL,Z7_CCUSTO,Z7_CODITEM FROM "+ RetSqlName("SZ7") +" SZ7 WHERE SZ7.D_E_L_E_T_ = ' ' AND Z7_CCUSTO = '"+cContCTT+"' AND Z7_CODITEM = '"+cContSZ6+"' AND Z7_STATUS = '1'"
			U_RT99M001(cInstSql, cRetCon, cAgrup, cOrdem)    
			lOk := .T.
		Else
			lOk := .F.
		EndIf 
		
		If lOk
			lRet := .T.
		Else 
			If Empty(cContCTT)
				ShowHelpDlg('RT99M003',{'O Campo Centro de Custo não foi preenchido.'},,{'Preencha o campo Centro de Custo primeiro para depois prosseguir com a inclusão do cadastro.'},)
			ElseIf Empty(cContSZ6) 
			 	ShowHelpDlg('RT99M003',{'O Campo Item Contábil não foi preenchido.'},,{'Preencha o campo Item Contábil primeiro para depois prosseguir com a inclusão do cadastro.'},)
			EndIf
		EndIf
		
	EndIf
	
	RestArea(aArea)

Return lRet 