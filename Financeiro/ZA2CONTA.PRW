//Bibliotecas
#Include "Protheus.ch"
 
//--------------------------------------------------------------

/*/{STARSOFT INFORMÁTICA LTDA} ZA2CONTA
	Fonte para tratativa do campo A2_NUMCON para preenchimento de zeros a esquerda 
  quando for alterado ou incluído na rotina de cadastro de fornecedores em MVC.

  Para utilização do fonte, criar um gatilho no campo A2_NUMCON p/ A2_NUMCON com a regra 
  u_ZA2CONTA()

 
@return Lógico 
@author Lucas Costa
@since 31/05/2021
/*/

//--------------------------------------------------------------
 
User Function ZA2CONTA()
    Local cCampo    := "A2_NUMCON"
    Local nTamanho  := TamSX3(cCampo)[1]
    Local cConteudo := PadL(AllTrim(FwFldGet(cCampo)), nTamanho, '0')
    Local cRetorno  := ' '
 
    //Função FwFldPut para posicionar no campo destino o conteúdo da variável cConteudo 
    FwFldPut(cCampo, cConteudo,,,, .T.)

Return cRetorno
