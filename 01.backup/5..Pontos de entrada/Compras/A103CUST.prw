
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �A103CUST  �Autor  � Toni Aguiar        � Data �  23/03/17   ���
�������������������������������������������������������������������������͹��
���Desc.     � Ajusta o custo do produto pelo DOC. DE ENTRADA acrescentando���
���          � 35% de des�gio, caso configure a TES F4_CREDICM='S' e      ���
���          � F4_XDESGI='S', do contr�rio, assume o custo padr�o.        ���
���          �                                                            ���
���          � O Kardex ficar� com o la�amento ajustado automaticamente   ���
���          � j� acrescentado os 35%.                                    ���
���          � Em rela��o ao LP cont�bil, este deve ser configurado para  ���
���          � contabilizar o valor de des�gio debitando a conta de estoque���
���          � e creditando a conta de ICMS A RECUPERAR.                  ���
���          �                                                            ���
���          � Fiscalmente n�o muda nada do padr�o, ser� modificado apenas���
���          � o custo de entrada no kardex e na contabilidade.           ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function A103CUST 
Local aRet  := PARAMIXB[1]
Local nIcms := SD1->D1_VALICM

If SF4->F4_ESTOQUE="S" .And. SF4->F4_CREDICMS=='S' .And. SF4->F4_XDESAGI=='S'
   aRet[1][1]+=NoRound((nIcms * 100)/100,2) 
   aRet[1][2]+=nIcms/RecMoeda(dDataBase,2)  
Endif

Return aRet
