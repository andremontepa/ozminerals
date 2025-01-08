#Include "PROTHEUS.CH"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณXCOR003   บ Autor ณ Ismael Junior      บ Data ณ  18/10/17   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Rotina para solicita็ใo de recursos or็amentarios          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGACOM                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
User Function XCOR003()
Local oButton1
Local oButton2
Local oCcusto
Local oClvl
Local oConta
Local oItemco
Local oSay1
Local oSay2
Local oSay3
Local oSay4
Local oSay6  
Local oSlMotivo
Local oValor
Private nValor  := 0.0
Private cCusto := SPACE(9)
Private cItemco := SPACE(9)
Private cClvl  := SPACE(20)
Private cConta := Space(20)
Private cSlMotiv:= SPACE(80)
Static oDlg

  DEFINE MSDIALOG oDlg TITLE "Solicita็ใo de Recursos" FROM 000, 000  TO 170, 490 COLORS 0, 16777215 PIXEL

    @ 006, 004 SAY oSay1 PROMPT "Centro de Custo" SIZE 041, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 006, 078 SAY oSay2 PROMPT "Item Contแbil" SIZE 040, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 006, 150 SAY oSay3 PROMPT "Classe" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 015, 003 MSGET oCcusto VAR cCusto SIZE 060, 010 OF oDlg COLORS 0, 16777215 F3 "CTT" PIXEL
    @ 015, 077 MSGET oItemco VAR cItemco SIZE 060, 010 OF oDlg COLORS 0, 16777215 F3 "CTD" PIXEL
    @ 015, 151 MSGET oClvl VAR cClvl SIZE 090, 010 OF oDlg COLORS 0, 16777215 F3 "CTHORC" PIXEL
    @ 029, 004 SAY oSay6 PROMPT "Conta" SIZE 030, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 036, 004 MSGET oConta VAR cConta SIZE 078, 010 OF oDlg COLORS 0, 16777215 F3 "CT1" PIXEL    
    @ 029, 094 SAY oSay4 PROMPT "Valor" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 036, 092 MSGET oValor VAR nValor SIZE 085, 010 OF oDlg PICTURE "@E 999,999,999.99" COLORS 0, 16777215 PIXEL 
    @ 049, 004 SAY oSay5 PROMPT "Motivo da Solicita็ใo" SIZE 081, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 057, 003 MSGET oSlMotivo VAR cSlMotiv SIZE 236, 010 OF oDlg COLORS 0, 16777215 PIXEL     
    @ 070, 159 BUTTON oButton1 PROMPT "Sair" SIZE 037, 012 OF oDlg ACTION IIF(MsgYesNo("Deseja realmente fechar a rotina?","Aten็ใo"),oDlg:END(),) PIXEL
    //@ 070, 202 BUTTON oButton2 PROMPT "OK" SIZE 037, 012 OF oDlg ACTION u_WFCOR03(,,cCusto,cItemco,cClvl,nValor,cSlMotiv) PIXEL 
    @ 070, 202 BUTTON oButton2 PROMPT "OK" SIZE 037, 012 OF oDlg ACTION IIF(MsgYesNo("Deseja realmente efetuar essa solicita็ใo?","Aten็ใo"),u_WFCOR03(,,cCusto,cItemco,cClvl,cConta,nValor,cSlMotiv),) PIXEL   

  ACTIVATE MSDIALOG oDlg CENTERED    

Return
