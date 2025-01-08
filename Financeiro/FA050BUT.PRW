#include "rwmake.ch"
#include "fileio.ch"
#include "TbiConn.ch"
#include "TbiCode.ch"
#include "protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  F050BUT  ºAutor  ³Ismael Junior       º Data ³  12/06/21   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ponto de entrada Inclusão de botão para rotinas específicasº±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function F050BUT()

Local aRotina := {}
AAdd(aRotina, {"#Aprovadores",{ || U_LAPROV() },"#Aprovadores"})

Return aRotina 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  LAPROV  ºAutor  ³Ismael Junior       º Data ³  12/06/21      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Lista os aprovadores e mostra o status de cada aprovação   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function LAPROV()

Local oButton1
Static oDlg

  DEFINE MSDIALOG oDlg TITLE "Aprovadores" FROM 000, 000  TO 200, 500 COLORS 0, 16777215 PIXEL

    fprovadores()
    @ 084, 207 BUTTON oButton1 PROMPT "Ok" SIZE 037, 012 OF oDlg ACTION oDlg:END()  PIXEL

  ACTIVATE MSDIALOG oDlg CENTERED
Return  

//------------------------------------------------
Static Function fprovadores()
//------------------------------------------------
Local Aprovadores
Local cNomeAprov  := ""
Local cStatus := ""
Local cSQL:= "TBSZC"
Local aDados := {}
cQuery := " SELECT ZC_NIVEL,ZC_APROVA,ZC_DATALIB,ZC_LIBERA,ZC_NUM "
cQuery += " FROM " + RetSqlName("SZC") + " SZC"
cQuery += " WHERE ZC_FILIAL = '" + xFilial("SE2") + "' "
cQuery += " AND ZC_PREFIXO = '" + SE2->E2_PREFIXO + "' "
cQuery += " AND ZC_NUM = '" + SE2->E2_NUM + "' "
//cQuery += " AND ZC_PARCELA = '" + SE2->E2_PARCELA + "' "
cQuery += " AND ZC_TIPO = '" + SE2->E2_TIPO + "' "
cQuery += " AND ZC_FORNECE = '" + SE2->E2_FORNECE + "' "
cQuery += " AND ZC_LOJA = '" + SE2->E2_LOJA + "' "
cQuery += " AND SZC.D_E_L_E_T_ = ' ' "
cQuery += " ORDER BY ZC_NIVEL
		
    If SELECT(cSQL) > 0
        (cSQL)->(DbCloseArea())
    Endif
    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cSQL,.T.,.T.) 
    If !Empty((cSQL)->ZC_APROVA)
      Do While (cSQL)->(!Eof())
          PswOrder(1)    // ordenado pelo codigo
          If PswSeek((cSQL)->ZC_APROVA, .T. )
              aInfo := PswRet()
              cNomeAprov  := Alltrim(aInfo[1][2])
          EndIf
          If (cSQL)->ZC_LIBERA == 'OK'
              cStatus := 'Liberado'
          Else
              cStatus := 'Aguardando Lib.'
          Endif            
          Aadd(aDados,{cNomeAprov,(cSQL)->ZC_NIVEL,cStatus})
          (cSQL)->(dbSkip())
      EndDo
      @ 004, 003 LISTBOX Aprovadores Fields HEADER "APROVADOR","NIVEL","STATUS" SIZE 243, 077 OF oDlg PIXEL ColSizes 50,50
      Aprovadores:SetArray(aDados)
      Aprovadores:bLine := {|| {;
        aDados[Aprovadores:nAt,1],;
        aDados[Aprovadores:nAt,2],;
        aDados[Aprovadores:nAt,3];
      }}
    else
      MsgInfo("Alçada de aprovação não encontrada", "Atenção")
    Endif    
    // DoubleClick event
    //Aprovadores:bLDblClick := {|| aprovadores[Aprovadores:nAt,1] := !aprovadores[Aprovadores:nAt,1],;
      //Aprovadores:DrawSelect()}

Return
