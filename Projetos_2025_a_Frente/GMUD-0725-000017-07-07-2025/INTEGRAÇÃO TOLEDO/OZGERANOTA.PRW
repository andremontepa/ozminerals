#Include "Protheus.ch"
#Include "RwMake.ch"
#Include "TopConn.ch"

Static _cMsgErro := ""

/*/{Protheus.doc}   OZGERANOTA

@author Julio Martins - Crmservices
@Maio/2025
/*/

User Function OZGERANOTA(c_Pedido,c_Ser,cProdu,cClient,cLoja,cQuant,pUnit)

	Local _aArea := GetArea()
	Local _aAreaSC5 := SC5->(GetArea())
	Local _aAreaSC6 := SC6->(GetArea())
	Local _aAreaSC9 := SC9->(GetArea())
	Local _aAreaSF4 := SF4->(GetArea())
	Local _aAreaSB1 := SB1->(GetArea())
	Local _aAreaSB2 := SB2->(GetArea())

	Local _aPvlNfs := {}
	
	Local _cRetorno := ""
	
	Private _aRecnos := {}

	Default c_Pedido := ""
	Default c_Ser    := ""
	Default cProdut  := ""
	Default cClient  := ""
	Default cLoja    := ""
	Default cQuant   := 0
	Default pUnit    := 0

	
	DbSelectArea("SC5")		// PEDIDOS DE VENDA
	SC5->(DbSetOrder(1))	// C5_FILIAL+C5_NUM
	
	DbSelectArea("SC6")		// ITENS DOS PEDIDOS DE VENDA
	SC6->(DbSetOrder(1))	// C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
	
	DbSelectArea("SC9")		// PEDIDOS LIBERADOS
	SC9->(DbSetOrder(1))	// C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO
	
	DbSelectArea("SE4")		// CONDICOES DE PAGAMENTO
	SE4->(DbSetOrder(1))	// E4_FILIAL+E4_CODIGO
	
	DbSelectArea("SF4")		// TIPOS DE ENTRADA E SAIDA
	SF4->(DbSetOrder(1))	// F4_FILIAL+F4_CODIGO
	
	DbSelectArea("SB1")		// DESCRICAO GENERICA DO PRODUTO
	SB1->(DbSetOrder(1))	// B1_FILIAL+B1_COD
	
	DbSelectArea("SB2")		// SALDOS FISICO E FINANCEIRO
	SB2->(DbSetOrder(1))	// B2_FILIAL+B2_COD+B2_LOCAL

	_cMsgErro := ""
	
	ConOut(FunName() + " - Inicio da geração da geração de nota do pedido '" + c_Pedido + "'. Data: " + DtoC(dDataBase) + " - Hora: " + Time())
	
	If _fValida(c_Pedido,c_Ser,cProdu,cClient,cLoja,cQuant,pUnit)

		// Função para montar as informações para geração da nota.
		_aPvlNfs := _fMakeInf(c_Pedido)
		
		// Função para gerar nota.
		_cRetorno := _fGeraDoc(_aPvlNfs,c_Ser)		
	EndIf
	
	ConOut(FunName() + " - Final da geração da geração de nota do pedido '" + c_Pedido + "'. Data: " + DtoC(dDataBase) + " - Hora: " + Time())

	RestArea(_aAreaSB2)
	RestArea(_aAreaSB1)
	RestArea(_aAreaSF4)
	RestArea(_aAreaSC9)
	RestArea(_aAreaSC6)
	RestArea(_aAreaSC5)
	RestArea(_aArea)

Return _cRetorno



Static Function _fValida(c_Pedido,c_Ser,cProdu,cClient,cLoja,cQuant,pUnit)

	Local _lContinua := .F.

	Default c_Pedido := ""
	
	If Empty(c_Pedido)
		_cMsgErro := "Numero do pedido não informado!"
	ElseIf !SC5->(Dbseek(xFilial("SC5")+c_Pedido))
		_cMsgErro := "Numero do pedido[" + _cMsgErro + "] não encontrado!"
	ElseIf !Empty(SC5->C5_NOTA)
		_cMsgErro := "Numero do pedido[" + _cMsgErro + "] já possui nota!"
	Else
		_lContinua := .T.
		//##################################//
		// Libera o Pedido para Faturamento //
        //####################################
       		DbSelectArea("SC9")
			DbSetOrder(1)
			RecLock("SC9", .T.)
			SC9->C9_FILIAL  := cFilAnt
			SC9->C9_DATALIB := DDATABASE
			SC9->C9_PEDIDO  := c_Pedido
			SC9->C9_ITEM    := "01"
			SC9->C9_PRODUTO := cProdu    // Codigo do Produto
			SC9->C9_CLIENTE := cClient   // Codigo Cliente Destino
			SC9->C9_LOJA    := cLoja     // Loja Cliente
			SC9->C9_QTDLIB  := cQuant    // Quantidade Liberada
			SC9->C9_SEQUEN  := "01"
            SC9->C9_PRCVEN  := pUnit     // Preço unitário
			SC9->C9_GRUPO   := ""
			SC9->C9_BLEST   := "10"
			SC9->C9_BLCRED  := "10"
			SC9->C9_LOCAL   := "01"
			SC9->C9_TPCARGA := "2"
			//SC9->C9_DATAENT := DDATABASE
			SC9->C9_NUMSEQ  :=" "
			SC9->C9_RETOPER :="2"
			SC9->C9_TPOP    :="1"
			SC9->C9_SOLFLG  := 0
			SC9->( MsUnlock() )
	EndIf
	
