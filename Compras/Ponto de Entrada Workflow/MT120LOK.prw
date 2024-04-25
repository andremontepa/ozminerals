#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "TOTVS.CH"

User Function  MT120LOK()

	Local nPosNum     := aScan(aHeader,{|x| AllTrim(x[2]) == 'C7_NUMSC'})
	Local nPosItem    := aScan(aHeader,{|x| AllTrim(x[2]) == 'C7_ITEMSC'}) //não é o item do pedido, é o da SC no pedido
    Local nPostpapl  := aScan(aHeader,{|x| AllTrim(x[2]) == 'C7_XTPAPL'})
	Local lValido := .T.
    Local aPropri:= " "

	//If MsSeek(xFilial('SC7')+aCols[n][nPosPrd]+cA120Num+aCols[n][nPosItem])

	If !Empty(aCols[n][nPosNum])

		aPropri:= Posicione('SC1',1,xFilial('SC1')+aCols[n][nPosNum]+aCols[n][nPosItem],'C1_XPROPRI')
		If aCols[n][nPostpapl] <> aPropri
			Msginfo('Apropriação do pedido nao pode ser diferente da SC','Atençao')
			lValido:= .f.
		EndIf

	EndIf
Return(lValido)

