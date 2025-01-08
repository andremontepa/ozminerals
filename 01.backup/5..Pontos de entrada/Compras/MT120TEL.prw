#Include "Rwmake.ch"
#Include "Protheus.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ MT120TEL     ºAutor  ³ Toni Aguiar       º Data ³  10/18/16º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ P.E. para incElusão de folders no pedido de compras         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/              

User Function MT120TEL
If !IsInCallStack("CNTA120")
   AADD(aTitles, 'Observações')
Endif
Return Nil
                                       
User Function MT120FOL
Local  nOpc    := Paramixb[1]
Local  aPosGet := Paramixb[2]
Local  oMemo   := ""
Local  oMemo2  := ""
Local  _aArea  := GetArea()   
Static aMisc            

If !IsInCallStack("CNTA120")
   aMisc:={}
   AADD(aMisc, If(nOpc==4 .Or. nOpc==2, SC7->C7_SOLICIT, SPACE(20)))
   AADD(aMisc, If(nOpc==4 .Or. nOpc==2, SC7->C7_XAPLIC  , SPACE(30)))
   AADD(aMisc, If(nOpc==4 .Or. nOpc==2, SC7->C7_XOBS   , "")) 
   AADD(aMisc, If(nOpc==4 .Or. nOpc==2, SC7->C7_XOBSF  , "")) 

   If nOpc <> 1
      @ 006, aPosGet[1,1] Say OemToAnsi('Solicitante') Of oFolder:aDialogs[7] PIXEL SIZE 070,009
      @ 019, aPosGet[1,1] Say OemToAnsi('Área de aplicação') of oFolder:aDialogs[7] PIXEL SIZE 070,009   
      @ 006, aPosGet[1,3] Say OemToAnsi('Obs Aprovacao') Of oFolder:aDialogs[7] PIXEL SIZE 070,009
      @ 006, aPosGet[1,5] Say OemToAnsi('Obs Fornecedor') Of oFolder:aDialogs[7] PIXEL SIZE 070,009
   
      If nOpc==2
         @ 005, aPosGet[1,2] Say OemToAnsi(aMisc[1]) Of oFolder:aDialogs[7] PIXEL SIZE 100,009
         @ 018, aPosGet[1,2] Say OemToAnsi(aMisc[2]) Of oFolder:aDialogs[7] PIXEL SIZE 100,009
         //@ 006, aPosGet[1,4]-50 Say OemToAnsi(aMisc[3]) Of oFolder:aDialogs[7] PIXEL SIZE 200,041
         oMemo:=tMultiGet():New(006,aPosGet[1,3]+50,{|u|If(PCount()>0, aMisc[3]:=u, aMisc[3])}, oFolder:aDialogs[7],150,041,,,,,,.T.,,,,,,,,,,.T.,.T.)
         oMemo2:=tMultiGet():New(006,aPosGet[1,5]+50,{|u|If(PCount()>0, aMisc[4]:=u, aMisc[4])}, oFolder:aDialogs[7],150,041,,,,,,.T.,,,,,,,,,,.T.,.T.)
      Else
         @ 005, aPosGet[1,2] MsGet aMisc[1] Picture '@!'  Of oFolder:aDialogs[7] PIXEL SIZE 100,009 HASBUTTON
         @ 018, aPosGet[1,2] MsGet aMisc[2] Picture '@!'  Of oFolder:aDialogs[7] PIXEL SIZE 100,009 HASBUTTON
         oMemo:=tMultiGet():New(006,aPosGet[1,3]+50,{|u|If(PCount()>0, aMisc[3]:=u, aMisc[3])}, oFolder:aDialogs[7],150,041,,,,,,.T.,,,,,,,,,,.T.,.T.)
	     oMemo2:=tMultiGet():New(006,aPosGet[1,5]+50,{|u|If(PCount()>0, aMisc[4]:=u, aMisc[4])}, oFolder:aDialogs[7],150,041,,,,,,.T.,,,,,,,,,,.T.,.T.)
      Endif
   Endif 
Endif
RestArea(_aArea)
Return Nil
          
User Function MTA120G2
Local _aArea:=GetArea() 
Default aMisc := {"","","",""}
If !IsInCallStack("CNTA120") .And. !IsInCallStack("IACOMP03")
   SC7->C7_SOLICIT := aMisc[1]
   SC7->C7_XAPLIC  := aMisc[2]
   SC7->C7_XOBS    := aMisc[3]
   SC7->C7_XOBSF   := aMisc[4]
Endif                   
RestArea(_aArea)
Return                     

 