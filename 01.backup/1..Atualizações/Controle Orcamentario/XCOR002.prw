#Include "Rwmake.ch"
#Include "Protheus.ch"
#Include "Topconn.ch"

#Define  APOS {  15,  1, 70, 315 }

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณXCOR002   บAutor  ณ Ismael Junior      บ Data ณ  09/10/17   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Cadastro Gestores x Centro de Custos                       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Estoque e custos                                           บฑฑ        
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function XCOR002()        
Private cCadastro := "Cadastro Gestores x Centro de custos"

Private aRotina   := { { "Pesquisa"   ,"AxPesqui"   ,0,1},; //"Pesquisar"
{ "Visualizar" ,"u_COR02Vis",0,2},; //"Visual"
{ "Incluir"    ,"u_COR02Inc",0,3},; //"Incluir"
{ "Alterar"    ,"u_COR02Alt",0,4},; //"Alterar"
{ "Excluir"    ,"u_COR02Exc",0,5} } //"Exclusao"
Private aCmp     := {{"Filial"   ,"ZW4_FILIAL"     ,"", 00,00,"@!"},;
{"Cod Gestor"  ,"ZW4_COD"   ,"", 00,00,"@!"},;
{"Nome Gestor" ,"ZW4_NOME"  ,"", 00,00,"@!"}}

dbSelectArea("ZW4")
dbSetOrder(1)
MBrowse(6,1,22,75,"ZW4",aCmp,,,,,fCriaCor())
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ COR02Vis  บAutor  ณ Ismael Junior em 09/10/2017            บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo de visualiza็ใo do registro                         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ ExpC1: Alias do arquivo                                    บฑฑ
ฑฑบ          ณ ExpN2: Registro do Arquivo                                 บฑฑ
ฑฑบ          ณ ExpN3: Opcao da MBrowse                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function COR02Vis(cAlias,nReg,nOpcx)
Local aArea     	:= GetArea()
Local oGetDad		:= Nil 
Local oDlg			:= Nil 
Local nUsado    	:= 0
Local nCntFor   	:= 0
Local cCadastro 	:= "Controle Or็amentario - Visualiza็ใo"
Local cQuery    	:= ""
Local cTrab1     	:= "ZW5"
Local bWhile    	:= {|| .T. }
Local aObjects  	:= {}
Local aPosObj   	:= {}
Local aSizeAut  	:= MsAdvSize()
Local nX 			:= 0
Private aDadosZW5 	:= {}
Private aHEADER 	:= {}
Private aCOLS   	:= {}
Private aGETS   	:= {}
Private aTELA   	:= {}

dbSelectArea("ZW4")
dbSetOrder(1)
For nCntFor := 1 To FCount()
	M->&(FieldName(nCntFor)) := FieldGet(nCntFor)
Next nCntFor

// Montagem do aHeader
aDadosZW5 := FWSX3Util():GetListFieldsStruct(cTrab1,.F.)
For nX := 1 To Len(aDadosZW5)
	Aadd(aHeader,{ GetSX3Cache(aDadosZW5[nX][1],"X3_TITULO"), aDadosZW5[nX][1], X3Picture(aDadosZW5[nX][1]),aDadosZW5[nX][3],aDadosZW5[nX][4],GetSX3Cache(aDadosZW5[nX][1],"X3_VALID"),GetSX3Cache(aDadosZW5[nX][1],"X3_USADO"), aDadosZW5[nX][2],cTrab1, GetSX3Cache(aDadosZW5[nX][1],"X3_CONTEXT") } )
Next nX 

// Montagem do aCols                                            |
dbSelectArea("ZW5")
dbSetOrder(1)

cQuery := "SELECT *,R_E_C_N_O_ ZW5RECNO "
cQuery += "FROM "+RetSqlName("ZW5")+" ZW5 "
cQuery += "WHERE ZW5.ZW5_FILIAL='"+xFilial("ZW5")+"' AND "
cQuery +=       "ZW5.ZW5_NUM='"+ZW4->ZW4_NUM+"' AND "
cQuery +=       "ZW5.D_E_L_E_T_<>'*' "
cQuery += "ORDER BY "+SqlOrder(ZW5->(IndexKey()))
cQuery := ChangeQuery(cQuery)
cTrab1 := "CORVis"
If Select(cTrab1) > 0
	(cTrab1)->(DbCloseArea())
