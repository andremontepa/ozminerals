#include 'protheus.ch'
#include 'parmtype.ch'

//--------------------------------------------------------------

/*/{STARSOFT INFORM�TICA LTDA} FA420CRI
	Ponto de Entrada com fun��o de declarar as var�veis nWsomaJurMul e nWsomaOutras para utiliza��o
	na gera��o da remessa do CNAB de pagamento. 

 
@return L�gico 
@author Lucas Costa
@since 21/01/2020
/*/

//--------------------------------------------------------------

User Function FA420CRI()
Public nWsomaJurMul := 0
Public nWsomaOutras := 0

Return .T. 