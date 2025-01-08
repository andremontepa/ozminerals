#include 'protheus.ch'
#include 'parmtype.ch'
//-------------------------------------------------------------------------------
/* {Protheus.doc} CTA120MNU
Ponto de Entrada - MenuDef Gestao de Contratos - Medições
Copyright I AGE© - Inteligência Andrews
@author Felipe Andrews de Almeida
@since 01/2021
@version Lobo Guara v.12.1.23
*/
//-------------------------------------------------------------------------------
user function CTA120MNU()
	aAdd(aRotina,{"Gerar Ped. Compra Nacional","U_IACOMP01()",0,6})
	aAdd(aRotina,{"Estorno Ped. Compra Nacional","U_IACOMP02()",0,6})
	aAdd(aRotina,{"Relatorio de Contratos Nacional","U_IACOMR01()",0,6})
	
return