Endif
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTrab1,.T.,.T.)

For nCntFor := 1 To Len(aHeader)
	TcSetField(cTrab1,AllTrim(aHeader[nCntFor][2]),aHeader[nCntFor,8],aHeader[nCntFor,4],aHeader[nCntFor,5])
Next nCntFor

Do While ( !Eof() .And. Eval(bWhile) )
	aadd(aCOLS,Array(nUsado+1))
	For nCntFor := 1 To nUsado
		If ( aHeader[nCntFor][10] != "V" )
			aCols[Len(aCols)][nCntFor] := FieldGet(FieldPos(aHeader[nCntFor][2]))
		Else
			ZW5->(dbGoto((cTrab1)->ZW5RECNO))
			aCols[Len(aCols)][nCntFor] := CriaVar(aHeader[nCntFor][2])
		EndIf
	Next nCntFor
	aCOLS[Len(aCols)][Len(aHeader)+1] := .F.
	dbSelectArea(cTrab1)
	dbSkip()
EndDo
dbSelectArea(cTrab1)
dbCloseArea()
dbSelectArea(cAlias)

aObjects := {}
AAdd( aObjects, { 315,  60, .T., .T. } )
AAdd( aObjects, { 100, 100, .T., .T. } )
aInfo   := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects, .T. )

DEFINE MSDIALOG oDlg TITLE cCadastro From aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL
EnChoice( cAlias ,nReg, nOpcx, , , , , aPosObj[1], , 3 )
oGetDad := MSGetDados():New (aPosObj[2,1], aPosObj[2,2], aPosObj[2,3], aPosObj[2,4], nOpcx, "u_COR02LinOk" ,"AllwaysTrue","",.F.)
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||oDlg:End()},{||oDlg:End()})
RestArea(aArea)
//cTrab1->(DbCloseArea())
Return(.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCOR02Inc    บAutor  ณ Ismael Junior em 10/10/2017           บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo de tratamento da inclusใo do registro               บฑฑ
ฑฑบ          ณ COR02Inc(ExpC1,ExpN2,ExpN3)                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ ExpC1: Alias do arquivo                                    บฑฑ
ฑฑบ          ณ ExpN2: Registro do Arquivo                                 บฑฑ
ฑฑบ          ณ ExpN3: Opcao da MBrowse                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function COR02Inc(cAlias,nReg,nOpcx)
Local aArea     := GetArea()
Local cCadastro := OemToAnsi("Cadastro de gestores - Inclusใo")
Local oGetDad	:= Nil
Local oDlg		:= Nil 
Local nUsado    := 0
Local nCntFor   := 0
Local nOpcA     := 0
Local aObjects  := {}
Local aPosObj   := {}
Local aSizeAut  := MsAdvSize()
Local nX		:= 0
Private aHEADER := {}
Private aCOLS   := {}
Private aGETS   := {}
Private aTELA   := {}

// Montagem das Variaveis de Memoria
dbSelectArea("ZW4")
dbSetOrder(1)
For nCntFor := 1 To FCount()
	M->&(FieldName(nCntFor)) := CriaVar(FieldName(nCntFor))
Next nCntFor

// Montagem do aHeader
aDadosZW5 := FWSX3Util():GetListFieldsStruct("ZW5",.F.)
For nX := 1 To Len(aDadosZW5)
	Aadd(aHeader,{ GetSX3Cache(aDadosZW5[nX][1],"X3_TITULO"), aDadosZW5[nX][1], X3Picture(aDadosZW5[nX][1]),aDadosZW5[nX][3],aDadosZW5[nX][4],GetSX3Cache(aDadosZW5[nX][1],"X3_VALID"),GetSX3Cache(aDadosZW5[nX][1],"X3_USADO"), aDadosZW5[nX][2],"ZW5", GetSX3Cache(aDadosZW5[nX][1],"X3_CONTEXT") } )
Next nX 

// Montagem da Acols
aadd(aCOLS,Array(nUsado+1))
For nCntFor := 1 To nUsado
	aCols[1][nCntFor] := CriaVar(aHeader[nCntFor][2])
Next nCntFor

aCOLS[1][1] := Strzero(Val(aCOLS[1][1])+1,2)
aCOLS[1][Len(aHeader)+1] := .F.
aObjects := {}
AAdd( aObjects, { 315,  60, .T., .T. } )
AAdd( aObjects, { 100, 100, .T., .T. } )
aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects, .T. )

