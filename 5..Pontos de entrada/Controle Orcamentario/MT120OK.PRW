#include "rwmake.ch"
#include "fileio.ch"
#include "TbiConn.ch"
#include "TbiCode.ch"
#include "protheus.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MT120OK   ºAutor  ³Ismael Junior       º Data ³  07/09/17   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ponto de entrada que valida os itens do pedido             º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function  MT120OK()
//Local nPosPed  := aScan(aHeader,{|x| AllTrim(x[2]) == 'C7_NUM'})
Local nPosPrd  := aScan(aHeader,{|x| AllTrim(x[2]) == 'C7_PRODUTO'})
Local nPosCC   := aScan(aHeader,{|x| AllTrim(x[2]) == 'C7_CC'})      // ISMAEL
Local nPosItc  := aScan(aHeader,{|x| AllTrim(x[2]) == 'C7_ITEMCTA'}) // ISMAEL
Local nPosClv  := aScan(aHeader,{|x| AllTrim(x[2]) == 'C7_CLVL'})   // ISMAEL  
Local nPosCon  := aScan(aHeader,{|x| AllTrim(x[2]) == 'C7_CONTA'})   // ISMAEL  
Local nPosTot  := aScan(aHeader,{|x| AllTrim(x[2]) == 'C7_TOTAL'})   // ISMAEL
//Local nPosItem := aScan(aHeader,{|x| AllTrim(x[2]) == 'C7_ITEM'})
Local nPosBloq := aScan(aHeader,{|x| AllTrim(x[2]) == 'C7_XBLQSAL'}) // ismael  C7_OPER
//Local nPosOper := aScan(aHeader,{|x| AllTrim(x[2]) == 'C7_OPER'})
//Local nPosApli := aScan(aHeader,{|x| AllTrim(x[2]) == 'C7_XTPAPL'}) // TIPO APLICAÇÃO DIRETA OU INDIRETA
Local nUsado  := Len(aHeader) // ismael
//Local lValida  := .T.
Local nX       := 0
Local _lRet    := .T.
//Local cVldItm
Local nValPed  := 0
Local cProd    := ""
Local cNumPed  := CA120NUM
Local cAno     := Alltrim(Str(Year(Date())))
Local _cCusto  := _cItemco := _cConta  := _cClvl := ""
Local cTexto   := ""
Local cMes     := Month2Str(Date())
Local cCodUser := RetCodUsr() //Retorna o Codigo do Usuario
Local cNamUser := UsrRetName( cCodUser )//Retorna o nome do usuario
Local nVlSaldo := 0
Local nZw3Val  := 0
Local aCab     := {}
Local aInfor   := {}
Local lRetWZ3  := .T.
Local oTabTemp	:= Nil 
Private aCampos:={ {"CHAV" ,"C", 38,0},;
{"BLOQ" ,"C",1,0},;
{"CCUSTO" ,"C",9,0},;
{"ITEMCO" ,"C",9,0},;
{"CLVL" ,"C",20,0},;
{"CONTA" ,"C",20,0},;
{"NVLTOT","N",14,2},;
{"NVLCON","N",14,2},;
{"CONTROLA" ,"C",1,0}}  // campos da tabela temporária

If Select("TRBGR")> 0
	TRBGR->(DbCloseArea())
Endif

oTabTemp := FWTemporaryTable():New("TRBGR", aCampos)
oTabTemp:AddIndex("1",{"CHAV","CCUSTO","ITEMCO"})
oTabTemp:Create()

For nX :=1 To Len( aCols )
	If ( !aCols[n][nUsado+1] )
		cProd   := Alltrim(aCols[nX][nPosPrd])
		//cConta  := Alltrim(aCols[nX][nPosCon])
		aCols[nX][nPosBloq] := "N"
