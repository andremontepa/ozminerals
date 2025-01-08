#Include "Protheus.ch"
#Include "Topconn.ch"
#include "rwmake.ch"
#include "fileio.ch"
#include "TbiConn.ch"
#include "TbiCode.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MT160WF   ºAutor  ³ Ismael Junior      º Data ³  14/03/19   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ponto de Entrada apos a gravacao do SC8                    º±±
±±º          ³ Sera utilizado para Gravar informacoes Adicionais ao Pedidoº±±  
±±º          ³ de Compras ou aos contratos                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TOTVS STARSOFT                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function MT160WF()
	Local cNumCot 	 		:= PARAMIXB[1]     
	Local cNumped 	 		:= SC7->C7_NUM //SC7->C7_NUMCOT     
	Local cQry 		 		:= "" 
	Local cQuery 	 		:= ""
	Local cNContrato 		:= ""
	Local cAno       		:= Alltrim(Str(Year(Date()))) 
	Local cMes     	 		:= Month2Str(Date())
	Local cCodUser   		:= RetCodUsr() //Retorna o Codigo do Usuario
	Local cNamUser   		:= UsrRetName( cCodUser )//Retorna o nome do usuario 
	Local cPedunico  		:= ""
	Private aCampos			:={ {"CHAV" ,"C", 38,0},;
	{"CCUSTO" ,"C",9,0},;
	{"ITEMCO" ,"C",9,0},;
	{"CLVL" ,"C",20,0},;
	{"CONTA" ,"C",20,0},;
	{"NVLTOT","N",14,2}}  // campos da tabela temporária
	Private oTabTemp		:= Nil 
	Private nStart      := 0

	If funname() <> "CNTA300"
		cQry := " SELECT C8_FILIAL+C8_NUM+C8_ITEM+C8_ITEMGRD+C8_FORNECE+C8_LOJA+C8_FORNOME AS CHAVE, C8_FILIAL+C8_NUM+C8_ITEM AS XOBS,C8_TPDOC,C8_ITEM,C8_NUMPED,C8_NUMCON"
		cQry += " FROM " + RetSqlName("SC8")+ " SC8 "
		cQry += " WHERE C8_NUM = '"+cNumCot+"' "
		cQry += " AND C8_FILIAL = '"+xFilial("SC8")+"' "
		cQry += " AND SC8.D_E_L_E_T_ != '*' "

		If SELECT("TRASC") > 0
			TRASC->(DbCloseArea())
		Endif
		dbUseArea(.T.,"TOPCONN", TcGenQry(,,cQry),"TRASC",.T.,.T.)
		DbSelectArea("TRASC")
		TRASC->(dbGoTop())
		Do While TRASC->(!Eof())
			//Alterado p/ replicar os anexos somente do fornecedor vencedor da cotação / Charles Lima - Starsoft - 06/08/2020
			If TRASC->C8_TPDOC == "1" .And. TRASC->C8_NUMPED <> "XXXXXX" 
				cQuery := "	SELECT AC9_CODOBJ FROM " + RetSqlName("AC9")+ " AC9 WHERE AC9_ENTIDA = 'SC8' AND AC9_CODENT = '"+TRASC->CHAVE+"' "
				If SELECT("TRBAC9") > 0
					TRBAC9->(DbCloseArea())
				Endif
				dbUseArea(.T.,"TOPCONN", TcGenQry(,,cQuery),"TRBAC9",.T.,.T.)
				DbSelectArea("TRBAC9")
				TRBAC9->(dbGoTop())
				Do While TRBAC9->(!Eof())
					RecLock( "AC9", .T. ) 		
					AC9->AC9_FILIAL := xFilial( "AC9" )
					AC9->AC9_FILENT := xFilial( "SC7" )
					AC9->AC9_ENTIDA := "SC7"
					AC9->AC9_CODENT := xFilial( "SC7" )+cNumped+TRASC->C8_ITEM
					AC9->AC9_CODOBJ := TRBAC9->AC9_CODOBJ	
					AC9->(MsUnLock()) // Confirma e finaliza a operação 
					dbSelectArea("TRBAC9")
					TRBAC9->(dbSkip())
				EndDo
			// Alterado p/ replicar os anexos somente do fornecedor vencedor da cotação / Charles Lima - Starsoft - 06/08/2020	
			Elseif TRASC->C8_TPDOC == "2" .And. TRASC->C8_NUMCON <> "XXXXXXXXXXXXXXX"
				cQuery := "	SELECT AC9_CODOBJ FROM " + RetSqlName("AC9")+ " AC9 WHERE AC9_ENTIDA = 'SC8' AND AC9_CODENT = '"+TRASC->CHAVE+"' "
				If SELECT("TRBAC9") > 0
					TRBAC9->(DbCloseArea())
				Endif
				dbUseArea(.T.,"TOPCONN", TcGenQry(,,cQuery),"TRBAC9",.T.,.T.)
				DbSelectArea("TRBAC9")
				TRBAC9->(dbGoTop())    

				cQury := "	SELECT CN9_NUMERO FROM " + RetSqlName("CN9")+ " CN9 WHERE CN9_NUMCOT = '"+cNumCot+"' AND CN9.D_E_L_E_T_ != '*' "
				If SELECT("TRCCN9") > 0
					TRCCN9->(DbCloseArea())
				Endif
				dbUseArea(.T.,"TOPCONN", TcGenQry(,,cQury),"TRCCN9",.T.,.T.)
				DbSelectArea("TRCCN9")
				TRCCN9->(dbGoTop())	
				cNContrato := TRCCN9->CN9_NUMERO
				Do While TRBAC9->(!Eof())
					If !Empty(cNContrato)
						RecLock( "AC9", .T. ) 		
						AC9->AC9_FILIAL := xFilial( "AC9" )
						AC9->AC9_FILENT := xFilial( "CN9" )
						AC9->AC9_ENTIDA := "CN9"
						AC9->AC9_CODENT := cNContrato
						AC9->AC9_CODOBJ := TRBAC9->AC9_CODOBJ	
						AC9->(MsUnLock()) // Confirma e finaliza a operação 
					Endif		
					dbSelectArea("TRBAC9")
					TRBAC9->(dbSkip())
				EndDo 
			Endif	
			cSql := " UPDATE "+ RetSqlName("SC7")+ " SET C7_XOBS = '"+Alltrim(SC8->C8_OBS)+"' WHERE C7_NUM = '"+cNumped+"' AND C7_ITEM = '"+SC8->C8_ITEM+"' AND C7_FILIAL = '"+xFilial("SC7")+"' AND D_E_L_E_T_ != '*' "
			TcSQLExec(cSql)	 
			nStatus := TcSQLExec(cSql)  
			if (nStatus < 0)
				FwLogMsg("MT160WF", /*cTransactionId*/, "MT160WF", FunName(), "","TCSQLError() " + TCSQLError(), 0, (nStart - Seconds()), {})
			endif
			cQury := "	SELECT C7_PRODUTO,C7_ITEM FROM " + RetSqlName("SC7")+ " SC7 WHERE C7_NUM = '"+TRASC->C8_NUMPED+"' AND SC7.D_E_L_E_T_ != '*' "
			If SELECT("TRDSC7") > 0
				TRDSC7->(DbCloseArea())
			Endif
			dbUseArea(.T.,"TOPCONN", TcGenQry(,,cQury),"TRDSC7",.T.,.T.)
			DbSelectArea("TRDSC7")
			TRDSC7->(dbGoTop())	
			Do While TRDSC7->(!Eof())			
				DbSelectArea("SB1")
				SB1->(DbSetOrder(1))
				If (DbSeek(xFilial("SB1")+substr(TRDSC7->C7_PRODUTO,1,TAMSX3("B1_COD")[1])))  
					cSql := " UPDATE "+ RetSqlName("SC7")+ " SET C7_XTPAPL = '"+SB1->B1_XAPROPR+"' WHERE C7_NUM = '"+TRASC->C8_NUMPED+"' AND C7_ITEM = '"+TRDSC7->C7_ITEM+"' AND C7_FILIAL = '"+xFilial("SC7")+"' AND D_E_L_E_T_ != '*' "
					TcSQLExec(cSql)	 
					nStatus := TcSQLExec(cSql)  
					if (nStatus < 0)
						FwLogMsg("MT160WF", /*cTransactionId*/, "MT160WF", FunName(), "","TCSQLError() " + TCSQLError(), 0, (nStart - Seconds()), {})
					endif			   		
				Endif
				dbSelectArea("TRDSC7")
				TRDSC7->(dbSkip())
			EndDo				 		 		 				 					
			dbSelectArea("TRASC")
			TRASC->(dbSkip())
		EndDo

		//****** Controle Orçamentario

		cQry := " SELECT C1_PEDIDO FROM SC1020 SC1 WHERE C1_COTACAO = '"+cNumCot+"' AND C1_FILIAL = '"+xFilial("SC1")+"' AND SC1.D_E_L_E_T_ != '*' "	
		If SELECT("TRASC1") > 0
			TRASC1->(DbCloseArea())
		Endif
		dbUseArea(.T.,"TOPCONN", TcGenQry(,,cQry),"TRASC1",.T.,.T.)
		DbSelectArea("TRASC1")
		TRASC1->(dbGoTop())
		Do While TRASC1->(!Eof())
			If Select("TRB")> 0
				TRB->(DbCloseArea())
			Endif

			oTabTemp := FWTemporaryTable():New("TRB", aEstrut)
			oTabTemp:AddIndex("01", "CHAV+CCUSTO+ITEMCO")
			oTabTemp:Create()

			cQury := "	SELECT C7_PRODUTO,C7_ITEM,C7_CC,C7_ITEMCTA,C7_CLVL,C7_CONTA,C7_TOTAL FROM " + RetSqlName("SC7")+ " SC7 WHERE C7_NUM = '"+TRASC1->C1_PEDIDO+"' AND C7_FILIAL = '"+xFilial("SC7")+"' AND SC7.D_E_L_E_T_ != '*' "
			If SELECT("TRDSC7") > 0
				TRDSC7->(DbCloseArea())
			Endif
			
			dbUseArea(.T.,"TOPCONN", TcGenQry(,,cQury),"TRDSC7",.T.,.T.)
			DbSelectArea("TRDSC7")
			TRDSC7->(dbGoTop())
			If cPedunico <> TRASC1->C1_PEDIDO	
				Do While TRDSC7->(!Eof())
					cPedunico := TRASC1->C1_PEDIDO			 
					cChave := TRDSC7->C7_CC + TRDSC7->C7_ITEMCTA + TRDSC7->C7_CLVL+TRDSC7->C7_CONTA
					TRB->(dbSeek(cChave))
					IF TRB->(EOF())
						reclock("TRB",.T.)
						TRB->CHAV       := cChave
						TRB->NVLTOT     := TRDSC7->C7_TOTAL
						TRB->CCUSTO     := TRDSC7->C7_CC
						TRB->ITEMCO     := TRDSC7->C7_ITEMCTA
						TRB->CLVL      := TRDSC7->C7_CLVL
						TRB->CONTA      := TRDSC7->C7_CONTA
					ELSE
						reclock("TRB",.F.)
						TRB->NVLTOT     := TRB->NVLTOT + TRDSC7->C7_TOTAL
					ENDIF			   	
					dbSelectArea("TRDSC7")
					TRDSC7->(dbSkip())
				EndDo

				TRB->(DbGoTop())
				While TRB->(!EOF())
					nVlpTot := TRB->NVLTOT   // ZW2_VAL"+cMes+"=ZW2_VAL"+cMes+cOpera+Alltrim(Str(nVlZw3))+"
					cUpdate:= " UPDATE " + RetSqlName("ZW2")+" SET ZW2_VAL"+cMes+"=ZW2_VAL"+cMes+"+"+Alltrim(Str(nVlpTot))+" ,ZW2_VLANO = ZW2_VLANO+"+Alltrim(Str(nVlpTot))
					cUpdate+= " WHERE ZW2_CCUSTO = '"+Alltrim(TRB->CCUSTO)+"' "
					cUpdate+= " AND ZW2_ITEMCO = '"+Alltrim(TRB->ITEMCO)+"' "
					cUpdate+= " AND ZW2_CLVL = '"+Alltrim(TRB->CLVL)+"' "
					cUpdate+= " AND ZW2_CONTA = '"+Alltrim(TRB->CONTA)+"' "
					cUpdate+= " AND ZW2_ANO = '"+cAno+"' " 
					cUpdate+= " AND ZW2_FILIAL = '"+xFilial("ZW2")+"' "
					cUpdate+= " AND D_E_L_E_T_ != '*' "
					nFlag := TcSqlExec(cUpdate)

					DbSelectArea("ZW3")
					ZW3->(DbSetOrder(2))
					RecLock("ZW3",.T.)
					ZW3->ZW3_FILIAL := XFILIAL("ZW3")
					ZW3->ZW3_NUM    := GETSX8NUM("ZW3","ZW3_NUM")
					ZW3->ZW3_TIPO   := "D"
					ZW3->ZW3_CCUSTO := TRB->CCUSTO
					ZW3->ZW3_ITEMCO := TRB->ITEMCO
					ZW3->ZW3_ANO    := cAno
					ZW3->ZW3_CLVL   := TRB->CLVL
					ZW3->ZW3_CONTA  := TRB->CONTA
					ZW3->ZW3_DATA   := Date()
					ZW3->ZW3_VALOR  := TRB->NVLTOT
					ZW3->ZW3_ORIGEM := "SC e Pedido de compra"
					ZW3->ZW3_USUARI := cNamUser
					ZW3->ZW3_NUMPED := TRASC1->C1_PEDIDO
					ZW3->ZW3_HISTOR := "Valor ref. pedido: "+TRASC1->C1_PEDIDO
					ZW3->(MsUnLock())
					ConfirmSX8()
					TRB->(Dbskip())					
				Enddo		       
			Endif	
			dbSelectArea("TRASC1")
			TRASC1->(dbSkip())
		EndDo
		//***********************************************************	

	Endif		
	oTabTemp:Delete()	   	 						
Return
