#Include "Protheus.ch"
#Include "TopConn.ch"

/*/{Protheus.doc} RT99M004
Rotina que valida se o valor digitado, existe na tabela de amarrações 
@author 	Ricardo Tavares Ferreira
@since 		17/02/2018
@version 	12.1.17
@return 	Logico
@Obs 		Ricardo Tavares - Construcao Inicial
/*/
//==========================================================================================================
	User Function RT99M004()
//==========================================================================================================  

	Local aArea 	:= GetArea() 
	Local cQuery   	:= ""
	Local QbLinha	:= chr(13)+chr(10)
	Local lRet		:= .F.    
	Local cCampoSZ6	:= ""
	Local cCampoSZ7	:= "" 
	Local cCampoCTT	:= ""  
	Local cContSZ6	:= "" 
	Local cContSZ7	:= ""
	Local cContCTT	:= ""     
	Local cDescCC	:= ""    
	Local cDescItem	:= ""  
	Local aCampos	:= {}
	Local cF3Atu	:= ""    
	Local nX		:= 0
	Local cCodAM	:= ""
	Local cTabAlias	:= AliasCpo(Substr(__READVAR,AT(">",__READVAR)+1,10))  
	Local cFiltro	:= "X3_ARQUIVO = '"+cTabAlias+"'" 
	Local aCont		:= {}
	Local cCont		:= ""
	
	DbSelectArea("SX3")
	SX3->(DbSetOrder(1))

	If FWIsInCallStack("CNTA121")
		Return .T.
	EndIf 
	
	// Filtro Pra retornar os campos e conteudos da rotina relacionada RT34A001
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
	 //--If ! Empty(aCont[nX][3])
		If .not. (Alltrim(aCont[nX][1]) $ "CNE_XCC|CNE_XITCTA|CNE_XCLVL")
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
		Else 
			// validar aqui CNZ_XCC, CNZ_XITCTA, CNZ_XCLVL, CNE_XCC, CNE_XITCTA, CNE_XCLVL
		EndIf
	 //--EndIf
	Next nX
	
	If Type("Acols") <> "A"
	
		If cF3Atu == "SZ6"  
			
			DbSelectArea("SZ6")
			SZ6->(DbSetOrder(2)) 
			
			cCodAM := GET_COD("SZ6",cContCTT,cContSZ6,cContSZ7)
			cDescCC := Posicione("CTT",1,xFilial("CTT")+cContCTT,"CTT_DESC01") 
			
			If Select("TMP") > 0
				TMP->(DBCLOSEAREA())
			EndIf
	
			cQuery := "SELECT "+QbLinha 
			cQuery += "Z6_COD COD "+QbLinha
			cQuery += "FROM "+RetSqlName("SZ6")+" Z6 "+QbLinha
			
			cQuery += "WHERE "+QbLinha 
			cQuery += "Z6.D_E_L_E_T_ = ' ' "+QbLinha 
			cQuery += "AND Z6_STATUS = '1' "+QbLinha
			cQuery += "AND Z6_COD = '"+cCodAM+"' "+QbLinha
			cQuery += "AND Z6_CODITEM = '"+cContSZ6+"' "+QbLinha
			cQuery += "AND Z6_CCUSTO = '"+cContCTT+"' "+QbLinha
			cQuery += "GROUP BY Z6_COD "+QbLinha
			
			cQuery := CHANGEQUERY(cQuery)
			DBUSEAREA(.T., 'TOPCONN', TCGENQRY(,,cQuery), "TMP", .F., .T.)

			DBSELECTAREA("TMP")
			TMP->(DBGOTOP())
			COUNT TO NQTREG
			TMP->(DBGOTOP())

			IF NQTREG <= 0 
				TMP->(DBCLOSEAREA())
				lOk	:= .F.
			Else		
				lOk	:= .T.
				TMP->(DBCLOSEAREA())
			EndIf
		     
		 	If lOk
				lRet := .T.
			ELse
				ShowHelpDlg('RT99M004',{'Este Item Contabil não possui amarração com este Centro de Custo ('+Alltrim(cContCTT)+' - '+Alltrim(cDescCC)+').'},,{'Realize a amarração deste Item Contabil ao Centro de Custo, para que o mesmo possa ser selecionado.'},)
			EndIf 

		ElseIf cF3Atu == "SZ7"  
			
			DbSelectArea("SZ7")
			SZ7->(DbSetOrder(3))
			
			cCodAM := GET_COD("SZ7",cContCTT,cContSZ6,cContSZ7)
			cDescItem := Posicione("CTD",1,xFilial("CTD")+cContSZ6,"CTD_DESC01")
		    
		    If Select("TMP") > 0
				TMP->(DBCLOSEAREA())
			EndIf
	
		    cQuery := "SELECT "+QbLinha 
			cQuery += "Z7_COD COD "+QbLinha
			cQuery += "FROM "+RetSqlName("SZ7")+" Z7 "+QbLinha
			
			cQuery += "WHERE "+QbLinha 
			cQuery += "Z7.D_E_L_E_T_ = ' ' "+QbLinha 
			cQuery += "AND Z7_STATUS = '1' "+QbLinha
			cQuery += "AND Z7_COD = '"+cCodAM+"' "+QbLinha
			cQuery += "AND Z7_CODITEM = '"+cContSZ6+"' "+QbLinha
			cQuery += "AND Z7_CCUSTO = '"+cContCTT+"' "+QbLinha
			cQuery += "AND Z7_CODCVL = '"+cContSZ7+"' "+QbLinha
			cQuery += "GROUP BY Z7_COD "+QbLinha
			
			cQuery := CHANGEQUERY(cQuery)
			DBUSEAREA(.T., 'TOPCONN', TCGENQRY(,,cQuery), "TMP", .F., .T.)

			DBSELECTAREA("TMP")
			TMP->(DBGOTOP())
			COUNT TO NQTREG
			TMP->(DBGOTOP())

			IF NQTREG <= 0 
				TMP->(DBCLOSEAREA())
				lOk	:= .F.
			Else		
				lOk	:= .T.
				TMP->(DBCLOSEAREA())
			EndIf
		     
		 	If lOk
				lRet := .T.
			ELse
				ShowHelpDlg('RT99M004',{'Esta Classe Valor não possui amarração com o Centro de Custo e Item Contabil selecionado (Centro de Custo: '+Alltrim(cContCTT)+' - '+Alltrim(cDescCC)+') e (Item Contabil: '+Alltrim(cContSZ6)+' - '+Alltrim(cDescItem)+').'},,{'Realize a amarração desta Classe Valor ao Item Contabil e Centro de Custo, para que o mesmo possa ser selecionado.'},)
			EndIf 
			
		ElseIf cF3Atu $ "CTD|CTH"
			ShowHelpDlg('RT99M004',{'Consulta Padrao SZ6 e/ou SZ7 nao cadastrada!!!'},,{'Cadastre as Consultas Padrão Listadas acima nos seus respectivos campos para depois prosseguir com a inclusão.'},)
		ElseIf Empty(cF3Atu)
			ShowHelpDlg('RT99M004',{'Campo Não Preenchido!!!'},,{'Preencha o Campo para que seja possivel alterar os demais campos da tela.'},)
		EndIF
	
	Else 
	    //--
	    //-- Alterado por Toni Aguiar em 17/03/2021
	    //--
	    //--
		//-- cContSZ6 := Acols[n][GdFieldPos(cCampoSZ6)]   
		//-- cContSZ7 := Acols[n][GdFieldPos(cCampoSZ7)]
		//-- cContCTT := Acols[n][GdFieldPos(cCampoCTT)]
        //--
	
		cContSZ6 := If(Alltrim(cContSZ6)="", Acols[n][GdFieldPos(cCampoSZ6)], cContSZ6) 
		cContSZ7 := If(Alltrim(cContSZ7)="", Acols[n][GdFieldPos(cCampoSZ7)], cContSZ7)
		cContCTT := If(Alltrim(cContCTT)="", Acols[n][GdFieldPos(cCampoCTT)], cContCTT)
	
		
		If cF3Atu == "SZ6"  
			
			DbSelectArea("SZ6")
			SZ6->(DbSetOrder(2)) 
			
			cCodAM := GET_COD("SZ6",cContCTT,cContSZ6,cContSZ7)
			cDescCC := Posicione("CTT",1,xFilial("CTT")+cContCTT,"CTT_DESC01") 
			
			If Select("TMP") > 0
				TMP->(DBCLOSEAREA())
			EndIf
	
			cQuery := "SELECT "+QbLinha 
			cQuery += "Z6_COD COD "+QbLinha
			cQuery += "FROM "+RetSqlName("SZ6")+" Z6 "+QbLinha
			
			cQuery += "WHERE "+QbLinha 
			cQuery += "Z6.D_E_L_E_T_ = ' ' "+QbLinha 
			cQuery += "AND Z6_STATUS = '1' "+QbLinha
			cQuery += "AND Z6_COD = '"+cCodAM+"' "+QbLinha
			cQuery += "AND Z6_CODITEM = '"+cContSZ6+"' "+QbLinha
			cQuery += "AND Z6_CCUSTO = '"+cContCTT+"' "+QbLinha
			cQuery += "GROUP BY Z6_COD "+QbLinha
			
			cQuery := CHANGEQUERY(cQuery)
			DBUSEAREA(.T., 'TOPCONN', TCGENQRY(,,cQuery), "TMP", .F., .T.)

			DBSELECTAREA("TMP")
			TMP->(DBGOTOP())
			COUNT TO NQTREG
			TMP->(DBGOTOP())

			IF NQTREG <= 0 
				TMP->(DBCLOSEAREA())
				lOk	:= .F.
			Else		
				lOk	:= .T.
				TMP->(DBCLOSEAREA())
			EndIf
		     
		 	If lOk
				lRet := .T.
			ELse
				ShowHelpDlg('RT99M004',{'Este Item Contabil não possui amarração com este Centro de Custo ('+Alltrim(cContCTT)+' - '+Alltrim(cDescCC)+').'},,{'Realize a amarração deste Item Contabil ao Centro de Custo, para que o mesmo possa ser selecionado.'},)
			EndIf 
		
		ElseIf cF3Atu == "SZ7"  
			
			DbSelectArea("SZ7")
			SZ7->(DbSetOrder(3))
			
			cCodAM := GET_COD("SZ7",cContCTT,cContSZ6,cContSZ7)
			cDescItem := Posicione("CTD",1,xFilial("CTD")+cContSZ6,"CTD_DESC01")
			
			If Select("TMP") > 0
				TMP->(DBCLOSEAREA())
			EndIf
	
			cQuery := "SELECT "+QbLinha 
			cQuery += "Z7_COD COD "+QbLinha
			cQuery += "FROM "+RetSqlName("SZ7")+" Z7 "+QbLinha
			
			cQuery += "WHERE "+QbLinha 
			cQuery += "Z7.D_E_L_E_T_ = ' ' "+QbLinha 
			cQuery += "AND Z7_STATUS = '1' "+QbLinha
			cQuery += "AND Z7_COD = '"+cCodAM+"' "+QbLinha
			cQuery += "AND Z7_CODITEM = '"+cContSZ6+"' "+QbLinha
			cQuery += "AND Z7_CCUSTO = '"+cContCTT+"' "+QbLinha
			cQuery += "AND Z7_CODCVL = '"+cContSZ7+"' "+QbLinha
			cQuery += "GROUP BY Z7_COD "+QbLinha
			
			cQuery := CHANGEQUERY(cQuery)
			DBUSEAREA(.T., 'TOPCONN', TCGENQRY(,,cQuery), "TMP", .F., .T.)

			DBSELECTAREA("TMP")
			TMP->(DBGOTOP())
			COUNT TO NQTREG
			TMP->(DBGOTOP())

			IF NQTREG <= 0 
				TMP->(DBCLOSEAREA())
				lOk	:= .F.
			Else		
				lOk	:= .T.
				TMP->(DBCLOSEAREA())
			EndIf
		     
		 	If lOk
				lRet := .T.
			ELse
				ShowHelpDlg('RT99M004',{'Esta Classe Valor não possui amarração com o Centro de Custo e Item Contabil selecionado (Centro de Custo: '+Alltrim(cContCTT)+' - '+Alltrim(cDescCC)+') e (Item Contabil: '+Alltrim(cContSZ6)+' - '+Alltrim(cDescItem)+').'},,{'Realize a amarração desta Classe Valor ao Item Contabil e Centro de Custo, para que o mesmo possa ser selecionado.'},)
			EndIf 
			
		ElseIf cF3Atu $ "CTD|CTH" .or. Empty(cF3Atu)
			ShowHelpDlg('RT99M004',{'Consulta Padrao SZ6 e/ou SZ7 nao cadastrada!!!'},,{'Cadastre as Consultas Padrão Listadas acima nos seus respectivos campos para depois prosseguir com a inclusão.'},)
		ElseIf Empty(cF3Atu)
			ShowHelpDlg('RT99M004',{'Campo Não Preenchido!!!'},,{'Preencha o Campo para que seja possivel alterar os demais campos da tela.'},)
		EndIF
	
	EndIf
	
	RestArea(aArea)