/*	DbSelectArea("SB1")
	SB1->(DbSetOrder(1))
	If !(DbSeek(xFilial("SB1")+cProd))  
   		aCols[nX][nPosApli] := SB1->B1_APROPRI
   	Endif */
   			 
		//POSICIONA NA CLASSE DO CENTRO DE CUSTO
 /*		_cClass := POSICIONE("CTT",1,XFILIAL("CTT")+aCols[nX][nPosCC],"CTT_CLASCC")
		DbSelectArea("SB1")
		SB1->(DbSetOrder(1))
		SB1->(DbSeek(xfilial("SB1")+cProd))
		// VERIFICICA TIPO DE OPERAÇÃO
		If Alltrim(aCols[nX][nPosOper])='51'
			cConta := SB1->B1_CONTA
		Else
			If _cClass ='1'
				cConta := SB1->B1_CTAATIV
			ElseIf _cClass ='2'
				cConta := SB1->B1_CTACUST
			ElseIf _cClass ='3'
				cConta := SB1->B1_CTADESP
			Endif
		Endif  */
		//aCols[nX][nPosCon] := cConta
/*		cQuery := " SELECT ZW2_PREANO-ZW2_VLANO VLSALDO, ZW2_BLOQ FROM "+RetSqlName("ZW2")+" ZW2 "
		cQuery += " WHERE ZW2_CCUSTO = '"+aCols[nX][nPosCC]+"' "
		cQuery += " AND ZW2_ITEMCO = '"+aCols[nX][nPosItc]+"' "
		cQuery += " AND ZW2_CLVL = '"+cConta+"' "
		cQuery += " AND ZW2_ANO = '"+cAno+"' "
		cQuery += " AND ZW2.D_E_L_E_T_ != '*' "  */
		cQuery := " SELECT SUM(ZW2_PREANO)-SUM(ZW2_VLANO) VLSALDO, ZW2_BLOQ FROM "+RetSqlName("ZW2")+" ZW2 "
		cQuery += " WHERE ZW2_CCUSTO = '"+aCols[nX][nPosCC]+"' "
		cQuery += " AND ZW2_ITEMCO = '"+aCols[nX][nPosItc]+"' "
		cQuery += " AND ZW2_CLVL = '"+aCols[nX][nPosClv]+"' "
		cQuery += " AND ZW2_CONTA = '"+aCols[nX][nPosCon]+"' "
		cQuery += " AND ZW2_ANO = '"+cAno+"' "
		cQuery += " AND ZW2_VLANO >= 0 "
		//cQuery += " AND ZW2_FILIAL = '"+xFilial("ZW2")+"' "
		cQuery += " AND ZW2.D_E_L_E_T_ != '*' " 
		cQuery += " GROUP BY ZW2_BLOQ "  		
		
		If SELECT("TRA") > 0
			("TRA")->(DbCloseArea())
		Endif
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRA",.T.,.T.)
		
                        //Inicio ***************** 06/04/2020 verifica se bloqueia sim ou não ****************
						cQrybloq := " SELECT ZW2_BLOQ FROM "+RetSqlName("ZW2")+" ZW2 "
						cQrybloq += " WHERE ZW2_CCUSTO = '"+aCols[nX][nPosCC]+"' "
						cQrybloq += " AND ZW2_ITEMCO = '"+aCols[nX][nPosItc]+"' "
						cQrybloq += " AND ZW2_CLVL = '"+aCols[nX][nPosClv]+"' "
						cQrybloq += " AND ZW2_CONTA = '"+aCols[nX][nPosCon]+"' "
						cQrybloq += " AND ZW2_ANO = '"+cAno+"' "
						cQrybloq += " AND ZW2.D_E_L_E_T_ != '*' " 						
							
						If SELECT("TRD") > 0
							TRD->(DbCloseArea())
						Endif
						dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQrybloq),"TRD",.T.,.T.)
						//Fim ***************************************************************************		
		
		If _cCusto+_cItemco+_cConta <> aCols[nX][nPosCC] + aCols[nX][nPosItc] + aCols[nX][nPosCon]
			nValPed := 0
			nValPed := aCols[nX][nPosTot]
			_cCusto  := aCols[nX][nPosCC]
			_cItemco := aCols[nX][nPosItc]
			_cClvl   := aCols[nX][nPosClv]
			_cConta  := aCols[nX][nPosCon]
		Else
			nValPed := nValPed + aCols[nX][nPosTot]
		Endif
		dbSelectArea("TRBGR")
		cChave := aCols[nX][nPosCC] + aCols[nX][nPosItc] + aCols[nX][nPosClv] + aCols[nX][nPosCon]
		nVlSaldo := TRA->VLSALDO 
		cControla := TRD->ZW2_BLOQ
		TRBGR->(dbSeek(cChave))
		IF EOF()
			reclock("TRBGR",.T.)
			TRBGR->CHAV       := cChave
			TRBGR->NVLTOT     := nValPed
			TRBGR->NVLCON     := nVlSaldo
			TRBGR->CCUSTO     := aCols[nX][nPosCC]
			TRBGR->ITEMCO     := aCols[nX][nPosItc]
			TRBGR->CLVL       := aCols[nX][nPosClv]
			TRBGR->CONTA      := aCols[nX][nPosCon]
			TRBGR->CONTROLA	:= cControla
		ELSE
			reclock("TRBGR",.F.)
			TRBGR->NVLTOT     := nValPed
			TRBGR->NVLCON     := nVlSaldo
		ENDIF
	Endif
