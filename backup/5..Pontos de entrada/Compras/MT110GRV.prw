#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} MT110GRV
MT110GRV - Ponto de Entrada execurado no final da gravação de cada item da SC.
@type function
@author Ricardo Tavares Ferreira
@since 16/04/2021
@version 12.1.27
@link https://tdn.totvs.com/display/public/PROT/MT110GRV
@obs LOCALIZAÇÃO : Function A110GRAVA - Função da Solicitação de Compras responsavel pela gravação das SCs.
EM QUE PONTO : No laco de gravação dos itens da SC na função A110GRAVA, executado após gravar o item da SC, 
a cada item gravado da SC o ponto é executado.
@history 16/04/2021, Ricardo Tavares Ferreira, Construção Inicial.
/*/
//=============================================================================================================================
    User Function MT110GRV()
//=============================================================================================================================

    Local aArea := GetArea()

    APIUtil():GravaDataHora("SC1",{SC1->(Recno())},{"C1_XDTALT","C1_XHRALT"})
    RestArea(aArea)
Return Nil 
