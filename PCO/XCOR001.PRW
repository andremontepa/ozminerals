#Include "Rwmake.ch"
#Include "Protheus.ch"
#Include "Topconn.ch"

#Define  APOS {  15,  1, 70, 315 }

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณXCOR001   บAutor  ณ Ismael Junior      บ Data ณ  03/06/19   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Cadastro para controle or็amentario                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Estoque e custos                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function XCOR001()
//Private aCores := {}
Private cCadastro := "Cadastro controle or็amentario"

Private aRotina   := { { "Pesquisa"   ,"AxPesqui"   ,0,1},; //"Pesquisar"
{ "Visualizar" ,"u_COR01Vis",0,2},; //"Visual"
{ "Incluir"    ,"u_COR01Inc",0,3},; //"Incluir"
{ "Alterar"    ,"u_COR01Alt",0,4},; //"Alterar" 2CR01HIS()
{ "Excluir"    ,"u_COR01Exc",0,5} } //"Exclusao"
Private aCmp     := {{"Filial"   ,"ZW1_FILIAL"     ,"", 00,00,"@!"},;
{"Centro de Custo"    ,"ZW1_CCUSTO"     ,"", 00,00,"@!"},;
{"Descri็ใo C. Custo" ,"ZW1_DCCUST" ,"", 00,00,"@!"},; 
{"Item Contabil"      ,"ZW1_ITEMCO" ,"", 00,00,"@!"},;
{"Descri็ใo Item Con" ,"ZW1_DITEMC" ,"", 00,00,"@!"},;
{"Ano"                ,"ZW1_ANO"    ,"", 00,00,"@!"}}

//AADD(aCores,{"ZW2_BLOQ == 'N'" ,"BR_VERDE" })
//AADD(aCores,{"ZW2_BLOQ == 'S'" ,"BR_VERMELHO" })

dbSelectArea("ZW1")
dbSetOrder(1)
MBrowse(6,1,22,75,"ZW1",aCmp,,,,,fCriaCor())
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ COR01Vis  บAutor  ณ Ismael Junior em 04/06/2019            บฑฑ
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
User Function COR01Vis(cAlias,nReg,nOpcx)
Local aArea     := GetArea()
Local oGetDad
Local oDlg
Local nUsado    := 0
Local nCntFor   := 0
Local nOpcA     := 0
Local lContinua := .T.
Local lQuery    := .F.
Local cCadastro := "Controle Or็amentario - Visualiza็ใo"
Local cQuery    := ""
Local cTrab1     := "ZW2"
Local bWhile    := {|| .T. }
Local aObjects  := {}
Local aPosObj   := {}
Local aSizeAut  := MsAdvSize()
Private aHEADER := {}
Private aCOLS   := {}
Private aGETS   := {}
Private aTELA   := {}

dbSelectArea("ZW1")
dbSetOrder(1)
For nCntFor := 1 To FCount()
	M->&(FieldName(nCntFor)) := FieldGet(nCntFor)
Next nCntFor

// Montagem do aHeader
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("ZW2")
Do While ( !Eof() .And. SX3->X3_ARQUIVO == "ZW2" )
	If ( X3USO(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL )
		nUsado++
		Aadd(aHeader,{ TRIM(X3Titulo()), TRIM(SX3->X3_CAMPO), SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_VALID, SX3->X3_USADO, SX3->X3_TIPO,;
		SX3->X3_ARQUIVO, SX3->X3_CONTEXT } )
	EndIf
	dbSelectArea("SX3")
	dbSkip()
EndDo

// Montagem do aCols                                            |
dbSelectArea("ZW2")
dbSetOrder(1)

cQuery := "SELECT *,R_E_C_N_O_ ZW2RECNO "
cQuery += "FROM "+RetSqlName("ZW2")+" ZW2 "
cQuery += "WHERE ZW2.ZW2_FILIAL='"+xFilial("ZW2")+"' AND "
cQuery +=       "ZW2.ZW2_NUM='"+ZW1->ZW1_NUM+"' AND "
cQuery +=       "ZW2.D_E_L_E_T_<>'*' "
cQuery += "ORDER BY "+SqlOrder(ZW2->(IndexKey()))
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
			ZW2->(dbGoto((cTrab1)->ZW2RECNO))
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
AAdd( aObjects, { 315,  30, .T., .T. } )
AAdd( aObjects, { 100, 100, .T., .T. } )
aInfo   := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects, .T. )

