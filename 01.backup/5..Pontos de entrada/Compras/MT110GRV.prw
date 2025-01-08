#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} MT110GRV
MT110GRV - Ponto de Entrada execurado no final da grava��o de cada item da SC.
@type function
@author Ricardo Tavares Ferreira
@since 16/04/2021
@version 12.1.27
@link https://tdn.totvs.com/display/public/PROT/MT110GRV
@obs LOCALIZA��O : Function A110GRAVA - Fun��o da Solicita��o de Compras responsavel pela grava��o das SCs.
EM QUE PONTO : No laco de grava��o dos itens da SC na fun��o A110GRAVA, executado ap�s gravar o item da SC, 
a cada item gravado da SC o ponto � executado.
@history 16/04/2021, Ricardo Tavares Ferreira, Constru��o Inicial.
/*/
//=============================================================================================================================
    User Function MT110GRV()
//=============================================================================================================================

    Local aArea := GetArea()

    APIUtil():GravaDataHora("SC1",{SC1->(Recno())},{"C1_XDTALT","C1_XHRALT"})
    RestArea(aArea)
Return Nil 
