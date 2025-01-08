#Include "Protheus.ch"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � M310CABEC �Autor  �Ismael Junior        � Data �  09/11/21 ���
�������������������������������������������������������������������������͹��
���Desc.     �  � utilizado para permitir que o usu�rio manipule o array  ���
���Desc.     �  aCabec que cont�m os itens do cabe�alho do pedido de      ���
���Desc.     �  vendas, documento de entrada ou fatura de entrada.        ���
�������������������������������������������������������������������������͹��
�����������������������������������������������������������������������������
*/
User Function M310CABEC
    Local cProg := PARAMIXB[1]
    Local aCabec := PARAMIXB[2]
  //  Local aPar := PARAMIXB[3]
    If cProg == 'MATA410'    
        aadd(aCabec,{'C5_ESPECI1',NNS->NNS_XESPEC,Nil})
        aadd(aCabec,{'C5_VOLUME1',NNS->NNS_XVOLUM,Nil})
        aadd(aCabec,{'C5_PESOL',NNS->NNS_XPESOL,Nil})
        aadd(aCabec,{'C5_PBRUTO',NNS->NNS_XPBRUT,Nil}) 
        aadd(aCabec,{'C5_VEICULO',NNS->NNS_XVEICU,Nil})
        aadd(aCabec,{'C5_TRANSP ',NNS->NNS_XTRANS,Nil}) 
        aadd(aCabec,{'C5_TPFRETE',NNS->NNS_XTPFRE,Nil})
        //aadd(aCabec,{'C5_XMENNFE',NNS->NNS_XMENNF,Nil})
    Endif
Return(aCabec)