DEFINE MSDIALOG oDlg TITLE cCadastro From aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL
EnChoice( cAlias ,nReg, nOpcx, , , , , aPosObj[1], , 3 )
oGetDad := MSGetDados():New(aPosObj[2,1], aPosObj[2,2], aPosObj[2,3], aPosObj[2,4], nOpcx, "u_COR02LinOk(3)", "u_COR02TudOk(3)","+ZW5_ITEM",.T.)
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, {||nOpcA:=If(oGetDad:TudoOk() .And. Obrigatorio(aGets,aTela), 1,0),If(nOpcA==1,oDlg:End(),Nil)},{||oDlg:End()})

If ( nOpcA == 1 )
	Begin Transaction
	COR02Grv(1)
	If ( __lSX8 )
		ConfirmSX8()
	EndIf
	EvalTrigger()
	End Transaction
Else
	If ( __lSX8 )
		RollBackSX8()
	EndIf
EndIf
RestArea(aArea)
Return(.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCOR02Alt   บAutor  ณ Ismael Junior  em 10/10/2017           บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo de tratamento da altera็ใo                          บฑฑ
ฑฑบ          ณ COR02Alt(ExpC1,ExpN2,ExpN3)                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ ExpC1: Alias do arquivo                                    บฑฑ
ฑฑบ          ณ ExpN2: Registro do Arquivo                                 บฑฑ
ฑฑบ          ณ ExpN3: Opcao da MBrowse                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function COR02Alt(cAlias,nReg,nOpcx)
Local aArea     := GetArea()
Local cCadastro := OemToAnsi("Cadastro de Gestores - Altera็ใo")
Local oGetDad	:= Nil 
Local oDlg		:= Nil 
Local nUsado    := 0
Local nCntFor   := 0
Local nOpcA     := 0
Local lContinua := .T.
Local cQuery    := ""
Local cTrab1    := "ZW5"
Local bWhile    := {|| .T. }
Local aObjects  := {}
Local aPosObj   := {}
Local aSizeAut  := MsAdvSize()
Local nX		:= 0
Private aHEADER := {}
Private aCOLS   := {}
Private aGETS   := {}
Private aTELA   := {}

// Montagem das Variaveis de Memoria
dbSelectArea("ZW4")
dbSetOrder(1)
lContinua := SoftLock("ZW4")
If ( lContinua )
For nCntFor := 1 To FCount()
M->&(FieldName(nCntFor)) := FieldGet(nCntFor)
Next nCntFor

// Montagem do aHeader
aDadosZW5 := FWSX3Util():GetListFieldsStruct("ZW5",.F.)
For nX := 1 To Len(aDadosZW5)
	Aadd(aHeader,{ GetSX3Cache(aDadosZW5[nX][1],"X3_TITULO"), aDadosZW5[nX][1], X3Picture(aDadosZW5[nX][1]),aDadosZW5[nX][3],aDadosZW5[nX][4],GetSX3Cache(aDadosZW5[nX][1],"X3_VALID"),GetSX3Cache(aDadosZW5[nX][1],"X3_USADO"), aDadosZW5[nX][2],"ZW5", GetSX3Cache(aDadosZW5[nX][1],"X3_CONTEXT") } )
Next nX 

// Montagem da aCols
dbSelectArea("ZW5")
dbSetOrder(1)

cQuery := "SELECT *,R_E_C_N_O_ ZW5RECNO "
cQuery += "FROM "+RetSqlName("ZW5")+" ZW5 "
cQuery += "WHERE ZW5.ZW5_FILIAL='"+xFilial("ZW5")+"' AND "
cQuery +=       "ZW5.ZW5_NUM='"+ZW4->ZW4_NUM+"' AND "
cQuery +=       "ZW5.D_E_L_E_T_<>'*' "
cQuery += "ORDER BY "+SqlOrder(ZW5->(IndexKey()))
cQuery := ChangeQuery(cQuery)
cTrab1 := "CORAlt"

If Select(cTrab1) > 0
(cTrab1)->(DbCloseArea())
Endif

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTrab1,.T.,.T.)