DEFINE MSDIALOG oDlg TITLE cCadastro From aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL
EnChoice( cAlias ,nReg, nOpcx, , , , , aPosObj[1], , 3 )
oGetDad := MSGetDados():New (aPosObj[2,1], aPosObj[2,2], aPosObj[2,3], aPosObj[2,4], nOpcx, "u_COR01LinOk" ,"AllwaysTrue","",.F.)
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||oDlg:End()},{||oDlg:End()})
RestArea(aArea)
//cTrab1->(DbCloseArea())
Return(.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCOR01Inc    บAutor  ณ Ismael Junior em 04/06/2019           บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo de tratamento da inclusใo do registro               บฑฑ
ฑฑบ          ณ COR01Inc(ExpC1,ExpN2,ExpN3)                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ ExpC1: Alias do arquivo                                    บฑฑ
ฑฑบ          ณ ExpN2: Registro do Arquivo                                 บฑฑ
ฑฑบ          ณ ExpN3: Opcao da MBrowse                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function COR01Inc(cAlias,nReg,nOpcx)
Local aArea     := GetArea()
Local cCadastro := OemToAnsi("Controle or็amentario - Inclusใo")
Local oGetDad
Local nUsado    := 0
Local nCntFor   := 0
Local nOpcA     := 0
Local aObjects  := {}
Local aPosObj   := {}
Local aSizeAut  := MsAdvSize()
Private aHEADER := {}
Private aCOLS   := {}
Private aGETS   := {}
Private aTELA   := {}
Private oDlg

// Montagem das Variaveis de Memoria
dbSelectArea("ZW1")
dbSetOrder(1)
For nCntFor := 1 To FCount()
	M->&(FieldName(nCntFor)) := CriaVar(FieldName(nCntFor))
Next nCntFor

// Montagem da aHeader
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("ZW2")
Do While ( !Eof() .And. SX3->X3_ARQUIVO == "ZW2" )
	If ( X3USO(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL )
		nUsado++
		Aadd(aHeader,{ TRIM(X3Titulo()),TRIM(SX3->X3_CAMPO),SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,;
		SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
	EndIf
	dbSelectArea("SX3")
	dbSkip()
EndDo

// Montagem da Acols
aadd(aCOLS,Array(nUsado+1))
For nCntFor := 1 To nUsado
	aCols[1][nCntFor] := CriaVar(aHeader[nCntFor][2])
Next nCntFor

aCOLS[1][1] := Strzero(Val(aCOLS[1][1])+1,4)
aCOLS[1][Len(aHeader)+1] := .F.
aObjects := {}
AAdd( aObjects, { 315,  30, .T., .T. } )
AAdd( aObjects, { 100, 100, .T., .T. } )
aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects, .T. )

DEFINE MSDIALOG oDlg TITLE cCadastro From aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL
EnChoice( cAlias ,nReg, nOpcx, , , , , aPosObj[1], , 3 )
oGetDad := MSGetDados():New(aPosObj[2,1], aPosObj[2,2], aPosObj[2,3], aPosObj[2,4], nOpcx, "u_COR01LinOk(3)", "u_COR01TudOk(3)","+ZW2_ITEM",.T.)
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, {||nOpcA:=If(oGetDad:TudoOk() .And. Obrigatorio(aGets,aTela), 1,0),If(nOpcA==1,oDlg:End(),Nil)},{||oDlg:End()})

If ( nOpcA == 1 )
	Begin Transaction
	COR01Grv(1)
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
ฑฑบPrograma  ณCOR01Alt   บAutor  ณ Ismael Junior  em 04/06/2019           บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo de tratamento da altera็ใo                          บฑฑ
ฑฑบ          ณ COR01Alt(ExpC1,ExpN2,ExpN3)                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ ExpC1: Alias do arquivo                                    บฑฑ
ฑฑบ          ณ ExpN2: Registro do Arquivo                                 บฑฑ
ฑฑบ          ณ ExpN3: Opcao da MBrowse                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function COR01Alt(cAlias,nReg,nOpcx)
Local aArea     := GetArea()
Local cCadastro := OemToAnsi("Controle Or็amentario - Altera็ใo")
Local oGetDad
Local oDlg
Local nUsado    := 0
Local nCntFor   := 0
Local nOpcA     := 0
Local lContinua := .T.
Local cQuery    := ""
Local cTrab1     := "ZW2"
Local bWhile    := {|| .T. }
Local aObjects  := {}
Local aPosObj   := {}
Local aSizeAut  := MsAdvSize()
Private aHEADER := {}
Private aCOLS   := {}
Private aGETS   := {}
Private aTELA   := {}

// Montagem das Variaveis de Memoria
dbSelectArea("ZW1")
dbSetOrder(1)
lContinua := SoftLock("ZW1")
If ( lContinua )
For nCntFor := 1 To FCount()
M->&(FieldName(nCntFor)) := FieldGet(nCntFor)
Next nCntFor

// Montagem da aHeader
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("ZW2")
Do While ( !Eof() .And. SX3->X3_ARQUIVO == "ZW2" )
If ( X3USO(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL )
nUsado++
Aadd(aHeader,{ TRIM(X3Titulo()),TRIM(SX3->X3_CAMPO),SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,;
SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
EndIf
dbSelectArea("SX3")
dbSkip()
EndDo

// Montagem da aCols
dbSelectArea("ZW2")
dbSetOrder(1)

cQuery := "SELECT *,R_E_C_N_O_ ZW2RECNO "
cQuery += "FROM "+RetSqlName("ZW2")+" ZW2 "
cQuery += "WHERE ZW2.ZW2_FILIAL='"+xFilial("ZW2")+"' AND "
cQuery +=       "ZW2.ZW2_NUM='"+ZW1->ZW1_NUM+"' AND "
cQuery +=       "ZW2.D_E_L_E_T_<>'*' "
cQuery += "ORDER BY "+SqlOrder(ZW2->(IndexKey()))
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
ZW2->(dbGoto((cTrab1)->ZW2RECNO))
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
AAdd( aObjects, { 315,  30, .T., .T. } )
AAdd( aObjects, { 100, 100, .T., .T. } )
aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects, .T. )

DEFINE MSDIALOG oDlg TITLE cCadastro From aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL
EnChoice( cAlias ,nReg, nOpcx, , , , , aPosObj[1], , 3 )
oGetDad := MSGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpcx,"u_COR01LinOk(4)","u_COR01TudOk(4)","+ZW2_ITEM",.T.)
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpca:=If(oGetDad:TudoOk().And.Obrigatorio(aGets,aTela),1,0),If(nOpcA==1,oDlg:End(),Nil)},{||oDlg:End()})
If ( nOpcA == 1 )

// Abre a tabela de contratos
Begin Transaction

dbSelectArea(cTrab1)
dbSelectArea(cAlias)

COR01Grv(2)
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
ฑฑบPrograma  ณCOR01Exc    บAutor  ณ Ismael Junior em 04/06/2019           บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo que trata a exclusใo                                บฑฑ
ฑฑบ          ณ COR01Exc(ExpC1,ExpN2,ExpN3)                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ ExpC1: Alias do arquivo                                    บฑฑ
ฑฑบ          ณ ExpN2: Registro do Arquivo                                 บฑฑ
ฑฑบ          ณ ExpN3: Opcao da MBrowse                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function COR01Exc(cAlias,nReg,nOpcx)
Local aArea     := GetArea()
Local cCadastro := OemToAnsi("Controle Or็amentario - Exclusใo")
Local oGetDad
Local oDlg
Local nUsado    := 0
Local nCntFor   := 0
Local nOpcA     := 0
Local lContinua := .T.
Local cQuery    := ""
Local cTrab1     := "ZW2"
Local bWhile    := {|| .T. }
Local aObjects  := {}
Local aPosObj   := {}
Local aSizeAut  := MsAdvSize()
Private aHEADER := {}
Private aCOLS   := {}
Private aGETS   := {}
Private aTELA   := {}

//   Montagem das Variaveis de Memoria
dbSelectArea("ZW1")
dbSetOrder(1)
lContinua := SoftLock("ZW1")
If ( lContinua )
	For nCntFor := 1 To FCount()
		M->&(FieldName(nCntFor)) := FieldGet(nCntFor)
	Next nCntFor
	
	//   Montagem da aHeader
	dbSelectArea("SX3")
	dbSetOrder(1)
	dbSeek("ZW2")
	Do While ( !Eof() .And. SX3->X3_ARQUIVO == "ZW2" )
		If ( X3USO(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL )
			nUsado++
			Aadd(aHeader,{ TRIM(X3Titulo()),TRIM(SX3->X3_CAMPO),SX3->X3_PICTURE, SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,;
			SX3->X3_ARQUIVO,SX3->X3_CONTEXT } )
		EndIf
		dbSelectArea("SX3")
		dbSkip()
	EndDo
	
	//   Montagem da aCols
	dbSelectArea("ZW2")
	dbSetOrder(1)
	
	cQuery := "SELECT *,R_E_C_N_O_ ZW2RECNO "
	cQuery += "FROM "+RetSqlName("ZW2")+" ZW2 "
	cQuery += "WHERE ZW2.ZW2_FILIAL='"+xFilial("ZW2")+"' AND "
	cQuery +=       "ZW2.ZW2_NUM='"+ZW1->ZW1_NUM+"' AND "
	cQuery +=       "ZW2.D_E_L_E_T_<>'*' "
	cQuery += "ORDER BY "+SqlOrder(ZW2->(IndexKey()))
	cQuery := ChangeQuery(cQuery)
	cTrab1 := "COR01VIS"
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
				ZW2->(dbGoto((cTrab1)->ZW2RECNO))
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
	AAdd( aObjects, { 315,  30, .T., .T. } )
	AAdd( aObjects, { 100, 100, .T., .T. } )
	aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects, .T. )
	
	DEFINE MSDIALOG oDlg TITLE cCadastro From aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL
	EnChoice( cAlias ,nReg, nOpcx, , , , , aPosObj[1], , 3 )
	oGetDad := MSGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpcx,"u_COR01LinOk(5)","u_COR01TudOk(5)","",.F.)
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpca:=If(oGetDad:TudoOk(),1,0),If(nOpcA==1,oDlg:End(),Nil)},{||oDlg:End()})
	If ( nOpcA == 1 )
		Begin Transaction
		If COR01Grv(3)
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
ฑฑบPrograma  ณCOR01LinOK  บAutor  ณIsmael Junior     บ Data ณ  04/06/2019 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo de valida็ใo da linha OK                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function COR01LinOk(_nOpc)
Local lRetorno:= .T.
Local nCntFor := 0
Local nLimite := 0
Local nUsado  := Len(aHeader)
Local nPconta   := aScan(aHeader,{|x| AllTrim(x[2])=="ZW2_CONTA"})
Local nPItem    := aScan(aHeader,{|x| AllTrim(x[2])=="ZW2_ITEM"})
Local nPccust   := aScan(aHeader,{|x| AllTrim(x[2])=="ZW2_CCUSTO"})
Local nPitemc   := aScan(aHeader,{|x| AllTrim(x[2])=="ZW2_ITEMCO"})
Local cCcusto := cItemco := ""
Local cConta := aCols[n,aScan(aHeader,{|x| AllTrim(x[2])=="ZW2_CONTA"})]
Local cItem  := aCols[n,aScan(aHeader,{|x| AllTrim(x[2])=="ZW2_ITEM"})]    
For nCntFor := 1 To Len(aCols)         //ISMAEL JUNIOR 12/05/2018
	If ( !aCols[nCntFor][nUsado+1] )
	    If aCols[n][nUsado+1]
	    cConta := ''  
	    Endif
		If aCols[nCntFor][nPconta] = cConta .and. aCols[nCntFor][nPItem] <> cItem
			MsgInfo("Esta Conta jแ foi adicioanda a este Centro de Custo e Item contแbil: (Item: "+aCols[nCntFor][nPItem]+")","Aten็ใo")
			lRetorno:= .F.
		Endif
	Endif
