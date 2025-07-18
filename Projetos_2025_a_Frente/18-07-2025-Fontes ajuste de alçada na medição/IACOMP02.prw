#include 'protheus.ch'
#include 'parmtype.ch'
//-------------------------------------------------------------------------------
/* {Protheus.doc} IACOMP02
Programa - Estorno de Medição / Pedido de Compras
Copyright I AGE© - Inteligência Andrews
@author Felipe Andrews de Almeida
@since 01/2021
@version Lobo Guara v.12.1.23
*/
//-------------------------------------------------------------------------------
user function IACOMP02()
	Local aGetAre := GetArea()
	Local aCN9Are := CN9->(GetArea())
	Local aCNDAre := CND->(GetArea())
	Local aSC7Are := SC7->(GetArea())
	Local cNumPed := CND->CND_PEDIDO
	Local _cEmpDes := CND->CND_XEMPRE
	Local _cFilDes := CND->CND_XFILIA

	dbSelectArea("CN9")
	CN9->(dbSetOrder(01))
	CN9->(dbSeek(CND->CND_FILIAL + CND->CND_CONTRA + CND->CND_REVISA))
	If CN9->CN9_XGLOBA == "N"
	      cNumped := "N"+substring(cNumped,2,5)
		If !fChkMov(cNumPed,_cEmpDes,_cFilDes)
			MsgStop("Pedido já com movimentação na Empresa/Filial destino. Verifique!")
			Return
		EndIf

		//Restaura codigo do pedido na CND
		dbSelectArea("CND")
		If CND->(RecLock("CND",.F.))
			CND->CND_PEDIDO := "0" + Right(Alltrim(CND->CND_PEDIDO),05)
			CND->(MsUnlock())
		EndIf

		//restaura pedido na SC7
		cQryIns := "UPDATE " + RetSqlName("SC7") + " SET D_E_L_E_T_ = '' WHERE C7_FILIAL = '" + CND->CND_FILIAL + "' AND C7_NUM =  '" + Left(CND->CND_PEDIDO,06) + "' "
		TCSqlExec(cQryIns)
		cQryIns := ""

		CN120Estor("CND",CND->(Recno()),07)

		dbSelectArea("SC7")
		SC7->(dbSetOrder(01))
		If SC7->(dbSeek(CND->CND_FILIAL + CND->CND_PEDIDO)) //se achou pedido foi porque nao concluiu o estorno
			//restaura pedido na SC7
			cQryIns := "UPDATE " + RetSqlName("SC7") + " SET D_E_L_E_T_ = '*' WHERE C7_FILIAL = '" + CND->CND_FILIAL + "' AND C7_NUM =  '" + Left(CND->CND_PEDIDO,06) + "' "
			TCSqlExec(cQryIns)
			cQryIns := ""

			//restaura codigo do pedido na CND
			dbSelectArea("CND")
			If CND->(RecLock("CND",.F.))
				CND->CND_PEDIDO := "N" + Right(Alltrim(CND->CND_PEDIDO),05)
				CND->(MsUnlock())
			EndIf
		Else
			//deleta pedido na SC7 destino
			cQryIns := "UPDATE SC7" + _cEmpDes + "0 SET D_E_L_E_T_ = '*' WHERE C7_FILIAL = '" + _cFilDes + "' AND C7_NUM =  '" + Alltrim(cNumPed) + "' "
			TCSqlExec(cQryIns)
			cQryIns := ""

			//deleta alcada do pedido na SCR destino
			cQryIns := "UPDATE SCR" + _cEmpDes + "0 SET D_E_L_E_T_ = '*' WHERE CR_FILIAL = '" + _cFilDes + "' AND CR_NUM =  '" + Alltrim(cNumPed) + "' "
			TCSqlExec(cQryIns)
			cQryIns := ""
		EndIf
	Else
		MsgStop("Essa funcionalidade é exclusiva para pedidos configurados como tipo Global. Verifique!")
	EndIf

	RestArea(aSC7Are)
	RestArea(aCNDAre)
	RestArea(aCN9Are)
	RestArea(aGetAre)

return

Static Function fChkMov(cNumPed,_cEmpDes,_cFilDes)
	Local cQrySql := "" //Variavel na qual é armazenado a query de consulta ao banco
	Local lRetVld := .T.

	_cEmpDes:= AllTrim(_cEmpDes)
	_cEmpDes:=Iif(Len(_cEmpDes)>1,Substr(_cEmpDes,2,1),_cEmpDes)

	cQrySql += " SELECT COUNT(SC7.C7_NUM) AS C7_QTDREG "
	cQrySql += " FROM SC70" + (_cEmpDes) + "0 SC7 "
	cQrySql += " WHERE SC7.C7_FILIAL = '" + _cFilDes + "' "
	cQrySql += " AND   SC7.C7_NUM    = '" + cNumPed + "' "
	cQrySql += " AND ( SC7.C7_QTDACLA > 0 OR SC7.C7_ENCER =  'E' ) "
	cQrySql += " AND   SC7.D_E_L_E_T_ <> '*' "

	fCloseArea("IATRB")
	dbUseArea(.T., "TOPCONN",TCGenQry(,,cQrySql),"IATRB",.T., .T.)

	dbSelectArea("IATRB")
	IATRB->(dbGoTop())

	If IATRB->C7_QTDREG > 0
		lRetVld := .F.
	EndIf

Return(lRetVld)

Static Function fCloseArea(pCodTab)

	If (Select(pCodTab)!= 0)
		dbSelectArea(pCodTab)
		dbCloseArea()
		If File(pCodTab+GetDBExtension())
			FErase(pCodTab+GetDBExtension())
		EndIf
	EndIf

Return