For nCntFor := 1 To Len(aHeader)
TcSetField(cTrab1,AllTrim(aHeader[nCntFor][2]),aHeader[nCntFor,8],aHeader[nCntFor,4],aHeader[nCntFor,5])
Next nCntFor

Do While ( !Eof() .And. Eval(bWhile) )
aadd(aCOLS,Array(nUsado+1))
For nCntFor := 1 To nUsado
If ( aHeader[nCntFor][10] != "V" )
aCols[Len(aCols)][nCntFor] := FieldGet(FieldPos(aHeader[nCntFor][2]))
Else
ZW5->(dbGoto((cTrab1)->ZW5RECNO))
aCols[Len(aCols)][nCntFor] := CriaVar(aHeader[nCntFor][2])
EndIf
Next nCntFor

aCOLS[Len(aCols)][Len(aHeader)+1] := .F.
dbSelectArea(cTrab1)
dbSkip()
EndDo
dbSelectArea(cTrab1)
//dbCloseArea()
dbSelectArea(cAlias)
EndIf
If ( lContinua )
aObjects := {}
AAdd( aObjects, { 315,  60, .T., .T. } )
AAdd( aObjects, { 100, 100, .T., .T. } )
aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects, .T. )

DEFINE MSDIALOG oDlg TITLE cCadastro From aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL
EnChoice( cAlias ,nReg, nOpcx, , , , , aPosObj[1], , 3 )
oGetDad := MSGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpcx,"u_COR02LinOk(4)","u_COR02TudOk(4)","+ZW5_ITEM",.T.)
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpca:=If(oGetDad:TudoOk().And.Obrigatorio(aGets,aTela),1,0),If(nOpcA==1,oDlg:End(),Nil)},{||oDlg:End()})
If ( nOpcA == 1 )

// Abre a tabela de contratos
Begin Transaction

dbSelectArea(cTrab1)
dbSelectArea(cAlias)

COR02Grv(2)
If ( __lSX8 )
ConfirmSX8()
EndIf
EvalTrigger()
End Transaction
Else
(cTrab1)->(dbCloseArea())
dbSelectArea(cAlias)

If ( __lSX8 )
RollBackSX8()
EndIf
EndIf
Else
//	(cTrab1)->(dbCloseArea())
EndIf
//cTrab1->(DbCloseArea())
RestArea(aArea)
Return(.T.) 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCOR02Exc    บAutor  ณ Ismael Junior em 10/10/2017           บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo que trata a exclusใo                                บฑฑ
ฑฑบ          ณ COR02Exc(ExpC1,ExpN2,ExpN3)                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ ExpC1: Alias do arquivo                                    บฑฑ
ฑฑบ          ณ ExpN2: Registro do Arquivo                                 บฑฑ
ฑฑบ          ณ ExpN3: Opcao da MBrowse                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function COR02Exc(cAlias,nReg,nOpcx)
Local aArea     := GetArea()
Local cCadastro := OemToAnsi("Controle Or็amentario - Exclusใo")
Local oGetDad
Local oDlg
Local nUsado    := 0
Local nCntFor   := 0
Local nOpcA     := 0
Local lContinua := .T.
Local cQuery    := ""
Local cTrab1     := "ZW5"
Local bWhile    := {|| .T. }
Local aObjects  := {}
Local aPosObj   := {}
Local nX		:= 0
Local aSizeAut  := MsAdvSize()
Private aHEADER := {}
Private aCOLS   := {}
Private aGETS   := {}
Private aTELA   := {}

