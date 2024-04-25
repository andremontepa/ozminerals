#INCLUDE "protheus.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MT094END  ºAutor  ³ Ismael Junior - STARSOFT em 02/04/2019  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ponto de entrada para tratamento de campos específicos     º±±
±±º          ³ na LINERAÇÃO DE DOCUMENTOS.                                º±±
±±º          ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAGCT>Atualizações>Movimentos>Medições/Entregas>CNTA120  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß    
*/
User Function MT094END()
Local cDocto  := PARAMIXB[1]
Local cTipo   := PARAMIXB[2]
Local nOpc    := PARAMIXB[3]
Local cFilDoc := PARAMIXB[4]
Local cCodEmp := FWCodEmp()
Local cSql := "" 
Local cUsuario := __cUserId      
Local cUsOld
Local aRet    
Local cDepto        
Local cCodUsr      

Private nStart      := 0

PswOrder(2)           
PswSeek(cUserName) 
aRet    := PswRet(1)
cDepto  := Alltrim(Upper(aRet[1][12]))

// Elimina registros da DBM
If nOpc == 1 .and. cTipo == 'SC'
   //Verificar item na SC disponivel   TRSC1->C1_ITEM
   cQry5 := " SELECT TOP 1 C1_ITEM FROM "+ RetSqlName("SC1")+ " SC1 WHERE C1_NUM = '"+cDocto+"' AND C1_FILIAL = '"+xFilial("SC1")+"' AND SC1.D_E_L_E_T_ != '*' "			
   If SELECT("TRSC1") > 0
      TRSC1->(DbCloseArea())
   Endif
   
   // Permance com apenas um item por grupo de aprovação, deletando os demais, gerado pela rotina padrão
   dbUseArea(.T.,"TOPCONN", TcGenQry(,,cQry5),"TRSC1",.T.,.T.)
   DbSelectArea("TRSC1")
   TRSC1->(dbGoTop())		   
   cSql := " UPDATE "+ RetSqlName("DBM")+ " SET D_E_L_E_T_ = '*' WHERE DBM_NUM = '"+cDocto+"' AND DBM_FILIAL = '"+xFilial("DBM")+"' AND DBM_GRUPO+DBM_ITEM <> '"+SCR->CR_GRUPO+TRSC1->C1_ITEM+"' AND DBM_XFLAG='' AND D_E_L_E_T_ != '*' "
   TcSQLExec(cSql) 
   nStatus := TcSQLExec(cSql)  
   if (nStatus < 0)
	   FwLogMsg("MT094END", /*cTransactionId*/, "MT094END", FunName(), "","TCSQLError() " + TCSQLError(), 0, (nStart - Seconds()), {})
   endif	 
Endif 

// Verifica se ainda há algum aprovador pendente no controle de alçada para aprovação	
//cQry2 := " SELECT CR_NUM FROM "+ RetSqlName("SCR")+ " SCR WHERE CR_NUM = '"+SCR->CR_NUM+"' AND CR_DATALIB = '' AND CR_XFLAG='' AND SCR.D_E_L_E_T_ != '*' " 
cQry2 := " SELECT CR_NUM FROM "+ RetSqlName("SCR")+ " SCR WHERE CR_NUM = '"+SCR->CR_NUM+"' AND CR_DATALIB = '' AND SCR.D_E_L_E_T_ != '*' " 

If SELECT("TRASCR") > 0
   TRASCR->(DbCloseArea())
Endif

dbUseArea(.T.,"TOPCONN", TcGenQry(,,cQry2),"TRASCR",.T.,.T.)
DbSelectArea("TRASCR")
TRASCR->(dbGoTop())        

