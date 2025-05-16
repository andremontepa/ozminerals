#include "Protheus.Ch"
#include "TbiConn.Ch"
#include "totvs.ch"
#include "ozminerals.ch"

#define  DOC_SERIE    "CST"

#define  PRODUCAO         "1"
#define  TRANSFERENCIA    "2"
#define  BAIXA_REQUISICAO "3"
#define  VENDA_CPV        "4"

/*/{Protheus.doc} SF2520E

	Ponto de entrada para Retornar Status da Tabela PAX/PAY

@type function
@author Fabio Santos - CRM Services 
@since  08/12/2023
@version P12
@database SQL SERVER 

@Obs

	Parametros:

	Se o parametro OZ_SF2520E estiver Habilitado, Será Executado o retorno do Status Tabela PAY/PAX
	Portanto, recomendamos usa-lo em empresas que tenha processo de custeio neste modelo. 

@see MATA520
@see OZGENSQL
@see u_ExcluiDocumentoCpv()

@nested-tags:Frameworks/OZminerals
/*/ 
User Function SF2520E()
	Local aArea                := {}  as array     
	Local cNumDoc              := ""  as character
	Local cSerieDoc            := ""  as character
	Local lPermiteExecutar     := .F. as logical 

	aArea              		   := GetArea()
	lPermiteExecutar           := GetNewPar("OZ_SF2520E",.T.)
	cNumDoc                    := Posicione("PAY",7,SF2->F2_FILIAL+SF2->F2_DOC+SF2->F2_SERIE+VENDA_CPV,"PAY_NUMNF")
	cSerieDoc                  := Posicione("PAY",7,SF2->F2_FILIAL+SF2->F2_DOC+SF2->F2_SERIE+VENDA_CPV,"PAY_SERIE")
	cCodFilial                 := SF2->F2_FILIAL

	If ( !IsBlind() )
		If ( lPermiteExecutar )
			If ( cSerieDoc $ DOC_SERIE ) .And. !Empty(Alltrim(cNumDoc))
				If ( FindFunction("estoque.Producao.Custeio.u_ExcluiDocumentoCpv") )
					estoque.Producao.Custeio.u_ExcluiDocumentoCpv(cNumDoc,cSerieDoc,cCodFilial)
				EndIf
			EndIf
		EndIf
	EndIf

	RestArea(aArea) 	
Return
