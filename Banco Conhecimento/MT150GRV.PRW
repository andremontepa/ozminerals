#INCLUDE "protheus.ch"
#INCLUDE "rwmake.ch"      

#INCLUDE "topconn.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MT150GRV  ºAutor  ³ Ismael Junior      º Data ³  30/03/19   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Responsável por efetuar a atualização das cotações de      º±±
±±º          ³ compra. APOS GRAVACAO DO SC8                               º±±  
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TOTVS STARSOFT                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
user function MT150GRV()
Local cCodChav := SC8->C8_FILIAL+SC8->C8_NUM+SC8->C8_ITEM+SC8->C8_ITEMGRD+SC8->C8_FORNECE+SC8->C8_LOJA+SC8->C8_FORNOME

	cQuery := "	SELECT AC9_CODOBJ FROM "+RetSqlName("AC9")+" WHERE AC9_ENTIDA = 'SC8' AND AC9_CODENT = '"+SC8->C8_FILIAL+SC8->C8_NUM+SC8->C8_ITEM+"' "
	If SELECT("TRBAC9") > 0
		TRBAC9->(DbCloseArea())
	Endif
    dbUseArea(.T.,"TOPCONN", TcGenQry(,,cQuery),"TRBAC9",.T.,.T.)
	DbSelectArea("TRBAC9")
	TRBAC9->(dbGoTop())
	Do While TRBAC9->(!Eof())
		DbSelectArea("AC9")
	  	AC9->(DbSetOrder(2))
	  	If !AC9->(DbSeek(xFilial("AC9")+"SC8"+xFilial( "SC8" )+Substr(cCodChav,0,Tamsx3("AC9_CODENT")[1])+TRBAC9->AC9_CODOBJ))
				RecLock( "AC9", .T. ) 		
				AC9->AC9_FILIAL := xFilial( "AC9" )
				AC9->AC9_FILENT := xFilial( "SC8" )
				AC9->AC9_ENTIDA := "SC8"
				AC9->AC9_CODENT := cCodChav
				AC9->AC9_CODOBJ := TRBAC9->AC9_CODOBJ	
				AC9->(MsUnLock())                           
		Endif	
	dbSelectArea("TRBAC9")
	TRBAC9->(dbSkip())
	EndDo						
return