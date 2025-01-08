#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRFATA002  บAutor  ณLeonardo/Sangelles  บ Data ณ  20/10/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

user function RFATA002(cTipo)
 
 Private cxTipo   := cTipo
 Private aButtons := {}
 Private aDadosZ1 := {}
 
 if cxTipo ==  "V"              
 	  //aadd(aButtons,{"BUDGET",{||},"Rateio"})
 
	  aAdd( aButtons, { "PRODUTO", {||  U_RFATA003("V")}, "Rateio", "Rateio" } ) 

	
		AxVisual("SZ1",,,,,,,aButtons,,,,,,,,,)                                                                       



 elseif cxTipo ==  "I"              
     
 	  aadd(aButtons,{"BUDGET",{|| U_RFATA003("I")},"Rateio", "Rateio" })
 
	 If AxInclui("SZ1",,,,,,,,,aButtons,,,,) == 1        
		//AxInclui( <cAlias>, <nReg>, <nOpc>, <aAcho>, <cFunc>, <aCpos>, <cTudoOk>, <lF3>, <cTransact>, <aButtons>, <aParam>, <aAuto>, <lVirtual>, <lMaximized>)                                               
	 	aAutoSE2 	:= {}
		AAdd(aAutoSE2, {"E2_PREFIXO"   ,"PRO"				,NIL})
		AAdd(aAutoSE2, {"E2_NUM"   	   ,SZ1->Z1_CODIGO		,NIL}) 
		AAdd(aAutoSE2, {"E2_TIPO"  	   ,"PR"				,NIL})
		AAdd(aAutoSE2, {"E2_NATUREZ"   ,"208017"		 	,NIL})   
		AAdd(aAutoSE2, {"E2_FORNECE"   ,SZ1->Z1_FORNECE	 	,NIL})   		
		AAdd(aAutoSE2, {"E2_LOJA"      ,SZ1->Z1_LOJA	 	,NIL})
		AAdd(aAutoSE2, {"E2_EMISSAO"   ,SZ1->Z1_DATAPRO	 	,NIL}) 
		AAdd(aAutoSE2, {"E2_VENCTO"    ,SZ1->Z1_DTVENC	 	,NIL})
		AAdd(aAutoSE2, {"E2_VENCREA"   ,SZ1->Z1_DTVENC	 	,NIL})  
		AAdd(aAutoSE2, {"E2_VALOR"     ,SZ1->Z1_VALOR	 	,NIL})
		AAdd(aAutoSE2, {"E2_VLCRUZ"    ,SZ1->Z1_VALOR		,NIL}) 
		AAdd(aAutoSE2, {"E2_SALDO"     ,SZ1->Z1_VALOR		,NIL})
		AAdd(aAutoSE2, {"E2_XCONTAB"   ,SZ1->Z1_CONTABI		,NIL})

		lMsErroAuto	:= .F.	
		
		MsExecAuto({|x, y| FINA050(x, y)}, aAutoSE2, 3) //3 = Opcao de inclusao 
			
   		If lMsErroAuto
			MostraErro()
		endif
	 endif
 elseIF cxTipo == "L"
 
	aLegenda := {}	
	AADD(aLegenda,{"BR_VERDE" 		,"Provisใo Inclusa"	})
	AADD(aLegenda,{"BR_VERMELHO" 	,"Provisใo Estornada"	})	
	BrwLegenda(cCadastro, "Legenda", aLegenda)
 else
   		Private oButton1
		Private oButton2
		Private oGet1
		Private cGet1 := space(6)
		Private oGet2
		Private cGet2 := "ZZZZZZ"
		Private dGet3 := ctod("  /  /  ")
		Private oGet4
		Private dGet4 := ctod("  /  /  ")
		Private oGet5
		Private dGet5 := ctod("  /  /  ")
		Private oGet6
		Private dGet6 := ctod("  /  /  ")
		Private oSay1
		Private oSay2
		Private oSay3
		Private oSay4
		Private oSay5
		Private oSay6
		Private oSay7
		Static oDlg
		
		  DEFINE MSDIALOG oDlg TITLE "Sele็ใo de Filtro" FROM 000, 000  TO 250, 350 COLORS 0, 16777215 PIXEL
		
		    @ 021, 013 MSGET oGet1 VAR cGet1 SIZE 060, 010 OF oDlg COLORS 0, 16777215 F3 "SA2" PIXEL
		    @ 025, 078 SAY oSay2 PROMPT "เ" SIZE 009, 007 OF oDlg COLORS 0, 16777215 PIXEL
		    @ 021, 088 MSGET oGet2 VAR cGet2 SIZE 060, 010 OF oDlg COLORS 0, 16777215 F3 "SA2" PIXEL
		    @ 012, 014 SAY oSay3 PROMPT "Fornecedor" SIZE 050, 007 OF oDlg COLORS 0, 16777215 PIXEL
		    @ 038, 014 SAY oSay4 PROMPT "Data Provisใo" SIZE 059, 007 OF oDlg COLORS 0, 16777215 PIXEL
		    @ 048, 014 MSGET oGet3 VAR dGet3 SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL
		    @ 052, 079 SAY oSay5 PROMPT "เ" SIZE 009, 007 OF oDlg COLORS 0, 16777215 PIXEL
		    @ 048, 089 MSGET oGet4 VAR dGet4 SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL
		    @ 063, 014 SAY oSay6 PROMPT "Data Vencimento" SIZE 059, 007 OF oDlg COLORS 0, 16777215 PIXEL
		    @ 072, 014 MSGET oGet5 VAR dGet5 SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL
		    @ 076, 079 SAY oSay7 PROMPT "เ" SIZE 009, 007 OF oDlg COLORS 0, 16777215 PIXEL
		    @ 072, 089 MSGET oGet6 VAR dGet6 SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL
		    if cxTipo == "E"
			    @ 093, 112 BUTTON oButton1 PROMPT "Estornar" SIZE 037, 012 OF oDlg PIXEL action funProcessa()
		    else
			    @ 093, 112 BUTTON oButton1 PROMPT "Excluir" SIZE 037, 012 OF oDlg PIXEL action funProcessa()
		    endif
		    @ 093, 071 BUTTON oButton2 PROMPT "Cancelar" SIZE 037, 012 OF oDlg PIXEL action oDlg:end()
		
		  ACTIVATE MSDIALOG oDlg CENTERED
		
 endif
