#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "fileio.ch"

/*/{Protheus.doc} CTA100MNU
CTA100MNU - Manuten��o de contratos.
@type class 
@author Ricardo Tavares Ferreira
@since 23/10/2021
@version 12.1.27
@obs LOCALIZA��O : Function CNTA100 - Rotina respons�vel pela Manuten��o de Contratos.
EM QUE PONTO : Antes de montar a tela do browser.
UTILIZA��O : Para adicionar bot�es no menu principal da rotina.
@link https://tdn.totvs.com/pages/releaseview.action?pageId=6089605
@history 23/10/2021, Ricardo Tavares Ferreira, Constru��o Inicial
/*/
//=============================================================================================================================
    User Function CTA100MNU()
//=============================================================================================================================

    Local aArea := GetArea()

    aadd(aRotina,{"#Exportar Itens (Medi��o)","U_RT69M001()",0,4,58,Nil,Nil,Nil})
    RestArea(aArea)
Return Nil 


