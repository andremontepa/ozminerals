#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} CN121ENC
CN121ENC - Realizar operações ao final do processo de encerramento da Medição.
@type function
@author Ricardo Tavares Ferreira
@since 25/04/2022
@obs Possibilita ao desenvolvedor realizar operações após o encerramento da medição.
Executado uma vez ao fim do encerramento ainda dentro da transação e mais uma vez após o fim da transação.
@version 12.1.33
@history 25/04/2022, Ricardo Tavares Ferreira, Construção Inicial
/*/
//=============================================================================================================================
User Function CN121ENC()
//=============================================================================================================================
	Local aArea     := GetArea()
	Local cQuery    := ""
	Local QbLinha   := chr(13)+chr(10)
	
	cQuery := "	SELECT "+QbLinha
	cQuery += "	AC9_CODOBJ "+QbLinha
	cQuery += "	FROM "
	cQuery += RetSqlName("AC9") + " AC9 "+QbLinha
	cQuery += "	WHERE AC9_ENTIDA = 'CND'"+QbLinha
	cQuery += "	AND AC9_CODENT = '"+FWXFilial("CND") + CND->CND_CONTRA + CND->CND_REVISA + CND->CND_NUMMED+"'"+QbLinha
	cQuery += "	AND D_E_L_E_T_ = ' ' "+QbLinha

	If SELECT("TRBAC9") > 0
		TRBAC9->(DbCloseArea())
	Endif

	dbUseArea(.T.,"TOPCONN", TcGenQry(,,cQuery),"TRBAC9",.T.,.T.)
	DbSelectArea("TRBAC9")
	TRBAC9->(dbGoTop())
	Do While TRBAC9->(!Eof())
		
		If !AC9->(DBSEEK(xFilial( "AC9" )+TRBAC9->AC9_CODOBJ+"SC7"+xFilial( "SC7" )+xFilial( "SC7" ) + SC7->C7_NUM + "0001"))
			RecLock( "AC9", .T. )
			AC9->AC9_FILIAL := xFilial( "AC9" )
			AC9->AC9_FILENT := xFilial( "SC7" )
			AC9->AC9_ENTIDA := "SC7"
			AC9->AC9_CODENT := xFilial( "SC7" ) + SC7->C7_NUM + "0001"
			AC9->AC9_CODOBJ := TRBAC9->AC9_CODOBJ
			AC9->(MsUnLock()) // Confirma e finaliza a operação
		EndIf
		dbSelectArea("TRBAC9")
		TRBAC9->(dbSkip())
	EndDo

	RestArea(aArea)

fmigrax()

	
RestArea(aArea)

Return Nil


Static Function fmigrax()
	Local cDestar := ""
	Local cNumPed := ""
	Local cNumMed := ""
	Local cItemPed:= ""
	Local _cFilDes:= cFilAnt // CND->CND_XFILIA
			
	//Rotina específica para GRAVAÇÃO RATEIOS E PROJETOS PEDIDOS DE COMPRAS
	//Julio Martins  -  Mar / 2025

dbSelectArea("CNE")
CNE->(dbSetOrder(04))

If CNE->(dbSeek(CND->CND_FILIAL + CND->CND_NUMMED))	

	cNumPed := CND->CND_PEDIDO
	cNumMed := CND->CND_NUMMED

	CND->(RECLOCK("CND",.F.))
    CND->CND_PEDIDO := CNE->CNE_PEDIDO
	CND->CND_FORNEC := CXN->CXN_FORNEC
    CND->CND_LJFORN := CXN->CXN_LJFORN
	CND->(MSUNLOCK())
		
	Do While !CNE->(Eof()) .And. alltrim(CNE->CNE_NUMMED)==alltrim(cNumMed)

	if !Empty(cNumPed)
		// Pesquisa Item do Pedido de Compras
		// Filial + Pedido + Item + Sequência
		dbSelectArea("SC7")
		dbSetOrder(1)
		dbGoTop()
		dbSeek(CNE->CNE_FILIAL + cNumPed + "0001" + space(4))
		Do While !SC7->(Eof()) .And. SC7->C7_NUM=cNumped
			if SC7->C7_NUM==cNumPed .and. SC7->C7_CONTRA == CNE->CNE_CONTRA .and. alltrim(SC7->C7_CONTREV)==alltrim(CNE->CNE_REVISA) .and. alltrim(SC7->C7_MEDICAO)==alltrim(CNE->CNE_NUMMED) .and. alltrim(SC7->C7_ITEMED)==alltrim(CNE->CNE_ITEM)
			cItemPed :=SC7->C7_ITEM  // Pega o Item do Pedido x a Medição
			Exit
			Endif
			SC7->(dbSkip())
        Enddo

		dbSelectArea("CNZ")
		dbSetOrder(08)
		dbGoTop()
		//
		
		// Verifica Rateios na CNZ - Se existir grava na SCH
		If CNZ->(dbSeek(CNE->CNE_FILIAL + CNE->CNE_CONTRA + cNumMed + CNE->CNE_ITEM ))
					 
			Do While !CNZ->(Eof()) .And. alltrim(CNZ_NUMMED)==alltrim(cNumMed)
			if !Empty(cNumPed)
					
					dbSelectArea("SCH")
					SCH->(dbSetOrder(01))
					If SCH->(dbSeek(xFilial("SCH")+cNumPed+CNZ->CNZ_FORNEC+CNZ->CNZ_LJFORN+Alltrim(cItemPed)+CNZ->CNZ_ITEM))
						RecLock("SCH",.F.)
						SCH->CH_PERC   := CNZ->CNZ_PERC
						SCH->CH_CC     := CNZ->CNZ_CC
						SCH->CH_ITEMCTA:= CNZ->CNZ_ITEMCT
						SCH->CH_CLVL   := CNZ->CNZ_CLVL
						SCH->CH_CUSTO1 := CNZ->CNZ_VALOR1
						SCH->CH_PROJET := CNZ->CNZ_PROJET
						SCH->CH_TAREFA := CNZ->CNZ_TAREFA
						SCH->(MsUnlock())
					else
						RecLock("SCH",.T.)
						SCH->CH_FILIAL := _cFilDes
					    SCH->CH_PEDIDO := Alltrim(cNumPed)
						SCH->CH_FORNECE:= CNZ->CNZ_FORNEC
						SCH->CH_LOJA   := CNZ->CNZ_LJFORN
						SCH->CH_ITEMPD := Alltrim(cItemPed)
						SCH->CH_ITEM   := CNZ->CNZ_ITEM
						SCH->CH_PERC   := CNZ->CNZ_PERC
						SCH->CH_CC     := CNZ->CNZ_CC
						SCH->CH_ITEMCTA:= CNZ->CNZ_ITEMCT
						SCH->CH_CLVL   := CNZ->CNZ_CLVL
						SCH->CH_CUSTO1 := CNZ->CNZ_VALOR1
						SCH->CH_PROJET := CNZ->CNZ_PROJET
						SCH->CH_TAREFA := CNZ->CNZ_TAREFA
						SCH->(MsUnlock())
					Endif


					If !Empty(CNZ->CNZ_PROJET)  // Verifica se Tem Projeto / Tarefa nao Item
						cDestar := u_PegaDes()
					
						dbSelectArea("AJ7")
						AJ7->(dbSetOrder(05))
						If AJ7->(dbSeek(xFilial("AJ7")+CNZ->CNZ_PROJET+CNZ->CNZ_TAREFA+Alltrim(cNumPed)+Alltrim(cItemPed)))
						RecLock("AJ7",.F.)
						AJ7->AJ7_QUANT  := ((CNZ->CNZ_PERC * CNE->CNE_QUANT)/100)
						AJ7->AJ7_PROJET := CNZ->CNZ_PROJET
						AJ7->AJ7_TAREFA := CNZ->CNZ_TAREFA
						AJ7->AJ7_DESCRI := cDestar
						AJ7->(MsUnlock())
						else
						RecLock("AJ7",.T.)
						AJ7->AJ7_FILIAL := _cFilDes
						AJ7->AJ7_NUMPC  := Alltrim(cNumPed)
						AJ7->AJ7_PROJET := CNZ->CNZ_PROJET
						AJ7->AJ7_TAREFA := CNZ->CNZ_TAREFA
						AJ7->AJ7_DESCRI := cDestar
						AJ7->AJ7_ITEMPC := Alltrim(cItemPed)
						AJ7->AJ7_COD    := CNE->CNE_PRODUT
						AJ7->AJ7_QUANT  := ((CNZ->CNZ_PERC * CNE->CNE_QUANT)/100)
						AJ7->(MsUnlock())
						Endif
					Endif
			Endif					
			CNZ->(dbSkip())
			EndDo

		// Grava os Rateios Conforme o Item da Medição - Tabela CNE
		Else
					
			If !Empty(cNumPed)
					dbSelectArea("SCH")
					SCH->(dbSetOrder(01))
					If SCH->(dbSeek(xFilial("SCH")+cNumPed+SC7->C7_FORNECE+SC7->C7_LOJA+cItemPed+Substring(cItemPed,3,2)))
						RecLock("SCH",.F.)
						SCH->CH_PERC   := 100
						SCH->CH_CC     := CNE->CNE_CC
						SCH->CH_ITEMCTA:= CNE->CNE_ITEMCT
						SCH->CH_CLVL   := CNE->CNE_CLVL
						SCH->CH_CUSTO1 := CNE->CNE_VLTOT
						SCH->CH_PROJET := CNE->CNE_PROJET
						SCH->CH_TAREFA := CNE->CNE_TAREFA
						SCH->(MsUnlock())
					else
						RecLock("SCH",.T.)
						SCH->CH_FILIAL := _cFilDes
					    SCH->CH_PEDIDO := Alltrim(cNumPed)
						SCH->CH_FORNECE:= SC7->C7_FORNECE
						SCH->CH_LOJA   := SC7->C7_LOJA
						SCH->CH_ITEMPD := Alltrim(cItemPed)
						SCH->CH_ITEM   := "01"
						SCH->CH_PERC   := 100
						SCH->CH_CC     := CNE->CNE_CC
						SCH->CH_ITEMCTA:= CNE->CNE_ITEMCT
						SCH->CH_CLVL   := CNE->CNE_CLVL
						SCH->CH_CUSTO1 := CNE->CNE_VLTOT
						SCH->CH_PROJET := CNE->CNE_PROJET
						SCH->CH_TAREFA := CNE->CNE_TAREFA
						SCH->(MsUnlock())
					Endif
	
				//	If !Empty(CNE->CNE_PROJET)  // Verifica se Tem Projeto / Tarefa nao Item
					cDestar := u_PegaDes()
						dbSelectArea("AJ7")
						AJ7->(dbSetOrder(05))
						If AJ7->(dbSeek(xFilial("AJ7")+CNE->CNE_PROJET+CNE->CNE_TAREFA+Alltrim(cNumPed)+Alltrim(cItemPed)))
						RecLock("AJ7",.F.)
						AJ7->AJ7_QUANT  := CNE->CNE_QUANT
						AJ7->AJ7_PROJET := CNE->CNE_PROJET
						AJ7->AJ7_TAREFA := CNE->CNE_TAREFA
						AJ7->AJ7_DESCRI := cDestar
						AJ7->(MsUnlock())
						else
						RecLock("AJ7",.T.)
						AJ7->AJ7_FILIAL := _cFilDes
						AJ7->AJ7_NUMPC  := Alltrim(cNumPed)
						AJ7->AJ7_PROJET := CNE->CNE_PROJET
						AJ7->AJ7_TAREFA := CNE->CNE_TAREFA
						AJ7->AJ7_DESCRI := cDestar
						AJ7->AJ7_ITEMPC :=Alltrim(cItemPed)
						AJ7->AJ7_COD    := CNE->CNE_PRODUT
						AJ7->AJ7_QUANT  := CNE->CNE_QUANT
						AJ7->(MsUnlock())
					Endif
				//	Endif
			Endif

		EndIf
	Endif
		CNE->(dbSkip())
	EndDo
EndIf
Return






	