Next 
Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCOR01Grv บAutor  ณ Ismael Junior      em 04/06/2019         บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo de grava็ใo do processo                             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ ExpN1: Opcao do Menu (Inclusao / Alteracao / Exclusao)     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function COR01Grv(nOpc)
Local aArea     := GetArea()
Local aUsrMemo  := If( ExistBlock( "COR01MEM" ), ExecBlock( "COR01MEM", .F.,.F. ), {} )
Local aMemoZW1  := {}
Local aMemoZW2  := {}
Local aRegistro := {}
Local cQuery    := ""
Local lGravou   := .F.
Local nCntFor   := 0
Local nCntFor2  := 0
Local nValDipo  := 0
Local nLoop     := 0
Local nUsado    := Len(aHeader)
Local nPconta   := aScan(aHeader,{|x| AllTrim(x[2])=="ZW2_CONTA"})
//Local nPVlTotal := aScan(aHeader,{|x| AllTrim(x[2])=="ZW2_VLTOTAL"})

If ValType( aUsrMemo ) == "A" .And. Len( aUsrMemo ) > 0
	For nLoop := 1 to Len( aUsrMemo )
		If aUsrMemo[ nLoop, 1 ] == "ZW1"
			AAdd( aMemoZW1, { aUsrMemo[ nLoop, 2 ], aUsrMemo[ nLoop, 3 ] } )
		ElseIf aUsrMemo[ nLoop, 1 ] == "ZW2"
			AAdd( aMemoZW2, { aUsrMemo[ nLoop, 2 ], aUsrMemo[ nLoop, 3 ] } )
		EndIf
	Next nLoop
