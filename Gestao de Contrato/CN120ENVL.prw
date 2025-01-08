#INCLUDE "protheus.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CN120ENVL �Autor  � Ismael Junior - STARSOFT em 22/03/2019  ���
�������������������������������������������������������������������������͹��
���Desc.     � Ponto de entrada para tratamento de campos espec�ficos     ���
���          � na gera��o do pedido de compras.                           ���
���A��o:     � Grava na Array dos itens a gerar o pedido de compras, a    ���
���          � observa��o da medi��o dos contratos                        ���
���          �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � SIGAGCT>Atualiza��es>Movimentos>Medi��es/Entregas>CNTA120  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������    
*/
User Function CN120ENVL()
	Local lRet := .T. 
	Local aGetAre := GetArea()
	Local aCN9Are := CN9->(GetArea())
	Local aCNDAre := CND->(GetArea())

	dbSelectArea("CN9")
	CN9->(dbSetOrder(1))
	CN9->(dbSeek(CND->CND_FILIAL + CND->CND_CONTRA + CND->CND_REVISA))
	
	/*
	cSql := " UPDATE " + RetSqlName("SAL")+ " SET AL_DOCPC = 'T',AL_DOCIP = 'T',AL_DOCCT = 'T',AL_DOCGA = 'T' WHERE AL_DOCPC <> 'T' AND AL_DOCMD = 'T' AND D_E_L_E_T_ != '*' " 
	TcSQLExec(cSql)
	nStatus := TcSQLExec(cSql)
	// TcSQLExec("COMMIT")
	   
	if (nStatus < 0)
		conout("TCSQLError() " + TCSQLError())
	endif
	*/
	If CN9->CN9_XGLOBA == "N" .And. !(IsInCallStack('U_IACOMP01'))
		lRet := .F.
		Help( ,, 'Help',, 'N�o e permitido estornar ou encerrar por esta rotina um contrato Nacional. Verifique!',1,0)
	EndIf
	
	RestArea(aCNDAre)
	RestArea(aCN9Are)
	RestArea(aGetAre)

Return(lRet) 