//   Montagem das Variaveis de Memoria
dbSelectArea("ZW4")
dbSetOrder(1)
lContinua := SoftLock("ZW4")
If ( lContinua )
	For nCntFor := 1 To FCount()
		M->&(FieldName(nCntFor)) := FieldGet(nCntFor)
	Next nCntFor
	
	// Montagem do aHeader
	aDadosZW5 := FWSX3Util():GetListFieldsStruct("ZW5",.F.)
	For nX := 1 To Len(aDadosZW5)
		Aadd(aHeader,{ GetSX3Cache(aDadosZW5[nX][1],"X3_TITULO"), aDadosZW5[nX][1], X3Picture(aDadosZW5[nX][1]),aDadosZW5[nX][3],aDadosZW5[nX][4],GetSX3Cache(aDadosZW5[nX][1],"X3_VALID"),GetSX3Cache(aDadosZW5[nX][1],"X3_USADO"), aDadosZW5[nX][2],"ZW5", GetSX3Cache(aDadosZW5[nX][1],"X3_CONTEXT") } )
	Next nX 
	
	//   Montagem da aCols
	dbSelectArea("ZW5")
	dbSetOrder(1)
	
	cQuery := "SELECT *,R_E_C_N_O_ ZW5RECNO "
	cQuery += "FROM "+RetSqlName("ZW5")+" ZW5 "
	cQuery += "WHERE ZW5.ZW5_FILIAL='"+xFilial("ZW5")+"' AND "
	cQuery +=       "ZW5.ZW5_NUM='"+ZW4->ZW4_NUM+"' AND "
	cQuery +=       "ZW5.D_E_L_E_T_<>'*' "
	cQuery += "ORDER BY "+SqlOrder(ZW5->(IndexKey()))
	cQuery := ChangeQuery(cQuery)
	cTrab1 := "COR02VIS"
	If Select(cTrab1) > 0
		(cTrab1)->(DbCloseArea())
	Endif
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTrab1,.T.,.T.)
	
	For nCntFor := 1 To Len(aHeader)
		TcSetField(cTrab1,AllTrim(aHeader[nCntFor][2]),aHeader[nCntFor,8],aHeader[nCntFor,4],aHeader[nCntFor,5])
	Next nCntFor
	
	Do While ( !Eof() .And. Eval(bWhile) )
		aadd(aCOLS,Array(nUsado+1))
		For nCntFor := 1 To nUsado
			If ( aHeader[nCntFor][10] != "V" )
				aCols[Len(aCols)][nCntFor] := FieldGet(FieldPos(aHeader[nCntFor][2]))
			Else
				ZW5->(dbGoto((cTrab1)->ZW5RECNO))
				aCols[Len(aCols)][nCntFor] := CriaVar(aHeader[nCntFor][2])
			EndIf
		Next nCntFor
		aCOLS[Len(aCols)][Len(aHeader)+1] := .F.
		dbSelectArea(cTrab1)
		dbSkip()
	EndDo
	dbSelectArea(cTrab1)
	dbCloseArea()
	dbSelectArea(cAlias)
EndIf
If ( lContinua )
	aObjects := {}
	AAdd( aObjects, { 315,  60, .T., .T. } )
	AAdd( aObjects, { 100, 100, .T., .T. } )
	aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects, .T. )
	
	DEFINE MSDIALOG oDlg TITLE cCadastro From aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL
	EnChoice( cAlias ,nReg, nOpcx, , , , , aPosObj[1], , 3 )
	oGetDad := MSGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpcx,"u_COR02LinOk(5)","u_COR02TudOk(5)","",.F.)
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpca:=If(oGetDad:TudoOk(),1,0),If(nOpcA==1,oDlg:End(),Nil)},{||oDlg:End()})
	If ( nOpcA == 1 )
		Begin Transaction
		If COR02Grv(3)
			EvalTrigger()
		EndIf
		End Transaction
	EndIf
