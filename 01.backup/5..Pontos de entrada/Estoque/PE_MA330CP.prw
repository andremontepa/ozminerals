#include "Protheus.Ch"
#include "TopConn.ch"
#include "TbiConn.ch"
#include "totvs.ch"

/*/{Protheus.doc} MA330OK

	Ponto de entrada para o tratamento do custeio OZ mineral´s 

    Localização : Function MATA330( ) - Localizado nas rotinas de processamento de 
                  custo em partes.

    Descrição    : O recálculo do custo médio possibilita dividir o custo de produtos 
                   fabricados em mais de uma parte, facilitando a visualização da composição 
                   de custos dos produtos acabados.

	Tdn : https://tdn.totvs.com/pages/releaseview.action?pageId=6087631

@type function
@author Fabio Santos - CRM Service
@since 10/11/2023
@version P12
@database SQL SERVER 

@Obs

	Parametros:
	Se o parametro OZ_MA330CP estiver Habilitado, Será executado o cuto em partes
	Portanto, recomendamos usa-lo em empresas que tenha processo de custeio neste modelo. 

@see MATA330

@nested-tags:Frameworks/OZminerals
/*/ 
User Function MA330CP()
	Local aArea             := {}  as array
    Local aRet              := {} as array 
	Local lPermiteExecutar  := .F. as Logical

	aArea                   := GetArea()
	lPermiteExecutar        := GetNewPar("OZ_MA330CP",.T.)

    If lPermiteExecutar
		aAdd(aRet,"SB1->B1_TIPO == 'CX'")
		aAdd(aRet,"SB1->B1_TIPO == 'DP'")
	EndIf 

	RestArea( aArea )

Return aRet