Return Nil

static function funProcessa 

Private oButton1
Private oButton2
Private oButton3
Static oDlg2

  DEFINE MSDIALOG oDlg2 TITLE "Tela de Estorno de Titulos Provisionados" FROM 000, 000  TO 500, 1100 COLORS 0, 16777215 PIXEL

    fMSNewGe1()
    @ 229, 010 BUTTON oButton1 PROMPT "Inverter Sele็ใo" SIZE 044, 012 OF oDlg2 PIXEL action funSelTudo() 
    if cxTipo == "E"
	    @ 229, 502 BUTTON oButton2 PROMPT "Estornar" SIZE 037, 012 OF oDlg2 PIXEL action Processa({|| funGrava()},"Estornando Tํtulos Provisionados...") 
	else
		@ 229, 502 BUTTON oButton2 PROMPT "Excluir" SIZE 037, 012 OF oDlg2 PIXEL action Processa({|| funExcluir()},"Estornando Tํtulos Provisionados...") 
	endif
    @ 229, 461 BUTTON oButton3 PROMPT "Cancelar" SIZE 037, 012 OF oDlg2 PIXEL action oDlg2:end()

  ACTIVATE MSDIALOG oDlg2 CENTERED

Return

//------------------------------------------------
Static Function fMSNewGe1()
//------------------------------------------------
Local aDadosZ1		:= {}
Local nX			:= 0 
Private aHeaderEx 	:= {}
Private aColsEx 	:= {}
Private aFieldFill 	:= {}
Private aFields 	:= {"OK", "Z1_FILIAL","Z1_CODIGO", "Z1_FORNECE", "Z1_LOJA", "A2_NOME", "Z1_DATAPRO", "Z1_DTVENC", "Z1_VALOR"}
Private aAlterFields:= {}
Static oMSNewGe1	:= Nil

 // Define field properties
