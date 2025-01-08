#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "TOTVS.CH"

User Function VldPropri()

Local lRet := .t.
Local aPropri := ""

IF !pertence("DI")
    Return .f.
EndIf

If !Empty(M->C7_NUMSC)

 aPropri:= Posicione('SC1',xFilial('SC1')+M->C7_NUMSC,'C1_XPROPRI')
 If M->C7_NUMSC <> aPropri
	Msginfo('Apropriação do pedido nao pode ser diferente da SC','Atençao')
	lRet:= .f.
 EndIf

EndIf

Return lRet
