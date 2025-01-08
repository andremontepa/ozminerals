#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "TOTVS.CH"

User Function  MT120LOK()

	Local nPosNum     := aScan(aHeader,{|x| AllTrim(x[2]) == 'C7_NUMSC'})
	Local nPosItem    := aScan(aHeader,{|x| AllTrim(x[2]) == 'C7_ITEMSC'}) //n�o � o item do pedido, � o da SC no pedido
    Local nPostpapl  := aScan(aHeader,{|x| AllTrim(x[2]) == 'C7_XTPAPL'})
	Local lValido := .T.
    Local aPropri:= " "

	//If MsSeek(xFilial('SC7')+aCols[n][nPosPrd]+cA120Num+aCols[n][nPosItem])

	//COMENTADO POR LEONARDO MEDEIROS. PARA FUNCIONAMENTO DEVER� SER TRATADA PRIEMIRAMENTE A INTEGRA��O DO BASE B PARA QUE O WEBSERVICE
	//BUSQUE A APROPRIA��O INFORMADA NA SC E N�O NO CADASTRO DO PRODUTO. TRATAR TAMB�M NO ENCERRAMENTO DA MEDI��O APRA QUE BUSQUE
	//A APROPRIA��O INDICADA NA MEDI��O
	//If !Empty(aCols[n][nPosNum])

		//aPropri:= Posicione('SC1',1,xFilial('SC1')+aCols[n][nPosNum]+aCols[n][nPosItem],'C1_XPROPRI')
		//If aCols[n][nPostpapl] <> aPropri
			//Msginfo('Apropria��o do pedido nao pode ser diferente da SC','Aten�ao')
			//lValido:= .f.
		//EndIf

	//EndIf
Return(lValido)