Return lRet

/*/{Protheus.doc} GET_COD
Função que retorna o codigo da amarração
@author 	Ricardo Tavares Ferreira
@since 		17/02/2018
@version 	12.1.17
@return 	Logico
@Obs 		Ricardo Tavares - sConstrucao Inicial
/*/
//==========================================================================================================
	Static Function GET_COD(cTab,cCusto,cItem,cClasse)
//==========================================================================================================  

	Local cCod		:= ""
	Local cQuery   	:= ""
	Local QbLinha	:= chr(13)+chr(10)
	Default cTab	:= ""
	Default cCusto	:= ""
	Default cItem	:= ""
	Default cClasse	:= ""
	
	If cTab == "SZ6"
		
		cQuery := "SELECT"+QbLinha 
		cQuery += "Z6_COD COD"+QbLinha
		cQuery += "FROM "+RetSqlName("SZ6")+" Z6 "+QbLinha
		
		cQuery += "WHERE"+QbLinha 
		cQuery += "Z6.D_E_L_E_T_ = ' '"+QbLinha 
		cQuery += "AND Z6_STATUS = '1'"+QbLinha
		cQuery += "AND Z6_CODITEM = '"+cItem+"'"+QbLinha
		cQuery += "AND Z6_CCUSTO = '"+cCusto+"'"+QbLinha
		cQuery += "GROUP BY Z6_COD"+QbLinha
		
		cQuery := CHANGEQUERY(cQuery)
		DBUSEAREA(.T., 'TOPCONN', TCGENQRY(,,cQuery), "QRYSZ6", .F., .T.)

		DBSELECTAREA("QRYSZ6")
		QRYSZ6->(DBGOTOP())
		COUNT TO NQTREG
		QRYSZ6->(DBGOTOP())

		IF NQTREG <= 0 
			QRYSZ6->(DBCLOSEAREA())
		Else		
			While !QRYSZ6->(EoF())
				cCod := QRYSZ6->COD
				QRYSZ6->(DbSkip())
			End
			QRYSZ6->(DBCLOSEAREA())
		EndIf
	
	Else
	
		cQuery := "SELECT "+QbLinha 
		cQuery += "Z7_COD COD "+QbLinha
		cQuery += "FROM "+RetSqlName("SZ7")+" Z7 "+QbLinha
		
		cQuery += "WHERE "+QbLinha 
		cQuery += "Z7.D_E_L_E_T_ = ' ' "+QbLinha 
		cQuery += "AND Z7_STATUS = '1' "+QbLinha
		cQuery += "AND Z7_CODITEM = '"+cItem+"' "+QbLinha
		cQuery += "AND Z7_CCUSTO = '"+cCusto+"' "+QbLinha
		cQuery += "AND Z7_CODCVL = '"+cClasse+"' "+QbLinha
		cQuery += "GROUP BY Z7_COD "+QbLinha
		
		cQuery := CHANGEQUERY(cQuery)
		DBUSEAREA(.T., 'TOPCONN', TCGENQRY(,,cQuery), "QRYSZ7", .F., .T.)

		DBSELECTAREA("QRYSZ7")
		QRYSZ7->(DBGOTOP())
		COUNT TO NQTREG
		QRYSZ7->(DBGOTOP())

		IF NQTREG <= 0 
			QRYSZ7->(DBCLOSEAREA())
		Else		
			While !QRYSZ7->(EoF())
				cCod := QRYSZ7->COD
				QRYSZ7->(DbSkip())
			End
			QRYSZ7->(DBCLOSEAREA())
		EndIf
	EndIf

Return cCod
