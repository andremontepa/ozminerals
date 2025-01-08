#include "Protheus.Ch"
#include "TopConn.ch"
#include "TbiConn.ch"
#include "totvs.ch"

#define STATUS_CONTABILIZA           1
#define TIPO_CONTABIL                2

/*/{Protheus.doc} MA330PGI

	Ponto de entrada para o tratamento do custeio OZ mineral´s 

    O ponto de entrada MA330PGI é acionado no inicio da rotina de contabilização 
    do custo médio, pode ser usado em conjunto com o MA330PGF que é executado 
    no final da rotina.
	
    Tdn : https://tdn.totvs.com/pages/releaseview.action?pageId=73893614

@type function
@author Fabio Santos - CRM Service
@since 11/11/2023
@version P12
@database SQL SERVER 

@Obs

	Parametros:

	Se o parametro OZ_MA330PG estiver Habilitado, Será executado o calculo do custeio. 
	Portanto, recomendamos usa-lo em empresas que tenha processo de custeio neste modelo. 

@see MATA330
@see OZGENSQL
@see u_RetornaLoteContabilDoCusteio()

@nested-tags:Frameworks/OZminerals
/*/ 
User Function MA330PGI()
	Local aArea             := {}  as array
	Local lPermiteExecutar  := .F. as Logical
	Local nContabiliza      := 0   as numeric 
	Local nTipoContabil     := 0   as numeric 

    aArea                   := GetArea()

	Pergunte("MTA330",.F.)
	nContabiliza            := MV_PAR10 
	nTipoContabil           := MV_PAR12 
	lPermiteExecutar        := GetNewPar("OZ_MA330PG",.T.)

	If ( !IsBlind() )
		If ( lPermiteExecutar )
			If ( FindFunction("estoque.Producao.Custeio.u_RetornaLoteContabilDoCusteio") )
				If ( nContabiliza = STATUS_CONTABILIZA .And. nTipoContabil = TIPO_CONTABIL )
					estoque.Producao.Custeio.u_RetornaLoteContabilDoCusteio()
				EndIf
			EndIf
		EndIf
	EndIf

	RestArea( aArea )

Return
