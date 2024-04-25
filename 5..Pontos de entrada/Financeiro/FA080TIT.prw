#include "protheus.ch"
#include "topconn.ch"
#include "rwmake.ch"
#include 'parmtype.ch'

/*/{Protheus.doc} FA080TIT
FA080TIT - Confirma baixas a pgar
@type function
@author Ricardo Tavares Ferreira
@since 07/05/2022
@obs O ponto de entrada FA080TIT sera utilizado na confirmacao da tela de baixa do contas a pagar,
antes da gracacao dos dados.
@version 12.1.33
@link https://tdn.totvs.com/display/public/mp/FA080TIT+-+Confirma+baixas+a+pgar+--+11899
@return logical, Retorna verdadeiro se pode prosseguir com a Baixa.
@history 07/05/2022, Ricardo Tavares Ferreira, Construção Inicial.
/*/
//====================================================================================================
    User Function FA080TIT()
//====================================================================================================

    Local aArea := GetArea()

    If .not. AVBUtil():GetSM2(Dtos(SE2->E2_EMIS1))
        ApMsgStop("Não é possivel prosseguir com a baixa por que não existe taxa de moeda cadastrada para a data -> "+Dtoc(SE2->E2_EMIS1)+", para prosseguir cadastre a cotação de moeda da data informada.","Atenção")
        Return .F. 
    EndIf 
    RestArea(aArea)
Return .T.
