#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
#INCLUDE 'FONT.CH' //Include responsável pelas fontes coloridas utilizadas no Texto, e com diversos estilos
#INCLUDE 'COLORS.CH' //Responsável pelas cores

User Function ProtheuzeiroExec()
Private cNomeFun   := Space(30)


SetPrvt("oFont1","oFont2","oFont3","oDlg1","oSay1","oSay2","oSay3","oSay4","oSay5","oSay6","oSay7","oSay8","oSay9","oSay10")
SetPrvt("oGet1","oBtn1","oBtn2")


oFont1     := TFont():New( "Arial Rounded MT Bold",0,-19,,.F.,0,,400,.F.,.F.,,,,,, )
oFont2     := TFont():New( "Arial Narrow",0,-16,,.F.,0,,400,.F.,.F.,,,,,, )
oFont3     := TFont():New( "Arial Rounded MT Bold",0,-16,,.F.,0,,400,.F.,.F.,,,,,, )

oDlg1      := MSDialog():New( 092,232,592,927,"Protheuzeiro Exec - Executando Programas ADVPL",,,.F.,,,,,,.T.,,,.T. )

oSay1      := TSay():New( 032,008,{||"Digite o seu fonte sem o U_"},oDlg1,,oFont1,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,132,016)
oSay2      := TSay():New( 100,008,{||"Caso tenha parâmetros, informe entre parênteses"},oDlg1,,oFont2,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,164,008)
oSay3      := TSay():New( 113,009,{||"Exemplo:"},oDlg1,,oFont2,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,047,008)
oSay4      := TSay():New( 154,010,{||"Soma(2,3)"},oDlg1,,oFont2,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,047,008)
oSay5      := TSay():New( 167,011,{||'fNome("Protheuzeiro")'},oDlg1,,oFont2,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,073,008)
oSay6      := TSay():New( 001,081,{||"Bem vindo ao PROTHEUZEIRO EXEC"},oDlg1,,oFont1,.F.,.F.,.F.,.T.,CLR_BLUE,CLR_WHITE,187,016)
oSay7      := TSay():New( 014,086,{||'"Salvando o dia a dia dos Protheuzeiros"'},oDlg1,,oFont3,.F.,.F.,.F.,.T.,CLR_BLUE,CLR_WHITE,162,016)
oSay8      := TSay():New( 127,011,{||"zTSay()"},oDlg1,,oFont2,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,047,008)
oSay9      := TSay():New( 140,012,{||"Protjeto01()"},oDlg1,,oFont2,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,047,008)
oSay10     := TSay():New( 180,012,{||"TRFORNECE()"},oDlg1,,oFont2,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,047,008)


oGet1      := TGet():New( 052,008,{|u| If(PCount()>0,cNomeFun:=u,cNomeFun)},oDlg1,212,013,'',,CLR_BLACK,CLR_WHITE,oFont1,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","cNomeFun",,)

oBtn1      := TButton():New( 076,008,"Executar",oDlg1,{|| IIF(!Empty(cNomeFun),fMontaFun(),Alert("Operação não permitida"))},060,016,,oFont1,,.T.,,"",,,,.F. )
oBtn2      := TButton():New( 077,081,"Cancelar",oDlg1,{|| oDlg1:End()},060,016,,oFont1,,.T.,,"",,,,.F. )

oDlg1:Activate(,,,.T.)

Return



Static Function fMontaFun()
cNomeFun := Alltrim(cNomeFun)

IF !("(" $ cNomeFun) .OR. !(")" $ cNomeFun)
    Alert("Você precisa colocar os parênteses!","Tente novamente")
else
    cNomeFun := "U_"+Alltrim(cNomeFun)
endif

return &cNomeFun
