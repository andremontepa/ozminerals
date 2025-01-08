#Include "Rwmake.ch"
#Include "Protheus.ch"
#include "TOTVS.CH"
User Function CRIASB9()

If MsgYesNo("Este programa vai criar os saldos iniciais na SB9 a partir da SB7. Continua?")
	
	Processa({|| RunCont() },"Processando...")
	
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma ³IMPSB1    ºAutor ³Microsiga           º Data ³ 04/17/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function RunCont()
Local dData := CTOD("30/06/2017")

dbSelectArea("SB7")
SB7->(dbSetOrder(1))
SB7->(dbGoTop())

nRecCount := 0
Count to nRecCount
ProcRegua(nRecCount)
SB7->(dbGoTop())
While SB7->(!Eof())
	
	If STOD(DTOS(SB7->B7_DATA)) <= dData
		SB7->(dbSkip())
		Loop
	Endif
	
	IncProc(OemToAnsi("PRODUTO: ")+SB7->B7_COD)
	ProcessMessages()
	
	dbSelectArea("SB9")
	dbSetOrder(1)
	//B9_FILIAL, B9_COD, B9_LOCAL, B9_DATA, R_E_C_N_O_, D_E_L_E_T_
	If !dbSeek(xFilial("SB9")+SB7->B7_COD+SB7->B7_LOCAL)
		
		SB9->(RecLock("SB9",.T.))
		SB9->B9_FILIAL     := xFilial("SB9")
		SB9->B9_QINI       := 0.00
		SB9->B9_COD        := SB7->B7_COD
		SB9->B9_LOCAL      := SB7->B7_LOCAL
		SB9->B9_DATA 	   := CTOD("01/07/2017")
		SB9->(msUnLock())
		
	EndIf
	dbSelectArea("SB7")
	SB7->(dbSkip())
Enddo
Return
