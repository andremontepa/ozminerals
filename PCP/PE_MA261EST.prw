#include "Protheus.Ch"
#include "TbiConn.Ch"
#include "totvs.ch"
#include "ozminerals.ch"

#define  PRODUCAO         "1"
#define  TRANSFERENCIA    "2"
#define  BAIXA_REQUISICAO "3"
#define  VENDA_CPV        "4"

/*/{Protheus.doc} MA261EST

	Ponto de entrada para Retornar Status da Tabela PAX/PAY

	Este ponto de entrada é chamado após a confirmação do estorno das transferencias. 
	Pode ser utilizado para validar se o estorno pode ser efetuado ou não.

	TDN : https://tdn.totvs.com/pages/releaseview.action?pageId=6087618

@type function
@author Fabio Santos - CRM Services 
@since  08/12/2023
@version P12
@database SQL SERVER 

@Obs

	Parametros:

	Se o parametro OZ_MA261EX estiver Habilitado, Será Executado o retorno do Status Tabela PAY/PAX
	Portanto, recomendamos usa-lo em empresas que tenha processo de custeio neste modelo. 


@see MATA261
@see OZGENSQL
@see u_EstornaransferenciaArmazen()

@nested-tags:Frameworks/OZminerals
/*/ 
User Function MA261EST()
	Local aArea            := {}  as array     
	Local cNumDoc          := ""  as character
	Local cCodFilial       := ""  as character
	Local lPermiteExecutar := .F. as logical 
    Local lRet             := .T. as logical

	aArea              	   := GetArea()
	lPermiteExecutar       := GetNewPar("OZ_MA261EX",.T.)
	cNumDoc                := Posicione("PAY",4,SD3->D3_FILIAL + SD3->D3_DOC + TRANSFERENCIA,"PAY_NUMDOC") 
	cCodFilial             := SD3->D3_FILIAL 

	If ( !IsBlind() )
		If ( lPermiteExecutar )
			If !Empty(Alltrim(cNumDoc))
				If ( FindFunction("estoque.Producao.Custeio.u_EstornaTransferenciaArmazen") )
					estoque.Producao.Custeio.u_EstornaTransferenciaArmazen(cNumDoc,cCodFilial)
				EndIf
			EndIf
		EndIf
	EndIf

	RestArea(aArea) 	
Return lRet