EndIf

// Guarda os registros em um array para atualizacao
dbSelectArea("ZW2")
dbSetOrder(1)

cQuery := "SELECT ZW2.R_E_C_N_O_ ZW2RECNO "
cQuery += "FROM "+RetSqlName("ZW2")+" ZW2 "
cQuery += "WHERE ZW2.ZW2_FILIAL='"+xFilial("ZW2")+"' AND "
cQuery +=       "ZW2.ZW2_NUM='"+M->ZW1_NUM+"' AND "
cQuery +=       "ZW2.D_E_L_E_T_<>'*' "
cQuery += "ORDER BY "+SqlOrder(ZW2->(IndexKey()))
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"COR01VGRV",.T.,.T.)

dbSelectArea("COR01VGRV")
Do While ( !Eof() )
	aadd(aRegistro,ZW2RECNO)
	dbSelectArea("COR01VGRV")
	dbSkip()
EndDo
dbSelectArea("COR01VGRV")
dbCloseArea()
dbSelectArea("ZW2")

Do Case
	Case nOpc != 3 // Inclusใo / Altera็ใo
		For nCntFor := 1 To Len(aCols)
			If ( nCntFor > Len(aRegistro) )
				If ( !aCols[nCntFor][nUsado+1] )
					RecLock("ZW2",.T.)
				EndIf
			Else
				ZW2->(dbGoto(aRegistro[nCntFor]))
				RecLock("ZW2")        				
			EndIf
			If ( !aCols[nCntFor][nUsado+1] )
				lGravou := .T.
				For nCntFor2 := 1 To nUsado
					If ( aHeader[nCntFor2][10] != "V" )
						FieldPut(FieldPos(aHeader[nCntFor2][2]),aCols[nCntFor][nCntFor2])
					EndIf
				Next nCntFor2
				
				// Grava os campos obrigatorios                                   |
				ZW2->ZW2_FILIAL := xFilial("ZW2")
				ZW2->ZW2_NUM    := M->ZW1_NUM
				ZW2->ZW2_CCUSTO := M->ZW1_CCUSTO
				ZW2->ZW2_ITEMCO := M->ZW1_ITEMCO
				ZW2->ZW2_ANO    := M->ZW1_ANO
				ZW2->ZW2_CLVL   := M->ZW1_CLVL
				ZW2->ZW2_BLOQ   := M->ZW1_BLOQ
			Else
				If ( nCntFor <= Len(aRegistro) )
					dbDelete()
			        DbSelectArea("ZW3")
			        ZW3->(DbSetOrder(2))
			        If ZW3->(DbSeek(xFilial("ZW3")+M->ZW1_CCUSTO+M->ZW1_ITEMCO+M->ZW1_CLVL+aCols[nCntFor][nPconta]+M->ZW1_ANO))
				    While ZW3->(!eof()) .AND. ZW3->ZW3_CCUSTO+ZW3->ZW3_ITEMCO+ZW3->ZW3_CONTA+ZW3->ZW3_ANO = M->ZW1_CCUSTO+M->ZW1_ITEMCO+aCols[nCntFor][nPconta]+M->ZW1_ANO
					RecLock("ZW3")
					ZW3->(dbDelete())
					ZW3->(MsUnLock())
					ZW3->(DbSkip())
				Enddo
			Endif					
				EndIf
			EndIf
			MsUnLock()
			
		Next nCntFor
		// Grava historico opera็ใo
		U_COR01HIS(lGravou)
	OtherWise // Exclusao
		
		For nCntFor := 1 To Len(aRegistro)
			ZW2->(dbGoto(aRegistro[nCntFor]))
			
			RecLock("ZW2")
			dbDelete()
			MsUnLock()
			DbSelectArea("ZW3")
			ZW3->(DbSetOrder(2))
			If ZW3->(DbSeek(xFilial("ZW3")+M->ZW1_CCUSTO+M->ZW1_ITEMCO+M->ZW1_CLVL+aCols[nCntFor][nPconta]))
				While ZW3->(!eof()) .AND. ZW3->ZW3_CCUSTO+ZW3->ZW3_ITEMCO+ZW3->ZW3_CONTA = M->ZW1_CCUSTO+M->ZW1_ITEMCO+aCols[nCntFor][nPconta]
					RecLock("ZW3")
					dbDelete()
					MsUnLock()
					ZW3->(DbSkip())
				Enddo
			Endif
		Next nCntFor
