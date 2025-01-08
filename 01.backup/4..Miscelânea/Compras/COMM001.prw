#Include "TOPCONN.CH" 
#Include "RWMAKE.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �COMM001   �Autor  � Toni Aguiar        � Data �  26/04/17   ���
�������������������������������������������������������������������������͹��
���Desc.     � Atualiza o ponto de pedido para emiss�o do relat�rio       ���
���          � Itens em ponto de pedidos e solicita��o de compras         ���
�������������������������������������������������������������������������͹��
���Uso       � TOTVS STARSOFT                                             ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function COMM001()
Local cSql             
Local cQry
Local Titulo:="Atualiza o ponto de pedido para gerar as solicita��es de compras"   

cQry := "UPDATE "+RetSqlName("SB1")+" SET B1_LE = 0 WHERE B1_XAPROPR='I' AND D_E_L_E_T_<>'*' "
TcSqlExec(cQry)
TcSqlExec("Commit")

cSql:="SELECT DISTINCT B1_COD,B1_DESC,B1_LOCPAD,SUM(B2_QATU) AS B1_QATU, MAX(B1_EMIN) AS B1_EMIN, MAX(B1_EMAX) AS B1_EMAX "
cSql+="           FROM SB1010 SB1 "
cSql+="     INNER JOIN SB2010 SB2 ON SB2.B2_FILIAL='02' AND SB2.B2_COD=SB1.B1_COD AND SB2.D_E_L_E_T_<>'*' "
cSql+="          WHERE SB1.B1_XAPROPR='I' AND SB1.B1_EMIN>0 AND SB2.B2_QATU < SB1.B1_EMIN AND SB1.B1_EMAX>0 AND SB1.D_E_L_E_T_<>'*' "
cSql+="       GROUP BY B1_COD,B1_DESC,B1_LOCPAD "
cSql+="       ORDER BY B1_COD "
cSql:=ChangeQuery(cSql)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"TRB",.F.,.T.)

RptStatus({|| RunProc() },Titulo)
Return        

Static Function RunProc()
Local nTolera
Local nReposicao

dbSelectArea("TRB")
TRB->(dbGoTop())
SetRegua(TRB->(Reccount()))                

Do While !TRB->(Eof())
   IncRegua("Atualizando produto -> "+TRB->B1_COD+"...")  
   
   If SB1->(dbSeek(xFilial("SB1")+TRB->B1_COD))
      nTolera    := TRB->(B1_EMAX-B1_EMIN)      // Toler�ncia
      nReposicao := TRB->(B1_EMIN-B1_QATU)      // Qual a reposi��o pelo ponto de pedido.
      
      RecLock("SB1",.F.)
      SB1->B1_LE := (nTolera + nReposicao)
      SB1->(MsUnLock())
   Endif
   TRB->(dbSkip())
Enddo
Alert("Ponto de pedido atualizado com sucesso!")
TRB->(dbCloseArea())
Return
