#Include "Rwmake.ch"
#Include "Protheus.ch"
#Include "Topconn.ch"
#Include "TBICONN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMT100TOK  บAutor  ณSangelles           บ Data ณ  12/10/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
user function MT100AGR  
     
	if INCLUI 
		_cSQL := "SELECT COUNT(*) QTDE FROM "+RetSqlName("SE2")+" "
		_cSQL += " WHERE E2_PREFIXO = 'PRO' "
		_cSQL += " AND D_E_L_E_T_ <> '*' "
		_cSQL += " AND E2_SALDO > 0  "
		_cSQL += " AND E2_FORNECE = '"+cA100For+"' "    
		_cSQL += " AND E2_LOJA    = '"+cLoja+"' "  
		_cSQL += " AND E2_FILIAL  = '"+xFilial("SE2")+"' "
		
		If Select("TMP") > 0
			TMP->(dbCloseArea())
		EndIf
		dbUseArea(.T.,"TOPCONN", TCGenQry(,,_cSQL), "TMP", .F., .T.)
		
		//Altera็ใo a pedido do Leonardo aAbax - Stephen 
	    if TMP->QTDE > 0 .and. !IsInCallStack("U_MTUFOPRO") 
			if MsgYesNo("Existem Provis๕es a Pagar para este fornecedor. Deseja fazer a compensa็ใo?")
				funValida()
			endif           
		endif    
	endif
    if INCLUI == .F. .and. ALTERA == .F.  
    
    	_cSQL := "SELECT COUNT(*) QTDE FROM "+RetSqlName("SE2")+" "
		_cSQL += " WHERE E2_PREFIXO = 'PRO' "
		_cSQL += " AND D_E_L_E_T_ = '*' "
		_cSQL += " AND E2_FORNECE  = '"+cA100For+"' "    
		_cSQL += " AND E2_LOJA     = '"+cLoja+"' "  
		_cSQL += " AND E2_FILIAL   = '"+xFilial("SE2")+"' "
		_cSQL += " AND E2_XPROVIS  = '"+cNFiscal+"' "
		
		If Select("TMP") > 0
			TMP->(dbCloseArea())
		EndIf
		dbUseArea(.T.,"TOPCONN", TCGenQry(,,_cSQL), "TMP", .F., .T.)
		
	    if TMP->QTDE > 0
	    		cQry := " UPDATE "+RetSqlName("SE2")+" SET D_E_L_E_T_ = '' "
				cQry += " WHERE E2_PREFIXO = 'PRO' "
				cQry += " AND D_E_L_E_T_ = '*' "
				cQry += " AND E2_FORNECE  = '"+cA100For+"' "    
				cQry += " AND E2_LOJA     = '"+cLoja+"' "  
	   			cQry += " AND E2_FILIAL   = '"+xFilial("SE2")+"' "
	   			cQry += " AND E2_XPROVIS  = '"+cNFiscal+"' "
				
				If (TCSQLExec(cQry) < 0)
			    	Return MsgStop("Erro ao ATUALIZAR DADOS DE FINANCEIRO! " + TCSQLError())
				EndIf    
				
				cQry := " UPDATE "+RetSqlName("SZ1")+" SET Z1_STATUS = '1' "
				cQry += " WHERE D_E_L_E_T_ <> '*'  "
				cQry += "  AND Z1_FILIAL = '"+xFilial("SZ1")+"' "
				cQry += "  AND Z1_CODIGO IN (  "
				cQry += "  SELECT E2_NUM FROM SE2010  "
				cQry += "  WHERE E2_XPROVIS = '"+cNFiscal+"' "
				cQry += "   AND E2_FILIAL = '"+xFilial("SE2")+"' "
				cQry += "   AND D_E_L_E_T_ <> '*')   "
				
				If (TCSQLExec(cQry) < 0)
			    	Return MsgStop("Erro ao ATUALIZAR DADOS DE FINANCEIRO! " + TCSQLError())
				EndIf 
		endif
    endif     
return .T.

static function funValida
	
Private oButton1
Private oButton2
Private cxTipo := cTipo 
Static oDlg3 

  DEFINE MSDIALOG oDlg3 TITLE "Provis๕es a Pagar" FROM 000, 000  TO 400, 800 COLORS 0, 16777215 PIXEL

    fMSNewGe1()
    
   	@ 179, 348 BUTTON oButton1 PROMPT "Salvar" SIZE 037, 012 OF oDlg3 PIXEL action funSalvar()
    @ 179, 307 BUTTON oButton2 PROMPT "Cancelar" SIZE 037, 012 OF oDlg3 PIXEL action oDlg3:end()

  ACTIVATE MSDIALOG oDlg3 CENTERED

Return

//------------------------------------------------ 
Static Function fMSNewGe1()
//------------------------------------------------ 
Local nX := 0
Local aDadosZ1 := {}
Private aHeaderEx := {}
Private aColsEx := {}
Private aFieldFill := {}
Private aFields := {"OK","E2_NUM","E2_PARCELA", "E2_EMISSAO", "E2_VENCREA","E2_VALOR"}
Private aAlterFields := {"OK"}
Static oMSNewGe3

 // Define field properties
