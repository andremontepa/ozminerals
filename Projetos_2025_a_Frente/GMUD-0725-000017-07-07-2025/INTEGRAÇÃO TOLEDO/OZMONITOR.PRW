//Bibliotecas
#Include "Protheus.ch"
 
/*/{Protheus.doc} zTeste
Função de Teste
@type function
@author Terminal de Informação
@since 13/11/2016
@version 1.0
    @example
    u_zTeste()
/*/
 
User Function OZMONITOR()
    Local aArea    := GetArea()
    Local aArea25  := Z25->(GetArea())
    Local cDelOk   := ".T."
    Local cFunTOk  := ".T." //Pode ser colocado como "u_zVldTst()"
 
    //Chamando a tela de cadastros
    AxCadastro('Z25', 'MONITOR TOLEDO', cDelOk, cFunTOk)
 
    RestArea(aArea25)
    RestArea(aArea)
Return