For nX := 1 to Len(aFields)
	aDadosZ1 :=FWSX3Util():GetFieldStruct(Alltrim(aFields[nX]))
	If Len(aDadosZ1) > 0
		Aadd(aHeaderEx,{ GetSX3Cache(aDadosZ1[1],"X3_TITULO"), aDadosZ1[1], X3Picture(aDadosZ1[1]),aDadosZ1[3],aDadosZ1[4],GetSX3Cache(aDadosZ1[1],"X3_VALID"),GetSX3Cache(aDadosZ1[1],"X3_USADO"), aDadosZ1[2],"",GetSX3Cache(aDadosZ1[1],"X3_CONTEXT")})
	Else 
		Aadd(aHeaderEx, {"Selec.","OK","@BMP",3,0,"AllwaysTrue()","","C","","V"})
	EndIF 
Next nX
               
_cSQL := "  SELECT Z1_FILIAL, Z1_CODIGO, Z1_FORNECE, Z1_LOJA, A2_NOME, Z1_DATAPRO, Z1_DTVENC, Z1_VALOR FROM "+RetSqlName("SZ1")+" SZ1, "+ RetSqlName("SA2")+" SA2 "
_cSQL += "WHERE SZ1.D_E_L_E_T_ <> '*' " 
_cSQL += "  AND SA2.D_E_L_E_T_ <> '*' "
_cSQL += "  AND A2_COD  = Z1_FORNECE "
_cSQL += "  AND A2_LOJA = Z1_LOJA AND Z1_STATUS = '1' "

//_cSQL += "  AND Z1_FILIAL = '"+xFilial("SZ1")+"' "
                     
if cGet1 <> space(6) .or. cGet2 <> "ZZZZZZ"
	_cSQL += "  AND Z1_FORNECE BETWEEN '"+cGet1+"' AND '"+cGet2+"' " 
endif
if dGet3 <> ctod("  /  /  ")  .or. dGet4 <> ctod("  /  /  ") 
	_cSQL += "  AND Z1_DATAPRO BETWEEN '"+dtos(dGet3)+"' AND '"+dtos(dGet4)+"' " 
endif
if dGet5 <> ctod("  /  /  ")  .or. dGet6 <> ctod("  /  /  ") 
	_cSQL += "  AND Z1_DTVENC BETWEEN '"+dtos(dGet5)+"' AND '"+dtos(dGet6)+"' " 
endif
  
_cSQL += " ORDER BY Z1_FILIAL, Z1_FORNECE, Z1_LOJA, A2_NOME, Z1_DATAPRO, Z1_DTVENC, Z1_VALOR "
 
If Select("TMP") > 0
	TMP->(dbCloseArea())
EndIf
dbUseArea(.T.,"TOPCONN", TCGenQry(,,_cSQL), "TMP", .F., .T.)


While !TMP->(EOF())
	Aadd(aFieldFill, {"LBOK", TMP->Z1_FILIAL, TMP->Z1_CODIGO, TMP->Z1_FORNECE, TMP->Z1_LOJA, TMP->A2_NOME, TMP->Z1_DATAPRO,TMP->Z1_DTVENC,TMP->Z1_VALOR, .F. } )
	TMP->(dbskip())
end

if len(aFieldFill) == 0
	Aviso("Aten็ใo","Nใo existe Tํtulo(s) Provisionado(s) para ser estornado(s)!",{"OK"}) 
		oDlg2:end()
		oDlg:end()
	return
endif

// Define field values
//if len(aFieldFill) == 0
//	For nX := 1 to Len(aFields)
//		If DbSeek(aFields[nX])
//			Aadd(aFieldFill, CriaVar(SX3->X3_CAMPO))
//		Endif
//	Next nX
//endif

aColsEx := aFieldFill

  oMSNewGe1 := MsNewGetDados():New(  013, 006, 222, 542, GD_INSERT+GD_DELETE+GD_UPDATE, "AllwaysTrue", "AllwaysTrue", "+Field1+Field2", aAlterFields,, 999, "AllwaysTrue", "", "AllwaysTrue", oDlg2, aHeaderEx, aColsEx)
   
  bSvblDblClick := oMSNewGe1:oBrowse:bLDblClick
  oMSNewGe1:oBrowse:bLDblClick := {|| if(oMSNewGe1:oBrowse:nColPos<>1,GdRstDblClick(@oMSNewGe1,@bSvblDblClick),CLIQUE())}

Return