Return _lContinua


Static Function _fMakeInf(c_Pedido)
Local   _aPvlNfs  := {}
Local   _nPosicao := 0
Default c_Pedido  := ""

	If !Empty(c_Pedido)
		If SC5->(Dbseek(xFilial("SC5")+c_Pedido))
			// Condição de pagamento
			SE4->(Dbseek(xFilial("SE4")+SC5->C5_CONDPAG))

			If SC6->(Dbseek(xFilial('SC6')+c_Pedido))
				While SC6->(!Eof()) .And. xFilial('SC6')+c_Pedido == SC6->(C6_FILIAL+C6_NUM)
					// Pedidos liberados
					SC9->(Dbseek(xFilial("SC9")+SC6->(C6_NUM+C6_ITEM)))

					// Cadastro de produtos
					SB1->(Dbseek(xFilial("SB1")+SC6->C6_PRODUTO))

					// Saldos fisico e financeiro
					SB2->(Dbseek(xFilial("SB2")+SC6->C6_PRODUTO))
					
					// Tipos de entrada e saida
					SF4->(Dbseek(xFilial("SF4")+SC6->C6_TES))
					
					// Adiciona um linha
					Aadd(_aPvlNfs,{})
					_nPosicao := Len(_aPvlNfs)
					
					// Adiciona as colunas
					Aadd(_aPvlNfs[_nPosicao],SC5->C5_NUM)		// Numero Pedido
					Aadd(_aPvlNfs[_nPosicao],SC9->C9_ITEM)		// Item do pedido
					Aadd(_aPvlNfs[_nPosicao],SC9->C9_SEQUEN)	// Sequencia
					Aadd(_aPvlNfs[_nPosicao],SC9->C9_QTDLIB)	// Quantidade liberada
					Aadd(_aPvlNfs[_nPosicao],SC9->C9_PRCVEN)	// Preço de venda
					Aadd(_aPvlNfs[_nPosicao],SC9->C9_PRODUTO)	// Codigo do produto
					Aadd(_aPvlNfs[_nPosicao],.F.)
					Aadd(_aPvlNfs[_nPosicao],SC9->(RecNo()))
					Aadd(_aPvlNfs[_nPosicao],SC5->(RecNo()))
					Aadd(_aPvlNfs[_nPosicao],SC6->(RecNo()))
					Aadd(_aPvlNfs[_nPosicao],SE4->(RecNo()))
					Aadd(_aPvlNfs[_nPosicao],SB1->(RecNo()))
					Aadd(_aPvlNfs[_nPosicao],SB2->(RecNo()))
					Aadd(_aPvlNfs[_nPosicao],SF4->(RecNo()))
					
					Aadd(_aRecnos,{})
					_nPosicao := Len(_aRecnos)
					
					Aadd(_aRecnos[_nPosicao],{"SC9",SC9->(RecNo())})
					Aadd(_aRecnos[_nPosicao],{"SC5",SC5->(RecNo())})
					Aadd(_aRecnos[_nPosicao],{"SC6",SC6->(RecNo())})
					Aadd(_aRecnos[_nPosicao],{"SE4",SE4->(RecNo())})
					Aadd(_aRecnos[_nPosicao],{"SB1",SB1->(RecNo())})
					Aadd(_aRecnos[_nPosicao],{"SB2",SB2->(RecNo())})
					Aadd(_aRecnos[_nPosicao],{"SF4",SF4->(RecNo())})

					SC6->(DbSkip())
				EndDo
			EndIf
		EndIf
	EndIf

Return _aPvlNfs


