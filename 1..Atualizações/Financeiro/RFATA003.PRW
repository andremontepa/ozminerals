#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RFATA003  ºAutor  ³Leonardo/Sangelles  º Data ³  20/10/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

user function RFATA003(cTipo)

Local aDadosZ2		:= {}
Private oButton1
Private oButton2
Private cxTipo := cTipo 
Static oDlg3

  DEFINE MSDIALOG oDlg3 TITLE "Rateio por Centro de Custo e Item Contábil" FROM 000, 000  TO 400, 800 COLORS 0, 16777215 PIXEL

    fMSNewGe1()
    if cxTipo == "I"
    	@ 179, 348 BUTTON oButton1 PROMPT "Salvar" SIZE 037, 012 OF oDlg3 PIXEL action funSalvar()
    endif

    @ 179, 307 BUTTON oButton2 PROMPT "Cancelar" SIZE 037, 012 OF oDlg3 PIXEL action oDlg3:end()

  ACTIVATE MSDIALOG oDlg3 CENTERED

Return

//------------------------------------------------ 
Static Function fMSNewGe1()
//------------------------------------------------ 
Local nX	:= 0
Private aHeaderEx := {}
Private aColsEx := {}
Private aFieldFill := {}
Private aFields := {"Z2_CC","Z2_ITEMC", "Z2_DEBITO", "Z2_VALOR"}
Private aAlterFields := {"Z2_CC","Z2_ITEMC","Z2_DEBITO","Z2_VALOR"}
Static oMSNewGe3

  // Define field properties
  DbSelectArea("SX3")
  SX3->(DbSetOrder(2))

  For nX := 1 to Len(aFields)
	aDadosZ2 := FWSX3Util():GetFieldStruct(Alltrim(aFields[nX]))
	If Len(aDadosZ2) > 0
		Aadd(aHeaderEx,{ GetSX3Cache(aDadosZ2[1],"X3_TITULO"), aDadosZ2[1], X3Picture(aDadosZ2[1]),aDadosZ2[3],aDadosZ2[4],GetSX3Cache(aDadosZ2[1],"X3_VALID"),GetSX3Cache(aDadosZ2[1],"X3_USADO"), aDadosZ1[2],"",GetSX3Cache(aDadosZ1[1],"X3_CONTEXT")})
	Endif
  Next nX         
  
  
//Preenchimento dos campos editáveis no aCols
_cSQL := " SELECT Z2_ITEM, Z2_CC, Z2_ITEMC, Z2_DEBITO, Z2_VALOR FROM "+RetSqlName("SZ2")+" "
_cSQL += " WHERE Z2_FILIAL = '"+xFilial("SZ2")+"' "
_cSQL += "   AND Z2_CODIGO = '"+M->Z1_CODIGO+"' "
_cSQL += "   AND D_E_L_E_T_ <> '*' ORDER BY Z2_ITEM "

If Select("TMP") > 0
	TMP->(dbCloseArea())
EndIf
dbUseArea(.T.,"TOPCONN", TCGenQry(,,_cSQL), "TMP", .F., .T.)


While !TMP->(EOF())
	Aadd(aFieldFill, {TMP->Z2_CC,TMP->Z2_ITEMC, TMP->Z2_DEBITO, TMP->Z2_VALOR , .F. } )
	TMP->(dbskip())
end

if len(aFieldFill) == 0
	Aadd(aFieldFill, {TMP->Z2_CC,TMP->Z2_ITEMC, TMP->Z2_DEBITO, TMP->Z2_VALOR, .F. } )
endif
// Define field values
//if len(aFieldFill) == 0
//	For nX := 1 to Len(aFields)
//		If DbSeek(aFields[nX])
//			Aadd(aFieldFill, CriaVar(SX3->X3_CAMPO))
//		Endif
//	Next nX
//endif
//Aadd(aFieldFill, .F.)
//Aadd(aColsEx, aFieldFill)
aColsEx := aFieldFill

  oMSNewGe3 := MsNewGetDados():New( 010, 005, 169, 388, GD_INSERT+GD_DELETE+GD_UPDATE, "AllwaysTrue", "AllwaysTrue", "+Field1+Field2", aAlterFields,, 999, "AllwaysTrue", "", "AllwaysTrue", oDlg3, aHeaderEx, aColsEx)

Return


static function funSalvar
	
	Local nX := 0 

	nValor   := M->Z1_VALOR
	nValGrid := 0
	
	for nX := 1 to len(oMSNewGe3:aCols)
		nValGrid += oMSNewGe3:aCols[nX][04]
	next nX                               
	if nValor <> nValGrid
		Aviso("Atenção","Valor do rateio difere do valor principal",{"OK"})   
	else             
		cQry := " UPDATE "+RetSqlName("SZ2")+" SET D_E_L_E_T_ = '*' "
		cQry += " WHERE Z2_FILIAL = '"+xFilial("SZ2")+"'  "		
		cQry += "  AND Z2_CODIGO = '"+M->Z1_CODIGO+"'  "
		cQry += "  AND D_E_L_E_T_ <> '*' " "
		If (TCSQLExec(cQry) < 0)
		 		Return MsgStop("Erro ao excluir Rateio! " + TCSQLError())
		EndIf 

		for nX := 1  to len(oMSNewGe3:aCols)
				RecLock("SZ2",.T.)
				SZ2->Z2_FILIAL := xFilial("SZ2")
				SZ2->Z2_CODIGO := M->Z1_CODIGO
				SZ2->Z2_ITEM   := PADL(ALLTRIM(STR(nX)),3,"0")
				SZ2->Z2_CC     := oMSNewGe3:aCols[nX][01]
				SZ2->Z2_ITEMC  := oMSNewGe3:aCols[nX][02]
				SZ2->Z2_DEBITO := oMSNewGe3:aCols[nX][03]
				SZ2->Z2_VALOR  := oMSNewGe3:aCols[nX][04]				
				SZ2->(MsUnlock())                                      		
		next nX
		Aviso("Informação","Rateio gravado com sucesso!",{"OK"}) 
		oDlg3:end()
	endif
return
