//Bibliotecas
#Include "Protheus.ch"
#Include "Topconn.ch"
#INCLUDE "Totvs.ch"

/*/{Protheus.doc} RetContaLP
Função RetContaLP, para retorno de Conta Contábil de Lançamento Padrão
@since 02.10.2023
@author Stephen Ribeiro - Equilibrio T.I. */


User Function RetContaLP()

    Local cConta    :=""
    Local cPedido   := SD1->D1_PEDIDO
    Local cCusto    := SDE->DE_CC
    Local cQry      := ""

    If Alltrim(SD1->D1_COD)=="000459".AND.SD1->D1_RATEIO=='1' .and. !empty(cPedido)

         cQry:= "SELECT TOP 1 CNZ.CNZ_CONTA CONTA FROM CND010 CND "
        cQry+= "INNER JOIN CNZ010 CNZ ON CNZ.CNZ_FILIAL = CND.CND_FILIAL AND CNZ.CNZ_CONTRA = CND.CND_CONTRA AND CNZ.CNZ_REVISA = CNZ.CNZ_REVISA AND CND.CND_NUMMED = CNZ.CNZ_NUMMED "
        cQry+= "WHERE CNZ.D_E_L_E_T_ = ' ' "
        cQry+= "AND CND_PEDIDO = '"+cPedido+"' "
        cQry+= "AND CND.D_E_L_E_T_ = ' '"
        cQry+= "AND CNZ.CNZ_CC = '"+cCusto+"'"
        cQry+= "ORDER BY CND_REVISA DESC "

        if Select("TMP1") <> 0
            TMP1->(dbCloseArea())
        Endif

        dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQry),"TMP1",.F.,.T.)
        cConta:= TMP1->CONTA

    Else
        cConta:=IIF(SD1->D1_XOPER=="51",SB1->B1_CONTA, IIf(U_CLASCC()=="1", SB1->B1_CTAATIV, IIf(U_CLASCC()=="2", SB1->B1_CTACUST,IIF(U_CLASCC()=="3",SB1->B1_CTADESP,SB1->B1_XCTAEXP))))
    EndIf
return cConta
