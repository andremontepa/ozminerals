#Include "Protheus.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ M310CABEC ºAutor  ³Ismael Junior        º Data ³  09/11/21 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  É utilizado para permitir que o usuário manipule o array  º±±
±±ºDesc.     ³  aCabec que contém os itens do cabeçalho do pedido de      º±±
±±ºDesc.     ³  vendas, documento de entrada ou fatura de entrada.        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
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
