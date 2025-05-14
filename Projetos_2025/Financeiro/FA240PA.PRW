#Include  'Protheus.ch'


/*/{Protheus.doc} FA240PA
description
@type function
@version  
@author USER
@since 28/03/2022
@return variant, return_description
/*/ 
User Function FA240PA()
 
Local lRet  :=  .T.  // .T. - para o sistema permitir a seleção de PA (com mov. Bancário) na tela de borderô de pagamento e
 
                             // .F. - para não permitir.
 
//lRet :=  MsgYesNo("Permite selecionar PA? ","PONTO DE ENTRADA - FA240PA")
 
Return lRet
