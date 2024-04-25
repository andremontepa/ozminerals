#Include "Protheus.ch"
#Include "Topconn.ch"
#include "rwmake.ch"
#include "fileio.ch"
#include "TbiConn.ch"
#include "TbiCode.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MT120OK   ºAutor  ³Ismael Junior       º Data ³  22/06/19   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ O ponto de entrada MT161OK é usado para validar as propostas ±
±±º          ³dos fornecedores no momento da gravação da análise da cotação ±
±±º          ³Se .T. finaliza o processo. Se .F., interrompe o processo.  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function MT161OK()
Local aPropostas := PARAMIXB[1] // Array contendo todos os dados da proposta da cotação
Local cTpDoc     := PARAMIXB[2] // Tipo do documento
Local lReturn    := .T.
Local nX := nY := nZ   := 0 
Local cAno       := Alltrim(Str(Year(Date())))
Local _lRet      := .T.
Local _cCusto    := _cItemco := _cConta  := _cClvl := ""
Local cTexto     := "" 
Local aCab     	 := {}
Local aInfor     := {}
Local oTabTemp	:= Nil 
Private aCampos  :={ {"CHAV" ,"C", 38,0},;
{"BLOQ" ,"C",1,0},;
{"CCUSTO" ,"C",9,0},;
{"ITEMCO" ,"C",9,0},;
{"CLVL" ,"C",20,0},;
{"CONTA" ,"C",20,0},;
{"NVLTOT","N",14,2},;
{"NVLCON","N",14,2},;
{"CONTROLA" ,"C",1,0}}  // campos da tabela temporária

If Select("TRB")> 0
	TRB->(DbCloseArea())
Endif

oTabTemp := FWTemporaryTable():New("TRB", aCampos)
oTabTemp:AddIndex("01","CHAV+CCUSTO+ITEMCO")
oTabTemp:Create()

