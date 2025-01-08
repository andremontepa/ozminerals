#INCLUDE "protheus.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MT094CCR  ºAutor  ³ Ismael Junior - STARSOFT em 26/03/2019  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ O Ponto de Entrada MT094CCR tem como funcionalidade exibir º±±
±±			 ³	 informações de outros campos da alçada no momento da 	     º±±
±±			 ³	 liberação do documento.                          		        º±±
±±º			 ³															                 º±±
±±ºAção:     ³ A chamada do Ponto de Entrada MT094CCR ocorre ao acionar   º±±
±±º          ³     o botão "Aprovar", na rotina Liberação de Documentos   º±±
±±º          ³     (MATA094).                                             º±±
±±º          ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ 															  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß    
*/
User Function MT094CCR()
Local cLisCmp := "" 
Local cCodEmp := FWCodEmp()
Local cDelete := ""
Local QbLinha := chr(13)+chr(10)
Private nStart      := 0

	cDelete := " DELETE FROM " +RetSqlName("DBM")
	cDelete += " WHERE DBM_FILIAL = '"+SCR->CR_FILIAL+"'  "+QbLinha
	cDelete += " AND   DBM_NUM	= '"+SCR->CR_NUM+"' "+QbLinha
	cDelete += " AND   DBM_TIPO	= '"+SCR->CR_TIPO+"' "+QbLinha

	TCSQLExec(cDelete)

	If ALLTRIM(SCR->CR_TIPO)$ "CT/RV"
		cLisCmp += 'CR_XDTINIC|CR_XREVISA|CR_XDTFIM|CR_XDTREV|'
		cLisCmp += 'CR_XSALDO|CR_XVLINI|CR_XVLATU|CR_XVLADIT|'
		cLisCmp += 'CR_XCODOBJ|CR_XCODCLA|CR_XCODJUS|CR_XGLOBA'
	Endif
	
If cCodEmp == "02"
   cSql := " UPDATE "+ RetSqlName("DBM")+ " SET D_E_L_E_T_ = '' WHERE DBM_NUM = '"+SCR->CR_NUM+"' AND DBM_FILIAL = '"+xFilial("DBM")+"' AND DBM_XFLAG='' AND DBM_USER = '"+__cUserId+"' "
   TcSQLExec(cSql) 
   nStatus := TcSQLExec(cSql)  
   if (nStatus < 0)
	   FwLogMsg("MT094CCR", /*cTransactionId*/, "MT094CCR", FunName(), "","TCSQLError() " + TCSQLError(), 0, (nStart - Seconds()), {})
   endif 	              
Endif

//Verificar item na SC disponivel
cQry5 := " SELECT TOP 1 C1_ITEM FROM "+ RetSqlName("SC1")+ " SC1 WHERE C1_NUM = '"+SCR->CR_NUM+"' AND C1_FILIAL = '"+xFilial("SC1")+"'  AND SC1.D_E_L_E_T_ != '*' "			
If SELECT("TRSC1") > 0
   TRSC1->(DbCloseArea())
Endif
dbUseArea(.T.,"TOPCONN", TcGenQry(,,cQry5),"TRSC1",.T.,.T.)
DbSelectArea("TRSC1")
TRSC1->(dbGoTop()) 

//******************* verifica se dbm foi criada *******************   18/09/2019
If SCR->CR_TIPO = 'SC'
   cQry4 := " SELECT DBM_NUM FROM "+ RetSqlName("DBM")+ " DBM WHERE DBM_NUM = '"+SCR->CR_NUM+"' AND DBM_FILIAL = '"+xFilial("DBM")+;
            "' AND DBM_GRUPO+DBM_ITEM = '"+SCR->CR_GRUPO+TRSC1->C1_ITEM+"' AND DBM_USER = '"+__cUserId+"' AND D_E_L_E_T_ != '*' " 
            // - Retirado o xFlag da Query 09/07/2021
            //"' AND DBM_GRUPO+DBM_ITEM = '"+SCR->CR_GRUPO+TRSC1->C1_ITEM+"' AND DBM_USER = '"+__cUserId+"' AND DBM_XFLAG='' AND D_E_L_E_T_ != '*' " 
		
   If SELECT("TRADBM") > 0
      TRADBM->(DbCloseArea())
   Endif
   dbUseArea(.T.,"TOPCONN", TcGenQry(,,cQry4),"TRADBM",.T.,.T.)
   DbSelectArea("TRADBM")
   TRADBM->(dbGoTop()) 
   If Empty(TRADBM->DBM_NUM)
      cQry4 := " SELECT CR_NUM,CR_GRUPO,CR_ITGRP,CR_USER,CR_APROV,CR_TOTAL "
	   cQry4 += " FROM "+RetSqlName("SCR")+" "
      cQry4 += " WHERE CR_NUM = '"+SCR->CR_NUM+"' AND CR_FILIAL = '"+SCR->CR_FILIAL+"' AND CR_TIPO = 'SC'  AND CR_USER = '"+__cUserId+"' AND D_E_L_E_T_ != '*' " 
      // - Retirado o xFlag da Query 09/07/2021
      //cQry4 += " WHERE CR_NUM = '"+SCR->CR_NUM+"' AND CR_FILIAL = '"+SCR->CR_FILIAL+"' AND CR_TIPO = 'SC'  AND CR_USER = '"+__cUserId+"' AND CR_XFLAG='' AND D_E_L_E_T_ != '*' " 

      If SELECT("TRACR") > 0
         TRACR->(DbCloseArea())
      Endif
 
      dbUseArea(.T.,"TOPCONN", TcGenQry(,,cQry4),"TRACR",.T.,.T.)
      DbSelectArea("TRACR")
      TRACR->(dbGoTop())

      RecLock("DBM",.T.)
      DBM->DBM_FILIAL     := xFilial("DBM")
      DBM->DBM_TIPO := 'SC'
      DBM->DBM_NUM := TRACR->CR_NUM
      DBM->DBM_ITEM := TRSC1->C1_ITEM
      DBM->DBM_GRUPO := TRACR->CR_GRUPO
      DBM->DBM_ITGRP := TRACR->CR_ITGRP
      DBM->DBM_USER := TRACR->CR_USER
      DBM->DBM_APROV := '2'
      DBM->DBM_USAPRO := TRACR->CR_APROV
      DBM->DBM_VALOR := TRACR->CR_TOTAL
      DBM->DBM_XFLAG  := '1'
      DBM->(msUnLock()) 
   Endif
Endif			

Return (cLisCmp)
