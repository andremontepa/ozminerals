
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MA130KEY  �Autor  �Toni Aguiar - TOTVS STARSOFR em 08/05/19 ���
�������������������������������������������������������������������������͹��
���Desc.     � Ordena Arquivos de trabalho ( < PARAMIXB> ) --> cRet       ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
                                     
User Function MA131KEY()
Local cRet := ''
Local cKey := ParamIXB[1]
	
If 'C1_OK' $ Upper( cKey ) 
   cRet := 'C1_FILIAL+C1_OK+C1_GRADE+C1_FORNECE+C1_LOJA+C1_PRODUTO+C1_DESCRI+Dtos(C1_DATPRF)+C1_ITEM+C1_CC+C1_CONTA+C1_ITEMCTA+C1_CLVL+C1_FILENT'
Else 
   cRet := 'C1_FILIAL+C1_GRADE+C1_FORNECE+C1_LOJA+C1_PRODUTO+C1_DESCRI+Dtos(C1_DATPRF)+C1_ITEM+C1_CC+C1_CONTA+C1_ITEMCTA+C1_CLVL+C1_FILENT'
EndIf
Return cRet
