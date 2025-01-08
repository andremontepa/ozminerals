#INCLUDE "protheus.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MT110VLD  ºAutor  ³ Ismael Junior - STARSOFT em 18/04/2019  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Localizado na Solicitação de Compras, este ponto de entrada
 é responsável em validar o registro posicionado da Solicitação de Compras
antes de executar as operações de inclusão, alteração, exclusão e cópia. 
Se retornar .T., deve executar as operações de inclusão, alteração, 
exclusão e cópia ou .F. para interromper o processo.                      º±±
±±º          ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAGCT>Atualizações>Movimentos>Medições/Entregas>CNTA120  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß    
*/
User Function MT110VLD()
Local ExpN1    := Paramixb[1]
Local ExpL1    := .T.   

If ExpN1 == 4
   //	cSql := " UPDATE "+ RetSqlName("DBM")+ " SET D_E_L_E_T_ = '*' WHERE DBM_NUM = '"+SC1->C1_NUM+"' AND DBM_FILIAL = '"+xFilial("DBM")+"' AND D_E_L_E_T_ != '*' "
   	cSql := " DELETE FROM "+ RetSqlName("DBM")+ " WHERE DBM_NUM = '"+SC1->C1_NUM+"' AND DBM_FILIAL = '"+xFilial("DBM")+"' "
	TcSQLExec(cSql) 
	nStatus := TcSQLExec(cSql)  
	  if (nStatus < 0)
	    conout("TCSQLError() " + TCSQLError())
	  endif
Endif
Return ExpL1