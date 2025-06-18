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
		//AC9_FILIAL+AC9_CODOBJ+AC9_ENTIDA+AC9_FILENT+AC9_CODENT
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
/*
	CND->(RECLOCK("CND",.F.))
    CND->CND_PEDIDO := CNE->CNE_PEDIDO
	CND->CND_FORNEC := CXN->CXN_FORNEC
    CND->CND_LJFORN := CXN->CXN_LJFORN
	CND->(MSUNLOCK())
*/

fmigrax()

	
RestArea(aArea)

Return Nil


Static Function fmigrax()
	//Local aArea     := GetArea()
	//Local cQuery    := ""
	//Local QbLinha   := chr(13)+chr(10)
	//Local nXi := 0
	Local cDestar := ""
	//Local cQryIns := ""
	Local cNumPed := ""
	Local cNumMed := ""
	Local cItemPed:= ""
//	Local _cEmpDes:= cEmpAnt // CND->CND_XEMPRE
	Local _cFilDes:= cFilAnt // CND->CND_XFILIA
	//Local aLisCmp := {"CH_FILIAL","CH_PEDIDO","CH_FORNECE","CH_LOJA","CH_ITEMPD","CH_ITEM","CH_PERC","CH_CC","CH_ITEMCTA","CH_CLVL","CH_CUSTO1","CH_PROJET","CH_TAREFA"}
	//Local aLisaj7 := {"AJ7_FILIAL","AJ7_PROJET","AJ7_TAREFA","AJ7_NUMPC","AJ7_ITEMPC","AJ7_COD","AJ7_QUANT","AJ7_DESCRI"}

		
	//Rotina específica para GRAVAÇÃO RATEIOS E PROJETOS PEDIDOS DE COMPRAS
	//Julio Martins  -  Mar / 2025


dbSelectArea("CNE")
CNE->(dbSetOrder(04))
//If CNE->(dbSeek(CND->CND_FILIAL + CND->CND_CONTRA + CND->CND_REVISA + CND->CND_NUMERO + CND->CND_NUMMED))
If CNE->(dbSeek(CND->CND_FILIAL + CND->CND_NUMMED))	
		//msgalert("FMIRATEIO ENTROU")

		cNumPed := CNE->CNE_PEDIDO
		cNumMed := CND->CND_NUMMED

	CND->(RECLOCK("CND",.F.))
    CND->CND_PEDIDO := CNE->CNE_PEDIDO
	CND->CND_FORNEC := CXN->CXN_FORNEC
    CND->CND_LJFORN := CXN->CXN_LJFORN
	CND->(MSUNLOCK())

		
	Do While !CNE->(Eof()) .And. alltrim(CNE->CNE_NUMMED)==alltrim(cNumMed)
	//Do While !CNE->(Eof()) .And. CND->CND_FILIAL + CND->CND_CONTRA + CND->CND_REVISA + CND->CND_NUMERO + CND->CND_NUMMED == CNE->CNE_FILIAL + CNE->CNE_CONTRA + CNE->CNE_REVISA + CNE->CNE_NUMERO + CNE->CNE_NUMMED
		dbSelectArea("CNZ")
		CNZ->(dbSetOrder(02))
		If CNZ->(dbSeek(CNE->CNE_FILIAL + CNE->CNE_CONTRA + CNE->CNE_REVISA + CNE->CNE_NUMMED + CNE->CNE_ITEM))
		
				_cCNE_XCC   := CNZ->CNZ_XCC
				_cCNE_XITCT := CNZ->CNZ_XITEM 
				_cCNE_XCLVL := CNZ->CNZ_XCLVL
				_cCNE_PROJET:= CNZ->CNZ_PROJET
				_cCNE_TAREFA:= CNZ->CNZ_TAREFA

				cNumPed := CNE->CNE_PEDIDO
				
				if Empty(_cCNE_XCC)
				_cCNE_XCC   := CNZ->CNZ_CC
				endif

				if Empty(_cCNE_XITCT)
				_cCNE_XITCT := CNZ->CNZ_ITEMCT
				endif

				if Empty(_cCNE_XCLVL)
				_cCNE_XCLVL := CNZ->CNZ_CLVL
				endif
			
			Do While !CNZ->(Eof()) .And. alltrim(CNZ_NUMMED)==alltrim(cNumMed)
			//Do While !CNZ->(Eof()) .And. CNE->CNE_FILIAL + CNE->CNE_CONTRA + CNE->CNE_REVISA + CNE->CNE_NUMMED + CNE->CNE_ITEM 		   == CNZ->CNZ_FILIAL + CNZ->CNZ_CONTRA + CNZ->CNZ_REVISA + CNZ->CNZ_NUMMED + CNZ->CNZ_ITCONT

					cItemPed := Posicione("SC7",4,xFilial("SC7") + CNE->CNE_PRODUT + cNumPed,"C7_ITEM")
					dbSelectArea("SCH")
					SCH->(dbSetOrder(01))
					If SCH->(dbSeek(xFilial("SCH")+cNumPed+CNZ->CNZ_FORNEC+CNZ->CNZ_LJFORN+cItemPed+CNZ->CNZ_ITEM))
					RecLock("SCH",.F.)
						SCH->CH_PROJET := CNZ->CNZ_PROJET
						SCH->CH_TAREFA := CNZ->CNZ_TAREFA
					SCH->(MsUnlock())
					else
						
					RecLock("SCH",.T.)
						SCH->CH_FILIAL := _cFilDes
					    SCH->CH_PEDIDO := Right(Alltrim(cNumPed),06)
						SCH->CH_FORNECE:= CNZ->CNZ_FORNEC
						SCH->CH_LOJA   := CNZ->CNZ_LJFORN
						SCH->CH_ITEMPD := Posicione("SC7",4,xFilial("SC7") + CNE->CNE_PRODUT + cNumPed,"C7_ITEM")
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
	
					cDestar := u_PegaDes()
					cItemPed:= Posicione("SC7",4,xFilial("SC7") + CNE->CNE_PRODUT + cNumPed,"C7_ITEM")

					dbSelectArea("AJ7")
					AJ7->(dbSetOrder(05))
					If AJ7->(dbSeek(xFilial("AJ7")+CNZ->CNZ_PROJET+CNZ->CNZ_TAREFA+Right(Alltrim(cNumPed),06)+Right(Alltrim(cItemPed),04)))
					
					else
					If val(Alltrim(cItemPed))>0
					RecLock("AJ7",.T.)
						AJ7->AJ7_FILIAL := _cFilDes
						AJ7->AJ7_NUMPC  := Right(Alltrim(cNumPed),06)
						AJ7->AJ7_PROJET := CNZ->CNZ_PROJET
						AJ7->AJ7_TAREFA := CNZ->CNZ_TAREFA
						AJ7->AJ7_DESCRI := cDestar
						AJ7->AJ7_ITEMPC := Right(Alltrim(cItemPed),04)
						AJ7->AJ7_COD    := CNE->CNE_PRODUT
						AJ7->AJ7_QUANT  := ((CNZ->CNZ_PERC * CNE->CNE_QUANT)/100)
					//	AJ7->AJ7_ITCONT := CNZ->CNZ_ITCONT
					AJ7->(MsUnlock())
					Endif
					Endif
								
			CNZ->(dbSkip())
			EndDo
		EndIf
		CNE->(dbSkip())
	EndDo
EndIf


Return






	

