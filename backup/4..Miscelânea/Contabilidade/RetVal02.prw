//Bibliotecas
#Include "Protheus.ch"
#Include "Topconn.ch"
#INCLUDE "Totvs.ch"

/*/{Protheus.doc} RetVal02
Função RetVal, para retorno de valores de Lançamento Padrão
@since 16.11.2023
@author Stephen Ribeiro - Equilibrio T.I. */


User Function RetVal02()

Local nValor:=0

IF SB1->B1_LOCPAD <> '03'

    nValor:=IIF(SD1->D1_RATEIO=="1",(((SD1->D1_TOTAL+SD1->D1_IPI)-(SD1->D1_DESC+SD1->D1_VALIRR+SD1->D1_VALISS+SD1->D1_VALINS+SD1->D1_VALPIS+SD1->D1_VALCOF+SD1->D1_VALCSL))*SDE->DE_PERC)/100,0)

Endif

return nValor 
