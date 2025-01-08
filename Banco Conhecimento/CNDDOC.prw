#INCLUDE "protheus.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CNDDOC   ºAutor  ³ Ismael Junior      º Data ³  03/04/19    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Carrega os documetnos do contrato para medição             º±±
±±º          ³ 															  º±±  
±±º          ³ 								                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TOTVS STARSOFT                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function CNDDOC()
	cQuery := "	SELECT AC9_CODOBJ FROM " + RetSqlName("AC9")+ " AC9 WHERE AC9_ENTIDA = 'CN9' AND AC9_CODENT = '"+M->CND_CONTRA+"' AND D_E_L_E_T_ != '*' "
	If SELECT("TRBAC9") > 0
		TRBAC9->(DbCloseArea())
	Endif
    dbUseArea(.T.,"TOPCONN", TcGenQry(,,cQuery),"TRBAC9",.T.,.T.)
	DbSelectArea("TRBAC9")
	TRBAC9->(dbGoTop())
	 	cQry := " SELECT AC9_CODOBJ FROM " + RetSqlName("AC9")+ " AC9 WHERE AC9_ENTIDA = 'CND' AND AC9_CODENT = '"+xFilial( "CND" ) + M->CND_CONTRA + M->CND_REVISA + M->CND_NUMMED+"' AND D_E_L_E_T_ != '*' "
		If SELECT("TRBCND") > 0
			TRBCND->(DbCloseArea())
		Endif
	    dbUseArea(.T.,"TOPCONN", TcGenQry(,,cQry),"TRBCND",.T.,.T.)
		DbSelectArea("TRBCND")
		TRBCND->(dbGoTop())    
		If Empty(TRBCND->AC9_CODOBJ)	    
			Do While TRBAC9->(!Eof())
				RecLock( "AC9", .T. ) 		
				AC9->AC9_FILIAL := xFilial( "AC9" )
				AC9->AC9_FILENT := xFilial( "CND" )
				AC9->AC9_ENTIDA := "CND"
				AC9->AC9_CODENT := xFilial( "CND" ) + M->CND_CONTRA + M->CND_REVISA + M->CND_NUMMED
				AC9->AC9_CODOBJ := TRBAC9->AC9_CODOBJ	
				AC9->(MsUnLock()) // Confirma e finaliza a operação  		
			dbSelectArea("TRBAC9")
			TRBAC9->(dbSkip())
			EndDo 
		Endif	
Return nil				