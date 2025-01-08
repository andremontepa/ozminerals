#include "Protheus.Ch"
#include "TopConn.ch"
#include "TbiConn.ch"
#include "totvs.ch"

#define STATUS_CONTABILIZA           1
#define TIPO_CONTABIL                2

/*/{Protheus.doc} MA330FIM

	Ponto de entrada para o tratamento do custeio OZ mineral´s 

	Function MA330Process - Função de processamento da rotina de recalculo do custo medio
							Executada após todo o processamento do recalculo do custo medio para 
							que se possa realizar customizações no final da rotina.

	Tdn : https://tdn.totvs.com/pages/releaseview.action?pageId=6087635

@type function
@author Fabio Santos - CRM Service
@since 01/10/2023
@version P12
@database SQL SERVER 

@Obs

	Parametros:

	Se o parametro OZ_MA330FI estiver Habilitado, Será executado o calculo do custeio. 
	Portanto, recomendamos usa-lo em empresas que tenha processo de custeio neste modelo. 

@see MATA330
@see OZGENSQL
@see u_ManutencaoTabelaTemporaria()

@nested-tags:Frameworks/OZminerals
/*/ 
User Function MA330FIM()
	Local aArea             := {}  as array
	Local lPermiteExecutar  := .F. as Logical
	Local nContabiliza      := 0   as numeric  
	Local nTipoContabil     := 0   as numeric 

	aArea                   := GetArea()
	lPermiteExecutar        := GetNewPar("OZ_MA330FI",.T.)

	Pergunte("MTA330",.F.)
	nContabiliza            := MV_PAR10 
	nTipoContabil           := MV_PAR12 

	If ( !IsBlind() )
		If ( lPermiteExecutar )
			If ( FindFunction("estoque.Producao.Custeio.u_ManutencaoTabelaTemporaria") )
				estoque.Producao.Custeio.u_ManutencaoTabelaTemporaria()
			EndIf
		EndIf

		If ( lPermiteExecutar )
			If ( FindFunction("estoque.Producao.Custeio.u_AjustaCustoEmParteCaixaDepreciacao") )
				estoque.Producao.Custeio.u_AjustaCustoEmParteCaixaDepreciacao()
			EndIf
		EndIf

		If ( lPermiteExecutar )
			If ( FindFunction("estoque.Producao.Custeio.u_DesbloqueiaSequenciaLancamentoPadrao") )
				If ( nContabiliza = STATUS_CONTABILIZA .And. nTipoContabil = TIPO_CONTABIL )
					estoque.Producao.Custeio.u_DesbloqueiaSequenciaLancamentoPadrao()
				EndIf 
			EndIf
		EndIf
	EndIf

	RestArea( aArea )

Return
