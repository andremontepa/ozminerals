#Include "Rwmake.ch"
#Include "Topconn.ch"
#include "TbiConn.ch"
#include "TbiCode.ch"
#include "protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMT116AGR บAutor  ณIsmael Junior        บ Data ณ  25/11/21   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  P.E. ap๓s a gravacao do documento de entrada              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function MT116AGR()

	Local _nXoper  := aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "D1_XOPER"})
	Local _nXprod  := aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "D1_COD"})
	Local _nXdoc   := aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "D1_NFORI"})
	Local _nXserie := aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "D1_SERIORI"})
	Static xOperOrig:= " "
	Static Xprod    := " "
	Static Xdoc     := " "
	Static Xserie   := " "
	Local i

	Private nStart      := 0

	// Gerenciamento do bloqueio na inclusใo do contas a pagar
	// Envio de workflow solicitando aprova็ใo
	If SF1->F1_TIPO = 'C' .AND. SF1->F1_TPCOMPL = '3'
		cUpdate := "UPDATE " + RetSqlName("SE2") + " SET E2_DATALIB = '" + DTOS(date()) + "' "
		cUpdate += "WHERE E2_FILIAL = '" + SE2->E2_FILIAL + "' ""
		cUpdate += "AND E2_PREFIXO = '" + SE2->E2_PREFIXO + "' "
		cUpdate += "AND E2_NUM = '" + SE2->E2_NUM + "' "
		cUpdate += "AND E2_FORNECE = '" + SE2->E2_FORNECE + "'
		cUpdate += "AND E2_LOJA = '" + SE2->E2_LOJA + "'
		cUpdate += "AND D_E_L_E_T_ = ' ' "
		nFlag := TcSqlExec(cUpdate)
	Else
		cGrupoAp := GETMV("MV_XNFAPRO")
		cQuery:="SELECT AL_USER,AL_NIVEL,AL_COD "
		cQuery+="FROM "+RetSqlName("SAL")+" SAL "
		cQuery+="WHERE AL_FILIAL='"+xFilial("SAL")+"'
		cQuery+="AND AL_COD = '" + cGrupoAp + "' "
		cQuery+="AND SAL.D_E_L_E_T_ = ' ' "
		If SELECT("SALTB") > 0
			SALTB->(DbCloseArea())
		Endif
		ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"SALTB",.T.,.T.)

		DbSelectArea("SZC")
		SZC->(DbSetOrder(1))
		Do While SALTB->(!Eof())
			RecLock("SZC",.T.)
			SZC->ZC_FILIAL   := XFILIAL("SZC")
			SZC->ZC_PREFIXO  := SE2->E2_PREFIXO
			SZC->ZC_NUM      := SE2->E2_NUM
			SZC->ZC_PARCELA  := SE2->E2_PARCELA
			SZC->ZC_TIPO     := SE2->E2_TIPO
			SZC->ZC_FORNECE  := SE2->E2_FORNECE
			SZC->ZC_LOJA     := SE2->E2_LOJA
			SZC->ZC_APROVA   := SALTB->AL_USER
			SZC->ZC_GRUPO    := SALTB->AL_COD
			SZC->ZC_NIVEL    := SALTB->AL_NIVEL
			SZC->(MsUnLock())
			SALTB->(dbSkip())
		EndDo
		//Envio do workflow
		//Inicio o Processo, enviando o e-mail.
		dbSelectArea("SE2")
		SE2->(dbSetOrder(06))
		If SE2->(dbSeek(xFilial("SE2") + SF1->F1_FORNECE + SF1->F1_LOJA + SF1->F1_SERIE + SF1->F1_DOC))
			u_WF050INC( , , SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,SE2->E2_TIPO,SE2->E2_FORNECE,SE2->E2_LOJA )
		Endif
// Pesquisa tipo TX - 
		cUpdate := "UPDATE " + RetSqlName("SE2") + " SET E2_DATALIB = '" + DTOS(date()) + "' "
		cUpdate += "WHERE E2_FILIAL = '" + SE2->E2_FILIAL + "' ""
		cUpdate += "AND E2_PREFIXO = '" + SE2->E2_PREFIXO + "' "
		cUpdate += "AND E2_NUM = '" + SE2->E2_NUM + "' "
		cUpdate += "AND E2_TIPO IN ('TX','INS','ISS') "
		//cUpdate += "AND E2_FORNECE = 'UNIAO' "
		//cUpdate += "AND E2_LOJA = '00' "
		cUpdate += "AND D_E_L_E_T_ = ' ' "
		nFlag := TcSqlExec(cUpdate)
	Endif

