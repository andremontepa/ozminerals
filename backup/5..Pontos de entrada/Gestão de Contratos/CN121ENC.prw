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

	CND->(RECLOCK("CND",.F.))
	CND->CND_PEDIDO := CNE->CNE_PEDIDO
	CND->CND_FORNEC := CXN->CXN_FORNEC
	CND->CND_LJFORN := CXN->CXN_LJFORN
	CND->(MSUNLOCK())

Return Nil