static Function CLIQUE()



	if oMSNewGe1:ACOLS[oMSNewGe1:NAT][1] == "LBOK"
		oMSNewGe1:ACOLS[oMSNewGe1:NAT][1] := "LBNO"
	else
		oMSNewGe1:ACOLS[oMSNewGe1:NAT][1] := "LBOK"
	endif

return

static Function funSelTudo

Local nX := 0
	for nX := 1 to len(oMSNewGe1:ACOLS)
			if oMSNewGe1:ACOLS[nX][1] == "LBOK"
				oMSNewGe1:ACOLS[nX][1] := "LBNO"
			else
				oMSNewGe1:ACOLS[nX][1] := "LBOK"
			endif		
	next nX
return 


static function funGrava

Local nX := 0

		for nX := 1 to len(oMSNewGe1:ACOLS)
			if oMSNewGe1:ACOLS[nX][1]  == "LBOK"
				aArray := {}
 
				PRIVATE lMsErroAuto := .F.
				 
				                                
				aArray := { { "E2_PREFIXO" , "PRO" 						, NIL },;
							{ "E2_FILIAL"  , oMSNewGe1:ACOLS[nX][2]		, NIL },;
				            { "E2_NUM"     , oMSNewGe1:ACOLS[nX][3]     , NIL } }
				 
				MsExecAuto( { |x,y,z| FINA050(x,y,z)}, aArray,, 5)  // 3 - Inclusao, 4 - Altera็ใo, 5 - Exclusใo
				 
				If lMsErroAuto
				    MostraErro()
				    return
				Endif
				
				SZ1->(dbsetorder(1))
				SZ1->(dbgotop())
				if SZ1->(dbseek(oMSNewGe1:ACOLS[nX][2]+oMSNewGe1:ACOLS[nX][3]))
					RecLock("SZ1",.F.)
					SZ1->Z1_STATUS := "2" 
					SZ1->Z1_DTESTOR := ddatabase //NAO ESTAVA GRAVANDO LEO/SANGELLES 26/01/2017
					SZ1->(MsUnlock())                                      
				endif
			endif			
		next nX 
		Aviso("Informa็ใo","Tํtulos Provisionados estornados com sucesso!",{"OK"})
		oDlg2:end()
		oDlg:end()
return 



static function funExcluir

Local nX := 0

		for nX := 1 to len(oMSNewGe1:ACOLS)
			if oMSNewGe1:ACOLS[nX][1]  == "LBOK"
				
				SE2->(dbsetorder(1))
				SE2->(dbgotop())
				if SE2->(dbseek(oMSNewGe1:ACOLS[nX][2]+"PRO"+oMSNewGe1:ACOLS[nX][3]))
				
					cQry := " UPDATE "+RetSqlName("CT2")+" SET D_E_L_E_T_ = '*' "
					cQry += " WHERE CT2_DATA = '"+dtos(SE2->E2_EMISSAO)+"'  "
					cQry += "  AND (UPPER(CT2_HIST) LIKE 'INC TITPRO "+oMSNewGe1:ACOLS[nX][3]+"%' OR  "
					cQry += " 	  UPPER(CT2_HIST) LIKE 'EST TITPRO "+oMSNewGe1:ACOLS[nX][3]+"%')  "
					cQry += "  AND CT2_FILIAL = '"+SUBSTR(oMSNewGe1:ACOLS[nX][2],1,2)+"'  "
					cQry += "  AND D_E_L_E_T_ <> '*' " "
					If (TCSQLExec(cQry) < 0)
			    		Return MsgStop("Erro ao excluir importa็ใo da contabilidade! " + TCSQLError())
					EndIf 
					RecLock( "SE2" ,.F.)
					SE2->(dbDelete())
					SE2->(MsUnlock())	
				endif						 			     
				SZ1->(dbsetorder(1))
				SZ1->(dbgotop())
				if SZ1->(dbseek(oMSNewGe1:ACOLS[nX][2]+oMSNewGe1:ACOLS[nX][3]))
					RecLock("SZ1",.F.)
					//SZ1->Z1_STATUS := "3"
					SZ1->(dbdelete())
					SZ1->(MsUnlock())                                      
				endif
			endif			
		next nX 
		Aviso("Informa็ใo","Tํtulos Provisionados exclusos com sucesso!",{"OK"})
		oDlg2:end()
		oDlg:end()

return 
