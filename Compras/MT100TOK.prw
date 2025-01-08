#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "PRTOPDEF.CH"

/*/{Protheus.doc} MT100TOK
Rotina de importação de Dados de Tabelas Pre Definidas
@type function           
@author Ricardo Tavares Ferreira
@since 10/03/2022
@version 12.1.27
@obs Descrição: LOCALIZAÇÃO : Function A103Tudok()
EM QUE PONTO : Este P.E. é chamado na função A103Tudok()
Pode ser usado para validar a inclusao da NF.
Esse Ponto de Entrada é chamado 2 vezes dentro da rotina A103Tudok(). 
Para o controle do número de vezes em que ele é chamado foi criada a variável lógica lMT100TOK, 
que quando for definida como (.F.) o ponto de entrada será chamado somente uma vez.
@link https://tdn.totvs.com/pages/releaseview.action?pageId=6085400
@history 10/03/2022, Ricardo Tavares Ferreira, Construção Inicial
/*/
//=============================================================================================================================
User Function MT100TOK()
//=============================================================================================================================

	Local aArea     := GetArea()
	Local nVal      := 0
	Local nPosTotal := aScan(aHeader,{|x| AllTrim(x[2])=="D1_TOTAL"})
	Local nPosPed   := aScan(aHeader,{|x| AllTrim(x[2])=="D1_PEDIDO"})

	Local dEmitam   := ""
	Local dEmitay   := ""

	Local cTes		:= ""
	Local nPosTes   := aScan(aHeader,{|x| AllTrim(x[2])=="D1_TES"})
	Local cPedCom   := ""
	Local aVenc     := {}
	Local aDados    := {}
	Local nX        := 0

	Local dDataFim  := Nil

	dbselectarea("SF2")
	dEmitam   := substr(dtoc(F2_EMISSAO),4,2)  // Mês
	dEmitay   := substr(dtoc(F2_EMISSAO),7,4)  // Ano
	RestArea(aArea)
	
	lMT100TOK := .F.
	If FWIsInCallStack("MATA311")
		Return .T.
	EndIf

	If FWIsInCallStack("MATA103")
		aDados := aCols

		For nX := 1 To Len(aDados)
			nVal 	 += aDados[nX][nPosTotal]
			cPedCom  := aDados[nX][nPosPed]
			cTes     := aDados[nX][nPosTes]
		Next nX

		aVenc := Condicao(nVal,CCONDICAO,0,DDEMISSAO,0)
		//Stephen Noel - Equilibrio T.I. 03/10/22 - Se for tranferencia entre filiais
		If ! Alltrim(cTes) == '206' .AND. Posicione('SF4',1,xFilial('SF4')+cTes,'F4_DUPLIC') == 'S'
		//Regras

        if  dEmitam=substr(dtoc(DDatabase),4,2).and. dEmitay=substr(dtoc(DDatabase),7,4)  // Dentro do MÊS / ANO
				
			If Empty(cPedCom)
				For nX := 1 To Len(aVenc)
					dDataFim := DaySum(Date(),7)
		   			If Val(Dtos(aVenc[nX][1])) < Val(Dtos(dDataFim)) 
						//Substituido a pedido do Leonardo aAbax - Stephen
					    //MsgStop("Para documentos sem vinculo com PC a data de vencimento nao pode ser menor que 7 dias da data atual ("+Dtoc(Date())+"). Data do sistema ("+Dtoc(DDatabase)+").","A1031DUP")
						Help(" ",1,"MT100TOK",,"Para documentos sem vinculo com PC a data de vencimento nao pode ser menor que 7 dias da data atual ("+Dtoc(Date())+"). Data do sistema ("+Dtoc(DDatabase)+").",4,1)
						Return .F.
					EndIf
				Next nX
			EndIf

			For nX := 1 To Len(aVenc)
				If Val(Dtos(aVenc[nX][1])) < Val(Dtos(Date()))
					//Substituido a pedido do Leonardo aAbax - Stephen
					//MsgStop("A Data Utilizada para vencimento do titulo nao pode ser menor que a data atual ("+Dtoc(Date())+"). Data do sistema ("+Dtoc(DDatabase)+").","A1031DUP")
					Help(" ",1,"MT100TOK",,"A Data Utilizada para vencimento do titulo nao pode ser menor que a data atual ("+Dtoc(Date())+"). Data do sistema ("+Dtoc(DDatabase)+").",4,1)
					Return .F.
				EndIf
			Next nX
		EndIf
	    Endif
	EndIf
	RestArea(aArea)

Return .T.
