#include "Protheus.Ch"
#include "TopConn.ch"
#include "TbiConn.ch"
#include "totvs.ch"

#define STATUS_CONTABILIZA           1
#define TIPO_CONTABIL                2

/*/{Protheus.doc} MA330OK

	Ponto de entrada para o tratamento do custeio OZ mineral´s 

	Localização : Function MATA330 - Recálculo do Custo Médio.
	Em que ponto: Executada após a confirmação do recálculo do custo médio, 
	ponto utilizado para validar se será permitida a execução da rotina.

	Tdn : https://tdn.totvs.com/pages/releaseview.action?pageId=6087638

@type function
@author Fabio Santos - CRM Service
@since 30/10/2023
@version P12
@database SQL SERVER 

@Obs

	Parametros:
	Se o parametro OZ_MA330OK estiver Habilitado, Será executado o BACKUP lote 008840. 
	Portanto, recomendamos usa-lo em empresas que tenha processo de custeio neste modelo. 

@see MATA330
@see OZGENSQL
@see u_GravaLoteContabilDoCusteio()
@see u_ManutencaoTabelaTemporaria
@see u_CompatibilizaCustoTransferecia()
@see u_BloqueiaSequenciaLancamentoPadrao()
@see u_GravaOperacaoCustoCaixaDepreciacao()

@nested-tags:Frameworks/OZminerals
/*/ 
User Function MA330OK()
	Local aArea             := {}  as array
	Local lPermiteExecutar  := .F. as Logical
	Local nContabiliza      := 0   as numeric  
	Local nTipoContabil     := 0   as numeric 

	Private lRet            := .T. as Logical

	aArea                   := GetArea()
	
	Pergunte("MTA330",.F.)
	lPermiteExecutar        := GetNewPar("OZ_MA330OK",.T.)
	nContabiliza            := MV_PAR10 
	nTipoContabil           := MV_PAR12 
	
	If ( !IsBlind() )
		If ( lPermiteExecutar )
			If ( FindFunction("estoque.Producao.Custeio.u_BloqueiaSequenciaLancamentoPadrao") )
				If ( nContabiliza = STATUS_CONTABILIZA .And. nTipoContabil = TIPO_CONTABIL )
					estoque.Producao.Custeio.u_BloqueiaSequenciaLancamentoPadrao()
				EndIf 
			EndIf
		EndIf

		If ( lPermiteExecutar )
			If ( FindFunction("estoque.Producao.Custeio.u_ManutencaoTabelaTemporaria") )
				estoque.Producao.Custeio.u_ManutencaoTabelaTemporaria()
			EndIf
		EndIf

		If ( lPermiteExecutar )
			If ( FindFunction("estoque.Producao.Custeio.u_ZeraSaldoCustoEmPartes") )
				If ( nContabiliza <> STATUS_CONTABILIZA .And. nTipoContabil <> TIPO_CONTABIL )
					estoque.Producao.Custeio.u_ZeraSaldoCustoEmPartes()
				EndIf 
			EndIf
		EndIf

		If ( lPermiteExecutar )
			If ( FindFunction("estoque.Producao.Custeio.u_GravaOperacaoCustoCaixaDepreciacao") )
				estoque.Producao.Custeio.u_GravaOperacaoCustoCaixaDepreciacao()
			EndIf
		EndIf

		If ( lPermiteExecutar )
			If ( FindFunction("estoque.Producao.Custeio.u_GravaLoteContabilDoCusteio") )
				If ( nContabiliza = STATUS_CONTABILIZA .And. nTipoContabil = TIPO_CONTABIL )
					estoque.Producao.Custeio.u_GravaLoteContabilDoCusteio()
				EndIf 
			EndIf
		EndIf
	EndIf 

	RestArea( aArea )

Return lRet
