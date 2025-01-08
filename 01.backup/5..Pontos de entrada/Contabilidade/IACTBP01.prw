#include 'protheus.ch'
/*  IACTBP01
    Desenvolvedor: Felipe Andrews
    Processo: Faz a apuração de lançamentos contabeis consolidado por filial
    Data: 31/01/2022
    Release: 12.1.25
*/
User Function IACTBP01()
	Local cDtaLan := DTOS(dDataLanc)
	Local cQry := ""
	Local cMsg := "Já existe lançamento de Apuração do CTA para o mês informado!"+ Chr(13) + Chr(10)+"Efetue a exclusão do Lote para possibilitar nova inclusão"

    // Verifica se já existe lançamento de CTA para o mês informado
	cQry := "SELECT * FROM "+RetSqlName("CT2")+" CT2 "
	cQry += "WHERE CT2_DATA BETWEEN "+DTOS(FirstDate(dDataLanc))+" AND "+DTOS(LastDate(dDataLanc))+" AND CT2.D_E_L_E_T_ <> '*' AND CT2_LOTE = 'APUCTA' "
	fCloseArea("TRA")
	dbUseArea(.T., "TOPCONN", TcGenQry(,,cQry), "TRA", .T., .T.)

	If EMPTY(TRA->CT2_LOTE)
		fCloseArea("TRA")

		//monta arquivo de trabalho
		fGetTrb(cDtaLan)

		//monta arquivo de trabalho
		fGrvTmp()
	Else
		FWAlertError(cMsg, "Já Existe Apuração CTA")
	Endif

Return

/*  fGrvTmp
    Desenvolvedor: Felipe Andrews
    Processo: Grava a tabela TMP
    Data: 31/01/2022
    Release: 12.1.25
*/
Static Function fGrvTmp(cDtaLan)
	Local nVlrRes := 0 //valor de resultado
	Local nNexLin := 0 //Contador da linha
	Local cUsrAtu := UsrRetName(RetCodUsr())

	dbSelectArea("IATRB")
	IATRB->(dbGoTop())
	If !IATRB->(Eof())
		dbSelectArea("TMP")
		If TMP->(RecLock("TMP",.F.))
			TMP->(dbDelete())
			TMP->(MsUnlock())
		EndIf
	EndIf

	Do While !IATRB->(Eof())
		nVlrRes := IATRB->CQ0_RESULT //valor de resultado
		If !Empty(nVlrRes)
			nNexLin++

			dbSelectArea("TMP")
			If TMP->(RecLock("TMP",.T.))
				TMP->CT2_FILIAL		:= xFilial()
				TMP->CT2_DATA		:= dDataLanc
				TMP->CT2_DATATX		:= dDataLanc
				TMP->CT2_DTCV3		:= dDataLanc
				TMP->CT2_LOTE		:= cLote
				TMP->CT2_SBLOTE		:= cSubLote
				TMP->CT2_DOC		:= cDoc
				TMP->CT2_LINHA		:= StrZero(nNexLin,03)
				TMP->CT2_FILORI		:= cFilAnt
				TMP->CT2_EMPORI		:= Substr(cNumEmp,01,02)
				TMP->CT2_HIST		:= "AJUSTE DE CONVERSAO CTA - CONTA " + IATRB->CQ0_CONTA
				TMP->CT2_VALR02	    := IIf(nVlrRes<0,nVlrRes*(-1),nVlrRes)
				If nVlrRes < 0                           // Caso o resultado seja crédito lança a débito na conta CTA
					TMP->CT2_DEBITO	:= IATRB->CT1_TRNSEF
					TMP->CT2_DC		:= "1"
				else                                     // Caso o resultado seja débito lança a crédito na conta CTA
					TMP->CT2_CREDIT	:= IATRB->CT1_TRNSEF
					TMP->CT2_DC		:= "2"
				EndIf
				TMP->CT2_SEQHIS		:= "001"
				TMP->CT2_SEQLAN		:= StrZero(nNexLin,03)
				TMP->CT2_MOEDLC		:= "02"
				TMP->CT2_TPSALD		:= "1"
				TMP->CT2_ROTINA		:= "CTBA102"		// Indica qual o programa gerador
				TMP->CT2_MANUAL		:= "1"				// Lancamento manual
				TMP->CT2_AGLUT		:= "2"				// Nao aglutina
				TMP->CT2_ORIGEM 	:= "IACTBP01 - APURACAO DE CTA - USUARIO: " + cUsrAtu
				TMP->CT2_CRCONV		:= "4"
				TMP->CT2_CTRLSD		:= "2"

				TMP->(MsUnlock())
			EndIf
		EndIf

		IATRB->(dbSkip())
	EndDo

Return


/*  fGetTrb
    Desenvolvedor: Felipe Andrews
    Processo: Faz a montagem do arquivo de trabalho temporário
    Data: 31/01/2022
    Release: 12.1.25
*/
Static Function fGetTrb(cDtaLan)
	Local cQrySql := "" /* query de consulta SQL */

	/* montagem da clausula SELECT */
	cQrySql += " SELECT TRB.CQ0_CONTA, TRB.CT1_TRNSEF, (TRB.CQ0_DEBITO - TRB.CQ0_CREDIT) AS CQ0_RESULT "

    /* montagem da clausula FROM */
	cQrySql += " FROM ( "

	/* montagem da clausula SELECT */
	cQrySql += " SELECT CQ0.CQ0_CONTA, CT1.CT1_TRNSEF, SUM(CQ0.CQ0_DEBITO) AS CQ0_DEBITO, SUM(CQ0.CQ0_CREDIT) AS CQ0_CREDIT "

	/* montagem da clausula FROM */
	cQrySql += " FROM " + RetSqlName("CQ0") + " CQ0 "

	/* montagem da clausula INNER JOIN */
	cQrySql += " INNER JOIN " + RetSqlName("CT1") + " CT1 "
	cQrySql += " ON ( CT1.CT1_CONTA = CQ0.CQ0_CONTA "
	cQrySql += " AND CT1.D_E_L_E_T_ <>  '*' ) "

	/* montagem da clausula WHERE */
	cQrySql += " WHERE CQ0.CQ0_DATA = '" + cDtaLan + "' "
	cQrySql += " AND CQ0.CQ0_MOEDA = '02' "
	cQrySql += " AND CQ0.D_E_L_E_T_ <> '*' "

	/* montagem da clausula GROUP BY */
	cQrySql += " GROUP BY CQ0.CQ0_CONTA, CT1.CT1_TRNSEF "
	cQrySql += " ) TRB "

	/* montagem da clausula ORDER BY */
	cQrySql += " ORDER BY TRB.CT1_TRNSEF "

	fCloseArea("IATRB")
	dbUseArea(.T., "TOPCONN",TCGenQry(,,cQrySql),"IATRB",.T., .T.)

Return

/*
    Desenvolvedor: Felipe Andrews
    Processo: fecha area aberta
    Data: 31/01/2022
    Release: 12.1.25
*/
Static Function fCloseArea(pCodTab)
	If (Select(pCodTab)!= 0)
		dbSelectArea(pCodTab)
		dbCloseArea()
		If File(pCodTab+GetDBExtension())
			fErase(pCodTab+GetDBExtension())
		EndIf
	EndIf

Return
