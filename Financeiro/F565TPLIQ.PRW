#Include "Rwmake.ch"
#Include "Topconn.ch"
#include "TbiConn.ch"
#include "TbiCode.ch"
#include "protheus.ch"


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³F565TPliq ºAutor  ³Ismael Junior        º Data ³  25/11/21  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Ponto de entrada que permite a manipulação do título de   º±±
±±ºDesc.     ³  liquidação. É chamado logo na geração da SE2 do título de º±±
±±ºDesc.     ³  liquidação, estando posicionado no mesmo                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
 
User Function F565TPliq()
    if Empty(SE2->E2_DATALIB) 
        cUpdate := "UPDATE " + RetSqlName("SE2") + " SET E2_DATALIB = '" + DTOS(date()) + "' "
        cUpdate += "WHERE E2_FILIAL = '" + SE2->E2_FILIAL + "' ""
        cUpdate += "AND E2_PREFIXO = '" + SE2->E2_PREFIXO + "' "
        cUpdate += "AND E2_NUM = '" + SE2->E2_NUM + "' "
        cUpdate += "AND E2_TIPO = '" + SE2->E2_TIPO + "' "
        cUpdate += "AND E2_FORNECE = '" + SE2->E2_FORNECE + "' "
        cUpdate += "AND E2_LOJA = '" + SE2->E2_LOJA + "' "
        cUpdate += "AND D_E_L_E_T_ != '*' "
        nFlag := TcSqlExec(cUpdate)
    endif             
Return
