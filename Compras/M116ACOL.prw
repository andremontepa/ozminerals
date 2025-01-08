#include 'protheus.ch'


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณM116ACOL()     บAutor  Charles Lima    บ Data ณ  11/10/19   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.   ณ Ponto de entrada utilizado para preencher automaticamente    บฑฑ
ฑฑบ        ณ os campos da aba de informa็๕es adicionais do doc. de entradaบฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGACOM - Conhecimento de frete                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function M116ACOL() 


	Local cAliasSD1 := PARAMIXB[1]   //-- Alias arq. NF Entrada itens
	Local nX        := PARAMIXB[2]    //-- N๚mero da linha do aCols correspondente
	Local aDoc      := PARAMIXB[3]    //-- Vetor contendo o documento, s้rie, fornecedor, loja e itens do documento
	Local _aArea    := GetArea()
	Local _cMsg     := "O(s) campo(s) a seguir estarใo sem preenchimento na aba Informa็๕es adicionais: " + CRLF
	Local _lMostra  := .F.

	//-- Processamento de usuแrio

	aInfAdic[10] :=	Posicione("SA2",1,xfilial("SA2")+cA100For+cLoja,"A2_EST")     // ESTADO DE ORIGEM    | F1_UFORITR | 
	aInfAdic[11] :=	Posicione("SA2",1,xfilial("SA2")+cA100For+cLoja,"A2_COD_MUN") // MUNICIPIO DE ORIGEM | F1_MUORITR |	
	aInfAdic[12] :=	Posicione("SM0",1,cNumEmp,"M0_ESTENT")                        // ESTADO DE DESTINO    | F1_UFDESTR |
	aInfAdic[13] :=	RIGHT(Posicione("SM0",1,cNumEmp,"M0_CODMUN"),5)               // MUNICIPIO DE DESTINO | F1_MUDESTR |

	If Empty(aInfAdic[10])
		_cMsg += CRLF
		_cMsg += "ESTADO DE ORIGEM"
		_lMostra := .T.
	Endif
	If Empty(aInfAdic[11])
		_cMsg += CRLF
		_cMsg += "MUNICIPIO DE ORIGEM"
		_lMostra := .T.
	Endif 
	If Empty(aInfAdic[12])
		_cMsg += CRLF
		_cMsg += "ESTADO DE DESTINO"
		_lMostra := .T. 
	Endif
	If Empty(aInfAdic[13])
		_cMsg += CRLF
		_cMsg += "MUNICIPIO DE DESTINO"
		_lMostra := .T.
	Endif

	If _lMostra
		Alert (_cMsg)
	Endif

	RestArea(_aArea)

Return Nil


