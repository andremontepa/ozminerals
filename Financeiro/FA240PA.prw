#Include  'Protheus.ch'

//Alert: Ponto de entrada que permite inclusão de PA com movimento bancário em borderô de pagamento. 
 
    User Function __FA240PA()
 
Local lRet  :=  .T.  // .T. - para o sistema permitir a seleção de PA (com mov. Bancário) na tela de borderô de pagamento e
                     // .F. - para não permitir.
 
lRet :=  MsgYesNo("Permite selecionar PA? ","PONTO DE ENTRADA - FA240PA")
 
Return lRet
