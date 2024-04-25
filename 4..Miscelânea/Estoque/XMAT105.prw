#INCLUDE "rwmake.ch" 
#INCLUDE "TOTVS.ch"
#INCLUDE 'TOPCONN.CH'
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³XMAT105   º Autor ³ Ismael Junior      º Data ³  14/09/17   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Função generica para verifica se produto tem saldo disponi-º±±
±±º          ³ nivel (saldo no estoque menos o reservado)                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ ESTOQUE (SIGAEST)                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function XMAT105(cProd,cLocal)
Local nSaldo := 0
Local nRes   := 0
_cSql := " SELECT SUM(CP_QUANT) AS QTRESEV "
_cSql += " FROM "+RetSqlName("SCP")+" CP "
_cSql += " WHERE CP_PRODUTO = '"+cProd+"' "
_cSql += " AND CP_LOCAL = '"+cLocal+"' "
_cSql += " AND CP_STATUS = '' "
_cSql += " AND CP.D_E_L_E_T_  != '*' " 

//Tratando a query para o AdvPL
//memowrite(funname()+".sql",_cSql)
TCQuery _cSql new Alias (_cAlias:=GetNextAlias())
(_cAlias)->(DbGotop())

nSaldo := POSICIONE("SB2",1,XFILIAL("SB2")+cProd+cLocal,"B2_QATU")
nRes := nSaldo - (_cAlias)->QTRESEV
Return(nRes)
