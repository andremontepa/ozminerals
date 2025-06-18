#include "totvs.ch"
#include "Protheus.Ch"
#include "TbiConn.Ch"
#include "totvs.ch"
#include "ozminerals.ch"

/*/{Protheus.doc} PE FA080TIT

    PONTO DE ENTRADA PRA ENVIAR O ID DO TITULO PAGO
    O ponto de entrada FA080TIT sera utilizado na confirmacao da tela de 
    baixa do contas a pagar, antes da gracacao dos dados.

@type function
@autor  Mateus Hengle
@since 20/11/2023
@version P12
@database SQL SERVER 

@history 09/06/2024, Fabio Santos, Foi implementado metodologia de fazer chamada passando parametros de empresa e filial  

@Obs

    Link Documentação do Fonte : 
    https://tdn.totvs.com/display/public/mp/FA080TIT+-+Confirma+baixas+a+pgar+--+11899

@See u_RetornaTituloPago()
 
@return logical, True ou False 

@nested-tags:Frameworks/OZminerals
/*/ 
User Function FA080TIT()
	Local aArea                := {}  as array     
	Local lPermiteExecutar     := .F. as Logical
	Local lRet                 := .T. as Logical

    aArea                      := GetArea()
	lPermiteExecutar           := GetNewPar("OZ_FA080TI",.T.)

	If ( !IsBlind() )
		If ( lPermiteExecutar .And. !Empty(Alltrim(SE2->E2_XID)) )
			If ( FindFunction("financeiro.argo.u_RetornaTituloPago") )
				lRet := financeiro.argo.u_RetornaTituloPago(SE2->E2_FILIAL,; 
															SE2->E2_XID,; 
															SE2->E2_PARCELA)
			EndIf
		EndIf
	EndIf

	RestArea( aArea )

Return lRet
