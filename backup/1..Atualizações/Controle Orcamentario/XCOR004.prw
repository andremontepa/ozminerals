#Include "PROTHEUS.CH"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³XCOR004   º Autor ³ Ismael Junior      º Data ³  21/10/17   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Rotina para transferência de recursos orçamentarios        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGACOM                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function XCOR004()
Local oButton1
Local oButton2
Local oGroup1
Local oGroup2
Local oSay1
Local oSay11
Local oSay2
Local oSay3
Local oSay4
Local oSay5
Local oSay6
Local oSay7
Local oSay8
Local oSay9
Local oSlMotivo
Local oValor
Private oSaldo1
Private cSaldo1 := ""
Private oSaldo2
Private cSaldo2 := ""
Private oCcusto1
Private oCcusto2 
Private oClvl1
Private oClvl2
Private oConta1
Private oConta2
Private oItemco1
Private oItemco2
Private cValor    := 0
Private cCcusto1  := Space(9)    
Private cItemco1  := Space(9)
Private cClvl1   := Space(20) 
Private cCcusto2  := Space(9)  
Private cItemco2  := Space(9) 
Private cClvl2   := Space(20) 
Private cConta1 := Space(20)
Private cConta2 := Space(20)
Private cSlMotiv  := Space(80) 
Static oDlg

  DEFINE MSDIALOG oDlg TITLE "Solicitação de Transferência de Recursos" FROM 000, 000  TO 205, 780 COLORS 0, 16777215 PIXEL

    @ 004, 002 GROUP oGroup1 TO 032, 388 PROMPT "Conta de Origem" OF oDlg COLOR 0, 16777215 PIXEL
    @ 010, 004 SAY oSay1 PROMPT "Centro de Custo" SIZE 041, 007 OF oGroup1 COLORS 0, 16777215 PIXEL
    @ 010, 066 SAY oSay2 PROMPT "Item Contábil" SIZE 040, 007 OF oGroup1 COLORS 0, 16777215 PIXEL
    @ 010, 132 SAY oSay3 PROMPT "Classe Valor" SIZE 025, 007 OF oGroup1 COLORS 0, 16777215 PIXEL
    @ 010, 229 SAY oSay13 PROMPT "Conta" SIZE 025, 007 OF oGroup1 COLORS 0, 16777215 PIXEL
    @ 018, 005 MSGET oCcusto1 VAR cCcusto1 SIZE 060, 010 OF oGroup1 COLORS 0, 16777215 F3 "CTT" PIXEL
    @ 018, 067 MSGET oItemco1 VAR cItemco1 SIZE 060, 010 OF oGroup1 COLORS 0, 16777215 F3 "CTD" PIXEL
    @ 018, 132 MSGET oClvl1 VAR cClvl1 SIZE 090, 010 OF oGroup1 COLORS 0, 16777215 F3 "CTHORC" PIXEL
    @ 018, 230 MSGET oConta1 VAR cConta1 SIZE 079, 010 OF oGroup1 COLORS 0, 16777215 VALID cor04Sal(1,cCcusto1,cItemco1,cClvl1,cConta1) F3 "CT1" PIXEL
    @ 010, 321 SAY oSay9 PROMPT "Saldo da Conta" SIZE 043, 007 OF oGroup1 COLORS 0, 16777215 PIXEL
    @ 018, 321 SAY oSaldo1 VAR cSaldo1 SIZE 061, 007 OF oGroup1 COLORS 16711680, 16777215 PIXEL

    @ 034, 002 GROUP oGroup2 TO 062, 388 PROMPT "Conta de Destino" OF oDlg COLOR 0, 16777215 PIXEL    
    @ 040, 004 SAY oSay6 PROMPT "Centro de Custo" SIZE 041, 007 OF oGroup2 COLORS 0, 16777215 PIXEL
    @ 040, 067 SAY oSay7 PROMPT "Item Contábil" SIZE 040, 007 OF oGroup2 COLORS 0, 16777215 PIXEL
    @ 040, 133 SAY oSay8 PROMPT "Classe Valor" SIZE 025, 007 OF oGroup2 COLORS 0, 16777215 PIXEL
    @ 039, 233 SAY oSay14 PROMPT "Conta" SIZE 025, 007 OF oGroup2 COLORS 0, 16777215 PIXEL
    @ 048, 005 MSGET oCcusto2 VAR cCcusto2 SIZE 060, 010 OF oGroup2 COLORS 0, 16777215 F3 "CTT" PIXEL
    @ 048, 067 MSGET oItemco2 VAR cItemco2 SIZE 060, 010 OF oGroup2 COLORS 0, 16777215 F3 "CTD" PIXEL
    @ 048, 132 MSGET oClvl2 VAR cClvl2 SIZE 090, 010 OF oGroup2 COLORS 0, 16777215 F3 "CTHORC" PIXEL    
    @ 047, 232 MSGET oConta2 VAR cConta2 SIZE 077, 010 OF oGroup2 COLORS 0, 16777215 VALID cor04Sal(2,cCcusto2,cItemco2,cClvl2,cConta2) F3 "CT1" PIXEL
    @ 040, 321 SAY oSay11 PROMPT "Saldo da Conta" SIZE 043, 007 OF oGroup2 COLORS 0, 16777215 PIXEL
    @ 048, 321 SAY oSaldo2 VAR cSaldo2 SIZE 061, 007 OF oGroup2 COLORS 16711680, 16777215 PIXEL 
    
    @ 063, 092 SAY oSay5 PROMPT "Motivo da Solicitação" SIZE 081, 007 OF oDlg COLORS 0, 16777215 PIXEL 
    @ 063, 005 SAY oSay4 PROMPT "Valor" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 070, 003 MSGET oValor VAR cValor SIZE 085, 010 OF oDlg PICTURE "@E 999,999,999.99" COLORS 0, 16777215 PIXEL
    @ 070, 092 MSGET oSlMotivo VAR cSlMotiv SIZE 211, 010 OF oDlg COLORS 0, 16777215 PIXEL
        
    @ 085, 225 BUTTON oButton1 PROMPT "Sair" SIZE 037, 012 OF oDlg ACTION IIF(MsgYesNo("Deseja realmente fechar a rotina?","Atenção"),oDlg:END(),) PIXEL
    //@ 085, 268 BUTTON oButton2 PROMPT "OK" SIZE 037, 012 OF oDlg ACTION u_WFCOR04(,,cCcusto1,cItemco1,cClvl1,cCcusto2,cItemco2,cClvl2,cValor,cSlMotiv) PIXEL
	@ 085, 268 BUTTON oButton2 PROMPT "OK" SIZE 037, 012 OF oDlg ACTION IIF(MsgYesNo("Deseja realmente efetuar essa solicitação?","Atenção"),u_WFCOR04(,,cCcusto1,cItemco1,cClvl1,cConta1,cCcusto2,cItemco2,cClvl2,cConta2,cValor,cSlMotiv),) PIXEL
    //IIF(MsgYesNo("Deseja realmente efetuar essa solicitação?","Atenção"),u_WFCOR03(,,cCusto,cItemco,cConta,nValor,cSlMotiv),)
  ACTIVATE MSDIALOG oDlg CENTERED 

