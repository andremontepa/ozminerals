#include 'protheus.ch'
#include 'parmtype.ch'

//--------------------------------------------------------------

/*/{STARSOFT INFORMÁTICA LTDA} FA420CRI
	Ponto de Entrada com função de declarar as varáveis nWsomaJurMul e nWsomaOutras para utilização
	na geração da remessa do CNAB de pagamento. 

 
@return Lógico 
@author Lucas Costa
@since 21/01/2020
/*/

//--------------------------------------------------------------

User Function FA420CRI()
Public nWsomaJurMul := 0
Public nWsomaOutras := 0

Return .T. 