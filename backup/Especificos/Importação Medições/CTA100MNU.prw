#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "fileio.ch"

/*/{Protheus.doc} CTA100MNU
CTA100MNU - Manutenção de contratos.
@type class 
@author Ricardo Tavares Ferreira
@since 23/10/2021
@version 12.1.27
@obs LOCALIZAÇÃO : Function CNTA100 - Rotina responsável pela Manutenção de Contratos.
EM QUE PONTO : Antes de montar a tela do browser.
UTILIZAÇÃO : Para adicionar botões no menu principal da rotina.
@link https://tdn.totvs.com/pages/releaseview.action?pageId=6089605
@history 23/10/2021, Ricardo Tavares Ferreira, Construção Inicial
/*/
//=============================================================================================================================
    User Function CTA100MNU()
//=============================================================================================================================

    Local aArea := GetArea()

    aadd(aRotina,{"#Exportar Itens (Medição)","U_RT69M001()",0,4,58,Nil,Nil,Nil})
    RestArea(aArea)
Return Nil 


