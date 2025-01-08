
#include "protheus.ch"
#INCLUDE "TOPCONN.CH"

User function F240OK2()
	local lRet:= .T.
Return lRet

User Function F240TDOK

	Local peAliasSE2 := paramixb[2]
	Local lRetorno   := .T.
	Local aCliente   := {}
	Local nX         := 0
	Local cTexto     := " "
	Local cCgc       := " "
	Local cNome      := " "
	Local proxCGc    := " "
	Static cCodigo   := " "
	Static cLoja     := " "



	If .Not. Empty( paramixb[1] )
		While !(peAliasSE2)->(Eof())
			cCgc    :=    Posicione("SA2",1,xFilial('SA2')+E2_FORNECE+E2_LOJA, 'A2_CGC') //Pegando cgc fornecedor
			cNome   :=    Posicione("SA1",3,xFilial('SA1')+cCgc, 'A1_NOME')//Pegando nome fornecedor
			cCodigo :=    Posicione("SA1",3,xFilial('SA1')+cCgc, 'A1_COD')  //Codigo cliente
			cLoja   :=    Posicione("SA1",3,xFilial('SA1')+cCgc, 'A1_LOJA')//Loja Cliente
			If !empty(cCgc)
				If CriaTMP1() > 0 .and. !proxCGc == cCgc
					Aadd(aCliente, {cCodigo, cLoja, cNome})
				EndIf
			EndIf
			(peAliasSE2)->(dbSkip())
			proxCGc:= cCgc
		End
	EndIf

	For nX := 1 to Len(aCliente)
		cTexto += "Fron.:" +E2_FORNECE+'-'+E2_LOJA+" Cli.: "+aCliente[nX][1]+'-'+aCliente[nX][2]+'   '+aCliente[nX][3]+chr(13)+chr(10)
	Next

	If !empty(cTexto)
		If !MsgYesNo(cTexto, "Exitem Fornecedores com títulos à receber em aberto, continua?")
			lRetorno   := .F.
		EndIf
	EndIf

Return lRetorno


Static Function CriaTMP1()

	Local cQuery  :=  " "
	Static nQtdTit :=  0

	cQuery := " SELECT * FROM SE1010 "
	cQuery += " WHERE E1_CLIENTE = '"+cCodigo+"' AND E1_LOJA = '"+cLoja+"' "
	cQuery += " AND E1_SALDO > 0 AND D_E_L_E_T_ = ' ' AND E1_CLIENTE <> '000009' "

	If Select("TMP1") > 0
		TMP1->(DbCloseArea())
	Endif

	TCQUERY cQuery NEW ALIAS "TMP1"

	DbSelectArea("TMP1")
	TMP1->(DbGoTop())
	Count to nQtdTit
	TMP1->(DbCloseArea())

Return nQtdTit