// Se nouver algum aprovador pendente de aprovação
// e a SC já estiver toda aprovada, a rotina bloqueia novamente toda SC.
If !Empty(TRASCR->CR_NUM)	
	 
   cQry3 := " SELECT C1_NUM FROM "+ RetSqlName("SC1")+ " SC1 WHERE C1_NUM = '"+SCR->CR_NUM+"' AND C1_APROV = 'L' AND SC1.D_E_L_E_T_ != '*' " 
   If SELECT("TRASC1") > 0
      TRASC1->(DbCloseArea())
   Endif

   dbUseArea(.T.,"TOPCONN", TcGenQry(,,cQry3),"TRASC1",.T.,.T.)
   DbSelectArea("TRASC1")
   TRASC1->(dbGoTop()) 
   If !Empty(TRASC1->C1_NUM)
      cSql := " UPDATE "+ RetSqlName("SC1")+ " SET C1_APROV = 'B' WHERE C1_NUM = '"+SCR->CR_NUM+"' AND C1_FILIAL = '"+xFilial("SC1")+"' AND D_E_L_E_T_ != '*' "
      TcSQLExec(cSql) 
      nStatus := TcSQLExec(cSql)  
      if (nStatus < 0)
	      FwLogMsg("MT094END", /*cTransactionId*/, "MT094END", FunName(), "","TCSQLError() " + TCSQLError(), 0, (nStart - Seconds()), {})
      endif	 
   Endif
Endif

