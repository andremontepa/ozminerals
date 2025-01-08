#INCLUDE "protheus.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MT131WF   ºAutor  ³ Ismael Junior      º Data ³  30/03/19   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Executado após atualização de arquivos na geracao cotacoes º±±
±±º          ³   											              º±±  
±±º          ³ 												              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TOTVS STARSOFT                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
user function MT131WF()
Local cNumc8 	:= ParamIXB[1] 
Local cQry 		:= "" 
Local cQuery 	:= "" 

cQry := " SELECT C1_FILIAL+C1_NUM+C1_ITEM AS CHAVE,C1_ITEM " 
cQry += " FROM " + RetSqlName("SC1")+ " SC1 " 
cQry += " WHERE C1_NUM = '"+SC1->C1_NUM+"' "
cQry += " AND C1_FILIAL = '"+xFilial("SC1")+"' "
cQry += " AND SC1.D_E_L_E_T_ != '*' "

If SELECT("TRASC") > 0
	TRASC->(DbCloseArea())
Endif
dbUseArea(.T.,"TOPCONN", TcGenQry(,,cQry),"TRASC",.T.,.T.)
DbSelectArea("TRASC")
TRASC->(dbGoTop())
Do While TRASC->(!Eof())
	cQuery := "	SELECT AC9_CODOBJ FROM " + RetSqlName("AC9")+ " WHERE AC9_ENTIDA = 'SC1' AND AC9_CODENT = '"+TRASC->CHAVE+"' "
	If SELECT("TRBAC9") > 0
		TRBAC9->(DbCloseArea())
	Endif
    dbUseArea(.T.,"TOPCONN", TcGenQry(,,cQuery),"TRBAC9",.T.,.T.)
	DbSelectArea("TRBAC9")
	TRBAC9->(dbGoTop())
	Do While TRBAC9->(!Eof())
				RecLock( "AC9", .T. ) 		
				AC9->AC9_FILIAL := xFilial( "AC9" )
				AC9->AC9_FILENT := xFilial( "SC8" )
				AC9->AC9_ENTIDA := "SC8"
				AC9->AC9_CODENT := xFilial( "SC8" )+cNumc8+TRASC->C1_ITEM
				AC9->AC9_CODOBJ := TRBAC9->AC9_CODOBJ	
				AC9->(MsUnLock()) // Confirma e finaliza a operação 
	dbSelectArea("TRBAC9")
	TRBAC9->(dbSkip())
	EndDo				
dbSelectArea("TRASC")
TRASC->(dbSkip())
EndDo		
return