DbSelectArea("SX3")
SX3->(DbSetOrder(2))
For nX := 1 to Len(aFields)
	aDadosZ1 :=FWSX3Util():GetFieldStruct(Alltrim(aFields[nX]))
	If Len(aDadosZ1) > 0
		Aadd(aHeaderEx,{ GetSX3Cache(aDadosZ1[1],"X3_TITULO"), aDadosZ1[1], X3Picture(aDadosZ1[1]),aDadosZ1[3],aDadosZ1[4],GetSX3Cache(aDadosZ1[1],"X3_VALID"),GetSX3Cache(aDadosZ1[1],"X3_USADO"), aDadosZ1[2],"",GetSX3Cache(aDadosZ1[1],"X3_CONTEXT")})
	Else 
		Aadd(aHeaderEx, {"Selec.","OK","@BMP",3,0,"AllwaysTrue()","","C","","V"})
	EndIF 
Next nX
  
//Preenchimento dos campos editแveis no aCols
_cSQL := "SELECT E2_FILIAL, E2_NUM, E2_PARCELA, E2_EMISSAO, E2_VENCREA, E2_VALOR FROM "+RetSqlName("SE2")+" "
_cSQL += " WHERE E2_PREFIXO = 'PRO' "
_cSQL += " AND D_E_L_E_T_ <> '*' "
_cSQL += " AND E2_SALDO > 0  "
_cSQL += " AND E2_FORNECE = '"+cA100For+"' "    
_cSQL += " AND E2_LOJA    = '"+cLoja+"' "  
_cSQL += " AND E2_FILIAL  = '"+xFilial("SE2")+"' "

_cSQL += " ORDER BY E2_NUM, E2_PARCELA "

If Select("TMP") > 0
	TMP->(dbCloseArea())
EndIf
dbUseArea(.T.,"TOPCONN", TCGenQry(,,_cSQL), "TMP", .F., .T.)


While !TMP->(EOF())
	Aadd(aFieldFill, {"LBOK", TMP->E2_NUM, TMP->E2_PARCELA, stod(TMP->E2_EMISSAO), stod(TMP->E2_VENCREA), TMP->E2_VALOR , .F. } )
	TMP->(dbskip())
end

if len(aFieldFill) == 0
	Aadd(aFieldFill, {"LBOK", TMP->E2_NUM, TMP->E2_PARCELA, stod(TMP->E2_EMISSAO), stod(TMP->E2_VENCREA), TMP->E2_VALOR , .F. } )
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
  bSvblDblClick := oMSNewGe3:oBrowse:bLDblClick
  oMSNewGe3:oBrowse:bLDblClick := {|| if(oMSNewGe3:oBrowse:nColPos<>1,GdRstDblClick(@oMSNewGe3,@bSvblDblClick),CLIQUE())}


Return

static function funSalvar
	
	Local nX := 0
	
	for nX := 1 to len(oMSNewGe3:aCols)
		if oMSNewGe3:aCols[nX][1] == "LBOK"
	
				aArray := {}
 
				PRIVATE lMsErroAuto := .F.
				    
				cQry := " UPDATE "+RetSqlName("SE2")+" SET E2_XPROVIS = '"+cNFiscal+"' "
				cQry += " WHERE E2_FILIAL = '"+xFilial("SE2")+"'  "
				cQry += "  AND E2_NUM     = '"+oMSNewGe3:ACOLS[nX][2]+"' " 
				cQry += "  AND E2_PARCELA = '"+oMSNewGe3:ACOLS[nX][3]+"' " 
				cQry += "  AND E2_FORNECE = '"+cA100For+"' " 
				cQry += "  AND E2_LOJA   = '"+cLoja+"' " 
				cQry += "  AND D_E_L_E_T_ <> '*' AND E2_PREFIXO = 'PRO' "
				
				If (TCSQLExec(cQry) < 0)
			    	Return MsgStop("Erro ao ATUALIZAR DADOS DE FINANCEIRO! " + TCSQLError())
				EndIf 
			
				aArray := { { "E2_PREFIXO" , "PRO" 						, NIL },;
							{ "E2_FILIAL"  , xFilial("SE2")				, NIL },;
				            { "E2_NUM"     , oMSNewGe3:ACOLS[nX][2]     , NIL } }
				 
				MsExecAuto( { |x,y,z| FINA050(x,y,z)}, aArray,, 5)  // 3 - Inclusao, 4 - Altera็ใo, 5 - Exclusใo
				 
				If lMsErroAuto
				    MostraErro()
				    return
				Endif
				
				SZ1->(dbsetorder(1))
				SZ1->(dbgotop())
				if SZ1->(dbseek(xFilial("SZ1")+oMSNewGe3:ACOLS[nX][2]))
					RecLock("SZ1",.F.)
					SZ1->Z1_STATUS := "2"
					SZ1->Z1_DTESTOR := ddatabase
					SZ1->(MsUnlock())                                      
				endif
		
		endif
	next nX
	//Aviso("Informa็ใo","Rateio gravado com sucesso!",{"OK"}) 
	oDlg3:end()
	
return

static Function CLIQUE()
	if oMSNewGe3:ACOLS[oMSNewGe3:NAT][1] == "LBOK"
		oMSNewGe3:ACOLS[oMSNewGe3:NAT][1] := "LBNO"
	else
		oMSNewGe3:ACOLS[oMSNewGe3:NAT][1] := "LBOK"
	endif
	oMSNewGe3:REFRESH()
return
