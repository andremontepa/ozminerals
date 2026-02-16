#include 'protheus.ch'

/*/{Protheus.doc} M116ACOL
Ponto de Entrada para manipulação do aCols na inclusão de Conhecimento de Frete.
Ajustado para buscar o Tipo de Operação no campo F4_CODIGO2 da TES de origem.
/*/
User Function M116ACOL()
	Local cAliasSD1 := ParamIXB[1] // Alias da query/área da SD1 de origem
	Local nX        := ParamIXB[2] // Índice da linha corrente no aCols
	Local aDoc      := PARAMIXB[3] // Vetor contendo dados do documento
	Local _aArea    := GetArea()
	Local _cMsg     := "O(s) campo(s) a seguir estarão sem preenchimento na aba Informações adicionais: " + CRLF
	Local _lMostra  := .F.

	// Variáveis Private do MATA116 acessíveis no escopo
	Local nPosXOper := aScan(aHeader, {|x| AllTrim(x[2]) == "D1_XOPER"})
	Local nPosOper  := aScan(aHeader, {|x| AllTrim(x[2]) == "D1_OPER"})
	Local nPosTes   := aScan(aHeader, {|x| AllTrim(x[2]) == "D1_TES"})

	// Dados da NF de origem para busca
	Local cTesOrig  := (cAliasSD1)->D1_TES
	Local cXOper    := (cAliasSD1)->D1_XOPER
	Local cTesCTE   := Space(TamSX3("D1_TES")[1])

	// 1. Lógica para buscar o tes  na SF4 da origem via F4_CODIGO2
	// Se o campo F4_CODIGO2 estiver preenchido na TES da nota original, usamos ele como D1_TES
	cTesCTE := Posicione("SF4", 1, xFilial("SF4") + cTesOrig, "F4_CODIGO2")

	// 2. Gravação do Campo D1_XOPER e limpeza do D1_OPER padrão
	aCols[nX][nPosXOper] := cXOper
	aCols[nX][nPosOper]  := cXOper



	// 4. Gravação do Campo D1_TES diretamente no aCols se encontrou correspondência na SFM
	aCols[nX][nPosTes] := cTesCTE


	//-- Processamento de usuário (Informações Adicionais)
	// Verificando se a variável existe para evitar erro de runtime
	aInfAdic[10] := Posicione("SA2", 1, xFilial("SA2") + cA100For + cLoja, "A2_EST")
	aInfAdic[11] := Posicione("SA2", 1, xFilial("SA2") + cA100For + cLoja, "A2_COD_MUN")
	aInfAdic[12] := Posicione("SM0", 1, cNumEmp, "M0_ESTENT")
	aInfAdic[13] := RIGHT(Posicione("SM0", 1, cNumEmp, "M0_CODMUN"), 5)

	If Empty(aInfAdic[10])
		_cMsg += CRLF + "ESTADO DE ORIGEM"
		_lMostra := .T.
	EndIf
	If Empty(aInfAdic[11])
		_cMsg += CRLF + "MUNICIPIO DE ORIGEM"
		_lMostra := .T.
	EndIf
	If Empty(aInfAdic[12])
		_cMsg += CRLF + "ESTADO DE DESTINO"
		_lMostra := .T.
	EndIf
	If Empty(aInfAdic[13])
		_cMsg += CRLF + "MUNICIPIO DE DESTINO"
		_lMostra := .T.
	EndIf

	If _lMostra
		Alert(_cMsg)
	EndIf


	RestArea(_aArea)
Return Nil
