/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FA080CHK  �Autor  �Toni Aguiar         � Data �  27/04/11   ���
�������������������������������������������������������������������������͹��
���Desc.     � Rotina que abre a tela de compensa��o de t�tulos           ���
���          � caso exista pagamentos antecipados no fornecedor           ���
�������������������������������������������������������������������������͹��
���Uso       � SIGAFIN>Atualiza��es>Contas a Pagar>Baixa a pagar manual   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function FA080CHK
   Local lRet:=.T.
   Local nAdto_:=0
   If GetNewPar("MV_VLTITAD",.F.) .And. !(SE2->E2_TIPO $ MVPAGANT+"/"+MV_CPNEG)
      nAdto_:= F090BuscAD( "SE2", SE2->E2_FORNECE, SE2->E2_LOJA )
      If nAdto_<>0 
         If MsgYesNo("Deseja compensa-los agora?","Aten��o!!!")
            lRet:=.F.
            Fina340(3)
         Endif
      Endif
   Endif
Return lRet
