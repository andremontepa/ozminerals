#INCLUDE "protheus.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MT110VLD  �Autor  � Ismael Junior - STARSOFT em 18/04/2019  ���
�������������������������������������������������������������������������͹��
���Desc.     � Localizado na Solicita��o de Compras, este ponto de entrada
 � respons�vel em validar o registro posicionado da Solicita��o de Compras
antes de executar as opera��es de inclus�o, altera��o, exclus�o e c�pia. 
Se retornar .T., deve executar as opera��es de inclus�o, altera��o, 
exclus�o e c�pia ou .F. para interromper o processo.                      ���
���          �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � SIGAGCT>Atualiza��es>Movimentos>Medi��es/Entregas>CNTA120  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������    
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