EndCase



// Atualizacao do cabecalho
dbSelectArea("ZW1")
dbSetOrder(1)

//- Toni Aguiar - TOTVS STARSOFT em 26/08/2020
//- Mudan็a na forma de inclusใo dos registros devido a perda de sequ๊ncia da fun็ใo GETXNUM()
//-
If nOpc==1
   If ( MsSeek(xFilial("ZW1")+M->ZW1_NUM) )
      Alert("Impossํvel inlcuir este registro, pois o mesmo jแ foi incluํdo anteriormente!")
      // Restaura integridade da rotina
      RestArea(aArea)
      Return( .T. )
   Else
   	  If ( lGravou )
	 	 RecLock("ZW1",.T.)
	  EndIf
   Endif
Else 
   If ( MsSeek(xFilial("ZW1")+M->ZW1_NUM) )
      RecLock("ZW1",.F.)
   Endif
Endif

/*
//- Documentado por Toni Aguiar - TOTVS STARSOFT em 26/08/2020
//- Forma antiga de inclusใo de registros que causa a exlusใo ou atualiza็ใo dos registros 
//- de forma indevida, devido a perda da sequencia controlada pela fun็ใo GETXNUM.
//-
If ( MsSeek(xFilial("ZW1")+M->ZW1_NUM) )
	RecLock("ZW1")
Else
	If ( lGravou )
		RecLock("ZW1",.T.)
	EndIf
EndIf
*/