EndIf
RestArea(aArea)
//cTrab1->(DbCloseArea())
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCOR02LinOK  บAutor  ณIsmael Junior     บ Data ณ  10/10/2017 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo de valida็ใo da linha OK                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function COR02LinOk(_nOpc)
Local lRetorno:= .T.
Local nCntFor := 0
Local nLimite := 0
Local nUsado  := Len(aHeader)
Local nPccust := aScan(aHeader,{|x| AllTrim(x[2])=="ZW5_CCUSTO"}) 
Local nPitemc := aScan(aHeader,{|x| AllTrim(x[2])=="ZW5_ITEMCO"})
Local nPItem  := aScan(aHeader,{|x| AllTrim(x[2])=="ZW5_ITEM"})
Local cCcusto := aCols[n,aScan(aHeader,{|x| AllTrim(x[2])=="ZW5_CCUSTO"})]
Local cItemco := aCols[n,aScan(aHeader,{|x| AllTrim(x[2])=="ZW5_ITEMCO"})]
Local cItem   := aCols[n,aScan(aHeader,{|x| AllTrim(x[2])=="ZW5_ITEM"})]
Local cSQL 	  := "TRAZW4"
For nCntFor := 1 To Len(aCols)
	If ( !aCols[nCntFor][nUsado+1] )
		If aCols[nCntFor][nPccust]+aCols[nCntFor][nPitemc] = cCcusto+cItemco .and. aCols[nCntFor][nPItem] <> cItem .and. cItem <> '01'
			MsgInfo("Este Centro de Custo jแ foi adicioando para este Gestor: (Item: "+aCols[nCntFor][nPItem]+")","Aten็ใo")
			lRetorno:= .F.
		Endif
		If cItem <> '01'
			cQuery := " SELECT ZW4_COD,ZW4_NOME AS NOME " 
			cQuery += " FROM "+RetSqlName("ZW4")+" ZW4 "
			cQuery += " INNER JOIN "+RetSqlName("ZW5")+" ZW5 ON ZW5_NUM = ZW4_NUM AND ZW5_FILIAL = '"+xFilial("ZW5")+"' AND ZW5.D_E_L_E_T_ != '*' "
			cQuery += " WHERE ZW5_CCUSTO = '"+aCols[nCntFor][nPccust]+"' "
			cQuery += " AND ZW5_ITEMCO = '"+aCols[nCntFor][nPitemc]+"' "
			cQuery += " AND ZW4_FILIAL = '"+xFilial("ZW4")+"' "
			cQuery += " AND ZW4.D_E_L_E_T_ != '*' "
			If SELECT(cSQL) > 0
				(cSQL)->(DbCloseArea())
			Endif
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cSQL,.T.,.T.)
			If !Empty((cSQL)->ZW4_COD) .and. (cSQL)->ZW4_COD <> M->ZW4_COD
		   		MsgInfo("Este Centro de Custo e Item Contabํl jแ foi adicioando para o Gestor: "+(cSQL)->NOME,"Aten็ใo")
				lRetorno:= .F.			
			Endif
		Endif
	Endif
Next 
Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCOR02Grv บAutor  ณ Ismael Junior      em 10/10/2017         บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo de grava็ใo do processo                             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ ExpN1: Opcao do Menu (Inclusao / Alteracao / Exclusao)     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function COR02Grv(nOpc)
Local aArea     := GetArea()
Local aUsrMemo  := If( ExistBlock( "COR02MEM" ), ExecBlock( "COR02MEM", .F.,.F. ), {} )
Local aMemoZW4  := {}
Local aMemoZW5  := {}
Local aRegistro := {}
Local cQuery    := ""
Local lGravou   := .F.
Local nCntFor   := 0
Local nCntFor2  := 0
Local nValDipo  := 0
Local nLoop     := 0
Local nUsado    := Len(aHeader)
Local nPconta   := aScan(aHeader,{|x| AllTrim(x[2])=="ZW5_CONTA"})
//Local nPVlTotal := aScan(aHeader,{|x| AllTrim(x[2])=="ZW5_VLTOTAL"})

If ValType( aUsrMemo ) == "A" .And. Len( aUsrMemo ) > 0
	For nLoop := 1 to Len( aUsrMemo )
		If aUsrMemo[ nLoop, 1 ] == "ZW4"
			AAdd( aMemoZW4, { aUsrMemo[ nLoop, 2 ], aUsrMemo[ nLoop, 3 ] } )
		ElseIf aUsrMemo[ nLoop, 1 ] == "ZW5"
			AAdd( aMemoZW5, { aUsrMemo[ nLoop, 2 ], aUsrMemo[ nLoop, 3 ] } )
		EndIf
	Next nLoop
EndIf

// Guarda os registros em um array para atualizacao
dbSelectArea("ZW5")
dbSetOrder(1)

