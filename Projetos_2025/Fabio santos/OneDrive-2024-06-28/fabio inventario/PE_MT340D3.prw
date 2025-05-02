#include "protheus.ch"
#include "Totvs.ch"
#include "Tbiconn.ch"
//#include "ozminerals.ch"

/*/{Protheus.doc} MT340D3

	Rotina para incluir CENTRO DE CUSTO, ITEM CONTABIL E CLASSE no registro de inventario tabela SD3

@type Function
@author Fabio Santos - CRM Service
@since 08/07/2024
@version P12
@database MSSQL

@nested-tags:Frameworks/OZminerals
/*/
User Function MT340D3()
	Local aArea             := GetArea()
	Local cCentroCusto      := ""  as Character
	Local cItemContabil     := ""  as Character
	Local cClasseValor      := ""  as Character
    Local cCtaContabil      := ""  as Character
    Local cDocInventario    := ""  as Character
    Local nValorInvent      := ""  as Character
	Local nSeqInvent        := 0   as integer
	Local dD3EMISSAO        := DTOS((D3_EMISSAO))
	Local cD3COD            := D3_COD
	Local cD3LOCAL          := D3_LOCAL
	Local cD3LOCALIZ        := D3_LOCALIZ
	Local cD3NUMSERI        := D3_NUMSERI
	Local cD3LOTECTL        := D3_LOTECTL
	Local cD3NUMLOTE        := D3_NUMLOTE

	DbSelectArea("SB7")
	SB7->(DbSetOrder(1)) 
	If (SB7->(DbSeek(xFilial("SB7") + dD3EMISSAO + cD3COD + cD3LOCAL + cD3LOCALIZ + cD3NUMSERI + cD3LOTECTL + cD3NUMLOTE )))
		cCentroCusto    := SB7->B7_XCC
		cItemContabil   := SB7->B7_XITEMCT
		cClasseValor    := SB7->B7_XCLVL
        cCtaContabil    := SB7->B7_XCONTA
    	cCtaDespInvent  := SB7->B7_XCTADES
		cDocInventario  := SB7->B7_DOC
		nValorInvent    := SB7->B7_XVALOR 
		nSeqInvent      := SB7->B7_XSEQINV  

		If ( SD3->D3_CUSTO1 == 0 .And. nValorInvent > 0 )
			SD3->D3_XVLRINV := nValorInvent  
		EndIf	
        SD3->D3_CONTA   := cCtaContabil
        SD3->D3_XCTADES := cCtaDespInvent
		SD3->D3_CC      := cCentroCusto
		SD3->D3_ITEMCTA := cItemContabil
		SD3->D3_CLVL    := cClasseValor
		SD3->D3_XDOCINV := cDocInventario
		SD3->D3_XSEQINV := nSeqInvent
	EndIf

	RestArea(aArea)

Return()

