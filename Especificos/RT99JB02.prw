#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} RT99JB02
Funcao que valida de o Ambiente esta Exclusivo para execucao via JOB.
@author 	Ricardo Tavares Ferreira
@since 		31/07/2018
@version 	12.1.17
@return 	Logico
@Obs 		Ricardo Tavares - Construcao Inicial
/*/
//==========================================================================================================
	User Function RT99JB02()
//==========================================================================================================
		
	Private nRpl	:= 150
	
	RpcSetType(3)
	RpcSetEnv("01","02")//Prepare Environment Empresa "01" Filial "01"
		
	PROC_INT()
	
	RpcClearEnv()
	
Return

/*/{Protheus.doc} PROC_INT 
Função responsavel por processar a integracao
@author 	Ricardo Tavares Ferreira
@since 		31/07/2018
@version 	12.1.17
@return 	Logico
@Obs 		Ricardo Tavares - Construcao Inicial
/*/
//==========================================================================================================
	Static Function PROC_INT()
//==========================================================================================================

	If GET_DADOS()
		
		DbSelectArea("SZA")
		SZA->(DbSetOrder(1))
		
		DbSelectArea("SZ8")
		SZ8->(DbSetOrder(1))
		
		While ! TMP1->(EOF())
			
			SZA->(DBGOTO(TMP1->IDSZA))
			RecLock("SZA",.F.)
				SZA->ZA_STATUS = '5'
			SZA->(MsUnlock())
			
			SZ8->(DBGOTO(TMP1->IDSZ8))
			RecLock("SZ8",.F.)
				SZ8->Z8_STATUS = '4'
			SZ8->(MsUnlock())
			
			TMP1->(DBSKIP())
		End
		TMP1->(DBCLOSEAREA())
	EndIf

Return

/*/{Protheus.doc} GET_DADOS 
Função responsavel por processar a integracao
@author 	Ricardo Tavares Ferreira
@since 		31/07/2018
@version 	12.1.17
@return 	Logico
@Obs 		Ricardo Tavares - Construcao Inicial
/*/
//==========================================================================================================
	Static Function GET_DADOS()
//==========================================================================================================

	Local cQuery		:= ""
	Local QBLINHA		:= chr(13)+chr(10)

    cQuery := "SELECT SZA.R_E_C_N_O_ IDSZA, SZ8.R_E_C_N_O_ IDSZ8 "+QbLinha 
    cQuery += "FROM "
	cQuery +=  RetSqlName("SZA") + " SZA "+QBLINHA 

    cQuery += "INNER JOIN "
	cQuery +=  RetSqlName("SF3") + " SF3 "+QBLINHA 
    cQuery += " ON F3_FILIAL = ZA_FILIAL "+QbLinha
    cQuery += " AND F3_NFISCAL = ZA_NF "+QbLinha
    cQuery += " AND F3_SERIE = ZA_SERIE "+QbLinha
    cQuery += " AND F3_CLIEFOR = ZA_CLIENTE "+QbLinha
    cQuery += " AND F3_LOJA = ZA_LOJA "+QbLinha
    cQuery += " AND SF3.D_E_L_E_T_ = '  ' "+QbLinha
    cQuery += " AND F3_OBSERV = ' ' "+QbLinha 
    cQuery += " AND F3_CHVNFE <> ' ' "+QbLinha 

    cQuery += "INNER JOIN "
	cQuery +=  RetSqlName("SZ8") + " SZ8 "+QBLINHA
    cQuery += "ON Z8_FILIAL = ZA_FILIAL"+QbLinha
    cQuery += "AND Z8_COD = ZA_CONT"+QbLinha
    cQuery += "AND SZ8.D_E_L_E_T_ = ' '"+QbLinha

    cQuery += " WHERE"+QbLinha
    cQuery += " SZA.D_E_L_E_T_ = ' ' "+QbLinha
    cQuery += " AND ZA_PEDIDO <> ' ' "+QbLinha 
    cQuery += " AND ZA_NF <> ' ' "+QbLinha
    cQuery += " AND ZA_SERIE <> ' ' "+QbLinha
    
    MEMOWRITE("C:/ricardo/RT99JB01.sql",cQuery)			     
	cQuery := ChangeQuery(cQuery)
	DBUSEAREA(.T.,'TOPCONN',TcGenQry(,,cQuery),"TMP1",.F.,.T.)
		
	DBSELECTAREA("TMP1")
	TMP1->(DBGOTOP())
	COUNT TO NQTREG
	TMP1->(DBGOTOP())
		
	If NQTREG <= 0
		TMP1->(DBCLOSEAREA())
		Conout("[RT99JB02][GET_DADOS]  [" + Dtoc(DATE()) +" "+ Time()+ "]  Não ha Ordens de Carregamento Pendentes de Encerramento ...")
		Return .F.
	Else
		Conout(Replicate("-",nRpl))
		Conout("[RT99JB02][GET_DADOS]  [" + Dtoc(DATE()) +" "+ Time()+ "] Ha Ordens de Carregamento Pendentes de Encerramento ...")
		Conout(Replicate("-",nRpl))
    EndIf
    
Return .T.