Next nX
TRBGR->(DbGoTop())
While TRBGR->(!EOF())
	nVlPed  := TRBGR->NVLTOT
	nVlCont := TRBGR->NVLCON
	cControl := TRBGR->CONTROLA
	//verificar se já foi lançado informação para o pedido
	DbSelectArea("ZW3")
	ZW3->(DbSetOrder(3))
	If ZW3->(DbSeek(xfilial("ZW3")+cNumPed+TRBGR->CCUSTO+TRBGR->ITEMCO+TRBGR->CLVL+TRBGR->CONTA+cAno))
		If ZW3->ZW3_VALOR > TRBGR->NVLTOT
			nVlZw3 := ZW3->ZW3_VALOR - TRBGR->NVLTOT
			nVlCont := nVlCont + nVlZw3
		Elseif ZW3->ZW3_VALOR < TRBGR->NVLTOT
			nVlZw3 := TRBGR->NVLTOT - ZW3->ZW3_VALOR
			nVlCont := nVlCont - nVlZw3
		Else
			lRetWZ3 := .F.
		Endif
		lAlt := .T.
	Endif
	If cControl = 'S' // Sinaliza que a flag de controle para centro de custo esta desativada para bloqueio	
		If lRetWZ3
			nValTot := nVlCont - nVlPed
			If nValTot < 0
				_lRet := .F.
				reclock("TRBGR",.F.)
				TRBGR->BLOQ := "B"
			Endif
		Endif
	Endif	
	TRBGR->(Dbskip())
Enddo
If !_lRet
	TRBGR->(DbGoTop())
	While TRBGR->(!EOF())
		If !Empty(TRBGR->BLOQ)
			cTexto +="Saldo da conta insuficiente!"+chr(13)+chr(10)
			cTexto +="Centro de Custo: "+Alltrim(SubStr(TRBGR->CHAV,1,9))+", Item: "+Alltrim(SubStr(TRBGR->CHAV,10,9))+" e Conta: "+Alltrim(SubStr(TRBGR->CHAV,19,20))+chr(13)+chr(10)+;
			"Valor Solicitado: "+Transform(TRBGR->NVLTOT,"@E 999,999,999.99")+chr(13)+chr(10)+;
			"Saldo conta     : "+Transform(TRBGR->NVLCON,"@E 999,999,999.99")+chr(13)+chr(10)+chr(13)+chr(10)
			
			AADD(aInfor,Alltrim(TRBGR->CCUSTO))
			AADD(aInfor,Alltrim(TRBGR->CCUSTO)+" / "+Alltrim(TRBGR->ITEMCO)+" / "+Alltrim(TRBGR->CLVL)+" / "+Alltrim(TRBGR->CONTA))
			AADD(aInfor,TRBGR->NVLTOT)
			AADD(aInfor,cNumPed)
			AADD(aInfor,TRBGR->NVLCON)
			AADD(aInfor,TRBGR->ITEMCO)
			
			AADD(aCab,aInfor)
		Endif
		TRBGR->(Dbskip())
	Enddo
	cTexto +="O pedido não pode ser gerado pois não tenha saldo sufiente!"+chr(13)+chr(10)+"Obs: Deseja Enviar um E-mail para o Gestor do centro de custos?"
	
	If IsBlind()
		Return .F. 
	Else
		If MsgYesNo(cTexto,"Atenção")
			/*_lRet := .T.
			For nX :=1 To Len( aCols )
				aCols[nX][nPosBloq] := "S"
			Next nX   */
			u_Wf120ok(aCab) // email para gesto avisando sobre pedido sem saldo.
			//_lRet := .F.
		Endif
	Endif