If cTpDoc = 'Pedido de Compra' //Pedido de Compra
	For nX := 1 To Len(aPropostas[1])
	 If Len(aPropostas[1][nX][1]) > 0  
		For nY := 1 To Len(aPropostas[1][nX])
		 If nY > 1 
			For nZ := 1 To Len(aPropostas[1][nX][nY])
				If aPropostas[1][nX][nY][nZ][1] = .T. 
				cFornecedor := aPropostas[1][nX][1][1]
		 		cItem     := aPropostas[1][nX][nY][nZ][2]   
		 		cProduto  := aPropostas[1][nX][nY][nZ][3]
		    	nValor    := aPropostas[1][nX][nY][nZ][4]
	 			
				cQuery := " SELECT  C1_CC,C1_ITEMCTA,C1_CLVL,C1_CONTA,C8_TOTAL AS TOTAL "
				cQuery += " FROM "+RetSqlName("SC8")+" SC8 "
				cQuery += " INNER JOIN "+RetSqlName("SC1")+" SC1 ON C1_NUM = C8_NUMSC AND C1_FILIAL = C8_FILIAL AND SC1.D_E_L_E_T_ != '*' "
				//cQuery += " WHERE C8_NUMSC = '"+SC8->C8_NUMSC+"' "
			   	//cQuery += " AND C8_NUM = '"+SC8->C8_NUM+"' "  
			   	cQuery += " WHERE C8_NUM = '"+SC8->C8_NUM+"' "
				cQuery += " AND C8_FORNECE = '"+cFornecedor+"' "
				cQuery += " AND C1_PRODUTO = '"+cProduto+"' " 
				cQuery += " AND C1_FILIAL = '"+xFilial("SC8")+"' "
				cQuery += " AND C8_ITEM = '"+cItem+"' "
				cQuery += " AND SC8.D_E_L_E_T_ != '*' "							
				
				If SELECT("TRA") > 0
					TRA->(DbCloseArea())
				Endif
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRA",.T.,.T.) 
				TRA->(DbGoTop())
			   //	While TRA->(!EOF())	       
						cQuery := " SELECT SUM(ZW2_PREANO)-SUM(ZW2_VLANO) VLSALDO, ZW2_BLOQ FROM "+RetSqlName("ZW2")+" ZW2 "
						cQuery += " WHERE ZW2_CCUSTO = '"+TRA->C1_CC+"' "
						cQuery += " AND ZW2_ITEMCO = '"+TRA->C1_ITEMCTA+"' "
						cQuery += " AND ZW2_CLVL = '"+TRA->C1_CLVL+"' "
						cQuery += " AND ZW2_CONTA = '"+TRA->C1_CONTA+"' "
						cQuery += " AND ZW2_ANO = '"+cAno+"' "
						cQuery += " AND ZW2_VLANO >= 0 "
						//cQuery += " AND ZW2_FILIAL = '"+xFilial("ZW2")+"' "
						cQuery += " AND ZW2.D_E_L_E_T_ != '*' " 
						cQuery += " GROUP BY ZW2_BLOQ " 						
							
						If SELECT("TRC") > 0
							TRC->(DbCloseArea())
						Endif
						dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRC",.T.,.T.)
                        //Inicio ***************** 06/04/2020 verifica se bloqueia sim ou não ****************
						cQrybloq := " SELECT ZW2_BLOQ FROM "+RetSqlName("ZW2")+" ZW2 "
						cQrybloq += " WHERE ZW2_CCUSTO = '"+TRA->C1_CC+"' "
						cQrybloq += " AND ZW2_ITEMCO = '"+TRA->C1_ITEMCTA+"' "
						cQrybloq += " AND ZW2_CLVL = '"+TRA->C1_CLVL+"' "
						cQrybloq += " AND ZW2_CONTA = '"+TRA->C1_CONTA+"' "
						cQrybloq += " AND ZW2_ANO = '"+cAno+"' "
						cQrybloq += " AND ZW2.D_E_L_E_T_ != '*' " 						
							
						If SELECT("TRD") > 0
							TRD->(DbCloseArea())
						Endif
						dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQrybloq),"TRD",.T.,.T.)
						//Fim ***************************************************************************
						If _cCusto+_cItemco+_cConta <> TRA->C1_CC + TRA->C1_ITEMCTA + TRA->C1_CLVL + TRA->C1_CONTA
							nValPed  := 0
							nValPed  := TRA->TOTAL
							_cCusto  := TRA->C1_CC
							_cItemco := TRA->C1_ITEMCTA
							_cClvl   := TRA->C1_CLVL
							_cConta  := TRA->C1_CONTA
						Else
							//nValPed := nValPed + nValor
							nValPed := nValor
						Endif
						dbSelectArea("TRC")
						cChave := TRA->C1_CC + TRA->C1_ITEMCTA + TRA->C1_CLVL + TRA->C1_CONTA
						nVlSaldo := TRC->VLSALDO 
						cControla := TRD->ZW2_BLOQ 
						If nVlSaldo = 0    // ajuste para conta não cadastrada
							lReturn := .F.
							_lRet := .F.
						Endif
						TRB->(dbSeek(cChave))
						IF TRB->(EOF())
							reclock("TRB",.T.)
							TRB->CHAV       := cChave
							TRB->NVLTOT     := nValPed
							TRB->NVLCON     := nVlSaldo
							TRB->CCUSTO     := TRA->C1_CC
							TRB->ITEMCO     := TRA->C1_ITEMCTA
							TRB->CLVL     := TRA->C1_CLVL
							TRB->CONTA      := TRA->C1_CONTA
							TRB->CONTROLA	:= cControla
						ELSE
							reclock("TRB",.F.)
							TRB->NVLTOT     := TRB->NVLTOT + nValPed
							TRB->NVLCON     := nVlSaldo
						ENDIF	   		
				//TRA->(Dbskip())
			   //	Enddo		    
				Endif 
			Next nZ							       	          
		 Endif	
		Next nY
	 Endif				
	Next nX
	 
	TRB->(DbGoTop())
	While TRB->(!EOF())
		nVlPed  := TRB->NVLTOT
		nVlCont := TRB->NVLCON
		cControl := TRB->CONTROLA

		If cControl = 'S' .or. Empty(cControl)// Sinaliza que a flag de controle para centro de custo esta desativada para bloqueio	
				nValTot := nVlCont - nVlPed
				If nValTot <= 0
					_lRet := .F.
					lReturn := .F.
					reclock("TRB",.F.)
					TRB->BLOQ := "B"
				Endif
		Else
			_lRet := .T.
			lReturn := .T.								
		Endif	
		TRB->(Dbskip())
	Enddo
	
	If !_lRet
		TRB->(DbGoTop())
		While TRB->(!EOF())
			If Empty(TRB->BLOQ)
			lReturn := .F.
				cTexto +="Saldo da conta insuficiente!"+chr(13)+chr(10)
				cTexto +="Centro de Custo: "+Alltrim(SubStr(TRB->CHAV,1,9))+", Item: "+Alltrim(SubStr(TRB->CHAV,10,9))+" e Conta: "+Alltrim(SubStr(TRB->CHAV,19,20))+chr(13)+chr(10)+;
				"Valor Solicitado: "+Transform(TRB->NVLTOT,"@E 999,999,999.99")+chr(13)+chr(10)+;
				"Saldo conta     : "+Transform(TRB->NVLCON,"@E 999,999,999.99")+chr(13)+chr(10)+chr(13)+chr(10)
				
				AADD(aInfor,Alltrim(TRB->CCUSTO))
				AADD(aInfor,Alltrim(TRB->CCUSTO)+" / "+Alltrim(TRB->ITEMCO)+" / "+Alltrim(TRB->CLVL)+" / "+Alltrim(TRB->CONTA))
				AADD(aInfor,TRB->NVLTOT)
				AADD(aInfor,"000000")
				AADD(aInfor,TRB->NVLCON)
				AADD(aInfor,TRB->ITEMCO)
				
				AADD(aCab,aInfor)
			Endif
			TRB->(Dbskip())
		Enddo
		cTexto +="Deseja enviar mensagem para gestor do centro de custos?"+chr(13)+chr(10)+"Obs: Solicitações de compra para este centro de custo ficarão bloqueadas atá que se tenha saldo sufiente!"
		If MsgYesNo(cTexto,"Atenção")
			u_Wf161ok(aCab) // email para gesto avisando sobre pedido sem saldo.
		Endif
	Endif	
Endif
oTabTemp:Delete()
Return (lReturn)
