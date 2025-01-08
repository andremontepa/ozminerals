//Bibliotecas
#Include "Protheus.ch"
#Include "Topconn.ch"
#INCLUDE "Totvs.ch"

/*/{Protheus.doc} RetVal01
Função RetVal, para retorno de valores de Lançamento Padrão 
@since 26.09.2022
@author Stephen Ribeiro - Equilibrio T.I. */


User Function RetVal01()

Local nValor:=0

if SD1->D1_RATEIO<>"1".AND.SD1->D1_CF<>"1151" .AND.SD1->D1_TES<>"162" .AND.SD1->D1_TES<>"008"

    nValor:=SD1->(D1_TOTAL+D1_VALIPI+D1_VALFRE+D1_SEGURO+D1_DESPESA+D1_ICMSRET-D1_VALDESC-IF(SA2->A2_RECISS="N".OR.SA2->A2_RECISS="",D1_VALISS,0)-IF(SD1->D1_VALIRR>0,D1_VALIRR,0)-D1_VALINS)

Endif 

return nValor