Static Function _fGeraDoc(a_PvlNfs,c_Ser)

	Local _cNumDoc 	:= ""	
	Local _aError 	:= {}	
	Local nX     	:= 0
	Local _nModuloAt:= 0
	Local c_SerBkp	:= ""

	Default a_PvlNfs := {}	
	Default c_Ser    := ""
	
	If Empty(a_PvlNfs)
		ConOut("a_PvlNfs vazio")
	Else
		// Guarda o modulo atual
		_nModuloAt := nModulo
		
		// Ativa o modulo faturamento
		nModulo := 5	
		
		ConOut("Gerando a nota fiscal.")
		
		// Função para destravar o SX5, o parametro MV_NUMITEM e os recnos utilizados para realizar a nota.
		U_EXTERF11(c_Ser,_aRecnos)
		
		/*Parametros do MaPvlNfs - Função para inclusao de Nota fiscal de Saida atraves do PV liberado
			01 - aPvlNfs: Array com os itens a serem gerados                    
			02 - cSerieNFS: Serie da Nota Fiscal                                  
			03 - lMostraCtb: Mostra Lct.Contabil                                   
			04 - lAglutCtb: Aglutina Lct.Contabil                                 
			05 - lCtbOnLine: Contabiliza On-Line                                   
			06 - lCtbCusto: Contabiliza Custo On-Line                             
			07 - lReajuste: Reajuste de preco na nota fiscal                      
			08 - nCalAcrs: Tipo de Acrescimo Financeiro                          
			09 - nArredPrcLis: Tipo de Arredondamento                                
			10 - lAtuSA7: Atualiza Amarracao Cliente x Produto                  
			11 - lECF: Cupom Fiscal                                          
			12 - cEmbExp: Numero do Embarque de Exportacao                      
			13 - bAtuFin: Code block para complemento de atualizacao dos titulos financeiros.                                     
			14 - bAtuPGerNF: Code block para complemento de atualizacao dos dados apos a geracao da nota fiscal.                       
			15 - bAtuPvl: Code Block de atualizacao do pedido de venda antes da geracao da nota fiscal*/

			//Dança das séries criada para que o processo de seleção das notas seja feito com mais praticidade. O fonte padrão TOTVS busca o campo com espaço no fim. Por isso eu coloco o espaço e depois retiro.
			If Len(c_Ser) <> 3
				c_SerBkp := c_Ser
				c_Ser    := c_Ser + Space(2)
			EndIf
		
		//_cNumDoc := MaPvlNfs(a_PvlNfs,c_SerDoc,.F.,.F.,.F.,.T.,.F.,0,0,.T.,.F.)

		_cNumDoc := MaPvlNfs(a_PvlNfs,c_Ser,.F.,.F.,.F.,.F.,.F.,0,0,.F.,.F.,"",{||},{||},{||},{|| .T. },Date(),.F.)


		_aError := GetAutoGRLog()

			
			If Len(c_Ser) <> 3
				c_Ser := c_SerBkp
			EndIf

		// Se retornar este bloco PULA NF 
		// IncNota(a_PvlNfs[1][1],c_SerDoc,"",@aNotas)
		// _cNumDoc := aNotas[1][2]
		#IFDEF TOP
	
			//-- Na função IncNota tem uma chamada para a função NxtSX5Nota (MATXFUNA) onde tem um RecLock no parâmetro MV_NUMITEN,
			//-- ao voltar, por algum motivo, o lock não é retirado, em todas as outras tabelas os locks são perdidos ao finalizar com
			//-- END TRANSACTION.... a tabela SX6 continua com o registro travado dando erro em outras telas.	Esse problema só ocorre
			//-- qdo estamos utilizando o TOP CONNECT com o parâmetro MV_TTS como S.
			aLockSX6 := SX6->(DBRLockList())
	
			For nX := 1 To Len(aLockSX6)	
	
				SX6->(DBGoTo(aLockSX6[nX]))
				SX6->(MSUnLock())
			
			Next nX
	
		#ENDIF

		// Função para destravar o SX5, o parametro MV_NUMITEM e os recnos utilizados para realizar a nota.
		U_EXTERF11(c_Ser,_aRecnos)

		//MsUnLockAll()
		//DBCommitAll()

		// Volta o modulo atual
		nModulo := _nModuloAt

		If Empty(_cNumDoc)
			ConOut("Erro na Geracao da Nota Fiscal")

		//	_aError := GetAutoGRLog()
			AEval(_aError,{|x| _cMsgErro += "Pedido: " + AllTrim(x[1]) + " | Nota: " + AllTrim(x[2]) + " | Serie: " + AllTrim(x[3]) + CRLF })			
			Conout("ReprogrammingSalesOrder",_cMsgErro)
		Else
			ConOut("***Nota fiscal gerada com sucesso***")
			Conout("***Nota " + _cNumDoc + "|" + c_Ser + " gerada com sucesso!")
		EndIf
	EndIf

Return _cNumDoc


User Function FT013AER()

Return _cMsgErro
