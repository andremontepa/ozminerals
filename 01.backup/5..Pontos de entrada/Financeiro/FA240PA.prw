#Include  'Protheus.ch'

//Alert: Ponto de entrada que permite inclus�o de PA com movimento banc�rio em border� de pagamento. 
 
    User Function __FA240PA()
 
Local lRet  :=  .T.  // .T. - para o sistema permitir a sele��o de PA (com mov. Banc�rio) na tela de border� de pagamento e
                     // .F. - para n�o permitir.
 
lRet :=  MsgYesNo("Permite selecionar PA? ","PONTO DE ENTRADA - FA240PA")
 
Return lRet