If ( !lGravou )
	dbDelete()
	
Else
	For nCntFor := 1 To ZW1->(FCount())
		If ( FieldName(nCntFor)!="ZW1_FILIAL" )
			FieldPut(nCntFor,M->&(FieldName(nCntFor)))
		Else
			ZW1->ZW1_FILIAL := xFilial("ZW1")
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
ฑฑบPrograma  ณCOR01TudOk บAutor  ณ Ismael Junior em 04/06/2019            บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo TudoOK                                              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function COR01TudOk(_nOpc)
Local lRet      := .T.
Local nCntFor   := 0
Local nUsado  := Len(aHeader)
Local dAnoAtu := Substr(Dtoc(Date()),7,4)
Local dAnoPro := Substr(Dtoc(YearSum(Date(),1)),7,4)
Local cText := ""
Local cText2 := ""
Local lbloq  := .F.
Local cSQL 	  := "TRAZW1"
If _nOpc = 3
	If M->ZW1_ANO = dAnoAtu 
	lbloq := .T.
	ElseIf M->ZW1_ANO = dAnoPro
	lbloq := .T.
	Endif
	 If !lBloq
		IF MsgYesNo("Ano do Exercํcio informado ้ diferente do ano atual "+dAnoAtu+" ou do proxํmo ano "+dAnoPro  +chr(13)+chr(10)+"Desejแ continuar?","Aten็ใo")
			lRet := .T.
		Else
			lRet := .F.
		Endif
	 Endif
			cQuery := " SELECT ZW1_CCUSTO AS CCUSTO FROM "+RetSqlName("ZW1")+" ZW1
			cQuery += " WHERE ZW1_CCUSTO = '"+M->ZW1_CCUSTO+"' "
			cQuery += " AND ZW1_ITEMCO = '"+M->ZW1_ITEMCO+"' "
			cQuery += " AND ZW1_CLVL = '"+M->ZW1_CLVL+"' "
			cQuery += " AND ZW1_ANO = '"+M->ZW1_ANO+"' "
			cQuery += " AND ZW1_FILIAL = '"+xFilial("ZW1")+"' "
			cQuery += " AND ZW1.D_E_L_E_T_ != '*'
			
			If SELECT(cSQL) > 0
				(cSQL)->(DbCloseArea())
			Endif
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cSQL,.T.,.T.)
			If !Empty((cSQL)->CCUSTO) 
		   		MsgInfo("Este Centro de Custo e Item Contabํl jแ foi adicioando! Para inclusใo de novas contas contabeis Edite o existente  ","Aten็ใo")
				lRet:= .F.			
			Endif	 