If nOpc == 1 .and. cTipo == 'SC'
   cQry1 := " SELECT R_E_C_N_O_ AS C1RECNUM,C1_APROV,C1_CC,C1_ITEMCTA,C1_CLVL "
   cQry1 += " FROM "+ RetSqlName("SC1")+ " SC1 "
   cQry1 += " WHERE C1_NUM = '"+cDocto+"' "
   cQry1 += " AND C1_FILIAL = '"+xFilial("SC1")+"' AND SC1.D_E_L_E_T_ != '*' "
   If SELECT("TRASC1") > 0
      TRASC1->(DbCloseArea())
   Endif
   dbUseArea(.T.,"TOPCONN", TcGenQry(,,cQry1),"TRASC1",.T.,.T.)
   DbSelectArea("TRASC1")
   TRASC1->(dbGoTop())
   Do While TRASC1->(!Eof())
      cQry2 := " SELECT AL_APROV,AL_NIVEL,AL_USER,DBL_CC,DBL_ITEMCT,DBL_CLVL " 
      cQry2 += " FROM "+ RetSqlName("SAK")+ " SAK "
      cQry2 += " INNER JOIN "+ RetSqlName("SAL")+ " SAL ON AL_USER = AK_USER AND AL_DOCSC = 'T' AND SAL.D_E_L_E_T_ != '*' "
      cQry2 += " INNER JOIN "+ RetSqlName("DBL")+ " DBL ON AL_COD = DBL_GRUPO AND DBL_CC = '"+TRASC1->C1_CC+"' AND DBL_ITEMCT = '"+TRASC1->C1_ITEMCTA+"' AND DBL_CLVL = '"+TRASC1->C1_CLVL+"' AND DBL.D_E_L_E_T_ != '*' "
      cQry2 += " WHERE AK_USER = '"+cUsuario+"' "
      cQry2 += " AND SAK.D_E_L_E_T_ != '*' "
	
      If SELECT("TRASAK") > 0
         TRASAK->(DbCloseArea())
      Endif
      dbUseArea(.T.,"TOPCONN", TcGenQry(,,cQry2),"TRASAK",.T.,.T.)
      DbSelectArea("TRASAK")
      TRASAK->(dbGoTop())
      
      // Em casos de produtos indiretos, a rotina deve submeter também à aprovação do grupo de almoxarifado.
      // Neste caso, o grupo de almoxarifado é incluído através do ponto de Entrada M110STTS que avalia se há ou não produtos indiretos na SC. 
      cValidaAmx:=IIf(cDepto=='ALMOXARIFADO'.And.SCR->CR_XFLAG=='1', '1', '2')
      Do While TRASAK->(!Eof()) .Or. cValidaAmx='1'
	     
	     If cValidaAmx<>'1'                                                           
	        // Para casos normais de grupos de aprovação
            cSql := " UPDATE "+ RetSqlName("SCR")+ " SET CR_USERLIB = '"+TRASAK->AL_USER+"',CR_LIBAPRO ='"+TRASAK->AL_APROV+"',CR_VALLIB = CR_TOTAL,CR_TIPOLIM = 'D',CR_STATUS = '03',CR_DATALIB = CONVERT(CHAR(8),GETDATE(),112) "
            //cSql += "  WHERE CR_NUM = '"+cDocto+"' AND CR_FILIAL = '"+xFilial("SCR")+"' AND CR_NIVEL = '"+TRASAK->AL_NIVEL+"' AND CR_XFLAG='' AND D_E_L_E_T_ != '*' "
            cSql += "  WHERE CR_NUM = '"+cDocto+"' AND CR_FILIAL = '"+xFilial("SCR")+"' AND CR_NIVEL = '"+TRASAK->AL_NIVEL+"' AND D_E_L_E_T_ != '*' "
         Else  
            // Para casos em que houve produtos indiretos na SC, neste caso, deve-se submeter à aprovação do Almoxarifado também.                                                                                    
            cSql := " UPDATE "+ RetSqlName("SCR")+ " SET CR_USERLIB = '"+cUsuario+"',CR_LIBAPRO ='"+SCR->CR_APROV+"',CR_VALLIB = CR_TOTAL,CR_TIPOLIM = 'D',CR_STATUS = '03',CR_DATALIB = CONVERT(CHAR(8),GETDATE(),112) "
            cSql += "  WHERE CR_NUM = '"+cDocto+"' AND CR_FILIAL = '"+xFilial("SCR")+"' AND CR_NIVEL = '"+SCR->CR_NIVEL+"' AND D_E_L_E_T_ != '*' " 
            cValidaAmx="2"
         Endif
         
         TcSQLExec(cSql) 
         nStatus := TcSQLExec(cSql)  
         if (nStatus < 0)
	         FwLogMsg("MT094END", /*cTransactionId*/, "MT094END", FunName(), "","TCSQLError() " + TCSQLError(), 0, (nStart - Seconds()), {})
         endif	
	   
         cQry2 := " SELECT COUNT(CR_NUM) QUANT FROM "+ RetSqlName("SCR")+ " SCR "
         cQry2 += " WHERE CR_NUM = '"+cDocto+"' " 
         cQry2 += " AND CR_TIPO = 'SC'  
         cQry2 += " AND CR_DATALIB = ''
         //cQry2 += " AND CR_XFLAG = ''
         cQry2 += " AND SCR.D_E_L_E_T_ != '*'
         If SELECT("TRASCR") > 0
            TRASCR->(DbCloseArea())
         Endif

         dbUseArea(.T.,"TOPCONN", TcGenQry(,,cQry2),"TRASCR",.T.,.T.)
         DbSelectArea("TRASCR")
         TRASCR->(dbGoTop())
         If Empty(TRASCR->QUANT) 
            cSql := " UPDATE "+RetSqlName("SC1")+" SET C1_APROV = 'L' WHERE C1_NUM = '"+cDocto+"' AND C1_FILIAL = '"+xFilial("SC1")+"' AND D_E_L_E_T_ != '*' "
            TcSQLExec(cSql)	 
            nStatus := TcSQLExec(cSql)  
            if (nStatus < 0)
	            FwLogMsg("MT094END", /*cTransactionId*/, "MT094END", FunName(), "","TCSQLError() " + TCSQLError(), 0, (nStart - Seconds()), {})
            endif
         Endif  
		     
         dbSelectArea("TRASAK")
         TRASAK->(dbSkip())
      EndDo 
		
      dbSelectArea("TRASC1")
      TRASC1->(dbSkip())
   EndDo	
Endif
Return
