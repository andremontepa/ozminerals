#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} RT99JB03
JOB Responsavel por marcar os registros que foram aprovados para envio do email.
@author 	Ricardo Tavares Ferreira
@since 		08/06/2019
@version 	12.1.17
@return 	Logico
@Obs 		Ricardo Tavares - Construcao Inicial
/*/
//==========================================================================================================
	User Function RT99JB03()
//==========================================================================================================
	
	Local aEmpresas := {}
	Local nX		:= 0
	Private nStart      := 0
	
	aadd(aEmpresas,{"01","AVB MINERACAO LTDA"})
	aadd(aEmpresas,{"02","VALE DOURADO MINERACAO LTDA"})
	aadd(aEmpresas,{"03","SANTA LUCIA MINERACAO LTDA"})
	aadd(aEmpresas,{"04","AVANCO RESOURCES MINERACAO LTDA"})
	aadd(aEmpresas,{"05","ACG MINERACAO LTDA"})
	aadd(aEmpresas,{"06","MCT MINERACAO LTDA"})
	aadd(aEmpresas,{"07","MINERACAO AGUAS BOAS LTDA"})

	For nX := 1 To Len(aEmpresas)
		RpcSetType(3)
		RpcSetEnv(aEmpresas[nX][1],"01")
		FwLogMsg("RT99JB03", /*cTransactionId*/, "RT99JB03", FunName(), "","[26]  [RT99JB03] [" + Dtoc(DATE()) +" "+ Time()+ "] Inicio da Execucao do JOB RT99JB03...", 0, (nStart - Seconds()), {})
		PROC_INT()
		FwLogMsg("RT99JB03", /*cTransactionId*/, "RT99JB03", FunName(), "","[28]  [RT99JB03] [" + Dtoc(DATE()) +" "+ Time()+ "] Fim da Execucao do JOB RT99JB03...", 0, (nStart - Seconds()), {})
		RpcClearEnv()
	Next nX	
Return

/*/{Protheus.doc} PROC_INT 
Função responsavel por processar a alteracao dos arquivos.
@author 	Ricardo Tavares Ferreira
@since 		08/06/2019
@version 	12.1.17
@return 	Logico
@Obs 		Ricardo Tavares - Construcao Inicial
/*/
//==========================================================================================================
	Static Function PROC_INT()
//==========================================================================================================

	If GET_DADOS()
		While .not. TMP1->(Eof())
			U_WFSENDPC(Alltrim(TMP1->FILIAL),Alltrim(TMP1->DOC),Alltrim(TMP1->TIPO))
			TMP1->(DbSkip())
		End
		TMP1->(DbCloseArea())
	EndIF
Return

/*/{Protheus.doc} GET_DADOS 
Função responsavel por buscar os dados para alteração
@author 	Ricardo Tavares Ferreira
@since 		08/06/2019
@version 	12.1.17
@return 	Logico
@Obs 		Ricardo Tavares - Construcao Inicial
/*/
//==========================================================================================================
	Static Function GET_DADOS()
//==========================================================================================================

	Local cQuery	:= ""
	Local QbLinha	:= chr(13)+chr(10)
	Local nQtdReg	:= 0

	cQuery := " SELECT TOP 1"+QbLinha 
	cQuery += " CR_NUM DOC "+QbLinha
	cQuery += " , CR_TIPO TIPO "+QbLinha
	//cQuery += " , CR_USER USER1 "+QbLinha
	//cQuery += " , CR_APROV APROV "+QbLinha
	//cQuery += " , CR_GRUPO GRUPO "+QbLinha
	//cQuery += " , CR_NIVEL NIVEL "+QbLinha 
	//cQuery += " , CR_STATUS STATUS "+QbLinha 
	//cQuery += " , CR_XENVMAI ENVMAIL "+QbLinha
	//cQuery += " , SCR.R_E_C_N_O_ IDSCR "+QbLinha
	//cQuery += " , CR_DATALIB DATALIB "+QbLinha
	cQuery += " , CR_FILIAL FILIAL  "+QbLinha

    cQuery += " FROM "
	cQuery +=   RetSqlName("SCR") + " SCR "+QbLinha 

	cQuery += " WHERE "+QbLinha 
	cQuery += " SCR.D_E_L_E_T_ = ' ' "+QbLinha 
	cQuery += " AND CR_XENVMAI <> 'S' "+QbLinha
	cQuery += " AND CR_TIPO = 'PC' "+QbLinha
	cQuery += " AND CR_STATUS ='02' "+QbLinha
	cQuery += " AND CR_DATALIB = ' ' "+QbLinha
	cQuery += " GROUP BY  CR_NUM , CR_TIPO , CR_FILIAL  "+QbLinha 
	//cQuery += " ORDER BY CR_NUM, CR_NIVEL "+QbLinha

    MemoWrite("C:/ricardo/RT99JB03.sql",cQuery)			     
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),"TMP1",.F.,.T.)
		
	DbSelectArea("TMP1")
	TMP1->(DbGoTop())
	Count TO nQtdReg
	TMP1->(DbGoTop())
		
	If nQtdReg <= 0
		TMP1->(DbCloseArea())
		FwLogMsg("RT99JB03", /*cTransactionId*/, "RT99JB03", FunName(), "","[106] [RT99JB03] [GET_DADOS] [" +Dtoc(DATE())+" "+Time()+ "]  Não ha dados para serem processados EMPRESA ["+cEmpAnt+"]...", 0, (nStart - Seconds()), {})
		Return .F.
    EndIf
Return .T.