Endif
Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCorComp  บAutor  ณIsmael Junior     บ Data ณ  04/06/2019 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo para preencher demais campos com valor de janeiro   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function CorComp()
Local nCntFor := 0
Local nUsado  := Len(aHeader)
Local nPitem  := aScan(aHeader,{|x| AllTrim(x[2])=="ZW2_ITEM"})
Local nPval1  := aScan(aHeader,{|x| AllTrim(x[2])=="ZW2_PRE01"})
Local nPval2  := aScan(aHeader,{|x| AllTrim(x[2])=="ZW2_PRE02"})
Local nPval3  := aScan(aHeader,{|x| AllTrim(x[2])=="ZW2_PRE03"})
Local nPval4  := aScan(aHeader,{|x| AllTrim(x[2])=="ZW2_PRE04"})
Local nPval5  := aScan(aHeader,{|x| AllTrim(x[2])=="ZW2_PRE05"})
Local nPval6  := aScan(aHeader,{|x| AllTrim(x[2])=="ZW2_PRE06"})
Local nPval7  := aScan(aHeader,{|x| AllTrim(x[2])=="ZW2_PRE07"})
Local nPval8  := aScan(aHeader,{|x| AllTrim(x[2])=="ZW2_PRE08"})
Local nPval9  := aScan(aHeader,{|x| AllTrim(x[2])=="ZW2_PRE09"})
Local nPval10  := aScan(aHeader,{|x| AllTrim(x[2])=="ZW2_PRE10"})
Local nPval11  := aScan(aHeader,{|x| AllTrim(x[2])=="ZW2_PRE11"})
Local nPval12  := aScan(aHeader,{|x| AllTrim(x[2])=="ZW2_PRE12"})
Local nPvlano := aScan(aHeader,{|x| AllTrim(x[2])=="ZW2_PREANO"})
Local nVal2 := 0
Local cItem  := aCols[n,aScan(aHeader,{|x| AllTrim(x[2])=="ZW2_ITEM"})]
For nCntFor := 1 To Len(aCols)
	If ( !aCols[nCntFor][nUsado+1] )
		If aCols[nCntFor][nPitem] == cItem
			If MsgYesNo("Deseja Repertir este valor nos demais meses?","Repetir Valores")
				nVal2 := aCols[nCntFor][nPval1]
				aCols[nCntFor][nPval2] := aCols[nCntFor][nPval1]
				aCols[nCntFor][nPval3] := aCols[nCntFor][nPval1]
				aCols[nCntFor][nPval4] := aCols[nCntFor][nPval1]
				aCols[nCntFor][nPval5] := aCols[nCntFor][nPval1]
				aCols[nCntFor][nPval6] := aCols[nCntFor][nPval1]
				aCols[nCntFor][nPval7] := aCols[nCntFor][nPval1]
				aCols[nCntFor][nPval8] := aCols[nCntFor][nPval1]
				aCols[nCntFor][nPval9] := aCols[nCntFor][nPval1]
				aCols[nCntFor][nPval10] := aCols[nCntFor][nPval1]
				aCols[nCntFor][nPval11] := aCols[nCntFor][nPval1]
				aCols[nCntFor][nPval12] := aCols[nCntFor][nPval1]
				aCols[nCntFor][nPvlano] := aCols[nCntFor][nPval1]+aCols[nCntFor][nPval2]+aCols[nCntFor][nPval3]+aCols[nCntFor][nPval4]+aCols[nCntFor][nPval5]+;
				aCols[nCntFor][nPval6]+aCols[nCntFor][nPval7]+aCols[nCntFor][nPval8]+aCols[nCntFor][nPval9]+aCols[nCntFor][nPval10]+aCols[nCntFor][nPval11]+aCols[nCntFor][nPval12]
			Else
				nVal2 := 0
			Endif
		Endif
	Endif
Next
Return(nVal2)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPtotal     บAutor  ณ Ismael Junior em 04/06/2019            บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo Ptotal                                              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function Ptotal()
Local nCntFor   := 0
Local nUsado  := Len(aHeader) 
Local nPitem  := aScan(aHeader,{|x| AllTrim(x[2])=="ZW2_ITEM"})
Local nPval1  := aScan(aHeader,{|x| AllTrim(x[2])=="ZW2_PRE01"})
Local nPval2  := aScan(aHeader,{|x| AllTrim(x[2])=="ZW2_PRE02"})
Local nPval3  := aScan(aHeader,{|x| AllTrim(x[2])=="ZW2_PRE03"})
Local nPval4  := aScan(aHeader,{|x| AllTrim(x[2])=="ZW2_PRE04"})
Local nPval5  := aScan(aHeader,{|x| AllTrim(x[2])=="ZW2_PRE05"})
Local nPval6  := aScan(aHeader,{|x| AllTrim(x[2])=="ZW2_PRE06"})
Local nPval7  := aScan(aHeader,{|x| AllTrim(x[2])=="ZW2_PRE07"})
Local nPval8  := aScan(aHeader,{|x| AllTrim(x[2])=="ZW2_PRE08"})
Local nPval9  := aScan(aHeader,{|x| AllTrim(x[2])=="ZW2_PRE09"})
Local nPval10  := aScan(aHeader,{|x| AllTrim(x[2])=="ZW2_PRE10"})
Local nPval11  := aScan(aHeader,{|x| AllTrim(x[2])=="ZW2_PRE11"})
Local nPval12  := aScan(aHeader,{|x| AllTrim(x[2])=="ZW2_PRE12"})
Local nPvlano := aScan(aHeader,{|x| AllTrim(x[2])=="ZW2_PREANO"})
Local nVal := nVlTot := 0
Local nValtotal := 0 
Local cItem  := aCols[n,aScan(aHeader,{|x| AllTrim(x[2])=="ZW2_ITEM"})]
For nCntFor := 1 To Len(aCols)
	If ( !aCols[nCntFor][nUsado+1] ) .AND. aCols[nCntFor][nPitem] == cItem
		
		nVal := aCols[nCntFor][nPval1]+aCols[nCntFor][nPval2]+aCols[nCntFor][nPval3]+aCols[nCntFor][nPval4]+aCols[nCntFor][nPval5]+;
		aCols[nCntFor][nPval6]+aCols[nCntFor][nPval7]+aCols[nCntFor][nPval8]+aCols[nCntFor][nPval9]+aCols[nCntFor][nPval10]+aCols[nCntFor][nPval11]+aCols[nCntFor][nPval12]
	Endif 
	If ( !aCols[nCntFor][nUsado+1] )	
		nVlTot := aCols[nCntFor][nPval1]+aCols[nCntFor][nPval2]+aCols[nCntFor][nPval3]+aCols[nCntFor][nPval4]+aCols[nCntFor][nPval5]+;
		aCols[nCntFor][nPval6]+aCols[nCntFor][nPval7]+aCols[nCntFor][nPval8]+aCols[nCntFor][nPval9]+aCols[nCntFor][nPval10]+aCols[nCntFor][nPval11]+aCols[nCntFor][nPval12]
		nValtotal := nValtotal + nVlTot
	Endif	
