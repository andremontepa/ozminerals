#Include 'Totvs.ch'
#Include 'Protheus.ch'         
#INCLUDE "TOPCONN.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FunNumPC  �Autor  �Leonardo Medeiros   � Data �  05/03/18   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Pedido de Compras                                          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/


user function funNumPC 

   cSeqCli := GETMV("MV_XSC7")   
   cSeqCli := alltrim(str(val(cSeqCli) + 1))
   cSeqCli := PADL(cSeqCli,6,"0")
   PUTMV("MV_XSC7",cSeqCli)    
   
return cSeqCli   
		/*
		cSql := "SELECT MAX(C7_NUM)+1 NUMATUAL FROM "+RetSqlName("SC7")
		cSql += " WHERE C7_FILIAL = '" + xFilial('SC7') + "' " 
			
		If Select("TMP") > 0
		 TMP->(DbCloseArea())
		Endif
		
		TCQUERY cSql NEW ALIAS "TMP" 
		
		cXNum := padl(TMP->NUMATUAL,6,"0")
        
return cXNum
*/