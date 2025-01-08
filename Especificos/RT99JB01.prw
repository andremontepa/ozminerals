#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} RT99JB01
Funcao que valida de o Ambiente esta Exclusivo para execucao via JOB.
@author 	Ricardo Tavares Ferreira
@since 		31/07/2018
@version 	12.1.17
@return 	Logico
@Obs 		Ricardo Tavares - Construcao Inicial
/*/
//==========================================================================================================
	User Function RT99JB01()
//==========================================================================================================
		
	Private nRpl	:= 150
	Private oSay	:= Nil
	
	FWMsgRun(, {|oSay| PROC_INT(oSay) },"Faturamento da Ordem de Carregamento", "Encerrando Ordem de Carregamento...")
	
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
	Static Function PROC_INT(oSay)
//==========================================================================================================
	
	Local QBLINHA		:= chr(13)+chr(10)
	
	If GET_DADOS()
		
		DbSelectArea("SZA")
		SZA->(DbSetOrder(1))
		
		DbSelectArea("SZ8")
		SZ8->(DbSetOrder(1))
		
		While ! TMP1->(EOF())
			
			cUpd := "UPDATE " + RetSqlName("SZA") +QBLINHA
			cUpd += "SET ZA_STATUS = '5'"+QBLINHA
			cUpd += "WHERE R_E_C_N_O_ = '"+cValToChar(TMP1->IDSZA)+"'"+QBLINHA
			
			If (TcSqlExec(cUpd) < 0)
				Conout("[RT99JB01][PROC_INT]  [" + Dtoc(DATE()) +" "+ Time()+ "]  Falha da Execução do UPDATE - SZA ...")
			Else
				Conout("[RT99JB01][PROC_INT]  [" + Dtoc(DATE()) +" "+ Time()+ "]  Update na Tabela SZA executado com sucesso ...")
			EndIf

			cUpd := "UPDATE " + RetSqlName("SZ8") +QBLINHA
			cUpd += "SET Z8_STATUS = '4'"+QBLINHA
			cUpd += "WHERE R_E_C_N_O_ = '"+cValToChar(TMP1->IDSZ8)+"'"+QBLINHA
			
			If (TcSqlExec(cUpd) < 0)
				Conout("[RT99JB01][PROC_INT]  [" + Dtoc(DATE()) +" "+ Time()+ "]  Falha da Execução do UPDATE - SZ8 ...")
			Else
				Conout("[RT99JB01][PROC_INT]  [" + Dtoc(DATE()) +" "+ Time()+ "]  Update na Tabela SZ8 executado com sucesso ...")
			EndIf
			
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
	
	If Select("TMP1") > 0								   
		TMP1->(DbCloseArea())								
	Endif
					
    cQuery := " SELECT "+QbLinha 
	cQuery += " ZA_COD ORDEM "+QbLinha  
	cQuery += " , ZA_NF NF "+QbLinha  
	cQuery += " , ZA_SERIE SERIE "+QbLinha 
	cQuery += " , ZA_CLIENTE CLIENTE "+QbLinha 
	cQuery += " , ZA_LOJA LOJA "+QbLinha 
	cQuery += " , SZA.R_E_C_N_O_ IDSZA "+QbLinha 
	cQuery += " , SZ8.R_E_C_N_O_ IDSZ8 "+QbLinha
	cQuery += " ,  ZA_STATUS STATUS "+QbLinha

	cQuery += "FROM "
	cQuery +=  RetSqlName("SZA") + " SZA "+QBLINHA
	 
	cQuery += "INNER JOIN "
	cQuery +=  RetSqlName("SZ8") + " SZ8 "+QBLINHA 
	cQuery += " ON Z8_COD = ZA_CONT "+QbLinha
	cQuery += " AND SZ8.D_E_L_E_T_ = ' ' "+QbLinha
	cQuery += " WHERE "+QbLinha 
	cQuery += " SZA.D_E_L_E_T_ = ' ' "+QbLinha  
	cQuery += " AND ZA_COD = '"+SZA->ZA_COD+"' "+QbLinha 
    
    MEMOWRITE("C:/ricardo/RT99JB01.sql",cQuery)			     
	cQuery := ChangeQuery(cQuery)
	DBUSEAREA(.T.,'TOPCONN',TcGenQry(,,cQuery),"TMP1",.F.,.T.)
		
	DBSELECTAREA("TMP1")
	TMP1->(DBGOTOP())
	COUNT TO NQTREG
	TMP1->(DBGOTOP())
		
	If NQTREG <= 0
		TMP1->(DBCLOSEAREA())
		Conout(Replicate("-",nRpl))
		Conout("[RT99JB01][GET_DADOS]  [" + Dtoc(DATE()) +" "+ Time()+ "]  Não ha dados para Integracao com o Protheus ...")
		Conout(Replicate("-",nRpl))
		Return .F.
	Else
		Conout(Replicate("-",nRpl))
		Conout("[RT99JB01][GET_DADOS]  [" + Dtoc(DATE()) +" "+ Time()+ "]  Dados Encontrados para integracao ...")
		Conout(Replicate("-",nRpl))
    EndIf
    
Return .T.
