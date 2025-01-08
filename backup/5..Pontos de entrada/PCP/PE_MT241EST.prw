#include "Protheus.Ch"
#include "TbiConn.Ch"
#include "totvs.ch"
#include "ozminerals.ch"

#define  PRODUCAO         "1"
#define  TRANSFERENCIA    "2"
#define  BAIXA_REQUISICAO "3"
#define  VENDA_CPV        "4"

/*/{Protheus.doc} MT241EST

	Ponto de entrada para Retornar Status da Tabela PAX/PAY

	Após a atualização do registro de movimentos internos (SD3) no estorno do movimento 
	e tem como finalidade a atualização de algum arquivo ou campo.

	TDN : https://tdn.totvs.com/pages/releaseview.action?pageId=6087740

@type function
@author Fabio Santos - CRM Services 
@since  08/12/2023
@version P12
@database SQL SERVER 

@Obs

	Parametros:

	Se o parametro OZ_MT241EX estiver Habilitado, Será Executado o retorno do Status Tabela PAY/PAX
	Portanto, recomendamos usa-lo em empresas que tenha processo de custeio neste modelo. 

@see MATA241
@see OZGENSQL
@see u_EstornaRequisicaoInterna()

@nested-tags:Frameworks/OZminerals
/*/ 
User Function MT241EST()
	Local aArea            := {}  as array     
	Local cNumDoc          := ""  as character
	Local cCodFilial       := ""  as character
	Local lPermiteExecutar := .F. as logical 

	aArea              	   := GetArea()
	lPermiteExecutar       := GetNewPar("OZ_MT241EX",.T.)
	cNumDoc                := Posicione("PAY",4,SD3->D3_FILIAL + SD3->D3_DOC + BAIXA_REQUISICAO,"PAY_NUMDOC") 
	cCodFilial             := SD3->D3_FILIAL 

	If ( !IsBlind() )
		If ( lPermiteExecutar )
			If !Empty(Alltrim(cNumDoc))
				If ( FindFunction("estoque.Producao.Custeio.u_EstornaRequisicaoInterna") )
					estoque.Producao.Custeio.u_EstornaRequisicaoInterna(cNumDoc,cCodFilial)
				EndIf
			EndIf
		EndIf
	EndIf

	RestArea(aArea) 
		
Return 
