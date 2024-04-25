#include "Protheus.Ch"
#include "TbiConn.Ch"
#include "totvs.ch"
#include "ozminerals.ch"

/*/{Protheus.doc} MA330MOD

	Ponto de entrada para o tratamento do custeio Mão de Obra - OZminerals 
   
	Function MA330Mod - Função que calcula o custo das requisições de mão de obra feitas no período, 
    localizado no fonte do MATA330.

	Tdn https://tdn.totvs.com/pages/releaseview.action?pageId=6087637

@type function
@author Fabio Santos - CRM Services 
@since  08/10/2023
@version P12
@database SQL SERVER 

@Obs

	Parametros:

	Se o parametro OZ_MA330MO estiver Habilitado, Será executado o calculo do custeio. 
	Portanto, recomendamos usa-lo em empresas que tenha processo de custeio neste modelo. 

@see MATA330
@see OZGENSQL
@see u_CalculoCustoMaoDeObra()

@nested-tags:Frameworks/OZminerals
/*/ 
User Function MA330MOD()
	Local aArea                := {}  as array     
	Local cPesqCodigoProduto   := ""  as character
	Local lPermiteExecutar     := .F. as Logical

	aArea                      := GetArea()
	cPesqCodigoProduto         := PARAMIXB[1]

	lPermiteExecutar           := GetNewPar("OZ_MA330MO",.F.)
	
	If ( !IsBlind() )
		If ( lPermiteExecutar )
			If ( FindFunction("estoque.Producao.Custeio.u_CalculoCustoMaoDeObra") )
				estoque.Producao.Custeio.u_CalculoCustoMaoDeObra(cPesqCodigoProduto)
			EndIf
		EndIf
	EndIf

	RestArea( aArea )	

Return