Next
M->ZW1_TOTAL := nValtotal
GETDREFRESH()
Return(nVal)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCOR01HIS    บAutor  ณIsmael Junior     บ Data ณ  04/06/2019 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo para preencher demais campos com valor de janeiro   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function COR01HIS(lGravou)
Local nCntFor := 0
Local lRet    := .T.
Local nUsado  := Len(aHeader)
Local nPreano := aScan(aHeader,{|x| AllTrim(x[2])=="ZW2_PREANO"})
Local nPconta  := aScan(aHeader,{|x| AllTrim(x[2])=="ZW2_CONTA"})
Local cCodUser := RetCodUsr() //Retorna o Codigo do Usuario
Local cNamUser := UsrRetName( cCodUser )//Retorna o nome do usuario
Local cOrigem  := "Cadastro Or็amentario"

For nCntFor := 1 To Len(aCols)
DbSelectArea("ZW3")
ZW3->(DbSetOrder(2))
If ZW3->(DbSeek(xFilial("ZW3")+M->ZW1_CCUSTO+M->ZW1_ITEMCO+M->ZW1_CLVL+aCols[nCntFor][nPconta]+M->ZW1_ANO))
	lRec := .F.
Else
	lRec := .T.
	   	If ( !aCols[nCntFor][nUsado+1] )
		 	If aCols[nCntFor][nPreano] > 0
				//dDate := Ctod("01/01/"+M->ZW1_ANO)
				dDate := DDATABASE
				RecLock("ZW3",lRec)
				ZW3->ZW3_FILIAL := XFILIAL("ZW3")
				ZW3->ZW3_NUM    := GETSX8NUM("ZW3","ZW3_NUM")
				ZW3->ZW3_TIPO   := "C"
				ZW3->ZW3_CCUSTO := M->ZW1_CCUSTO
				ZW3->ZW3_ITEMCO := M->ZW1_ITEMCO
				ZW3->ZW3_ANO    := M->ZW1_ANO
				ZW3->ZW3_CONTA  := aCols[nCntFor][nPconta]
				ZW3->ZW3_CLVL   := M->ZW1_CLVL
				ZW3->ZW3_DATA   := dDate
				ZW3->ZW3_VALOR  := aCols[nCntFor][nPreano] 
				ZW3->ZW3_ORIGEM := cOrigem
				ZW3->ZW3_USUARI := cNamUser
				ZW3->ZW3_HISTOR := "Valor do Or็amento para o ano de "+M->ZW1_ANO
				ZW3->(MsUnLock())
				ConfirmSX8()
		   	Endif
	   	Endif 
Endif
Next
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCorComp  บAutor  ณIsmael Junior     บ Data ณ  04/06/2019 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo para preencher demais campos com valor de janeiro   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function zw1exist(cCusto,cItemco,cAno,cClvl)
Local cSQL := "TRAZW1"
Local lRet := .T.
			cQuery := " SELECT ZW1_CCUSTO AS CCUSTO FROM "+RetSqlName("ZW1")+" ZW1
			cQuery += " WHERE ZW1_CCUSTO = '"+cCusto+"' "
			cQuery += " AND ZW1_ITEMCO = '"+cItemco+"' "
			cQuery += " AND ZW1_CLVL = '"+cClvl+"' "
			cQuery += " AND ZW1_ANO = '"+cAno+"' "
			cQuery += " AND ZW1_FILIAL = '"+xFilial("ZW1")+"' "
			cQuery += " AND ZW1.D_E_L_E_T_ != '*'
			
			If SELECT(cSQL) > 0
				(cSQL)->(DbCloseArea())
			Endif
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cSQL,.T.,.T.)
			If !Empty((cSQL)->CCUSTO) 
		   		MsgInfo("Este Centro de Custo e Item Contabํl jแ foi adicioando! Para inclusใo de novas contas contabeis Edite o existente  ","Aten็ใo")
				lRet:= .F.			
			Endif
Return(lRet)   