Return 

Static Function cor04Sal(nX,cCusto,cItemco,cClvl,cConta)
Local cAno    := Alltrim(Str(Year(Date())))
Local cSaldo  := ""
//Local cMes    := Month2Str(Date())
Local cSQL:= "TRA"

cQuery := " SELECT SUM(ZW2_PREANO) VALOR FROM "+RetSqlName("ZW2")+ " ZW2 " 
cQuery += " WHERE ZW2_CCUSTO = '"+Alltrim(cCusto)+"' "
cQuery += " AND ZW2_ITEMCO = '"+Alltrim(cItemco)+"' "
cQuery += " AND ZW2_CLVL = '"+Alltrim(cClvl)+"' "
cQuery += " AND ZW2_CONTA = '"+Alltrim(cConta)+"' "
cQuery += " AND ZW2_ANO = '"+cAno+"' "
cQuery += " AND ZW2_FILIAL = '"+xFilial("ZW2")+"' "
cQuery += " AND ZW2.D_E_L_E_T_ != '*' "  

If SELECT(cSQL) > 0
	(cSQL)->(DbCloseArea())
Endif
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cSQL,.T.,.T.)
If nX = 1 
cSaldo1 := Transform((cSQL)->VALOR,"@E 999,999,999.99")
oSaldo1:refresh()
Else
cSaldo2 := Transform((cSQL)->VALOR,"@E 999,999,999.99")
oSaldo2:refresh()
Endif
oDlg:Refresh()
Return(cSaldo)