/*/{Protheus.doc} MT116AGR
(Ponto de entrada para gravar os campos que nรฃo gravados diretamente via Execuato da rotina MATA116  )
/*/
	If IsInCallStack("U_MTUFOPRO")

		cQryExc :=" UPDATE "+RetSqlName("SF1")+" "+CHR(13)+CHR(10)
		cQryExc +=" SET F1_USUSMAR   = '"+cUserAbx+"',"+CHR(13)+CHR(10)
		cQryExc +="    F1_EST     = '"+aCabec[aScan(aCabec,{|x| AllTrim(x[1]) == "F1_UFORITR"})][2]+"',"+CHR(13)+CHR(10)
		cQryExc +="    F1_UFORITR = '"+aCabec[aScan(aCabec,{|x| AllTrim(x[1]) == "F1_UFORITR"})][2]+"',"+CHR(13)+CHR(10)
		cQryExc +="    F1_MUORITR = '"+aCabec[aScan(aCabec,{|x| AllTrim(x[1]) == "F1_MUORITR"})][2]+"',"+CHR(13)+CHR(10)
		cQryExc +="    F1_UFDESTR = '"+aCabec[aScan(aCabec,{|x| AllTrim(x[1]) == "F1_UFDESTR"})][2]+"',"+CHR(13)+CHR(10)
		cQryExc +="    F1_MUDESTR = '"+aCabec[aScan(aCabec,{|x| AllTrim(x[1]) == "F1_MUDESTR"})][2]+"',"+CHR(13)+CHR(10)
		cQryExc +="    F1_TPCTE   = '"+cTipCTE+"',"+CHR(13)+CHR(10)
		cQryExc +="    F1_CHVNFE  = '"+cCHVCTE+"',"+CHR(13)+CHR(10)
		cQryExc +="    F1_DTCPISS = '"+Dtos(cDTCPiss)+"', "+CHR(13)+CHR(10)
		cQryExc +="    F1_MODAL   = '"+cModal+"' "+CHR(13)+CHR(10)
		cQryExc +=" WHERE F1_DOC = '"+cNFiscal+"'"+CHR(13)+CHR(10)
		cQryExc +=" AND F1_SERIE = '"+cSerie+"'"+CHR(13)+CHR(10)
		cQryExc +=" AND F1_FORNECE = '"+cA100For+"'"+CHR(13)+CHR(10)
		cQryExc +=" AND F1_LOJA = '"+cLoja+"'"+CHR(13)+CHR(10)
		cQryExc +=" AND D_E_L_E_T_ <> '*'"+CHR(13)+CHR(10)

		If (TCSQLExec(cQryExc) < 0)
			FwLogMsg("MT116AGR", /*cTransactionId*/, "MT116AGR", FunName(), "","TCSQLError() " + TCSQLError(), 0, (nStart - Seconds()), {})
		EndIf

		//Stephen Noel de Melo Ribeiro - Equilibrio Tecnologia - 21/09/2022
		Criatmp1()
		DbSelectArea('TMP1')
		While TMP1->(!EoF())
			SD1->(dbSeek(xfilial("SD1")+SF8->F8_NFORIG+SF8->F8_SERORIG+SF8->F8_FORNECE+SF8->F8_LOJA,.t.))
			While !SD1->(eof()) .and. ;
					xFilial("SD1") == SD1->D1_FILIAL .and.;
					SF8->F8_NFORIG == SD1->D1_DOC     .and.;
					SF8->F8_SERORIG == SD1->D1_SERIE   .and.;
					SF8->F8_FORNECE == SD1->D1_FORNECE .and.;
					SF8->F8_LOJA    == SD1->D1_LOJA .and.;
					TMP1->PROD      == SD1->D1_COD

				RecLock("SD1", .F.)
				SD1->D1_XOPER:= TMP1->XOPER
				SD1->(MsUnlock())
				SD1->(DBSKIP())
			End
			TMP1->(DBSKIP())
		End
		TMP1->(DBCLOSEAREA( ))

	EndIf

Return nil


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  CriaTmp1 บAutor  ณStephen Noel          บ Data ณ  21/09/2022 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Busca D1_XOPER                                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function CriaTmp1()

	Local cQuery := ""


	cQuery := " SELECT "
	cQuery += " D1_XOPER XOPER, D1_COD PROD "
	cQuery += " FROM SF8010 SF8 "
	cQuery += " INNER JOIN SD1010 SD1 ON D1_DOC = F8_NFORIG AND D1_SERIE = SF8.F8_SERORIG "
	cQuery += " AND SD1.D1_FORNECE = SF8.F8_FORNECE AND SD1.D1_LOJA = SF8.F8_LOJA AND SD1.D_E_L_E_T_ = ' '"
	cQuery += " WHERE F8_NFDIFRE = '"+cNFiscal+"' "
	cQuery += " AND F8_SEDIFRE = '"+cSerie+"' "
	cQuery += " AND SF8.D_E_L_E_T_ = ' ' "
	cQuery += " AND SF8.F8_TRANSP = '"+cA100For+"' "
	cQuery += " AND SF8.F8_LOJTRAN = '"+cLoja+"' "


	if Select("TMP1") <> 0
		TMP1->(dbCloseArea())
	Endif

	MemoWrite("C:/ricardo/"+SB1->B1_COD+".sql",cQuery)

	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),"TMP1",.F.,.T.)

Return