Else
	TRBGR->(DbGoTop())
	While TRBGR->(!EOF())
		If TRBGR->BLOQ <> "B"
			//verificar se já foi lançado informação para o pedido
			DbSelectArea("ZW3")
			ZW3->(DbSetOrder(3))
			If ZW3->(DbSeek(xfilial("ZW3")+cNumPed+TRBGR->CCUSTO+TRBGR->ITEMCO+TRBGR->CLVL+TRBGR->CONTA+cAno))
				cQuery := " SELECT SUM(ZW3_VALOR) DEBITO, "
				cQuery += " CREDITO = (SELECT SUM(ZW3_VALOR) FROM "+RetSqlName("ZW3")+" ZW3 WHERE ZW3_NUMPED = '"+cNumPed+"' "
				cQuery += " AND ZW3_CCUSTO = '"+Alltrim(TRBGR->CCUSTO)+"' "
				cQuery += " AND ZW3_ITEMCO = '"+Alltrim(TRBGR->ITEMCO)+"' "
				cQuery += " AND ZW3_CLVL = '"+Alltrim(TRBGR->CLVL)+"' "
				cQuery += " AND ZW3_CONTA = '"+Alltrim(TRBGR->CONTA)+"' "
				cQuery += " AND ZW3_ANO = '"+cAno+"' "
				cQuery += " AND ZW3_TIPO = 'C') "
				cQuery += " FROM "+RetSqlName("ZW3")+" ZW3 "
				cQuery += " WHERE ZW3_NUMPED = '"+cNumPed+"' "
				cQuery += " AND ZW3_CCUSTO = '"+Alltrim(TRBGR->CCUSTO)+"' "
				cQuery += " AND ZW3_ITEMCO = '"+Alltrim(TRBGR->ITEMCO)+"' "
				cQuery += " AND ZW3_CLVL = '"+Alltrim(TRBGR->CLVL)+"' "
				cQuery += " AND ZW3_CONTA = '"+Alltrim(TRBGR->CONTA)+"' "
				cQuery += " AND ZW3_ANO = '"+cAno+"' "
				cQuery += " AND ZW3_TIPO = 'D' "
				
				If SELECT("TRC") > 0
					("TRC")->(DbCloseArea())
				Endif
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRC",.T.,.T.)
				nZw3Val := TRC->DEBITO - TRC->CREDITO
				If nZw3Val > TRBGR->NVLTOT
					nVlZw3 := nZw3Val - TRBGR->NVLTOT
					cOpera := "-"
					cDebCred := "C"
				Elseif nZw3Val < TRBGR->NVLTOT
					nVlZw3 := TRBGR->NVLTOT - nZw3Val
					cOpera := "+"
					cDebCred := "D"
				Else
					nVlZw3 := 0
				Endif
				If nVlZw3 > 0    //0001
					cUpdate:= " UPDATE " + RetSqlName("ZW2")+" SET ZW2_VAL"+cMes+"=ZW2_VAL"+cMes+cOpera+Alltrim(Str(nVlZw3))+" ,ZW2_VLANO=ZW2_VLANO"+cOpera+Alltrim(Str(nVlZw3))
					cUpdate+= " WHERE ZW2_CCUSTO = '"+Alltrim(TRBGR->CCUSTO)+"' "
					cUpdate+= " AND ZW2_ITEMCO = '"+Alltrim(TRBGR->ITEMCO)+"' "
					cUpdate+= " AND ZW2_CLVL = '"+Alltrim(TRBGR->CLVL)+"' "
					cUpdate+= " AND ZW2_CONTA = '"+Alltrim(TRBGR->CONTA)+"' "
					cUpdate+= " AND ZW2_ANO = '"+cAno+"' " 
					cUpdate+= " AND ZW2_FILIAL = '"+xFilial("ZW2")+"' "
					cUpdate+= " AND D_E_L_E_T_ != '*' "
					nFlag := TcSqlExec(cUpdate)
					
					RecLock("ZW3",.T.)
					ZW3->ZW3_FILIAL := XFILIAL("ZW3")
					ZW3->ZW3_NUM    := GETSX8NUM("ZW3","ZW3_NUM")
					ZW3->ZW3_TIPO   := cDebCred
					ZW3->ZW3_CCUSTO := TRBGR->CCUSTO
					ZW3->ZW3_ITEMCO := TRBGR->ITEMCO
					ZW3->ZW3_ANO    := cAno
					ZW3->ZW3_CLVL   := TRBGR->CLVL
					ZW3->ZW3_CONTA  := TRBGR->CONTA
					ZW3->ZW3_DATA   := Date()
					ZW3->ZW3_VALOR  := nVlZw3
					ZW3->ZW3_ORIGEM := "Pedido de compra"
					ZW3->ZW3_USUARI := cNamUser
					ZW3->ZW3_NUMPED := cNumPed
					ZW3->ZW3_HISTOR := "Valor ref. alteração do pedido: "+cNumPed
					ZW3->(MsUnLock())
					ConfirmSX8()
				Endif
			Else
				nVlpTot := TRBGR->NVLTOT   // ZW2_VAL"+cMes+"=ZW2_VAL"+cMes+cOpera+Alltrim(Str(nVlZw3))+"
				cUpdate:= " UPDATE " + RetSqlName("ZW2")+" SET ZW2_VAL"+cMes+"=ZW2_VAL"+cMes+"+"+Alltrim(Str(nVlpTot))+" ,ZW2_VLANO = ZW2_VLANO+"+Alltrim(Str(nVlpTot))
				cUpdate+= " WHERE ZW2_CCUSTO = '"+Alltrim(TRBGR->CCUSTO)+"' "
				cUpdate+= " AND ZW2_ITEMCO = '"+Alltrim(TRBGR->ITEMCO)+"' "
				cUpdate+= " AND ZW2_CLVL = '"+Alltrim(TRBGR->CLVL)+"' "
				cUpdate+= " AND ZW2_CONTA = '"+Alltrim(TRBGR->CONTA)+"' "
				cUpdate+= " AND ZW2_ANO = '"+cAno+"' "
			   	cUpdate+= " AND ZW2_FILIAL = '"+xFilial("ZW2")+"' "
				cUpdate+= " AND D_E_L_E_T_ != '*' "
				nFlag := TcSqlExec(cUpdate)
				
				DbSelectArea("ZW3")
				ZW3->(DbSetOrder(2))
				RecLock("ZW3",.T.)
				ZW3->ZW3_FILIAL := XFILIAL("ZW3")
				ZW3->ZW3_NUM    := GETSX8NUM("ZW3","ZW3_NUM")
				ZW3->ZW3_TIPO   := "D"
				ZW3->ZW3_CCUSTO := TRBGR->CCUSTO
				ZW3->ZW3_ITEMCO := TRBGR->ITEMCO
				ZW3->ZW3_ANO    := cAno
				ZW3->ZW3_CLVL  := TRBGR->CLVL
				ZW3->ZW3_CONTA  := TRBGR->CONTA
				ZW3->ZW3_DATA   := Date()
				ZW3->ZW3_VALOR  := TRBGR->NVLTOT
				ZW3->ZW3_ORIGEM := "Pedido de compra"
				ZW3->ZW3_USUARI := cNamUser
				ZW3->ZW3_NUMPED := cNumPed
				ZW3->ZW3_HISTOR := "Valor ref. pedido: "+cNumPed
				ZW3->(MsUnLock())
				ConfirmSX8()
			Endif
		Endif
		TRBGR->(Dbskip())
	Enddo
Endif

oTabTemp:Delete()
Return(_lRet)