cQuery := "SELECT ZW5.R_E_C_N_O_ ZW5RECNO "
cQuery += "FROM "+RetSqlName("ZW5")+" ZW5 "
cQuery += "WHERE ZW5.ZW5_FILIAL='"+xFilial("ZW5")+"' AND "
cQuery +=       "ZW5.ZW5_NUM='"+M->ZW4_NUM+"' AND "
cQuery +=       "ZW5.D_E_L_E_T_<>'*' "
cQuery += "ORDER BY "+SqlOrder(ZW5->(IndexKey()))
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"COR02VGRV",.T.,.T.)

dbSelectArea("COR02VGRV")
Do While ( !Eof() )
	aadd(aRegistro,ZW5RECNO)
	dbSelectArea("COR02VGRV")
	dbSkip()
EndDo
dbSelectArea("COR02VGRV")
dbCloseArea()
dbSelectArea("ZW5")

Do Case
	Case nOpc != 3 // Inclusใo / Altera็ใo
		For nCntFor := 1 To Len(aCols)
			If ( nCntFor > Len(aRegistro) )
				If ( !aCols[nCntFor][nUsado+1] )
					RecLock("ZW5",.T.)
				EndIf
			Else
				ZW5->(dbGoto(aRegistro[nCntFor]))
				RecLock("ZW5")
			EndIf
			If ( !aCols[nCntFor][nUsado+1] )
				lGravou := .T.
				For nCntFor2 := 1 To nUsado
					If ( aHeader[nCntFor2][10] != "V" )
						FieldPut(FieldPos(aHeader[nCntFor2][2]),aCols[nCntFor][nCntFor2])
					EndIf
				Next nCntFor2
				
				// Grava os campos obrigatorios                                   |
				ZW5->ZW5_FILIAL := xFilial("ZW5")
				ZW5->ZW5_NUM    := M->ZW4_NUM
				ZW5->ZW5_CCUSTO := M->ZW4_CCUSTO
			Else
				If ( nCntFor <= Len(aRegistro) )
					dbDelete()								
				EndIf
			EndIf
			MsUnLock()
			
		Next nCntFor
	OtherWise // Exclusao
		
		For nCntFor := 1 To Len(aRegistro)
			ZW5->(dbGoto(aRegistro[nCntFor]))
			
			RecLock("ZW5")
			dbDelete()
			MsUnLock()
/*			DbSelectArea("ZW3")
			ZW3->(DbSetOrder(2))
			If ZW3->(DbSeek(xFilial("ZW3")+M->ZW4_CCUSTO+M->ZW4_ITEMCO+aCols[nCntFor][nPconta]))
				While ZW3->(!eof()) .AND. ZW3->ZW3_CCUSTO+ZW3->ZW3_ITEMCO+ZW3->ZW3_CONTA = M->ZW4_CCUSTO+M->ZW4_ITEMCO+aCols[nCntFor][nPconta]
					RecLock("ZW3")
					dbDelete()
					MsUnLock()
					ZW3->(DbSkip())
				Enddo
			Endif                 */
		Next nCntFor
EndCase

// Atualizacao do cabecalho
dbSelectArea("ZW4")
dbSetOrder(1)
If ( MsSeek(xFilial("ZW4")+M->ZW4_NUM) )
	RecLock("ZW4")
Else
	If ( lGravou )
		RecLock("ZW4",.T.)
	EndIf
EndIf
If ( !lGravou )
	dbDelete()
	
Else
	For nCntFor := 1 To ZW4->(FCount())
		If ( FieldName(nCntFor)!="ZW4_FILIAL" )
			FieldPut(nCntFor,M->&(FieldName(nCntFor)))
		Else
			ZW4->ZW4_FILIAL := xFilial("ZW4")
		EndIf
	Next nCntFor
	
EndIf
MsUnLock()
// Restaura integridade da rotina
RestArea(aArea)
Return( .T. )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCOR02TudOk บAutor  ณ Ismael Junior em 10/10/2017            บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo TudoOK                                              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function COR02TudOk(_nOpc)
Local lRet      := .T.
Local nCntFor   := 0
Local nUsado  := Len(aHeader)
//Local dAnoAtu := Substr(Dtoc(Date()),7,4)
//Local dAnoPro := Substr(Dtoc(YearSum(Date(),1)),7,4)
If _nOpc = 3
 
Endif
Return( lRet )



