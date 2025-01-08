#include "Protheus.Ch"
#include "TbiConn.Ch"
#include "totvs.ch"
#include "ozminerals.ch"

#define  DOC_SERIE        "CST"

#define  PRODUCAO         "1"
#define  TRANSFERENCIA    "2"
#define  BAIXA_REQUISICAO "3"
#define  VENDA_CPV        "4"

/*/{Protheus.doc} MTA410E

	Ponto de entrada para Retornar Status da Tabela PAX/PAY

	Executado após deletar o registro no SC6 (item do pedido de venda)

	TDN : https://tdn.totvs.com/display/public/PROT/MTA410E

@type function
@author Fabio Santos - CRM Services 
@since  08/12/2023
@version P12
@database SQL SERVER 

@Obs

	Parametros:

	Se o parametro OZ_MTA410E estiver Habilitado, Será Executado o retorno do Status Tabela PAY/PAX
	Portanto, recomendamos usa-lo em empresas que tenha processo de custeio neste modelo. 

@see MATA410
@see OZGENSQL
@see u_ExcluiPedidoDeVendasCpv()

@nested-tags:Frameworks/OZminerals
/*/ 
User Function MTA410E()
	Local aArea                := {}  as array     
	Local cNumPed              := ""  as character
	Local lPermiteExecutar     := .F. as logical 

	aArea              		   := GetArea()
	lPermiteExecutar           := GetNewPar("OZ_MTA410E",.T.)
	cNumPed                    := Posicione("PAY",6,SC6->C6_FILIAL + SC6->C6_NUM + VENDA_CPV,"PAY_NUMPED") 
	cCodFilial                 := SC6->C6_FILIAL 

	If ( !IsBlind() )
		If ( lPermiteExecutar )
			If !Empty(Alltrim(cNumPed))
				If ( FindFunction("estoque.Producao.Custeio.u_ExcluiPedidoDeVendasCpv") )
					estoque.Producao.Custeio.u_ExcluiPedidoDeVendasCpv(cNumPed,cCodFilial)
				EndIf
			EndIf
		EndIf
	EndIf

	RestArea(aArea) 	
Return
